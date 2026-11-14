package com.edumanagement.modules.academic.entity;

import com.edumanagement.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "academic_programs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AcademicProgram extends BaseEntity {

    @Column(name = "code", nullable = false, unique = true, length = 20)
    private String code;

    @Column(name = "name", nullable = false, length = 150)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id", nullable = false)
    private Department department;

    @Column(name = "total_credits", nullable = false)
    private Integer totalCredits;

    @Column(name = "duration_years", nullable = false)
    private Integer durationYears;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
}
