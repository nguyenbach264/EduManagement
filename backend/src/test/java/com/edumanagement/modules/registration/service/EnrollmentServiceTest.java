package com.edumanagement.modules.registration.service;

import com.edumanagement.common.exception.AppException;
import com.edumanagement.common.exception.ConflictException;
import com.edumanagement.common.exception.ErrorCode;
import com.edumanagement.modules.academic.entity.Course;
import com.edumanagement.modules.academic.entity.Semester;
import com.edumanagement.modules.grade.entity.Grade;
import com.edumanagement.modules.grade.repository.GradeRepository;
import com.edumanagement.modules.registration.entity.ClassSection;
import com.edumanagement.modules.registration.entity.Enrollment;
import com.edumanagement.modules.registration.repository.ClassSectionRepository;
import com.edumanagement.modules.registration.repository.EnrollmentRepository;
import com.edumanagement.modules.student.entity.Student;
import com.edumanagement.modules.student.repository.StudentRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class EnrollmentServiceTest {

    @Mock
    private ClassSectionRepository classSectionRepository;

    @Mock
    private EnrollmentRepository enrollmentRepository;

    @Mock
    private StudentRepository studentRepository;

    @Mock
    private GradeRepository gradeRepository;

    @Mock
    private ScheduleValidationService scheduleValidationService;

    @InjectMocks
    private EnrollmentService enrollmentService;

    @Test
    @DisplayName("Lớp học phần đã đầy sĩ số -> Ném lỗi ConflictException SECTION_FULL")
    void testEnrollCourse_SectionFull() {
        Long studentId = 1L;
        Long sectionId = 10L;

        Student student = Student.builder().studentCode("2021600001").build();
        student.setId(studentId);

        Semester semester = Semester.builder().registerOpen(true).maxCredits(24).build();
        Course course = Course.builder().name("Mạng máy tính").credits(3).prerequisites(Collections.emptySet()).build();

        // Lớp đã đạt sĩ số tối đa 60/60
        ClassSection section = ClassSection.builder()
                .sectionCode("IT3050.01")
                .maxCapacity(60)
                .currentEnrolled(60)
                .semester(semester)
                .course(course)
                .build();
        section.setId(sectionId);

        when(studentRepository.findById(studentId)).thenReturn(Optional.of(student));
        when(classSectionRepository.findByIdWithPessimisticLock(sectionId)).thenReturn(Optional.of(section));

        ConflictException ex = assertThrows(ConflictException.class, () ->
                enrollmentService.enrollCourse(studentId, sectionId)
        );

        assertEquals(ErrorCode.SECTION_FULL, ex.getErrorCode());
        verify(enrollmentRepository, never()).save(any(Enrollment.class));
    }

    @Test
    @DisplayName("Chưa đạt môn tiên quyết -> Ném lỗi PREREQUISITE_NOT_MET")
    void testEnrollCourse_PrerequisiteNotMet() {
        Long studentId = 1L;
        Long sectionId = 20L;

        Student student = Student.builder().studentCode("2021600001").build();
        Semester semester = Semester.builder().registerOpen(true).maxCredits(24).build();

        // Môn tiên quyết: Nhập môn lập trình
        Course prereqCourse = Course.builder().code("IT1010").name("Nhập môn Lập trình").build();
        prereqCourse.setId(100L);

        // Môn muốn đăng ký: CTDL & GT (cần IT1010)
        Course advancedCourse = Course.builder()
                .code("IT2010")
                .name("Cấu trúc dữ liệu và giải thuật")
                .credits(3)
                .prerequisites(Set.of(prereqCourse))
                .build();

        ClassSection section = ClassSection.builder()
                .sectionCode("IT2010.01")
                .maxCapacity(60)
                .currentEnrolled(10)
                .semester(semester)
                .course(advancedCourse)
                .build();

        when(studentRepository.findById(studentId)).thenReturn(Optional.of(student));
        when(classSectionRepository.findByIdWithPessimisticLock(sectionId)).thenReturn(Optional.of(section));
        when(enrollmentRepository.findByStudentIdAndClassSectionId(studentId, sectionId)).thenReturn(Optional.empty());
        when(enrollmentRepository.isStudentEnrolledInCourseInSemester(studentId, advancedCourse.getId(), semester.getId())).thenReturn(false);

        // Sinh viên chưa có điểm đạt của môn tiên quyết
        when(gradeRepository.findPassedGradesByStudentAndCourse(studentId, 100L)).thenReturn(Collections.emptyList());

        AppException ex = assertThrows(AppException.class, () ->
                enrollmentService.enrollCourse(studentId, sectionId)
        );

        assertEquals(ErrorCode.PREREQUISITE_NOT_MET, ex.getErrorCode());
        assertTrue(ex.getMessage().contains("Nhập môn Lập trình"));
    }

    @Test
    @DisplayName("Đăng ký thành công -> Tăng sĩ số lớp lên 1 và lưu Enrollment + Grade")
    void testEnrollCourse_Success() {
        Long studentId = 1L;
        Long sectionId = 30L;

        Student student = Student.builder().studentCode("2021600001").build();
        Semester semester = Semester.builder().registerOpen(true).maxCredits(24).build();
        semester.setId(1L);

        Course course = Course.builder().name("Giải tích 1").credits(3).prerequisites(Collections.emptySet()).build();
        course.setId(5L);

        ClassSection section = ClassSection.builder()
                .sectionCode("BS1010.01")
                .maxCapacity(60)
                .currentEnrolled(59) // Còn đúng 1 slot
                .semester(semester)
                .course(course)
                .build();

        when(studentRepository.findById(studentId)).thenReturn(Optional.of(student));
        when(classSectionRepository.findByIdWithPessimisticLock(sectionId)).thenReturn(Optional.of(section));
        when(enrollmentRepository.findByStudentIdAndClassSectionId(studentId, sectionId)).thenReturn(Optional.empty());
        when(enrollmentRepository.isStudentEnrolledInCourseInSemester(studentId, course.getId(), semester.getId())).thenReturn(false);
        when(enrollmentRepository.findActiveEnrollmentsByStudentAndSemester(studentId, semester.getId())).thenReturn(Collections.emptyList());

        when(enrollmentRepository.save(any(Enrollment.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Enrollment enrollment = enrollmentService.enrollCourse(studentId, sectionId);

        assertNotNull(enrollment);
        assertEquals(60, section.getCurrentEnrolled()); // Đã tăng từ 59 lên 60
        verify(classSectionRepository).save(section);
        verify(gradeRepository).save(any(Grade.class));
    }
}
