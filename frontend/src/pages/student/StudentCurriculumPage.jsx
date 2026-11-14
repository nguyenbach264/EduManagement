import React, { useMemo, useState } from 'react';
import { Button, Card, Collapse, Descriptions, Modal, Progress, Spin, Table, Tag } from 'antd';
import {
  BookOutlined,
  CheckCircleOutlined,
  ClockCircleOutlined,
  InfoCircleOutlined,
  MailOutlined,
  PhoneOutlined,
  ReadOutlined,
  TeamOutlined,
} from '@ant-design/icons';
import { useQuery } from '@tanstack/react-query';
import { commonApi, studentApi } from '../../api/services';

export const StudentCurriculumPage = () => {
  const [selectedCourseId, setSelectedCourseId] = useState(null);
  const [modalOpen, setModalOpen] = useState(false);

  const { data: courses = [], isLoading } = useQuery({
    queryKey: ['student-curriculum'],
    queryFn: studentApi.getCurriculum,
  });

  const { data: courseDetail, isLoading: isLoadingDetail } = useQuery({
    queryKey: ['course-detail', selectedCourseId],
    queryFn: () => commonApi.getCourseDetails(selectedCourseId),
    enabled: Boolean(selectedCourseId && modalOpen),
  });

  const stats = useMemo(() => {
    const totalCredits = courses.reduce((acc, c) => acc + c.credits, 0);
    const passedCredits = courses
      .filter((c) => c.completionStatus === 'PASSED')
      .reduce((acc, c) => acc + c.credits, 0);
    const percent = totalCredits > 0 ? Math.round((passedCredits / totalCredits) * 100) : 0;
    return { totalCredits, passedCredits, percent };
  }, [courses]);

  const bySemester = useMemo(() => {
    const map = {};
    for (const c of courses) {
      if (!map[c.semesterIndex]) map[c.semesterIndex] = [];
      map[c.semesterIndex].push(c);
    }
    return Object.entries(map).sort(([a], [b]) => Number(a) - Number(b));
  }, [courses]);

  const handleOpenDetail = (courseId) => {
    setSelectedCourseId(courseId);
    setModalOpen(true);
  };

  const columns = [
    {
      title: 'Mã môn',
      dataIndex: 'courseCode',
      key: 'courseCode',
      width: 120,
      render: (v, r) => (
        <button
          type="button"
          onClick={() => handleOpenDetail(r.courseId)}
          className="font-bold text-ag-600 hover:text-ag-700 bg-transparent border-0 cursor-pointer p-0 underline text-left"
        >
          {v}
        </button>
      ),
    },
    {
      title: 'Tên học phần',
      dataIndex: 'courseName',
      key: 'courseName',
      render: (text, r) => (
        <div>
          <button
            type="button"
            onClick={() => handleOpenDetail(r.courseId)}
            className="font-semibold text-slate-800 hover:text-ag-600 text-left bg-transparent border-0 cursor-pointer p-0 text-sm leading-snug"
          >
            {text}
          </button>
          {r.prerequisites && r.prerequisites.length > 0 && (
            <div className="text-[11px] text-amber-700 mt-0.5">
              Tiên quyết: {r.prerequisites.join('; ')}
            </div>
          )}
        </div>
      ),
    },
    {
      title: 'Số TC',
      dataIndex: 'credits',
      key: 'credits',
      width: 70,
      align: 'center',
      render: (v) => <span className="font-bold text-slate-800">{v}</span>,
    },
    {
      title: 'Loại HP',
      dataIndex: 'compulsory',
      key: 'compulsory',
      width: 100,
      align: 'center',
      render: (v) => <Tag color={v ? 'geekblue' : 'default'}>{v ? 'Bắt buộc' : 'Tự chọn'}</Tag>,
    },
    {
      title: 'Điểm cao nhất',
      key: 'score',
      width: 120,
      align: 'center',
      render: (_, r) =>
        r.bestScore10 != null ? (
          <span className="text-sm">
            <strong className="text-slate-900">{Number(r.bestScore10).toFixed(1)}</strong>{' '}
            <Tag color={r.bestScore10 >= 8.5 ? 'green' : r.bestScore10 >= 7 ? 'blue' : 'orange'} className="ml-1">
              {r.letterGrade}
            </Tag>
          </span>
        ) : (
          <span className="text-slate-400">—</span>
        ),
    },
    {
      title: 'Tiến độ',
      dataIndex: 'completionStatus',
      key: 'completionStatus',
      width: 120,
      align: 'center',
      render: (status) => {
        if (status === 'PASSED') return <Tag color="success">Đã tích lũy</Tag>;
        if (status === 'ENROLLED') return <Tag color="processing">Đang học</Tag>;
        return <Tag color="default">Chưa học</Tag>;
      },
    },
  ];

  if (isLoading) {
    return (
      <div className="py-20 flex justify-center">
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Overview Banner */}
      <Card className="shadow-xs border border-slate-200 bg-white" styles={{ body: { padding: 18 } }}>
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-11 h-11 rounded-lg bg-blue-50 text-ag-600 flex items-center justify-center text-xl shrink-0">
              <ReadOutlined />
            </div>
            <div>
              <h1 className="m-0 text-base md:text-lg font-bold text-slate-900">
                Chương trình đào tạo chuẩn — Khung 140 Tín chỉ
              </h1>
              <div className="text-xs text-slate-500 mt-0.5">
                Khung đào tạo chia thành 8 học kỳ chuẩn. Kỳ thứ 8 gồm Thực tập doanh nghiệp (6 TC) & Đồ án tốt nghiệp (9 TC).
              </div>
            </div>
          </div>
          <div className="w-full sm:w-72">
            <div className="flex justify-between text-xs text-slate-600 mb-1">
              <span>Tiến độ tích lũy:</span>
              <strong className="text-ag-600">
                {stats.passedCredits} / {stats.totalCredits || 140} TC ({stats.percent}%)
              </strong>
            </div>
            <Progress percent={stats.percent} strokeColor="#1a73e8" />
          </div>
        </div>
      </Card>

      {/* 8 Semesters Collapse Accordion */}
      <Collapse
        defaultActiveKey={bySemester.map(([sem]) => sem)}
        className="bg-white border border-slate-200"
        items={bySemester.map(([semIndex, list]) => {
          const isSemester8 = semIndex === '8';
          const semCredits = list.reduce((s, c) => s + c.credits, 0);
          const passedCount = list.filter((c) => c.completionStatus === 'PASSED').length;

          return {
            key: semIndex,
            label: (
              <div className="flex items-center justify-between pr-2 flex-wrap gap-2">
                <div className="flex items-center gap-2">
                  <span className="font-bold text-slate-800 text-sm">
                    {isSemester8 ? 'Học kỳ 8 (Kỳ tốt nghiệp & Thực tập chuyên nghiệp)' : `Học kỳ ${semIndex}`}
                  </span>
                  {isSemester8 && (
                    <Tag color="purple" className="m-0 font-medium">
                      Chung cho tất cả các ngành
                    </Tag>
                  )}
                </div>
                <div className="text-xs text-slate-500 flex items-center gap-3">
                  <span>
                    Đạt: <strong>{passedCount}/{list.length}</strong> môn
                  </span>
                  <span>•</span>
                  <span>
                    Tổng số: <strong className="text-ag-700">{semCredits} tín chỉ</strong>
                  </span>
                </div>
              </div>
            ),
            children: (
              <Table
                rowKey="courseId"
                columns={columns}
                dataSource={list}
                pagination={false}
                size="small"
                scroll={{ x: 800 }}
                onRow={(r) => ({
                  onClick: () => handleOpenDetail(r.courseId),
                  className: 'cursor-pointer hover:bg-blue-50/40 transition-colors',
                })}
              />
            ),
          };
        })}
      />

      {/* Course Detail Modal as requested in Requirement 2 */}
      <Modal
        title={
          <div className="flex items-center gap-2 text-slate-800">
            <BookOutlined className="text-ag-600" />
            <span>Thông tin chi tiết học phần: {courseDetail?.name || 'Đang tải...'}</span>
          </div>
        }
        open={modalOpen}
        onCancel={() => setModalOpen(false)}
        footer={[
          <Button key="close" type="primary" onClick={() => setModalOpen(false)}>
            Đóng
          </Button>,
        ]}
        width={720}
      >
        {isLoadingDetail || !courseDetail ? (
          <div className="py-12 flex justify-center">
            <Spin />
          </div>
        ) : (
          <div className="space-y-4 py-2">
            <Descriptions bordered size="small" column={{ xs: 1, sm: 2 }}>
              <Descriptions.Item label="Mã học phần">
                <Tag color="blue" className="font-bold">{courseDetail.code}</Tag>
              </Descriptions.Item>
              <Descriptions.Item label="Số tín chỉ">
                <strong className="text-slate-900">{courseDetail.credits} TC</strong> ({courseDetail.theoryHours} tiết lý thuyết, {courseDetail.practiceHours} tiết thực hành)
              </Descriptions.Item>
              <Descriptions.Item label="Tên học phần" span={2}>
                <span className="font-bold text-slate-900">{courseDetail.name}</span>
              </Descriptions.Item>
              <Descriptions.Item label="Khoa / Bộ môn phụ trách" span={2}>
                {courseDetail.departmentName || 'Khoa Công nghệ Thông tin'}
              </Descriptions.Item>
            </Descriptions>

            {/* Grading formula breakdown - 4 score types */}
            <div className="rounded-lg bg-blue-50/60 border border-blue-100 p-3 space-y-1.5">
              <div className="text-xs font-bold text-ag-900 flex items-center gap-1.5">
                <InfoCircleOutlined className="text-ag-600" /> Công thức & Trọng số tính điểm học phần
              </div>
              {(courseDetail.credits ?? 3) <= 3 ? (
                <>
                  <div className="grid grid-cols-3 gap-2 text-center text-xs pt-1">
                    <div className="bg-white rounded p-2 border border-blue-200">
                      <div className="text-slate-500 font-medium">Thường xuyên 1</div>
                      <div className="text-[10px] text-slate-400 mt-0.5">(TX1)</div>
                      <div className="font-bold text-slate-800 text-sm mt-1">
                        {Math.round((courseDetail.attendanceWeight && Number(courseDetail.attendanceWeight) > 0 ? Number(courseDetail.attendanceWeight) : 0.4) * 50)}%
                      </div>
                    </div>
                    <div className="bg-white rounded p-2 border border-blue-200">
                      <div className="text-slate-500 font-medium">Thường xuyên 2</div>
                      <div className="text-[10px] text-slate-400 mt-0.5">(TX2)</div>
                      <div className="font-bold text-slate-800 text-sm mt-1">
                        {Math.round((courseDetail.attendanceWeight && Number(courseDetail.attendanceWeight) > 0 ? Number(courseDetail.attendanceWeight) : 0.4) * 50)}%
                      </div>
                    </div>
                    <div className="bg-white rounded p-2 border border-indigo-200 bg-indigo-50/40">
                      <div className="text-slate-500 font-medium">Cuối kỳ</div>
                      <div className="text-[10px] text-slate-400 mt-0.5">(CK)</div>
                      <div className="font-bold text-indigo-700 text-sm mt-1">
                        {Math.round((courseDetail.finalWeight && Number(courseDetail.finalWeight) > 0 ? Number(courseDetail.finalWeight) : 0.6) * 100)}%
                      </div>
                    </div>
                  </div>
                  <div className="text-[11px] text-slate-500 italic text-center pt-1">
                    Môn ≤ 3 tín chỉ không có giữa kỳ • Điểm HP = TX1×0.20 + TX2×0.20 + CK×0.60
                  </div>
                </>
              ) : (
                <>
                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 text-center text-xs pt-1">
                    <div className="bg-white rounded p-2 border border-blue-200">
                      <div className="text-slate-500 font-medium">Thường xuyên 1</div>
                      <div className="text-[10px] text-slate-400 mt-0.5">(TX1)</div>
                      <div className="font-bold text-slate-800 text-sm mt-1">
                        {Math.round((courseDetail.attendanceWeight && Number(courseDetail.attendanceWeight) > 0 ? Number(courseDetail.attendanceWeight) : 0.2) * 50)}%
                      </div>
                    </div>
                    <div className="bg-white rounded p-2 border border-blue-200">
                      <div className="text-slate-500 font-medium">Thường xuyên 2</div>
                      <div className="text-[10px] text-slate-400 mt-0.5">(TX2)</div>
                      <div className="font-bold text-slate-800 text-sm mt-1">
                        {Math.round((courseDetail.attendanceWeight && Number(courseDetail.attendanceWeight) > 0 ? Number(courseDetail.attendanceWeight) : 0.2) * 50)}%
                      </div>
                    </div>
                    <div className="bg-white rounded p-2 border border-blue-200">
                      <div className="text-slate-500 font-medium">Giữa kỳ</div>
                      <div className="text-[10px] text-slate-400 mt-0.5">(GK)</div>
                      <div className="font-bold text-slate-800 text-sm mt-1">
                        {Math.round((courseDetail.midtermWeight && Number(courseDetail.midtermWeight) > 0 ? Number(courseDetail.midtermWeight) : 0.3) * 100)}%
                      </div>
                    </div>
                    <div className="bg-white rounded p-2 border border-indigo-200 bg-indigo-50/40">
                      <div className="text-slate-500 font-medium">Cuối kỳ</div>
                      <div className="text-[10px] text-slate-400 mt-0.5">(CK)</div>
                      <div className="font-bold text-indigo-700 text-sm mt-1">
                        {Math.round((courseDetail.finalWeight && Number(courseDetail.finalWeight) > 0 ? Number(courseDetail.finalWeight) : 0.5) * 100)}%
                      </div>
                    </div>
                  </div>
                  <div className="text-[11px] text-slate-500 italic text-center pt-1">
                    Môn ≥ 4 tín chỉ có giữa kỳ • Điểm HP = TX1×0.10 + TX2×0.10 + GK×0.30 + CK×0.50
                  </div>
                </>
              )}
            </div>

            {/* Prerequisites */}
            <div className="rounded-lg border border-slate-200 p-3 space-y-2">
              <div className="text-xs font-bold text-slate-800 flex items-center gap-1.5">
                <CheckCircleOutlined className="text-emerald-600" /> Ràng buộc điều kiện tiên quyết
              </div>
              {courseDetail.prerequisites && courseDetail.prerequisites.length > 0 ? (
                <div className="space-y-1">
                  {courseDetail.prerequisites.map((p) => (
                    <div key={p.id} className="text-xs flex items-center justify-between bg-slate-50 p-2 rounded border border-slate-200">
                      <span>
                        <strong className="text-ag-700">{p.code}</strong> — {p.name}
                      </span>
                      <Tag color="cyan">{p.credits} TC</Tag>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-xs text-slate-400 italic">
                  Học phần này không yêu cầu môn học tiên quyết trước khi đăng ký.
                </div>
              )}
            </div>

            {/* Assigned Teachers */}
            <div className="rounded-lg border border-slate-200 p-3 space-y-2">
              <div className="text-xs font-bold text-slate-800 flex items-center gap-1.5">
                <TeamOutlined className="text-ag-600" /> Giảng viên đảm nhiệm giảng dạy
              </div>
              {courseDetail.assignedTeachers && courseDetail.assignedTeachers.length > 0 ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                  {courseDetail.assignedTeachers.map((t) => (
                    <div key={t.id} className="bg-slate-50 p-2.5 rounded border border-slate-200 text-xs space-y-1">
                      <div className="font-bold text-slate-900">
                        {t.academicTitle || t.academicRank ? `${t.academicTitle || t.academicRank} ` : ''}
                        {t.fullName}
                      </div>
                      <div className="text-slate-500">Mã GV: {t.teacherCode}</div>
                      {t.phone && (
                        <div className="text-slate-600 flex items-center gap-1">
                          <PhoneOutlined className="text-ag-600" /> {t.phone}
                        </div>
                      )}
                      {t.email && (
                        <div className="text-slate-600 flex items-center gap-1">
                          <MailOutlined className="text-ag-600" /> {t.email}
                        </div>
                      )}
                      {t.officeAddress && (
                        <div className="text-slate-500 text-[11px]">
                          Văn phòng: {t.officeAddress}
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-xs text-slate-400 italic">
                  Đang cập nhật danh sách giảng viên phụ trách cho học phần này.
                </div>
              )}
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};