package com.edumanagement.modules.student.repository;

import com.edumanagement.modules.student.entity.Student;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, Long> {

    Optional<Student> findByStudentCode(String studentCode);

    Optional<Student> findByUserId(Long userId);

    @Query("SELECT s FROM Student s JOIN FETCH s.user JOIN FETCH s.department JOIN FETCH s.academicProgram WHERE s.user.username = :username")
    Optional<Student> findByUserUsername(@Param("username") String username);

    boolean existsByStudentCode(String studentCode);

    @Query(value = "SELECT s FROM Student s " +
            "JOIN FETCH s.user u " +
            "JOIN FETCH s.department d " +
            "JOIN FETCH s.academicProgram p " +
            "WHERE (:departmentId IS NULL OR d.id = :departmentId) " +
            "AND (:cohort IS NULL OR s.cohort = :cohort) " +
            "AND (:keyword IS NULL OR :keyword = '' OR LOWER(s.studentCode) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(u.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')))",
            countQuery = "SELECT COUNT(s) FROM Student s JOIN s.user u " +
            "WHERE (:departmentId IS NULL OR s.department.id = :departmentId) " +
            "AND (:cohort IS NULL OR s.cohort = :cohort) " +
            "AND (:keyword IS NULL OR :keyword = '' OR LOWER(s.studentCode) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(u.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Student> searchStudents(
            @Param("departmentId") Long departmentId,
            @Param("cohort") Integer cohort,
            @Param("keyword") String keyword,
            Pageable pageable
    );

    @Query("SELECT d.name, COUNT(s) FROM Student s JOIN s.department d GROUP BY d.name ORDER BY COUNT(s) DESC")
    List<Object[]> countStudentsByDepartment();
}
