package com.edumanagement.modules.academic.entity;

import com.edumanagement.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "program_courses", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"program_id", "course_id"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProgramCourse extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "program_id", nullable = false)
    private AcademicProgram program;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(name = "semester_index", nullable = false)
    private Integer semesterIndex; // Semester 1 to 8

    @Builder.Default
    @Column(name = "is_compulsory", nullable = false)
    private boolean compulsory = true;
}
