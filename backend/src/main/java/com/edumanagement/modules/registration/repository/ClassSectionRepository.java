package com.edumanagement.modules.registration.repository;

import com.edumanagement.modules.registration.entity.ClassSection;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClassSectionRepository extends JpaRepository<ClassSection, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT cs FROM ClassSection cs WHERE cs.id = :id")
    Optional<ClassSection> findByIdWithPessimisticLock(@Param("id") Long id);

    @Query("SELECT cs FROM ClassSection cs " +
            "JOIN FETCH cs.course c " +
            "JOIN FETCH cs.semester s " +
            "LEFT JOIN FETCH cs.teacher t " +
            "LEFT JOIN FETCH t.user " +
            "WHERE cs.id = :id")
    Optional<ClassSection> findByIdWithDetails(@Param("id") Long id);

    @Query("SELECT DISTINCT cs FROM ClassSection cs " +
            "JOIN FETCH cs.course c " +
            "JOIN FETCH cs.semester s " +
            "LEFT JOIN FETCH cs.teacher t " +
            "LEFT JOIN FETCH t.user " +
            "LEFT JOIN FETCH cs.schedules sch " +
            "WHERE s.id = :semesterId AND cs.status = 'OPEN' " +
            "ORDER BY cs.sectionCode ASC")
    List<ClassSection> findAvailableSectionsInSemester(@Param("semesterId") Long semesterId);

    @Query("SELECT DISTINCT cs FROM ClassSection cs " +
            "JOIN FETCH cs.course c " +
            "JOIN FETCH cs.semester s " +
            "LEFT JOIN FETCH cs.teacher t " +
            "LEFT JOIN FETCH t.user " +
            "LEFT JOIN FETCH cs.schedules sch " +
            "WHERE t.id = :teacherId AND s.id = :semesterId " +
            "ORDER BY cs.sectionCode ASC")
    List<ClassSection> findByTeacherIdAndSemesterIdWithDetails(
            @Param("teacherId") Long teacherId,
            @Param("semesterId") Long semesterId
    );

    List<ClassSection> findByTeacherIdAndSemesterId(Long teacherId, Long semesterId);

    Optional<ClassSection> findBySectionCode(String sectionCode);

    boolean existsBySemesterIdAndSectionCode(Long semesterId, String sectionCode);

    @Query("SELECT DISTINCT cs FROM ClassSection cs " +
            "JOIN FETCH cs.course c " +
            "JOIN FETCH cs.semester s " +
            "LEFT JOIN FETCH cs.teacher t " +
            "LEFT JOIN FETCH t.user " +
            "WHERE s.id = :semesterId " +
            "ORDER BY cs.sectionCode ASC")
    List<ClassSection> findBySemesterIdWithDetails(@Param("semesterId") Long semesterId);

    @Query(value = "SELECT cs FROM ClassSection cs " +
            "JOIN FETCH cs.course c " +
            "JOIN FETCH cs.semester s " +
            "LEFT JOIN FETCH cs.teacher t " +
            "LEFT JOIN FETCH t.user " +
            "WHERE (:semesterId IS NULL OR s.id = :semesterId) " +
            "AND (:keyword IS NULL OR :keyword = '' OR LOWER(cs.sectionCode) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(c.code) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(c.name) LIKE LOWER(CONCAT('%', :keyword, '%')))",
            countQuery = "SELECT COUNT(cs) FROM ClassSection cs JOIN cs.course c " +
            "WHERE (:semesterId IS NULL OR cs.semester.id = :semesterId) " +
            "AND (:keyword IS NULL OR :keyword = '' OR LOWER(cs.sectionCode) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(c.code) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(c.name) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<ClassSection> searchClassSections(
            @Param("semesterId") Long semesterId,
            @Param("keyword") String keyword,
            Pageable pageable
    );

    long countBySemesterId(Long semesterId);
}
