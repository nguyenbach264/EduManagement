import React, { useState } from 'react';
import { Alert, Button, Card, Form, Input, Modal, Space, Steps, Tag, Typography, message } from 'antd';
import {
  ArrowLeftOutlined,
  CheckCircleOutlined,
  KeyOutlined,
  LockOutlined,
  LoginOutlined,
  MailOutlined,
  SafetyCertificateOutlined,
  UserOutlined,
} from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { authApi } from '../api/services';
import { getErrorMessage } from '../api/client';
import { useAuth } from '../context/AuthContext';

const { Title, Text } = Typography;

export const LoginPage = () => {
  const { login, isAuthenticated, primaryRole } = useAuth();
  const navigate = useNavigate();
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState(null);

  React.useEffect(() => {
    if (isAuthenticated) {
      if (primaryRole === 'ROLE_ADMIN') {
        navigate('/admin/dashboard', { replace: true });
      } else if (primaryRole === 'ROLE_TEACHER') {
        navigate('/teacher/dashboard', { replace: true });
      } else {
        navigate('/student/dashboard', { replace: true });
      }
    }
  }, [isAuthenticated, primaryRole, navigate]);

  // Forgot Password Modal State
  const [forgotModalOpen, setForgotModalOpen] = useState(false);
  const [forgotStep, setForgotStep] = useState(0); // 0: request OTP, 1: verify & reset
  const [forgotUsername, setForgotUsername] = useState('');
  const [maskedEmail, setMaskedEmail] = useState('');
  const [demoOtp, setDemoOtp] = useState('');
  const [forgotLoading, setForgotLoading] = useState(false);
  const [forgotError, setForgotError] = useState(null);
  const [forgotForm1] = Form.useForm();
  const [forgotForm2] = Form.useForm();

  const onFinish = async (values) => {
    setLoading(true);
    setErrorMsg(null);
    try {
      const profile = await login(values.username.trim(), values.password);
      if (profile.roles.includes('ROLE_ADMIN')) {
        navigate('/admin/dashboard', { replace: true });
      } else if (profile.roles.includes('ROLE_TEACHER')) {
        navigate('/teacher/dashboard', { replace: true });
      } else {
        navigate('/student/dashboard', { replace: true });
      }
    } catch (err) {
      setErrorMsg(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  };

  const fillAccount = (username) => {
    form.setFieldsValue({ username, password: '123' + '456' });
  };

  // Step 1: Send OTP
  const handleSendOtp = async (values) => {
    setForgotLoading(true);
    setForgotError(null);
    try {
      const res = await authApi.sendForgotPasswordOtp({
        identifier: values.usernameOrEmail.trim(),
      });
      setForgotUsername(values.usernameOrEmail.trim());
      setMaskedEmail(res.maskedEmail || 'email liên kết');
      setDemoOtp(res.demoOtp || '');
      message.success('Mã xác thực OTP đã được gửi thành công!');
      setForgotStep(1);
    } catch (err) {
      setForgotError(getErrorMessage(err));
    } finally {
      setForgotLoading(false);
    }
  };

  // Step 2: Verify OTP and Reset Password
  const handleVerifyAndReset = async (values) => {
    if (values.newPassword !== values.confirmPassword) {
      setForgotError('Mật khẩu xác nhận không khớp với mật khẩu mới');
      return;
    }
    setForgotLoading(true);
    setForgotError(null);
    try {
      await authApi.verifyOtpAndResetPassword({
        identifier: forgotUsername,
        otp: values.otp.trim(),
        newPassword: values.newPassword,
      });
      message.success('Mật khẩu đã được đặt lại thành công! Bạn có thể đăng nhập ngay.');
      setForgotModalOpen(false);
      form.setFieldsValue({
        username: forgotUsername,
        password: values.newPassword,
      });
      // Reset forgot state
      setForgotStep(0);
      forgotForm1.resetFields();
      forgotForm2.resetFields();
    } catch (err) {
      setForgotError(getErrorMessage(err));
    } finally {
      setForgotLoading(false);
    }
  };

  const openForgotPasswordModal = () => {
    setForgotStep(0);
    setForgotError(null);
    setDemoOtp('');
    setMaskedEmail('');
    const currentUsername = form.getFieldValue('username');
    if (currentUsername) {
      forgotForm1.setFieldsValue({ usernameOrEmail: currentUsername });
    }
    setForgotModalOpen(true);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#edf4fb] p-4">
      <div className="w-full max-w-4xl grid grid-cols-1 md:grid-cols-12 rounded-2xl overflow-hidden shadow-xl bg-white border border-[#d8e4f2]">
        {/* Left Side: Solid University Blue Branding Panel (NO gradient) */}
        <div className="md:col-span-5 bg-[#1e40af] text-white p-8 flex flex-col justify-between">
          <div>
            <div className="flex items-center gap-3 mb-6">
              <div className="w-11 h-11 rounded-xl bg-white/20 border border-white/30 flex items-center justify-center font-extrabold text-lg text-white">
                EM
              </div>
              <div>
                <div className="text-lg font-bold tracking-wide">EduManagement</div>
                <div className="text-xs text-blue-200">Cổng Thông tin Đào tạo Đại học</div>
              </div>
            </div>

            <h1 className="text-2xl font-bold leading-snug text-white mb-3">
              Hệ thống Quản lý Đào tạo & Tín chỉ
            </h1>
            <p className="text-sm text-blue-100 leading-relaxed">
              Cổng thông tin đào tạo điện tử dành cho Cán bộ, Giảng viên và Sinh viên. Tra cứu học phần, thời khóa biểu và kết quả học tập nhanh chóng, chính xác.
            </p>
          </div>

          <div className="mt-8 space-y-3 text-xs text-blue-100 border-t border-white/20 pt-5">
            <div className="flex items-center gap-2">
              <SafetyCertificateOutlined className="text-sky-300 text-sm" />
              <span>Phân quyền bảo mật cho Sinh viên, Giảng viên & Phòng Đào tạo</span>
            </div>
            <div className="flex items-center gap-2">
              <SafetyCertificateOutlined className="text-sky-300 text-sm" />
              <span>Đăng ký tín chỉ trực tuyến, cảnh báo trùng lịch và kiểm soát sĩ số</span>
            </div>
            <div className="flex items-center gap-2">
              <SafetyCertificateOutlined className="text-sky-300 text-sm" />
              <span>Tra cứu thời khóa biểu toàn năm và bảng điểm chi tiết theo trọng số</span>
            </div>
          </div>
        </div>

        {/* Right Side: Login Form */}
        <div className="md:col-span-7 p-6 sm:p-10 flex flex-col justify-center bg-white">
          <div className="mb-6">
            <Title level={3} className="!mb-1 !text-slate-800">
              Đăng nhập Hệ thống
            </Title>
            <Text type="secondary">Sử dụng tài khoản được cấp để truy cập cổng đào tạo</Text>
          </div>

          {errorMsg && <Alert type="error" showIcon message={errorMsg} className="mb-4" />}

          <Form form={form} layout="vertical" onFinish={onFinish} size="large">
            <Form.Item
              name="username"
              label={<span className="text-xs font-semibold text-slate-700">Tên đăng nhập / Mã SV / Mã GV</span>}
              rules={[{ required: true, message: 'Vui lòng nhập tên đăng nhập' }]}
            >
              <Input prefix={<UserOutlined className="text-slate-400" />} placeholder="Ví dụ: student1, teacher1, admin" />
            </Form.Item>

            <Form.Item
              name="password"
              label={
                <div className="w-full flex items-center justify-between">
                  <span className="text-xs font-semibold text-slate-700">Mật khẩu</span>
                  <button
                    type="button"
                    onClick={openForgotPasswordModal}
                    className="text-xs font-medium text-[#1a73e8] hover:text-blue-700 bg-transparent border-0 cursor-pointer p-0 underline"
                  >
                    Quên mật khẩu?
                  </button>
                </div>
              }
              rules={[{ required: true, message: 'Vui lòng nhập mật khẩu' }]}
            >
              <Input.Password prefix={<LockOutlined className="text-slate-400" />} placeholder="Nhập mật khẩu" />
            </Form.Item>

            <Button
              type="primary"
              htmlType="submit"
              loading={loading}
              icon={<LoginOutlined />}
              block
              className="h-11 font-semibold mt-2 bg-[#1a73e8]"
            >
              Đăng nhập ngay
            </Button>
          </Form>

          {/* Realistic Experience Accounts Box */}
          <Card size="small" className="mt-6 bg-[#f0f6ff] border-[#c2daf7]">
            <div className="text-xs font-semibold text-slate-700 mb-2">
              Tài khoản trải nghiệm mẫu (Mật khẩu mặc định: <Tag color="blue">123456</Tag>):
            </div>
            <Space wrap size="small">
              <Button size="small" onClick={() => fillAccount('student1')}>
                Sinh viên (student1)
              </Button>
              <Button size="small" onClick={() => fillAccount('teacher1')}>
                Giảng viên (teacher1)
              </Button>
              <Button size="small" onClick={() => fillAccount('admin')}>
                Phòng Đào tạo (admin)
              </Button>
            </Space>
          </Card>
        </div>
      </div>

      {/* Forgot Password Modal */}
      <Modal
        title={
          <div className="flex items-center gap-2 text-base font-bold text-slate-800">
            <KeyOutlined className="text-[#1a73e8]" />
            <span>Khôi phục Mật khẩu Tài khoản</span>
          </div>
        }
        open={forgotModalOpen}
        onCancel={() => setForgotModalOpen(false)}
        footer={null}
        destroyOnClose
        centered
        width={480}
      >
        <div className="py-2 space-y-4">
          <Steps
            size="small"
            current={forgotStep}
            items={[
              { title: 'Nhập tài khoản' },
              { title: 'Xác thực OTP & Mật khẩu mới' },
            ]}
          />

          {forgotError && (
            <Alert type="error" showIcon message={forgotError} className="text-xs" />
          )}

          {forgotStep === 0 ? (
            <Form form={forgotForm1} layout="vertical" onFinish={handleSendOtp} requiredMark={false}>
              <div className="text-xs text-slate-600 mb-3 leading-relaxed">
                Nhập tên đăng nhập hoặc mã sinh viên / giảng viên của bạn. Hệ thống sẽ gửi mã xác thực OTP 6 số đến địa chỉ email đã đăng ký.
              </div>

              <Form.Item
                name="usernameOrEmail"
                label={<span className="text-xs font-semibold text-slate-700">Tên đăng nhập hoặc Mã số SV / GV</span>}
                rules={[{ required: true, message: 'Vui lòng nhập tên đăng nhập hoặc mã số' }]}
              >
                <Input
                  prefix={<UserOutlined className="text-slate-400" />}
                  placeholder="Ví dụ: student1 hoặc 20261001"
                  autoFocus
                />
              </Form.Item>

              <div className="flex justify-end gap-2 pt-2">
                <Button onClick={() => setForgotModalOpen(false)}>Hủy bỏ</Button>
                <Button type="primary" htmlType="submit" loading={forgotLoading} className="bg-[#1a73e8]">
                  Gửi mã xác thực OTP
                </Button>
              </div>
            </Form>
          ) : (
            <Form form={forgotForm2} layout="vertical" onFinish={handleVerifyAndReset} requiredMark={false}>
              <Alert
                type="info"
                showIcon
                icon={<MailOutlined />}
                message={
                  <div className="text-xs">
                    Mã xác thực OTP đã được gửi đến email <strong>{maskedEmail}</strong>. Mã có hiệu lực trong 5 phút.
                    {demoOtp && (
                      <div className="mt-1 text-ag-700 font-medium">
                        (Mã thử nghiệm hệ thống: <Tag color="blue" className="font-bold">{demoOtp}</Tag>)
                      </div>
                    )}
                  </div>
                }
                className="mb-3"
              />

              <Form.Item
                name="otp"
                label={<span className="text-xs font-semibold text-slate-700">Mã xác thực OTP (6 chữ số)</span>}
                rules={[
                  { required: true, message: 'Vui lòng nhập mã OTP 6 số' },
                  { len: 6, message: 'Mã OTP phải có đúng 6 chữ số' },
                ]}
              >
                <Input
                  placeholder="Ví dụ: 123456"
                  maxLength={6}
                  className="font-mono text-center tracking-widest text-lg font-bold"
                  autoFocus
                />
              </Form.Item>

              <Form.Item
                name="newPassword"
                label={<span className="text-xs font-semibold text-slate-700">Mật khẩu mới</span>}
                rules={[
                  { required: true, message: 'Vui lòng nhập mật khẩu mới' },
                  { min: 6, message: 'Mật khẩu mới tối thiểu 6 ký tự' },
                ]}
              >
                <Input.Password prefix={<LockOutlined className="text-slate-400" />} placeholder="Nhập ít nhất 6 ký tự" />
              </Form.Item>

              <Form.Item
                name="confirmPassword"
                label={<span className="text-xs font-semibold text-slate-700">Xác nhận mật khẩu mới</span>}
                rules={[{ required: true, message: 'Vui lòng xác nhận mật khẩu mới' }]}
              >
                <Input.Password prefix={<LockOutlined className="text-slate-400" />} placeholder="Nhập lại mật khẩu mới" />
              </Form.Item>

              <div className="flex items-center justify-between gap-2 pt-2">
                <Button
                  icon={<ArrowLeftOutlined />}
                  onClick={() => setForgotStep(0)}
                  disabled={forgotLoading}
                >
                  Quay lại
                </Button>
                <Button type="primary" htmlType="submit" loading={forgotLoading} className="bg-[#1a73e8]">
                  Xác nhận đặt lại mật khẩu
                </Button>
              </div>
            </Form>
          )}
        </div>
      </Modal>
    </div>
  );
};
