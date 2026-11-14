import React from 'react';
import { Button, Card, Progress, Spin, Tag } from 'antd';
import { AppstoreAddOutlined, BookOutlined, CalendarOutlined, TrophyOutlined } from '@ant-design/icons';
import { useQuery } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { studentApi } from '../../api/services';
import { AcademicScheduleView } from '../../components/AcademicScheduleView';
import { StudentAcademicResultsTable } from '../../components/StudentAcademicResultsTable';
import { useSemester } from '../../context/SemesterContext';

export const StudentDashboardPage = () => {
  const { selectedSemesterId } = useSemester();
  const navigate = useNavigate();

  const { data: dashboard, isLoading: loadingDash } = useQuery({
    queryKey: ['student-dashboard', selectedSemesterId],
    queryFn: () => studentApi.getDashboard(selectedSemesterId),
  });

  const { data: schedule = [], isLoading: loadingSched } = useQuery({
    queryKey: ['student-schedule', selectedSemesterId],
    queryFn: () => studentApi.getSchedule(selectedSemesterId),
  });

  if (loadingDash) {
    return (
      <div className="py-20 flex justify-center">
        <Spin size="large" />
      </div>
    );
  }

  const progressPercent = dashboard?.programTotalCredits
    ? Math.min(100, Math.round((dashboard.totalCreditsEarned / dashboard.programTotalCredits) * 100))
    : 0;

  return (
    <div className="space-y-5">
      <div className="rounded-xl bg-[#1e40af] text-white p-5 flex flex-wrap items-center justify-between gap-4 shadow-sm">
        <div>
          <div className="flex flex-wrap items-center gap-2">
            <h2 className="m-0 text-lg md:text-xl font-bold text-white">
              Xin chào, {dashboard?.fullName}
            </h2>
            <Tag color={dashboard?.registerOpen ? 'green' : 'default'} className="m-0">
              {dashboard?.registerOpen ? 'Đang mở ĐKTC' : 'Cổng ĐKTC đóng'}
            </Tag>
          </div>
          <p className="m-0 text-xs md:text-sm text-blue-100 mt-1">
            Mã SV: <strong>{dashboard?.studentCode}</strong> • {dashboard?.programName} ({dashboard?.departmentName}) • Khóa {dashboard?.cohort}
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button
            type="primary"
            ghost
            style={{ borderColor: '#fff', color: '#fff' }}
            icon={<TrophyOutlined />}
            onClick={() => navigate('/student/grades')}
          >
            Xem bảng điểm
          </Button>
          <Button
            type="default"
            icon={<AppstoreAddOutlined />}
            onClick={() => navigate('/student/registration')}
            className="font-semibold text-ag-700"
          >
            Đăng ký tín chỉ
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <Card className="border-l-4 border-l-ag-600 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">CPA Tích lũy (Hệ 4)</div>
          <div className="text-2xl font-bold text-slate-800 mt-1">
            {Number(dashboard?.cumulativeGpa ?? 0).toFixed(2)} <span className="text-sm font-normal text-slate-400">/ 4.00</span>
          </div>
          <div className="text-xs text-ag-600 font-semibold mt-1">
            Xếp loại: {dashboard?.academicClassification} (Hệ 10: {Number(dashboard?.cumulativeScore10 ?? 0).toFixed(1)})
          </div>
        </Card>

        <Card className="border-l-4 border-l-sky-500 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">Tín chỉ tích lũy CTĐT</div>
          <div className="text-2xl font-bold text-slate-800 mt-1">
            {dashboard?.totalCreditsEarned ?? 0}{' '}
            <span className="text-sm font-normal text-slate-400">/ {dashboard?.programTotalCredits ?? 0} TC</span>
          </div>
          <Progress percent={progressPercent} size="small" strokeColor="#1a73e8" className="mt-1 mb-0" />
        </Card>

        <Card className="border-l-4 border-l-indigo-500 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">Tín chỉ kỳ đang chọn</div>
          <div className="text-2xl font-bold text-slate-800 mt-1">
            {dashboard?.currentSemesterCredits ?? 0}{' '}
            <span className="text-sm font-normal text-slate-400">/ {dashboard?.currentSemesterMaxCredits ?? 24} TC</span>
          </div>
          <div className="text-xs text-slate-600 mt-1 flex items-center gap-1">
            <BookOutlined className="text-indigo-500" />
            <span>Đã đăng ký {dashboard?.enrolledCoursesCount ?? 0} lớp học phần</span>
          </div>
        </Card>

        <Card className="border-l-4 border-l-emerald-500 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">Học kỳ hiện hành</div>
          <div className="text-base font-bold text-slate-800 mt-1 truncate">
            {dashboard?.activeSemesterName || 'Chưa chọn'}
          </div>
          <div className="text-xs text-emerald-600 font-semibold mt-1 flex items-center gap-1">
            <CalendarOutlined />
            <span>Trạng thái SV: {dashboard?.academicStatus}</span>
          </div>
        </Card>
      </div>

      <AcademicScheduleView
        schedule={schedule}
        isLoading={loadingSched}
        isDashboard={true}
        title="Thời khóa biểu sinh viên"
        semesterName={dashboard?.activeSemesterName || ''}
      />

      <StudentAcademicResultsTable
        showHeader={true}
        showPdfExport={false}
        cardTitle="Kết quả học tập toàn khóa"
      />
    </div>
  );
};
