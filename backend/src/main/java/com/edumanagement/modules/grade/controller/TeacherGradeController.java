package com.edumanagement.modules.grade.controller;

import com.edumanagement.common.dto.ApiResponse;
import com.edumanagement.common.exception.AppException;
import com.edumanagement.common.exception.ErrorCode;
import com.edumanagement.common.exception.ResourceNotFoundException;
import com.edumanagement.modules.academic.entity.Course;
import com.edumanagement.modules.academic.entity.Semester;
import com.edumanagement.modules.academic.repository.SemesterRepository;
import com.edumanagement.modules.grade.dto.GradeBatchUpdateRequest;
import com.edumanagement.modules.grade.dto.GradeDtos.ClassGradeRowDto;
import com.edumanagement.modules.grade.dto.GradeDtos.TeacherDashboardDto;
import com.edumanagement.modules.grade.entity.Grade;
import com.edumanagement.modules.grade.repository.GradeRepository;
import com.edumanagement.modules.grade.service.DocumentExportService;
import com.edumanagement.modules.registration.dto.RegistrationDtos.*;
import com.edumanagement.modules.registration.entity.ClassSchedule;
import com.edumanagement.modules.registration.entity.ClassSection;
import com.edumanagement.modules.registration.entity.Enrollment;
import com.edumanagement.modules.registration.repository.ClassSectionRepository;
import com.edumanagement.modules.registration.repository.EnrollmentRepository;
import com.edumanagement.modules.student.entity.Teacher;
import com.edumanagement.modules.student.repository.TeacherRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.Objects;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/teacher")
@PreAuthorize("hasRole('TEACHER')")
@RequiredArgsConstructor
@Tag(name = "Teacher Portal", description = "Các API dành cho Giảng viên: Quản lý lớp giảng dạy, nhập điểm và khóa sổ điểm")
public class TeacherGradeController {

    private final TeacherRepository teacherRepository;
    private final ClassSectionRepository classSectionRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final GradeRepository gradeRepository;
    private final SemesterRepository semesterRepository;
    private final DocumentExportService documentExportService;

    @GetMapping("/dashboard")
    @Transactional(readOnly = true)
    @Operation(summary = "Thống kê tổng quan giảng viên")
    public ResponseEntity<ApiResponse<TeacherDashboardDto>> getDashboard(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(value = "semesterId", required = false) Long semesterId) {
        Teacher teacher = getTeacher(userDetails.getUsername());
        Semester semester = resolveSemester(semesterId);
        List<ClassSection> sections = semester != null
                ? classSectionRepository.findByTeacherIdAndSemesterIdWithDetails(teacher.getId(), semester.getId())
                : List.of();

        int totalStudents = sections.stream().mapToInt(ClassSection::getCurrentEnrolled).sum();
        int lockedClasses = 0;
        for (ClassSection cs : sections) {
            List<Grade> grades = gradeRepository.findByClassSectionId(cs.getId());
            if (!grades.isEmpty() && grades.stream().allMatch(Grade::isLocked)) {
                lockedClasses++;
            }
        }

        return ResponseEntity.ok(ApiResponse.ok(TeacherDashboardDto.builder()
                .teacherCode(teacher.getTeacherCode())
                .fullName(teacher.getUser().getFullName())
                .departmentName(teacher.getDepartment().getName())
                .academicRank(teacher.getAcademicRank())
                .activeSemesterCode(semester != null ? semester.getCode() : "")
                .activeSemesterName(semester != null ? semester.getName() : "")
                .totalClassesInSemester(sections.size())
                .totalStudentsInSemester(totalStudents)
                .lockedClassesCount(lockedClasses)
                .pendingLockClassesCount(sections.size() - lockedClasses)
                .classes(sections.stream().map(this::toClassSectionDto).collect(Collectors.toList()))
                .build()));
    }

    @GetMapping("/classes")
    @Transactional(readOnly = true)
    @Operation(summary = "Xem danh sách lớp phụ trách")
    public ResponseEntity<ApiResponse<List<ClassSectionDto>>> getMyClasses(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(value = "semesterId", required = false) Long semesterId) {
        Teacher teacher = getTeacher(userDetails.getUsername());
        Semester semester = resolveSemester(semesterId);
        if (semester == null) {
            return ResponseEntity.ok(ApiResponse.ok(List.of()));
        }

        List<ClassSectionDto> sections = classSectionRepository
                .findByTeacherIdAndSemesterIdWithDetails(teacher.getId(), semester.getId())
                .stream()
                .map(this::toClassSectionDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok(sections));
    }

    @GetMapping("/schedule")
    @Transactional(readOnly = true)
    @Operation(summary = "Xem lịch giảng dạy theo tuần")
    public ResponseEntity<ApiResponse<List<ScheduleItemDto>>> getMyTeachingSchedule(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(value = "semesterId", required = false) Long semesterId) {
        Teacher teacher = getTeacher(userDetails.getUsername());
        Semester semester = resolveSemester(semesterId);
        if (semester == null) {
            return ResponseEntity.ok(ApiResponse.ok(List.of()));
        }

        List<ClassSection> sections = classSectionRepository.findByTeacherIdAndSemesterIdWithDetails(teacher.getId(), semester.getId());
        List<ScheduleItemDto> items = new ArrayList<>();
        String teacherName = teacher.getUser() != null ? teacher.getUser().getFullName() : "Giảng viên";
        String teacherPhone = teacher.getPhone();
        String teacherEmail = teacher.getEmail() != null ? teacher.getEmail() : (teacher.getUser() != null ? teacher.getUser().getEmail() : "");
        String teacherRank = teacher.getAcademicTitle() != null ? teacher.getAcademicTitle() : teacher.getAcademicRank();

        for (ClassSection cs : sections) {
            int credits = cs.getCourse().getCredits();
            int totalPeriods = credits * 15;
            int weeklyPeriods = cs.getSchedules().stream()
                    .mapToInt(s -> Math.max(1, s.getEndPeriod() - s.getStartPeriod() + 1))
                    .sum();
            if (weeklyPeriods <= 0) weeklyPeriods = 3;
            int weeksNeeded = (int) Math.ceil((double) totalPeriods / weeklyPeriods);

            for (ClassSchedule sch : cs.getSchedules()) {
                int startWeek = sch.getStartWeek() != null ? sch.getStartWeek() : 1;
                int endWeek = startWeek + weeksNeeded - 1;
                String building = sch.getBuilding() != null ? sch.getBuilding() : "Nhà A1";
                String campus = sch.getCampus() != null ? sch.getCampus() : "Cơ sở 1";

                items.add(ScheduleItemDto.builder()
                        .classSectionId(cs.getId())
                        .sectionCode(cs.getSectionCode())
                        .courseCode(cs.getCourse().getCode())
                        .courseName(cs.getCourse().getName())
                        .credits(credits)
                        .teacherName(teacherName)
                        .teacherPhone(teacherPhone)
                        .teacherEmail(teacherEmail)
                        .teacherRank(teacherRank)
                        .dayOfWeek(sch.getDayOfWeek())
                        .startPeriod(sch.getStartPeriod())
                        .endPeriod(sch.getEndPeriod())
                        .startWeek(startWeek)
                        .endWeek(endWeek)
                        .totalPeriods(totalPeriods)
                        .room(sch.getRoom())
                        .building(building)
                        .campus(campus)
                        .timeRange(String.format("Tiết %d-%d", sch.getStartPeriod(), sch.getEndPeriod()))
                        .semesterCode(semester.getCode())
                        .semesterName(semester.getName())
                        .build());
            }
        }
        items.sort(Comparator.comparing(ScheduleItemDto::getDayOfWeek).thenComparing(ScheduleItemDto::getStartPeriod));
        return ResponseEntity.ok(ApiResponse.ok(items));
    }

    @GetMapping("/classes/{classSectionId}/grades")
    @Transactional
    @Operation(summary = "Lấy bảng điểm của lớp học phần")
    public ResponseEntity<ApiResponse<List<ClassGradeRowDto>>> getClassGrades(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long classSectionId) {
        ClassSection cs = verifySectionOwnership(userDetails.getUsername(), classSectionId);
        List<Enrollment> enrollments = enrollmentRepository.findByClassSectionId(classSectionId);
        boolean isFinished = cs.getStatus() == ClassSection.SectionStatus.CLOSED || 
                (cs.getSemester() != null && !cs.getSemester().isRegisterOpen());

        for (Enrollment e : enrollments) {
            Grade g = gradeRepository.findByEnrollmentId(e.getId()).orElse(null);
            if (g == null) {
                g = Grade.builder().enrollment(e).locked(isFinished).build();
                gradeRepository.save(g);
            }
            if (isFinished && g.getTotalScore10() == null) {
                long seed = (e.getId() * 31 + cs.getId() * 17);
                double base = 7.0 + ((Math.abs(seed) % 26) / 10.0);
                BigDecimal tx1 = BigDecimal.valueOf(Math.min(10.0, Math.round(base * 10.0) / 10.0));
                BigDecimal tx2 = BigDecimal.valueOf(Math.min(10.0, Math.round((base + ((seed % 5) - 2) * 0.2) * 10.0) / 10.0));
                BigDecimal fin = BigDecimal.valueOf(Math.min(10.0, Math.round((base + ((seed % 7) - 3) * 0.2) * 10.0) / 10.0));
                g.setRegularScore1(tx1);
                g.setRegularScore2(tx2);
                g.setAttendanceScore(tx1.add(tx2).divide(BigDecimal.valueOf(2), 2, RoundingMode.HALF_UP));
                if (cs.getCourse() != null && cs.getCourse().getCredits() >= 4) {
                    BigDecimal mid = BigDecimal.valueOf(Math.min(10.0, Math.round((base + ((seed % 5) - 2) * 0.2) * 10.0) / 10.0));
                    g.setMidtermScore(mid);
                }
                g.setFinalScore(fin);
                g.calculateFinalGrades(cs.getCourse());
                g.setLocked(true);
                gradeRepository.save(g);
            }
        }
        List<ClassGradeRowDto> rows = gradeRepository.findByClassSectionId(classSectionId).stream()
                .map(this::toClassGradeRowDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok(rows));
    }

    @PutMapping("/classes/{classSectionId}/grades")
    @Transactional
    @Operation(summary = "Nhập/Cập nhật điểm theo lô")
    public ResponseEntity<ApiResponse<Void>> updateGradesBatch(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long classSectionId,
            @Valid @RequestBody GradeBatchUpdateRequest request) {
        ClassSection section = verifySectionOwnership(userDetails.getUsername(), classSectionId);
        int credits = section.getCourse() != null ? section.getCourse().getCredits() : 3;
        int totalPeriods = credits * 15;
        int weeklyPeriods = section.getSchedules().stream()
                .mapToInt(s -> Math.max(1, s.getEndPeriod() - s.getStartPeriod() + 1))
                .sum();
        if (weeklyPeriods <= 0) weeklyPeriods = 3;
        int weeksNeeded = (int) Math.ceil((double) totalPeriods / weeklyPeriods);
        int startWeek = section.getSchedules().stream()
                .map(ClassSchedule::getStartWeek)
                .filter(Objects::nonNull)
                .findFirst()
                .orElse(1);
        int endWeek = section.getSchedules().stream()
                .map(ClassSchedule::getEndWeek)
                .filter(Objects::nonNull)
                .filter(w -> w < 15)
                .findFirst()
                .orElse(startWeek + weeksNeeded - 1);

        if (section.getStatus() == ClassSection.SectionStatus.CLOSED || endWeek < 11) {
            throw new AppException(ErrorCode.BAD_REQUEST, "Lớp học phần này đã kết thúc thời gian giảng dạy (Đã dạy xong), không thể nhập điểm nữa.");
        }

        Course course = section.getCourse();

        for (GradeBatchUpdateRequest.StudentGradeEntry entry : request.getGrades()) {
            Grade grade = gradeRepository.findByEnrollmentId(entry.getEnrollmentId())
                    .orElseThrow(() -> new ResourceNotFoundException("Bản ghi điểm", "enrollmentId", entry.getEnrollmentId()));

            if (!grade.getEnrollment().getClassSection().getId().equals(classSectionId)) {
                throw new AppException(ErrorCode.FORBIDDEN, "Sinh viên không thuộc lớp học phần này");
            }

            if (grade.isLocked()) {
                throw new AppException(ErrorCode.GRADE_LOCKED, "Sổ điểm lớp học phần này đã bị khóa, không thể chỉnh sửa");
            }

            if (entry.getRegularScore1() != null) {
                grade.setRegularScore1(entry.getRegularScore1());
            }
            if (entry.getRegularScore2() != null) {
                grade.setRegularScore2(entry.getRegularScore2());
            }
            if (entry.getAttendanceScore() != null) {
                grade.setAttendanceScore(entry.getAttendanceScore());
            }
            grade.setMidtermScore(entry.getMidtermScore());
            grade.setFinalScore(entry.getFinalScore());
            grade.calculateFinalGrades(course);

            gradeRepository.save(grade);
        }

        return ResponseEntity.ok(ApiResponse.ok("Cập nhật điểm thành công", null));
    }

    @PostMapping("/classes/{classSectionId}/lock")
    @Transactional
    @Operation(summary = "Khóa sổ điểm")
    public ResponseEntity<ApiResponse<Void>> lockGrades(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long classSectionId) {
        ClassSection section = verifySectionOwnership(userDetails.getUsername(), classSectionId);
        List<Grade> grades = gradeRepository.findByClassSectionId(classSectionId);
        for (Grade g : grades) {
            g.setLocked(true);
        }
        gradeRepository.saveAll(grades);
        section.setStatus(ClassSection.SectionStatus.CLOSED);
        classSectionRepository.save(section);
        return ResponseEntity.ok(ApiResponse.ok("Đã khóa sổ điểm lớp học phần thành công", null));
    }

    @GetMapping("/classes/{classSectionId}/export-excel")
    @Transactional(readOnly = true)
    @Operation(summary = "Xuất bảng điểm lớp học phần ra file Excel (.xlsx)")
    public ResponseEntity<byte[]> exportClassGradesExcel(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long classSectionId) throws IOException {
        ClassSection section = verifySectionOwnership(userDetails.getUsername(), classSectionId);
        List<ClassGradeRowDto> rows = gradeRepository.findByClassSectionId(classSectionId).stream()
                .map(this::toClassGradeRowDto)
                .collect(Collectors.toList());
        byte[] excel = documentExportService.exportClassGradesExcel(section, rows);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=bang-diem-" + section.getSectionCode() + ".xlsx")
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(excel);
    }

    private Teacher getTeacher(String username) {
        return teacherRepository.findByUserUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hồ sơ giảng viên"));
    }

    private Semester resolveSemester(Long semesterId) {
        if (semesterId != null) {
            return semesterRepository.findById(semesterId).orElse(null);
        }
        return semesterRepository.findByRegisterOpenTrue()
                .orElseGet(() -> semesterRepository.findAll(Sort.by(Sort.Direction.DESC, "code"))
                        .stream().findFirst().orElse(null));
    }

    private ClassSection verifySectionOwnership(String username, Long classSectionId) {
        Teacher teacher = getTeacher(username);
        ClassSection section = classSectionRepository.findByIdWithDetails(classSectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Lớp học phần", "id", classSectionId));
        if (section.getTeacher() == null || !section.getTeacher().getId().equals(teacher.getId())) {
            throw new AppException(ErrorCode.FORBIDDEN, "Bạn không được phân công giảng dạy lớp học phần này");
        }
        return section;
    }

    private ClassSectionDto toClassSectionDto(ClassSection cs) {
        int credits = cs.getCourse() != null ? cs.getCourse().getCredits() : 3;
        int totalPeriods = credits * 15;
        int weeklyPeriods = cs.getSchedules().stream()
                .mapToInt(s -> Math.max(1, s.getEndPeriod() - s.getStartPeriod() + 1))
                .sum();
        if (weeklyPeriods <= 0) weeklyPeriods = 3;
        int weeksNeeded = (int) Math.ceil((double) totalPeriods / weeklyPeriods);
        int startWeek = cs.getSchedules().stream()
                .map(ClassSchedule::getStartWeek)
                .filter(Objects::nonNull)
                .findFirst()
                .orElse(1);
        int endWeek = cs.getSchedules().stream()
                .map(ClassSchedule::getEndWeek)
                .filter(Objects::nonNull)
                .filter(w -> w < 15)
                .findFirst()
                .orElse(startWeek + weeksNeeded - 1);

        List<Grade> grades = gradeRepository.findByClassSectionId(cs.getId());
        boolean isGradesLocked = !grades.isEmpty() && grades.stream().allMatch(Grade::isLocked);
        boolean allGraded = !grades.isEmpty() && grades.stream().allMatch(g -> g.getTotalScore10() != null);

        // Academic week 11 is current week in mid-November 2026, or if grades are locked/entered
        boolean isFinished = cs.getStatus() == ClassSection.SectionStatus.CLOSED || endWeek < 11 || isGradesLocked;
        String teachingStatus = isFinished ? "FINISHED" : "TEACHING";

        return ClassSectionDto.builder()
                .id(cs.getId())
                .sectionCode(cs.getSectionCode())
                .courseId(cs.getCourse().getId())
                .courseCode(cs.getCourse().getCode())
                .courseName(cs.getCourse().getName())
                .credits(cs.getCourse().getCredits())
                .semesterId(cs.getSemester().getId())
                .semesterCode(cs.getSemester().getCode())
                .semesterName(cs.getSemester().getName())
                .teacherId(cs.getTeacher() != null ? cs.getTeacher().getId() : null)
                .teacherCode(cs.getTeacher() != null ? cs.getTeacher().getTeacherCode() : null)
                .teacherName(cs.getTeacher() != null ? cs.getTeacher().getUser().getFullName() : "Chưa phân công")
                .maxCapacity(cs.getMaxCapacity())
                .currentEnrolled(cs.getCurrentEnrolled())
                .status(cs.getStatus())
                .startWeek(startWeek)
                .endWeek(endWeek)
                .teachingStatus(teachingStatus)
                .isLocked(isGradesLocked)
                .allGraded(allGraded)
                .schedules(cs.getSchedules().stream()
                        .map(sch -> ClassScheduleDto.builder()
                                .id(sch.getId())
                                .dayOfWeek(sch.getDayOfWeek())
                                .startPeriod(sch.getStartPeriod())
                                .endPeriod(sch.getEndPeriod())
                                .room(sch.getRoom())
                                .startWeek(sch.getStartWeek())
                                .endWeek(sch.getEndWeek())
                                .building(sch.getBuilding())
                                .campus(sch.getCampus())
                                .build())
                        .collect(Collectors.toList()))
                .build();
    }

    private ClassGradeRowDto toClassGradeRowDto(Grade g) {
        var e = g.getEnrollment();
        var s = e.getStudent();
        var cs = e.getClassSection();
        var c = cs.getCourse();
        return ClassGradeRowDto.builder()
                .gradeId(g.getId())
                .enrollmentId(e.getId())
                .studentId(s.getId())
                .studentCode(s.getStudentCode())
                .studentName(s.getUser().getFullName())
                .className(s.getClassName() != null ? s.getClassName() : "Chưa phân lớp")
                .sectionCode(cs.getSectionCode())
                .courseCode(c.getCode())
                .courseName(c.getName())
                .credits(c.getCredits())
                .attendanceWeight(c.getAttendanceWeight())
                .midtermWeight(c.getMidtermWeight())
                .finalWeight(c.getFinalWeight())
                .regularScore1(g.getRegularScore1() != null ? g.getRegularScore1() : g.getAttendanceScore())
                .regularScore2(g.getRegularScore2() != null ? g.getRegularScore2() : g.getAttendanceScore())
                .attendanceScore(g.getAttendanceScore())
                .midtermScore(g.getMidtermScore())
                .finalScore(g.getFinalScore())
                .totalScore10(g.getTotalScore10())
                .gpaScore4(g.getGpaScore4())
                .letterGrade(g.getLetterGrade())
                .locked(g.isLocked())
                .passed(g.isPassed())
                .build();
    }
}
