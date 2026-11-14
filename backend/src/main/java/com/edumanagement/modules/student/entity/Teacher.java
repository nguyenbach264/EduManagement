package com.edumanagement.modules.student.entity;

import com.edumanagement.common.base.BaseEntity;
import com.edumanagement.modules.academic.entity.Department;
import com.edumanagement.modules.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "teachers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Teacher extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "teacher_code", nullable = false, unique = true, length = 20)
    private String teacherCode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id", nullable = false)
    private Department department;

    @Column(name = "academic_rank", length = 50)
    private String academicRank; // e.g., ThS, TS, PGS, GS

    @Column(name = "academic_title", length = 50)
    private String academicTitle; // e.g., Tiến sĩ, Phó Giáo sư, Thạc sĩ

    @Column(name = "phone", length = 30)
    private String phone; // e.g., 0912 345 678

    @Column(name = "email", length = 100)
    private String email; // e.g., giangvien@daihoc.edu.vn

    @Column(name = "office_address", length = 150)
    private String officeAddress; // e.g., P.405 - Tòa nhà A1 - Cơ sở 1
}
