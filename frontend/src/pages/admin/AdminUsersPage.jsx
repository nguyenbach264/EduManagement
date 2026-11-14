import React, { useState } from 'react';
import {
  Button,
  Card,
  Form,
  Input,
  InputNumber,
  Modal,
  Select,
  Space,
  Table,
  Tabs,
  Tag,
  Upload,
  message,
} from 'antd';
import { EditOutlined, PlusOutlined, SearchOutlined, UploadOutlined } from '@ant-design/icons';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { adminApi } from '../../api/services';
import { getErrorMessage } from '../../api/client';
import { useLazyList } from '../../hooks/useLazyList';

export const AdminUsersPage = () => {
  const queryClient = useQueryClient();

  const [stuKeyword, setStuKeyword] = useState('');
  const [stuDept, setStuDept] = useState(undefined);
  const [stuCohort, setStuCohort] = useState(undefined);
  const [stuModalOpen, setStuModalOpen] = useState(false);
  const [editingStu, setEditingStu] = useState(null);
  const [stuForm] = Form.useForm();

  const [teaKeyword, setTeaKeyword] = useState('');
  const [teaDept, setTeaDept] = useState(undefined);
  const [teaStatus, setTeaStatus] = useState(undefined);
  const [teaModalOpen, setTeaModalOpen] = useState(false);
  const [editingTea, setEditingTea] = useState(null);
  const [teaForm] = Form.useForm();

  const { data: departments = [] } = useQuery({ queryKey: ['admin-departments'], queryFn: adminApi.getDepartments });
  const { data: programs = [] } = useQuery({ queryKey: ['admin-programs'], queryFn: adminApi.getPrograms });

  const { data: studentsData, isLoading: loadingStu } = useQuery({
    queryKey: ['admin-students', stuKeyword, stuDept, stuCohort],
    queryFn: () =>
      adminApi.getStudents({
        page: 0,
        size: 5000,
        keyword: stuKeyword || undefined,
        departmentId: stuDept,
        cohort: stuCohort,
      }),
  });

  const { data: teachersData, isLoading: loadingTea } = useQuery({
    queryKey: ['admin-teachers', teaKeyword, teaDept, teaStatus],
    queryFn: () =>
      adminApi.getTeachers({
        page: 0,
        size: 5000,
        keyword: teaKeyword || undefined,
        departmentId: teaDept,
        active: teaStatus,
      }),
  });

  const stuLazy = useLazyList(studentsData?.content ?? [], { initialCount: 40, pageSize: 40 });
  const teaLazy = useLazyList(teachersData?.content ?? [], { initialCount: 40, pageSize: 40 });

  const saveStudentMutation = useMutation({
    mutationFn: (vals) =>
      editingStu ? adminApi.updateStudent(editingStu.id, vals) : adminApi.createStudent(vals),
    onSuccess: () => {
      message.success(editingStu ? 'Cập nhật sinh viên thành công' : 'Lưu hồ sơ sinh viên thành công');
      setStuModalOpen(false);
      setEditingStu(null);
      stuForm.resetFields();
      queryClient.invalidateQueries({ queryKey: ['admin-students'] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const saveTeacherMutation = useMutation({
    mutationFn: (vals) =>
      editingTea ? adminApi.updateTeacher(editingTea.id, vals) : adminApi.createTeacher(vals),
    onSuccess: () => {
      message.success(editingTea ? 'Cập nhật giảng viên thành công' : 'Tạo giảng viên thành công');
      setTeaModalOpen(false);
      setEditingTea(null);
      teaForm.resetFields();
      queryClient.invalidateQueries({ queryKey: ['admin-teachers'] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const studentColumns = [
    { title: 'Mã SV', dataIndex: 'studentCode', width: 120, render: (v) => <strong className="text-ag-700">{v}</strong> },
    { title: 'Họ và tên', dataIndex: 'fullName', width: 180 },
    { title: 'Email', dataIndex: 'email', width: 200 },
    { title: 'Khoa', dataIndex: 'departmentName' },
    { title: 'Ngành / CTĐT', dataIndex: 'programName' },
    { title: 'Khóa', dataIndex: 'cohort', width: 80, align: 'center' },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      width: 110,
      render: (s) => <Tag color={s === 'STUDYING' ? 'green' : s === 'WARNING' ? 'orange' : 'default'}>{s}</Tag>,
    },
    {
      title: 'Sửa',
      width: 70,
      align: 'center',
      render: (_, r) => (
        <Button
          size="small"
          icon={<EditOutlined />}
          onClick={() => {
            setEditingStu(r);
            stuForm.setFieldsValue(r);
            setStuModalOpen(true);
          }}
        />
      ),
    },
  ];

  const teacherColumns = [
    { title: 'Mã GV', dataIndex: 'teacherCode', width: 100, render: (v) => <strong className="text-ag-700">{v}</strong> },
    { title: 'Họ và tên', dataIndex: 'fullName', width: 200 },
    { title: 'Học vị / Học hàm', dataIndex: 'academicRank', width: 140 },
    { title: 'Chức danh', dataIndex: 'academicTitle', width: 130, render: (v) => v || 'Giảng viên' },
    { title: 'Email', dataIndex: 'email', width: 210 },
    { title: 'Khoa', dataIndex: 'departmentName' },
    {
      title: 'Trạng thái làm việc',
      dataIndex: 'active',
      width: 140,
      align: 'center',
      render: (a) => (
        <Tag color={a ? 'green' : 'red'}>
          {a ? 'Đang công tác' : 'Tạm nghỉ / Đã nghỉ'}
        </Tag>
      ),
    },
    {
      title: 'Sửa',
      width: 70,
      align: 'center',
      render: (_, r) => (
        <Button
          size="small"
          icon={<EditOutlined />}
          onClick={() => {
            setEditingTea(r);
            teaForm.setFieldsValue({
              ...r,
              active: r.active !== undefined ? r.active : true,
            });
            setTeaModalOpen(true);
          }}
        />
      ),
    },
  ];

  return (
    <Card className="shadow-sm">
      <Tabs
        items={[
          {
            key: 'students',
            label: `Sinh viên (${studentsData?.totalElements ?? 0})`,
            children: (
              <div className="space-y-3">
                <div className="flex flex-wrap justify-between gap-2">
                  <Space wrap>
                    <Input
                      allowClear
                      prefix={<SearchOutlined />}
                      placeholder="Tìm mã SV, tên, email..."
                      value={stuKeyword}
                      onChange={(e) => setStuKeyword(e.target.value)}
                      className="w-56"
                    />
                    <Select
                      allowClear
                      placeholder="Lọc theo khoa"
                      value={stuDept}
                      onChange={setStuDept}
                      className="w-52"
                      options={departments.map((d) => ({ value: d.id, label: d.name }))}
                    />
                    <Select
                      allowClear
                      placeholder="Khóa"
                      value={stuCohort}
                      onChange={setStuCohort}
                      className="w-28"
                      options={[2021, 2022, 2023, 2024, 2025].map((c) => ({ value: c, label: `K${c}` }))}
                    />
                  </Space>

                  <Space wrap>
                    <Upload
                      accept=".xlsx"
                      showUploadList={false}
                      customRequest={async ({ file, onSuccess, onError }) => {
                        try {
                          const res = await adminApi.importStudentsExcel(file);
                          message.success(`Import thành công ${res.importedCount}/${res.totalRows} sinh viên (bỏ qua ${res.skippedCount})`);
                          queryClient.invalidateQueries({ queryKey: ['admin-students'] });
                          onSuccess?.(res);
                        } catch (err) {
                          message.error(getErrorMessage(err));
                          onError?.(err);
                        }
                      }}
                    >
                      <Button icon={<UploadOutlined />}>Import Excel (.xlsx)</Button>
                    </Upload>
                    <Button
                      type="primary"
                      icon={<PlusOutlined />}
                      onClick={() => {
                        setEditingStu(null);
                        stuForm.resetFields();
                        setStuModalOpen(true);
                      }}
                    >
                      Thêm Sinh viên
                    </Button>
                  </Space>
                </div>

                <div ref={stuLazy.containerRef} className="border border-slate-200 rounded-lg overflow-hidden bg-white shadow-sm">
                  <Table
                    rowKey="id"
                    loading={loadingStu}
                    columns={studentColumns}
                    dataSource={stuLazy.visibleData}
                    scroll={{ x: 1000, y: 560 }}
                    pagination={false}
                  />
                </div>
              </div>
            ),
          },
          {
            key: 'teachers',
            label: `Giảng viên (${teachersData?.totalElements ?? 0})`,
            children: (
              <div className="space-y-3">
                <div className="flex flex-wrap justify-between gap-2">
                  <Space wrap>
                    <Input
                      allowClear
                      prefix={<SearchOutlined />}
                      placeholder="Tìm mã GV, tên, email..."
                      value={teaKeyword}
                      onChange={(e) => setTeaKeyword(e.target.value)}
                      className="w-56"
                    />
                    <Select
                      allowClear
                      placeholder="Lọc theo khoa"
                      value={teaDept}
                      onChange={setTeaDept}
                      className="w-52"
                      options={departments.map((d) => ({ value: d.id, label: d.name }))}
                    />
                    <Select
                      allowClear
                      placeholder="Trạng thái làm việc"
                      value={teaStatus}
                      onChange={setTeaStatus}
                      className="w-52"
                      options={[
                        { value: true, label: 'Đang công tác (Hoạt động)' },
                        { value: false, label: 'Tạm nghỉ / Đã nghỉ việc' },
                      ]}
                    />
                  </Space>
                  <Button
                    type="primary"
                    icon={<PlusOutlined />}
                    onClick={() => {
                      setEditingTea(null);
                      teaForm.resetFields();
                      setTeaModalOpen(true);
                    }}
                  >
                    Thêm Giảng viên
                  </Button>
                </div>

                <div ref={teaLazy.containerRef} className="border border-slate-200 rounded-lg overflow-hidden bg-white shadow-sm">
                  <Table
                    rowKey="id"
                    loading={loadingTea}
                    columns={teacherColumns}
                    dataSource={teaLazy.visibleData}
                    scroll={{ x: 1000, y: 560 }}
                    pagination={false}
                  />
                </div>
              </div>
            ),
          },
        ]}
      />

      {/* Modal Sinh viên */}
      <Modal
        title={editingStu ? `Cập nhật SV: ${editingStu.studentCode}` : 'Thêm Sinh viên mới'}
        open={stuModalOpen}
        onCancel={() => {
          setStuModalOpen(false);
          setEditingStu(null);
        }}
        onOk={() => stuForm.submit()}
        confirmLoading={saveStudentMutation.isPending}
        width={620}
      >
        <Form form={stuForm} layout="vertical" onFinish={(vals) => saveStudentMutation.mutate(vals)}>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {!editingStu && (
              <Form.Item name="studentCode" label="Mã sinh viên" rules={[{ required: true }]}>
                <Input />
              </Form.Item>
            )}
            <Form.Item name="fullName" label="Họ và tên" rules={[{ required: true }]}>
              <Input />
            </Form.Item>
            <Form.Item name="email" label="Email" rules={[{ required: true, type: 'email' }]}>
              <Input />
            </Form.Item>
            <Form.Item name="phone" label="Số điện thoại">
              <Input />
            </Form.Item>
            <Form.Item name="departmentId" label="Khoa" rules={[{ required: true }]}>
              <Select showSearch optionFilterProp="label" options={departments.map((d) => ({ value: d.id, label: d.name }))} />
            </Form.Item>
            <Form.Item name="programId" label="Chương trình đào tạo" rules={[{ required: true }]}>
              <Select showSearch optionFilterProp="label" options={programs.map((p) => ({ value: p.id, label: `${p.code} - ${p.name}` }))} />
            </Form.Item>
            <Form.Item name="cohort" label="Khóa học" initialValue={2024} rules={[{ required: true }]}>
              <InputNumber min={2015} max={2035} className="w-full" />
            </Form.Item>
            {editingStu && (
              <Form.Item name="status" label="Trạng thái học vụ">
                <Select
                  options={['STUDYING', 'WARNING', 'SUSPENDED', 'DROPPED', 'GRADUATED'].map((s) => ({ value: s, label: s }))}
                />
              </Form.Item>
            )}
          </div>
        </Form>
      </Modal>

      {/* Modal Giảng viên (Thêm mới & Chỉnh sửa thông tin, Trạng thái làm việc) */}
      <Modal
        title={editingTea ? `Chỉnh sửa Giảng viên: ${editingTea.teacherCode}` : 'Thêm Giảng viên mới'}
        open={teaModalOpen}
        onCancel={() => {
          setTeaModalOpen(false);
          setEditingTea(null);
          teaForm.resetFields();
        }}
        onOk={() => teaForm.submit()}
        confirmLoading={saveTeacherMutation.isPending}
        width={600}
      >
        <Form form={teaForm} layout="vertical" onFinish={(vals) => saveTeacherMutation.mutate(vals)}>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <Form.Item name="teacherCode" label="Mã giảng viên" rules={[{ required: true, message: 'Vui lòng nhập mã giảng viên' }]}>
              <Input disabled={Boolean(editingTea)} placeholder="Ví dụ: GV220" />
            </Form.Item>
            <Form.Item name="fullName" label="Họ và tên" rules={[{ required: true, message: 'Vui lòng nhập họ và tên' }]}>
              <Input placeholder="Ví dụ: TS. Nguyễn Văn A" />
            </Form.Item>
            <Form.Item name="email" label="Email" rules={[{ required: true, type: 'email', message: 'Email không hợp lệ' }]}>
              <Input placeholder="email@haui.edu.vn" />
            </Form.Item>
            <Form.Item name="phone" label="Số điện thoại">
              <Input placeholder="0912345678" />
            </Form.Item>
            <Form.Item name="departmentId" label="Khoa quản lý" rules={[{ required: true, message: 'Vui lòng chọn khoa' }]}>
              <Select showSearch optionFilterProp="label" options={departments.map((d) => ({ value: d.id, label: d.name }))} />
            </Form.Item>
            <Form.Item name="academicRank" label="Học vị / Học hàm" initialValue="Tiến sĩ">
              <Select options={['Thạc sĩ', 'Tiến sĩ', 'Phó Giáo sư', 'Giáo sư'].map((r) => ({ value: r, label: r }))} />
            </Form.Item>
            <Form.Item name="academicTitle" label="Chức danh giảng dạy" initialValue="Giảng viên">
              <Select options={['Giảng viên', 'Giảng viên chính', 'Giảng viên cao cấp'].map((r) => ({ value: r, label: r }))} />
            </Form.Item>
            <Form.Item name="active" label="Trạng thái làm việc" initialValue={true}>
              <Select
                options={[
                  { value: true, label: 'Đang làm việc / Hoạt động' },
                  { value: false, label: 'Tạm nghỉ / Đã nghỉ việc / Khóa' },
                ]}
              />
            </Form.Item>
            <div className="sm:col-span-2">
              <Form.Item name="officeAddress" label="Văn phòng làm việc">
                <Input placeholder="Ví dụ: Phòng 301, Nhà A1" />
              </Form.Item>
            </div>
            {!editingTea && (
              <div className="sm:col-span-2">
                <Form.Item name="password" label="Mật khẩu ban đầu (mặc định: 123456)">
                  <Input.Password placeholder="Để trống để dùng mật khẩu mặc định 123456" />
                </Form.Item>
              </div>
            )}
          </div>
        </Form>
      </Modal>
    </Card>
  );
};
