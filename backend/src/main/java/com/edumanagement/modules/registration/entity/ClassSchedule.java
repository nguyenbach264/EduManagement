package com.edumanagement.modules.registration.entity;

import com.edumanagement.common.base.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "class_schedules")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClassSchedule extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "class_section_id", nullable = false)
    private ClassSection classSection;

    @Column(name = "day_of_week", nullable = false)
    private Integer dayOfWeek; // 2: Monday, 3: Tuesday, ..., 8: Sunday

    @Column(name = "start_period", nullable = false)
    private Integer startPeriod; // 1 to 12

    @Column(name = "end_period", nullable = false)
    private Integer endPeriod; // 1 to 12

    @Column(name = "room", nullable = false, length = 50)
    private String room; // e.g., "A1-302"

    @Builder.Default
    @Column(name = "start_week", nullable = false)
    private Integer startWeek = 1; // Tuần bắt đầu

    @Builder.Default
    @Column(name = "end_week", nullable = false)
    private Integer endWeek = 15; // Tuần kết thúc

    @Column(name = "building", length = 50)
    private String building; // e.g., "Tòa nhà A1"

    @Column(name = "campus", length = 50)
    private String campus; // e.g., "Cơ sở 1"

    /**
     * Kiểm tra xem 2 khung giờ học có bị trùng nhau hay không.
     * Trùng khi: Cùng thứ trong tuần VÀ khoảng tiết giao nhau (max(start) <= min(end)).
     */
    public boolean overlapsWith(ClassSchedule other) {
        if (!this.dayOfWeek.equals(other.dayOfWeek)) {
            return false;
        }
        return Math.max(this.startPeriod, other.startPeriod) <= Math.min(this.endPeriod, other.endPeriod);
    }
}
