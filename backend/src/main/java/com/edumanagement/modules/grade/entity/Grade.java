package com.edumanagement.modules.grade.entity;

import com.edumanagement.common.base.BaseEntity;
import com.edumanagement.modules.academic.entity.Course;
import com.edumanagement.modules.registration.entity.Enrollment;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Entity
@Table(name = "grades")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Grade extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "enrollment_id", nullable = false, unique = true)
    private Enrollment enrollment;

    @Column(name = "regular_score_1", precision = 4, scale = 2)
    private BigDecimal regularScore1; // Thường xuyên 1 (TX1)

    @Column(name = "regular_score_2", precision = 4, scale = 2)
    private BigDecimal regularScore2; // Thường xuyên 2 (TX2)

    @Column(name = "attendance_score", precision = 4, scale = 2)
    private BigDecimal attendanceScore; // Điểm quá trình/thường xuyên tổng hợp

    @Column(name = "midterm_score", precision = 4, scale = 2)
    private BigDecimal midtermScore; // Điểm giữa kỳ (hệ 10)

    @Column(name = "final_score", precision = 4, scale = 2)
    private BigDecimal finalScore; // Điểm cuối kỳ (hệ 10)

    @Column(name = "total_score_10", precision = 4, scale = 2)
    private BigDecimal totalScore10; // Điểm tổng kết hệ 10

    @Column(name = "gpa_score_4", precision = 4, scale = 2)
    private BigDecimal gpaScore4; // Quy đổi thang điểm 4

    @Column(name = "letter_grade", length = 5)
    private String letterGrade; // A+, A, B+, B, C+, C, D+, D, F

    @Builder.Default
    @Column(name = "is_locked", nullable = false)
    private boolean locked = false;

    /**
     * Tự động tính điểm tổng kết và quy đổi theo trọng số của môn học.
     * Quy định:
     * - Môn từ 3 tín chỉ trở xuống (credits <= 3): Không có điểm giữa kỳ, chỉ có TX1, TX2 và cuối kỳ.
     *   Trọng số cuối kỳ luôn ở mức 50-70% (mặc định CK 60%, TX 40% tương ứng TX1 20%, TX2 20%).
     * - Môn từ 4 tín chỉ trở lên (credits >= 4): Có thường xuyên 1, 2, giữa kỳ và cuối kỳ.
     *   Trọng số: TX 20%, Giữa kỳ 30%, Cuối kỳ 50% (trong khoảng 50-70%).
     * - Điểm tổng kết hệ 10 LUÔN làm tròn đến chữ số thập phân thứ nhất (scale = 1: 9.0, 9.1, 8.4...).
     */
    public void calculateFinalGrades(Course course) {
        BigDecimal tx;
        if (regularScore1 != null && regularScore2 != null) {
            tx = regularScore1.add(regularScore2).divide(BigDecimal.valueOf(2), 2, RoundingMode.HALF_UP);
            this.attendanceScore = tx;
        } else if (regularScore1 != null) {
            tx = regularScore1;
            this.attendanceScore = tx;
        } else {
            tx = attendanceScore;
        }

        int credits = (course != null && course.getCredits() != null) ? course.getCredits() : 3;
        boolean hasMidterm = credits >= 4;

        if (tx == null || finalScore == null || (hasMidterm && midtermScore == null)) {
            return;
        }

        BigDecimal total;
        if (!hasMidterm) {
            this.midtermScore = null;
            BigDecimal attW = (course != null && course.getAttendanceWeight() != null && course.getAttendanceWeight().compareTo(BigDecimal.ZERO) > 0)
                    ? course.getAttendanceWeight()
                    : new BigDecimal("0.40");
            BigDecimal finW = (course != null && course.getFinalWeight() != null && course.getFinalWeight().compareTo(BigDecimal.ZERO) > 0)
                    ? course.getFinalWeight()
                    : new BigDecimal("0.60");

            BigDecimal sum = attW.add(finW);
            if (sum.compareTo(BigDecimal.ZERO) > 0 && sum.compareTo(BigDecimal.ONE) != 0) {
                attW = attW.divide(sum, 2, RoundingMode.HALF_UP);
                finW = BigDecimal.ONE.subtract(attW);
            }
            total = tx.multiply(attW).add(finalScore.multiply(finW));
        } else {
            BigDecimal attW = (course != null && course.getAttendanceWeight() != null && course.getAttendanceWeight().compareTo(BigDecimal.ZERO) > 0)
                    ? course.getAttendanceWeight()
                    : new BigDecimal("0.20");
            BigDecimal midW = (course != null && course.getMidtermWeight() != null && course.getMidtermWeight().compareTo(BigDecimal.ZERO) > 0)
                    ? course.getMidtermWeight()
                    : new BigDecimal("0.30");
            BigDecimal finW = (course != null && course.getFinalWeight() != null && course.getFinalWeight().compareTo(BigDecimal.ZERO) > 0)
                    ? course.getFinalWeight()
                    : new BigDecimal("0.50");

            total = tx.multiply(attW)
                    .add(midtermScore.multiply(midW))
                    .add(finalScore.multiply(finW));
        }

        // Luôn làm tròn điểm đến chữ số thập phân thứ nhất (scale = 1: 9.0, 9.1, 8.4, ...)
        this.totalScore10 = total.setScale(1, RoundingMode.HALF_UP);

        double score = totalScore10.doubleValue();
        if (score >= 9.0) {
            this.letterGrade = "A+";
            this.gpaScore4 = new BigDecimal("4.0");
        } else if (score >= 8.5) {
            this.letterGrade = "A";
            this.gpaScore4 = new BigDecimal("3.7");
        } else if (score >= 8.0) {
            this.letterGrade = "B+";
            this.gpaScore4 = new BigDecimal("3.5");
        } else if (score >= 7.0) {
            this.letterGrade = "B";
            this.gpaScore4 = new BigDecimal("3.0");
        } else if (score >= 6.5) {
            this.letterGrade = "C+";
            this.gpaScore4 = new BigDecimal("2.5");
        } else if (score >= 5.5) {
            this.letterGrade = "C";
            this.gpaScore4 = new BigDecimal("2.0");
        } else if (score >= 5.0) {
            this.letterGrade = "D+";
            this.gpaScore4 = new BigDecimal("1.5");
        } else if (score >= 4.0) {
            this.letterGrade = "D";
            this.gpaScore4 = new BigDecimal("1.0");
        } else {
            this.letterGrade = "F";
            this.gpaScore4 = new BigDecimal("0.0");
        }
    }

    public boolean isPassed() {
        return totalScore10 != null && totalScore10.doubleValue() >= 4.0;
    }
}
