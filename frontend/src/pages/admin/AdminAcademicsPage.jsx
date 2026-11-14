import React, { useState } from 'react';
import { Button, Card, Form, Input, InputNumber, Modal, Popconfirm, Select, Space, Switch, Table, Tabs, Tag, message } from 'antd';
import { DeleteOutlined, EditOutlined, PlusOutlined, SearchOutlined } from '@ant-design/icons';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { adminApi } from '../../api/services';
import { getErrorMessage } from '../../api/client';
import { useLazyList } from '../../hooks/useLazyList';

export const AdminAcademicsPage = () => {
  const queryClient = useQueryClient();

  const [deptModalOpen, setDeptModalOpen] = useState(false);
  const [editingDept, setEditingDept] = useState(null);
  const [deptForm] = Form.useForm();

  const [progModalOpen, setProgModalOpen] = useState(false);
  const [progForm] = Form.useForm();
  const [selectedProgram, setSelectedProgram] = useState(null);
  const [pcForm] = Form.useForm();

  const [coursePage, setCoursePage] = useState(0);
  const [courseKeyword, setCourseKeyword] = useState('');
  const [courseDeptFilter, setCourseDeptFilter] = useState(undefined);
  const [courseModalOpen, setCourseModalOpen] = useState(false);
  const [editingCourse, setEditingCourse] = useState(null);
  const [courseForm] = Form.useForm();

  const { data: departments = [], isLoading: loadingDepts } = useQuery({
    queryKey: ['admin-departments'],
    queryFn: adminApi.getDepartments,
  });

  const { data: programs = [], isLoading: loadingProgs } = useQuery({
    queryKey: ['admin-programs'],
    queryFn: adminApi.getPrograms,
  });

  const { data: coursesData, isLoading: loadingCourses } = useQuery({
    queryKey: ['admin-courses', courseKeyword, courseDeptFilter],
    queryFn: () =>
      adminApi.getCourses({
        page: 0,
        size: 5000,
        keyword: courseKeyword || undefined,
        departmentId: courseDeptFilter,
      }),
  });

  const courseLazy = useLazyList(coursesData?.content ?? [], { initialCount: 40, pageSize: 40 });

  const { data: allCoursesForSelect } = useQuery({
    queryKey: ['admin-courses-all'],
    queryFn: () => adminApi.getCourses({ page: 0, size: 200 }),
  });

  const { data: programCourses = [], isLoading: loadingPC } = useQuery({
    queryKey: ['admin-program-courses', selectedProgram?.id],
    queryFn: () => adminApi.getProgramCourses(selectedProgram.id),
    enabled: Boolean(selectedProgram?.id),
  });

  const saveDeptMutation = useMutation({
    mutationFn: (vals) =>
      editingDept ? adminApi.updateDepartment(editingDept.id, vals) : adminApi.createDepartment(vals),
    onSuccess: () => {
      message.success('Lưu khoa/viện thành công');
      setDeptModalOpen(false);
      setEditingDept(null);
      deptForm.resetFields();
      queryClient.invalidateQueries({ queryKey: ['admin-departments'] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const deleteDeptMutation = useMutation({
    mutationFn: (id) => adminApi.deleteDepartment(id),
    onSuccess: () => {
      message.success('Đã xóa khoa');
      queryClient.invalidateQueries({ queryKey: ['admin-departments'] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const saveProgMutation = useMutation({
    mutationFn: (vals) => adminApi.createProgram(vals),
    onSuccess: () => {
      message.success('Tạo chương trình đào tạo thành công');
      setProgModalOpen(false);
      progForm.resetFields();
      queryClient.invalidateQueries({ queryKey: ['admin-programs'] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const addPcMutation = useMutation({
    mutationFn: (vals) => adminApi.addProgramCourse(selectedProgram.id, vals),
    onSuccess: () => {
      message.success('Đã gán môn học vào khung CTĐT');
      pcForm.resetFields();
      queryClient.invalidateQueries({ queryKey: ['admin-program-courses', selectedProgram?.id] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const removePcMutation = useMutation({
    mutationFn: (pcId) => adminApi.removeProgramCourse(selectedProgram.id, pcId),
    onSuccess: () => {
      message.success('Đã xóa môn khỏi khung CTĐT');
      queryClient.invalidateQueries({ queryKey: ['admin-program-courses', selectedProgram?.id] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const saveCourseMutation = useMutation({
    mutationFn: (vals) =>
      editingCourse ? adminApi.updateCourse(editingCourse.id, vals) : adminApi.createCourse(vals),
    onSuccess: () => {
      message.success('Lưu môn học thành công');
      setCourseModalOpen(false);
      setEditingCourse(null);
      courseForm.resetFields();
      queryClient.invalidateQueries({ queryKey: ['admin-courses'] });
      queryClient.invalidateQueries({ queryKey: ['admin-courses-all'] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const deleteCourseMutation = useMutation({
    mutationFn: (id) => adminApi.deleteCourse(id),
    onSuccess: () => {
      message.success('Đã xóa môn học');
      queryClient.invalidateQueries({ queryKey: ['admin-courses'] });
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const deptColumns = [
    { title: 'Mã khoa', dataIndex: 'code', width: 110, render: (v) => <strong className="text-ag-700">{v}</strong> },
    { title: 'Tên Khoa / Viện', dataIndex: 'name' },
    { title: 'Điện thoại', dataIndex: 'phone', width: 140 },
    { title: 'Email', dataIndex: 'email', width: 200 },
    {
      title: 'Thao tác',
      width: 130,
      render: (_, r) => (
        <Space>
          <Button
            size="small"
            icon={<EditOutlined />}
            onClick={() => {
              setEditingDept(r);
              deptForm.setFieldsValue(r);
              setDeptModalOpen(true);
            }}
          />
          <Popconfirm title="Xóa khoa này?" onConfirm={() => deleteDeptMutation.mutate(r.id)}>
            <Button size="small" danger icon={<DeleteOutlined />} />
          </Popconfirm>
        </Space>
      ),
    },
  ];

  const progColumns = [
    { title: 'Mã CTĐT', dataIndex: 'code', width: 110, render: (v) => <strong className="text-ag-700">{v}</strong> },
    { title: 'Tên Chương trình Đào tạo', dataIndex: 'name' },
    { title: 'Khoa quản lý', dataIndex: 'departmentName' },
    { title: 'Tổng TC', dataIndex: 'totalCredits', width: 90, align: 'center' },
    { title: 'Số năm', dataIndex: 'durationYears', width: 80, align: 'center' },
    {
      title: 'Khung CTĐT',
      width: 150,
      render: (_, r) => (
        <Button size="small" type="primary" ghost onClick={() => setSelectedProgram(r)}>
          Cấu hình môn học
        </Button>
      ),
    },
  ];

  const courseColumns = [
    { title: 'Mã môn', dataIndex: 'code', width: 115, render: (v) => <strong className="text-ag-700">{v}</strong> },
    { title: 'Tên môn học', dataIndex: 'name' },
    { title: 'TC', dataIndex: 'credits', width: 60, align: 'center' },
    { title: 'Khoa', dataIndex: 'departmentName', width: 200 },
    {
      title: 'Tiên quyết',
      key: 'prereqs',
      render: (_, r) =>
        r.prerequisites.length === 0 ? (
          <span className="text-xs text-slate-400">Không có</span>
        ) : (
          <Space wrap size={4}>
            {r.prerequisites.map((p) => (
              <Tag color="blue" key={p.id}>
                {p.code}
              </Tag>
            ))}
          </Space>
        ),
    },
    {
      title: 'Thao tác',
      width: 120,
      render: (_, r) => (
        <Space>
          <Button
            size="small"
            icon={<EditOutlined />}
            onClick={() => {
              setEditingCourse(r);
              courseForm.setFieldsValue({
                ...r,
                prerequisiteIds: r.prerequisites.map((p) => p.id),
              });
              setCourseModalOpen(true);
            }}
          />
          <Popconfirm title="Xóa môn học này?" onConfirm={() => deleteCourseMutation.mutate(r.id)}>
            <Button size="small" danger icon={<DeleteOutlined />} />
          </Popconfirm>
        </Space>
      ),
    },
  ];

  const pcColumns = [
    { title: 'Kỳ', dataIndex: 'semesterIndex', width: 65, render: (v) => <Tag color="blue">Kỳ {v}</Tag> },
    { title: 'Mã môn', dataIndex: 'courseCode', width: 110 },
    { title: 'Tên môn học', dataIndex: 'courseName' },
    { title: 'TC', dataIndex: 'credits', width: 60, align: 'center' },
    { title: 'Loại', dataIndex: 'compulsory', width: 100, render: (v) => <Tag color={v ? 'geekblue' : 'default'}>{v ? 'Bắt buộc' : 'Tự chọn'}</Tag> },
    {
      title: 'Xóa',
      width: 70,
      render: (_, r) => (
        <Button size="small" danger icon={<DeleteOutlined />} onClick={() => removePcMutation.mutate(r.id)} />
      ),
    },
  ];

  return (
    <Card className="shadow-sm">
      <Tabs
        items={[
          {
            key: 'departments',
            label: `Khoa / Viện (${departments.length})`,
            children: (
              <div className="space-y-3">
                <div className="flex justify-end">
                  <Button
                    type="primary"
                    icon={<PlusOutlined />}
                    onClick={() => {
                      setEditingDept(null);
                      deptForm.resetFields();
                      setDeptModalOpen(true);
                    }}
                  >
                    Thêm Khoa/Viện
                  </Button>
                </div>
                <Table
                  rowKey="id"
                  loading={loadingDepts}
                  columns={deptColumns}
                  dataSource={departments}
                  scroll={{ x: 750 }}
                  pagination={false}
                />
              </div>
            ),
          },
          {
            key: 'programs',
            label: `Chương trình Đào tạo (${programs.length})`,
            children: (
              <div className="space-y-3">
                <div className="flex justify-end">
                  <Button type="primary" icon={<PlusOutlined />} onClick={() => setProgModalOpen(true)}>
                    Thêm Chương trình ĐT
                  </Button>
                </div>
                <Table
                  rowKey="id"
                  loading={loadingProgs}
                  columns={progColumns}
                  dataSource={programs}
                  scroll={{ x: 800 }}
                  pagination={false}
                />
              </div>
            ),
          },
          {
            key: 'courses',
            label: `Môn học & Tiên quyết (${coursesData?.totalElements ?? 0})`,
            children: (
              <div className="space-y-3">
                <div className="flex flex-wrap justify-between gap-2">
                  <Space wrap>
                    <Input
                      allowClear
                      prefix={<SearchOutlined />}
                      placeholder="Tìm mã/tên môn..."
                      value={courseKeyword}
                      onChange={(e) => {
                        setCourseKeyword(e.target.value);
                        setCoursePage(0);
                      }}
                      className="w-56"
                    />
                    <Select
                      allowClear
                      placeholder="Lọc theo khoa"
                      value={courseDeptFilter}
                      onChange={(v) => {
                        setCourseDeptFilter(v);
                        setCoursePage(0);
                      }}
                      className="w-56"
                      options={departments.map((d) => ({ value: d.id, label: d.name }))}
                    />
                  </Space>
                  <Button
                    type="primary"
                    icon={<PlusOutlined />}
                    onClick={() => {
                      setEditingCourse(null);
                      courseForm.resetFields();
                      courseForm.setFieldsValue({
                        attendanceWeight: 0.1,
                        midtermWeight: 0.3,
                        finalWeight: 0.6,
                        theoryHours: 30,
                        practiceHours: 30,
                      });
                      setCourseModalOpen(true);
                    }}
                  >
                    Thêm Môn học
                  </Button>
                </div>
                <div ref={courseLazy.containerRef} className="border border-slate-200 rounded-lg overflow-hidden bg-white shadow-sm">
                  <Table
                    rowKey="id"
                    loading={loadingCourses}
                    columns={courseColumns}
                    dataSource={courseLazy.visibleData}
                    scroll={{ x: 850, y: 560 }}
                    pagination={false}
                  />
                </div>
              </div>
            ),
          },
        ]}
      />

      <Modal
        title={editingDept ? 'Cập nhật Khoa/Viện' : 'Thêm Khoa/Viện'}
        open={deptModalOpen}
        onCancel={() => setDeptModalOpen(false)}
        onOk={() => deptForm.submit()}
        confirmLoading={saveDeptMutation.isPending}
      >
        <Form form={deptForm} layout="vertical" onFinish={(vals) => saveDeptMutation.mutate(vals)}>
          <Form.Item name="code" label="Mã khoa" rules={[{ required: true }]}>
            <Input disabled={Boolean(editingDept)} />
          </Form.Item>
          <Form.Item name="name" label="Tên khoa" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="phone" label="Điện thoại">
            <Input />
          </Form.Item>
          <Form.Item name="email" label="Email">
            <Input />
          </Form.Item>
          <Form.Item name="description" label="Mô tả">
            <Input.TextArea rows={2} />
          </Form.Item>
        </Form>
      </Modal>

      <Modal
        title="Thêm Chương trình Đào tạo"
        open={progModalOpen}
        onCancel={() => setProgModalOpen(false)}
        onOk={() => progForm.submit()}
        confirmLoading={saveProgMutation.isPending}
      >
        <Form form={progForm} layout="vertical" onFinish={(vals) => saveProgMutation.mutate(vals)}>
          <Form.Item name="code" label="Mã CTĐT" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="name" label="Tên CTĐT" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="departmentId" label="Khoa quản lý" rules={[{ required: true }]}>
            <Select options={departments.map((d) => ({ value: d.id, label: d.name }))} showSearch optionFilterProp="label" />
          </Form.Item>
          <div className="grid grid-cols-2 gap-3">
            <Form.Item name="totalCredits" label="Tổng tín chỉ" initialValue={150} rules={[{ required: true }]}>
              <InputNumber min={1} className="w-full" />
            </Form.Item>
            <Form.Item name="durationYears" label="Thời gian (năm)" initialValue={4} rules={[{ required: true }]}>
              <InputNumber min={1} max={7} className="w-full" />
            </Form.Item>
          </div>
        </Form>
      </Modal>

      <Modal
        title={`Khung CTĐT: ${selectedProgram?.name || ''}`}
        open={Boolean(selectedProgram)}
        onCancel={() => setSelectedProgram(null)}
        footer={null}
        width={820}
      >
        <div className="space-y-4">
          <Form
            form={pcForm}
            layout="inline"
            onFinish={(vals) => addPcMutation.mutate(vals)}
            className="flex flex-wrap gap-2 bg-slate-50 p-3 rounded-lg"
          >
            <Form.Item name="courseId" rules={[{ required: true, message: 'Chọn môn' }]} className="min-w-[260px]">
              <Select
                showSearch
                placeholder="Chọn môn học"
                optionFilterProp="label"
                options={(allCoursesForSelect?.content ?? []).map((c) => ({
                  value: c.id,
                  label: `${c.code} - ${c.name} (${c.credits} TC)`,
                }))}
              />
            </Form.Item>
            <Form.Item name="semesterIndex" initialValue={1} rules={[{ required: true }]}>
              <InputNumber min={1} max={10} addonBefore="Kỳ" className="w-28" />
            </Form.Item>
            <Form.Item name="compulsory" valuePropName="checked" initialValue={true}>
              <Switch checkedChildren="Bắt buộc" unCheckedChildren="Tự chọn" />
            </Form.Item>
            <Button type="primary" htmlType="submit" icon={<PlusOutlined />} loading={addPcMutation.isPending}>
              Gán vào khung
            </Button>
          </Form>

          <Table
            rowKey="id"
            size="small"
            loading={loadingPC}
            columns={pcColumns}
            dataSource={programCourses}
            pagination={false}
          />
        </div>
      </Modal>

      <Modal
        title={editingCourse ? 'Cập nhật Môn học' : 'Thêm Môn học'}
        open={courseModalOpen}
        onCancel={() => setCourseModalOpen(false)}
        onOk={() => courseForm.submit()}
        confirmLoading={saveCourseMutation.isPending}
        width={640}
      >
        <Form form={courseForm} layout="vertical" onFinish={(vals) => saveCourseMutation.mutate(vals)}>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <Form.Item name="code" label="Mã môn học" rules={[{ required: true }]}>
              <Input disabled={Boolean(editingCourse)} />
            </Form.Item>
            <Form.Item name="departmentId" label="Khoa quản lý" rules={[{ required: true }]}>
              <Select showSearch optionFilterProp="label" options={departments.map((d) => ({ value: d.id, label: d.name }))} />
            </Form.Item>
          </div>
          <Form.Item name="name" label="Tên môn học" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <div className="grid grid-cols-3 gap-3">
            <Form.Item name="credits" label="Số tín chỉ" initialValue={3} rules={[{ required: true }]}>
              <InputNumber min={1} max={15} className="w-full" />
            </Form.Item>
            <Form.Item name="theoryHours" label="Giờ lý thuyết" initialValue={30} rules={[{ required: true }]}>
              <InputNumber min={0} className="w-full" />
            </Form.Item>
            <Form.Item name="practiceHours" label="Giờ thực hành" initialValue={30} rules={[{ required: true }]}>
              <InputNumber min={0} className="w-full" />
            </Form.Item>
          </div>
          <Form.Item name="prerequisiteIds" label="Môn học tiên quyết">
            <Select
              mode="multiple"
              allowClear
              showSearch
              optionFilterProp="label"
              placeholder="Chọn các môn tiên quyết (nếu có)"
              options={(allCoursesForSelect?.content ?? [])
                .filter((c) => c.id !== editingCourse?.id)
                .map((c) => ({ value: c.id, label: `${c.code} - ${c.name}` }))}
            />
          </Form.Item>
        </Form>
      </Modal>
    </Card>
  );
};
