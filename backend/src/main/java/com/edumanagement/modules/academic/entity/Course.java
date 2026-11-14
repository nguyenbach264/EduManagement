package com.edumanagement.modules.academic.entity;

import com.edumanagement.common.base.BaseEntity;
import com.edumanagement.modules.student.entity.Teacher;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "courses")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Course extends BaseEntity {

    @Column(name = "code", nullable = false, unique = true, length = 20)
    private String code;

    @Column(name = "name", nullable = false, length = 150)
    private String name;

    @Column(name = "credits", nullable = false)
    private Integer credits;

    @Column(name = "theory_hours", nullable = false)
    private Integer theoryHours;

    @Column(name = "practice_hours", nullable = false)
    private Integer practiceHours;

    @Builder.Default
    @Column(name = "attendance_weight", nullable = false, precision = 4, scale = 2)
    private BigDecimal attendanceWeight = new BigDecimal("0.10");

    @Builder.Default
    @Column(name = "midterm_weight", nullable = false, precision = 4, scale = 2)
    private BigDecimal midtermWeight = new BigDecimal("0.30");

    @Builder.Default
    @Column(name = "final_weight", nullable = false, precision = 4, scale = 2)
    private BigDecimal finalWeight = new BigDecimal("0.60");

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id", nullable = false)
    private Department department;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "course_prerequisites",
            joinColumns = @JoinColumn(name = "course_id"),
            inverseJoinColumns = @JoinColumn(name = "prerequisite_id")
    )
    @Builder.Default
    private Set<Course> prerequisites = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "course_teachers",
            joinColumns = @JoinColumn(name = "course_id"),
            inverseJoinColumns = @JoinColumn(name = "teacher_id")
    )
    @Builder.Default
    private Set<Teacher> assignedTeachers = new HashSet<>();
}
