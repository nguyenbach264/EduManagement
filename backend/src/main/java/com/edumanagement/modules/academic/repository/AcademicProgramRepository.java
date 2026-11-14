package com.edumanagement.modules.academic.repository;

import com.edumanagement.modules.academic.entity.AcademicProgram;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AcademicProgramRepository extends JpaRepository<AcademicProgram, Long> {

    Optional<AcademicProgram> findByCode(String code);

    List<AcademicProgram> findByDepartmentId(Long departmentId);

    boolean existsByCode(String code);

    @Query("SELECT ap FROM AcademicProgram ap JOIN FETCH ap.department ORDER BY ap.code ASC")
    List<AcademicProgram> findAllWithDepartment();
}
