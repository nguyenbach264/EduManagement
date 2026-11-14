package com.edumanagement.modules.registration.repository;

import com.edumanagement.modules.registration.entity.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EnrollmentRepository extends JpaRepository<Enrollment, Long> {

    Optional<Enrollment> findByStudentIdAndClassSectionId(Long studentId, Long classSectionId);

    @Query("SELECT DISTINCT e FROM Enrollment e " +
            "JOIN FETCH e.classSection cs " +
            "JOIN FETCH cs.course c " +
            "JOIN FETCH cs.semester sem " +
            "LEFT JOIN FETCH cs.teacher t " +
            "LEFT JOIN FETCH t.user " +
            "LEFT JOIN FETCH cs.schedules sch " +
            "WHERE e.student.id = :studentId " +
            "AND sem.id = :semesterId " +
            "AND e.status = 'ENROLLED'")
    List<Enrollment> findActiveEnrollmentsByStudentAndSemester(
            @Param("studentId") Long studentId,
            @Param("semesterId") Long semesterId
    );

    @Query("SELECT e FROM Enrollment e " +
            "JOIN FETCH e.classSection cs " +
            "JOIN FETCH cs.course c " +
            "WHERE e.student.id = :studentId AND e.status = 'ENROLLED'")
    List<Enrollment> findAllActiveEnrollmentsByStudentId(@Param("studentId") Long studentId);

    @Query("SELECT COUNT(e) > 0 FROM Enrollment e " +
            "WHERE e.student.id = :studentId " +
            "AND e.classSection.course.id = :courseId " +
            "AND e.classSection.semester.id = :semesterId " +
            "AND e.status = 'ENROLLED'")
    boolean isStudentEnrolledInCourseInSemester(
            @Param("studentId") Long studentId,
            @Param("courseId") Long courseId,
            @Param("semesterId") Long semesterId
    );

    List<Enrollment> findByClassSectionId(Long classSectionId);

    List<Enrollment> findByClassSectionIdAndStatus(Long classSectionId, Enrollment.EnrollmentStatus status);

    @Query("SELECT COUNT(e) FROM Enrollment e WHERE e.classSection.semester.id = :semesterId AND e.status = 'ENROLLED'")
    long countActiveBySemesterId(@Param("semesterId") Long semesterId);
}
