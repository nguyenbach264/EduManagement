package com.edumanagement.modules.academic.repository;

import com.edumanagement.modules.academic.entity.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CourseRepository extends JpaRepository<Course, Long> {

    Optional<Course> findByCode(String code);

    boolean existsByCode(String code);

    List<Course> findByDepartmentId(Long departmentId);

    @Query("SELECT c FROM Course c JOIN FETCH c.department LEFT JOIN FETCH c.prerequisites WHERE c.id = :id")
    Optional<Course> findByIdWithDetails(@Param("id") Long id);

    @Query(value = "SELECT c FROM Course c " +
            "JOIN FETCH c.department d " +
            "WHERE (:departmentId IS NULL OR d.id = :departmentId) " +
            "AND (:keyword IS NULL OR :keyword = '' OR LOWER(c.code) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(c.name) LIKE LOWER(CONCAT('%', :keyword, '%')))",
            countQuery = "SELECT COUNT(c) FROM Course c " +
            "WHERE (:departmentId IS NULL OR c.department.id = :departmentId) " +
            "AND (:keyword IS NULL OR :keyword = '' OR LOWER(c.code) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(c.name) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Course> searchCourses(
            @Param("departmentId") Long departmentId,
            @Param("keyword") String keyword,
            Pageable pageable
    );
}
