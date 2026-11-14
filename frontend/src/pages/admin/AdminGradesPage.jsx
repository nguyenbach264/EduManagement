import React, { useState } from 'react';
import {
  Alert,
  Button,
  Card,
  Input,
  Modal,
  Popconfirm,
  Select,
  Space,
  Table,
  Tag,
  Tooltip,
  message,
} from 'antd';
import {
  CheckCircleOutlined,
  CloseCircleOutlined,
  EyeOutlined,
  LockOutlined,
  SearchOutlined,
  UnlockOutlined,
} from '@ant-design/icons';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { adminApi } from '../../api/services';
import { getErrorMessage } from '../../api/client';
import { useSemester } from '../../context/SemesterContext';

export const AdminGradesPage = () => {
  const { selectedSemesterId } = useSemester();
  const queryClient = useQueryClient();

  const [keyword, setKeyword] = useState('');
  const [statusFilter, setStatusFilter] = useState(undefined);

  // Modal Sổ điểm lớp học phần (Chỉ xem)
  const [activeSection, setActiveSection] = useState(null);

  // Query danh sách lớp học phần kèm thống kê điểm
  const { data: sectionSummaries = [], isLoading } = useQuery({
    queryKey: ['admin-section-grades-summary', selectedSemesterId, keyword, statusFilter],
    queryFn: () =>
      adminApi.getSectionGradesSummary({
        semesterId: selectedSemesterId,
        keyword: keyword || undefined,
        statusFilter: statusFilter || undefined,
      }),
  });

  // Query điểm chi tiết khi mở modal lớp học phần (Chỉ xem)
  const {
    data: sectionGradesData = [],
    isLoading: loadingGrades,
    refetch: refetchSectionGrades,
  } = useQuery({
    queryKey: ['admin-section-grades', activeSection?.classSectionId],
    queryFn: () => adminApi.getSectionGrades(activeSection.classSectionId),
    enabled: Boolean(activeSection?.classSectionId),
  });

  // Mutations mở / khóa toàn bộ lớp từ danh sách hoặc modal
  const unlockSectionMutation = useMutation({
    mutationFn: (sectionId) => adminApi.unlockSectionGrades(sectionId),
    onSuccess: () => {
      message.success('Đã mở khóa sổ điểm cho toàn bộ lớp học phần');
      queryClient.invalidateQueries({ queryKey: ['admin-section-grades-summary'] });
      if (activeSection) refetchSectionGrades();
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const lockSectionMutation = useMutation({
    mutationFn: (sectionId) => adminApi.lockSectionGrades(sectionId),
    onSuccess: () => {
      message.success('Đã khóa sổ điểm lớp học phần');
      queryClient.invalidateQueries({ queryKey: ['admin-section-grades-summary'] });
      if (activeSection) refetchSectionGrades();
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  // Cột bảng Lớp học phần ở Admin
  const sectionColumns = [
    {
      title: 'Mã lớp HP',
      dataIndex: 'sectionCode',
      width: 140,
      render: (v, r) => (
        <Button
          type="link"
          className="p-0 font-bold text-ag-700 hover:text-ag-800"
          onClick={() => setActiveSection(r)}
        >
          {v}
        </Button>
      ),
    },
    {
      title: 'Học phần',
      key: 'course',
      render: (_, r) => (
        <div
          className="cursor-pointer group"
          onClick={() => setActiveSection(r)}
        >
          <div className="font-semibold text-slate-800 group-hover:text-ag-700 transition">
            {r.courseName}
          </div>
          <div className="text-xs text-slate-500">
            {r.courseCode} • <span className="font-medium text-slate-600">{r.credits} tín chỉ</span>
            {r.departmentName && ` • ${r.departmentName}`}
          </div>
        </div>
      ),
    },
    {
      title: 'Giảng viên',
      dataIndex: 'teacherName',
      width: 170,
      render: (v) => <span className="text-slate-700 font-medium">{v}</span>,
    },
    {
      title: 'Tiến độ chấm điểm',
      key: 'progress',
      width: 160,
      align: 'center',
      render: (_, r) => {
        const percent = r.totalStudents > 0 ? Math.round((r.gradedCount / r.totalStudents) * 100) : 0;
        return (
          <div>
            <div className="font-semibold text-slate-800">
              {r.gradedCount} / {r.totalStudents} SV
            </div>
            <div className="w-full bg-slate-100 rounded-full h-1.5 mt-1 overflow-hidden">
              <div
                className={`h-full rounded-full ${percent === 100 ? 'bg-emerald-500' : 'bg-ag-600'}`}
                style={{ width: `${percent}%` }}
              />
            </div>
          </div>
        );
      },
    },
    {
      title: 'Trạng thái sổ điểm',
      dataIndex: 'status',
      width: 140,
      align: 'center',
      render: (status) => {
        if (status === 'LOCKED') return <Tag color="error">Đã khóa sổ</Tag>;
        if (status === 'PARTIAL') return <Tag color="warning">Khóa một phần</Tag>;
        return <Tag color="success">Đang mở</Tag>;
      },
    },
    {
      title: 'Thao tác',
      key: 'actions',
      width: 230,
      align: 'center',
      render: (_, r) => (
        <Space size="small">
          <Button
            type="primary"
            ghost
            size="small"
            icon={<EyeOutlined />}
            onClick={() => setActiveSection(r)}
          >
            Xem bảng điểm
          </Button>

          {r.status !== 'OPEN' ? (
            <Popconfirm
              title="Mở khóa sổ điểm lớp này?"
              description="Toàn bộ điểm của sinh viên trong lớp sẽ được mở cho giảng viên hiệu chỉnh."
              onConfirm={() => unlockSectionMutation.mutate(r.classSectionId)}
            >
              <Button size="small" icon={<UnlockOutlined />}>
                Mở khóa
              </Button>
            </Popconfirm>
          ) : (
            <Popconfirm
              title="Khóa sổ điểm lớp này?"
              description="Khóa sổ điểm của cả lớp để chống sửa đổi."
              onConfirm={() => lockSectionMutation.mutate(r.classSectionId)}
            >
              <Button size="small" danger icon={<LockOutlined />}>
                Khóa sổ
              </Button>
            </Popconfirm>
          )}
        </Space>
      ),
    },
  ];

  // Cột bảng điểm chi tiết trong Modal (CHỈ XEM - READ ONLY)
  const modalGradeColumns = [
    {
      title: 'STT',
      key: 'index',
      width: 50,
      align: 'center',
      render: (_, __, idx) => <span className="text-slate-400 font-mono text-xs">{idx + 1}</span>,
    },
    {
      title: 'Mã SV',
      dataIndex: 'studentCode',
      width: 110,
      render: (v) => <span className="font-mono font-medium text-slate-800">{v}</span>,
    },
    {
      title: 'Họ và tên',
      dataIndex: 'studentName',
      width: 180,
      render: (v, r) => (
        <div>
          <div className="font-semibold text-slate-800">{v}</div>
          <div className="text-xs text-slate-400">{r.className}</div>
        </div>
      ),
    },
    {
      title: 'TX1',
      dataIndex: 'regularScore1',
      width: 75,
      align: 'center',
      render: (v, r) => {
        const val = v != null ? v : r.attendanceScore;
        return <span className="font-semibold text-slate-700">{val != null ? Number(val).toFixed(1) : '-'}</span>;
      },
    },
    {
      title: 'TX2',
      dataIndex: 'regularScore2',
      width: 75,
      align: 'center',
      render: (v, r) => {
        const val = v != null ? v : r.attendanceScore;
        return <span className="font-semibold text-slate-700">{val != null ? Number(val).toFixed(1) : '-'}</span>;
      },
    },
    ...(activeSection?.credits >= 4
      ? [
          {
            title: 'Giữa kỳ (30%)',
            dataIndex: 'midtermScore',
            width: 95,
            align: 'center',
            render: (v) => (
              <span className="font-semibold text-amber-700">{v != null ? Number(v).toFixed(1) : '-'}</span>
            ),
          },
        ]
      : []),
    {
      title: activeSection?.credits >= 4 ? 'Cuối kỳ (50%)' : 'Cuối kỳ (60%)',
      dataIndex: 'finalScore',
      width: 95,
      align: 'center',
      render: (v) => (
        <span className="font-bold text-blue-700">{v != null ? Number(v).toFixed(1) : '-'}</span>
      ),
    },
    {
      title: 'Tổng kết (10)',
      dataIndex: 'totalScore10',
      width: 100,
      align: 'center',
      render: (val) => (
        <span className="font-bold text-slate-800 text-sm">
          {val != null ? Number(val).toFixed(1) : '-'}
        </span>
      ),
    },
    {
      title: 'Hệ 4',
      dataIndex: 'gpaScore4',
      width: 75,
      align: 'center',
      render: (val) => (
        <span className="font-medium text-slate-600">
          {val != null ? Number(val).toFixed(2) : '-'}
        </span>
      ),
    },
    {
      title: 'Điểm chữ',
      dataIndex: 'letterGrade',
      width: 85,
      align: 'center',
      render: (val) => {
        if (!val) return '-';
        return <Tag color={val === 'F' ? 'red' : 'blue'} className="font-bold">{val}</Tag>;
      },
    },
    {
      title: 'Kết quả',
      dataIndex: 'passed',
      width: 95,
      align: 'center',
      render: (passed) =>
        passed != null ? (
          passed ? (
            <Tag color="success" icon={<CheckCircleOutlined />}>Đạt</Tag>
          ) : (
            <Tag color="error" icon={<CloseCircleOutlined />}>Học lại</Tag>
          )
        ) : (
          <span className="text-slate-400">-</span>
        ),
    },
    {
      title: 'Khóa',
      dataIndex: 'locked',
      width: 85,
      align: 'center',
      render: (locked) =>
        locked ? (
          <Tag color="red" className="text-xs">Đã khóa</Tag>
        ) : (
          <Tag color="green" className="text-xs">Mở</Tag>
        ),
    },
  ];

  return (
    <div className="space-y-4">
      {/* Thanh điều khiển tìm kiếm & lọc */}
      <Card className="shadow-sm" styles={{ body: { padding: 16 } }}>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h2 className="m-0 text-base font-bold text-slate-800">
              Quản lý Sổ điểm & Khóa điểm theo Lớp học phần
            </h2>
            <div className="text-xs text-slate-500">
              Gom theo Lớp học phần • Bấm vào tên lớp hoặc nút &quot;Xem bảng điểm&quot; để xem chi tiết điểm cả lớp. Quản trị viên chỉ thực hiện Mở khóa / Khóa sổ điểm.
            </div>
          </div>
          <Space wrap>
            <Input
              allowClear
              prefix={<SearchOutlined />}
              placeholder="Tìm mã lớp HP, tên môn, giảng viên..."
              value={keyword}
              onChange={(e) => setKeyword(e.target.value)}
              className="w-72"
            />
            <Select
              allowClear
              placeholder="Trạng thái sổ điểm"
              value={statusFilter}
              onChange={setStatusFilter}
              className="w-44"
              options={[
                { value: 'LOCKED', label: 'Đã khóa sổ' },
                { value: 'OPEN', label: 'Đang mở' },
              ]}
            />
          </Space>
        </div>
      </Card>

      {/* Bảng danh sách Lớp học phần */}
      <Card className="shadow-sm" styles={{ body: { padding: 0 } }}>
        <Table
          rowKey="classSectionId"
          loading={isLoading}
          columns={sectionColumns}
          dataSource={sectionSummaries}
          scroll={{ x: 1000 }}
          pagination={false}
        />
      </Card>

      {/* Modal Sổ điểm của cả lớp (Chỉ xem - Read Only) */}
      <Modal
        title={
          activeSection && (
            <div className="flex flex-wrap items-center justify-between gap-3 pr-6">
              <div>
                <div className="text-base font-bold text-slate-900">
                  Bảng điểm Lớp học phần: <span className="text-ag-700">{activeSection.sectionCode}</span>
                </div>
                <div className="text-xs font-normal text-slate-500 mt-0.5">
                  Môn học: <strong className="text-slate-700">{activeSection.courseName}</strong> ({activeSection.courseCode} • {activeSection.credits} TC) • GV: {activeSection.teacherName} • Sĩ số: {sectionGradesData.length} SV
                </div>
              </div>
            </div>
          )
        }
        open={Boolean(activeSection)}
        onCancel={() => setActiveSection(null)}
        width={1100}
        footer={[
          <Button key="close" onClick={() => setActiveSection(null)}>
            Đóng
          </Button>,
          activeSection && (
            <Space key="lock-actions">
              {activeSection.status !== 'OPEN' ? (
                <Popconfirm
                  key="unlock-btn"
                  title="Mở khóa sổ điểm cho cả lớp?"
                  description="Cho phép giảng viên phụ trách hiệu chỉnh và cập nhật điểm số."
                  onConfirm={() => unlockSectionMutation.mutate(activeSection.classSectionId)}
                >
                  <Button
                    type="primary"
                    ghost
                    icon={<UnlockOutlined />}
                    loading={unlockSectionMutation.isPending}
                  >
                    Mở khóa sổ điểm cả lớp
                  </Button>
                </Popconfirm>
              ) : (
                <Popconfirm
                  key="lock-btn"
                  title="Khóa sổ điểm lớp này?"
                  description="Khóa toàn bộ điểm của sinh viên trong lớp để hoàn tất kỳ học."
                  onConfirm={() => lockSectionMutation.mutate(activeSection.classSectionId)}
                >
                  <Button
                    danger
                    type="primary"
                    icon={<LockOutlined />}
                    loading={lockSectionMutation.isPending}
                  >
                    Khóa sổ điểm cả lớp
                  </Button>
                </Popconfirm>
              )}
            </Space>
          ),
        ]}
      >
        <div className="py-2 space-y-3">
          <Alert
            type="info"
            showIcon
            message="Chế độ Chỉ xem (Read-only)"
            description="Bảng điểm lớp học phần ở chế độ chỉ xem. Việc nhập và sửa điểm do Giảng viên phụ trách thực hiện qua Cổng Giảng viên. Phòng Đào tạo thực hiện nghiệp vụ Mở khóa hoặc Khóa sổ điểm theo quy chế."
            className="text-xs"
          />

          <Table
            rowKey="enrollmentId"
            loading={loadingGrades}
            columns={modalGradeColumns}
            dataSource={sectionGradesData}
            pagination={false}
            scroll={{ y: 460 }}
            size="small"
          />
        </div>
      </Modal>
    </div>
  );
};
