package com.edumanagement.modules.registration.service;

import com.edumanagement.common.exception.AppException;
import com.edumanagement.common.exception.ConflictException;
import com.edumanagement.common.exception.ErrorCode;
import com.edumanagement.common.exception.ResourceNotFoundException;
import com.edumanagement.modules.academic.entity.Course;
import com.edumanagement.modules.academic.entity.Semester;
import com.edumanagement.modules.grade.entity.Grade;
import com.edumanagement.modules.grade.repository.GradeRepository;
import com.edumanagement.modules.registration.entity.ClassSchedule;
import com.edumanagement.modules.registration.entity.ClassSection;
import com.edumanagement.modules.registration.entity.Enrollment;
import com.edumanagement.modules.registration.repository.ClassSectionRepository;
import com.edumanagement.modules.registration.repository.EnrollmentRepository;
import com.edumanagement.modules.student.entity.Student;
import com.edumanagement.modules.student.repository.StudentRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class EnrollmentService {

    private final ClassSectionRepository classSectionRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final StudentRepository studentRepository;
    private final GradeRepository gradeRepository;
    private final ScheduleValidationService scheduleValidationService;

    /**
     * ĐĂNG KÝ HỌC PHẦN (CORE BUSINESS TRANSACTION)
     * Sử dụng Pessimistic Locking (SELECT ... FOR UPDATE) để đảm bảo không bị quá tải sĩ số (No Over-enrollment)
     * khi hàng trăm sinh viên cùng đăng ký 1 slot trong cùng 1 giây.
     */
    @Transactional(isolation = Isolation.REPEATABLE_READ)
    public Enrollment enrollCourse(Long studentId, Long classSectionId) {
        log.info("Bắt đầu xử lý đăng ký môn: studentId={}, classSectionId={}", studentId, classSectionId);

        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Sinh viên", "id", studentId));

        // 1. Khóa bản ghi lớp học phần bằng PESSIMISTIC_WRITE (Khóa dòng ở mức Database)
        ClassSection section = classSectionRepository.findByIdWithPessimisticLock(classSectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Lớp học phần", "id", classSectionId));

        Semester semester = section.getSemester();
        Course course = section.getCourse();

        // 2. Kiểm tra cổng đăng ký có mở không
        if (!semester.isRegisterOpen()) {
            throw new AppException(ErrorCode.REGISTRATION_CLOSED, "Cổng đăng ký tín chỉ học kỳ này hiện đang đóng");
        }

        if (section.getStatus() != ClassSection.SectionStatus.OPEN) {
            throw new AppException(ErrorCode.REGISTRATION_CLOSED, "Lớp học phần " + section.getSectionCode() + " hiện không mở đăng ký");
        }

        // 3. Kiểm tra sĩ số lớp
        if (section.isFull()) {
            log.warn("Lớp học phần {} đã đầy sĩ số ({}/{})", section.getSectionCode(), section.getCurrentEnrolled(), section.getMaxCapacity());
            throw new ConflictException(ErrorCode.SECTION_FULL, "Lớp học phần " + section.getSectionCode() + " đã hết chỗ đăng ký");
        }

        // 4. Kiểm tra sinh viên đã đăng ký lớp này chưa
        if (enrollmentRepository.findByStudentIdAndClassSectionId(studentId, classSectionId).isPresent()) {
            throw new ConflictException(ErrorCode.ALREADY_ENROLLED, "Bạn đã đăng ký lớp học phần này rồi");
        }

        // 5. Kiểm tra sinh viên đã đăng ký lớp khác của CÙNG MÔN HỌC này trong kỳ chưa
        if (enrollmentRepository.isStudentEnrolledInCourseInSemester(studentId, course.getId(), semester.getId())) {
            throw new ConflictException(ErrorCode.ALREADY_ENROLLED, "Bạn đã đăng ký một lớp học phần khác của môn '" + course.getName() + "' trong học kỳ này");
        }

        // 6. Kiểm tra điều kiện môn tiên quyết (Prerequisites)
        if (!course.getPrerequisites().isEmpty()) {
            for (Course prereq : course.getPrerequisites()) {
                List<Grade> passedGrades = gradeRepository.findPassedGradesByStudentAndCourse(studentId, prereq.getId());
                if (passedGrades.isEmpty()) {
                    throw new AppException(ErrorCode.PREREQUISITE_NOT_MET,
                            String.format("Bạn chưa đạt điều kiện môn tiên quyết: '%s (%s)'", prereq.getName(), prereq.getCode()));
                }
            }
        }

        // 7. Lấy danh sách các lớp đã đăng ký thành công trong kỳ để kiểm tra giới hạn tín chỉ và trùng lịch
        List<Enrollment> currentEnrollments = enrollmentRepository.findActiveEnrollmentsByStudentAndSemester(studentId, semester.getId());

        int currentTotalCredits = currentEnrollments.stream()
                .mapToInt(e -> e.getClassSection().getCourse().getCredits())
                .sum();

        if (currentTotalCredits + course.getCredits() > semester.getMaxCredits()) {
            throw new AppException(ErrorCode.CREDIT_LIMIT_EXCEEDED,
                    String.format("Vượt quá số tín chỉ tối đa (%d). Hiện tại: %d, thêm môn: %d",
                            semester.getMaxCredits(), currentTotalCredits, course.getCredits()));
        }

        // 8. Kiểm tra trùng thời khóa biểu (Schedule Conflict)
        List<ClassSchedule> existingSchedules = new ArrayList<>();
        for (Enrollment existingEnrollment : currentEnrollments) {
            existingSchedules.addAll(existingEnrollment.getClassSection().getSchedules());
        }
        scheduleValidationService.validateNoScheduleCollision(section.getSchedules(), existingSchedules);

        // 9. Thực hiện ghi danh và tăng số lượng sinh viên hiện tại của lớp
        section.setCurrentEnrolled(section.getCurrentEnrolled() + 1);
        classSectionRepository.save(section);

        Enrollment enrollment = Enrollment.builder()
                .student(student)
                .classSection(section)
                .enrolledAt(LocalDateTime.now())
                .status(Enrollment.EnrollmentStatus.ENROLLED)
                .build();

        enrollment = enrollmentRepository.save(enrollment);

        // Khởi tạo bản ghi điểm rỗng cho sinh viên
        Grade grade = Grade.builder()
                .enrollment(enrollment)
                .locked(false)
                .build();
        gradeRepository.save(grade);

        log.info("Đăng ký thành công: studentCode={}, sectionCode={}, enrolledCount={}/{}",
                student.getStudentCode(), section.getSectionCode(), section.getCurrentEnrolled(), section.getMaxCapacity());

        return enrollment;
    }

    /**
     * HỦY ĐĂNG KÝ HỌC PHẦN
     */
    @Transactional(isolation = Isolation.REPEATABLE_READ)
    public void dropCourse(Long studentId, Long classSectionId) {
        Enrollment enrollment = enrollmentRepository.findByStudentIdAndClassSectionId(studentId, classSectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thông tin đăng ký học phần này"));

        ClassSection section = classSectionRepository.findByIdWithPessimisticLock(classSectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Lớp học phần", "id", classSectionId));

        if (!section.getSemester().isRegisterOpen()) {
            throw new AppException(ErrorCode.REGISTRATION_CLOSED, "Cổng đăng ký tín chỉ đã đóng, không thể hủy môn");
        }

        Grade existingGrade = gradeRepository.findByEnrollmentId(enrollment.getId()).orElse(null);
        if (existingGrade != null && existingGrade.isLocked()) {
            throw new AppException(ErrorCode.GRADE_LOCKED, "Học phần đã khóa sổ điểm, không thể hủy đăng ký");
        }

        // Giảm sĩ số lớp
        if (section.getCurrentEnrolled() > 0) {
            section.setCurrentEnrolled(section.getCurrentEnrolled() - 1);
            classSectionRepository.save(section);
        }

        if (existingGrade != null) {
            gradeRepository.delete(existingGrade);
        }
        enrollmentRepository.delete(enrollment);

        log.info("Hủy môn thành công: studentId={}, sectionCode={}", studentId, section.getSectionCode());
    }

    /**
     * PHÒNG ĐÀO TẠO ÉP GHI DANH (Admin Force Enroll - bỏ qua giới hạn tín chỉ/cổng đóng)
     */
    @Transactional(isolation = Isolation.REPEATABLE_READ)
    public Enrollment forceEnroll(Long studentId, Long classSectionId) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("Sinh viên", "id", studentId));
        ClassSection section = classSectionRepository.findByIdWithPessimisticLock(classSectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Lớp học phần", "id", classSectionId));

        if (enrollmentRepository.findByStudentIdAndClassSectionId(studentId, classSectionId).isPresent()) {
            throw new ConflictException(ErrorCode.ALREADY_ENROLLED, "Sinh viên đã có trong lớp học phần này");
        }

        if (section.getCurrentEnrolled() >= section.getMaxCapacity()) {
            throw new ConflictException(ErrorCode.SECTION_FULL,
                    String.format("Lớp học phần %s đã đạt sĩ số tối đa (%d/%d sinh viên)",
                            section.getSectionCode(), section.getCurrentEnrolled(), section.getMaxCapacity()));
        }

        section.setCurrentEnrolled(section.getCurrentEnrolled() + 1);
        classSectionRepository.save(section);

        Enrollment enrollment = enrollmentRepository.save(Enrollment.builder()
                .student(student)
                .classSection(section)
                .enrolledAt(LocalDateTime.now())
                .status(Enrollment.EnrollmentStatus.ENROLLED)
                .build());

        gradeRepository.save(Grade.builder()
                .enrollment(enrollment)
                .locked(false)
                .build());
        return enrollment;
    }

    /**
     * PHÒNG ĐÀO TẠO ÉP HỦY GHI DANH (Admin Force Drop)
     */
    @Transactional(isolation = Isolation.REPEATABLE_READ)
    public void forceDrop(Long studentId, Long classSectionId) {
        Enrollment enrollment = enrollmentRepository.findByStudentIdAndClassSectionId(studentId, classSectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thông tin ghi danh của sinh viên trong lớp này"));
        ClassSection section = classSectionRepository.findByIdWithPessimisticLock(classSectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Lớp học phần", "id", classSectionId));

        if (section.getCurrentEnrolled() > 0) {
            section.setCurrentEnrolled(section.getCurrentEnrolled() - 1);
            classSectionRepository.save(section);
        }

        gradeRepository.findByEnrollmentId(enrollment.getId()).ifPresent(gradeRepository::delete);
        enrollmentRepository.delete(enrollment);
    }
}
