package com.edumanagement.modules.academic.controller;

import com.edumanagement.common.constant.RoleEnum;
import com.edumanagement.common.dto.ApiResponse;
import com.edumanagement.common.dto.PageResponse;
import com.edumanagement.common.exception.AppException;
import com.edumanagement.common.exception.ConflictException;
import com.edumanagement.common.exception.ErrorCode;
import com.edumanagement.common.exception.ResourceNotFoundException;
import com.edumanagement.modules.academic.dto.AcademicDtos.*;
import com.edumanagement.modules.academic.entity.*;
import com.edumanagement.modules.academic.repository.*;
import com.edumanagement.modules.grade.dto.GradeBatchUpdateRequest;
import com.edumanagement.modules.grade.dto.GradeDtos.AdminGradeRowDto;
import com.edumanagement.modules.grade.dto.GradeDtos.ClassGradeRowDto;
import com.edumanagement.modules.grade.entity.Grade;
import com.edumanagement.modules.grade.repository.GradeRepository;
import com.edumanagement.modules.registration.dto.RegistrationDtos.*;
import com.edumanagement.modules.registration.entity.ClassSchedule;
import com.edumanagement.modules.registration.entity.ClassSection;
import com.edumanagement.modules.registration.entity.Enrollment;
import com.edumanagement.modules.registration.repository.ClassSectionRepository;
import com.edumanagement.modules.registration.repository.EnrollmentRepository;
import com.edumanagement.modules.registration.service.EnrollmentService;
import com.edumanagement.modules.student.dto.StudentTeacherDtos.*;
import com.edumanagement.modules.student.entity.Student;
import com.edumanagement.modules.student.entity.Teacher;
import com.edumanagement.modules.student.repository.StudentRepository;
import com.edumanagement.modules.student.repository.TeacherRepository;
import com.edumanagement.modules.user.entity.Role;
import com.edumanagement.modules.user.entity.User;
import com.edumanagement.modules.user.repository.RoleRepository;
import com.edumanagement.modules.user.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
@Tag(name = "Admin Portal", description = "Các API dành cho Quản trị viên / Phòng đào tạo")
public class AdminAcademicController {

    private final DepartmentRepository departmentRepository;
    private final AcademicProgramRepository academicProgramRepository;
    private final ProgramCourseRepository programCourseRepository;
    private final CourseRepository courseRepository;
    private final SemesterRepository semesterRepository;
    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final ClassSectionRepository classSectionRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final EnrollmentService enrollmentService;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final GradeRepository gradeRepository;
    private final PasswordEncoder passwordEncoder;

    // --- Dashboard ---
    @GetMapping("/dashboard")
    @Transactional(readOnly = true)
    @Operation(summary = "Thống kê tổng quan Phòng Đào tạo")
    public ResponseEntity<ApiResponse<AdminDashboardDto>> getDashboard() {
        Semester activeSem = semesterRepository.findByRegisterOpenTrue()
                .orElseGet(() -> semesterRepository.findAll(Sort.by(Sort.Direction.DESC, "code"))
                        .stream().findFirst().orElse(null));

        long openSections = activeSem != null ? classSectionRepository.countBySemesterId(activeSem.getId()) : 0;
        long activeEnrollments = activeSem != null ? enrollmentRepository.countActiveBySemesterId(activeSem.getId()) : 0;

        List<DepartmentStat> deptStats = studentRepository.countStudentsByDepartment().stream()
                .limit(10)
                .map(row -> new DepartmentStat((String) row[0], ((Number) row[1]).longValue()))
                .collect(Collectors.toList());

        Map<String, Long> gradeDist = new LinkedHashMap<>();
        for (Object[] row : gradeRepository.countByLetterGrade()) {
            gradeDist.put((String) row[0], ((Number) row[1]).longValue());
        }

        AdminDashboardDto dto = AdminDashboardDto.builder()
                .totalStudents(studentRepository.count())
                .totalTeachers(teacherRepository.count())
                .totalDepartments(departmentRepository.count())
                .totalPrograms(academicProgramRepository.count())
                .totalCourses(courseRepository.count())
                .openSectionsInActiveSemester(openSections)
                .totalEnrollmentsInActiveSemester(activeEnrollments)
                .lockedGradesCount(gradeRepository.countByLockedTrue())
                .unlockedGradesCount(gradeRepository.countByLockedFalse())
                .activeSemesterName(activeSem != null ? activeSem.getName() : "Chưa thiết lập")
                .departmentStats(deptStats)
                .gradeDistribution(gradeDist)
                .build();

        return ResponseEntity.ok(ApiResponse.ok(dto));
    }

    // --- Khoa / Viện ---
    @GetMapping("/departments")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách Khoa/Viện")
    public ResponseEntity<ApiResponse<List<DepartmentDto>>> getDepartments() {
        List<DepartmentDto> list = departmentRepository.findAll(Sort.by("code").ascending()).stream()
                .map(this::toDepartmentDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok(list));
    }

    @PostMapping("/departments")
    @Transactional
    @Operation(summary = "Tạo Khoa/Viện mới")
    public ResponseEntity<ApiResponse<DepartmentDto>> createDepartment(@Valid @RequestBody DepartmentRequest request) {
        if (departmentRepository.existsByCode(request.getCode())) {
            throw new ConflictException("Mã khoa đã tồn tại");
        }
        Department saved = departmentRepository.save(Department.builder()
                .code(request.getCode().trim().toUpperCase())
                .name(request.getName().trim())
                .phone(request.getPhone())
                .email(request.getEmail())
                .description(request.getDescription())
                .build());
        return ResponseEntity.ok(ApiResponse.ok("Tạo khoa thành công", toDepartmentDto(saved)));
    }

    @PutMapping("/departments/{id}")
    @Transactional
    @Operation(summary = "Cập nhật Khoa/Viện")
    public ResponseEntity<ApiResponse<DepartmentDto>> updateDepartment(
            @PathVariable Long id, @Valid @RequestBody DepartmentRequest request) {
        Department dept = departmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Khoa", "id", id));
        dept.setName(request.getName().trim());
        dept.setPhone(request.getPhone());
        dept.setEmail(request.getEmail());
        dept.setDescription(request.getDescription());
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật khoa thành công", toDepartmentDto(departmentRepository.save(dept))));
    }

    @DeleteMapping("/departments/{id}")
    @Transactional
    @Operation(summary = "Xóa Khoa/Viện")
    public ResponseEntity<ApiResponse<Void>> deleteDepartment(@PathVariable Long id) {
        if (!departmentRepository.existsById(id)) {
            throw new ResourceNotFoundException("Khoa", "id", id);
        }
        departmentRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.ok("Xóa khoa thành công", null));
    }

    // --- Chương trình đào tạo & Khung chương trình ---
    @GetMapping("/programs")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách Chương trình đào tạo")
    public ResponseEntity<ApiResponse<List<AcademicProgramDto>>> getPrograms() {
        List<AcademicProgramDto> list = academicProgramRepository.findAllWithDepartment().stream()
                .map(this::toProgramDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok(list));
    }

    @PostMapping("/programs")
    @Transactional
    @Operation(summary = "Tạo Chương trình đào tạo mới")
    public ResponseEntity<ApiResponse<AcademicProgramDto>> createProgram(@Valid @RequestBody AcademicProgramRequest request) {
        if (academicProgramRepository.existsByCode(request.getCode())) {
            throw new ConflictException("Mã chương trình đào tạo đã tồn tại");
        }
        Department dept = departmentRepository.findById(request.getDepartmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Khoa", "id", request.getDepartmentId()));
        AcademicProgram saved = academicProgramRepository.save(AcademicProgram.builder()
                .code(request.getCode().trim())
                .name(request.getName().trim())
                .department(dept)
                .totalCredits(request.getTotalCredits())
                .durationYears(request.getDurationYears())
                .description(request.getDescription())
                .build());
        return ResponseEntity.ok(ApiResponse.ok("Tạo CTĐT thành công", toProgramDto(saved)));
    }

    @GetMapping("/programs/{programId}/courses")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách môn học trong khung CTĐT")
    public ResponseEntity<ApiResponse<List<ProgramCourseDto>>> getProgramCourses(@PathVariable Long programId) {
        List<ProgramCourseDto> list = programCourseRepository.findByProgramIdOrderBySemesterIndexAsc(programId).stream()
                .map(pc -> ProgramCourseDto.builder()
                        .id(pc.getId())
                        .programId(programId)
                        .courseId(pc.getCourse().getId())
                        .courseCode(pc.getCourse().getCode())
                        .courseName(pc.getCourse().getName())
                        .credits(pc.getCourse().getCredits())
                        .departmentName(pc.getCourse().getDepartment().getName())
                        .semesterIndex(pc.getSemesterIndex())
                        .compulsory(pc.isCompulsory())
                        .build())
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok(list));
    }

    @PostMapping("/programs/{programId}/courses")
    @Transactional
    @Operation(summary = "Gán môn học vào khung CTĐT theo kỳ (1-8)")
    public ResponseEntity<ApiResponse<ProgramCourseDto>> addCourseToProgram(
            @PathVariable Long programId,
            @Valid @RequestBody ProgramCourseRequest request) {
        AcademicProgram program = academicProgramRepository.findById(programId)
                .orElseThrow(() -> new ResourceNotFoundException("CTĐT", "id", programId));
        Course course = courseRepository.findByIdWithDetails(request.getCourseId())
                .orElseThrow(() -> new ResourceNotFoundException("Môn học", "id", request.getCourseId()));

        if (programCourseRepository.findByProgramIdAndCourseId(programId, request.getCourseId()).isPresent()) {
            throw new ConflictException("Môn học đã tồn tại trong chương trình đào tạo này");
        }

        ProgramCourse saved = programCourseRepository.save(ProgramCourse.builder()
                .program(program)
                .course(course)
                .semesterIndex(request.getSemesterIndex())
                .compulsory(request.isCompulsory())
                .build());

        return ResponseEntity.ok(ApiResponse.ok("Gán môn học vào CTĐT thành công", ProgramCourseDto.builder()
                .id(saved.getId())
                .programId(programId)
                .courseId(course.getId())
                .courseCode(course.getCode())
                .courseName(course.getName())
                .credits(course.getCredits())
                .departmentName(course.getDepartment().getName())
                .semesterIndex(saved.getSemesterIndex())
                .compulsory(saved.isCompulsory())
                .build()));
    }

    @DeleteMapping("/programs/{programId}/courses/{programCourseId}")
    @Transactional
    @Operation(summary = "Xóa môn học khỏi khung CTĐT")
    public ResponseEntity<ApiResponse<Void>> removeCourseFromProgram(
            @PathVariable Long programId, @PathVariable Long programCourseId) {
        ProgramCourse pc = programCourseRepository.findById(programCourseId)
                .orElseThrow(() -> new ResourceNotFoundException("ProgramCourse", "id", programCourseId));
        if (!pc.getProgram().getId().equals(programId)) {
            throw new AppException(ErrorCode.BAD_REQUEST, "Môn học không thuộc chương trình đào tạo này");
        }
        programCourseRepository.delete(pc);
        return ResponseEntity.ok(ApiResponse.ok("Đã xóa môn khỏi khung CTĐT", null));
    }

    // --- Môn học ---
    @GetMapping("/courses")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách môn học (phân trang)")
    public ResponseEntity<ApiResponse<PageResponse<CourseDto>>> getCourses(
            @RequestParam(required = false) Long departmentId,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("code").ascending());
        Page<CourseDto> dtoPage = courseRepository.searchCourses(departmentId, keyword, pageable)
                .map(this::toCourseDto);
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.from(dtoPage)));
    }

    @PostMapping("/courses")
    @Transactional
    @Operation(summary = "Tạo môn học mới")
    public ResponseEntity<ApiResponse<CourseDto>> createCourse(@Valid @RequestBody CourseRequest request) {
        if (courseRepository.existsByCode(request.getCode())) {
            throw new ConflictException("Mã môn học đã tồn tại");
        }
        Department dept = departmentRepository.findById(request.getDepartmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Khoa", "id", request.getDepartmentId()));

        Set<Course> prereqs = resolvePrerequisites(request.getPrerequisiteIds(), null);

        Course saved = courseRepository.save(Course.builder()
                .code(request.getCode().trim().toUpperCase())
                .name(request.getName().trim())
                .credits(request.getCredits())
                .theoryHours(request.getTheoryHours())
                .practiceHours(request.getPracticeHours())
                .attendanceWeight(request.getAttendanceWeight() != null ? request.getAttendanceWeight() : new BigDecimal("0.10"))
                .midtermWeight(request.getMidtermWeight() != null ? request.getMidtermWeight() : new BigDecimal("0.30"))
                .finalWeight(request.getFinalWeight() != null ? request.getFinalWeight() : new BigDecimal("0.60"))
                .department(dept)
                .prerequisites(prereqs)
                .build());
        return ResponseEntity.ok(ApiResponse.ok("Tạo môn học thành công", toCourseDto(saved)));
    }

    @PutMapping("/courses/{id}")
    @Transactional
    @Operation(summary = "Cập nhật môn học và môn tiên quyết")
    public ResponseEntity<ApiResponse<CourseDto>> updateCourse(
            @PathVariable Long id, @Valid @RequestBody CourseRequest request) {
        Course course = courseRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new ResourceNotFoundException("Môn học", "id", id));
        Department dept = departmentRepository.findById(request.getDepartmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Khoa", "id", request.getDepartmentId()));

        course.setName(request.getName().trim());
        course.setCredits(request.getCredits());
        course.setTheoryHours(request.getTheoryHours());
        course.setPracticeHours(request.getPracticeHours());
        if (request.getAttendanceWeight() != null) course.setAttendanceWeight(request.getAttendanceWeight());
        if (request.getMidtermWeight() != null) course.setMidtermWeight(request.getMidtermWeight());
        if (request.getFinalWeight() != null) course.setFinalWeight(request.getFinalWeight());
        course.setDepartment(dept);
        course.setPrerequisites(resolvePrerequisites(request.getPrerequisiteIds(), id));

        return ResponseEntity.ok(ApiResponse.ok("Cập nhật môn học thành công", toCourseDto(courseRepository.save(course))));
    }

    @DeleteMapping("/courses/{id}")
    @Transactional
    @Operation(summary = "Xóa môn học")
    public ResponseEntity<ApiResponse<Void>> deleteCourse(@PathVariable Long id) {
        if (!courseRepository.existsById(id)) {
            throw new ResourceNotFoundException("Môn học", "id", id);
        }
        courseRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.ok("Đã xóa môn học", null));
    }

    private Set<Course> resolvePrerequisites(List<Long> ids, Long selfId) {
        if (ids == null || ids.isEmpty()) return new HashSet<>();
        Set<Course> result = new HashSet<>();
        for (Long pid : ids) {
            if (selfId != null && selfId.equals(pid)) {
                throw new AppException(ErrorCode.BAD_REQUEST, "Môn học không thể là tiên quyết của chính nó");
            }
            result.add(courseRepository.findById(pid)
                    .orElseThrow(() -> new ResourceNotFoundException("Môn tiên quyết", "id", pid)));
        }
        return result;
    }

    // --- Học kỳ & Đóng/Mở cổng đăng ký ---
    @GetMapping("/semesters")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách học kỳ")
    public ResponseEntity<ApiResponse<List<SemesterDto>>> getSemesters() {
        List<SemesterDto> list = semesterRepository.findAll(Sort.by(Sort.Direction.DESC, "code")).stream()
                .map(this::toSemesterDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok(list));
    }

    @PostMapping("/semesters")
    @Transactional
    @Operation(summary = "Tạo học kỳ mới")
    public ResponseEntity<ApiResponse<SemesterDto>> createSemester(@Valid @RequestBody SemesterRequest request) {
        if (semesterRepository.existsByCode(request.getCode())) {
            throw new ConflictException("Mã học kỳ đã tồn tại");
        }
        if (request.isRegisterOpen()) {
            semesterRepository.findByRegisterOpenTrue().ifPresent(s -> {
                s.setRegisterOpen(false);
                semesterRepository.save(s);
            });
        }
        Semester saved = semesterRepository.save(Semester.builder()
                .code(request.getCode().trim())
                .name(request.getName().trim())
                .academicYear(request.getAcademicYear().trim())
                .semesterNumber(request.getSemesterNumber())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .registerOpen(request.isRegisterOpen())
                .minCredits(request.getMinCredits())
                .maxCredits(request.getMaxCredits())
                .build());
        return ResponseEntity.ok(ApiResponse.ok("Tạo học kỳ thành công", toSemesterDto(saved)));
    }

    @PutMapping("/semesters/{id}/toggle-registration")
    @Transactional
    @Operation(summary = "Bật/Tắt cổng đăng ký tín chỉ")
    public ResponseEntity<ApiResponse<SemesterDto>> toggleRegistration(@PathVariable Long id) {
        Semester semester = semesterRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Học kỳ", "id", id));
        boolean targetState = !semester.isRegisterOpen();
        if (targetState) {
            semesterRepository.findByRegisterOpenTrue().ifPresent(other -> {
                if (!other.getId().equals(id)) {
                    other.setRegisterOpen(false);
                    semesterRepository.save(other);
                }
            });
        }
        semester.setRegisterOpen(targetState);
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật trạng thái cổng đăng ký thành công", toSemesterDto(semesterRepository.save(semester))));
    }

    @PutMapping("/semesters/{id}/credit-limits")
    @Transactional
    @Operation(summary = "Cập nhật giới hạn số tín chỉ đăng ký (tối thiểu, tối đa)")
    public ResponseEntity<ApiResponse<SemesterDto>> updateCreditLimits(
            @PathVariable Long id,
            @Valid @RequestBody CreditLimitsRequest request) {
        Semester semester = semesterRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Học kỳ", "id", id));
        if (request.getMinCredits() != null && request.getMaxCredits() != null &&
                request.getMinCredits() > request.getMaxCredits()) {
            throw new AppException(ErrorCode.BAD_REQUEST, "Số tín chỉ tối thiểu không được lớn hơn tối đa");
        }
        if (request.getMinCredits() != null) semester.setMinCredits(request.getMinCredits());
        if (request.getMaxCredits() != null) semester.setMaxCredits(request.getMaxCredits());
        Semester saved = semesterRepository.save(semester);
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật giới hạn tín chỉ thành công", toSemesterDto(saved)));
    }

    // --- Sinh viên ---
    @GetMapping("/students")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách sinh viên (phân trang)")
    public ResponseEntity<ApiResponse<PageResponse<StudentDto>>> getStudents(
            @RequestParam(required = false) Long departmentId,
            @RequestParam(required = false) Integer cohort,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("studentCode").ascending());
        Page<StudentDto> studentPage = studentRepository.searchStudents(departmentId, cohort, keyword, pageable)
                .map(this::toStudentDto);
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.from(studentPage)));
    }

    @PostMapping("/students")
    @Transactional
    @Operation(summary = "Tạo hồ sơ sinh viên kèm tài khoản đăng nhập")
    public ResponseEntity<ApiResponse<StudentDto>> createStudent(@Valid @RequestBody CreateStudentRequest request) {
        if (studentRepository.existsByStudentCode(request.getStudentCode()) || userRepository.existsByUsername(request.getStudentCode())) {
            throw new ConflictException("Mã sinh viên đã tồn tại");
        }
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("Email đã được sử dụng");
        }
        Department dept = departmentRepository.findById(request.getDepartmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Khoa", "id", request.getDepartmentId()));
        AcademicProgram program = academicProgramRepository.findById(request.getProgramId())
                .orElseThrow(() -> new ResourceNotFoundException("CTĐT", "id", request.getProgramId()));
        Role studentRole = roleRepository.findByName(RoleEnum.ROLE_STUDENT)
                .orElseThrow(() -> new ResourceNotFoundException("Role ROLE_STUDENT không tồn tại"));

        String rawPassword = (request.getPassword() != null && !request.getPassword().isBlank()) ? request.getPassword() : "123456";
        User user = userRepository.save(User.builder()
                .username(request.getStudentCode().trim())
                .password(passwordEncoder.encode(rawPassword))
                .email(request.getEmail().trim())
                .fullName(request.getFullName().trim())
                .phone(request.getPhone())
                .active(true)
                .roles(Set.of(studentRole))
                .build());

        Student saved = studentRepository.save(Student.builder()
                .user(user)
                .studentCode(request.getStudentCode().trim())
                .department(dept)
                .academicProgram(program)
                .cohort(request.getCohort())
                .status(Student.StudentStatus.STUDYING)
                .dateOfBirth(request.getDateOfBirth())
                .gender(request.getGender())
                .address(request.getAddress())
                .build());

        return ResponseEntity.ok(ApiResponse.ok("Tạo sinh viên thành công", toStudentDto(saved)));
    }

    @PutMapping("/students/{id}")
    @Transactional
    @Operation(summary = "Cập nhật hồ sơ sinh viên")
    public ResponseEntity<ApiResponse<StudentDto>> updateStudent(
            @PathVariable Long id, @Valid @RequestBody UpdateStudentRequest request) {
        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Sinh viên", "id", id));
        User user = student.getUser();
        user.setFullName(request.getFullName().trim());
        if (request.getEmail() != null && !request.getEmail().isBlank()) user.setEmail(request.getEmail().trim());
        user.setPhone(request.getPhone());
        if (request.getActive() != null) user.setActive(request.getActive());
        userRepository.save(user);

        if (request.getDepartmentId() != null) {
            student.setDepartment(departmentRepository.findById(request.getDepartmentId())
                    .orElseThrow(() -> new ResourceNotFoundException("Khoa", "id", request.getDepartmentId())));
        }
        if (request.getProgramId() != null) {
            student.setAcademicProgram(academicProgramRepository.findById(request.getProgramId())
                    .orElseThrow(() -> new ResourceNotFoundException("CTĐT", "id", request.getProgramId())));
        }
        if (request.getCohort() != null) student.setCohort(request.getCohort());
        if (request.getStatus() != null) student.setStatus(request.getStatus());
        student.setDateOfBirth(request.getDateOfBirth());
        student.setGender(request.getGender());
        student.setAddress(request.getAddress());

        return ResponseEntity.ok(ApiResponse.ok("Cập nhật sinh viên thành công", toStudentDto(studentRepository.save(student))));
    }

    @PostMapping("/students/import-excel")
    @Transactional
    @Operation(summary = "Import danh sách sinh viên từ file Excel (.xlsx)")
    public ResponseEntity<ApiResponse<ImportResultDto>> importStudentsExcel(@RequestParam("file") MultipartFile file) {
        Role studentRole = roleRepository.findByName(RoleEnum.ROLE_STUDENT)
                .orElseThrow(() -> new ResourceNotFoundException("Role ROLE_STUDENT không tồn tại"));

        int totalRows = 0;
        int imported = 0;
        int skipped = 0;
        List<String> errors = new ArrayList<>();
        DataFormatter formatter = new DataFormatter();

        try (InputStream is = file.getInputStream(); Workbook workbook = new XSSFWorkbook(is)) {
            Sheet sheet = workbook.getSheetAt(0);
            for (int r = 1; r <= sheet.getLastRowNum(); r++) {
                Row row = sheet.getRow(r);
                if (row == null) continue;
                String studentCode = formatter.formatCellValue(row.getCell(0)).trim();
                if (studentCode.isEmpty()) continue;
                totalRows++;

                try {
                    String fullName = formatter.formatCellValue(row.getCell(1)).trim();
                    String email = formatter.formatCellValue(row.getCell(2)).trim();
                    String phone = formatter.formatCellValue(row.getCell(3)).trim();
                    String deptCode = formatter.formatCellValue(row.getCell(4)).trim();
                    String progCode = formatter.formatCellValue(row.getCell(5)).trim();
                    int cohort = Integer.parseInt(formatter.formatCellValue(row.getCell(6)).trim());

                    if (studentRepository.existsByStudentCode(studentCode) || userRepository.existsByEmail(email)) {
                        skipped++;
                        errors.add("Dòng " + (r + 1) + ": Trùng mã SV hoặc email (" + studentCode + ")");
                        continue;
                    }

                    Department dept = departmentRepository.findByCode(deptCode)
                            .orElseThrow(() -> new IllegalArgumentException("Không thấy mã khoa " + deptCode));
                    AcademicProgram prog = academicProgramRepository.findByCode(progCode)
                            .orElseThrow(() -> new IllegalArgumentException("Không thấy mã CTĐT " + progCode));

                    User user = userRepository.save(User.builder()
                            .username(studentCode)
                            .password(passwordEncoder.encode("123456"))
                            .email(email)
                            .fullName(fullName)
                            .phone(phone)
                            .active(true)
                            .roles(Set.of(studentRole))
                            .build());

                    studentRepository.save(Student.builder()
                            .user(user)
                            .studentCode(studentCode)
                            .department(dept)
                            .academicProgram(prog)
                            .cohort(cohort)
                            .status(Student.StudentStatus.STUDYING)
                            .build());
                    imported++;
                } catch (Exception ex) {
                    skipped++;
                    errors.add("Dòng " + (r + 1) + ": " + ex.getMessage());
                }
            }
        } catch (Exception e) {
            throw new AppException(ErrorCode.BAD_REQUEST, "Không đọc được file Excel: " + e.getMessage());
        }

        return ResponseEntity.ok(ApiResponse.ok("Hoàn tất import sinh viên", ImportResultDto.builder()
                .totalRows(totalRows)
                .importedCount(imported)
                .skippedCount(skipped)
                .errors(errors)
                .build()));
    }

    // --- Giảng viên ---
    @GetMapping("/teachers")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách giảng viên (phân trang)")
    public ResponseEntity<ApiResponse<PageResponse<TeacherDto>>> getTeachers(
            @RequestParam(required = false) Long departmentId,
            @RequestParam(required = false) Boolean active,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("teacherCode").ascending());
        Page<TeacherDto> teacherPage = teacherRepository.searchTeachers(departmentId, active, keyword, pageable)
                .map(this::toTeacherDto);
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.from(teacherPage)));
    }

    @PostMapping("/teachers")
    @Transactional
    @Operation(summary = "Tạo hồ sơ giảng viên kèm tài khoản đăng nhập")
    public ResponseEntity<ApiResponse<TeacherDto>> createTeacher(@Valid @RequestBody CreateTeacherRequest request) {
        if (teacherRepository.existsByTeacherCode(request.getTeacherCode()) || userRepository.existsByUsername(request.getTeacherCode())) {
            throw new ConflictException("Mã giảng viên đã tồn tại");
        }
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("Email đã được sử dụng");
        }
        Department dept = departmentRepository.findById(request.getDepartmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Khoa", "id", request.getDepartmentId()));
        Role teacherRole = roleRepository.findByName(RoleEnum.ROLE_TEACHER)
                .orElseThrow(() -> new ResourceNotFoundException("Role ROLE_TEACHER không tồn tại"));

        String rawPassword = (request.getPassword() != null && !request.getPassword().isBlank()) ? request.getPassword() : "123456";
        User user = userRepository.save(User.builder()
                .username(request.getTeacherCode().trim())
                .password(passwordEncoder.encode(rawPassword))
                .email(request.getEmail().trim())
                .fullName(request.getFullName().trim())
                .phone(request.getPhone())
                .active(true)
                .roles(Set.of(teacherRole))
                .build());

        Teacher saved = teacherRepository.save(Teacher.builder()
                .user(user)
                .teacherCode(request.getTeacherCode().trim())
                .department(dept)
                .academicRank(request.getAcademicRank())
                .academicTitle(request.getAcademicTitle())
                .officeAddress(request.getOfficeAddress())
                .build());
        return ResponseEntity.ok(ApiResponse.ok("Tạo giảng viên thành công", toTeacherDto(saved)));
    }

    @PutMapping("/teachers/{id}")
    @Transactional
    @Operation(summary = "Cập nhật thông tin giảng viên và trạng thái làm việc")
    public ResponseEntity<ApiResponse<TeacherDto>> updateTeacher(
            @PathVariable Long id,
            @Valid @RequestBody UpdateTeacherRequest request) {
        Teacher teacher = teacherRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Giảng viên", "id", id));
        User user = teacher.getUser();

        if (request.getEmail() != null && !request.getEmail().trim().equalsIgnoreCase(user.getEmail())) {
            if (userRepository.existsByEmail(request.getEmail().trim())) {
                throw new ConflictException("Email đã được sử dụng bởi tài khoản khác");
            }
            user.setEmail(request.getEmail().trim());
            teacher.setEmail(request.getEmail().trim());
        }

        if (request.getFullName() != null) {
            user.setFullName(request.getFullName().trim());
        }
        if (request.getPhone() != null) {
            user.setPhone(request.getPhone().trim());
            teacher.setPhone(request.getPhone().trim());
        }
        if (request.getActive() != null) {
            user.setActive(request.getActive());
        }

        if (request.getDepartmentId() != null) {
            Department dept = departmentRepository.findById(request.getDepartmentId())
                    .orElseThrow(() -> new ResourceNotFoundException("Khoa", "id", request.getDepartmentId()));
            teacher.setDepartment(dept);
        }
        if (request.getAcademicRank() != null) {
            teacher.setAcademicRank(request.getAcademicRank());
        }
        if (request.getAcademicTitle() != null) {
            teacher.setAcademicTitle(request.getAcademicTitle());
        }
        if (request.getOfficeAddress() != null) {
            teacher.setOfficeAddress(request.getOfficeAddress());
        }

        userRepository.save(user);
        Teacher updated = teacherRepository.save(teacher);
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật thông tin giảng viên thành công", toTeacherDto(updated)));
    }

    // --- Lớp học phần & TKB ---
    @GetMapping("/class-sections")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách lớp học phần (phân trang)")
    public ResponseEntity<ApiResponse<PageResponse<ClassSectionDto>>> getClassSections(
            @RequestParam(required = false) Long semesterId,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("sectionCode").ascending());
        Page<ClassSectionDto> dtoPage = classSectionRepository.searchClassSections(semesterId, keyword, pageable)
                .map(this::toClassSectionDto);
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.from(dtoPage)));
    }

    @PostMapping("/class-sections")
    @Transactional
    @Operation(summary = "Mở lớp học phần mới kèm lịch học")
    public ResponseEntity<ApiResponse<ClassSectionDto>> createClassSection(@Valid @RequestBody ClassSectionRequest request) {
        if (classSectionRepository.existsBySemesterIdAndSectionCode(request.getSemesterId(), request.getSectionCode())) {
            throw new ConflictException("Mã lớp học phần đã tồn tại trong học kỳ này");
        }
        Course course = courseRepository.findById(request.getCourseId())
                .orElseThrow(() -> new ResourceNotFoundException("Môn học", "id", request.getCourseId()));
        Semester semester = semesterRepository.findById(request.getSemesterId())
                .orElseThrow(() -> new ResourceNotFoundException("Học kỳ", "id", request.getSemesterId()));
        Teacher teacher = request.getTeacherId() != null
                ? teacherRepository.findById(request.getTeacherId())
                .orElseThrow(() -> new ResourceNotFoundException("Giảng viên", "id", request.getTeacherId()))
                : null;

        ClassSection section = ClassSection.builder()
                .course(course)
                .semester(semester)
                .teacher(teacher)
                .sectionCode(request.getSectionCode().trim())
                .maxCapacity(request.getMaxCapacity())
                .currentEnrolled(0)
                .status(request.getStatus() != null ? request.getStatus() : ClassSection.SectionStatus.OPEN)
                .build();

        if (request.getSchedules() != null) {
            for (ClassScheduleRequest sr : request.getSchedules()) {
                section.getSchedules().add(ClassSchedule.builder()
                        .classSection(section)
                        .dayOfWeek(sr.getDayOfWeek())
                        .startPeriod(sr.getStartPeriod())
                        .endPeriod(sr.getEndPeriod())
                        .room(sr.getRoom().trim())
                        .build());
            }
        }

        ClassSection saved = classSectionRepository.save(section);
        return ResponseEntity.ok(ApiResponse.ok("Mở lớp học phần thành công", toClassSectionDto(saved)));
    }

    @DeleteMapping("/class-sections/{id}")
    @Transactional
    @Operation(summary = "Xóa lớp học phần")
    public ResponseEntity<ApiResponse<Void>> deleteClassSection(@PathVariable Long id) {
        if (!classSectionRepository.existsById(id)) {
            throw new ResourceNotFoundException("Lớp học phần", "id", id);
        }
        classSectionRepository.deleteById(id);
        return ResponseEntity.ok(ApiResponse.ok("Đã xóa lớp học phần", null));
    }

    @PostMapping("/class-sections/{id}/force-enroll")
    @Operation(summary = "Ép ghi danh sinh viên vào lớp")
    public ResponseEntity<ApiResponse<Void>> forceEnroll(
            @PathVariable Long id, @RequestBody Map<String, Long> body) {
        Long studentId = body.get("studentId");
        enrollmentService.forceEnroll(studentId, id);
        return ResponseEntity.ok(ApiResponse.ok("Ép ghi danh thành công", null));
    }

    @DeleteMapping("/class-sections/{id}/force-drop/{studentId}")
    @Operation(summary = "Hủy ghi danh sinh viên khỏi lớp")
    public ResponseEntity<ApiResponse<Void>> forceDrop(
            @PathVariable Long id, @PathVariable Long studentId) {
        enrollmentService.forceDrop(studentId, id);
        return ResponseEntity.ok(ApiResponse.ok("Đã hủy ghi danh sinh viên", null));
    }

    // --- Quản lý Sổ điểm & Khóa điểm theo Lớp học phần ---
    @GetMapping("/class-sections/grades-summary")
    @Transactional(readOnly = true)
    @Operation(summary = "Danh sách lớp học phần kèm thống kê trạng thái sổ điểm")
    public ResponseEntity<ApiResponse<List<SectionGradeSummaryDto>>> getSectionGradesSummary(
            @RequestParam(required = false) Long semesterId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String statusFilter) {

        List<ClassSection> sections;
        if (semesterId != null) {
            sections = classSectionRepository.findBySemesterIdWithDetails(semesterId);
        } else {
            Semester activeSem = semesterRepository.findByRegisterOpenTrue()
                    .orElse(semesterRepository.findAll(Sort.by(Sort.Direction.DESC, "code")).stream().findFirst().orElse(null));
            sections = activeSem != null
                    ? classSectionRepository.findBySemesterIdWithDetails(activeSem.getId())
                    : classSectionRepository.findAll();
        }

        String kw = keyword != null ? keyword.trim().toLowerCase() : "";

        List<SectionGradeSummaryDto> list = new ArrayList<>();
        for (ClassSection cs : sections) {
            if (!kw.isEmpty()) {
                boolean matchCode = cs.getSectionCode().toLowerCase().contains(kw);
                boolean matchCourse = cs.getCourse().getName().toLowerCase().contains(kw)
                        || cs.getCourse().getCode().toLowerCase().contains(kw);
                boolean matchTeacher = cs.getTeacher() != null && cs.getTeacher().getUser().getFullName().toLowerCase().contains(kw);
                if (!matchCode && !matchCourse && !matchTeacher) continue;
            }

            List<Grade> grades = gradeRepository.findByClassSectionId(cs.getId());
            int total = cs.getCurrentEnrolled();
            int graded = (int) grades.stream().filter(g -> g.getTotalScore10() != null).count();
            int locked = (int) grades.stream().filter(Grade::isLocked).count();

            boolean allLocked = total > 0 && locked == total;
            boolean partiallyLocked = locked > 0 && locked < total;
            String status = allLocked ? "LOCKED" : (locked == 0 ? "OPEN" : "PARTIAL");

            if ("LOCKED".equalsIgnoreCase(statusFilter) && !allLocked) continue;
            if ("OPEN".equalsIgnoreCase(statusFilter) && allLocked) continue;

            String teacherName = cs.getTeacher() != null ? cs.getTeacher().getUser().getFullName() : "Chưa phân công";

            list.add(SectionGradeSummaryDto.builder()
                    .classSectionId(cs.getId())
                    .sectionCode(cs.getSectionCode())
                    .courseId(cs.getCourse().getId())
                    .courseCode(cs.getCourse().getCode())
                    .courseName(cs.getCourse().getName())
                    .credits(cs.getCourse().getCredits())
                    .departmentName(cs.getCourse().getDepartment() != null ? cs.getCourse().getDepartment().getName() : "")
                    .semesterId(cs.getSemester().getId())
                    .semesterCode(cs.getSemester().getCode())
                    .semesterName(cs.getSemester().getName())
                    .teacherName(teacherName)
                    .totalStudents(total)
                    .gradedCount(graded)
                    .lockedCount(locked)
                    .allLocked(allLocked)
                    .partiallyLocked(partiallyLocked)
                    .status(status)
                    .build());
        }

        list.sort(Comparator.comparing(SectionGradeSummaryDto::getSectionCode));
        return ResponseEntity.ok(ApiResponse.ok(list));
    }

    @GetMapping("/class-sections/{classSectionId}/grades")
    @Transactional
    @Operation(summary = "Xem toàn bộ bảng điểm của một lớp học phần từ phía Admin")
    public ResponseEntity<ApiResponse<List<ClassGradeRowDto>>> getAdminClassGrades(
            @PathVariable Long classSectionId) {
        ClassSection cs = classSectionRepository.findById(classSectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Lớp học phần", "id", classSectionId));

        List<Enrollment> enrollments = enrollmentRepository.findByClassSectionId(classSectionId);
        for (Enrollment e : enrollments) {
            if (gradeRepository.findByEnrollmentId(e.getId()).isEmpty()) {
                gradeRepository.save(Grade.builder().enrollment(e).locked(false).build());
            }
        }

        List<ClassGradeRowDto> rows = gradeRepository.findByClassSectionId(classSectionId).stream()
                .map(g -> {
                    var e = g.getEnrollment();
                    var s = e.getStudent();
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
                })
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.ok(rows));
    }

    @PutMapping("/class-sections/{classSectionId}/unlock")
    @Transactional
    @Operation(summary = "Mở khóa toàn bộ sổ điểm của một lớp học phần")
    public ResponseEntity<ApiResponse<Void>> unlockClassSectionGrades(@PathVariable Long classSectionId) {
        ClassSection section = classSectionRepository.findById(classSectionId).orElse(null);
        if (section != null) {
            section.setStatus(ClassSection.SectionStatus.OPEN);
            classSectionRepository.save(section);
        }
        List<Grade> grades = gradeRepository.findByClassSectionId(classSectionId);
        for (Grade g : grades) {
            g.setLocked(false);
        }
        gradeRepository.saveAll(grades);
        return ResponseEntity.ok(ApiResponse.ok("Đã mở khóa sổ điểm cho cả lớp học phần thành công", null));
    }

    @PutMapping("/class-sections/{classSectionId}/lock")
    @Transactional
    @Operation(summary = "Khóa toàn bộ sổ điểm của một lớp học phần")
    public ResponseEntity<ApiResponse<Void>> lockClassSectionGrades(@PathVariable Long classSectionId) {
        ClassSection section = classSectionRepository.findById(classSectionId).orElse(null);
        if (section != null) {
            section.setStatus(ClassSection.SectionStatus.CLOSED);
            classSectionRepository.save(section);
        }
        List<Grade> grades = gradeRepository.findByClassSectionId(classSectionId);
        for (Grade g : grades) {
            g.setLocked(true);
        }
        gradeRepository.saveAll(grades);
        return ResponseEntity.ok(ApiResponse.ok("Đã khóa sổ điểm lớp học phần thành công", null));
    }

    @PutMapping("/class-sections/{classSectionId}/grades")
    @Transactional
    @Operation(summary = "Cập nhật bảng điểm cả lớp từ Admin")
    public ResponseEntity<ApiResponse<Void>> updateClassGradesByAdmin(
            @PathVariable Long classSectionId,
            @Valid @RequestBody GradeBatchUpdateRequest request) {
        ClassSection section = classSectionRepository.findById(classSectionId)
                .orElseThrow(() -> new ResourceNotFoundException("Lớp học phần", "id", classSectionId));
        Course course = section.getCourse();

        for (GradeBatchUpdateRequest.StudentGradeEntry entry : request.getGrades()) {
            Grade grade = gradeRepository.findByEnrollmentId(entry.getEnrollmentId())
                    .orElseThrow(() -> new ResourceNotFoundException("Bản ghi điểm", "enrollmentId", entry.getEnrollmentId()));

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
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật bảng điểm thành công", null));
    }

    // --- Quản lý điểm & Mở khóa ---
    @GetMapping("/grades")
    @Transactional(readOnly = true)
    @Operation(summary = "Tra cứu bảng điểm toàn trường")
    public ResponseEntity<ApiResponse<PageResponse<AdminGradeRowDto>>> getGrades(
            @RequestParam(required = false) Long semesterId,
            @RequestParam(required = false) Boolean locked,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("id").descending());
        Page<AdminGradeRowDto> result = gradeRepository.searchGradesForAdmin(semesterId, locked, keyword, pageable)
                .map(g -> {
                    var e = g.getEnrollment();
                    var cs = e.getClassSection();
                    return AdminGradeRowDto.builder()
                            .gradeId(g.getId())
                            .semesterCode(cs.getSemester().getCode())
                            .semesterName(cs.getSemester().getName())
                            .sectionCode(cs.getSectionCode())
                            .courseCode(cs.getCourse().getCode())
                            .courseName(cs.getCourse().getName())
                            .studentCode(e.getStudent().getStudentCode())
                            .studentName(e.getStudent().getUser().getFullName())
                            .attendanceScore(g.getAttendanceScore())
                            .midtermScore(g.getMidtermScore())
                            .finalScore(g.getFinalScore())
                            .totalScore10(g.getTotalScore10())
                            .gpaScore4(g.getGpaScore4())
                            .letterGrade(g.getLetterGrade())
                            .locked(g.isLocked())
                            .build();
                });
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.from(result)));
    }

    @PutMapping("/grades/{gradeId}/unlock")
    @Transactional
    @Operation(summary = "Mở khóa sổ điểm cho giảng viên sửa lại khi có phúc khảo")
    public ResponseEntity<ApiResponse<Void>> unlockGrade(@PathVariable Long gradeId) {
        Grade grade = gradeRepository.findById(gradeId)
                .orElseThrow(() -> new ResourceNotFoundException("Bản ghi điểm", "id", gradeId));
        grade.setLocked(false);
        gradeRepository.save(grade);
        return ResponseEntity.ok(ApiResponse.ok("Đã mở khóa điểm thành công", null));
    }

    // --- Mappers ---
    private DepartmentDto toDepartmentDto(Department d) {
        return DepartmentDto.builder()
                .id(d.getId()).code(d.getCode()).name(d.getName())
                .phone(d.getPhone()).email(d.getEmail()).description(d.getDescription())
                .build();
    }

    private AcademicProgramDto toProgramDto(AcademicProgram p) {
        return AcademicProgramDto.builder()
                .id(p.getId()).code(p.getCode()).name(p.getName())
                .departmentId(p.getDepartment().getId())
                .departmentCode(p.getDepartment().getCode())
                .departmentName(p.getDepartment().getName())
                .totalCredits(p.getTotalCredits()).durationYears(p.getDurationYears())
                .description(p.getDescription())
                .build();
    }

    private CourseDto toCourseDto(Course c) {
        return CourseDto.builder()
                .id(c.getId()).code(c.getCode()).name(c.getName())
                .credits(c.getCredits()).theoryHours(c.getTheoryHours()).practiceHours(c.getPracticeHours())
                .attendanceWeight(c.getAttendanceWeight()).midtermWeight(c.getMidtermWeight()).finalWeight(c.getFinalWeight())
                .departmentId(c.getDepartment().getId()).departmentName(c.getDepartment().getName())
                .prerequisites(c.getPrerequisites().stream()
                        .map(p -> SimpleCourseDto.builder().id(p.getId()).code(p.getCode()).name(p.getName()).credits(p.getCredits()).build())
                        .collect(Collectors.toList()))
                .build();
    }

    private SemesterDto toSemesterDto(Semester s) {
        return SemesterDto.builder()
                .id(s.getId()).code(s.getCode()).name(s.getName())
                .academicYear(s.getAcademicYear()).semesterNumber(s.getSemesterNumber())
                .startDate(s.getStartDate()).endDate(s.getEndDate())
                .registerOpen(s.isRegisterOpen()).minCredits(s.getMinCredits()).maxCredits(s.getMaxCredits())
                .build();
    }

    private StudentDto toStudentDto(Student s) {
        return StudentDto.builder()
                .id(s.getId()).studentCode(s.getStudentCode())
                .fullName(s.getUser().getFullName()).username(s.getUser().getUsername())
                .email(s.getUser().getEmail()).phone(s.getUser().getPhone())
                .departmentId(s.getDepartment().getId()).departmentCode(s.getDepartment().getCode())
                .departmentName(s.getDepartment().getName())
                .programId(s.getAcademicProgram().getId()).programCode(s.getAcademicProgram().getCode())
                .programName(s.getAcademicProgram().getName())
                .cohort(s.getCohort()).status(s.getStatus())
                .dateOfBirth(s.getDateOfBirth()).gender(s.getGender()).address(s.getAddress())
                .active(s.getUser().isActive())
                .build();
    }

    private TeacherDto toTeacherDto(Teacher t) {
        return TeacherDto.builder()
                .id(t.getId()).teacherCode(t.getTeacherCode())
                .fullName(t.getUser().getFullName()).username(t.getUser().getUsername())
                .email(t.getUser().getEmail()).phone(t.getUser().getPhone())
                .departmentId(t.getDepartment().getId()).departmentCode(t.getDepartment().getCode())
                .departmentName(t.getDepartment().getName())
                .academicRank(t.getAcademicRank())
                .academicTitle(t.getAcademicTitle())
                .officeAddress(t.getOfficeAddress())
                .active(t.getUser().isActive())
                .build();
    }

    private ClassSectionDto toClassSectionDto(ClassSection cs) {
        List<Grade> grades = gradeRepository.findByClassSectionId(cs.getId());
        boolean isGradesLocked = !grades.isEmpty() && grades.stream().allMatch(Grade::isLocked);
        boolean allGraded = !grades.isEmpty() && grades.stream().allMatch(g -> g.getTotalScore10() != null);
        boolean isFinished = cs.getStatus() == ClassSection.SectionStatus.CLOSED || isGradesLocked;

        return ClassSectionDto.builder()
                .id(cs.getId()).sectionCode(cs.getSectionCode())
                .courseId(cs.getCourse().getId()).courseCode(cs.getCourse().getCode())
                .courseName(cs.getCourse().getName()).credits(cs.getCourse().getCredits())
                .semesterId(cs.getSemester().getId()).semesterCode(cs.getSemester().getCode())
                .semesterName(cs.getSemester().getName())
                .teacherId(cs.getTeacher() != null ? cs.getTeacher().getId() : null)
                .teacherCode(cs.getTeacher() != null ? cs.getTeacher().getTeacherCode() : null)
                .teacherName(cs.getTeacher() != null ? cs.getTeacher().getUser().getFullName() : "Chưa phân công")
                .maxCapacity(cs.getMaxCapacity()).currentEnrolled(cs.getCurrentEnrolled())
                .status(cs.getStatus())
                .teachingStatus(isFinished ? "FINISHED" : "TEACHING")
                .isLocked(isGradesLocked)
                .allGraded(allGraded)
                .schedules(cs.getSchedules().stream()
                        .map(sch -> ClassScheduleDto.builder()
                                .id(sch.getId()).dayOfWeek(sch.getDayOfWeek())
                                .startPeriod(sch.getStartPeriod()).endPeriod(sch.getEndPeriod())
                                .room(sch.getRoom()).build())
                        .collect(Collectors.toList()))
                .build();
    }
}
