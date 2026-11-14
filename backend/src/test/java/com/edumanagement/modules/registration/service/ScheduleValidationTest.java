package com.edumanagement.modules.registration.service;

import com.edumanagement.common.exception.AppException;
import com.edumanagement.modules.academic.entity.Course;
import com.edumanagement.modules.registration.entity.ClassSchedule;
import com.edumanagement.modules.registration.entity.ClassSection;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class ScheduleValidationTest {

    private ScheduleValidationService scheduleValidationService;

    @BeforeEach
    void setUp() {
        scheduleValidationService = new ScheduleValidationService();
    }

    @Test
    @DisplayName("Cùng thứ và tiết học giao nhau -> Ném lỗi SCHEDULE_CONFLICT")
    void testScheduleCollision_SameDay_OverlapPeriods() {
        Course course1 = Course.builder().name("Công nghệ Web").build();
        ClassSection section1 = ClassSection.builder().course(course1).build();

        // Lớp 1: Thứ 2 (tiết 1 đến 3)
        ClassSchedule existingSchedule = ClassSchedule.builder()
                .classSection(section1)
                .dayOfWeek(2)
                .startPeriod(1)
                .endPeriod(3)
                .room("A1-302")
                .build();

        Course course2 = Course.builder().name("Cơ sở dữ liệu").build();
        ClassSection section2 = ClassSection.builder().course(course2).build();

        // Lớp 2: Thứ 2 (tiết 3 đến 5) -> Tiết 3 bị trùng!
        ClassSchedule newSchedule = ClassSchedule.builder()
                .classSection(section2)
                .dayOfWeek(2)
                .startPeriod(3)
                .endPeriod(5)
                .room("B2-101")
                .build();

        assertThrows(AppException.class, () ->
                scheduleValidationService.validateNoScheduleCollision(
                        List.of(newSchedule),
                        List.of(existingSchedule)
                )
        );
    }

    @Test
    @DisplayName("Cùng thứ nhưng không giao nhau -> Hợp lệ, không có lỗi")
    void testScheduleCollision_SameDay_NonOverlapPeriods() {
        Course course1 = Course.builder().name("Công nghệ Web").build();
        ClassSection section1 = ClassSection.builder().course(course1).build();

        // Lớp 1: Thứ 2 (tiết 1 đến 3)
        ClassSchedule existingSchedule = ClassSchedule.builder()
                .classSection(section1)
                .dayOfWeek(2)
                .startPeriod(1)
                .endPeriod(3)
                .room("A1-302")
                .build();

        Course course2 = Course.builder().name("Hệ điều hành").build();
        ClassSection section2 = ClassSection.builder().course(course2).build();

        // Lớp 2: Thứ 2 (tiết 4 đến 6) -> Không giao nhau
        ClassSchedule newSchedule = ClassSchedule.builder()
                .classSection(section2)
                .dayOfWeek(2)
                .startPeriod(4)
                .endPeriod(6)
                .room("B2-101")
                .build();

        assertDoesNotThrow(() ->
                scheduleValidationService.validateNoScheduleCollision(
                        List.of(newSchedule),
                        List.of(existingSchedule)
                )
        );
    }

    @Test
    @DisplayName("Khác thứ trong tuần -> Hợp lệ, không có lỗi")
    void testScheduleCollision_DifferentDays() {
        Course course1 = Course.builder().name("Giải tích 1").build();
        ClassSection section1 = ClassSection.builder().course(course1).build();

        // Lớp 1: Thứ 2 (tiết 1 đến 3)
        ClassSchedule existingSchedule = ClassSchedule.builder()
                .classSection(section1)
                .dayOfWeek(2)
                .startPeriod(1)
                .endPeriod(3)
                .room("A1-302")
                .build();

        Course course2 = Course.builder().name("Đại số tuyến tính").build();
        ClassSection section2 = ClassSection.builder().course(course2).build();

        // Lớp 2: Thứ 4 (tiết 1 đến 3)
        ClassSchedule newSchedule = ClassSchedule.builder()
                .classSection(section2)
                .dayOfWeek(4)
                .startPeriod(1)
                .endPeriod(3)
                .room("A1-302")
                .build();

        assertDoesNotThrow(() ->
                scheduleValidationService.validateNoScheduleCollision(
                        List.of(newSchedule),
                        List.of(existingSchedule)
                )
        );
    }
}
