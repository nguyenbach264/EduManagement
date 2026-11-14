package com.edumanagement.modules.academic.repository;

import com.edumanagement.modules.academic.entity.Semester;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SemesterRepository extends JpaRepository<Semester, Long> {

    Optional<Semester> findByCode(String code);

    Optional<Semester> findByRegisterOpenTrue();

    boolean existsByCode(String code);
}
