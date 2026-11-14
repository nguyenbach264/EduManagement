import React, { useState } from 'react';
import { Button, Card, DatePicker, Form, Input, InputNumber, Modal, Select, Space, Switch, Table, Tag, Tooltip, message } from 'antd';
import { EditOutlined, PlusOutlined, SettingOutlined } from '@ant-design/icons';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { adminApi } from '../../api/services';
import { getErrorMessage } from '../../api/client';
import { useSemester } from '../../context/SemesterContext';

export const AdminSemestersPage = () => {
  const queryClient = useQueryClient();
  const { reloadSemesters } = useSemester();
  const [modalOpen, setModalOpen] = useState(false);
  const [limitsModalOpen, setLimitsModalOpen] = useState(false);
  const [selectedSemesterForLimits, setSelectedSemesterForLimits] = useState(null);
  const [form] = Form.useForm();
  const [limitsForm] = Form.useForm();

  const { data: semesters = [], isLoading } = useQuery({
    queryKey: ['admin-semesters'],
    queryFn: adminApi.getSemesters,
  });

  const toggleMutation = useMutation({
    mutationFn: (id) => adminApi.toggleRegistration(id),
    onSuccess: () => {
      message.success('Đã cập nhật trạng thái cổng đăng ký tín chỉ');
      queryClient.invalidateQueries({ queryKey: ['admin-semesters'] });
      reloadSemesters();
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const createMutation = useMutation({
    mutationFn: (vals) => adminApi.createSemester(vals),
    onSuccess: () => {
      message.success('Tạo học kỳ mới thành công');
      setModalOpen(false);
      form.resetFields();
      queryClient.invalidateQueries({ queryKey: ['admin-semesters'] });
      reloadSemesters();
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const updateLimitsMutation = useMutation({
    mutationFn: ({ id, data }) => adminApi.updateCreditLimits(id, data),
    onSuccess: () => {
      message.success('Cập nhật giới hạn tín chỉ thành công');
      setLimitsModalOpen(false);
      limitsForm.resetFields();
      queryClient.invalidateQueries({ queryKey: ['admin-semesters'] });
      reloadSemesters();
    },
    onError: (e) => message.error(getErrorMessage(e)),
  });

  const handleOpenLimitsModal = (record) => {
    setSelectedSemesterForLimits(record);
    limitsForm.setFieldsValue({
      minCredits: record.minCredits ?? 12,
      maxCredits: record.maxCredits ?? 24,
    });
    setLimitsModalOpen(true);
  };

  const columns = [
    { title: 'Mã HK', dataIndex: 'code', width: 100, render: (v) => <strong className="text-ag-700">{v}</strong> },
    { title: 'Tên học kỳ', dataIndex: 'name' },
    { title: 'Năm học', dataIndex: 'academicYear', width: 120 },
    {
      title: 'Thời gian',
      key: 'dates',
      width: 190,
      render: (_, r) => <span className="text-xs">{r.startDate} → {r.endDate}</span>,
    },
    {
      title: 'Giới hạn TC',
      key: 'credits',
      width: 160,
      render: (_, r) => (
        <Tooltip title="Bấm để chỉnh sửa giới hạn tín chỉ">
          <button
            type="button"
            onClick={() => handleOpenLimitsModal(r)}
            className="cursor-pointer border-0 bg-transparent p-0 hover:opacity-80 flex items-center gap-1"
          >
            <Tag color="blue" className="font-semibold text-xs py-0.5">
              {r.minCredits} - {r.maxCredits} TC
            </Tag>
            <EditOutlined className="text-blue-500 text-xs" />
          </button>
        </Tooltip>
      ),
    },
    {
      title: 'Cổng ĐKTC',
      key: 'registerOpen',
      width: 140,
      render: (_, r) => (
        <Switch
          checked={r.registerOpen}
          checkedChildren="Đang MỞ"
          unCheckedChildren="Đang đóng"
          loading={toggleMutation.isPending}
          onChange={() => toggleMutation.mutate(r.id)}
        />
      ),
    },
  ];

  return (
    <div className="space-y-4">
      <Card
        className="shadow-sm"
        title="Quản lý Học kỳ & Đóng/Mở Cổng Đăng ký Tín chỉ"
        extra={
          <Button type="primary" icon={<PlusOutlined />} onClick={() => setModalOpen(true)}>
            Tạo học kỳ mới
          </Button>
        }
        styles={{ body: { padding: 0 } }}
      >
        <Table
          rowKey="id"
          loading={isLoading}
          columns={columns}
          dataSource={semesters}
          scroll={{ x: 800 }}
          pagination={false}
        />
      </Card>

      {/* Modal Cấu hình Giới hạn Tín chỉ */}
      <Modal
        title={`Cấu hình Giới hạn Tín chỉ — ${selectedSemesterForLimits?.code || ''} (${selectedSemesterForLimits?.name || ''})`}
        open={limitsModalOpen}
        onCancel={() => setLimitsModalOpen(false)}
        onOk={() => limitsForm.submit()}
        confirmLoading={updateLimitsMutation.isPending}
      >
        <div className="text-xs text-slate-500 mb-4">
          Quy định số tín chỉ tối thiểu và tối đa sinh viên được phép đăng ký trong học kỳ này.
        </div>
        <Form
          form={limitsForm}
          layout="vertical"
          onFinish={(values) => {
            if (values.minCredits > values.maxCredits) {
              message.error('Số tín chỉ tối thiểu không được lớn hơn tối đa');
              return;
            }
            updateLimitsMutation.mutate({
              id: selectedSemesterForLimits.id,
              data: values,
            });
          }}
        >
          <div className="grid grid-cols-2 gap-4">
            <Form.Item
              name="minCredits"
              label="Số tín chỉ tối thiểu"
              rules={[
                { required: true, message: 'Vui lòng nhập TC tối thiểu' },
                { type: 'number', min: 0, message: 'TC tối thiểu >= 0' },
              ]}
            >
              <InputNumber min={0} max={30} className="w-full" placeholder="Ví dụ: 12" />
            </Form.Item>
            <Form.Item
              name="maxCredits"
              label="Số tín chỉ tối đa"
              rules={[
                { required: true, message: 'Vui lòng nhập TC tối đa' },
                { type: 'number', min: 1, message: 'TC tối đa >= 1' },
              ]}
            >
              <InputNumber min={1} max={50} className="w-full" placeholder="Ví dụ: 24" />
            </Form.Item>
          </div>
        </Form>
      </Modal>

      {/* Modal Tạo học kỳ mới */}
      <Modal
        title="Tạo Học kỳ mới"
        open={modalOpen}
        onCancel={() => setModalOpen(false)}
        onOk={() => form.submit()}
        confirmLoading={createMutation.isPending}
      >
        <Form
          form={form}
          layout="vertical"
          onFinish={(vals) => {
            createMutation.mutate({
              ...vals,
              startDate: vals.startDate.format('YYYY-MM-DD'),
              endDate: vals.endDate.format('YYYY-MM-DD'),
            });
          }}
        >
          <div className="grid grid-cols-2 gap-3">
            <Form.Item name="code" label="Mã học kỳ (vd: 20262)" rules={[{ required: true }]}>
              <Input />
            </Form.Item>
            <Form.Item name="academicYear" label="Năm học (vd: 2026-2027)" rules={[{ required: true }]}>
              <Input />
            </Form.Item>
          </div>
          <Form.Item name="name" label="Tên học kỳ" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <div className="grid grid-cols-3 gap-3">
            <Form.Item name="semesterNumber" label="Loại học kỳ" initialValue={1} rules={[{ required: true }]}>
              <Select
                options={[
                  { value: 1, label: '1 - Học kỳ 1 (Kỳ chính, 4 tháng)' },
                  { value: 2, label: '2 - Học kỳ 2 (Kỳ chính, 4 tháng)' },
                  { value: 3, label: '3 - Học kỳ Xuân (Kỳ phụ, 2 tháng)' },
                  { value: 4, label: '4 - Học kỳ 3 (Kỳ chính, 4 tháng)' },
                  { value: 5, label: '5 - Học kỳ 4 (Kỳ chính, 4 tháng)' },
                  { value: 6, label: '6 - Học kỳ Hè (Kỳ phụ, 2 tháng)' },
                ]}
              />
            </Form.Item>
            <Form.Item name="minCredits" label="TC tối thiểu" initialValue={12} rules={[{ required: true }]}>
              <InputNumber min={0} className="w-full" />
            </Form.Item>
            <Form.Item name="maxCredits" label="TC tối đa" initialValue={24} rules={[{ required: true }]}>
              <InputNumber min={1} className="w-full" />
            </Form.Item>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Form.Item name="startDate" label="Ngày bắt đầu" rules={[{ required: true }]}>
              <DatePicker className="w-full" />
            </Form.Item>
            <Form.Item name="endDate" label="Ngày kết thúc" rules={[{ required: true }]}>
              <DatePicker className="w-full" />
            </Form.Item>
          </div>
          <Form.Item name="registerOpen" label="Mở đăng ký ngay" valuePropName="checked" initialValue={false}>
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};
