package com.edumanagement.modules.grade.service;

import com.edumanagement.modules.academic.entity.Course;
import com.edumanagement.modules.grade.dto.GradeDtos.StudentCourseGradeDto;
import com.edumanagement.modules.grade.entity.Grade;
import com.edumanagement.modules.grade.repository.GradeRepository;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class GpaCalculationService {

    private final GradeRepository gradeRepository;

    @Data
    @Builder
    public static class AcademicSummary {
        private BigDecimal cumulativeGpa;      // CPA tích lũy toàn khóa (quy đổi thang 4)
        private BigDecimal cumulativeScore10;  // Điểm tích lũy hệ 10
        private int totalCreditsEarned;        // Tổng số tín chỉ đã tích lũy (điểm >= 4.0)
        private int totalCreditsAttempted;     // Tổng số tín chỉ đã học
        private String academicClassification; // Xuất sắc, Giỏi, Khá, Trung bình, Yếu
        private Map<String, SemesterGpa> semesterGpas; // GPA theo từng kỳ
        private List<StudentCourseGradeDto> courseGrades; // Chi tiết từng môn
    }

    @Data
    @Builder
    public static class SemesterGpa {
        private String semesterCode;
        private String semesterName;
        private BigDecimal semesterGpa4;
        private BigDecimal semesterScore10;
        private int creditsRegistered;
        private int creditsPassed;
    }

    /**
     * TÍNH ĐIỂM CPA TÍCH LŨY TOÀN KHÓA:
     * Quy chế tín chỉ Bộ GD&ĐT: Khi sinh viên học cải thiện (hoặc học lại),
     * hệ thống sẽ lấy ĐIỂM CAO NHẤT giữa các lần học để tính vào CPA tích lũy.
     */
    @Transactional(readOnly = true)
    public AcademicSummary calculateStudentCumulativeSummary(Long studentId) {
        List<Grade> allGrades = gradeRepository.findAllGradesByStudentId(studentId);

        if (allGrades.isEmpty()) {
            return AcademicSummary.builder()
                    .cumulativeGpa(BigDecimal.ZERO)
                    .cumulativeScore10(BigDecimal.ZERO)
                    .totalCreditsEarned(0)
                    .totalCreditsAttempted(0)
                    .academicClassification("Chưa có điểm")
                    .semesterGpas(Collections.emptyMap())
                    .courseGrades(Collections.emptyList())
                    .build();
        }

        // 1. Gom nhóm theo từng Môn học (Course ID) để tìm điểm cao nhất cho từng môn
        Map<Long, List<Grade>> gradesByCourse = allGrades.stream()
                .collect(Collectors.groupingBy(g -> g.getEnrollment().getClassSection().getCourse().getId()));

        BigDecimal totalWeightedGpa4 = BigDecimal.ZERO;
        BigDecimal totalWeightedScore10 = BigDecimal.ZERO;
        int totalCreditsForCpa = 0;
        int totalCreditsEarned = 0;

        for (Map.Entry<Long, List<Grade>> entry : gradesByCourse.entrySet()) {
            List<Grade> courseGrades = entry.getValue();

            // Lấy điểm có gpaScore4 cao nhất trong tất cả các lần học của môn này
            Grade bestGrade = courseGrades.stream()
                    .max(Comparator.comparing(Grade::getGpaScore4))
                    .orElse(courseGrades.get(0));

            Course course = bestGrade.getEnrollment().getClassSection().getCourse();
            int credits = course.getCredits();

            totalWeightedGpa4 = totalWeightedGpa4.add(bestGrade.getGpaScore4().multiply(BigDecimal.valueOf(credits)));
            totalWeightedScore10 = totalWeightedScore10.add(bestGrade.getTotalScore10().multiply(BigDecimal.valueOf(credits)));
            totalCreditsForCpa += credits;

            if (bestGrade.isPassed()) {
                totalCreditsEarned += credits;
            }
        }

        BigDecimal cumulativeGpa = totalCreditsForCpa > 0
                ? totalWeightedGpa4.divide(BigDecimal.valueOf(totalCreditsForCpa), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        BigDecimal cumulativeScore10 = totalCreditsForCpa > 0
                ? totalWeightedScore10.divide(BigDecimal.valueOf(totalCreditsForCpa), 1, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        // 2. Tính GPA riêng cho từng học kỳ
        Map<String, List<Grade>> gradesBySemester = allGrades.stream()
                .collect(Collectors.groupingBy(g -> g.getEnrollment().getClassSection().getSemester().getCode()));

        Map<String, SemesterGpa> semesterGpaMap = new HashMap<>();
        for (Map.Entry<String, List<Grade>> entry : gradesBySemester.entrySet()) {
            String semCode = entry.getKey();
            List<Grade> semGrades = entry.getValue();

            BigDecimal semWeightedGpa = BigDecimal.ZERO;
            BigDecimal semWeighted10 = BigDecimal.ZERO;
            int semCredits = 0;
            int semPassedCredits = 0;

            String semName = semGrades.get(0).getEnrollment().getClassSection().getSemester().getName();

            for (Grade g : semGrades) {
                int cr = g.getEnrollment().getClassSection().getCourse().getCredits();
                semWeightedGpa = semWeightedGpa.add(g.getGpaScore4().multiply(BigDecimal.valueOf(cr)));
                semWeighted10 = semWeighted10.add(g.getTotalScore10().multiply(BigDecimal.valueOf(cr)));
                semCredits += cr;
                if (g.isPassed()) {
                    semPassedCredits += cr;
                }
            }

            BigDecimal semGpa4 = semCredits > 0
                    ? semWeightedGpa.divide(BigDecimal.valueOf(semCredits), 2, RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;

            BigDecimal semScore10 = semCredits > 0
                    ? semWeighted10.divide(BigDecimal.valueOf(semCredits), 1, RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;

            semesterGpaMap.put(semCode, SemesterGpa.builder()
                    .semesterCode(semCode)
                    .semesterName(semName)
                    .semesterGpa4(semGpa4)
                    .semesterScore10(semScore10)
                    .creditsRegistered(semCredits)
                    .creditsPassed(semPassedCredits)
                    .build());
        }

        List<StudentCourseGradeDto> courseGradeDtos = allGrades.stream()
                .map(g -> {
                    var cs = g.getEnrollment().getClassSection();
                    var c = cs.getCourse();
                    var sem = cs.getSemester();
                    return StudentCourseGradeDto.builder()
                            .gradeId(g.getId())
                            .enrollmentId(g.getEnrollment().getId())
                            .classSectionId(cs.getId())
                            .semesterCode(sem.getCode())
                            .semesterName(sem.getName())
                            .sectionCode(cs.getSectionCode())
                            .courseCode(c.getCode())
                            .courseName(c.getName())
                            .credits(c.getCredits())
                            .attendanceWeight(c.getAttendanceWeight())
                            .midtermWeight(c.getMidtermWeight())
                            .finalWeight(c.getFinalWeight())
                            .regularScore1(g.getRegularScore1() != null ? g.getRegularScore1() : g.getAttendanceScore())
                            .regularScore2(g.getRegularScore2() != null ? g.getRegularScore2() : g.getAttendanceScore())
                            .attendanceScore(g.getAttendanceScore())
                            .midtermScore(g.getMidtermScore())
                            .finalScore(g.getFinalScore())
                            .totalScore10(g.getTotalScore10())
                            .gpaScore4(g.getGpaScore4())
                            .letterGrade(g.getLetterGrade())
                            .locked(g.isLocked())
                            .passed(g.isPassed())
                            .build();
                })
                .collect(Collectors.toList());

        return AcademicSummary.builder()
                .cumulativeGpa(cumulativeGpa)
                .cumulativeScore10(cumulativeScore10)
                .totalCreditsEarned(totalCreditsEarned)
                .totalCreditsAttempted(allGrades.stream().mapToInt(g -> g.getEnrollment().getClassSection().getCourse().getCredits()).sum())
                .academicClassification(classifyAcademicStanding(cumulativeGpa))
                .semesterGpas(semesterGpaMap)
                .courseGrades(courseGradeDtos)
                .build();
    }

    private String classifyAcademicStanding(BigDecimal gpa4) {
        double val = gpa4.doubleValue();
        if (val >= 3.60) return "Xuất sắc";
        if (val >= 3.20) return "Giỏi";
        if (val >= 2.50) return "Khá";
        if (val >= 2.00) return "Trung bình";
        return "Yếu";
    }
}
