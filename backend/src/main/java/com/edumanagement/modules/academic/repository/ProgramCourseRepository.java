package com.edumanagement.modules.academic.repository;

import com.edumanagement.modules.academic.entity.ProgramCourse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProgramCourseRepository extends JpaRepository<ProgramCourse, Long> {

    @Query("SELECT pc FROM ProgramCourse pc " +
            "JOIN FETCH pc.course c " +
            "JOIN FETCH c.department " +
            "WHERE pc.program.id = :programId " +
            "ORDER BY pc.semesterIndex ASC, c.code ASC")
    List<ProgramCourse> findByProgramIdOrderBySemesterIndexAsc(@Param("programId") Long programId);

    Optional<ProgramCourse> findByProgramIdAndCourseId(Long programId, Long courseId);
}
