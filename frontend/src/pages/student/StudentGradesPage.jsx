import React from 'react';
import { StudentAcademicResultsTable } from '../../components/StudentAcademicResultsTable';

export const StudentGradesPage = () => {
  return (
    <div className="space-y-5">
      <StudentAcademicResultsTable
        showHeader={true}
        showPdfExport={true}
        cardTitle="Bảng điểm học tập & Kết quả toàn khóa"
      />
    </div>
  );
};
