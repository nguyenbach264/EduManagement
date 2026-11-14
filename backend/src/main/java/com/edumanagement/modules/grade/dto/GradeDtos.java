package com.edumanagement.modules.grade.dto;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;

public class GradeDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ClassGradeRowDto {
        private Long gradeId;
        private Long enrollmentId;
        private Long studentId;
        private String studentCode;
        private String studentName;
        private String className; // Lớp sinh hoạt
        private String sectionCode;
        private String courseCode;
        private String courseName;
        private Integer credits;
        private BigDecimal attendanceWeight;
        private BigDecimal midtermWeight;
        private BigDecimal finalWeight;
        private BigDecimal regularScore1; // Thường xuyên 1 (TX1)
        private BigDecimal regularScore2; // Thường xuyên 2 (TX2)
        private BigDecimal attendanceScore;
        private BigDecimal midtermScore;
        private BigDecimal finalScore;
        private BigDecimal totalScore10;
        private BigDecimal gpaScore4;
        private String letterGrade;
        private boolean locked;
        private boolean passed;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ClassSectionGradeReportDto {
        private Long classSectionId;
        private String sectionCode;
        private String courseCode;
        private String courseName;
        private Integer credits;
        private String teacherName;
        private String semesterName;
        private int totalStudents;
        private BigDecimal averageScore10;
        private java.util.Map<String, Long> gradeDistribution;
        private List<ClassGradeRowDto> students;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StudentCourseGradeDto {
        private Long gradeId;
        private Long enrollmentId;
        private Long classSectionId;
        private String semesterCode;
        private String semesterName;
        private String sectionCode;
        private String courseCode;
        private String courseName;
        private Integer credits;
        private BigDecimal attendanceWeight;
        private BigDecimal midtermWeight;
        private BigDecimal finalWeight;
        private BigDecimal regularScore1; // Thường xuyên 1 (TX1)
        private BigDecimal regularScore2; // Thường xuyên 2 (TX2)
        private BigDecimal attendanceScore;
        private BigDecimal midtermScore;
        private BigDecimal finalScore;
        private BigDecimal totalScore10;
        private BigDecimal gpaScore4;
        private String letterGrade;
        private boolean locked;
        private boolean passed;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AdminGradeRowDto {
        private Long gradeId;
        private String semesterCode;
        private String semesterName;
        private String sectionCode;
        private String courseCode;
        private String courseName;
        private String studentCode;
        private String studentName;
        private BigDecimal regularScore1; // Thường xuyên 1 (TX1)
        private BigDecimal regularScore2; // Thường xuyên 2 (TX2)
        private BigDecimal attendanceScore;
        private BigDecimal midtermScore;
        private BigDecimal finalScore;
        private BigDecimal totalScore10;
        private BigDecimal gpaScore4;
        private String letterGrade;
        private boolean locked;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TeacherDashboardDto {
        private String teacherCode;
        private String fullName;
        private String departmentName;
        private String academicRank;
        private String activeSemesterCode;
        private String activeSemesterName;
        private int totalClassesInSemester;
        private int totalStudentsInSemester;
        private int lockedClassesCount;
        private int pendingLockClassesCount;
        private List<com.edumanagement.modules.registration.dto.RegistrationDtos.ClassSectionDto> classes;
    }
}
