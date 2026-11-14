package com.edumanagement.modules.student.repository;

import com.edumanagement.modules.student.entity.Teacher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TeacherRepository extends JpaRepository<Teacher, Long> {

    Optional<Teacher> findByTeacherCode(String teacherCode);

    Optional<Teacher> findByUserId(Long userId);

    @Query("SELECT t FROM Teacher t JOIN FETCH t.user JOIN FETCH t.department WHERE t.user.username = :username")
    Optional<Teacher> findByUserUsername(@Param("username") String username);

    boolean existsByTeacherCode(String teacherCode);

    @Query(value = "SELECT t FROM Teacher t " +
            "JOIN FETCH t.user u " +
            "JOIN FETCH t.department d " +
            "WHERE (:departmentId IS NULL OR d.id = :departmentId) " +
            "AND (:active IS NULL OR u.active = :active) " +
            "AND (:keyword IS NULL OR :keyword = '' OR LOWER(t.teacherCode) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(u.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')))",
            countQuery = "SELECT COUNT(t) FROM Teacher t JOIN t.user u " +
            "WHERE (:departmentId IS NULL OR t.department.id = :departmentId) " +
            "AND (:active IS NULL OR u.active = :active) " +
            "AND (:keyword IS NULL OR :keyword = '' OR LOWER(t.teacherCode) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(u.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Teacher> searchTeachers(
            @Param("departmentId") Long departmentId,
            @Param("active") Boolean active,
            @Param("keyword") String keyword,
            Pageable pageable
    );
}
