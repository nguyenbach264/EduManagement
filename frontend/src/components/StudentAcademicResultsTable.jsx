import React, { useMemo, useState } from 'react';
import { Button, Card, Modal, Spin, Table, Tag, Tooltip, message } from 'antd';
import {
  CheckCircleOutlined,
  DownloadOutlined,
  InfoCircleOutlined,
  TeamOutlined,
  TrophyOutlined,
  UserOutlined,
} from '@ant-design/icons';
import { useQuery } from '@tanstack/react-query';
import { studentApi } from '../api/services';
import { getErrorMessage } from '../api/client';
import { useAuth } from '../context/AuthContext';

export const StudentAcademicResultsTable = ({
  showHeader = true,
  showPdfExport = true,
  cardTitle = 'Kết quả học tập toàn khóa',
}) => {
  const { user } = useAuth();
  const [downloading, setDownloading] = useState(false);
  const [selectedSectionId, setSelectedSectionId] = useState(null);
  const [classModalOpen, setClassModalOpen] = useState(false);

  const { data: summary, isLoading } = useQuery({
    queryKey: ['student-academic-results'],
    queryFn: studentApi.getAcademicResults,
  });

  const { data: classSectionReport, isLoading: isLoadingClassReport } = useQuery({
    queryKey: ['class-section-grades', selectedSectionId],
    queryFn: () => studentApi.getClassSectionGrades(selectedSectionId),
    enabled: Boolean(selectedSectionId && classModalOpen),
  });

  const allGrades = useMemo(() => summary?.courseGrades ?? [], [summary]);

  const handleOpenClassGrades = (item) => {
    const identifier = typeof item === 'object' ? (item?.classSectionId || item?.sectionCode) : item;
    if (!identifier) {
      message.info('Không tìm thấy thông tin lớp học phần');
      return;
    }
    setSelectedSectionId(identifier);
    setClassModalOpen(true);
  };

  const handleExportPdf = async () => {
    setDownloading(true);
    try {
      const blob = await studentApi.exportTranscriptPdf();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `bang-diem-${user?.studentCode || 'sinhvien'}.pdf`;
      a.click();
      window.URL.revokeObjectURL(url);
      message.success('Đã tải xuống phiếu điểm PDF');
    } catch (err) {
      message.error(getErrorMessage(err));
    } finally {
      setDownloading(false);
    }
  };

  // 12 streamlined columns:
  // - Bỏ mã học phần & học kỳ
  // - Tách riêng Tên môn học phần & Lớp học phần
  // - Bỏ nút xem/thao tác (bấm tên môn để xem điểm cả lớp)
  // - Môn <= 3 TC không có giữa kỳ (hiển thị '-')
  // - Luôn làm tròn 1 chữ số thập phân
  const columns = [
    {
      title: 'STT',
      key: 'stt',
      width: 55,
      align: 'center',
      render: (_, __, idx) => <span className="text-slate-500 font-medium">{idx + 1}</span>,
    },
    {
      title: 'Tên môn học phần',
      dataIndex: 'courseName',
      key: 'courseName',
      render: (v, r) => (
        <Tooltip title="Bấm vào tên môn để xem kết quả học tập của cả lớp học phần" placement="topLeft">
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              handleOpenClassGrades(r);
            }}
            className="text-left font-semibold text-ag-700 hover:text-ag-800 hover:underline bg-transparent border-0 cursor-pointer p-0 text-sm leading-snug flex items-center gap-1.5 group"
          >
            <span>{v}</span>
            <TeamOutlined className="text-ag-500 text-xs opacity-60 group-hover:opacity-100 transition-opacity" />
          </button>
        </Tooltip>
      ),
    },
    {
      title: 'Lớp học phần',
      dataIndex: 'sectionCode',
      key: 'sectionCode',
      width: 150,
      render: (v) => <span className="font-mono text-xs text-slate-700 font-medium">{v}</span>,
    },
    {
      title: 'Số TC',
      dataIndex: 'credits',
      key: 'credits',
      width: 70,
      align: 'center',
      render: (v) => <span className="font-semibold text-slate-800">{v}</span>,
    },
    {
      title: 'TX 1',
      key: 'regularScore1',
      width: 75,
      align: 'center',
      render: (_, r) => {
        const v = r.regularScore1 ?? r.attendanceScore;
        return v != null ? Number(v).toFixed(1) : '-';
      },
    },
    {
      title: 'TX 2',
      key: 'regularScore2',
      width: 75,
      align: 'center',
      render: (_, r) => {
        const v = r.regularScore2 ?? r.attendanceScore;
        return v != null ? Number(v).toFixed(1) : '-';
      },
    },
    {
      title: 'Giữa kỳ',
      key: 'midtermScore',
      width: 80,
      align: 'center',
      render: (_, r) => {
        const cr = r.credits ?? 3;
        if (cr <= 3) {
          return <span className="text-slate-400 italic text-xs" title="Môn ≤ 3 tín chỉ không có điểm giữa kỳ">-</span>;
        }
        return r.midtermScore != null ? Number(r.midtermScore).toFixed(1) : '-';
      },
    },
    {
      title: 'Cuối kỳ',
      dataIndex: 'finalScore',
      key: 'finalScore',
      width: 80,
      align: 'center',
      render: (v) => (v != null ? Number(v).toFixed(1) : '-'),
    },
    {
      title: 'Tổng kết (10)',
      dataIndex: 'totalScore10',
      key: 'totalScore10',
      width: 105,
      align: 'center',
      render: (v) => (
        <span className="font-bold text-slate-900 text-sm">
          {v != null ? Number(v).toFixed(1) : '-'}
        </span>
      ),
    },
    {
      title: 'Điểm chữ',
      dataIndex: 'letterGrade',
      key: 'letterGrade',
      width: 85,
      align: 'center',
      render: (v, r) => (v ? <Tag color={r.passed ? 'blue' : 'red'}>{v}</Tag> : '-'),
    },
    {
      title: 'Hệ 4',
      dataIndex: 'gpaScore4',
      key: 'gpaScore4',
      width: 75,
      align: 'center',
      render: (v) => (v != null ? Number(v).toFixed(1) : '-'),
    },
    {
      title: 'Đánh giá',
      key: 'passed',
      width: 95,
      align: 'center',
      render: (_, r) =>
        r.totalScore10 == null ? (
          <Tag>Chưa có</Tag>
        ) : r.passed ? (
          <Tag color="success">Đạt</Tag>
        ) : (
          <Tag color="error">Học lại</Tag>
        ),
    },
  ];

  // Class grade modal columns
  const classGradeColumns = [
    {
      title: 'STT',
      key: 'stt',
      width: 55,
      align: 'center',
      render: (_, __, idx) => idx + 1,
    },
    {
      title: 'Mã SV',
      dataIndex: 'studentCode',
      key: 'studentCode',
      width: 110,
      render: (v) => (
        <span className={`font-mono text-xs ${v === user?.studentCode ? 'font-bold text-ag-700' : 'text-slate-700'}`}>
          {v}
        </span>
      ),
    },
    {
      title: 'Họ và tên',
      dataIndex: 'studentName',
      key: 'studentName',
      render: (v, r) => (
        <span className={r.studentCode === user?.studentCode ? 'font-bold text-ag-700' : 'text-slate-900 font-medium'}>
          {v} {r.studentCode === user?.studentCode && <Tag color="blue" className="ml-1 text-[10px]">Bạn</Tag>}
        </span>
      ),
    },
    {
      title: 'Lớp SH',
      dataIndex: 'className',
      key: 'className',
      width: 120,
      render: (v) => <span className="text-xs text-slate-600">{v}</span>,
    },
    {
      title: 'TX 1',
      key: 'regularScore1',
      width: 70,
      align: 'center',
      render: (_, r) => {
        const v = r.regularScore1 ?? r.attendanceScore;
        return v != null ? Number(v).toFixed(1) : '-';
      },
    },
    {
      title: 'TX 2',
      key: 'regularScore2',
      width: 70,
      align: 'center',
      render: (_, r) => {
        const v = r.regularScore2 ?? r.attendanceScore;
        return v != null ? Number(v).toFixed(1) : '-';
      },
    },
    {
      title: 'Giữa kỳ',
      key: 'midtermScore',
      width: 75,
      align: 'center',
      render: (_, r) => {
        const cr = classSectionReport?.credits ?? 3;
        if (cr <= 3) return <span className="text-slate-400 italic text-xs">-</span>;
        return r.midtermScore != null ? Number(r.midtermScore).toFixed(1) : '-';
      },
    },
    {
      title: 'Cuối kỳ',
      dataIndex: 'finalScore',
      key: 'finalScore',
      width: 75,
      align: 'center',
      render: (v) => (v != null ? Number(v).toFixed(1) : '-'),
    },
    {
      title: 'Tổng (10)',
      dataIndex: 'totalScore10',
      key: 'totalScore10',
      width: 90,
      align: 'center',
      render: (v) => <strong className="text-slate-900">{v != null ? Number(v).toFixed(1) : '-'}</strong>,
    },
    {
      title: 'Điểm chữ',
      dataIndex: 'letterGrade',
      key: 'letterGrade',
      width: 80,
      align: 'center',
      render: (v, r) => (v ? <Tag color={r.passed ? 'blue' : 'red'}>{v}</Tag> : '-'),
    },
    {
      title: 'Hệ 4',
      dataIndex: 'gpaScore4',
      key: 'gpaScore4',
      width: 70,
      align: 'center',
      render: (v) => (v != null ? Number(v).toFixed(1) : '-'),
    },
    {
      title: 'Đánh giá',
      key: 'passed',
      width: 85,
      align: 'center',
      render: (_, r) => (r.passed ? <Tag color="success">Đạt</Tag> : <Tag color="error">Học lại</Tag>),
    },
  ];

  if (isLoading) {
    return (
      <div className="py-16 flex justify-center">
        <Spin size="large" />
      </div>
    );
  }

  const passedCoursesCount = allGrades.filter((g) => g.passed).length;

  return (
    <div className="space-y-4">
      {showHeader && (
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <TrophyOutlined className="text-ag-600 text-lg" />
            <h2 className="m-0 text-base md:text-lg font-bold text-slate-800">
              {cardTitle}
            </h2>
          </div>

          {showPdfExport && (
            <Button
              type="primary"
              ghost
              icon={<DownloadOutlined />}
              loading={downloading}
              onClick={handleExportPdf}
              className="text-xs font-semibold"
            >
              Xuất Phiếu điểm PDF
            </Button>
          )}
        </div>
      )}

      {/* Main Single Comprehensive Table: All courses */}
      <Card className="shadow-xs border border-slate-200 bg-white" styles={{ body: { padding: 0 } }}>
        <Table
          rowKey="gradeId"
          columns={columns}
          dataSource={allGrades}
          scroll={{ x: 950 }}
          pagination={false}
          onRow={(record) => ({
            onClick: () => handleOpenClassGrades(record),
            className: 'cursor-pointer hover:bg-blue-50/40 transition-colors',
          })}
        />

        {/* Tổng kết GPA & Tổng tín chỉ bên dưới bảng */}
        <div className="border-t border-slate-200 bg-slate-50/70 p-4 rounded-b-lg">
          <div className="flex items-center gap-2 mb-3">
            <CheckCircleOutlined className="text-emerald-600 font-bold" />
            <span className="font-bold text-slate-800 text-sm uppercase tracking-wide">
              Tổng kết kết quả học tập & CPA toàn khóa
            </span>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-4 gap-3">
            <div className="p-3 bg-white rounded-lg border border-slate-200 shadow-2xs">
              <div className="text-xs text-slate-500 font-medium">Tín chỉ tích lũy (CPA)</div>
              <div className="text-xl font-bold text-ag-700 mt-1">
                {summary?.totalCreditsEarned ?? 0}{' '}
                <span className="text-xs font-normal text-slate-400">/ 140 TC</span>
              </div>
              <div className="text-[11px] text-slate-500 mt-0.5">
                Đã học: <strong>{summary?.totalCreditsAttempted ?? 0} TC</strong> • Đạt {passedCoursesCount}/{allGrades.length} môn
              </div>
            </div>

            <div className="p-3 bg-white rounded-lg border border-slate-200 shadow-2xs">
              <div className="text-xs text-slate-500 font-medium">CPA Tích lũy (Hệ 4)</div>
              <div className="text-xl font-bold text-slate-800 mt-1">
                {Number(summary?.cumulativeGpa ?? 0).toFixed(2)}{' '}
                <span className="text-xs font-normal text-slate-400">/ 4.00</span>
              </div>
              <div className="text-[11px] text-slate-500 mt-0.5">
                Quy đổi theo quy chế đào tạo tín chỉ
              </div>
            </div>

            <div className="p-3 bg-white rounded-lg border border-slate-200 shadow-2xs">
              <div className="text-xs text-slate-500 font-medium">Điểm TB tích lũy (Hệ 10)</div>
              <div className="text-xl font-bold text-slate-800 mt-1">
                {Number(summary?.cumulativeScore10 ?? 0).toFixed(1)}{' '}
                <span className="text-xs font-normal text-slate-400">/ 10.0</span>
              </div>
              <div className="text-[11px] text-slate-500 mt-0.5">
                Làm tròn đến 1 chữ số thập phân
              </div>
            </div>

            <div className="p-3 bg-white rounded-lg border border-slate-200 shadow-2xs">
              <div className="text-xs text-slate-500 font-medium">Xếp loại học lực</div>
              <div className="text-xl font-bold text-emerald-700 mt-1">
                {summary?.academicClassification || 'Chưa xếp loại'}
              </div>
              <div className="text-[11px] text-emerald-600 mt-0.5 font-medium">
                Dựa trên CPA tích lũy hiện hành
              </div>
            </div>
          </div>
        </div>
      </Card>

      {/* Modal: Bảng điểm cả lớp học phần khi bấm vào tên môn */}
      <Modal
        title={
          <div className="flex items-center gap-2 text-slate-800">
            <TeamOutlined className="text-ag-600 text-lg" />
            <span className="font-bold">
              Bảng điểm lớp học phần: {classSectionReport ? `${classSectionReport.sectionCode} — ${classSectionReport.courseName}` : 'Đang tải...'}
            </span>
          </div>
        }
        open={classModalOpen}
        onCancel={() => setClassModalOpen(false)}
        footer={[
          <Button key="close" type="primary" onClick={() => setClassModalOpen(false)}>
            Đóng bảng điểm lớp
          </Button>,
        ]}
        width={960}
      >
        {isLoadingClassReport || !classSectionReport ? (
          <div className="py-16 flex justify-center">
            <Spin size="large" />
          </div>
        ) : (
          <div className="space-y-4 py-2">
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
              <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-200">
                <div className="text-[11px] text-slate-500 font-semibold uppercase">Môn học / Tín chỉ</div>
                <div className="font-bold text-slate-800 text-sm mt-0.5">
                  {classSectionReport.courseName} ({classSectionReport.credits} TC)
                </div>
              </div>
              <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-200">
                <div className="text-[11px] text-slate-500 font-semibold uppercase">Giảng viên</div>
                <div className="font-bold text-slate-800 text-sm mt-0.5 truncate">
                  {classSectionReport.teacherName}
                </div>
              </div>
              <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-200">
                <div className="text-[11px] text-slate-500 font-semibold uppercase">Sĩ số lớp</div>
                <div className="font-bold text-ag-700 text-sm mt-0.5">
                  {classSectionReport.totalStudents} sinh viên
                </div>
              </div>
              <div className="bg-slate-50 p-2.5 rounded-lg border border-slate-200">
                <div className="text-[11px] text-slate-500 font-semibold uppercase">Điểm TB Lớp (10)</div>
                <div className="font-bold text-emerald-700 text-sm mt-0.5">
                  {classSectionReport.averageScore10 != null ? Number(classSectionReport.averageScore10).toFixed(1) : '-'} / 10.0
                </div>
              </div>
            </div>

            <Table
              rowKey="studentCode"
              size="small"
              columns={classGradeColumns}
              dataSource={classSectionReport.students ?? []}
              scroll={{ x: 850 }}
              pagination={false}
              rowClassName={(r) => (r.studentCode === user?.studentCode ? 'bg-blue-50/70 font-semibold' : '')}
            />
          </div>
        )}
      </Modal>
    </div>
  );
};
