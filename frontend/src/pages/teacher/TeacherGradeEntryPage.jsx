import React, { useEffect, useMemo, useState } from 'react';
import { Alert, Button, Card, Col, InputNumber, Popconfirm, Row, Space, Spin, Table, Tag, message } from 'antd';
import { Column } from '@ant-design/plots';
import {
  ArrowLeftOutlined,
  BarChartOutlined,
  CheckCircleOutlined,
  DownloadOutlined,
  LockOutlined,
  SaveOutlined,
  TeamOutlined,
} from '@ant-design/icons';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useNavigate, useParams } from 'react-router-dom';
import { teacherApi } from '../../api/services';
import { getErrorMessage } from '../../api/client';

export function previewCalc(row) {
  const credits = row.credits ?? 3;
  const hasMidterm = credits >= 4;

  const tx1 = row.regularScore1 != null ? Number(row.regularScore1) : (row.attendanceScore != null ? Number(row.attendanceScore) : null);
  const tx2 = row.regularScore2 != null ? Number(row.regularScore2) : (row.attendanceScore != null ? Number(row.attendanceScore) : null);
  const mid = row.midtermScore != null ? Number(row.midtermScore) : null;
  const fin = row.finalScore != null ? Number(row.finalScore) : null;

  if (tx1 == null || tx2 == null || fin == null || (hasMidterm && mid == null)) {
    return {
      total: row.totalScore10 != null ? Number(row.totalScore10).toFixed(1) : null,
      letter: row.letterGrade,
      gpa4: row.gpaScore4 != null ? Number(row.gpaScore4).toFixed(1) : null,
    };
  }

  const avgTx = (tx1 + tx2) / 2;
  let total;
  if (!hasMidterm) {
    // Môn <= 3 tín chỉ: Không có giữa kỳ, TX 40% (mỗi TX 20%), cuối kỳ 60%
    const attWeight = row.attendanceWeight && Number(row.attendanceWeight) > 0 ? Number(row.attendanceWeight) : 0.4;
    const finWeight = row.finalWeight && Number(row.finalWeight) > 0 ? Number(row.finalWeight) : 0.6;
    total = Number((avgTx * attWeight + fin * finWeight).toFixed(1));
  } else {
    // Môn >= 4 tín chỉ: Có thường xuyên 20%, giữa kỳ 30%, cuối kỳ 50%
    const attWeight = row.attendanceWeight && Number(row.attendanceWeight) > 0 ? Number(row.attendanceWeight) : 0.2;
    const midWeight = row.midtermWeight && Number(row.midtermWeight) > 0 ? Number(row.midtermWeight) : 0.3;
    const finWeight = row.finalWeight && Number(row.finalWeight) > 0 ? Number(row.finalWeight) : 0.5;
    total = Number((avgTx * attWeight + mid * midWeight + fin * finWeight).toFixed(1));
  }

  let letter = 'F';
  let gpa4 = 0.0;
  if (total >= 9.0) { letter = 'A+'; gpa4 = 4.0; }
  else if (total >= 8.5) { letter = 'A'; gpa4 = 3.7; }
  else if (total >= 8.0) { letter = 'B+'; gpa4 = 3.5; }
  else if (total >= 7.0) { letter = 'B'; gpa4 = 3.0; }
  else if (total >= 6.5) { letter = 'C+'; gpa4 = 2.5; }
  else if (total >= 5.5) { letter = 'C'; gpa4 = 2.0; }
  else if (total >= 5.0) { letter = 'D+'; gpa4 = 1.5; }
  else if (total >= 4.0) { letter = 'D'; gpa4 = 1.0; }
  return { total: total.toFixed(1), letter, gpa4: gpa4.toFixed(1) };
}

// Reusable Grade Distribution & Analytics Chart
export const GradeDistributionChart = ({ rows = [] }) => {
  const gradeCounts = useMemo(() => {
    const counts = { 'A+': 0, A: 0, 'B+': 0, B: 0, 'C+': 0, C: 0, 'D+': 0, D: 0, F: 0 };
    for (const row of rows) {
      const calc = previewCalc(row);
      if (calc.letter && counts[calc.letter] !== undefined) {
        counts[calc.letter]++;
      }
    }
    return counts;
  }, [rows]);

  const scoreRanges = useMemo(() => {
    const ranges = { '9-10': 0, '8-9': 0, '7-8': 0, '6-7': 0, '5-6': 0, '<5': 0 };
    let totalGraded = 0;
    let scoreSum = 0;
    let passCount = 0;
    for (const row of rows) {
      const calc = previewCalc(row);
      if (calc.total != null) {
        totalGraded++;
        scoreSum += Number(calc.total);
        if (Number(calc.total) >= 4.0) passCount++;
        if (Number(calc.total) >= 9.0) ranges['9-10']++;
        else if (Number(calc.total) >= 8.0) ranges['8-9']++;
        else if (Number(calc.total) >= 7.0) ranges['7-8']++;
        else if (Number(calc.total) >= 6.0) ranges['6-7']++;
        else if (Number(calc.total) >= 5.0) ranges['5-6']++;
        else ranges['<5']++;
      }
    }
    return { ranges, totalGraded, avgScore: totalGraded > 0 ? scoreSum / totalGraded : 0, passCount };
  }, [rows]);

  const maxCount = Math.max(...Object.values(gradeCounts), 1);
  const gradeColors = {
    'A+': '#16a34a', A: '#22c55e', 'B+': '#3b82f6', B: '#60a5fa',
    'C+': '#f59e0b', C: '#fbbf24', 'D+': '#f97316', D: '#fb923c', F: '#ef4444',
  };

  const gradePlotData = useMemo(
    () =>
      Object.entries(gradeCounts).map(([grade, count]) => ({
        grade,
        count,
      })),
    [gradeCounts]
  );

  const gradePlotConfig = {
    data: gradePlotData,
    xField: 'grade',
    yField: 'count',
    height: 190,
    axis: {
      x: { title: false },
      y: { title: false },
    },
    label: {
      text: (d) => (d.count > 0 ? String(d.count) : ''),
      textBaseline: 'bottom',
    },
    style: {
      radiusTopLeft: 4,
      radiusTopRight: 4,
      fill: ({ grade }) => gradeColors[grade] || '#1a73e8',
    },
  };

  const scorePlotData = useMemo(
    () =>
      Object.entries(scoreRanges.ranges).map(([range, count]) => ({
        range,
        count,
      })),
    [scoreRanges.ranges]
  );

  const scorePlotConfig = {
    data: scorePlotData,
    xField: 'range',
    yField: 'count',
    height: 190,
    axis: {
      x: { title: false },
      y: { title: false },
    },
    label: {
      text: (d) => (d.count > 0 ? String(d.count) : ''),
      textBaseline: 'bottom',
    },
    style: {
      radiusTopLeft: 4,
      radiusTopRight: 4,
      fill: ({ range }) => (range === '<5' ? '#ef4444' : '#1a73e8'),
    },
  };

  const passRate = rows.length > 0 ? Math.round((scoreRanges.passCount / Math.max(scoreRanges.totalGraded, rows.length)) * 100) : 0;

  // Component averages (4 score types)
  const componentAverages = useMemo(() => {
    const valid = rows.filter((r) => r.midtermScore != null || r.finalScore != null || r.regularScore1 != null || r.attendanceScore != null);
    if (valid.length === 0) return null;
    const avg = (fn) => {
      const list = valid.map(fn).filter((v) => v != null);
      return list.length > 0 ? (list.reduce((a, b) => a + Number(b), 0) / list.length).toFixed(1) : '—';
    };
    return {
      tx1: avg((r) => r.regularScore1 ?? r.attendanceScore),
      tx2: avg((r) => r.regularScore2 ?? r.attendanceScore),
      mid: avg((r) => r.midtermScore),
      fin: avg((r) => r.finalScore),
    };
  }, [rows]);

  return (
    <div className="space-y-4">
      {/* 4 Summary Stat Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 text-center">
          <div className="text-xs text-slate-500 font-medium">Sĩ số lớp</div>
          <div className="text-2xl font-bold text-blue-700 mt-0.5">{rows.length}</div>
        </div>
        <div className="bg-green-50 border border-green-200 rounded-lg p-3 text-center">
          <div className="text-xs text-slate-500 font-medium">Đã có điểm</div>
          <div className="text-2xl font-bold text-green-700 mt-0.5">{scoreRanges.totalGraded}</div>
        </div>
        <div className="bg-purple-50 border border-purple-200 rounded-lg p-3 text-center">
          <div className="text-xs text-slate-500 font-medium">Điểm TB toàn lớp</div>
          <div className="text-2xl font-bold text-purple-700 mt-0.5">
            {scoreRanges.totalGraded > 0 ? scoreRanges.avgScore.toFixed(1) : '—'}
          </div>
        </div>
        <div className={`${passRate >= 70 ? 'bg-emerald-50 border-emerald-200' : 'bg-red-50 border-red-200'} border rounded-lg p-3 text-center`}>
          <div className="text-xs text-slate-500 font-medium">Tỷ lệ đạt môn</div>
          <div className={`text-2xl font-bold mt-0.5 ${passRate >= 70 ? 'text-emerald-700' : 'text-red-600'}`}>
            {scoreRanges.totalGraded > 0 ? `${passRate}%` : '—'}
          </div>
        </div>
      </div>

      {/* Grade Letter Bar Chart using official @ant-design/plots Column */}
      <div className="bg-white border border-slate-200 rounded-lg p-4">
        <div className="text-xs font-bold text-slate-700 mb-2 flex items-center justify-between">
          <span className="flex items-center gap-1.5">
            <BarChartOutlined className="text-ag-600" /> Biểu đồ cột phân phổ điểm chữ (A+, A, B+, B, C+, C, D+, D, F)
          </span>
          <span className="text-[11px] text-slate-400 font-normal">Thang điểm 4 quy đổi</span>
        </div>
        <Column {...gradePlotConfig} />
      </div>

      {/* Score Range Progression using official @ant-design/plots Column */}
      <div className="bg-white border border-slate-200 rounded-lg p-4">
        <div className="text-xs font-bold text-slate-700 mb-2 flex items-center justify-between">
          <span className="flex items-center gap-1.5">
            <BarChartOutlined className="text-ag-600" /> Biểu đồ cột phân bổ phổ điểm tổng kết (thang 10)
          </span>
          <span className="text-[11px] text-slate-400 font-normal">Đồ thị cột đứng</span>
        </div>
        <Column {...scorePlotConfig} />
      </div>

      {/* 4 Component Averages */}
      {componentAverages && (
        <div className="bg-blue-50/50 border border-blue-200 rounded-lg p-4">
          <div className="text-xs font-bold text-slate-700 mb-3">Điểm trung bình 4 thành phần đánh giá</div>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 text-center text-xs">
            <div className="bg-white rounded p-2.5 border border-blue-200">
              <div className="text-slate-500 font-medium">Thường xuyên 1</div>
              <div className="text-lg font-bold text-slate-800 mt-0.5">{componentAverages.tx1}</div>
              <div className="text-[10px] text-slate-400">TX1 (Thang 10)</div>
            </div>
            <div className="bg-white rounded p-2.5 border border-blue-200">
              <div className="text-slate-500 font-medium">Thường xuyên 2</div>
              <div className="text-lg font-bold text-slate-800 mt-0.5">{componentAverages.tx2}</div>
              <div className="text-[10px] text-slate-400">TX2 (Thang 10)</div>
            </div>
            <div className="bg-white rounded p-2.5 border border-blue-200">
              <div className="text-slate-500 font-medium">Giữa kỳ</div>
              <div className="text-lg font-bold text-slate-800 mt-0.5">{componentAverages.mid}</div>
              <div className="text-[10px] text-slate-400">GK (Thang 10)</div>
            </div>
            <div className="bg-white rounded p-2.5 border border-indigo-200 bg-indigo-50/30">
              <div className="text-slate-500 font-medium">Cuối kỳ</div>
              <div className="text-lg font-bold text-indigo-700 mt-0.5">{componentAverages.fin}</div>
              <div className="text-[10px] text-slate-400">CK (Thang 10)</div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export const TeacherGradeEntryPage = () => {
  const { sectionId } = useParams();
  const classSectionId = Number(sectionId);
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [showChart, setShowChart] = useState(false);

  const { data: rows = [], isLoading } = useQuery({
    queryKey: ['teacher-class-grades', classSectionId],
    queryFn: () => teacherApi.getClassGrades(classSectionId),
    enabled: Boolean(classSectionId),
  });

  const { data: myClasses = [] } = useQuery({
    queryKey: ['teacher-classes'],
    queryFn: () => teacherApi.getClasses(),
  });

  const currentClass = useMemo(() => {
    return myClasses.find((c) => String(c.id) === String(classSectionId));
  }, [myClasses, classSectionId]);

  const isFinished = useMemo(() => {
    if (currentClass?.teachingStatus === 'FINISHED') return true;
    if (currentClass?.status === 'CLOSED') return true;
    if (currentClass?.isLocked) return true;
    if (currentClass?.endWeek != null && currentClass.endWeek < 11) return true;
    return false;
  }, [currentClass]);

  const [editableRows, setEditableRows] = useState([]);

  useEffect(() => {
    setEditableRows(rows);
  }, [rows]);

  const allLocked = editableRows.length > 0 && editableRows.every((r) => r.locked);
  const firstRow = editableRows[0];

  const saveMutation = useMutation({
    mutationFn: () =>
      teacherApi.updateGradesBatch(
        classSectionId,
        editableRows
          .filter((r) => !r.locked)
          .map((r) => {
            const tx1 = r.regularScore1 ?? r.attendanceScore;
            const tx2 = r.regularScore2 ?? r.attendanceScore;
            const avg = tx1 != null && tx2 != null ? (Number(tx1) + Number(tx2)) / 2 : (tx1 ?? tx2);
            return {
              enrollmentId: r.enrollmentId,
              regularScore1: tx1,
              regularScore2: tx2,
              attendanceScore: avg,
              midtermScore: r.midtermScore,
              finalScore: r.finalScore,
            };
          })
      ),
    onSuccess: () => {
      message.success('Đã lưu bảng điểm thành công');
      queryClient.invalidateQueries({ queryKey: ['teacher-class-grades', classSectionId] });
    },
    onError: (err) => message.error(getErrorMessage(err)),
  });

  const lockMutation = useMutation({
    mutationFn: () => teacherApi.lockGrades(classSectionId),
    onSuccess: () => {
      message.success('Đã khóa sổ điểm lớp học phần');
      queryClient.invalidateQueries({ queryKey: ['teacher-class-grades', classSectionId] });
      queryClient.invalidateQueries({ queryKey: ['teacher-dashboard'] });
    },
    onError: (err) => message.error(getErrorMessage(err)),
  });

  const updateScore = (enrollmentId, field, val) => {
    setEditableRows((prev) =>
      prev.map((row) => (row.enrollmentId === enrollmentId ? { ...row, [field]: val ?? undefined } : row))
    );
  };

  const handleExportExcel = async () => {
    try {
      const blob = await teacherApi.exportGradesExcel(classSectionId);
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `bang-diem-${firstRow?.sectionCode || classSectionId}.xlsx`;
      a.click();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      message.error(getErrorMessage(err));
    }
  };

  // 4 columns: Thường xuyên 1, Thường xuyên 2, Giữa kỳ, Cuối kỳ (NO weight percentages in headers!)
  const columns = [
    { title: 'Mã SV', dataIndex: 'studentCode', key: 'studentCode', width: 120, render: (v) => <strong className="text-ag-700">{v}</strong> },
    { title: 'Họ và tên', dataIndex: 'studentName', key: 'studentName', width: 190 },
    {
      title: 'Thường xuyên 1',
      key: 'regularScore1',
      width: 130,
      render: (_, r) => (
        <InputNumber
          min={0}
          max={10}
          step={0.5}
          disabled={r.locked || isFinished}
          value={r.regularScore1 ?? r.attendanceScore}
          onChange={(v) => updateScore(r.enrollmentId, 'regularScore1', v)}
          className="w-24"
        />
      ),
    },
    {
      title: 'Thường xuyên 2',
      key: 'regularScore2',
      width: 130,
      render: (_, r) => (
        <InputNumber
          min={0}
          max={10}
          step={0.5}
          disabled={r.locked || isFinished}
          value={r.regularScore2 ?? r.attendanceScore}
          onChange={(v) => updateScore(r.enrollmentId, 'regularScore2', v)}
          className="w-24"
        />
      ),
    },
    {
      title: 'Giữa kỳ',
      key: 'midtermScore',
      width: 130,
      render: (_, r) => {
        const credits = r.credits ?? (firstRow?.credits ?? 3);
        if (credits <= 3) {
          return <span className="text-slate-400 italic text-xs">Không có (≤ 3 TC)</span>;
        }
        return (
          <InputNumber
            min={0}
            max={10}
            step={0.5}
            disabled={r.locked || isFinished}
            value={r.midtermScore}
            onChange={(v) => updateScore(r.enrollmentId, 'midtermScore', v)}
            className="w-24"
          />
        );
      },
    },
    {
      title: 'Cuối kỳ',
      key: 'finalScore',
      width: 130,
      render: (_, r) => (
        <InputNumber
          min={0}
          max={10}
          step={0.5}
          disabled={r.locked || isFinished}
          value={r.finalScore}
          onChange={(v) => updateScore(r.enrollmentId, 'finalScore', v)}
          className="w-24"
        />
      ),
    },
    {
      title: 'Tổng (10)',
      key: 'total',
      width: 100,
      align: 'center',
      render: (_, r) => {
        const calc = previewCalc(r);
        return <strong className="text-slate-900">{calc.total != null ? Number(calc.total).toFixed(1) : '-'}</strong>;
      },
    },
    {
      title: 'Chữ / Hệ 4',
      key: 'letter',
      width: 110,
      align: 'center',
      render: (_, r) => {
        const calc = previewCalc(r);
        if (!calc.letter) return '-';
        return (
          <Tag color={calc.letter === 'F' ? 'red' : 'blue'}>
            {calc.letter} ({calc.gpa4 != null ? Number(calc.gpa4).toFixed(1) : '-'})
          </Tag>
        );
      },
    },
    {
      title: 'Trạng thái',
      key: 'locked',
      width: 110,
      align: 'center',
      render: (_, r) => (r.locked ? <Tag color="red">Đã khóa</Tag> : <Tag color="green">Đang mở</Tag>),
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
      <Card className="shadow-sm" styles={{ body: { padding: 16 } }}>
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div className="flex items-center gap-3">
            <Button icon={<ArrowLeftOutlined />} onClick={() => navigate('/teacher/classes')}>
              Quay lại
            </Button>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="m-0 text-base font-bold text-slate-800">
                  Bảng nhập điểm: {firstRow?.sectionCode} — {firstRow?.courseName}
                </h2>
                <Tag color={isFinished ? 'default' : 'processing'}>
                  {isFinished ? 'Đã dạy xong' : 'Đang dạy'}
                </Tag>
              </div>
              <div className="text-xs text-slate-500 mt-0.5">
                Sĩ số: {editableRows.length} sinh viên • 4 cột điểm: Thường xuyên 1, Thường xuyên 2, Giữa kỳ, Cuối kỳ
              </div>
            </div>
          </div>

          <Space wrap>
            <Button
              icon={<BarChartOutlined />}
              onClick={() => setShowChart(!showChart)}
              type={showChart ? 'primary' : 'default'}
            >
              {showChart ? 'Ẩn phân tích' : 'Xem phân tích kết quả'}
            </Button>
            <Button icon={<DownloadOutlined />} onClick={handleExportExcel}>
              Xuất Excel
            </Button>
            <Button
              type="primary"
              icon={<SaveOutlined />}
              disabled={allLocked || isFinished}
              loading={saveMutation.isPending}
              onClick={() => saveMutation.mutate()}
            >
              Lưu bảng điểm
            </Button>
            <Popconfirm
              title="Khóa sổ điểm lớp học phần?"
              description="Sau khi khóa, giảng viên không thể tự sửa điểm trừ khi Phòng Đào tạo mở khóa."
              okText="Khóa sổ"
              cancelText="Hủy"
              onConfirm={() => lockMutation.mutate()}
            >
              <Button danger icon={<LockOutlined />} disabled={allLocked || isFinished} loading={lockMutation.isPending}>
                Khóa sổ điểm
              </Button>
            </Popconfirm>
          </Space>
        </div>
      </Card>

      {isFinished && (
        <Alert
          type="warning"
          showIcon
          message="Lớp học phần đã kết thúc thời gian giảng dạy (Đã dạy xong)"
          description={`Lớp học phần này đã hoàn thành giảng dạy ở tuần ${currentClass?.endWeek || 8}. Hệ thống đã đóng quyền nhập và sửa điểm, dữ liệu chuyển sang chế độ chỉ đọc.`}
        />
      )}

      {allLocked && (
        <Alert
          type="info"
          showIcon
          message="Sổ điểm của lớp này đã bị khóa"
          description="Liên hệ Phòng Đào tạo (Admin) nếu cần mở khóa phúc khảo điểm."
        />
      )}

      {/* Chart Analytics Panel */}
      {showChart && (
        <Card
          className="shadow-sm border border-blue-200 bg-blue-50/20"
          title={
            <span className="flex items-center gap-2 font-bold text-slate-800">
              <BarChartOutlined className="text-ag-600" />
              Phân tích kết quả học tập lớp {firstRow?.sectionCode} ({firstRow?.courseName})
            </span>
          }
        >
          <GradeDistributionChart rows={editableRows} />
        </Card>
      )}

      <Card className="shadow-sm" styles={{ body: { padding: 0 } }}>
        <Table
          rowKey="enrollmentId"
          columns={columns}
          dataSource={editableRows}
          scroll={{ x: 1050 }}
          pagination={false}
        />
      </Card>
    </div>
  );
};
