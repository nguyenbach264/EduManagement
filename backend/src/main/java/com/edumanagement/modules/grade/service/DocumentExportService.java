package com.edumanagement.modules.grade.service;

import com.edumanagement.modules.grade.dto.GradeDtos.ClassGradeRowDto;
import com.edumanagement.modules.grade.dto.GradeDtos.StudentCourseGradeDto;
import com.edumanagement.modules.registration.entity.ClassSection;
import com.edumanagement.modules.student.entity.Student;
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.Normalizer;
import java.util.List;

@Service
public class DocumentExportService {

    public byte[] exportClassGradesExcel(ClassSection section, List<ClassGradeRowDto> rows) throws IOException {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("BangDiem");

            CellStyle headerStyle = workbook.createCellStyle();
            org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.PALE_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            Row titleRow = sheet.createRow(0);
            titleRow.createCell(0).setCellValue("BANG DIEM LOP HOC PHAN: " + section.getSectionCode() + " - " + section.getCourse().getName());

            String[] headers = {"STT", "Ma SV", "Ho va Ten", "Chuyen can", "Giua ky", "Cuoi ky", "Tong 10", "Diem chu", "He 4", "Trang thai"};
            Row headerRow = sheet.createRow(2);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            int rowIdx = 3;
            int stt = 1;
            for (ClassGradeRowDto dto : rows) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(stt++);
                row.createCell(1).setCellValue(dto.getStudentCode());
                row.createCell(2).setCellValue(dto.getStudentName());
                row.createCell(3).setCellValue(dto.getAttendanceScore() != null ? dto.getAttendanceScore().doubleValue() : 0.0);
                row.createCell(4).setCellValue(dto.getMidtermScore() != null ? dto.getMidtermScore().doubleValue() : 0.0);
                row.createCell(5).setCellValue(dto.getFinalScore() != null ? dto.getFinalScore().doubleValue() : 0.0);
                row.createCell(6).setCellValue(dto.getTotalScore10() != null ? dto.getTotalScore10().doubleValue() : 0.0);
                row.createCell(7).setCellValue(dto.getLetterGrade() != null ? dto.getLetterGrade() : "");
                row.createCell(8).setCellValue(dto.getGpaScore4() != null ? dto.getGpaScore4().doubleValue() : 0.0);
                row.createCell(9).setCellValue(dto.isLocked() ? "Da khoa" : "Dang mo");
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
            return out.toByteArray();
        }
    }

    public byte[] exportStudentTranscriptPdf(Student student, GpaCalculationService.AcademicSummary summary) {
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Document document = new Document(PageSize.A4, 36, 36, 36, 36);
            PdfWriter.getInstance(document, out);
            document.open();

            com.lowagie.text.Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 15, new Color(26, 115, 232));
            com.lowagie.text.Font subFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, Color.DARK_GRAY);
            com.lowagie.text.Font bodyFont = FontFactory.getFont(FontFactory.HELVETICA, 10, Color.BLACK);

            Paragraph title = new Paragraph("PHIEU KET QUA HOC TAP / ACADEMIC TRANSCRIPT", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            document.add(new Paragraph(" "));

            document.add(new Paragraph("Sinh vien: " + toAscii(student.getUser().getFullName()) + "  |  Ma SV: " + student.getStudentCode(), subFont));
            document.add(new Paragraph("Khoa: " + toAscii(student.getDepartment().getName()) + "  |  Nganh: " + toAscii(student.getAcademicProgram().getName()), bodyFont));
            document.add(new Paragraph("CPA Tich luy (He 4): " + summary.getCumulativeGpa()
                    + "  |  He 10: " + summary.getCumulativeScore10()
                    + "  |  Tin chi dat: " + summary.getTotalCreditsEarned()
                    + "  |  Xep loai: " + toAscii(summary.getAcademicClassification()), subFont));
            document.add(new Paragraph(" "));

            PdfPTable table = new PdfPTable(new float[]{1.2f, 1.4f, 3.4f, 0.8f, 1f, 1f, 1f, 1f});
            table.setWidthPercentage(100);
            String[] cols = {"Hoc ky", "Ma HP", "Ten hoc phan", "TC", "He 10", "Chu", "He 4", "Ket qua"};
            for (String col : cols) {
                PdfPCell cell = new PdfPCell(new Phrase(col, subFont));
                cell.setBackgroundColor(new Color(230, 240, 255));
                cell.setPadding(6);
                table.addCell(cell);
            }

            List<StudentCourseGradeDto> grades = summary.getCourseGrades() != null ? summary.getCourseGrades() : List.of();
            for (StudentCourseGradeDto g : grades) {
                table.addCell(new Phrase(g.getSemesterCode(), bodyFont));
                table.addCell(new Phrase(g.getCourseCode(), bodyFont));
                table.addCell(new Phrase(toAscii(g.getCourseName()), bodyFont));
                table.addCell(new Phrase(String.valueOf(g.getCredits()), bodyFont));
                table.addCell(new Phrase(g.getTotalScore10() != null ? g.getTotalScore10().toString() : "-", bodyFont));
                table.addCell(new Phrase(g.getLetterGrade() != null ? g.getLetterGrade() : "-", bodyFont));
                table.addCell(new Phrase(g.getGpaScore4() != null ? g.getGpaScore4().toString() : "-", bodyFont));
                table.addCell(new Phrase(g.isPassed() ? "Dat" : "Khong dat", bodyFont));
            }

            document.add(table);
            document.close();
            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Khong the tao file PDF bang diem: " + e.getMessage(), e);
        }
    }

    private String toAscii(String input) {
        if (input == null) return "";
        String normalized = Normalizer.normalize(input, Normalizer.Form.NFD);
        return normalized.replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                .replace('đ', 'd')
                .replace('Đ', 'D');
    }
}
