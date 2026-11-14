package com.edumanagement.modules.student.dto;

import com.edumanagement.modules.student.entity.Student;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDate;

public class StudentTeacherDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StudentDto {
        private Long id;
        private String studentCode;
        private String fullName;
        private String username;
        private String email;
        private String phone;
        private Long departmentId;
        private String departmentCode;
        private String departmentName;
        private Long programId;
        private String programCode;
        private String programName;
        private Integer cohort;
        private Student.StudentStatus status;
        private LocalDate dateOfBirth;
        private String gender;
        private String address;
        private boolean active;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateStudentRequest {
        @NotBlank(message = "Mã sinh viên không được để trống")
        private String studentCode;
        @NotBlank(message = "Họ tên không được để trống")
        private String fullName;
        @NotBlank(message = "Email không được để trống")
        @Email(message = "Email không hợp lệ")
        private String email;
        private String phone;
        @NotNull(message = "Khoa không được để trống")
        private Long departmentId;
        @NotNull(message = "Chương trình đào tạo không được để trống")
        private Long programId;
        @NotNull(message = "Khóa học không được để trống")
        private Integer cohort;
        private LocalDate dateOfBirth;
        private String gender;
        private String address;
        private String password; // optional, defaults to 123456
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpdateStudentRequest {
        @NotBlank(message = "Họ tên không được để trống")
        private String fullName;
        @Email(message = "Email không hợp lệ")
        private String email;
        private String phone;
        private Long departmentId;
        private Long programId;
        private Integer cohort;
        private Student.StudentStatus status;
        private LocalDate dateOfBirth;
        private String gender;
        private String address;
        private Boolean active;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TeacherDto {
        private Long id;
        private String teacherCode;
        private String fullName;
        private String username;
        private String email;
        private String phone;
        private Long departmentId;
        private String departmentCode;
        private String departmentName;
        private String academicRank;
        private String academicTitle;
        private String officeAddress;
        private boolean active;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateTeacherRequest {
        @NotBlank(message = "Mã giảng viên không được để trống")
        private String teacherCode;
        @NotBlank(message = "Họ tên không được để trống")
        private String fullName;
        @NotBlank(message = "Email không được để trống")
        @Email(message = "Email không hợp lệ")
        private String email;
        private String phone;
        @NotNull(message = "Khoa không được để trống")
        private Long departmentId;
        private String academicRank;
        private String academicTitle;
        private String officeAddress;
        private String password;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpdateTeacherRequest {
        @NotBlank(message = "Họ tên không được để trống")
        private String fullName;
        @Email(message = "Email không hợp lệ")
        private String email;
        private String phone;
        private Long departmentId;
        private String academicRank;
        private String academicTitle;
        private String officeAddress;
        private Boolean active;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ImportResultDto {
        private int totalRows;
        private int importedCount;
        private int skippedCount;
        private java.util.List<String> errors;
    }
}
