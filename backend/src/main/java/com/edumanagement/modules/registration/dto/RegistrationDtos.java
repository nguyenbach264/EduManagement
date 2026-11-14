package com.edumanagement.modules.registration.dto;

import com.edumanagement.modules.registration.entity.ClassSection;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;
import java.util.List;

public class RegistrationDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ClassScheduleDto {
        private Long id;
        private Integer dayOfWeek;
        private Integer startPeriod;
        private Integer endPeriod;
        private String room;
        private Integer startWeek;
        private Integer endWeek;
        private String building;
        private String campus;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ClassScheduleRequest {
        @NotNull @Min(2) @Max(8)
        private Integer dayOfWeek;
        @NotNull @Min(1) @Max(15)
        private Integer startPeriod;
        @NotNull @Min(1) @Max(15)
        private Integer endPeriod;
        @NotBlank
        private String room;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ClassSectionDto {
        private Long id;
        private String sectionCode;
        private Long courseId;
        private String courseCode;
        private String courseName;
        private Integer credits;
        private Long semesterId;
        private String semesterCode;
        private String semesterName;
        private Long teacherId;
        private String teacherCode;
        private String teacherName;
        private Integer maxCapacity;
        private Integer currentEnrolled;
        private ClassSection.SectionStatus status;
        private Integer startWeek;
        private Integer endWeek;
        private String teachingStatus; // "TEACHING" | "FINISHED"
        private Boolean isLocked;
        private Boolean allGraded;
        private List<ClassScheduleDto> schedules;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ClassSectionRequest {
        @NotNull
        private Long courseId;
        @NotNull
        private Long semesterId;
        private Long teacherId;
        @NotBlank
        private String sectionCode;
        @NotNull @Min(1)
        private Integer maxCapacity;
        private ClassSection.SectionStatus status = ClassSection.SectionStatus.OPEN;
        @Valid
        private List<ClassScheduleRequest> schedules;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AvailableClassDto {
        private Long id;
        private String sectionCode;
        private Long courseId;
        private String courseCode;
        private String courseName;
        private Integer credits;
        private String departmentName;
        private Long semesterId;
        private String semesterCode;
        private String teacherName;
        private Integer maxCapacity;
        private Integer currentEnrolled;
        private boolean full;
        private boolean enrolled;
        private boolean sameCourseEnrolled;
        private boolean prerequisiteMet;
        private List<String> missingPrerequisites;
        private boolean scheduleConflict;
        private String conflictMessage;
        private boolean canEnroll;
        private List<ClassScheduleDto> schedules;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ScheduleItemDto {
        private Long enrollmentId;
        private Long classSectionId;
        private String sectionCode;
        private String courseCode;
        private String courseName;
        private Integer credits;
        private String teacherName;
        private String teacherPhone;
        private String teacherEmail;
        private String teacherRank;
        private Integer dayOfWeek;
        private Integer startPeriod;
        private Integer endPeriod;
        private Integer startWeek;
        private Integer endWeek;
        private Integer totalPeriods;
        private String room;
        private String building;
        private String campus;
        private String timeRange; // e.g. "07:00 - 09:25"
        private String semesterCode;
        private String semesterName;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CurriculumCourseDto {
        private Long courseId;
        private String courseCode;
        private String courseName;
        private Integer credits;
        private String departmentName;
        private Integer semesterIndex;
        private boolean compulsory;
        private String completionStatus; // PASSED, ENROLLED, NOT_TAKEN
        private BigDecimal bestScore10;
        private String letterGrade;
        private Integer theoryHours;
        private Integer practiceHours;
        private BigDecimal attendanceWeight;
        private BigDecimal midtermWeight;
        private BigDecimal finalWeight;
        private List<String> prerequisites;
        private List<String> teacherNames;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StudentDashboardDto {
        private String studentCode;
        private String fullName;
        private String departmentName;
        private String programName;
        private Integer cohort;
        private String academicStatus;
        private BigDecimal cumulativeGpa;
        private BigDecimal cumulativeScore10;
        private String academicClassification;
        private int totalCreditsEarned;
        private int programTotalCredits;
        private int currentSemesterCredits;
        private int currentSemesterMaxCredits;
        private int currentSemesterMinCredits;
        private String activeSemesterCode;
        private String activeSemesterName;
        private boolean registerOpen;
        private int enrolledCoursesCount;
    }
}
