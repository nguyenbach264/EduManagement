import React from 'react';
import { ConfigProvider, Spin } from 'antd';
import viVN from 'antd/locale/vi_VN';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { SemesterProvider } from './context/SemesterContext';
import { PortalLayout } from './layouts/PortalLayout';
import { LoginPage } from './pages/LoginPage';
import { ProfilePage } from './pages/ProfilePage';
import { StudentDashboardPage } from './pages/student/StudentDashboardPage';
import { StudentRegistrationPage } from './pages/student/StudentRegistrationPage';
import { StudentSchedulePage } from './pages/student/StudentSchedulePage';
import { StudentGradesPage } from './pages/student/StudentGradesPage';
import { StudentCurriculumPage } from './pages/student/StudentCurriculumPage';
import { TeacherDashboardPage } from './pages/teacher/TeacherDashboardPage';
import { TeacherClassesPage } from './pages/teacher/TeacherClassesPage';
import { TeacherSchedulePage } from './pages/teacher/TeacherSchedulePage';
import { TeacherGradeEntryPage } from './pages/teacher/TeacherGradeEntryPage';
import { AdminDashboardPage } from './pages/admin/AdminDashboardPage';
import { AdminAcademicsPage } from './pages/admin/AdminAcademicsPage';
import { AdminSemestersPage } from './pages/admin/AdminSemestersPage';
import { AdminClassSectionsPage } from './pages/admin/AdminClassSectionsPage';
import { AdminUsersPage } from './pages/admin/AdminUsersPage';
import { AdminGradesPage } from './pages/admin/AdminGradesPage';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

const HomeRedirect = () => {
  const { isAuthenticated, loading, primaryRole } = useAuth();
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Spin size="large" />
      </div>
    );
  }
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  if (primaryRole === 'ROLE_ADMIN') return <Navigate to="/admin/dashboard" replace />;
  if (primaryRole === 'ROLE_TEACHER') return <Navigate to="/teacher/dashboard" replace />;
  return <Navigate to="/student/dashboard" replace />;
};

const ProtectedRoute = ({ allowedRoles, children }) => {
  const { isAuthenticated, loading, user } = useAuth();
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Spin size="large" />
      </div>
    );
  }
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  if (allowedRoles && !allowedRoles.some((r) => user?.roles?.includes(r))) {
    return <Navigate to="/" replace />;
  }
  return <>{children}</>;
};

export const App = () => {
  return (
    <ConfigProvider
      locale={viVN}
      theme={{
        token: {
          colorPrimary: '#1a73e8',
          colorInfo: '#1a73e8',
          borderRadius: 8,
        },
      }}
    >
      <QueryClientProvider client={queryClient}>
        <AuthProvider>
          <SemesterProvider>
            <BrowserRouter>
              <Routes>
                <Route path="/login" element={<LoginPage />} />
                <Route path="/" element={<HomeRedirect />} />

                <Route
                  element={
                    <ProtectedRoute>
                      <PortalLayout />
                    </ProtectedRoute>
                  }
                >
                  <Route path="/profile" element={<ProfilePage />} />

                  {/* Student Portal */}
                  <Route
                    path="/student/dashboard"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_STUDENT']}>
                        <StudentDashboardPage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/student/registration"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_STUDENT']}>
                        <StudentRegistrationPage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/student/schedule"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_STUDENT']}>
                        <StudentSchedulePage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/student/grades"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_STUDENT']}>
                        <StudentGradesPage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/student/curriculum"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_STUDENT']}>
                        <StudentCurriculumPage />
                      </ProtectedRoute>
                    }
                  />

                  {/* Teacher Portal */}
                  <Route
                    path="/teacher/dashboard"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_TEACHER']}>
                        <TeacherDashboardPage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/teacher/classes"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_TEACHER']}>
                        <TeacherClassesPage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/teacher/schedule"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_TEACHER']}>
                        <TeacherSchedulePage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/teacher/classes/:sectionId/grades"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_TEACHER']}>
                        <TeacherGradeEntryPage />
                      </ProtectedRoute>
                    }
                  />

                  {/* Admin Portal */}
                  <Route
                    path="/admin/dashboard"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_ADMIN']}>
                        <AdminDashboardPage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/admin/academics"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_ADMIN']}>
                        <AdminAcademicsPage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/admin/semesters"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_ADMIN']}>
                        <AdminSemestersPage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/admin/class-sections"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_ADMIN']}>
                        <AdminClassSectionsPage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/admin/users"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_ADMIN']}>
                        <AdminUsersPage />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="/admin/grades"
                    element={
                      <ProtectedRoute allowedRoles={['ROLE_ADMIN']}>
                        <AdminGradesPage />
                      </ProtectedRoute>
                    }
                  />
                </Route>

                <Route path="*" element={<Navigate to="/" replace />} />
              </Routes>
            </BrowserRouter>
          </SemesterProvider>
        </AuthProvider>
      </QueryClientProvider>
    </ConfigProvider>
  );
};

export default App;
