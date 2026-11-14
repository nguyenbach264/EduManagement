package com.edumanagement.modules.registration.service;

import com.edumanagement.common.exception.AppException;
import com.edumanagement.common.exception.ErrorCode;
import com.edumanagement.modules.registration.entity.ClassSchedule;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ScheduleValidationService {

    /**
     * Kiểm tra xung đột lịch học giữa lớp đang muốn đăng ký và các lớp đã đăng ký trước đó.
     * Thuật toán: Với mỗi buổi học của lớp mới, duyệt qua tất cả buổi học của các lớp đã có.
     * Nếu trùng ngày trong tuần và khoảng thời gian giao nhau thì ném ngoại lệ xung đột.
     */
    public void validateNoScheduleCollision(List<ClassSchedule> newSchedules, List<ClassSchedule> existingSchedules) {
        if (newSchedules == null || existingSchedules == null) {
            return;
        }

        for (ClassSchedule newSched : newSchedules) {
            for (ClassSchedule existing : existingSchedules) {
                if (newSched.overlapsWith(existing)) {
                    String message = String.format(
                            "Trùng lịch học: Lớp mới học Thứ %d (tiết %d-%d, phòng %s) xung đột với môn đã đăng ký '%s' học Thứ %d (tiết %d-%d, phòng %s)",
                            newSched.getDayOfWeek(), newSched.getStartPeriod(), newSched.getEndPeriod(), newSched.getRoom(),
                            existing.getClassSection().getCourse().getName(),
                            existing.getDayOfWeek(), existing.getStartPeriod(), existing.getEndPeriod(), existing.getRoom()
                    );
                    throw new AppException(ErrorCode.SCHEDULE_CONFLICT, message);
                }
            }
        }
    }
}
