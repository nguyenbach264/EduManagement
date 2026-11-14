package com.edumanagement.modules.academic.entity;

import com.edumanagement.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "semesters")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Semester extends BaseEntity {

    @Column(name = "code", nullable = false, unique = true, length = 10)
    private String code; // e.g., 20241 (HK1 2024-2025)

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "academic_year", nullable = false, length = 20)
    private String academicYear; // e.g., 2024-2025

    @Column(name = "semester_number", nullable = false)
    private Integer semesterNumber; // 1, 2, or 3 (summer)

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

    @Builder.Default
    @Column(name = "is_register_open", nullable = false)
    private boolean registerOpen = false;

    @Builder.Default
    @Column(name = "min_credits", nullable = false)
    private Integer minCredits = 12;

    @Builder.Default
    @Column(name = "max_credits", nullable = false)
    private Integer maxCredits = 24;
}
