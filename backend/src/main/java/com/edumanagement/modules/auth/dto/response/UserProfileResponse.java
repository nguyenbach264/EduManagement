package com.edumanagement.modules.auth.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {

    private Long id;
    private String username;
    private String email;
    private String fullName;
    private String phone;
    private List<String> roles;
    private String studentCode; // If role is STUDENT
    private String teacherCode; // If role is TEACHER

    // Extended profile fields
    private Long departmentId;
    private String departmentName;
    private String departmentCode;
    private Long programId;
    private String programName;
    private String programCode;
    private String className;
    private String province;
    private String address;
    private LocalDate dateOfBirth;
    private String gender;
    private Integer cohort;
    private String academicStatus;

    // Teacher specific
    private String academicRank;
    private String academicTitle;
    private String officeAddress;
}
