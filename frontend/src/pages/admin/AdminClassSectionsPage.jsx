import React, { useState } from 'react';
import { Button, Card, Form, Input, InputNumber, Modal, Popconfirm, Select, Space, Table, Tag, message } from 'antd';
import { DeleteOutlined, MinusCircleOutlined, PlusOutlined, SearchOutlined, UserAddOutlined } from '@ant-design/icons';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { adminApi } from '../../api/services';
import { getErrorMessage } from '../../api/client';
import { useSemester } from '../../context/SemesterContext';

export const AdminClassSectionsPage = () => {
  const { semesters, selectedSemesterId } = useSemester();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(0);
  const [keyword, setKeyword] = useState('');
  const [createOpen, setCreateOpen] = useState(false);
  const [forceSection, setForceSection] = useState(null);
  const [form] = Form.useForm();
  const [forceForm] = Form.useForm();

  const { data, isLoading } = useQuery({
    queryKey: ['admin-class-sections', selectedSemesterId, keyword],
    queryFn: () =>
      adminApi.getClassSections({
        semesterId: selectedSemesterId,
        keyword: keyword || undefined,
        page: 0,
        size: 1000,
      }),
  });

  const { data: coursesData } = useQuery({
    queryKey: ['admin-courses-all'],
    queryFn: () => adminApi.getCourses({ page: 0, size: 200 }),
  });

  const { data: teachersData } = useQuery({
    queryKey: ['admin-teachers-all'],
    queryFn: () => adminApi.getTeachers({ page: 0, size: 200 }),
  });

  const { data: studentsData } = useQuery({
    queryKey: ['admin-students-all'],
    queryFn: () => adminApi.getStudents({ page: 0, size: 200 }),
    enabled: Boolean(forceSection),
  });

  const createMutation = useMutation({
    mutationFn: (vals) => adminApi.createClassSection(vals),
    onSuccess: () => {
      message.success('Mở lớp học phần thành công');
      setCreateOpen(false);
      form.resetFields();
      queryClient.invalidateQueries({ queryKey: ['admin-class-sections'] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const deleteMutation = useMutation({
    mutationFn: (id) => adminApi.deleteClassSection(id),
    onSuccess: () => {
      message.success('Đã xóa lớp học phần');
      queryClient.invalidateQueries({ queryKey: ['admin-class-sections'] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const forceEnrollMutation = useMutation({
    mutationFn: ({ sectionId, studentId }) => adminApi.forceEnroll(sectionId, studentId),
    onSuccess: () => {
      message.success('Ép ghi danh sinh viên thành công');
      setForceSection(null);
      forceForm.resetFields();
      queryClient.invalidateQueries({ queryKey: ['admin-class-sections'] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const columns = [
    { title: 'Mã lớp HP', dataIndex: 'sectionCode', width: 150, render: (v) => <strong className="text-ag-700">{v}</strong> },
    {
      title: 'Môn học',
      key: 'course',
      render: (_, r) => (
        <div>
          <div className="font-semibold text-slate-800">{r.courseName}</div>
          <div className="text-xs text-slate-500">
            {r.courseCode} • {r.credits} TC
          </div>
        </div>
      ),
    },
    { title: 'Giảng viên', dataIndex: 'teacherName', width: 180 },
    {
      title: 'Lịch học',
      key: 'schedules',
      width: 240,
      render: (_, r) => (
        <div className="space-y-1">
          {r.schedules.map((s, idx) => (
            <div key={idx} className="text-xs">
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
      key: 'cap',
      width: 95,
      align: 'center',
      render: (_, r) => <Tag color={r.currentEnrolled >= r.maxCapacity ? 'red' : 'green'}>{r.currentEnrolled}/{r.maxCapacity}</Tag>,
    },
    {
      title: 'Trạng thái',
      dataIndex: 'status',
      width: 100,
      render: (s) => <Tag color={s === 'OPEN' ? 'blue' : 'default'}>{s}</Tag>,
    },
    {
      title: 'Thao tác',
      width: 170,
      render: (_, r) => (
        <Space>
          <Button size="small" icon={<UserAddOutlined />} onClick={() => setForceSection(r)}>
            Ép ĐK
          </Button>
          <Popconfirm title="Xóa lớp học phần này?" onConfirm={() => deleteMutation.mutate(r.id)}>
            <Button size="small" danger icon={<DeleteOutlined />} />
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div className="space-y-4">
      <Card className="shadow-sm" styles={{ body: { padding: 16 } }}>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h2 className="m-0 text-base font-bold text-slate-800">Quản lý Mở Lớp học phần & Thời khóa biểu</h2>
            <div className="text-xs text-slate-500">Học kỳ lọc theo bộ chọn học kỳ trên thanh tiêu đề</div>
          </div>
          <Space wrap>
            <Input
              allowClear
              prefix={<SearchOutlined />}
              placeholder="Tìm mã lớp, môn học..."
              value={keyword}
              onChange={(e) => {
                setKeyword(e.target.value);
                setPage(0);
              }}
              className="w-56"
            />
            <Button
              type="primary"
              icon={<PlusOutlined />}
              onClick={() => {
                form.resetFields();
                form.setFieldsValue({
                  semesterId: selectedSemesterId,
                  maxCapacity: 60,
                  status: 'OPEN',
                  schedules: [{ dayOfWeek: 2, startPeriod: 1, endPeriod: 3, room: 'A1-302 (Cơ sở 1 - Khu A)' }],
                });
                setCreateOpen(true);
              }}
            >
              Mở lớp học phần
            </Button>
          </Space>
        </div>
      </Card>

      <Card className="shadow-sm" styles={{ body: { padding: 0 } }}>
        <Table
          rowKey="id"
          loading={isLoading}
          columns={columns}
          dataSource={data?.content ?? []}
          scroll={{ x: 1000 }}
          pagination={false}
        />
      </Card>

      <Modal
        title="Mở Lớp học phần & Phân công Lịch dạy"
        open={createOpen}
        onCancel={() => setCreateOpen(false)}
        onOk={() => form.submit()}
        confirmLoading={createMutation.isPending}
        width={720}
      >
        <Form form={form} layout="vertical" onFinish={(vals) => createMutation.mutate(vals)}>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <Form.Item name="semesterId" label="Học kỳ" rules={[{ required: true }]}>
              <Select options={semesters.map((s) => ({ value: s.id, label: `${s.code} - ${s.name}` }))} />
            </Form.Item>
            <Form.Item name="sectionCode" label="Mã lớp học phần" rules={[{ required: true }]}>
              <Input placeholder="VD: 20261IT4010002" />
            </Form.Item>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <Form.Item name="courseId" label="Môn học" rules={[{ required: true }]}>
              <Select
                showSearch
                optionFilterProp="label"
                options={(coursesData?.content ?? []).map((c) => ({ value: c.id, label: `${c.code} - ${c.name}` }))}
              />
            </Form.Item>
            <Form.Item name="teacherId" label="Giảng viên phụ trách">
              <Select
                allowClear
                showSearch
                optionFilterProp="label"
                options={(teachersData?.content ?? []).map((t) => ({ value: t.id, label: `${t.teacherCode} - ${t.fullName}` }))}
              />
            </Form.Item>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Form.Item name="maxCapacity" label="Sĩ số tối đa" rules={[{ required: true }]}>
              <InputNumber min={1} max={300} className="w-full" />
            </Form.Item>
            <Form.Item name="status" label="Trạng thái" rules={[{ required: true }]}>
              <Select
                options={[
                  { value: 'OPEN', label: 'OPEN (Mở đăng ký)' },
                  { value: 'CLOSED', label: 'CLOSED' },
                ]}
              />
            </Form.Item>
          </div>

          <div className="font-semibold text-xs text-slate-600 mb-2">Lịch học trong tuần:</div>
          <Form.List name="schedules">
            {(fields, { add, remove }) => (
              <div className="space-y-2">
                {fields.map(({ key, name, ...restField }) => (
                  <div key={key} className="grid grid-cols-12 gap-2 items-center bg-slate-50 p-2 rounded-lg">
                    <Form.Item {...restField} name={[name, 'dayOfWeek']} className="col-span-3 mb-0" rules={[{ required: true }]}>
                      <Select
                        options={[2, 3, 4, 5, 6, 7, 8].map((d) => ({
                          value: d,
                          label: d === 8 ? 'Chủ nhật' : `Thứ ${d}`,
                        }))}
                      />
                    </Form.Item>
                    <Form.Item {...restField} name={[name, 'startPeriod']} className="col-span-2 mb-0" rules={[{ required: true }]}>
                      <InputNumber min={1} max={15} placeholder="Từ tiết" className="w-full" />
                    </Form.Item>
                    <Form.Item {...restField} name={[name, 'endPeriod']} className="col-span-2 mb-0" rules={[{ required: true }]}>
                      <InputNumber min={1} max={15} placeholder="Đến tiết" className="w-full" />
                    </Form.Item>
                    <Form.Item {...restField} name={[name, 'room']} className="col-span-4 mb-0" rules={[{ required: true }]}>
                      <Input placeholder="Phòng (vd: 305 Khu A)" />
                    </Form.Item>
                    <div className="col-span-1 text-center">
                      {fields.length > 1 && <MinusCircleOutlined className="text-red-500 cursor-pointer" onClick={() => remove(name)} />}
                    </div>
                  </div>
                ))}
                <Button type="dashed" onClick={() => add({ dayOfWeek: 2, startPeriod: 1, endPeriod: 3, room: '' })} block icon={<PlusOutlined />}>
                  Thêm buổi học
                </Button>
              </div>
            )}
          </Form.List>
        </Form>
      </Modal>

      <Modal
        title={`Ép ghi danh vào lớp ${forceSection?.sectionCode || ''}`}
        open={Boolean(forceSection)}
        onCancel={() => setForceSection(null)}
        onOk={() => forceForm.submit()}
        confirmLoading={forceEnrollMutation.isPending}
      >
        <Form
          form={forceForm}
          layout="vertical"
          onFinish={(vals) => forceEnrollMutation.mutate({ sectionId: forceSection.id, studentId: vals.studentId })}
        >
          <Form.Item name="studentId" label="Chọn Sinh viên" rules={[{ required: true }]}>
            <Select
              showSearch
              optionFilterProp="label"
              options={(studentsData?.content ?? []).map((s) => ({
                value: s.id,
                label: `${s.studentCode} - ${s.fullName} (${s.departmentCode})`,
              }))}
            />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};
