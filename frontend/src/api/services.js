import { apiClient } from './client';

export const authApi = {
  login: (data) => apiClient.post('/auth/login', data).then((r) => r.data.data),
  logout: () => apiClient.post('/auth/logout').then((r) => r.data),
  getProfile: () => apiClient.get('/auth/profile').then((r) => r.data.data),
  changePassword: (data) => apiClient.put('/auth/change-password', data).then((r) => r.data),
  sendForgotPasswordOtp: (data) => apiClient.post('/auth/forgot-password/send-otp', data).then((r) => r.data.data),
  verifyOtpAndResetPassword: (data) => apiClient.post('/auth/forgot-password/verify-and-reset', data).then((r) => r.data),
};

export const commonApi = {
  getSemesters: () => apiClient.get('/common/semesters').then((r) => r.data.data),
  getDepartments: () => apiClient.get('/common/departments').then((r) => r.data.data),
  getPrograms: () => apiClient.get('/common/programs').then((r) => r.data.data),
  getCourseDetails: (courseId) => apiClient.get(`/common/courses/${courseId}/details`).then((r) => r.data.data),
};

export const studentApi = {
  getDashboard: (semesterId) =>
    apiClient.get('/student/dashboard', { params: { semesterId } }).then((r) => r.data.data),
  getAvailableClasses: (semesterId) =>
    apiClient.get('/student/registration/available-classes', { params: { semesterId } }).then((r) => r.data.data),
  enroll: (classSectionId) =>
    apiClient.post('/student/registration/enroll', { classSectionId }).then((r) => r.data),
  drop: (classSectionId) =>
    apiClient.post('/student/registration/drop', { classSectionId }).then((r) => r.data),
  getSchedule: (semesterId) =>
    apiClient.get('/student/schedule', { params: { semesterId } }).then((r) => r.data.data),
  getCurriculum: () => apiClient.get('/student/curriculum').then((r) => r.data.data),
  getAcademicResults: () => apiClient.get('/student/academic-results').then((r) => r.data.data),
  getClassSectionGrades: (classSectionId) =>
    apiClient.get(`/student/grades/class-section/${classSectionId}`).then((r) => r.data.data),
  exportTranscriptPdf: () =>
    apiClient.get('/student/grades/export-pdf', { responseType: 'blob' }).then((r) => r.data),
};

export const teacherApi = {
  getDashboard: (semesterId) =>
    apiClient.get('/teacher/dashboard', { params: { semesterId } }).then((r) => r.data.data),
  getClasses: (semesterId) =>
    apiClient.get('/teacher/classes', { params: { semesterId } }).then((r) => r.data.data),
  getSchedule: (semesterId) =>
    apiClient.get('/teacher/schedule', { params: { semesterId } }).then((r) => r.data.data),
  getClassGrades: (classSectionId) =>
    apiClient.get(`/teacher/classes/${classSectionId}/grades`).then((r) => r.data.data),
  updateGradesBatch: (classSectionId, grades) =>
    apiClient.put(`/teacher/classes/${classSectionId}/grades`, { grades }).then((r) => r.data),
  lockGrades: (classSectionId) =>
    apiClient.post(`/teacher/classes/${classSectionId}/lock`).then((r) => r.data),
  exportGradesExcel: (classSectionId) =>
    apiClient.get(`/teacher/classes/${classSectionId}/export-excel`, { responseType: 'blob' }).then((r) => r.data),
};

export const adminApi = {
  getDashboard: () => apiClient.get('/admin/dashboard').then((r) => r.data.data),

  getDepartments: () => apiClient.get('/admin/departments').then((r) => r.data.data),
  createDepartment: (data) => apiClient.post('/admin/departments', data).then((r) => r.data.data),
  updateDepartment: (id, data) => apiClient.put(`/admin/departments/${id}`, data).then((r) => r.data.data),
  deleteDepartment: (id) => apiClient.delete(`/admin/departments/${id}`).then((r) => r.data),

  getPrograms: () => apiClient.get('/admin/programs').then((r) => r.data.data),
  createProgram: (data) => apiClient.post('/admin/programs', data).then((r) => r.data.data),
  getProgramCourses: (programId) =>
    apiClient.get(`/admin/programs/${programId}/courses`).then((r) => r.data.data),
  addProgramCourse: (programId, data) =>
    apiClient.post(`/admin/programs/${programId}/courses`, data).then((r) => r.data.data),
  removeProgramCourse: (programId, programCourseId) =>
    apiClient.delete(`/admin/programs/${programId}/courses/${programCourseId}`).then((r) => r.data),

  getCourses: (params) => apiClient.get('/admin/courses', { params }).then((r) => r.data.data),
  createCourse: (data) => apiClient.post('/admin/courses', data).then((r) => r.data.data),
  updateCourse: (id, data) => apiClient.put(`/admin/courses/${id}`, data).then((r) => r.data.data),
  deleteCourse: (id) => apiClient.delete(`/admin/courses/${id}`).then((r) => r.data),

  getSemesters: () => apiClient.get('/admin/semesters').then((r) => r.data.data),
  createSemester: (data) => apiClient.post('/admin/semesters', data).then((r) => r.data.data),
  toggleRegistration: (id) =>
    apiClient.put(`/admin/semesters/${id}/toggle-registration`).then((r) => r.data.data),
  updateCreditLimits: (id, data) =>
    apiClient.put(`/admin/semesters/${id}/credit-limits`, data).then((r) => r.data.data),

  getStudents: (params) => apiClient.get('/admin/students', { params }).then((r) => r.data.data),
  createStudent: (data) => apiClient.post('/admin/students', data).then((r) => r.data.data),
  updateStudent: (id, data) => apiClient.put(`/admin/students/${id}`, data).then((r) => r.data.data),
  importStudentsExcel: (file) => {
    const formData = new FormData();
    formData.append('file', file);
    return apiClient
      .post('/admin/students/import-excel', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      .then((r) => r.data.data);
  },

  getTeachers: (params) => apiClient.get('/admin/teachers', { params }).then((r) => r.data.data),
  createTeacher: (data) => apiClient.post('/admin/teachers', data).then((r) => r.data.data),
  updateTeacher: (id, data) => apiClient.put(`/admin/teachers/${id}`, data).then((r) => r.data.data),

  getClassSections: (params) => apiClient.get('/admin/class-sections', { params }).then((r) => r.data.data),
  createClassSection: (data) => apiClient.post('/admin/class-sections', data).then((r) => r.data.data),
  deleteClassSection: (id) => apiClient.delete(`/admin/class-sections/${id}`).then((r) => r.data),
  forceEnroll: (classSectionId, studentId) =>
    apiClient.post(`/admin/class-sections/${classSectionId}/force-enroll`, { studentId }).then((r) => r.data),
  forceDrop: (classSectionId, studentId) =>
    apiClient.delete(`/admin/class-sections/${classSectionId}/force-drop/${studentId}`).then((r) => r.data),

  getGrades: (params) => apiClient.get('/admin/grades', { params }).then((r) => r.data.data),
  unlockGrade: (gradeId) => apiClient.put(`/admin/grades/${gradeId}/unlock`).then((r) => r.data),
  getSectionGradesSummary: (params) =>
    apiClient.get('/admin/class-sections/grades-summary', { params }).then((r) => r.data.data),
  getSectionGrades: (classSectionId) =>
    apiClient.get(`/admin/class-sections/${classSectionId}/grades`).then((r) => r.data.data),
  unlockSectionGrades: (classSectionId) =>
    apiClient.put(`/admin/class-sections/${classSectionId}/unlock`).then((r) => r.data),
  lockSectionGrades: (classSectionId) =>
    apiClient.put(`/admin/class-sections/${classSectionId}/lock`).then((r) => r.data),
  updateSectionGrades: (classSectionId, data) =>
    apiClient.put(`/admin/class-sections/${classSectionId}/grades`, data).then((r) => r.data),
};
