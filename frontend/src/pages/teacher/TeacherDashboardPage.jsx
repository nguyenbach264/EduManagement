import React, { useState } from 'react';
import { Button, Card, Descriptions, Modal, Space, Spin, Tag, Tooltip } from 'antd';
import {
  BarChartOutlined,
  BookOutlined,
  CheckCircleOutlined,
  EditOutlined,
  LockOutlined,
  TeamOutlined,
} from '@ant-design/icons';
import { useQuery } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { teacherApi } from '../../api/services';
import { AcademicScheduleView } from '../../components/AcademicScheduleView';
import { GradeDistributionChart } from './TeacherGradeEntryPage';
import { useSemester } from '../../context/SemesterContext';

export const TeacherDashboardPage = () => {
  const { selectedSemesterId } = useSemester();
  const navigate = useNavigate();
  const [selectedClassForAnalytics, setSelectedClassForAnalytics] = useState(null);
  const [analyticsModalOpen, setAnalyticsModalOpen] = useState(false);

  const { data: dashboard, isLoading } = useQuery({
    queryKey: ['teacher-dashboard', selectedSemesterId],
    queryFn: () => teacherApi.getDashboard(selectedSemesterId),
  });

  const { data: schedule = [] } = useQuery({
    queryKey: ['teacher-schedule', selectedSemesterId],
    queryFn: () => teacherApi.getSchedule(selectedSemesterId),
  });

  // Fetch grades for the selected class to show analytics chart
  const { data: classGrades = [], isLoading: isLoadingGrades } = useQuery({
    queryKey: ['teacher-class-grades', selectedClassForAnalytics?.id],
    queryFn: () => teacherApi.getClassGrades(selectedClassForAnalytics?.id),
    enabled: Boolean(selectedClassForAnalytics?.id && analyticsModalOpen),
  });

  const handleOpenAnalytics = (cls) => {
    setSelectedClassForAnalytics(cls);
    setAnalyticsModalOpen(true);
  };

  if (isLoading) {
    return (
      <div className="py-20 flex justify-center">
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div className="space-y-5">
      <div className="rounded-xl bg-[#1e40af] text-white p-5 flex flex-wrap items-center justify-between gap-4 shadow-sm">
        <div>
          <h2 className="m-0 text-lg md:text-xl font-bold text-white">
            Xin chào, {dashboard?.fullName}
          </h2>
          <p className="m-0 text-xs md:text-sm text-blue-100 mt-1">
            Mã GV: <strong>{dashboard?.teacherCode}</strong> • {dashboard?.academicRank} • {dashboard?.departmentName}
          </p>
        </div>
        <Button
          type="default"
          icon={<EditOutlined />}
          onClick={() => navigate('/teacher/classes')}
          className="font-semibold text-ag-700"
        >
          Quản lý lớp & Nhập điểm
        </Button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <Card className="border-l-4 border-l-ag-600 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">Lớp phụ trách kỳ này</div>
          <div className="text-2xl font-bold text-slate-800 mt-1">{dashboard?.totalClassesInSemester ?? 0}</div>
          <div className="text-xs text-ag-600 mt-1 flex items-center gap-1">
            <BookOutlined /> {dashboard?.activeSemesterName}
          </div>
        </Card>

        <Card className="border-l-4 border-l-sky-500 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">Tổng sinh viên giảng dạy</div>
          <div className="text-2xl font-bold text-slate-800 mt-1">{dashboard?.totalStudentsInSemester ?? 0}</div>
          <div className="text-xs text-sky-600 mt-1 flex items-center gap-1">
            <TeamOutlined /> Đang theo học trong kỳ
          </div>
        </Card>

        <Card className="border-l-4 border-l-emerald-500 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">Đã khóa sổ điểm</div>
          <div className="text-2xl font-bold text-emerald-700 mt-1">{dashboard?.lockedClassesCount ?? 0}</div>
          <div className="text-xs text-emerald-600 mt-1 flex items-center gap-1">
            <CheckCircleOutlined /> Đã nộp điểm chính thức
          </div>
        </Card>

        <Card className="border-l-4 border-l-amber-500 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">Đang mở nhập điểm</div>
          <div className="text-2xl font-bold text-amber-600 mt-1">{dashboard?.pendingLockClassesCount ?? 0}</div>
          <div className="text-xs text-amber-600 mt-1 flex items-center gap-1">
            <LockOutlined /> Chờ hoàn thiện & khóa sổ
          </div>
        </Card>
      </div>

      {(dashboard?.classes?.length ?? 0) > 0 && (
        <Card title="Lớp học phần phụ trách (Bấm để xem chi tiết & biểu đồ phân tích kết quả)" className="shadow-sm">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {dashboard?.classes.map((cls) => {
              const isFinished = cls.teachingStatus === 'FINISHED' || cls.status === 'CLOSED' || cls.isLocked || (cls.endWeek != null && cls.endWeek < 11);
              return (
                <div
                  key={cls.id}
                  className="p-3.5 rounded-xl border border-slate-200 hover:border-ag-500 transition-colors bg-slate-50/50 flex flex-col justify-between gap-3 cursor-pointer"
                  onClick={() => handleOpenAnalytics(cls)}
                >
                  <div>
                    <div className="flex items-center justify-between gap-2">
                      <div className="flex items-center gap-1.5 flex-wrap">
                        <span className="font-bold text-ag-700 text-sm">{cls.sectionCode}</span>
                        <Tag color={isFinished ? 'default' : 'processing'} className="m-0 font-medium">
                          {isFinished ? 'Đã dạy' : 'Đang dạy'}
                        </Tag>
                      </div>
                      <Tag color="blue">{cls.currentEnrolled}/{cls.maxCapacity} SV</Tag>
                    </div>
                    <div className="font-semibold text-slate-800 mt-1 text-sm hover:text-ag-600 transition">
                      {cls.courseName}
                    </div>
                    <div className="text-xs text-slate-500 mt-0.5">
                      {cls.courseCode} • {cls.credits} tín chỉ
                    </div>
                  </div>

                  <div className="flex items-center gap-2 pt-1">
                    <Button
                      size="small"
                      type="primary"
                      ghost
                      icon={<BarChartOutlined />}
                      onClick={(e) => {
                        e.stopPropagation();
                        handleOpenAnalytics(cls);
                      }}
                      className="flex-1 text-xs"
                    >
                      Xem phân tích kết quả
                    </Button>
                    {isFinished ? (
                      <Tooltip title="Lớp học phần đã dạy xong, không thể nhập điểm nữa">
                        <Button
                          type="default"
                          size="small"
                          icon={<EditOutlined />}
                          disabled
                          className="flex-1 text-xs"
                        >
                          Đã dạy xong
                        </Button>
                      </Tooltip>
                    ) : (
                      <Button
                        type="primary"
                        size="small"
                        icon={<EditOutlined />}
                        onClick={(e) => {
                          e.stopPropagation();
                          navigate(`/teacher/classes/${cls.id}/grades`);
                        }}
                        className="flex-1 text-xs"
                      >
                        Nhập điểm
                      </Button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </Card>
      )}

      {/* Multi-week teaching timetable (identical controls & calendar to student) */}
      <AcademicScheduleView
        schedule={schedule}
        isTeacher={true}
        isDashboard={true}
        title="Lịch giảng dạy giảng viên"
        semesterName={dashboard?.activeSemesterName || ''}
      />

      {/* Class Section Details & Result Analytics Modal */}
      <Modal
        title={
          <div className="flex items-center gap-2 text-slate-800 font-bold">
            <BarChartOutlined className="text-ag-600 text-lg" />
            <span>
              Phân tích kết quả lớp: {selectedClassForAnalytics?.sectionCode} — {selectedClassForAnalytics?.courseName}
            </span>
          </div>
        }
        open={analyticsModalOpen}
        onCancel={() => setAnalyticsModalOpen(false)}
        footer={[
          <Button key="close" onClick={() => setAnalyticsModalOpen(false)}>
            Đóng
          </Button>,
          <Button
            key="grades"
            type="primary"
            icon={<EditOutlined />}
            onClick={() => {
              setAnalyticsModalOpen(false);
              navigate(`/teacher/classes/${selectedClassForAnalytics?.id}/grades`);
            }}
          >
            Vào bảng nhập điểm
          </Button>,
        ]}
        width={880}
        destroyOnClose
      >
        {isLoadingGrades ? (
          <div className="py-16 flex justify-center">
            <Spin size="large" tip="Đang tải dữ liệu phân tích kết quả lớp học phần..." />
          </div>
        ) : (
          <div className="space-y-4 py-2">
            <Descriptions bordered size="small" column={{ xs: 1, sm: 3 }} className="bg-slate-50/50">
              <Descriptions.Item label="Mã lớp học phần">
                <Tag color="blue" className="font-bold">{selectedClassForAnalytics?.sectionCode}</Tag>
              </Descriptions.Item>
              <Descriptions.Item label="Học phần">
                <strong className="text-slate-800">{selectedClassForAnalytics?.courseCode}</strong> ({selectedClassForAnalytics?.credits} TC)
              </Descriptions.Item>
              <Descriptions.Item label="Sĩ số">
                <strong className="text-ag-700">{classGrades.length}</strong> sinh viên
              </Descriptions.Item>
            </Descriptions>

            {/* Results Analytics Chart */}
            <GradeDistributionChart rows={classGrades} />
          </div>
        )}
      </Modal>
    </div>
  );
};
