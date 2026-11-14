import React, { useState } from 'react';
import { Button, Card, Descriptions, Modal, Space, Spin, Table, Tag, Tooltip, message } from 'antd';
import { BarChartOutlined, DownloadOutlined, EditOutlined } from '@ant-design/icons';
import { useQuery } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { teacherApi } from '../../api/services';
import { getErrorMessage } from '../../api/client';
import { GradeDistributionChart } from './TeacherGradeEntryPage';
import { useSemester } from '../../context/SemesterContext';

export const TeacherClassesPage = () => {
  const { selectedSemesterId, selectedSemester } = useSemester();
  const navigate = useNavigate();
  const [selectedClassForAnalytics, setSelectedClassForAnalytics] = useState(null);
  const [analyticsModalOpen, setAnalyticsModalOpen] = useState(false);

  const { data: classes = [], isLoading } = useQuery({
    queryKey: ['teacher-classes', selectedSemesterId],
    queryFn: () => teacherApi.getClasses(selectedSemesterId),
  });

  const { data: classGrades = [], isLoading: isLoadingGrades } = useQuery({
    queryKey: ['teacher-class-grades', selectedClassForAnalytics?.id],
    queryFn: () => teacherApi.getClassGrades(selectedClassForAnalytics?.id),
    enabled: Boolean(selectedClassForAnalytics?.id && analyticsModalOpen),
  });

  const handleOpenAnalytics = (cls) => {
    setSelectedClassForAnalytics(cls);
    setAnalyticsModalOpen(true);
  };

  const handleExport = async (cls) => {
    try {
      const blob = await teacherApi.exportGradesExcel(cls.id);
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `bang-diem-${cls.sectionCode}.xlsx`;
      a.click();
      window.URL.revokeObjectURL(url);
      message.success('Đã xuất file Excel bảng điểm');
    } catch (err) {
      message.error(getErrorMessage(err));
    }
  };

  const columns = [
    {
      title: 'Mã lớp HP',
      dataIndex: 'sectionCode',
      key: 'sectionCode',
      width: 140,
      render: (v, r) => (
        <button
          type="button"
          onClick={() => handleOpenAnalytics(r)}
          className="font-bold text-ag-700 hover:text-ag-800 bg-transparent border-0 cursor-pointer p-0 underline text-left"
          title="Bấm để xem phân tích kết quả"
        >
          {v}
        </button>
      ),
    },
    {
      title: 'Môn học (Bấm xem phân tích)',
      key: 'course',
      render: (_, r) => (
        <div>
          <button
            type="button"
            onClick={() => handleOpenAnalytics(r)}
            className="font-semibold text-slate-800 hover:text-ag-600 bg-transparent border-0 cursor-pointer p-0 text-sm text-left leading-snug"
          >
            {r.courseName}
          </button>
          <div className="text-xs text-slate-500 mt-0.5">
            {r.courseCode} • {r.credits} TC
          </div>
        </div>
      ),
    },
    {
      title: 'Lịch giảng dạy',
      key: 'schedules',
      render: (_, r) => (
        <div className="space-y-1">
          {r.schedules.map((s, i) => (
            <div key={i} className="text-xs">
              <Tag color="blue">
                {s.dayOfWeek === 8 ? 'CN' : `T${s.dayOfWeek}`} ({s.startPeriod}-{s.endPeriod})
              </Tag>
              <span>{s.room}</span>
            </div>
          ))}
        </div>
      ),
    },
    {
      title: 'Sĩ số',
      key: 'enrolled',
      width: 100,
      align: 'center',
      render: (_, r) => <Tag color="geekblue">{r.currentEnrolled}/{r.maxCapacity}</Tag>,
    },
    {
      title: 'Trạng thái',
      key: 'teachingStatus',
      width: 110,
      align: 'center',
      render: (_, r) => {
        const isFinished = r.teachingStatus === 'FINISHED' || r.status === 'CLOSED' || r.isLocked || (r.endWeek != null && r.endWeek < 11);
        return (
          <Tag color={isFinished ? 'default' : 'processing'} className="m-0 font-medium">
            {isFinished ? 'Đã dạy' : 'Đang dạy'}
          </Tag>
        );
      },
    },
    {
      title: 'Thao tác',
      key: 'actions',
      width: 270,
      render: (_, r) => {
        const isFinished = r.teachingStatus === 'FINISHED' || r.status === 'CLOSED' || r.isLocked || (r.endWeek != null && r.endWeek < 11);
        return (
          <Space wrap>
            <Button
              size="small"
              icon={<BarChartOutlined />}
              onClick={() => handleOpenAnalytics(r)}
              className="text-xs"
            >
              Phân tích
            </Button>
            {isFinished ? (
              <Tooltip title="Lớp học phần đã dạy xong, không thể nhập điểm nữa">
                <Button
                  type="default"
                  size="small"
                  icon={<EditOutlined />}
                  disabled
                  className="text-xs"
                >
                  Nhập điểm
                </Button>
              </Tooltip>
            ) : (
              <Button
                type="primary"
                size="small"
                icon={<EditOutlined />}
                onClick={() => navigate(`/teacher/classes/${r.id}/grades`)}
                className="text-xs"
              >
                Nhập điểm
              </Button>
            )}
            <Button size="small" icon={<DownloadOutlined />} onClick={() => handleExport(r)}>
              Excel
            </Button>
          </Space>
        );
      },
    },
  ];

  return (
    <Card
      className="shadow-sm"
      title={`Danh sách lớp giảng dạy — ${selectedSemester?.name || ''}`}
      styles={{ body: { padding: 0 } }}
    >
      <Table
        rowKey="id"
        loading={isLoading}
        columns={columns}
        dataSource={classes}
        scroll={{ x: 880 }}
        pagination={false}
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
    </Card>
  );
};
