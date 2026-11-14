package com.edumanagement.modules.registration.entity;

import com.edumanagement.common.base.BaseEntity;
import com.edumanagement.modules.academic.entity.Course;
import com.edumanagement.modules.academic.entity.Semester;
import com.edumanagement.modules.student.entity.Teacher;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "class_sections", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"semester_id", "section_code"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClassSection extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "semester_id", nullable = false)
    private Semester semester;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "teacher_id")
    private Teacher teacher;

    @Column(name = "section_code", nullable = false, length = 30)
    private String sectionCode; // e.g., "IT4010.01"

    @Column(name = "max_capacity", nullable = false)
    private Integer maxCapacity;

    @Builder.Default
    @Column(name = "current_enrolled", nullable = false)
    private Integer currentEnrolled = 0;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private SectionStatus status = SectionStatus.OPEN;

    @OneToMany(mappedBy = "classSection", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @Builder.Default
    private List<ClassSchedule> schedules = new ArrayList<>();

    public boolean isFull() {
        return currentEnrolled >= maxCapacity;
    }

    public enum SectionStatus {
        OPEN,
        CLOSED,
        CANCELLED
    }
}
