import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../data/sample_prescription.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _weekOffset = 0;
  late final Prescription _prescription;
  final Map<String, bool> _takenStatus = {};
  final Map<String, DateTime> _takenTimes = {};

  static const List<String> _dayNames = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'CN',
  ];

  @override
  void initState() {
    super.initState();
    _prescription = createSamplePrescription();
    _initializeMockData();
  }

  // ── Helpers ──────────────────────────────────────────

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatShortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  DateTime get _weekMonday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return monday.add(Duration(days: 7 * _weekOffset));
  }

  List<DateTime> get _weekDays =>
      List.generate(7, (i) => _weekMonday.add(Duration(days: i)));

  bool _isDateInTreatment(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final start = DateTime(
        _prescription.startDate.year,
        _prescription.startDate.month,
        _prescription.startDate.day);
    final end = DateTime(
        _prescription.endDate.year,
        _prescription.endDate.month,
        _prescription.endDate.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isPastDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    return d.isBefore(today);
  }

  bool _isTaken(DateTime date, String medId, String period) {
    return _takenStatus['${_dateKey(date)}_${medId}_$period'] ?? false;
  }

  void _toggleTaken(DateTime date, String medId, String period) {
    final key = '${_dateKey(date)}_${medId}_$period';
    setState(() {
      if (_takenStatus[key] == true) {
        _takenStatus.remove(key);
        _takenTimes.remove(key);
      } else {
        _takenStatus[key] = true;
        _takenTimes[key] = DateTime.now();
      }
    });
  }

  String _getCellStatus(DateTime date, String period) {
    final allTaken =
        _prescription.medicines.every((m) => _isTaken(date, m.id, period));
    final anyTaken =
        _prescription.medicines.any((m) => _isTaken(date, m.id, period));

    if (allTaken) return 'completed';

    if (_isPastDate(date) && !_isToday(date)) {
      return anyTaken ? 'partial' : 'missed';
    }

    if (_isToday(date)) {
      final scheduleHour = period == 'morning' ? 7 : 19;
      final scheduleTime =
          DateTime(date.year, date.month, date.day, scheduleHour);
      if (DateTime.now().isAfter(scheduleTime)) {
        return anyTaken ? 'late_partial' : 'late';
      }
      return 'waiting';
    }

    return 'upcoming';
  }

  // ── Mock data ────────────────────────────────────────

  void _initializeMockData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Những ngày đã qua: đánh dấu đã uống hết
    for (var d = _prescription.startDate;
        d.isBefore(today);
        d = d.add(const Duration(days: 1))) {
      if (!_isDateInTreatment(d)) continue;
      final dk = _dateKey(d);
      for (var med in _prescription.medicines) {
        _takenStatus['${dk}_${med.id}_morning'] = true;
        _takenStatus['${dk}_${med.id}_evening'] = true;
        _takenTimes['${dk}_${med.id}_morning'] =
            DateTime(d.year, d.month, d.day, 7, 3);
        _takenTimes['${dk}_${med.id}_evening'] =
            DateTime(d.year, d.month, d.day, 19, 10);
      }
    }

    // Hôm nay buổi sáng: 2 thuốc đầu đã uống
    if (_isDateInTreatment(today) && now.hour >= 7) {
      final dk = _dateKey(today);
      for (var i = 0; i < _prescription.medicines.length && i < 2; i++) {
        final med = _prescription.medicines[i];
        _takenStatus['${dk}_${med.id}_morning'] = true;
        _takenTimes['${dk}_${med.id}_morning'] =
            DateTime(today.year, today.month, today.day, 7, 5);
      }
    }
  }

  // ── Build ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhắc nhở uống thuốc'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPrescriptionCard(),
            const SizedBox(height: 12),
            _buildWeekNavigator(),
            const SizedBox(height: 8),
            _buildScheduleTable(),
            const SizedBox(height: 12),
            _buildWeeklySummary(),
            const SizedBox(height: 16),
            _buildMedicineLegend(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Prescription card ────────────────────────────────

  Widget _buildPrescriptionCard() {
    final now = DateTime.now();
    final remaining = _prescription.endDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_information,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _prescription.diseaseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Bác sĩ kê đơn: ${_prescription.doctorName}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Liệu trình: ${_prescription.treatmentDays} ngày '
            '(${_formatDate(_prescription.startDate)} - ${_formatDate(_prescription.endDate)})',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Giờ uống: Sáng ${_prescription.morningTime} - Tối ${_prescription.eveningTime}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            remaining >= 0
                ? 'Còn lại: $remaining ngày'
                : 'Đã kết thúc liệu trình',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Week navigator ───────────────────────────────────

  Widget _buildWeekNavigator() {
    final start = _weekMonday;
    final end = start.add(const Duration(days: 6));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _weekOffset--),
          icon: const Icon(Icons.chevron_left, size: 20),
          label: const Text('Tuần trước',
              style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
        Text(
          '${_formatShortDate(start)} - ${_formatShortDate(end)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        TextButton(
          onPressed: () => setState(() => _weekOffset++),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tuần sau', style: TextStyle(fontSize: 12)),
              Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  // ── Schedule table ───────────────────────────────────

  Widget _buildScheduleTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTableHeader(),
          ...List.generate(7, (i) => _buildDayRow(i)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 68,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                child: Center(
                  child: Text(
                    'Ngày',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade300),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Buổi sáng',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green.shade800,
                      ),
                    ),
                    Text(
                      _prescription.morningTime,
                      style: TextStyle(
                          fontSize: 10, color: Colors.green.shade600),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade300),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Buổi tối',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green.shade800,
                      ),
                    ),
                    Text(
                      _prescription.eveningTime,
                      style: TextStyle(
                          fontSize: 10, color: Colors.green.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(int dayIndex) {
    final day = _weekDays[dayIndex];
    final inTreatment = _isDateInTreatment(day);
    final isToday = _isToday(day);

    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? const Color(0xFF4CAF50).withValues(alpha: 0.06)
            : (dayIndex.isEven ? Colors.grey.shade50 : Colors.white),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cột ngày
            Container(
              width: 68,
              decoration: BoxDecoration(
                border: Border(
                  left: isToday
                      ? const BorderSide(
                          color: Color(0xFF4CAF50), width: 3)
                      : BorderSide.none,
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayNames[dayIndex],
                    style: TextStyle(
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                      color: isToday
                          ? const Color(0xFF4CAF50)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatShortDate(day),
                    style: TextStyle(
                      fontSize: 10,
                      color: isToday
                          ? const Color(0xFF4CAF50)
                          : Colors.grey,
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Hôm nay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(width: 1, color: Colors.grey.shade300),
            // Cột sáng
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: inTreatment
                    ? _buildMedicineCell(day, 'morning')
                    : _buildEmptyCell(),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade300),
            // Cột tối
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: inTreatment
                    ? _buildMedicineCell(day, 'evening')
                    : _buildEmptyCell(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Medicine cell ────────────────────────────────────

  Widget _buildMedicineCell(DateTime date, String period) {
    final status = _getCellStatus(date, period);
    final canToggle = _isToday(date) || !_isPastDate(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._prescription.medicines.map((med) {
          final taken = _isTaken(date, med.id, period);
          final dose =
              period == 'morning' ? med.morningDose : med.eveningDose;

          return InkWell(
            onTap: canToggle
                ? () => _toggleTaken(date, med.id, period)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: med.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${med.shortName} $dose',
                      style: TextStyle(
                        fontSize: 10,
                        color: taken ? Colors.grey : Colors.black87,
                        decoration:
                            taken ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    taken
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 14,
                    color: taken
                        ? const Color(0xFF4CAF50)
                        : (status == 'late' || status == 'late_partial')
                            ? Colors.orange
                            : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        _buildCellStatusBadge(status),
      ],
    );
  }

  Widget _buildCellStatusBadge(String status) {
    String text;
    Color color;
    switch (status) {
      case 'completed':
        text = 'Đã uống đủ';
        color = const Color(0xFF4CAF50);
        break;
      case 'partial':
        text = 'Uống thiếu';
        color = Colors.orange;
        break;
      case 'missed':
        text = 'Bỏ lỡ';
        color = Colors.red;
        break;
      case 'late':
      case 'late_partial':
        text = 'Trễ giờ';
        color = Colors.orange;
        break;
      case 'waiting':
        text = 'Chưa đến giờ';
        color = Colors.blue;
        break;
      default:
        text = 'Sắp tới';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyCell() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Không có lịch',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade400,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // ── Weekly summary ───────────────────────────────────

  Widget _buildWeeklySummary() {
    int totalDoses = 0;
    int takenDoses = 0;
    for (var day in _weekDays) {
      if (_isDateInTreatment(day)) {
        for (var med in _prescription.medicines) {
          totalDoses += 2;
          if (_isTaken(day, med.id, 'morning')) takenDoses++;
          if (_isTaken(day, med.id, 'evening')) takenDoses++;
        }
      }
    }

    final percentage =
        totalDoses > 0 ? (takenDoses / totalDoses * 100).round() : 0;
    final complianceColor = percentage >= 80
        ? const Color(0xFF4CAF50)
        : (percentage >= 50 ? Colors.orange : Colors.red);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: complianceColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: complianceColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            percentage >= 80
                ? Icons.thumb_up_alt_outlined
                : Icons.info_outline,
            size: 18,
            color: complianceColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Tuân thủ tuần này: ',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          Text(
            '$takenDoses/$totalDoses liều ($percentage%)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: complianceColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Medicine legend ──────────────────────────────────

  Widget _buildMedicineLegend() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Chú thích thuốc',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Nhấn vào mũi tên để xem chi tiết từng loại thuốc',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            ..._prescription.medicines
                .map((med) => _buildMedicineExpansionTile(med)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineExpansionTile(PrescriptionMedicine med) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
        leading: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: med.color,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          med.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${med.type} | Sáng: ${med.morningDose} - Tối: ${med.eveningDose}',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        children: [
          _buildDetailRow('Thành phần', med.ingredient),
          _buildDetailRow('Công dụng', med.usage),
          _buildDetailRow('Liều buổi sáng', med.morningDose),
          _buildDetailRow('Liều buổi tối', med.eveningDose),
          _buildDetailRow('Hướng dẫn', med.instruction),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
