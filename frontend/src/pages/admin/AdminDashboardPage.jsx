import React, { useState } from 'react';
import { Card, Input, Progress, Select, Space, Spin, Table, Tag } from 'antd';
import {
  ApartmentOutlined,
  BookOutlined,
  LockOutlined,
  SearchOutlined,
  TeamOutlined,
  UserOutlined,
} from '@ant-design/icons';
import { useQuery } from '@tanstack/react-query';
import { adminApi } from '../../api/services';

export const AdminDashboardPage = () => {
  const [teaKeyword, setTeaKeyword] = useState('');
  const [teaDept, setTeaDept] = useState(undefined);
  const [teaStatus, setTeaStatus] = useState(undefined);
  const [teaPage, setTeaPage] = useState(0);

  const { data, isLoading } = useQuery({
    queryKey: ['admin-dashboard'],
    queryFn: adminApi.getDashboard,
  });

  const { data: departments = [] } = useQuery({
    queryKey: ['admin-departments'],
    queryFn: adminApi.getDepartments,
  });

  const { data: teachersData, isLoading: loadingTea } = useQuery({
    queryKey: ['admin-dashboard-teachers', teaKeyword, teaDept, teaStatus, teaPage],
    queryFn: () =>
      adminApi.getTeachers({
        page: teaPage,
        size: 10,
        keyword: teaKeyword || undefined,
        departmentId: teaDept,
        active: teaStatus,
      }),
  });

  if (isLoading) {
    return (
      <div className="py-20 flex justify-center">
        <Spin size="large" />
      </div>
    );
  }

  const maxDeptCount = Math.max(1, ...(data?.departmentStats?.map((d) => d.studentCount) ?? [1]));
  const totalGraded = Object.values(data?.gradeDistribution ?? {}).reduce((a, b) => a + b, 0) || 1;
  const orderedGrades = ['A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];

  const teacherColumns = [
    {
      title: 'Mã GV',
      dataIndex: 'teacherCode',
      width: 100,
      render: (v) => <strong className="text-ag-700">{v}</strong>,
    },
    {
      title: 'Họ và tên',
      dataIndex: 'fullName',
      width: 190,
      render: (v) => <span className="font-semibold text-slate-800">{v}</span>,
    },
    {
      title: 'Học hàm / Học vị',
      dataIndex: 'academicRank',
      width: 140,
    },
    {
      title: 'Chức danh',
      dataIndex: 'academicTitle',
      width: 130,
      render: (v) => v || 'Giảng viên',
    },
    {
      title: 'Khoa quản lý',
      dataIndex: 'departmentName',
    },
    {
      title: 'Email & SĐT',
      key: 'contact',
      width: 220,
      render: (_, r) => (
        <div className="text-xs">
          <div className="text-slate-700 font-mono">{r.email}</div>
          {r.phone && <div className="text-slate-500 mt-0.5">{r.phone}</div>}
        </div>
      ),
    },
    {
      title: 'Trạng thái làm việc',
      dataIndex: 'active',
      width: 150,
      align: 'center',
      render: (a) => (
        <Tag color={a ? 'green' : 'red'}>
          {a ? 'Đang công tác' : 'Tạm nghỉ / Đã nghỉ'}
        </Tag>
      ),
    },
  ];

  return (
    <div className="space-y-5">
      {/* Banner đầu trang */}
      <div className="rounded-xl bg-[#1e40af] text-white p-5 flex flex-wrap items-center justify-between gap-4 shadow-sm">
        <div>
          <h2 className="m-0 text-lg md:text-xl font-bold text-white">
            Trung tâm Điều hành Phòng Đào tạo
          </h2>
          <p className="m-0 text-xs md:text-sm text-blue-100 mt-1">
            Hệ thống đào tạo tập trung • Học kỳ hiện hành: <strong>{data?.activeSemesterName}</strong>
          </p>
        </div>
        <Tag color="cyan" className="m-0 font-semibold">
          {data?.openSectionsInActiveSemester ?? 0} lớp mở • {data?.totalEnrollmentsInActiveSemester ?? 0} lượt ĐKTC
        </Tag>
      </div>

      {/* 4 Cards Thống kê Tổng quan */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <Card className="border-l-4 border-l-ag-600 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">Tổng Sinh viên</div>
          <div className="text-2xl font-bold text-slate-800 mt-1">{data?.totalStudents ?? 0}</div>
          <div className="text-xs text-ag-600 mt-1 flex items-center gap-1">
            <TeamOutlined /> Quản lý hồ sơ toàn trường
          </div>
        </Card>

        <Card className="border-l-4 border-l-sky-500 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">Giảng viên & Khoa</div>
          <div className="text-2xl font-bold text-slate-800 mt-1">
            {data?.totalTeachers ?? 0} <span className="text-sm font-normal text-slate-400">GV</span> / {data?.totalDepartments ?? 0}{' '}
            <span className="text-sm font-normal text-slate-400">Khoa</span>
          </div>
          <div className="text-xs text-sky-600 mt-1 flex items-center gap-1">
            <UserOutlined /> {data?.totalPrograms ?? 0} Chương trình đào tạo
          </div>
        </Card>

        <Card className="border-l-4 border-l-indigo-500 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">Học phần & Lớp mở kỳ này</div>
          <div className="text-2xl font-bold text-slate-800 mt-1">
            {data?.totalCourses ?? 0} <span className="text-sm font-normal text-slate-400">Môn</span> / {data?.openSectionsInActiveSemester ?? 0}{' '}
            <span className="text-sm font-normal text-slate-400">Lớp</span>
          </div>
          <div className="text-xs text-indigo-600 mt-1 flex items-center gap-1">
            <BookOutlined /> {data?.totalEnrollmentsInActiveSemester ?? 0} lượt đăng ký
          </div>
        </Card>

        <Card className="border-l-4 border-l-amber-500 shadow-sm" styles={{ body: { padding: 16 } }}>
          <div className="text-xs text-slate-500 font-medium">Trạng thái Sổ điểm</div>
          <div className="text-2xl font-bold text-slate-800 mt-1">
            {data?.lockedGradesCount ?? 0} <span className="text-sm font-normal text-slate-400">Đã khóa</span>
          </div>
          <div className="text-xs text-amber-600 mt-1 flex items-center gap-1">
            <LockOutlined /> {data?.unlockedGradesCount ?? 0} bản ghi đang mở nhập điểm
          </div>
        </Card>
      </div>

      {/* 2 Biểu đồ Thống kê */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <Card
          className="shadow-sm"
          title={
            <span className="flex items-center gap-2">
              <ApartmentOutlined className="text-ag-600" /> Phân bố Sinh viên theo Khoa (Top 10)
            </span>
          }
        >
          <div className="space-y-3">
            {data?.departmentStats?.map((d) => (
              <div key={d.departmentName} className="space-y-1">
                <div className="flex justify-between text-xs">
                  <span className="font-medium text-slate-700 truncate pr-2">{d.departmentName}</span>
                  <strong className="text-ag-700 shrink-0">{d.studentCount} SV</strong>
                </div>
                <Progress
                  percent={Math.round((d.studentCount / maxDeptCount) * 100)}
                  showInfo={false}
                  size="small"
                  strokeColor="#1a73e8"
                />
              </div>
            ))}
          </div>
        </Card>

        <Card className="shadow-sm" title="Phổ điểm toàn trường (Theo điểm chữ)">
          <div className="space-y-3">
            {orderedGrades.map((letter) => {
              const count = data?.gradeDistribution?.[letter] ?? 0;
              const pct = Math.round((count / totalGraded) * 100);
              return (
                <div key={letter} className="space-y-1">
                  <div className="flex justify-between text-xs">
                    <span className="font-semibold text-slate-700">
                      Điểm <Tag color={letter === 'F' ? 'red' : 'blue'}>{letter}</Tag>
                    </span>
                    <span className="text-slate-600">
                      <strong>{count}</strong> lượt ({pct}%)
                    </span>
                  </div>
                  <Progress
                    percent={pct}
                    showInfo={false}
                    size="small"
                    strokeColor={letter === 'F' ? '#ef4444' : '#0ea5e9'}
                  />
                </div>
              );
            })}
          </div>
        </Card>
      </div>

      {/* Tra cứu & Lọc Giảng viên theo Khoa & Trạng thái làm việc */}
      <Card
        className="shadow-sm"
        title={
          <div className="flex flex-wrap items-center justify-between gap-3">
            <span className="flex items-center gap-2 font-bold text-slate-800">
              <TeamOutlined className="text-ag-600" /> Danh mục Giảng viên toàn trường ({teachersData?.totalElements ?? 0} GV)
            </span>
            <Space wrap>
              <Input
                allowClear
                prefix={<SearchOutlined />}
                placeholder="Tìm mã GV, họ tên, email..."
                value={teaKeyword}
                onChange={(e) => {
                  setTeaKeyword(e.target.value);
                  setTeaPage(0);
                }}
                className="w-56"
              />
              <Select
                allowClear
                placeholder="Lọc theo khoa"
                value={teaDept}
                onChange={(v) => {
                  setTeaDept(v);
                  setTeaPage(0);
                }}
                className="w-52"
                options={departments.map((d) => ({ value: d.id, label: d.name }))}
              />
              <Select
                allowClear
                placeholder="Trạng thái làm việc"
                value={teaStatus}
                onChange={(v) => {
                  setTeaStatus(v);
                  setTeaPage(0);
                }}
                className="w-52"
                options={[
                  { value: true, label: 'Đang công tác (Hoạt động)' },
                  { value: false, label: 'Tạm nghỉ / Đã nghỉ việc' },
                ]}
              />
            </Space>
          </div>
        }
      >
        <Table
          rowKey="id"
          loading={loadingTea}
          columns={teacherColumns}
          dataSource={teachersData?.content ?? []}
          pagination={{
            current: teaPage + 1,
            pageSize: 10,
            total: teachersData?.totalElements ?? 0,
            showTotal: (total) => `Tổng cộng ${total} giảng viên`,
            onChange: (p) => setTeaPage(p - 1),
          }}
          scroll={{ x: 950 }}
          size="middle"
        />
      </Card>
    </div>
  );
};
