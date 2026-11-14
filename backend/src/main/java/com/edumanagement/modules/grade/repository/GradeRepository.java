package com.edumanagement.modules.grade.repository;

import com.edumanagement.modules.grade.entity.Grade;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GradeRepository extends JpaRepository<Grade, Long> {

    Optional<Grade> findByEnrollmentId(Long enrollmentId);

    @Query("SELECT g FROM Grade g " +
            "JOIN FETCH g.enrollment e " +
            "JOIN FETCH e.student s " +
            "JOIN FETCH s.user u " +
            "JOIN FETCH e.classSection cs " +
            "JOIN FETCH cs.course c " +
            "WHERE cs.id = :classSectionId " +
            "ORDER BY s.studentCode ASC")
    List<Grade> findByClassSectionId(@Param("classSectionId") Long classSectionId);

    @Query("SELECT g FROM Grade g " +
            "JOIN FETCH g.enrollment e " +
            "JOIN FETCH e.classSection cs " +
            "JOIN FETCH cs.course c " +
            "JOIN FETCH cs.semester sem " +
            "WHERE e.student.id = :studentId " +
            "AND g.totalScore10 IS NOT NULL " +
            "ORDER BY sem.code DESC, c.code ASC")
    List<Grade> findAllGradesByStudentId(@Param("studentId") Long studentId);

    @Query("SELECT g FROM Grade g " +
            "JOIN g.enrollment e " +
            "JOIN e.classSection cs " +
            "WHERE e.student.id = :studentId " +
            "AND cs.course.id = :courseId " +
            "AND g.totalScore10 >= 4.0")
    List<Grade> findPassedGradesByStudentAndCourse(@Param("studentId") Long studentId, @Param("courseId") Long courseId);

    @Query(value = "SELECT g FROM Grade g " +
            "JOIN FETCH g.enrollment e " +
            "JOIN FETCH e.student s " +
            "JOIN FETCH s.user u " +
            "JOIN FETCH e.classSection cs " +
            "JOIN FETCH cs.course c " +
            "JOIN FETCH cs.semester sem " +
            "WHERE (:semesterId IS NULL OR sem.id = :semesterId) " +
            "AND (:locked IS NULL OR g.locked = :locked) " +
            "AND (:keyword IS NULL OR :keyword = '' OR LOWER(s.studentCode) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(u.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(cs.sectionCode) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(c.code) LIKE LOWER(CONCAT('%', :keyword, '%')))",
            countQuery = "SELECT COUNT(g) FROM Grade g " +
            "JOIN g.enrollment e JOIN e.student s JOIN s.user u JOIN e.classSection cs JOIN cs.course c JOIN cs.semester sem " +
            "WHERE (:semesterId IS NULL OR sem.id = :semesterId) " +
            "AND (:locked IS NULL OR g.locked = :locked) " +
            "AND (:keyword IS NULL OR :keyword = '' OR LOWER(s.studentCode) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(u.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(cs.sectionCode) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(c.code) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Grade> searchGradesForAdmin(
            @Param("semesterId") Long semesterId,
            @Param("locked") Boolean locked,
            @Param("keyword") String keyword,
            Pageable pageable
    );

    long countByLockedTrue();

    long countByLockedFalse();

    @Query("SELECT g.letterGrade, COUNT(g) FROM Grade g WHERE g.letterGrade IS NOT NULL GROUP BY g.letterGrade")
    List<Object[]> countByLetterGrade();
}
