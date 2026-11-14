import React, { useMemo, useState } from 'react';
import { Alert, Button, Card, Descriptions, Input, Modal, Popconfirm, Select, Space, Table, Tag, Tooltip, message } from 'antd';
import {
  AppstoreOutlined,
  BookOutlined,
  CalendarOutlined,
  CheckCircleOutlined,
  ClockCircleOutlined,
  CloseCircleOutlined,
  InfoCircleOutlined,
  PlusOutlined,
  SearchOutlined,
  SwapOutlined,
  UserOutlined,
  WarningOutlined,
} from '@ant-design/icons';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { studentApi } from '../../api/services';
import { getErrorMessage } from '../../api/client';
import { TimetableGrid } from '../../components/TimetableGrid';
import { useSemester } from '../../context/SemesterContext';
import { useLazyList } from '../../hooks/useLazyList';

export const StudentRegistrationPage = () => {
  const { selectedSemesterId, selectedSemester } = useSemester();
  const queryClient = useQueryClient();
  const [keyword, setKeyword] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [selectedCourseId, setSelectedCourseId] = useState(null);
  const [sectionModalOpen, setSectionModalOpen] = useState(false);

  const { data: dashboard } = useQuery({
    queryKey: ['student-dashboard', selectedSemesterId],
    queryFn: () => studentApi.getDashboard(selectedSemesterId),
  });

  const { data: classes = [], isLoading } = useQuery({
    queryKey: ['student-available-classes', selectedSemesterId],
    queryFn: () => studentApi.getAvailableClasses(selectedSemesterId),
  });

  const { data: schedule = [] } = useQuery({
    queryKey: ['student-schedule', selectedSemesterId],
    queryFn: () => studentApi.getSchedule(selectedSemesterId),
  });

  const invalidateAll = () => {
    queryClient.invalidateQueries({ queryKey: ['student-available-classes'] });
    queryClient.invalidateQueries({ queryKey: ['student-schedule'] });
    queryClient.invalidateQueries({ queryKey: ['student-dashboard'] });
  };

  const enrollMutation = useMutation({
    mutationFn: (classSectionId) => studentApi.enroll(classSectionId),
    onSuccess: () => {
      message.success('Đăng ký lớp học phần thành công!');
      invalidateAll();
    },
    onError: (err) => message.error(getErrorMessage(err)),
  });

  const dropMutation = useMutation({
    mutationFn: (classSectionId) => studentApi.drop(classSectionId),
    onSuccess: () => {
      message.success('Đã hủy đăng ký lớp học phần');
      invalidateAll();
    },
    onError: (err) => message.error(getErrorMessage(err)),
  });

  // Group individual class sections into Course units
  const courseGroups = useMemo(() => {
    const map = new Map();
    for (const item of classes) {
      if (!map.has(item.courseId)) {
        map.set(item.courseId, {
          courseId: item.courseId,
          courseCode: item.courseCode,
          courseName: item.courseName,
          credits: item.credits,
          departmentName: item.departmentName,
          sections: [],
          enrolledSection: null,
          hasEnrolled: false,
          canEnrollCount: 0,
          prerequisiteMet: item.prerequisiteMet,
          missingPrerequisites: item.missingPrerequisites || [],
        });
      }
      const group = map.get(item.courseId);
      group.sections.push(item);
      if (item.enrolled) {
        group.enrolledSection = item;
        group.hasEnrolled = true;
      }
      if (item.canEnroll) {
        group.canEnrollCount++;
      }
    }
    return Array.from(map.values()).sort((a, b) => a.courseCode.localeCompare(b.courseCode));
  }, [classes]);

  const filteredCourses = useMemo(() => {
    return courseGroups.filter((c) => {
      const kw = keyword.trim().toLowerCase();
      const matchKw =
        !kw ||
        c.courseCode.toLowerCase().includes(kw) ||
        c.courseName.toLowerCase().includes(kw) ||
        (c.departmentName && c.departmentName.toLowerCase().includes(kw)) ||
        c.sections.some((s) => s.sectionCode.toLowerCase().includes(kw));

      const matchStatus =
        statusFilter === 'ALL'
          ? true
          : statusFilter === 'CAN_ENROLL'
          ? c.canEnrollCount > 0 && !c.hasEnrolled
          : statusFilter === 'ENROLLED'
          ? c.hasEnrolled
          : true;

      return matchKw && matchStatus;
    });
  }, [courseGroups, keyword, statusFilter]);

  const courseLazy = useLazyList(filteredCourses, { initialCount: 25, pageSize: 25 });

  const activeCourse = useMemo(() => {
    return courseGroups.find((c) => c.courseId === selectedCourseId) || null;
  }, [courseGroups, selectedCourseId]);

  const handleOpenCourseModal = (course) => {
    setSelectedCourseId(course.courseId);
    setSectionModalOpen(true);
  };

  // Main Course Table Columns
  const courseColumns = [
    {
      title: 'STT',
      key: 'stt',
      width: 55,
      align: 'center',
      render: (_, __, idx) => <span className="text-slate-400 font-medium">{idx + 1}</span>,
    },
    {
      title: 'Mã HP',
      dataIndex: 'courseCode',
      key: 'courseCode',
      width: 120,
      render: (val, r) => (
        <button
          type="button"
          onClick={() => handleOpenCourseModal(r)}
          className="font-bold text-ag-700 hover:text-ag-800 hover:underline bg-transparent border-0 cursor-pointer p-0 text-left"
        >
          {val}
        </button>
      ),
    },
    {
      title: 'Tên học phần (Bấm để xem danh sách lớp)',
      dataIndex: 'courseName',
      key: 'courseName',
      render: (val, r) => (
        <div>
          <button
            type="button"
            onClick={() => handleOpenCourseModal(r)}
            className="font-semibold text-slate-800 hover:text-ag-600 bg-transparent border-0 cursor-pointer p-0 text-left text-sm leading-snug flex items-center gap-1.5 group"
          >
            <span className="group-hover:underline">{val}</span>
            <AppstoreOutlined className="text-ag-500 text-xs opacity-70 group-hover:opacity-100" />
          </button>
          {!r.prerequisiteMet && r.missingPrerequisites.length > 0 && (
            <div className="text-[11px] text-amber-700 mt-0.5">
              Tiên quyết chưa đạt: {r.missingPrerequisites.join('; ')}
            </div>
          )}
        </div>
      ),
    },
    {
      title: 'Số TC',
      dataIndex: 'credits',
      key: 'credits',
      width: 75,
      align: 'center',
      render: (v) => <span className="font-bold text-slate-800">{v}</span>,
    },
    {
      title: 'Khoa / Viện',
      dataIndex: 'departmentName',
      key: 'departmentName',
      width: 180,
      render: (v) => <span className="text-xs text-slate-600">{v || 'Khoa CNTT'}</span>,
    },
    {
      title: 'Số lớp mở',
      key: 'sectionCount',
      width: 120,
      align: 'center',
      render: (_, r) => (
        <Tag color="cyan" className="font-medium">
          {r.sections.length} lớp HP
        </Tag>
      ),
    },
    {
      title: 'Trạng thái đăng ký',
      key: 'status',
      width: 220,
      render: (_, r) => {
        if (r.hasEnrolled) {
          return (
            <Tag icon={<CheckCircleOutlined />} color="blue" className="font-medium">
              Đã ĐK: {r.enrolledSection?.sectionCode}
            </Tag>
          );
        }
        if (!r.prerequisiteMet) {
          return (
            <Tooltip title={`Thiếu tiên quyết: ${r.missingPrerequisites.join(', ')}`}>
              <Tag icon={<CloseCircleOutlined />} color="error">
                Thiếu tiên quyết
              </Tag>
            </Tooltip>
          );
        }
        if (r.canEnrollCount > 0) {
          return (
            <Tag icon={<CheckCircleOutlined />} color="success">
              Có thể đăng ký ({r.canEnrollCount} lớp)
            </Tag>
          );
        }
        return <Tag color="warning">Trùng lịch / Đã hết chỗ</Tag>;
      },
    },
    {
      title: 'Thao tác',
      key: 'action',
      width: 120,
      align: 'center',
      render: (_, r) => (
        <Button
          type={r.hasEnrolled ? 'default' : 'primary'}
          ghost={!r.hasEnrolled}
          size="small"
          onClick={() => handleOpenCourseModal(r)}
        >
          {r.hasEnrolled ? 'Xem / Đổi lớp' : 'Chọn lớp'}
        </Button>
      ),
    },
  ];

  // Section Table Columns (Inside Course Sections Modal)
  const sectionColumns = [
    {
      title: 'Mã lớp HP',
      dataIndex: 'sectionCode',
      key: 'sectionCode',
      width: 130,
      render: (val) => <span className="font-bold text-ag-700 font-mono text-sm">{val}</span>,
    },
    {
      title: 'Giảng viên',
      dataIndex: 'teacherName',
      key: 'teacherName',
      width: 160,
      render: (v) => (
        <span className="text-slate-800 text-xs font-medium flex items-center gap-1">
          <UserOutlined className="text-slate-400" /> {v || 'Chưa phân công'}
        </span>
      ),
    },
    {
      title: 'Lịch học (Thứ, Tiết, Phòng)',
      key: 'schedules',
      render: (_, r) => (
        <div className="space-y-1">
          {r.schedules?.map((s, idx) => (
            <div key={idx} className="text-xs text-slate-700 flex items-center gap-1.5 flex-wrap">
              <Tag color="blue" className="m-0 font-medium">
                {s.dayOfWeek === 8 ? 'Chủ nhật' : `Thứ ${s.dayOfWeek}`} (Tiết {s.startPeriod}-{s.endPeriod})
              </Tag>
              <span className="text-slate-600 font-medium">Phòng {s.room}</span>
            </div>
          ))}
        </div>
      ),
    },
    {
      title: 'Sĩ số',
      key: 'capacity',
      width: 95,
      align: 'center',
      render: (_, r) => (
        <Tag color={r.full ? 'red' : r.currentEnrolled >= r.maxCapacity - 5 ? 'orange' : 'green'} className="font-semibold">
          {r.currentEnrolled}/{r.maxCapacity}
        </Tag>
      ),
    },
    {
      title: 'Điều kiện & Trạng thái',
      key: 'status',
      width: 200,
      render: (_, r) => {
        if (r.enrolled) {
          return (
            <Tag icon={<CheckCircleOutlined />} color="blue" className="font-semibold">
              Đang học lớp này
            </Tag>
          );
        }
        if (r.sameCourseEnrolled) {
          return <Tag color="purple">Đã ĐK lớp khác cùng môn</Tag>;
        }
        if (!r.prerequisiteMet) {
          return (
            <Tooltip title={`Thiếu tiên quyết: ${r.missingPrerequisites.join(', ')}`}>
              <Tag icon={<CloseCircleOutlined />} color="error">
                Thiếu tiên quyết
              </Tag>
            </Tooltip>
          );
        }
        if (r.scheduleConflict) {
          return (
            <Tooltip title={r.conflictMessage}>
              <Tag icon={<WarningOutlined />} color="warning">
                Trùng lịch học
              </Tag>
            </Tooltip>
          );
        }
        if (r.full) {
          return <Tag color="default">Hết chỗ</Tag>;
        }
        return <Tag color="success">Đủ điều kiện ĐK</Tag>;
      },
    },
    {
      title: 'Thao tác',
      key: 'action',
      width: 120,
      align: 'center',
      render: (_, r) =>
        r.enrolled ? (
          <Popconfirm
            title="Hủy đăng ký lớp học phần này?"
            description={`Bạn có chắc muốn hủy lớp ${r.sectionCode}?`}
            okText="Hủy lớp"
            cancelText="Đóng"
            okButtonProps={{ danger: true }}
            onConfirm={() => dropMutation.mutate(r.id)}
          >
            <Button danger size="small" disabled={!selectedSemester?.registerOpen} loading={dropMutation.isPending}>
              Hủy lớp
            </Button>
          </Popconfirm>
        ) : (
          <Tooltip title={!r.canEnroll ? r.conflictMessage || (r.full ? 'Lớp đã hết chỗ' : 'Không đủ điều kiện') : ''}>
            <Button
              type="primary"
              size="small"
              icon={<PlusOutlined />}
              disabled={!r.canEnroll || !selectedSemester?.registerOpen}
              loading={enrollMutation.isPending}
              onClick={() => enrollMutation.mutate(r.id)}
            >
              Đăng ký
            </Button>
          </Tooltip>
        ),
    },
  ];

  return (
    <div className="space-y-5">
      {!selectedSemester?.registerOpen && (
        <Alert
          type="warning"
          showIcon
          message="Học kỳ đang chọn hiện KHÔNG mở cổng đăng ký tín chỉ"
          description="Bạn có thể xem danh sách lớp mở tham khảo hoặc chọn học kỳ đang mở ở góc trên bên phải."
        />
      )}

      {/* Top Credit & Enrollment Summary Card */}
      <Card className="shadow-xs border border-slate-200" styles={{ body: { padding: 16 } }}>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h2 className="m-0 text-base md:text-lg font-bold text-slate-800">
              Cổng Đăng ký Tín chỉ — {selectedSemester?.name}
            </h2>
            <div className="text-xs text-slate-600 mt-1">
              Tín chỉ đã chọn:{' '}
              <strong className="text-ag-600">
                {dashboard?.currentSemesterCredits ?? 0} / {dashboard?.currentSemesterMaxCredits ?? 24} TC
              </strong>{' '}
              (Tối thiểu {dashboard?.currentSemesterMinCredits ?? 12} TC) • Số lớp đã ĐK:{' '}
              <strong>{dashboard?.enrolledCoursesCount ?? 0}</strong>
            </div>
          </div>

          <Space wrap>
            <Input
              allowClear
              prefix={<SearchOutlined className="text-slate-400" />}
              placeholder="Tìm mã học phần, tên môn..."
              value={keyword}
              onChange={(e) => setKeyword(e.target.value)}
              className="w-56"
            />
            <Select
              value={statusFilter}
              onChange={setStatusFilter}
              className="w-48"
              options={[
                { value: 'ALL', label: 'Tất cả học phần mở' },
                { value: 'CAN_ENROLL', label: 'Có thể đăng ký' },
                { value: 'ENROLLED', label: 'Các môn đã đăng ký' },
              ]}
            />
          </Space>
        </div>
      </Card>

      {/* Timetable at the top of the page */}
      <TimetableGrid
        items={schedule}
        canDrop={Boolean(selectedSemester?.registerOpen)}
        onDropSection={(sectionId) => dropMutation.mutate(sectionId)}
        title="Thời khóa biểu các lớp đã đăng ký trong kỳ (Bấm dấu × để hủy nhanh)"
      />

      {/* Course Table - Click course name to view and select sections */}
      <Card
        className="shadow-xs border border-slate-200"
        title={
          <div className="flex items-center justify-between flex-wrap gap-2 py-1">
            <span className="font-bold text-slate-800 text-sm md:text-base">
              Danh sách học phần mở đăng ký ({filteredCourses.length} môn học phần)
            </span>
            <span className="text-xs text-slate-500 font-normal">
              Bấm vào tên môn để mở danh sách các lớp học phần và chọn đăng ký
            </span>
          </div>
        }
        styles={{ body: { padding: 0 } }}
      >
        <div ref={courseLazy.containerRef}>
          <Table
            rowKey="courseId"
            loading={isLoading}
            columns={courseColumns}
            dataSource={courseLazy.visibleData}
            scroll={{ x: 800, y: 520 }}
            pagination={false}
          />
        </div>
      </Card>

      {/* Course Sections Modal: Modal danh sách các lớp học phần của môn được chọn */}
      <Modal
        title={
          <div>
            <div className="text-base font-bold text-slate-900">
              Danh sách Lớp học phần — {activeCourse?.courseName} ({activeCourse?.courseCode})
            </div>
            <div className="text-xs text-slate-500 font-normal mt-0.5">
              Số tín chỉ: <strong className="text-slate-800">{activeCourse?.credits} TC</strong> • Khoa quản lý:{' '}
              <strong className="text-slate-800">{activeCourse?.departmentName || 'Khoa CNTT'}</strong> • Tổng số lớp mở:{' '}
              <strong className="text-ag-600">{activeCourse?.sections.length || 0} lớp</strong>
            </div>
          </div>
        }
        open={sectionModalOpen}
        onCancel={() => setSectionModalOpen(false)}
        footer={[
          <Button key="close" onClick={() => setSectionModalOpen(false)}>
            Đóng
          </Button>,
        ]}
        width={920}
      >
        <div className="py-2">
          {activeCourse && (
            <Table
              rowKey="id"
              columns={sectionColumns}
              dataSource={activeCourse.sections}
              pagination={false}
              size="middle"
            />
          )}
        </div>
      </Modal>
    </div>
  );
};
