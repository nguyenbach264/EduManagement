import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { studentApi } from '../../api/services';
import { AcademicScheduleView } from '../../components/AcademicScheduleView';
import { useSemester } from '../../context/SemesterContext';

export const StudentSchedulePage = () => {
  const { selectedSemesterId, selectedSemester } = useSemester();

  const { data: rawSchedule = [], isLoading } = useQuery({
    queryKey: ['student-schedule', selectedSemesterId],
    queryFn: () => studentApi.getSchedule(selectedSemesterId),
  });

  return (
    <AcademicScheduleView
      schedule={rawSchedule}
      isLoading={isLoading}
      title="Thời khóa biểu Cá nhân"
      semesterName={selectedSemester?.name || 'Năm học 2026 - 2027'}
      isTeacher={false}
    />
  );
};
