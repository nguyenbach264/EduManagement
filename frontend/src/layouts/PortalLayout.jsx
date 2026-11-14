import React, { useState } from 'react';
import { Avatar, Badge, Button, Drawer, Dropdown, Menu, Select, Tag } from 'antd';
import {
  ApartmentOutlined,
  AppstoreAddOutlined,
  BookOutlined,
  CalendarOutlined,
  CheckSquareOutlined,
  DashboardOutlined,
  EditOutlined,
  LogoutOutlined,
  MenuFoldOutlined,
  MenuOutlined,
  MenuUnfoldOutlined,
  ReadOutlined,
  ScheduleOutlined,
  TeamOutlined,
  TrophyOutlined,
  UnlockOutlined,
  UserOutlined,
} from '@ant-design/icons';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useSemester } from '../context/SemesterContext';

export const PortalLayout = () => {
  const { user, primaryRole, logout } = useAuth();
  const { semesters, selectedSemesterId, selectedSemester, setSelectedSemesterId } = useSemester();
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  const roleLabel =
    primaryRole === 'ROLE_ADMIN'
      ? 'Phòng Đào tạo'
      : primaryRole === 'ROLE_TEACHER'
      ? 'Giảng viên'
      : 'Sinh viên';

  const menuItems =
    primaryRole === 'ROLE_STUDENT'
      ? [
          { key: '/student/dashboard', icon: <DashboardOutlined />, label: 'Tổng quan Sinh viên' },
          { key: '/student/registration', icon: <AppstoreAddOutlined />, label: 'Đăng ký Tín chỉ' },
          { key: '/student/schedule', icon: <CalendarOutlined />, label: 'Thời khóa biểu' },
          { key: '/student/grades', icon: <TrophyOutlined />, label: 'Kết quả học tập & CPA' },
          { key: '/student/curriculum', icon: <ReadOutlined />, label: 'Chương trình đào tạo' },
          { key: '/profile', icon: <UserOutlined />, label: 'Hồ sơ cá nhân' },
        ]
      : primaryRole === 'ROLE_TEACHER'
      ? [
          { key: '/teacher/dashboard', icon: <DashboardOutlined />, label: 'Tổng quan Giảng viên' },
          { key: '/teacher/classes', icon: <BookOutlined />, label: 'Lớp dạy & Nhập điểm' },
          { key: '/teacher/schedule', icon: <CalendarOutlined />, label: 'Lịch giảng dạy tuần' },
          { key: '/profile', icon: <UserOutlined />, label: 'Hồ sơ cá nhân' },
        ]
      : [
          { key: '/admin/dashboard', icon: <DashboardOutlined />, label: 'Dashboard Toàn trường' },
          { key: '/admin/academics', icon: <ApartmentOutlined />, label: 'Khoa / Ngành / Môn học' },
          { key: '/admin/semesters', icon: <ScheduleOutlined />, label: 'Học kỳ & Đợt đăng ký' },
          { key: '/admin/class-sections', icon: <CheckSquareOutlined />, label: 'Lớp học phần & TKB' },
          { key: '/admin/users', icon: <TeamOutlined />, label: 'Quản lý Sinh viên & Cán bộ' },
          { key: '/admin/grades', icon: <UnlockOutlined />, label: 'Sổ điểm & Khóa điểm' },
          { key: '/profile', icon: <UserOutlined />, label: 'Hồ sơ cá nhân' },
        ];

  const userDropdownItems = [
    {
      key: 'profile',
      icon: <EditOutlined />,
      label: 'Thông tin & Đổi mật khẩu',
      onClick: () => navigate('/profile'),
    },
    { type: 'divider' },
    {
      key: 'logout',
      icon: <LogoutOutlined />,
      label: 'Đăng xuất',
      danger: true,
      onClick: handleLogout,
    },
  ];

  const renderSidebar = (isCollapsed) => (
    <div className="h-full flex flex-col justify-between bg-[#0f2942] text-white">
      <div>
        <div className={`h-16 px-4 flex items-center border-b border-white/10 bg-[#0c2136] ${isCollapsed ? 'justify-center px-0' : 'gap-3'}`}>
          <div className="w-9 h-9 rounded-lg bg-[#1a73e8] flex items-center justify-center font-extrabold text-white shadow-xs shrink-0 text-sm">
            EM
          </div>
          {!isCollapsed && (
            <div className="min-w-0">
              <div className="font-bold text-sm tracking-wide text-white truncate">EduManagement</div>
              <div className="text-xs text-blue-200 truncate">Cổng Đào tạo Đại học</div>
            </div>
          )}
        </div>

        <Menu
          theme="dark"
          mode="inline"
          inlineCollapsed={isCollapsed}
          selectedKeys={[location.pathname]}
          items={isCollapsed ? menuItems.map((m) => ({ ...m, label: '' })) : menuItems}
          onClick={({ key }) => {
            navigate(key);
            setMobileOpen(false);
          }}
          style={{ background: 'transparent', borderRight: 0, marginTop: 8 }}
        />
      </div>

      {!isCollapsed && (
        <div className="m-3 p-3 rounded-lg bg-[#163a63] border border-blue-400/20 text-xs space-y-1">
          <div className="text-blue-200 font-medium">Học kỳ hiện tại</div>
          <div className="font-bold text-white truncate">
            {selectedSemester ? selectedSemester.name : 'Đang tải...'}
          </div>
          <div className="flex items-center gap-1.5 pt-0.5">
            <Badge status={selectedSemester?.registerOpen ? 'processing' : 'default'} />
            <span className="text-blue-100">
              {selectedSemester?.registerOpen ? 'Cổng đăng ký tín chỉ: MỞ' : 'Cổng đăng ký tín chỉ: ĐÓNG'}
            </span>
          </div>
        </div>
      )}
    </div>
  );

  return (
    <div className="h-screen w-screen overflow-hidden flex bg-[#f4f7fb]">
      {/* Desktop Fixed Sidebar */}
      <aside
        style={{ width: collapsed ? 80 : 256, transition: 'width 0.2s' }}
        className="hidden lg:flex flex-col h-screen shrink-0 z-30 shadow-md border-r border-slate-200"
      >
        {renderSidebar(collapsed)}
      </aside>

      {/* Mobile Drawer */}
      <Drawer
        placement="left"
        open={mobileOpen}
        onClose={() => setMobileOpen(false)}
        width={260}
        styles={{ body: { padding: 0 } }}
        className="lg:hidden"
      >
        {renderSidebar(false)}
      </Drawer>

      {/* Main Area: Fixed Header + Independently Scrolling Content */}
      <div className="flex-1 flex flex-col h-screen overflow-hidden min-w-0">
        {/* Fixed Navbar / Top Header */}
        <header className="h-16 shrink-0 bg-white border-b border-slate-200 px-4 md:px-6 flex items-center z-20 shadow-xs">
          <div className="max-w-[1440px] mx-auto w-full flex items-center justify-between gap-3">
            <div className="flex items-center gap-3 min-w-0">
              <Button
                type="text"
                icon={<MenuOutlined />}
                onClick={() => setMobileOpen(true)}
                className="lg:hidden"
              />
              <Button
                type="text"
                icon={collapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />}
                onClick={() => setCollapsed(!collapsed)}
                className="hidden lg:inline-flex"
              />
              <div className="min-w-0">
                <div className="text-sm md:text-base font-bold text-slate-800 truncate">
                  Cổng Thông tin Đào tạo & Quản lý Tín chỉ
                </div>
                <div className="text-xs text-slate-500 hidden sm:block truncate">
                  {primaryRole === 'ROLE_STUDENT'
                    ? `${user?.fullName || ''} • ${user?.studentCode || user?.username || ''}`
                    : primaryRole === 'ROLE_ADMIN'
                    ? `${user?.fullName || ''} • ${user?.username || ''}`
                    : `${user?.fullName || ''} • ${user?.teacherCode || user?.username || ''}`}
                </div>
              </div>
            </div>

            <div className="flex items-center gap-2 md:gap-3 shrink-0">
              <Dropdown menu={{ items: userDropdownItems }} trigger={['click']} placement="bottomRight">
                <button
                  type="button"
                  className="flex items-center gap-2 px-2.5 py-1.5 rounded-full hover:bg-blue-50 transition-colors border border-slate-200 bg-white cursor-pointer shrink-0"
                >
                  <Avatar size="small" style={{ backgroundColor: '#1a73e8' }}>
                    {user?.fullName?.charAt(0)?.toUpperCase() || 'U'}
                  </Avatar>
                  <span className="text-xs md:text-sm font-semibold text-slate-800 whitespace-nowrap">
                    {user?.fullName}
                  </span>
                </button>
              </Dropdown>
            </div>
          </div>
        </header>

        {/* Independently Scrollable Main Page Content */}
        <main className="flex-1 overflow-y-auto px-4 md:px-6 py-4 md:py-6 bg-[#f4f7fb]">
          <div className="max-w-[1440px] mx-auto pb-10">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
};