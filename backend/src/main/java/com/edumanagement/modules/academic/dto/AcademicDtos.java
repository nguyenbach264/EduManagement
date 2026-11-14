package com.edumanagement.modules.academic.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public class AcademicDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DepartmentDto {
        private Long id;
        private String code;
        private String name;
        private String phone;
        private String email;
        private String description;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DepartmentRequest {
        @NotBlank(message = "Mã khoa không được để trống")
        private String code;
        @NotBlank(message = "Tên khoa không được để trống")
        private String name;
        private String phone;
        @Email(message = "Email không hợp lệ")
        private String email;
        private String description;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AcademicProgramDto {
        private Long id;
        private String code;
        private String name;
        private Long departmentId;
        private String departmentCode;
        private String departmentName;
        private Integer totalCredits;
        private Integer durationYears;
        private String description;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AcademicProgramRequest {
        @NotBlank(message = "Mã chương trình không được để trống")
        private String code;
        @NotBlank(message = "Tên chương trình không được để trống")
        private String name;
        @NotNull(message = "Khoa quản lý không được để trống")
        private Long departmentId;
        @NotNull @Min(1)
        private Integer totalCredits;
        @NotNull @Min(1)
        private Integer durationYears;
        private String description;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SimpleCourseDto {
        private Long id;
        private String code;
        private String name;
        private Integer credits;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TeacherSummaryDto {
        private Long id;
        private String teacherCode;
        private String fullName;
        private String academicRank;
        private String academicTitle;
        private String phone;
        private String email;
        private String officeAddress;
        private String departmentName;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CourseDetailDto {
        private Long id;
        private String code;
        private String name;
        private Integer credits;
        private Integer theoryHours;
        private Integer practiceHours;
        private BigDecimal attendanceWeight;
        private BigDecimal midtermWeight;
        private BigDecimal finalWeight;
        private Long departmentId;
        private String departmentName;
        private List<SimpleCourseDto> prerequisites;
        private List<TeacherSummaryDto> assignedTeachers;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CourseDto {
        private Long id;
        private String code;
        private String name;
        private Integer credits;
        private Integer theoryHours;
        private Integer practiceHours;
        private BigDecimal attendanceWeight;
        private BigDecimal midtermWeight;
        private BigDecimal finalWeight;
        private Long departmentId;
        private String departmentName;
        private List<SimpleCourseDto> prerequisites;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CourseRequest {
        @NotBlank(message = "Mã môn học không được để trống")
        private String code;
        @NotBlank(message = "Tên môn học không được để trống")
        private String name;
        @NotNull @Min(1) @Max(15)
        private Integer credits;
        @NotNull @Min(0)
        private Integer theoryHours;
        @NotNull @Min(0)
        private Integer practiceHours;
        private BigDecimal attendanceWeight;
        private BigDecimal midtermWeight;
        private BigDecimal finalWeight;
        @NotNull(message = "Khoa quản lý không được để trống")
        private Long departmentId;
        private List<Long> prerequisiteIds;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProgramCourseDto {
        private Long id;
        private Long programId;
        private Long courseId;
        private String courseCode;
        private String courseName;
        private Integer credits;
        private String departmentName;
        private Integer semesterIndex;
        private boolean compulsory;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProgramCourseRequest {
        @NotNull
        private Long courseId;
        @NotNull @Min(1) @Max(12)
        private Integer semesterIndex;
        private boolean compulsory = true;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SemesterDto {
        private Long id;
        private String code;
        private String name;
        private String academicYear;
        private Integer semesterNumber;
        private LocalDate startDate;
        private LocalDate endDate;
        private boolean registerOpen;
        private Integer minCredits;
        private Integer maxCredits;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SemesterRequest {
        @NotBlank
        private String code;
        @NotBlank
        private String name;
        @NotBlank
        private String academicYear;
        @NotNull @Min(1) @Max(6)
        private Integer semesterNumber;
        @NotNull
        private LocalDate startDate;
        @NotNull
        private LocalDate endDate;
        private boolean registerOpen;
        @NotNull @Min(0)
        private Integer minCredits;
        @NotNull @Min(1)
        private Integer maxCredits;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreditLimitsRequest {
        @NotNull(message = "Số tín chỉ tối thiểu không được để trống")
        @Min(value = 0, message = "Số tín chỉ tối thiểu không được âm")
        private Integer minCredits;

        @NotNull(message = "Số tín chỉ tối đa không được để trống")
        @Min(value = 1, message = "Số tín chỉ tối đa phải lớn hơn 0")
        private Integer maxCredits;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DepartmentStat {
        private String departmentName;
        private long studentCount;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AdminDashboardDto {
        private long totalStudents;
        private long totalTeachers;
        private long totalDepartments;
        private long totalPrograms;
        private long totalCourses;
        private long openSectionsInActiveSemester;
        private long totalEnrollmentsInActiveSemester;
        private long lockedGradesCount;
        private long unlockedGradesCount;
        private String activeSemesterName;
        private List<DepartmentStat> departmentStats;
        private Map<String, Long> gradeDistribution;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SectionGradeSummaryDto {
        private Long classSectionId;
        private String sectionCode;
        private Long courseId;
        private String courseCode;
        private String courseName;
        private Integer credits;
        private String departmentName;
        private Long semesterId;
        private String semesterCode;
        private String semesterName;
        private String teacherName;
        private int totalStudents;
        private int gradedCount;
        private int lockedCount;
        private boolean allLocked;
        private boolean partiallyLocked;
        private String status; // "LOCKED" | "OPEN" | "PARTIAL"
    }
}
