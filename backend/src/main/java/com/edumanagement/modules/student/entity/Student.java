package com.edumanagement.modules.student.entity;

import com.edumanagement.common.base.BaseEntity;
import com.edumanagement.modules.academic.entity.AcademicProgram;
import com.edumanagement.modules.academic.entity.Department;
import com.edumanagement.modules.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "students")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Student extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "student_code", nullable = false, unique = true, length = 20)
    private String studentCode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id", nullable = false)
    private Department department;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "program_id", nullable = false)
    private AcademicProgram academicProgram;

    @Column(name = "cohort", nullable = false)
    private Integer cohort; // e.g., 2021 (Khóa K16)

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(name = "academic_status", nullable = false, length = 20)
    private StudentStatus status = StudentStatus.STUDYING;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "gender", length = 10)
    private String gender;

    @Column(name = "address")
    private String address;

    @Column(name = "class_name", length = 50)
    private String className; // e.g. D21CNTT01, D22ANM01

    @Column(name = "province", length = 100)
    private String province; // 1 trong 34 tỉnh thành mới

    public enum StudentStatus {
        STUDYING,
        WARNING,
        SUSPENDED,
        DROPPED,
        GRADUATED
    }
}
