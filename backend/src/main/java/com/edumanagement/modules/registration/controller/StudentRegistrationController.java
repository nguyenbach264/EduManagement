package com.edumanagement.modules.registration.controller;

import com.edumanagement.common.dto.ApiResponse;
import com.edumanagement.common.exception.ResourceNotFoundException;
import com.edumanagement.modules.academic.entity.Course;
import com.edumanagement.modules.academic.entity.ProgramCourse;
import com.edumanagement.modules.academic.entity.Semester;
import com.edumanagement.modules.academic.repository.ProgramCourseRepository;
import com.edumanagement.modules.academic.repository.SemesterRepository;
import com.edumanagement.modules.grade.dto.GradeDtos.ClassGradeRowDto;
import com.edumanagement.modules.grade.dto.GradeDtos.ClassSectionGradeReportDto;
import com.edumanagement.modules.grade.entity.Grade;
import com.edumanagement.modules.grade.repository.GradeRepository;
import com.edumanagement.modules.grade.service.DocumentExportService;
import com.edumanagement.modules.grade.service.GpaCalculationService;
import com.edumanagement.modules.registration.dto.RegistrationDtos.*;
import com.edumanagement.modules.registration.entity.ClassSchedule;
import com.edumanagement.modules.registration.entity.ClassSection;
import com.edumanagement.modules.registration.entity.Enrollment;
import com.edumanagement.modules.registration.repository.ClassSectionRepository;
import com.edumanagement.modules.registration.repository.EnrollmentRepository;
import com.edumanagement.modules.registration.service.EnrollmentService;
import com.edumanagement.modules.student.entity.Student;
import com.edumanagement.modules.student.entity.Teacher;
import com.edumanagement.modules.student.repository.StudentRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/student")
@PreAuthorize("hasRole('STUDENT')")
@RequiredArgsConstructor
@Tag(name = "Student Portal", description = "Các API dành cho sinh viên: Đăng ký tín chỉ, tra cứu lịch học, xem bảng điểm")
public class StudentRegistrationController {

    private final EnrollmentService enrollmentService;
    private final ClassSectionRepository classSectionRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final StudentRepository studentRepository;
    private final SemesterRepository semesterRepository;
    private final ProgramCourseRepository programCourseRepository;
    private final GradeRepository gradeRepository;
    private final GpaCalculationService gpaCalculationService;
    private final DocumentExportService documentExportService;

    @GetMapping("/dashboard")
    @Transactional(readOnly = true)
    @Operation(summary = "Thống kê tổng quan sinh viên")
    public ResponseEntity<ApiResponse<StudentDashboardDto>> getDashboard(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(value = "semesterId", required = false) Long semesterId) {
        Student student = getStudent(userDetails.getUsername());
        Semester semester = resolveSemester(semesterId);
        GpaCalculationService.AcademicSummary summary = gpaCalculationService.calculateStudentCumulativeSummary(student.getId());
        List<Enrollment> currentEnrollments = semester != null
                ? enrollmentRepository.findActiveEnrollmentsByStudentAndSemester(student.getId(), semester.getId())
                : List.of();

        int currentCredits = currentEnrollments.stream()
                .mapToInt(e -> e.getClassSection().getCourse().getCredits())
                .sum();

        return ResponseEntity.ok(ApiResponse.ok(StudentDashboardDto.builder()
                .studentCode(student.getStudentCode())
                .fullName(student.getUser().getFullName())
                .departmentName(student.getDepartment().getName())
                .programName(student.getAcademicProgram().getName())
                .cohort(student.getCohort())
                .academicStatus(student.getStatus().name())
                .cumulativeGpa(summary.getCumulativeGpa())
                .cumulativeScore10(summary.getCumulativeScore10())
                .academicClassification(summary.getAcademicClassification())
                .totalCreditsEarned(summary.getTotalCreditsEarned())
                .programTotalCredits(student.getAcademicProgram().getTotalCredits())
                .currentSemesterCredits(currentCredits)
                .currentSemesterMaxCredits(semester != null ? semester.getMaxCredits() : 24)
                .currentSemesterMinCredits(semester != null ? semester.getMinCredits() : 12)
                .activeSemesterCode(semester != null ? semester.getCode() : "")
                .activeSemesterName(semester != null ? semester.getName() : "")
                .registerOpen(semester != null && semester.isRegisterOpen())
                .enrolledCoursesCount(currentEnrollments.size())
                .build()));
    }

    @GetMapping("/registration/available-classes")
    @Transactional(readOnly = true)
    @Operation(summary = "Xem danh sách lớp học phần mở đăng ký kèm trạng thái điều kiện")
    public ResponseEntity<ApiResponse<List<AvailableClassDto>>> getAvailableClasses(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(value = "semesterId", required = false) Long semesterId) {
        Student student = getStudent(userDetails.getUsername());
        Semester semester = resolveSemester(semesterId);
        if (semester == null) {
            return ResponseEntity.ok(ApiResponse.ok(List.of()));
        }

        // Danh sách học phần mở đăng ký chỉ bao gồm các môn nằm trong khung Chương trình đào tạo của sinh viên
        Set<Long> programCourseIds = programCourseRepository.findByProgramIdOrderBySemesterIndexAsc(student.getAcademicProgram().getId())
                .stream()
                .map(pc -> pc.getCourse().getId())
                .collect(Collectors.toSet());

        List<ClassSection> sections = classSectionRepository.findAvailableSectionsInSemester(semester.getId()).stream()
                .filter(cs -> programCourseIds.contains(cs.getCourse().getId()))
                .collect(Collectors.toList());
        List<Enrollment> currentEnrollments = enrollmentRepository.findActiveEnrollmentsByStudentAndSemester(student.getId(), semester.getId());

        Set<Long> enrolledSectionIds = currentEnrollments.stream()
                .map(e -> e.getClassSection().getId())
                .collect(Collectors.toSet());
        Set<Long> enrolledCourseIds = currentEnrollments.stream()
                .map(e -> e.getClassSection().getCourse().getId())
                .collect(Collectors.toSet());

        List<ClassSchedule> existingSchedules = currentEnrollments.stream()
                .flatMap(e -> e.getClassSection().getSchedules().stream())
                .collect(Collectors.toList());

        Set<Long> passedCourseIds = gradeRepository.findAllGradesByStudentId(student.getId()).stream()
                .filter(Grade::isPassed)
                .map(g -> g.getEnrollment().getClassSection().getCourse().getId())
                .collect(Collectors.toSet());

        List<AvailableClassDto> result = sections.stream().map(cs -> {
            Course course = cs.getCourse();
            boolean isEnrolled = enrolledSectionIds.contains(cs.getId());
            boolean isSameCourse = !isEnrolled && enrolledCourseIds.contains(course.getId());

            List<String> missingPrereqs = course.getPrerequisites().stream()
                    .filter(p -> !passedCourseIds.contains(p.getId()))
                    .map(p -> p.getCode() + " - " + p.getName())
                    .collect(Collectors.toList());
            boolean prereqMet = missingPrereqs.isEmpty();

            String conflictMsg = null;
            if (!isEnrolled) {
                for (ClassSchedule newSch : cs.getSchedules()) {
                    for (ClassSchedule ex : existingSchedules) {
                        if (newSch.overlapsWith(ex)) {
                            conflictMsg = String.format("Trùng Thứ %d (tiết %d-%d) với %s",
                                    ex.getDayOfWeek(), ex.getStartPeriod(), ex.getEndPeriod(),
                                    ex.getClassSection().getCourse().getName());
                            break;
                        }
                    }
                    if (conflictMsg != null) break;
                }
            }

            boolean full = cs.isFull();
            boolean hasConflict = conflictMsg != null;
            boolean canEnroll = semester.isRegisterOpen() && !full && !isEnrolled && !isSameCourse && prereqMet && !hasConflict;

            return AvailableClassDto.builder()
                    .id(cs.getId())
                    .sectionCode(cs.getSectionCode())
                    .courseId(course.getId())
                    .courseCode(course.getCode())
                    .courseName(course.getName())
                    .credits(course.getCredits())
                    .departmentName(course.getDepartment() != null ? course.getDepartment().getName() : "")
                    .semesterId(semester.getId())
                    .semesterCode(semester.getCode())
                    .teacherName(cs.getTeacher() != null ? cs.getTeacher().getUser().getFullName() : "Chưa phân công")
                    .maxCapacity(cs.getMaxCapacity())
                    .currentEnrolled(cs.getCurrentEnrolled())
                    .full(full)
                    .enrolled(isEnrolled)
                    .sameCourseEnrolled(isSameCourse)
                    .prerequisiteMet(prereqMet)
                    .missingPrerequisites(missingPrereqs)
                    .scheduleConflict(hasConflict)
                    .conflictMessage(conflictMsg)
                    .canEnroll(canEnroll)
                    .schedules(cs.getSchedules().stream()
                            .map(sch -> ClassScheduleDto.builder()
                                    .id(sch.getId())
                                    .dayOfWeek(sch.getDayOfWeek())
                                    .startPeriod(sch.getStartPeriod())
                                    .endPeriod(sch.getEndPeriod())
                                    .room(sch.getRoom())
                                    .build())
                            .collect(Collectors.toList()))
                    .build();
        }).collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.ok(result));
    }

    @PostMapping("/registration/enroll")
    @Operation(summary = "Đăng ký lớp học phần")
    public ResponseEntity<ApiResponse<Void>> enrollCourse(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody Map<String, Long> request) {
        Student student = getStudent(userDetails.getUsername());
        Long classSectionId = request.get("classSectionId");
        enrollmentService.enrollCourse(student.getId(), classSectionId);
        return ResponseEntity.ok(ApiResponse.ok("Đăng ký lớp học phần thành công", null));
    }

    @PostMapping("/registration/drop")
    @Operation(summary = "Hủy đăng ký lớp học phần")
    public ResponseEntity<ApiResponse<Void>> dropCourse(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody Map<String, Long> request) {
        Student student = getStudent(userDetails.getUsername());
        Long classSectionId = request.get("classSectionId");
        enrollmentService.dropCourse(student.getId(), classSectionId);
        return ResponseEntity.ok(ApiResponse.ok("Hủy đăng ký lớp học phần thành công", null));
    }

    private static final String[] PERIOD_START_TIMES = {
            "", "07:00", "07:50", "08:40", "09:35", "10:25", "11:15",
            "12:30", "13:20", "14:10", "15:05", "15:55", "16:45",
            "17:45", "18:35", "19:25"
    };

    private static final String[] PERIOD_END_TIMES = {
            "", "07:45", "08:35", "09:25", "10:20", "11:10", "12:00",
            "13:15", "14:05", "14:55", "15:50", "16:40", "17:30",
            "18:30", "19:20", "20:10"
    };

    private String formatTimeRange(int start, int end) {
        String s = (start >= 1 && start <= 15) ? PERIOD_START_TIMES[start] : "07:00";
        String e = (end >= 1 && end <= 15) ? PERIOD_END_TIMES[end] : "11:10";
        return s + " - " + e;
    }

    @GetMapping("/schedule")
    @Transactional(readOnly = true)
    @Operation(summary = "Xem thời khóa biểu cá nhân theo kỳ (hỗ trợ đa tuần, chi tiết giảng viên & phòng học)")
    public ResponseEntity<ApiResponse<List<ScheduleItemDto>>> getMySchedule(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(value = "semesterId", required = false) Long semesterId) {
        Student student = getStudent(userDetails.getUsername());
        Semester semester = resolveSemester(semesterId);
        if (semester == null) {
            return ResponseEntity.ok(ApiResponse.ok(List.of()));
        }

        List<Enrollment> enrollments = enrollmentRepository.findActiveEnrollmentsByStudentAndSemester(student.getId(), semester.getId());
        List<ScheduleItemDto> items = new ArrayList<>();
        for (Enrollment e : enrollments) {
            ClassSection cs = e.getClassSection();
            Teacher teacher = cs.getTeacher();
            String teacherName = teacher != null && teacher.getUser() != null ? teacher.getUser().getFullName() : "Chưa phân công";
            String teacherPhone = teacher != null ? teacher.getPhone() : null;
            String teacherEmail = teacher != null ? (teacher.getEmail() != null ? teacher.getEmail() : (teacher.getUser() != null ? teacher.getUser().getEmail() : null)) : null;
            String teacherRank = teacher != null ? (teacher.getAcademicTitle() != null ? teacher.getAcademicTitle() : teacher.getAcademicRank()) : null;

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
                        .enrollmentId(e.getId())
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
                        .timeRange(formatTimeRange(sch.getStartPeriod(), sch.getEndPeriod()))
                        .semesterCode(semester.getCode())
                        .semesterName(semester.getName())
                        .build());
            }
        }
        items.sort(Comparator.comparing(ScheduleItemDto::getDayOfWeek).thenComparing(ScheduleItemDto::getStartPeriod));
        return ResponseEntity.ok(ApiResponse.ok(items));
    }

    @GetMapping("/grades/class-section/{identifier}")
    @Transactional(readOnly = true)
    @Operation(summary = "Xem bảng điểm toàn thể lớp học phần khi sinh viên bấm vào 1 môn học")
    public ResponseEntity<ApiResponse<ClassSectionGradeReportDto>> getClassSectionGradeReport(
            @PathVariable String identifier) {
        ClassSection section;
        try {
            Long id = Long.parseLong(identifier);
            section = classSectionRepository.findById(id)
                    .or(() -> classSectionRepository.findBySectionCode(identifier))
                    .orElseThrow(() -> new ResourceNotFoundException("ClassSection", "id", id));
        } catch (NumberFormatException ex) {
            section = classSectionRepository.findBySectionCode(identifier)
                    .orElseThrow(() -> new ResourceNotFoundException("ClassSection", "sectionCode", identifier));
        }

        final ClassSection finalSection = section;
        List<Grade> grades = gradeRepository.findByClassSectionId(finalSection.getId());

        List<ClassGradeRowDto> studentRows = grades.stream().map(g -> {
            Student s = g.getEnrollment().getStudent();
            return ClassGradeRowDto.builder()
                    .gradeId(g.getId())
                    .enrollmentId(g.getEnrollment().getId())
                    .studentId(s.getId())
                    .studentCode(s.getStudentCode())
                    .studentName(s.getUser().getFullName())
                    .className(s.getClassName() != null ? s.getClassName() : "Chưa phân lớp")
                    .sectionCode(finalSection.getSectionCode())
                    .courseCode(finalSection.getCourse().getCode())
                    .courseName(finalSection.getCourse().getName())
                    .credits(finalSection.getCourse().getCredits())
                    .attendanceWeight(finalSection.getCourse().getAttendanceWeight())
                    .midtermWeight(finalSection.getCourse().getMidtermWeight())
                    .finalWeight(finalSection.getCourse().getFinalWeight())
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
        }).collect(Collectors.toList());

        Map<String, Long> distribution = new TreeMap<>();
        double totalSum = 0;
        int gradedCount = 0;
        for (Grade g : grades) {
            if (g.getLetterGrade() != null) {
                distribution.merge(g.getLetterGrade(), 1L, Long::sum);
            }
            if (g.getTotalScore10() != null) {
                totalSum += g.getTotalScore10().doubleValue();
                gradedCount++;
            }
        }

        BigDecimal avgScore = gradedCount > 0
                ? BigDecimal.valueOf(totalSum / gradedCount).setScale(1, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        String teacherName = section.getTeacher() != null && section.getTeacher().getUser() != null
                ? section.getTeacher().getUser().getFullName()
                : "Chưa phân công";

        ClassSectionGradeReportDto report = ClassSectionGradeReportDto.builder()
                .classSectionId(section.getId())
                .sectionCode(section.getSectionCode())
                .courseCode(section.getCourse().getCode())
                .courseName(section.getCourse().getName())
                .credits(section.getCourse().getCredits())
                .teacherName(teacherName)
                .semesterName(section.getSemester().getName())
                .totalStudents(studentRows.size())
                .averageScore10(avgScore)
                .gradeDistribution(distribution)
                .students(studentRows)
                .build();

        return ResponseEntity.ok(ApiResponse.ok(report));
    }

    @GetMapping("/curriculum")
    @Transactional(readOnly = true)
    @Operation(summary = "Xem khung chương trình đào tạo và tiến độ hoàn thành")
    public ResponseEntity<ApiResponse<List<CurriculumCourseDto>>> getCurriculum(
            @AuthenticationPrincipal UserDetails userDetails) {
        Student student = getStudent(userDetails.getUsername());
        List<ProgramCourse> programCourses = programCourseRepository.findByProgramIdOrderBySemesterIndexAsc(
                student.getAcademicProgram().getId());

        Map<Long, Grade> bestGradeByCourse = new HashMap<>();
        Map<String, Grade> bestGradeByCode = new HashMap<>();
        for (Grade g : gradeRepository.findAllGradesByStudentId(student.getId())) {
            if (g.getEnrollment() == null || g.getEnrollment().getClassSection() == null || g.getEnrollment().getClassSection().getCourse() == null) continue;
            Course gc = g.getEnrollment().getClassSection().getCourse();
            Long cid = gc.getId();
            String code = gc.getCode();
            java.util.function.BiFunction<Grade, Grade, Grade> merger = (g1, g2) -> {
                BigDecimal s1 = g1.getGpaScore4() != null ? g1.getGpaScore4() : (g1.getTotalScore10() != null ? g1.getTotalScore10() : BigDecimal.ZERO);
                BigDecimal s2 = g2.getGpaScore4() != null ? g2.getGpaScore4() : (g2.getTotalScore10() != null ? g2.getTotalScore10() : BigDecimal.ZERO);
                return s1.compareTo(s2) >= 0 ? g1 : g2;
            };
            bestGradeByCourse.merge(cid, g, merger);
            if (code != null) {
                bestGradeByCode.merge(code, g, merger);
            }
        }

        Set<Long> enrolledCourseIds = enrollmentRepository.findAllActiveEnrollmentsByStudentId(student.getId()).stream()
                .filter(e -> e.getClassSection() != null && e.getClassSection().getCourse() != null)
                .map(e -> e.getClassSection().getCourse().getId())
                .collect(Collectors.toSet());
        Set<String> enrolledCourseCodes = enrollmentRepository.findAllActiveEnrollmentsByStudentId(student.getId()).stream()
                .filter(e -> e.getClassSection() != null && e.getClassSection().getCourse() != null)
                .map(e -> e.getClassSection().getCourse().getCode())
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        List<CurriculumCourseDto> result = programCourses.stream().map(pc -> {
            Course c = pc.getCourse();
            Grade best = bestGradeByCourse.get(c.getId());
            if (best == null && c.getCode() != null) {
                best = bestGradeByCode.get(c.getCode());
            }
            String status = "NOT_TAKEN";
            if (best != null && best.isPassed()) {
                status = "PASSED";
            } else if (best != null) {
                status = "FAILED";
            } else if (enrolledCourseIds.contains(c.getId()) || (c.getCode() != null && enrolledCourseCodes.contains(c.getCode()))) {
                status = "ENROLLED";
            }
            List<String> prereqCodes = c.getPrerequisites().stream()
                    .map(p -> p.getCode() + " - " + p.getName())
                    .collect(Collectors.toList());
            List<String> teacherNames = c.getAssignedTeachers().stream()
                    .map(t -> (t.getAcademicTitle() != null ? t.getAcademicTitle() + " " : "") +
                            (t.getUser() != null ? t.getUser().getFullName() : ""))
                    .collect(Collectors.toList());

            return CurriculumCourseDto.builder()
                    .courseId(c.getId())
                    .courseCode(c.getCode())
                    .courseName(c.getName())
                    .credits(c.getCredits())
                    .theoryHours(c.getTheoryHours())
                    .practiceHours(c.getPracticeHours())
                    .attendanceWeight(c.getAttendanceWeight())
                    .midtermWeight(c.getMidtermWeight())
                    .finalWeight(c.getFinalWeight())
                    .prerequisites(prereqCodes)
                    .teacherNames(teacherNames)
                    .departmentName(c.getDepartment() != null ? c.getDepartment().getName() : "")
                    .semesterIndex(pc.getSemesterIndex())
                    .compulsory(pc.isCompulsory())
                    .completionStatus(status)
                    .bestScore10(best != null ? best.getTotalScore10() : null)
                    .letterGrade(best != null ? best.getLetterGrade() : null)
                    .build();
        }).collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.ok(result));
    }

    @GetMapping("/academic-results")
    @Operation(summary = "Xem kết quả học tập & GPA/CPA")
    public ResponseEntity<ApiResponse<GpaCalculationService.AcademicSummary>> getAcademicResults(
            @AuthenticationPrincipal UserDetails userDetails) {
        Student student = getStudent(userDetails.getUsername());
        GpaCalculationService.AcademicSummary summary = gpaCalculationService.calculateStudentCumulativeSummary(student.getId());
        return ResponseEntity.ok(ApiResponse.ok(summary));
    }

    @GetMapping("/grades/export-pdf")
    @Transactional(readOnly = true)
    @Operation(summary = "Xuất phiếu điểm tích lũy PDF")
    public ResponseEntity<byte[]> exportTranscriptPdf(@AuthenticationPrincipal UserDetails userDetails) {
        Student student = getStudent(userDetails.getUsername());
        GpaCalculationService.AcademicSummary summary = gpaCalculationService.calculateStudentCumulativeSummary(student.getId());
        byte[] pdf = documentExportService.exportStudentTranscriptPdf(student, summary);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=bang-diem-" + student.getStudentCode() + ".pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }

    private Student getStudent(String username) {
        return studentRepository.findByUserUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hồ sơ sinh viên của tài khoản này"));
    }

    private Semester resolveSemester(Long semesterId) {
        if (semesterId != null) {
            return semesterRepository.findById(semesterId).orElse(null);
        }
        return semesterRepository.findByRegisterOpenTrue()
                .orElseGet(() -> semesterRepository.findAll(Sort.by(Sort.Direction.DESC, "code"))
                        .stream().findFirst().orElse(null));
    }
}
