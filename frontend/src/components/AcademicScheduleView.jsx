import React, { useMemo, useState } from 'react';
import { Badge, Button, Calendar, Card, Descriptions, Empty, Modal, Popover, Radio, Select, Space, Spin, Tag, Tooltip } from 'antd';
import {
  BarChartOutlined,
  BookOutlined,
  CalendarOutlined,
  CheckCircleOutlined,
  CheckOutlined,
  ClockCircleOutlined,
  EditOutlined,
  EnvironmentOutlined,
  InfoCircleOutlined,
  LeftOutlined,
  MailOutlined,
  PhoneOutlined,
  RightOutlined,
  SyncOutlined,
  TeamOutlined,
  UserOutlined,
} from '@ant-design/icons';
import dayjs from 'dayjs';
import isoWeek from 'dayjs/plugin/isoWeek';
import weekOfYear from 'dayjs/plugin/weekOfYear';
import { useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { teacherApi } from '../api/services';
import { TimetableGrid } from './TimetableGrid';
import { GradeDistributionChart } from '../pages/teacher/TeacherGradeEntryPage';

dayjs.extend(isoWeek);
dayjs.extend(weekOfYear);

// Academic year begins first Monday of September 2026 (2026-08-31)
const ACADEMIC_START = dayjs('2026-09-01').startOf('isoWeek');

export const WEEKS_DATA = Array.from({ length: 52 }, (_, i) => {
  const weekNum = i + 1;
  const start = ACADEMIC_START.add(i * 7, 'day');
  const end = start.add(6, 'day');
  const fmt = (d) => d.format('DD/MM/YYYY');
  const semesterName =
    weekNum <= 19
      ? 'Học kỳ 1 (Năm học 2026 - 2027)'
      : weekNum <= 39
      ? 'Học kỳ 2 (Năm học 2026 - 2027)'
      : 'Học kỳ Hè (Năm học 2026 - 2027)';
  const semesterShort = weekNum <= 19 ? 'Học kỳ 1' : weekNum <= 39 ? 'Học kỳ 2' : 'Học kỳ Hè';
  return {
    week: weekNum,
    label: `Tuần ${weekNum} [${fmt(start)} – ${fmt(end)}]`,
    shortLabel: `Tuần ${weekNum}`,
    dateRange: `${fmt(start)} – ${fmt(end)}`,
    semesterName,
    semesterShort,
    startDate: start,
    endDate: end,
  };
});

export function getCurrentAcademicWeek() {
  const today = dayjs();
  for (let i = 0; i < WEEKS_DATA.length; i++) {
    const w = WEEKS_DATA[i];
    if (
      today.isSame(w.startDate, 'day') ||
      (today.isAfter(w.startDate) && today.isBefore(w.endDate.add(1, 'day')))
    ) {
      return w.week;
    }
  }
  return 1;
}

/**
 * Universal Academic Schedule View used across Student & Teacher Portals.
 * Provides consistent week navigation, visual calendar picker, accurate
 * course duration calculation (e.g. 3 credits with 2 sessions/week finishing at Week 8),
 * and class detail modal with result analytics chart for teachers.
 */
export const AcademicScheduleView = ({
  schedule = [],
  isLoading = false,
  title = 'Thời khóa biểu',
  subtitle = '',
  semesterName = 'Năm học 2026 - 2027',
  isTeacher = false,
  isDashboard = false,
  canDrop = false,
  onDropSection,
}) => {
  const navigate = useNavigate();
  const [selectedWeek, setSelectedWeek] = useState(() => getCurrentAcademicWeek());
  const [tempSelectedWeek, setTempSelectedWeek] = useState(() => getCurrentAcademicWeek());
  const [calendarDate, setCalendarDate] = useState(() => {
    const cur = WEEKS_DATA.find((w) => w.week === getCurrentAcademicWeek()) || WEEKS_DATA[0];
    return cur.startDate;
  });
  const [viewScope, setViewScope] = useState('WEEK'); // 'WEEK' or 'ALL'
  const [showCalendar, setShowCalendar] = useState(false);
  const [teacherDetailSectionId, setTeacherDetailSectionId] = useState(null);
  const [teacherDetailModalOpen, setTeacherDetailModalOpen] = useState(false);

  // Fetch teacher class grades when teacher inspects a section
  const { data: teacherClassGrades = [], isLoading: isLoadingTeacherGrades } = useQuery({
    queryKey: ['teacher-class-grades', teacherDetailSectionId],
    queryFn: () => teacherApi.getClassGrades(teacherDetailSectionId),
    enabled: Boolean(isTeacher && teacherDetailSectionId && teacherDetailModalOpen),
  });

  // Calculate accurate course durations based on credits and weekly sessions
  const enhancedSchedule = useMemo(() => {
    // Group by classSectionId to count total periods per week for each course section
    const sectionWeeklyPeriods = {};
    for (const item of schedule) {
      const sid = item.classSectionId;
      const periodsThisSession =
        item.endPeriod && item.startPeriod ? item.endPeriod - item.startPeriod + 1 : item.credits || 3;
      sectionWeeklyPeriods[sid] = (sectionWeeklyPeriods[sid] || 0) + Math.max(1, periodsThisSession);
    }

    return schedule.map((item) => {
      const sid = item.classSectionId;
      const credits = item.credits || 3;
      const totalPeriods = item.totalPeriods || credits * 15;
      const weeklyPeriods = sectionWeeklyPeriods[sid] || 3;
      // Formula: weeksNeeded = ceil(totalPeriods / weeklyPeriods)
      // E.g., 3 credits (45 periods) / 6 periods/week (2 sessions/week) = 7.5 -> 8 weeks!
      const weeksNeeded = Math.max(1, Math.ceil(totalPeriods / weeklyPeriods));
      const startW = item.startWeek != null ? item.startWeek : 1;
      const endW = item.endWeek != null && item.endWeek < 15 ? item.endWeek : startW + weeksNeeded - 1;

      return {
        ...item,
        startWeek: startW,
        endWeek: endW,
        totalPeriods,
        weeklyPeriods,
        weeksNeeded,
      };
    });
  }, [schedule]);

  // Filter schedule by selected week
  const displaySchedule = useMemo(() => {
    if (viewScope === 'ALL') return enhancedSchedule;
    return enhancedSchedule.filter((item) => {
      return selectedWeek >= item.startWeek && selectedWeek <= item.endWeek;
    });
  }, [enhancedSchedule, selectedWeek, viewScope]);

  // Finished early courses (e.g. completed at week 8, currently viewing week 9+)
  const finishedEarlyCourses = useMemo(() => {
    if (viewScope === 'ALL') return [];
    const seen = new Set();
    return enhancedSchedule.filter((item) => {
      if (item.endWeek < selectedWeek && !seen.has(item.classSectionId)) {
        seen.add(item.classSectionId);
        return true;
      }
      return false;
    });
  }, [enhancedSchedule, selectedWeek, viewScope]);

  // Upcoming courses (starting after selected week)
  const upcomingCourses = useMemo(() => {
    if (viewScope === 'ALL') return [];
    const seen = new Set();
    return enhancedSchedule.filter((item) => {
      if (item.startWeek > selectedWeek && !seen.has(item.classSectionId)) {
        seen.add(item.classSectionId);
        return true;
      }
      return false;
    });
  }, [enhancedSchedule, selectedWeek, viewScope]);

  const currentWeekInfo = WEEKS_DATA[selectedWeek - 1] || WEEKS_DATA[0];
  const tempWeekInfo = WEEKS_DATA[tempSelectedWeek - 1] || currentWeekInfo;
  const uniqueCourseCount = new Set(displaySchedule.map((s) => s.classSectionId)).size;

  const handleToggleCalendar = () => {
    if (!showCalendar) {
      setTempSelectedWeek(selectedWeek);
      const cur = WEEKS_DATA.find((w) => w.week === selectedWeek) || WEEKS_DATA[0];
      setCalendarDate(cur.startDate);
    }
    setShowCalendar(!showCalendar);
  };

  // Active weeks that have classes
  const weeksWithClasses = useMemo(() => {
    const set = new Set();
    for (const item of enhancedSchedule) {
      for (let w = item.startWeek; w <= item.endWeek; w++) {
        set.add(w);
      }
    }
    return set;
  }, [enhancedSchedule]);

  const handlePrevWeek = () => setSelectedWeek((w) => Math.max(1, w - 1));
  const handleNextWeek = () => setSelectedWeek((w) => Math.min(52, w + 1));
  const handleCurrentWeek = () => setSelectedWeek(getCurrentAcademicWeek());

  // Intercept timetable card click for teacher to show analytics modal
  const handleTeacherViewClass = (item) => {
    if (isTeacher && item?.classSectionId) {
      setTeacherDetailSectionId(item.classSectionId);
      setTeacherDetailModalOpen(true);
    }
  };

  // Calendar cell renderer
  const calendarCellRender = (current) => {
    const weekIdx = WEEKS_DATA.findIndex(
      (w) =>
        (current.isSame(w.startDate, 'day') || current.isAfter(w.startDate)) &&
        (current.isSame(w.endDate, 'day') || current.isBefore(w.endDate.add(1, 'day')))
    );
    if (weekIdx < 0) return null;
    const w = WEEKS_DATA[weekIdx];
    const hasClass = weeksWithClasses.has(w.week);
    const isSelected = w.week === tempSelectedWeek;

    if (!current.isSame(w.startDate, 'day')) return null;

    return (
      <div className="mt-0.5">
        <Tooltip title={`${w.label} • ${w.semesterShort}`}>
          <Badge
            status={isSelected ? 'processing' : hasClass ? 'success' : 'default'}
            text={
              <span
                className={`text-[10px] font-semibold cursor-pointer ${
                  isSelected ? 'text-blue-600 font-bold' : hasClass ? 'text-emerald-700' : 'text-slate-400'
                }`}
                onClick={(e) => {
                  e.stopPropagation();
                  setTempSelectedWeek(w.week);
                  setCalendarDate(w.startDate);
                }}
              >
                T{w.week}
              </span>
            }
          />
        </Tooltip>
      </div>
    );
  };

  return (
    <div className="space-y-4">
      {/* Top Banner Card (hidden or compacted on dashboard if needed) */}
      {!isDashboard && (
        <Card className="shadow-xs border border-slate-200" styles={{ body: { padding: 16 } }}>
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-[#1a73e8] text-white flex items-center justify-center text-lg font-bold">
                <CalendarOutlined />
              </div>
              <div>
                <h1 className="m-0 text-base md:text-lg font-bold text-slate-800">
                  {title} — {semesterName}
                </h1>
                <div className="text-xs text-slate-500 mt-0.5">{subtitle}</div>
              </div>
            </div>

            <div className="flex items-center gap-2 flex-wrap">
              <Tag color="blue" className="m-0 font-semibold px-2.5 py-1 text-xs">
                {viewScope === 'WEEK' ? currentWeekInfo.shortLabel : 'Toàn kỳ'}: {uniqueCourseCount} học phần •{' '}
                {displaySchedule.length} buổi học
              </Tag>
            </div>
          </div>
        </Card>
      )}

      {/* Week & Visual Calendar Navigator Toolbar */}
      <Card
        className="shadow-xs border border-[#c2daf7] bg-[#f8fbff]"
        styles={{ body: { padding: isDashboard ? 12 : 14 } }}
      >
        <div className="flex flex-wrap items-center justify-between gap-3">
          {/* Week Selector with Controls */}
          <div className="flex items-center gap-2 flex-wrap">
            <span className="text-xs font-bold text-slate-700">Tuần học:</span>
            <Space.Compact>
              <Button
                icon={<LeftOutlined />}
                onClick={handlePrevWeek}
                disabled={selectedWeek <= 1}
                title="Tuần trước"
              />
              <Button className="font-bold text-slate-800 pointer-events-none bg-white">
                Tuần {selectedWeek}
              </Button>
              <Button
                icon={<RightOutlined />}
                onClick={handleNextWeek}
                disabled={selectedWeek >= 52}
                title="Tuần sau"
              />
            </Space.Compact>

            <Button
              size="middle"
              icon={<SyncOutlined />}
              onClick={handleCurrentWeek}
              className="text-xs font-semibold"
            >
              Tuần hiện tại
            </Button>

            {/* Visual Calendar Toggle Button with Floating Overlay */}
            <div className="relative inline-block">
              <Button
                type={showCalendar ? 'primary' : 'default'}
                icon={<CalendarOutlined />}
                onClick={handleToggleCalendar}
                className="text-xs font-semibold"
              >
                {showCalendar ? 'Đóng lịch tháng' : 'Chọn theo Calendar'}
              </Button>

              {/* Floating Visual Calendar Overlay with z-index to not push page height */}
              {showCalendar && (
                <div className="absolute top-full left-0 mt-2 z-50 shadow-2xl bg-white border border-slate-200 rounded-xl overflow-hidden w-[360px] sm:w-[450px]">
                  <div className="text-xs font-bold text-slate-700 p-3 bg-slate-50 border-b border-slate-200 flex items-center justify-between">
                    <span className="flex items-center gap-1.5">
                      <CalendarOutlined className="text-ag-600" /> Chọn tuần trên Calendar
                    </span>
                    <div className="flex items-center gap-3 text-[11px] text-slate-500 font-normal">
                      <span className="flex items-center gap-1">
                        <Badge status="processing" /> Đang chọn (T{tempSelectedWeek})
                      </span>
                      <span className="flex items-center gap-1">
                        <Badge status="success" /> Có lịch
                      </span>
                    </div>
                  </div>

                  <div className="p-2">
                    <Calendar
                      fullscreen={false}
                      value={calendarDate}
                      cellRender={(current, info) => {
                        if (info.type === 'date') return calendarCellRender(current);
                        return null;
                      }}
                      onSelect={(date, { source }) => {
                        if (source === 'date') {
                          const weekIdx = WEEKS_DATA.findIndex(
                            (w) =>
                              (date.isSame(w.startDate, 'day') || date.isAfter(w.startDate)) &&
                              (date.isSame(w.endDate, 'day') || date.isBefore(w.endDate.add(1, 'day')))
                          );
                          if (weekIdx >= 0) {
                            setTempSelectedWeek(WEEKS_DATA[weekIdx].week);
                          }
                          setCalendarDate(date);
                        }
                      }}
                      headerRender={({ value }) => {
                        const month = value.month();
                        const year = value.year();
                        return (
                          <div className="flex items-center justify-between p-2.5 bg-slate-50 border-b border-slate-200">
                            <Button
                              size="small"
                              icon={<LeftOutlined />}
                              onClick={(e) => {
                                e.stopPropagation();
                                setCalendarDate((prev) => prev.subtract(1, 'month'));
                              }}
                            />
                            <span className="font-bold text-slate-800 text-sm">
                              Tháng {month + 1} / {year}
                            </span>
                            <Button
                              size="small"
                              icon={<RightOutlined />}
                              onClick={(e) => {
                                e.stopPropagation();
                                setCalendarDate((prev) => prev.add(1, 'month'));
                              }}
                            />
                          </div>
                        );
                      }}
                    />
                  </div>

                  {/* Action bar with 'Chọn' button */}
                  <div className="flex flex-wrap items-center justify-between p-3 bg-slate-50 border-t border-slate-200 gap-2">
                    <div className="text-xs">
                      <span className="text-slate-500 font-medium">Đang chọn: </span>
                      <span className="font-bold text-ag-700">
                        {tempWeekInfo
                          ? `${tempWeekInfo.shortLabel} [${tempWeekInfo.dateRange}]`
                          : `Tuần ${tempSelectedWeek}`}
                      </span>
                    </div>
                    <Space>
                      <Button size="small" onClick={() => setShowCalendar(false)}>
                        Hủy
                      </Button>
                      <Button
                        size="small"
                        type="primary"
                        icon={<CheckOutlined />}
                        onClick={() => {
                          setSelectedWeek(tempSelectedWeek);
                          setShowCalendar(false);
                        }}
                      >
                        Chọn
                      </Button>
                    </Space>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Scope Toggle: Week vs All Semester */}
          <div className="flex items-center gap-2">
            <Radio.Group
              value={viewScope}
              onChange={(e) => setViewScope(e.target.value)}
              buttonStyle="solid"
              size="middle"
            >
              <Radio.Button value="WEEK">Theo tuần</Radio.Button>
              <Radio.Button value="ALL">Tất cả các tuần</Radio.Button>
            </Radio.Group>
          </div>
        </div>

        {/* Academic Week & Semester Progression Information */}
        {viewScope === 'WEEK' && (
          <div className="mt-3 pt-3 border-t border-blue-100 flex flex-wrap items-center justify-between gap-2 text-xs">
            <div className="flex items-center gap-2 flex-wrap">
              <ClockCircleOutlined className="text-ag-600" />
              <span className="text-slate-800 font-bold">
                Tuần {currentWeekInfo.week} — {currentWeekInfo.semesterName}
              </span>
              <span className="text-slate-500 font-medium">({currentWeekInfo.dateRange})</span>
            </div>

            <div className="flex items-center gap-3 flex-wrap">
              {finishedEarlyCourses.length > 0 && (
                <Popover
                  title="Các môn đã hoàn thành đủ số tiết"
                  content={
                    <div className="space-y-1 text-xs">
                      {finishedEarlyCourses.map((c) => (
                        <div key={c.classSectionId} className="flex justify-between gap-3">
                          <span className="font-semibold text-slate-800">{c.courseName}</span>
                          <Tag color="green">Kết thúc tuần {c.endWeek}</Tag>
                        </div>
                      ))}
                    </div>
                  }
                >
                  <span className="text-amber-800 bg-amber-50 px-2.5 py-0.5 rounded border border-amber-200 cursor-pointer font-medium hover:bg-amber-100 transition">
                    {finishedEarlyCourses.length} môn đã kết thúc sớm (trước tuần {selectedWeek})
                  </span>
                </Popover>
              )}

              {upcomingCourses.length > 0 && (
                <span className="text-blue-800 bg-blue-50 px-2 py-0.5 rounded border border-blue-200 font-medium">
                  {upcomingCourses.length} môn sẽ bắt đầu sau tuần này
                </span>
              )}
            </div>
          </div>
        )}
      </Card>

      {/* Main Timetable View */}
      {isLoading ? (
        <div className="py-20 flex justify-center bg-white rounded-xl border border-slate-200">
          <Spin size="large" tip="Đang tải dữ liệu thời khóa biểu..." />
        </div>
      ) : (
        <TimetableGrid
          items={displaySchedule}
          canDrop={canDrop}
          onDropSection={onDropSection}
          selectedWeek={viewScope === 'WEEK' ? selectedWeek : null}
          isTeacher={isTeacher}
          onCardClick={handleTeacherViewClass}
          title={
            viewScope === 'WEEK'
              ? `${title} — Tuần ${currentWeekInfo.week} (${currentWeekInfo.semesterShort}) [${currentWeekInfo.dateRange}]`
              : `${title} toàn bộ học kỳ — ${semesterName}`
          }
        />
      )}

      {/* Modal for Teacher: Class Details & Result Analytics Chart */}
      {isTeacher && (
        <Modal
          title={
            <div className="flex items-center gap-2 text-slate-800 font-bold">
              <BarChartOutlined className="text-ag-600 text-lg" />
              <span>Phân tích Kết quả & Thống kê Lớp học phần</span>
            </div>
          }
          open={teacherDetailModalOpen}
          onCancel={() => setTeacherDetailModalOpen(false)}
          footer={[
            <Button key="close" onClick={() => setTeacherDetailModalOpen(false)}>
              Đóng
            </Button>,
            <Button
              key="gradeEntry"
              type="primary"
              icon={<EditOutlined />}
              onClick={() => {
                setTeacherDetailModalOpen(false);
                navigate(`/teacher/classes/${teacherDetailSectionId}/grades`);
              }}
            >
              Mở trang Nhập điểm
            </Button>,
          ]}
          width={860}
          destroyOnClose
        >
          {isLoadingTeacherGrades ? (
            <div className="py-16 flex justify-center">
              <Spin size="large" tip="Đang tải dữ liệu thống kê lớp học phần..." />
            </div>
          ) : (
            <div className="space-y-4 py-2">
              <GradeDistributionChart rows={teacherClassGrades} />
            </div>
          )}
        </Modal>
      )}
    </div>
  );
};
