import React, { useMemo, useState } from 'react';
import { Button, Card, Descriptions, Divider, Empty, Modal, Popconfirm, Segmented, Tag } from 'antd';
import {
  BarChartOutlined,
  BookOutlined,
  CalendarOutlined,
  ClockCircleOutlined,
  CloseOutlined,
  EnvironmentOutlined,
  InfoCircleOutlined,
  MailOutlined,
  PhoneOutlined,
  UserOutlined,
} from '@ant-design/icons';

const DAYS = [
  { key: 2, label: 'Thứ 2' },
  { key: 3, label: 'Thứ 3' },
  { key: 4, label: 'Thứ 4' },
  { key: 5, label: 'Thứ 5' },
  { key: 6, label: 'Thứ 6' },
  { key: 7, label: 'Thứ 7' },
  { key: 8, label: 'Chủ nhật' },
];

const SESSIONS = [
  { key: 'MORNING', label: 'Sáng', match: (start) => start <= 6 },
  { key: 'AFTERNOON', label: 'Chiều', match: (start) => start >= 7 && start <= 12 },
  { key: 'EVENING', label: 'Tối', match: (start) => start >= 13 },
];

function formatPeriods(start, end) {
  const arr = [];
  for (let p = start; p <= end; p++) arr.push(p);
  return `(${arr.join(', ')})`;
}

export const TimetableGrid = ({
  items = [],
  canDrop = false,
  onDropSection,
  title,
  selectedWeek,
  isTeacher = false,
  onCardClick,
}) => {
  const [viewMode, setViewMode] = useState('grid');
  const [selectedDetail, setSelectedDetail] = useState(null);
  const [detailModalOpen, setDetailModalOpen] = useState(false);

  const handleCardClick = (item) => {
    setSelectedDetail(item);
    setDetailModalOpen(true);
  };

  const grouped = useMemo(() => {
    const map = {};
    for (const s of SESSIONS) {
      for (const d of DAYS) {
        map[`${s.key}-${d.key}`] = [];
      }
    }
    for (const item of items) {
      const session = SESSIONS.find((s) => s.match(item.startPeriod)) ?? SESSIONS[0];
      const key = `${session.key}-${item.dayOfWeek}`;
      if (!map[key]) map[key] = [];
      map[key].push(item);
    }
    return map;
  }, [items]);

  const itemsByDay = useMemo(() => {
    const map = {};
    for (const d of DAYS) map[d.key] = [];
    for (const item of items) {
      const session = SESSIONS.find((s) => s.match(item.startPeriod)) ?? SESSIONS[0];
      if (!map[item.dayOfWeek]) map[item.dayOfWeek] = [];
      map[item.dayOfWeek].push({ sessionLabel: session.label, item });
    }
    return map;
  }, [items]);

  return (
    <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
      {/* Table Header: Solid light blue background (NO gradient) */}
      <div className="px-4 py-3 border-b border-slate-200 flex flex-wrap items-center justify-between gap-2 bg-[#f0f6ff]">
        <div className="flex items-center gap-2">
          <ClockCircleOutlined className="text-ag-600 text-base" />
          <h3 className="m-0 text-sm md:text-base font-bold text-slate-800">
            {title || 'Thời khóa biểu tuần (Sáng / Chiều / Tối)'}
          </h3>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-xs text-slate-600 hidden sm:inline">
            Tổng số buổi học: <strong className="text-ag-600">{items.length}</strong>
          </span>
          <Segmented
            size="small"
            value={viewMode}
            onChange={(val) => setViewMode(val)}
            options={[
              { label: 'Bảng tuần', value: 'grid' },
              { label: 'Theo ngày', value: 'day' },
            ]}
          />
        </div>
      </div>

      {items.length === 0 ? (
        <div className="py-12">
          <Empty description={selectedWeek ? `Không có lịch học nào trong Tuần ${selectedWeek}` : 'Chưa có lịch học nào trong học kỳ này'} />
        </div>
      ) : viewMode === 'day' ? (
        <div className="p-4 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3">
          {DAYS.map((day) => {
            const list = itemsByDay[day.key] || [];
            return (
              <div key={day.key} className="rounded-xl border border-slate-200 bg-slate-50/50 p-3 space-y-2">
                <div className="flex items-center justify-between border-b border-slate-200 pb-1.5">
                  <span className="font-bold text-ag-700 text-sm">{day.label}</span>
                  <span className="text-xs text-slate-500">{list.length} buổi</span>
                </div>
                {list.length === 0 ? (
                  <div className="text-xs text-slate-400 py-2">Không có lịch</div>
                ) : (
                  list.map((entry, idx) => (
                    <div
                      key={`${entry.item.classSectionId}-${idx}`}
                      onClick={() => handleCardClick(entry.item)}
                      className="timetable-card-item cursor-pointer hover:border-blue-500 hover:shadow-md transition"
                      title="Bấm để xem chi tiết phòng học & giảng viên"
                    >
                      <div className="flex items-start justify-between gap-1 leading-none">
                        <span className="timetable-card-code">
                          {entry.item.sectionCode}
                        </span>
                        {/* Only show red drop icon if canDrop is true (e.g. in registration page) */}
                        {canDrop && onDropSection && (
                          <Popconfirm
                            title="Hủy đăng ký lớp học phần?"
                            description={`Bạn chắc chắn muốn hủy môn "${entry.item.courseName}"?`}
                            okText="Hủy môn"
                            cancelText="Đóng"
                            okButtonProps={{ danger: true }}
                            onConfirm={(e) => {
                              e?.stopPropagation();
                              onDropSection(entry.item.classSectionId, entry.item.courseName);
                            }}
                          >
                            <button
                              type="button"
                              aria-label="Hủy môn"
                              onClick={(e) => e.stopPropagation()}
                              className="timetable-card-drop"
                            >
                              <CloseOutlined />
                            </button>
                          </Popconfirm>
                        )}
                      </div>
                      <div className="timetable-card-title">
                        {entry.item.courseName}
                      </div>
                      <div className="timetable-card-period">
                        {formatPeriods(entry.item.startPeriod, entry.item.endPeriod)}
                      </div>
                      <div className="timetable-card-room">
                        {entry.item.room}
                      </div>
                    </div>
                  ))
                )}
              </div>
            );
          })}
        </div>
      ) : (
        <div className="timetable-scroll overflow-x-auto">
          <table className="timetable-grid-table">
            <thead>
              <tr>
                <th className="timetable-session-header bg-slate-50/80"></th>
                {DAYS.map((day) => (
                  <th key={day.key} className="timetable-day-header">
                    {day.label}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {SESSIONS.map((session) => (
                <tr key={session.key}>
                  <td className="timetable-session-header">
                    {session.label}
                  </td>
                  {DAYS.map((day) => {
                    const cellItems = grouped[`${session.key}-${day.key}`] || [];
                    return (
                      <td key={day.key} className="timetable-cell">
                        <div className="space-y-2">
                          {cellItems.map((item, idx) => (
                            <div
                              key={`${item.classSectionId}-${item.startPeriod}-${idx}`}
                              onClick={() => handleCardClick(item)}
                              className="timetable-card-item cursor-pointer hover:border-blue-500 hover:shadow-md transition"
                              title="Bấm để xem chi tiết buổi học"
                            >
                              <div className="flex items-start justify-between gap-1 leading-none">
                                <span className="timetable-card-code">
                                  {item.sectionCode}
                                </span>
                                {/* Only show red drop icon when canDrop is true */}
                                {canDrop && onDropSection && (
                                  <Popconfirm
                                    title="Hủy đăng ký lớp học phần?"
                                    description={`Bạn chắc chắn muốn hủy môn "${item.courseName}" (${item.sectionCode})?`}
                                    okText="Hủy môn"
                                    cancelText="Đóng"
                                    okButtonProps={{ danger: true }}
                                    onConfirm={(e) => {
                                      e?.stopPropagation();
                                      onDropSection(item.classSectionId, item.courseName);
                                    }}
                                  >
                                    <button
                                      type="button"
                                      aria-label="Hủy môn"
                                      onClick={(e) => e.stopPropagation()}
                                      className="timetable-card-drop"
                                    >
                                      <CloseOutlined />
                                    </button>
                                  </Popconfirm>
                                )}
                              </div>
                              <div className="timetable-card-title">
                                {item.courseName}
                              </div>
                              <div className="timetable-card-period">
                                {formatPeriods(item.startPeriod, item.endPeriod)}
                              </div>
                              <div className="timetable-card-room">
                                {item.room}
                              </div>
                            </div>
                          ))}
                        </div>
                      </td>
                    );
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Course Schedule Detail Modal */}
      <Modal
        title={
          <div className="flex items-center gap-2">
            <BookOutlined className="text-ag-600 text-lg" />
            <span className="font-bold text-slate-800 text-base">Thông tin Chi tiết Buổi học</span>
          </div>
        }
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        destroyOnClose
        centered
        width={560}
      >
        {selectedDetail && (
          <div className="py-2 space-y-4">
            <div className="bg-[#f0f6ff] border border-[#c2daf7] rounded-lg p-3.5">
              <div className="text-xs text-ag-700 font-semibold uppercase tracking-wide">
                {selectedDetail.sectionCode} • Mã HP: {selectedDetail.courseCode}
              </div>
              <div className="text-base font-bold text-slate-900 mt-0.5">
                {selectedDetail.courseName}
              </div>
              <div className="flex items-center gap-2 mt-2 flex-wrap">
                <Tag color="blue" className="font-semibold">
                  {selectedDetail.credits} tín chỉ
                </Tag>
                <Tag color="cyan">
                  {selectedDetail.totalPeriods || selectedDetail.credits * 15} tiết tổng ({selectedDetail.credits} tiết/buổi)
                </Tag>
                <Tag color="purple">
                  Tuần {selectedDetail.startWeek || 1} đến Tuần {selectedDetail.endWeek || 15}
                </Tag>
              </div>
            </div>

            <Descriptions bordered size="small" column={1} labelStyle={{ width: '160px', fontWeight: '600', color: '#475569' }}>
              <Descriptions.Item label="Thời gian học">
                <div className="font-semibold text-slate-900">
                  {selectedDetail.dayOfWeek === 8 ? 'Chủ nhật' : `Thứ ${selectedDetail.dayOfWeek}`} • Tiết {selectedDetail.startPeriod} - {selectedDetail.endPeriod}
                </div>
                <div className="text-xs text-slate-500 mt-0.5">
                  Khung giờ: <strong className="text-ag-600">{selectedDetail.timeRange || '07:00 - 09:25'}</strong>
                </div>
              </Descriptions.Item>

              <Descriptions.Item label="Địa chỉ lớp học">
                <div className="font-semibold text-slate-900 flex items-center gap-1.5">
                  <EnvironmentOutlined className="text-ag-600" />
                  <span>{selectedDetail.room}</span>
                </div>
                <div className="text-xs text-slate-600 mt-0.5">
                  Tòa nhà: <strong>{selectedDetail.building || 'Tòa nhà A1'}</strong> • Cơ sở: <strong>{selectedDetail.campus || 'Cơ sở 1 (Khu A)'}</strong>
                </div>
              </Descriptions.Item>

              <Descriptions.Item label="Giảng viên phụ trách">
                <div className="font-semibold text-slate-900 flex items-center gap-1.5">
                  <UserOutlined className="text-ag-600" />
                  <span>{selectedDetail.teacherName || 'Chưa phân công'}</span>
                  {selectedDetail.teacherRank && (
                    <Tag color="geekblue" className="text-[11px] ml-1">
                      {selectedDetail.teacherRank}
                    </Tag>
                  )}
                </div>
              </Descriptions.Item>

              <Descriptions.Item label="Số điện thoại GV">
                {selectedDetail.teacherPhone ? (
                  <a
                    href={`tel:${selectedDetail.teacherPhone}`}
                    className="font-bold text-ag-600 hover:underline flex items-center gap-1"
                  >
                    <PhoneOutlined /> {selectedDetail.teacherPhone}
                  </a>
                ) : (
                  <span className="text-slate-400">0912 345 678</span>
                )}
              </Descriptions.Item>

              <Descriptions.Item label="Email giảng viên">
                {selectedDetail.teacherEmail ? (
                  <a
                    href={`mailto:${selectedDetail.teacherEmail}`}
                    className="text-slate-700 hover:text-ag-600 flex items-center gap-1"
                  >
                    <MailOutlined /> {selectedDetail.teacherEmail}
                  </a>
                ) : (
                  <span className="text-slate-400">giangvien@daihoc.edu.vn</span>
                )}
              </Descriptions.Item>

              <Descriptions.Item label="Quy tắc thời lượng">
                <div className="text-xs text-slate-600 leading-relaxed">
                  Môn học <strong>{selectedDetail.credits} tín chỉ</strong> tổng cộng <strong>{selectedDetail.credits * 15} tiết</strong>.{' '}
                  Mỗi buổi học <strong>{selectedDetail.endPeriod - selectedDetail.startPeriod + 1} tiết</strong>.{' '}
                  Học 2 buổi/tuần → kết thúc sau khoảng <strong>{Math.ceil(selectedDetail.credits * 15 / ((selectedDetail.endPeriod - selectedDetail.startPeriod + 1) * 2))} tuần</strong>.{' '}
                  Học phần kết thúc ngay sau khi hoàn thành đủ số tiết quy định (Tuần {selectedDetail.startWeek || 1} → {selectedDetail.endWeek || Math.ceil(selectedDetail.credits * 15 / ((selectedDetail.endPeriod - selectedDetail.startPeriod + 1) * 2))}).
                </div>
              </Descriptions.Item>
            </Descriptions>

            {isTeacher && selectedDetail.classSectionId && (
              <div className="pt-2 flex justify-end">
                <Button
                  type="primary"
                  icon={<BarChartOutlined />}
                  onClick={() => {
                    setDetailModalOpen(false);
                    if (onCardClick) onCardClick(selectedDetail);
                  }}
                >
                  Xem biểu đồ phân tích kết quả lớp học phần
                </Button>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
};
