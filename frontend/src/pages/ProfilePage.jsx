import React, { useState } from 'react';
import { Avatar, Button, Card, Divider, Form, Input, message, Spin, Tag } from 'antd';
import {
  ApartmentOutlined,
  EnvironmentOutlined,
  IdcardOutlined,
  LockOutlined,
  SafetyCertificateOutlined,
  UserOutlined,
} from '@ant-design/icons';
import { useQuery } from '@tanstack/react-query';
import { authApi } from '../api/services';
import { getErrorMessage } from '../api/client';
import { useAuth } from '../context/AuthContext';

// Clean Label & Textview Pair component as requested
const TextViewItem = ({ label, value, icon, tagColor, bold = false }) => (
  <div className="bg-slate-50/70 border border-slate-200/90 rounded-lg p-3 transition-colors hover:bg-blue-50/20">
    <div className="text-[11px] font-semibold text-slate-500 uppercase tracking-wide flex items-center gap-1.5">
      {icon && <span className="text-ag-600 text-xs">{icon}</span>}
      <span>{label}</span>
    </div>
    <div className="mt-1.5 text-sm min-h-[22px]">
      {tagColor ? (
        <Tag color={tagColor} className="m-0 font-semibold px-2 py-0.5">
          {value || 'Chưa phân loại'}
        </Tag>
      ) : (
        <span className={`${bold ? 'font-bold text-slate-900' : 'font-medium text-slate-800'}`}>
          {value || <span className="text-slate-400 font-normal italic">Chưa cập nhật</span>}
        </span>
      )}
    </div>
  </div>
);

export const ProfilePage = () => {
  const { user: authUser } = useAuth();
  const [form] = Form.useForm();
  const [submitting, setSubmitting] = useState(false);

  const { data: profile, isLoading } = useQuery({
    queryKey: ['user-profile'],
    queryFn: () => authApi.getProfile(),
    initialData: authUser,
  });

  const onChangePassword = async (values) => {
    if (values.newPassword !== values.confirmPassword) {
      message.error('Mật khẩu xác nhận không khớp');
      return;
    }
    setSubmitting(true);
    try {
      await authApi.changePassword({
        currentPassword: values.currentPassword,
        newPassword: values.newPassword,
      });
      message.success('Đổi mật khẩu thành công');
      form.resetFields();
    } catch (err) {
      message.error(getErrorMessage(err));
    } finally {
      setSubmitting(false);
    }
  };

  const isStudent = profile?.roles?.includes('ROLE_STUDENT');
  const isTeacher = profile?.roles?.includes('ROLE_TEACHER');

  if (isLoading) {
    return (
      <div className="py-20 flex justify-center">
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div className="space-y-5">
      {/* Top Banner Info Card */}
      <Card className="shadow-xs border border-slate-200 bg-white" styles={{ body: { padding: 20 } }}>
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <Avatar size={64} style={{ backgroundColor: '#1a73e8', fontSize: 24, fontWeight: 'bold' }}>
              {profile?.fullName?.charAt(0)?.toUpperCase() || 'U'}
            </Avatar>
            <div>
              <div className="flex items-center gap-2 flex-wrap">
                <h1 className="m-0 text-xl font-bold text-slate-900">{profile?.fullName}</h1>
                <Tag color="blue" className="font-semibold">
                  {isStudent ? 'Sinh viên chính quy' : isTeacher ? 'Giảng viên' : 'Quản trị viên'}
                </Tag>
                {profile?.className && (
                  <Tag color="cyan" className="font-medium">
                    Lớp: {profile.className}
                  </Tag>
                )}
              </div>
              <div className="text-xs text-slate-500 mt-1 flex items-center gap-3 flex-wrap">
                <span>Mã số: <strong className="text-slate-800">{profile?.studentCode || profile?.teacherCode || profile?.username}</strong></span>
                <span>•</span>
                <span>Khoa: <strong className="text-slate-800">{profile?.departmentName || 'Khoa Công nghệ Thông tin'}</strong></span>
                {profile?.programName && (
                  <>
                    <span>•</span>
                    <span>Ngành: <strong className="text-slate-800">{profile.programName}</strong></span>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-5">
        {/* Left Column: Full Label-Textview Details */}
        <div className="lg:col-span-8 space-y-5">
          {/* Academic & Organizational Details */}
          <Card
            className="shadow-xs border border-slate-200"
            title={
              <span className="flex items-center gap-2 font-bold text-slate-800">
                <ApartmentOutlined className="text-ag-600" /> Thông tin Đào tạo & Khoa / Ngành
              </span>
            }
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
              <TextViewItem
                label="Khoa / Viện chủ quản"
                value={profile?.departmentName || 'Khoa Công nghệ Thông tin'}
                bold
              />
              <TextViewItem
                label="Ngành đào tạo"
                value={profile?.programName || 'Công nghệ Thông tin'}
                bold
              />
              {isStudent && (
                <>
                  <TextViewItem
                    label="Lớp sinh hoạt"
                    value={profile?.className}
                    tagColor="blue"
                  />
                  <TextViewItem
                    label="Khóa tuyển sinh"
                    value={profile?.cohort ? `Khóa ${profile.cohort}` : 'Khóa K16'}
                  />
                  <TextViewItem
                    label="Trạng thái học tập"
                    value={profile?.academicStatus === 'STUDYING' ? 'Đang học tập bình thường' : profile?.academicStatus}
                    tagColor="green"
                  />
                  <TextViewItem
                    label="Hệ đào tạo"
                    value="Đại học chính quy (4.5 năm)"
                  />
                </>
              )}
              {isTeacher && (
                <>
                  <TextViewItem
                    label="Học vị / Học hàm"
                    value={profile?.academicTitle || profile?.academicRank || 'Tiến sĩ'}
                    bold
                  />
                  <TextViewItem
                    label="Văn phòng bộ môn"
                    value={profile?.officeAddress || 'Phòng 402 - Tòa nhà A1'}
                  />
                </>
              )}
            </div>
          </Card>

          {/* Personal & Demographics Details */}
          <Card
            className="shadow-xs border border-slate-200"
            title={
              <span className="flex items-center gap-2 font-bold text-slate-800">
                <IdcardOutlined className="text-ag-600" /> Thông tin Nhân thân & Địa chỉ cư trú
              </span>
            }
          >
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
              <TextViewItem
                label="Ngày sinh"
                value={profile?.dateOfBirth ? new Date(profile.dateOfBirth).toLocaleDateString('vi-VN') : '15/01/2003'}
              />
              <TextViewItem
                label="Giới tính"
                value={profile?.gender || 'Nam'}
              />
              <TextViewItem
                label="Tỉnh / Thành phố (34 tỉnh thành mới)"
                value={profile?.province || 'Thành phố Hà Nội'}
                bold
              />
              <TextViewItem
                label="Số điện thoại cá nhân"
                value={profile?.phone || '0912 345 678'}
              />
              <div className="sm:col-span-2">
                <TextViewItem
                  label="Địa chỉ thường trú cụ thể"
                  value={profile?.address || 'Số 1, Đường Giải Phóng, Phường Bách Khoa, Thành phố Hà Nội'}
                  icon={<EnvironmentOutlined />}
                />
              </div>
            </div>
          </Card>
        </div>

        {/* Right Column: Account Security & Password Change */}
        <div className="lg:col-span-4 space-y-5">
          <Card
            className="shadow-xs border border-slate-200"
            title={
              <span className="flex items-center gap-2 font-bold text-slate-800">
                <SafetyCertificateOutlined className="text-ag-600" /> Tài khoản & Đăng nhập
              </span>
            }
          >
            <div className="space-y-3">
              <TextViewItem label="Tên đăng nhập" value={profile?.username} bold />
              <TextViewItem label="Email liên kết" value={profile?.email} />
            </div>
          </Card>

          <Card
            className="shadow-xs border border-slate-200"
            title={
              <span className="flex items-center gap-2 font-bold text-slate-800">
                <LockOutlined className="text-ag-600" /> Đổi mật khẩu
              </span>
            }
          >
            <Form form={form} layout="vertical" onFinish={onChangePassword} requiredMark={false}>
              <Form.Item
                name="currentPassword"
                label={<span className="text-xs font-semibold text-slate-700">Mật khẩu hiện tại</span>}
                rules={[{ required: true, message: 'Vui lòng nhập mật khẩu hiện tại' }]}
              >
                <Input.Password placeholder="••••••••" />
              </Form.Item>
              <Form.Item
                name="newPassword"
                label={<span className="text-xs font-semibold text-slate-700">Mật khẩu mới</span>}
                rules={[
                  { required: true, message: 'Vui lòng nhập mật khẩu mới' },
                  { min: 6, message: 'Mật khẩu mới tối thiểu 6 ký tự' },
                ]}
              >
                <Input.Password placeholder="••••••••" />
              </Form.Item>
              <Form.Item
                name="confirmPassword"
                label={<span className="text-xs font-semibold text-slate-700">Xác nhận mật khẩu mới</span>}
                rules={[{ required: true, message: 'Vui lòng xác nhận lại mật khẩu mới' }]}
              >
                <Input.Password placeholder="••••••••" />
              </Form.Item>
              <Button type="primary" htmlType="submit" loading={submitting} block className="mt-2">
                Cập nhật mật khẩu
              </Button>
            </Form>
          </Card>
        </div>
      </div>
    </div>
  );
};