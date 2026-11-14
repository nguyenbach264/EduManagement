package com.edumanagement.modules.academic.controller;

import com.edumanagement.common.dto.ApiResponse;
import com.edumanagement.common.exception.ResourceNotFoundException;
import com.edumanagement.modules.academic.dto.AcademicDtos.*;
import com.edumanagement.modules.academic.entity.Course;
import com.edumanagement.modules.academic.repository.AcademicProgramRepository;
import com.edumanagement.modules.academic.repository.CourseRepository;
import com.edumanagement.modules.academic.repository.DepartmentRepository;
import com.edumanagement.modules.academic.repository.SemesterRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/common")
@RequiredArgsConstructor
@Tag(name = "Common Academic", description = "Danh mục dùng chung cho người dùng đã đăng nhập")
public class CommonAcademicController {

    private final SemesterRepository semesterRepository;
    private final DepartmentRepository departmentRepository;
    private final AcademicProgramRepository academicProgramRepository;
    private final CourseRepository courseRepository;

    @GetMapping("/semesters")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách học kỳ")
    public ResponseEntity<ApiResponse<List<SemesterDto>>> getSemesters() {
        List<SemesterDto> list = semesterRepository.findAll(Sort.by(Sort.Direction.DESC, "code")).stream()
                .map(s -> SemesterDto.builder()
                        .id(s.getId())
                        .code(s.getCode())
                        .name(s.getName())
                        .academicYear(s.getAcademicYear())
                        .semesterNumber(s.getSemesterNumber())
                        .startDate(s.getStartDate())
                        .endDate(s.getEndDate())
                        .registerOpen(s.isRegisterOpen())
                        .minCredits(s.getMinCredits())
                        .maxCredits(s.getMaxCredits())
                        .build())
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok(list));
    }

    @GetMapping("/departments")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách khoa/viện")
    public ResponseEntity<ApiResponse<List<DepartmentDto>>> getDepartments() {
        List<DepartmentDto> list = departmentRepository.findAll(Sort.by(Sort.Direction.ASC, "code")).stream()
                .map(d -> DepartmentDto.builder()
                        .id(d.getId())
                        .code(d.getCode())
                        .name(d.getName())
                        .phone(d.getPhone())
                        .email(d.getEmail())
                        .description(d.getDescription())
                        .build())
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok(list));
    }

    @GetMapping("/programs")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách chương trình đào tạo")
    public ResponseEntity<ApiResponse<List<AcademicProgramDto>>> getPrograms() {
        List<AcademicProgramDto> list = academicProgramRepository.findAllWithDepartment().stream()
                .map(p -> AcademicProgramDto.builder()
                        .id(p.getId())
                        .code(p.getCode())
                        .name(p.getName())
                        .departmentId(p.getDepartment().getId())
                        .departmentCode(p.getDepartment().getCode())
                        .departmentName(p.getDepartment().getName())
                        .totalCredits(p.getTotalCredits())
                        .durationYears(p.getDurationYears())
                        .description(p.getDescription())
                        .build())
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok(list));
    }

    @GetMapping("/courses/{id}/details")
    @Transactional(readOnly = true)
    @Operation(summary = "Xem chi tiết môn học: Trọng số điểm, môn tiên quyết, danh sách giảng viên đảm nhiệm")
    public ResponseEntity<ApiResponse<CourseDetailDto>> getCourseDetails(@PathVariable Long id) {
        Course course = courseRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Course", "id", id));

        List<SimpleCourseDto> prereqs = course.getPrerequisites().stream()
                .map(p -> SimpleCourseDto.builder()
                        .id(p.getId())
                        .code(p.getCode())
                        .name(p.getName())
                        .credits(p.getCredits())
                        .build())
                .collect(Collectors.toList());

        List<TeacherSummaryDto> teachers = course.getAssignedTeachers().stream()
                .map(t -> TeacherSummaryDto.builder()
                        .id(t.getId())
                        .teacherCode(t.getTeacherCode())
                        .fullName(t.getUser() != null ? t.getUser().getFullName() : "")
                        .academicRank(t.getAcademicRank())
                        .academicTitle(t.getAcademicTitle())
                        .phone(t.getPhone())
                        .email(t.getEmail() != null ? t.getEmail() : (t.getUser() != null ? t.getUser().getEmail() : ""))
                        .officeAddress(t.getOfficeAddress())
                        .departmentName(t.getDepartment() != null ? t.getDepartment().getName() : "")
                        .build())
                .collect(Collectors.toList());

        CourseDetailDto detail = CourseDetailDto.builder()
                .id(course.getId())
                .code(course.getCode())
                .name(course.getName())
                .credits(course.getCredits())
                .theoryHours(course.getTheoryHours())
                .practiceHours(course.getPracticeHours())
                .attendanceWeight(course.getAttendanceWeight())
                .midtermWeight(course.getMidtermWeight())
                .finalWeight(course.getFinalWeight())
                .departmentId(course.getDepartment() != null ? course.getDepartment().getId() : null)
                .departmentName(course.getDepartment() != null ? course.getDepartment().getName() : "")
                .prerequisites(prereqs)
                .assignedTeachers(teachers)
                .build();

        return ResponseEntity.ok(ApiResponse.ok(detail));
    }
}
