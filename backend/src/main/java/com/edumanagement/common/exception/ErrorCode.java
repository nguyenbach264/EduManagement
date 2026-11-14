package com.edumanagement.common.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public enum ErrorCode {
    INTERNAL_SERVER_ERROR("ERR_500", "Lỗi hệ thống nội bộ", HttpStatus.INTERNAL_SERVER_ERROR),
    UNAUTHORIZED("ERR_401", "Chưa xác thực hoặc token không hợp lệ", HttpStatus.UNAUTHORIZED),
    FORBIDDEN("ERR_403", "Không có quyền truy cập chức năng này", HttpStatus.FORBIDDEN),
    BAD_REQUEST("ERR_400", "Dữ liệu yêu cầu không hợp lệ", HttpStatus.BAD_REQUEST),
    RESOURCE_NOT_FOUND("ERR_404", "Không tìm thấy dữ liệu yêu cầu", HttpStatus.NOT_FOUND),
    CONFLICT("ERR_409", "Dữ liệu bị trùng lặp hoặc xung đột", HttpStatus.CONFLICT),

    // Business Codes
    USER_NOT_FOUND("USER_404", "Không tìm thấy người dùng", HttpStatus.NOT_FOUND),
    USER_ALREADY_EXISTS("USER_409", "Tên đăng nhập hoặc email đã tồn tại", HttpStatus.CONFLICT),
    INVALID_CREDENTIALS("AUTH_401", "Sai tên đăng nhập hoặc mật khẩu", HttpStatus.UNAUTHORIZED),
    TOKEN_EXPIRED("AUTH_TOKEN_EXPIRED", "Token đã hết hạn", HttpStatus.UNAUTHORIZED),
    TOKEN_REVOKED("AUTH_TOKEN_REVOKED", "Token đã bị thu hồi", HttpStatus.UNAUTHORIZED),

    // Academic & Registration Codes
    PREREQUISITE_NOT_MET("ENROLL_PREREQ", "Sinh viên chưa đạt điều kiện tiên quyết của môn học này", HttpStatus.BAD_REQUEST),
    SCHEDULE_CONFLICT("ENROLL_CONFLICT", "Lớp học phần bị trùng lịch với môn đã đăng ký trong kỳ", HttpStatus.BAD_REQUEST),
    SECTION_FULL("ENROLL_FULL", "Lớp học phần đã hết chỗ đăng ký", HttpStatus.CONFLICT),
    CREDIT_LIMIT_EXCEEDED("ENROLL_CREDIT_MAX", "Vượt quá số lượng tín chỉ tối đa cho phép trong học kỳ", HttpStatus.BAD_REQUEST),
    CREDIT_LIMIT_BELOW("ENROLL_CREDIT_MIN", "Chưa đạt số lượng tín chỉ tối thiểu của học kỳ", HttpStatus.BAD_REQUEST),
    ALREADY_ENROLLED("ENROLL_DUPLICATE", "Sinh viên đã đăng ký lớp học phần của môn này trong kỳ", HttpStatus.CONFLICT),
    REGISTRATION_CLOSED("ENROLL_CLOSED", "Hiện tại đợt đăng ký tín chỉ không mở", HttpStatus.BAD_REQUEST),

    // Grade Codes
    GRADE_LOCKED("GRADE_LOCKED", "Sổ điểm đã bị khóa, không thể chỉnh sửa", HttpStatus.FORBIDDEN);

    private final String code;
    private final String message;
    private final HttpStatus httpStatus;

    ErrorCode(String code, String message, HttpStatus httpStatus) {
        this.code = code;
        this.message = message;
        this.httpStatus = httpStatus;
    }
}
