package com.edumanagement.modules.grade.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GradeBatchUpdateRequest {

    @NotNull
    private List<StudentGradeEntry> grades;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StudentGradeEntry {
        @NotNull
        private Long enrollmentId;

        @DecimalMin(value = "0.0", message = "Điểm phải >= 0")
        @DecimalMax(value = "10.0", message = "Điểm phải <= 10")
        private BigDecimal regularScore1; // Thường xuyên 1

        @DecimalMin(value = "0.0", message = "Điểm phải >= 0")
        @DecimalMax(value = "10.0", message = "Điểm phải <= 10")
        private BigDecimal regularScore2; // Thường xuyên 2

        @DecimalMin(value = "0.0", message = "Điểm phải >= 0")
        @DecimalMax(value = "10.0", message = "Điểm phải <= 10")
        private BigDecimal attendanceScore;

        @DecimalMin(value = "0.0", message = "Điểm phải >= 0")
        @DecimalMax(value = "10.0", message = "Điểm phải <= 10")
        private BigDecimal midtermScore;

        @DecimalMin(value = "0.0", message = "Điểm phải >= 0")
        @DecimalMax(value = "10.0", message = "Điểm phải <= 10")
        private BigDecimal finalScore;
    }
}
