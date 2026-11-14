import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { teacherApi } from '../../api/services';
import { AcademicScheduleView } from '../../components/AcademicScheduleView';
import { useSemester } from '../../context/SemesterContext';

export const TeacherSchedulePage = () => {
  const { selectedSemesterId, selectedSemester } = useSemester();

  const { data: rawSchedule = [], isLoading } = useQuery({
    queryKey: ['teacher-schedule', selectedSemesterId],
    queryFn: () => teacherApi.getSchedule(selectedSemesterId),
  });

  return (
    <AcademicScheduleView
      schedule={rawSchedule}
      isLoading={isLoading}
      title="Lịch giảng dạy tuần"
      subtitle="Xem lịch giảng dạy theo tuần. Bấm vào từng buổi học để xem phòng học hoặc xem chart phân tích kết quả của lớp."
      semesterName={selectedSemester?.name || 'Năm học 2026 - 2027'}
      isTeacher={true}
    />
  );
};
