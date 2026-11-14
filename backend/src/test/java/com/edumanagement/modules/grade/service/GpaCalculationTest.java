package com.edumanagement.modules.grade.service;

import com.edumanagement.modules.academic.entity.Course;
import com.edumanagement.modules.academic.entity.Semester;
import com.edumanagement.modules.grade.entity.Grade;
import com.edumanagement.modules.grade.repository.GradeRepository;
import com.edumanagement.modules.registration.entity.ClassSection;
import com.edumanagement.modules.registration.entity.Enrollment;
import com.edumanagement.modules.student.entity.Student;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GpaCalculationTest {

    @Mock
    private GradeRepository gradeRepository;

    @InjectMocks
    private GpaCalculationService gpaCalculationService;

    @Test
    @DisplayName("Học cải thiện: CPA phải lấy ĐIỂM CAO NHẤT giữa các lần học môn đó")
    void testGpaCalculation_RetakeUsesHighestScore() {
        Long studentId = 1L;

        // Môn học: Cơ sở dữ liệu (3 tín chỉ)
        Course dbCourse = Course.builder()
                .name("Cơ sở dữ liệu")
                .credits(3)
                .build();
        dbCourse.setId(10L);

        Semester sem1 = Semester.builder().code("20231").name("Học kỳ 1 2023-2024").build();
        Semester sem2 = Semester.builder().code("20232").name("Học kỳ 2 2023-2024").build();

        // Lần 1 học kỳ 1: Sinh viên được 5.0 (hệ 10) -> Thang 4 = 1.5 (D+)
        Enrollment enrollment1 = Enrollment.builder()
                .student(Student.builder().build())
                .classSection(ClassSection.builder().course(dbCourse).semester(sem1).build())
                .build();
        Grade gradeAttempt1 = Grade.builder()
                .enrollment(enrollment1)
                .totalScore10(new BigDecimal("5.0"))
                .gpaScore4(new BigDecimal("1.5"))
                .letterGrade("D+")
                .build();

        // Lần 2 học kỳ 2 (Học cải thiện): Sinh viên được 8.5 (hệ 10) -> Thang 4 = 3.7 (A)
        Enrollment enrollment2 = Enrollment.builder()
                .student(Student.builder().build())
                .classSection(ClassSection.builder().course(dbCourse).semester(sem2).build())
                .build();
        Grade gradeAttempt2 = Grade.builder()
                .enrollment(enrollment2)
                .totalScore10(new BigDecimal("8.5"))
                .gpaScore4(new BigDecimal("3.7"))
                .letterGrade("A")
                .build();

        when(gradeRepository.findAllGradesByStudentId(studentId))
                .thenReturn(List.of(gradeAttempt1, gradeAttempt2));

        // Thực hiện tính toán
        GpaCalculationService.AcademicSummary summary = gpaCalculationService.calculateStudentCumulativeSummary(studentId);

        // CPA phải lấy điểm lần 2 (3.7), không được tính trung bình cả 2 lần (3.7 + 1.5)/2 = 2.6
        assertEquals(new BigDecimal("3.70"), summary.getCumulativeGpa());
        assertEquals(new BigDecimal("8.5"), summary.getCumulativeScore10());
        assertEquals(3, summary.getTotalCreditsEarned());
        assertEquals("Xuất sắc", summary.getAcademicClassification()); // 3.70 >= 3.60 là Xuất sắc
    }

    @Test
    @DisplayName("Tính đúng GPA của từng học kỳ riêng biệt")
    void testGpaCalculation_SemesterGpaCalculatedCorrectly() {
        Long studentId = 2L;

        Course c1 = Course.builder().name("Toán rời rạc").credits(3).build();
        c1.setId(1L);
        Course c2 = Course.builder().name("Lập trình Java").credits(3).build();
        c2.setId(2L);

        Semester sem = Semester.builder().code("20241").name("Học kỳ 1 2024-2025").build();

        // Môn 1: Điểm 4 = 4.0 (A+)
        Grade g1 = Grade.builder()
                .enrollment(Enrollment.builder().classSection(ClassSection.builder().course(c1).semester(sem).build()).build())
                .totalScore10(new BigDecimal("9.5"))
                .gpaScore4(new BigDecimal("4.0"))
                .letterGrade("A+")
                .build();

        // Môn 2: Điểm 4 = 3.0 (B)
        Grade g2 = Grade.builder()
                .enrollment(Enrollment.builder().classSection(ClassSection.builder().course(c2).semester(sem).build()).build())
                .totalScore10(new BigDecimal("7.5"))
                .gpaScore4(new BigDecimal("3.0"))
                .letterGrade("B")
                .build();

        when(gradeRepository.findAllGradesByStudentId(studentId)).thenReturn(List.of(g1, g2));

        GpaCalculationService.AcademicSummary summary = gpaCalculationService.calculateStudentCumulativeSummary(studentId);

        // GPA = (4.0*3 + 3.0*3) / 6 = 3.50 -> 3.50 là Giỏi (3.20 - 3.59)
        assertEquals(new BigDecimal("3.50"), summary.getCumulativeGpa());
        assertEquals(6, summary.getTotalCreditsEarned());
        assertEquals("Giỏi", summary.getAcademicClassification());
    }
}
