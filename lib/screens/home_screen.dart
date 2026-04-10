import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../services/prescription_service.dart';
import '../services/history_service.dart';
import '../services/auth_service.dart';
import 'add_prescription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _weekOffset = 0;
  List<Prescription> _prescriptions = [];
  Prescription? _prescription;
  bool _isLoading = true;
  String? _error;
  final Map<String, bool> _takenStatus = {};
  final Map<String, DateTime> _takenTimes = {};
  // Map history entry id by key for API calls
  final Map<String, String> _historyIds = {};

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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final prescriptions = await PrescriptionService.getActive();
      _prescriptions = prescriptions.take(2).toList();
      if (_prescriptions.isNotEmpty) {
        _prescription = _prescriptions.first;
        await _loadHistoryData();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHistoryData() async {
    if (_prescription == null) return;
    _takenStatus.clear();
    _takenTimes.clear();
    _historyIds.clear();

    try {
      final histories = await HistoryService.getAll(limit: 500);
      for (final h in histories) {
        final date = DateTime(h.scheduledTime.year, h.scheduledTime.month, h.scheduledTime.day);
        final period = h.period ?? (h.scheduledTime.hour < 12 ? 'morning' : 'evening');
        final key = '${_dateKey(date)}_${h.medicineId}_$period';
        _historyIds[key] = h.id;
        if (h.status == 'taken') {
          _takenStatus[key] = true;
          _takenTimes[key] = h.takenTime ?? h.scheduledTime;
        }
      }
    } catch (_) {
      // History loading is non-critical
    }
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
    if (_prescription == null) return false;
    final d = DateTime(date.year, date.month, date.day);
    final start = DateTime(
        _prescription!.startDate.year,
        _prescription!.startDate.month,
        _prescription!.startDate.day);
    final end = DateTime(
        _prescription!.endDate.year,
        _prescription!.endDate.month,
        _prescription!.endDate.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  bool _isDateInTreatmentFor(DateTime date, Prescription prescription) {
    final d = DateTime(date.year, date.month, date.day);
    final start = DateTime(
        prescription.startDate.year,
        prescription.startDate.month,
        prescription.startDate.day);
    final end = DateTime(
        prescription.endDate.year,
        prescription.endDate.month,
        prescription.endDate.day);
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
    // Call API in background
    _syncHistoryEntry(key, medId, date, period);
  }

  Future<void> _syncHistoryEntry(String key, String medId, DateTime date, String period) async {
    try {
      final historyId = _historyIds[key];
      if (historyId != null) {
        if (_takenStatus[key] == true) {
          await HistoryService.markAsTaken(historyId);
        } else {
          await HistoryService.markAsSkipped(historyId);
        }
      }
    } catch (_) {
      // Silently handle - local state is already updated
    }
  }

  String _getCellStatus(DateTime date, String period) {
    if (_prescription == null) return 'upcoming';
    final allTaken =
        _prescription!.medicines.every((m) => _isTaken(date, m.id, period));
    final anyTaken =
        _prescription!.medicines.any((m) => _isTaken(date, m.id, period));

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

  String _getCellStatusFor(DateTime date, String period, Prescription prescription) {
    final allTaken =
        prescription.medicines.every((m) => _isTaken(date, m.id, period));
    final anyTaken =
        prescription.medicines.any((m) => _isTaken(date, m.id, period));
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

  // ── Build ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhắc nhở uống thuốc'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => _showNotificationPanel(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _prescription == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Chưa có đơn thuốc nào'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddPrescriptionScreen(),
                                ),
                              );
                              if (result == true) _loadData();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm đơn thuốc'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPrescriptionCards(),
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
                    ),
    );
  }

  // ── Prescription cards ───────────────────────────────

  Widget _buildPrescriptionCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(2, (index) {
        final p = index < _prescriptions.length ? _prescriptions[index] : null;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 1 ? 8 : 0),
            child: p != null
                ? _buildSinglePrescriptionCard(p, index)
                : _buildEmptyPrescriptionSlot(),
          ),
        );
      }),
    );
  }

  Widget _buildSinglePrescriptionCard(Prescription p, int index) {
    final now = DateTime.now();
    final remaining =
        p.endDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    final gradients = [
      const [Color(0xFF4CAF50), Color(0xFF66BB6A)],
      const [Color(0xFF1976D2), Color(0xFF42A5F5)],
    ];
    final gradient = gradients[index % gradients.length];

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddPrescriptionScreen(prescription: p),
          ),
        );
        if (result == true) _loadData();
      },
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_information,
                  color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                'Đơn ${index + 1}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            p.diseaseName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (p.patientName.isNotEmpty)
            Text(
              'BN: ${p.patientName}',
              style: const TextStyle(color: Colors.white70, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          if (p.patientName.isNotEmpty)
            const SizedBox(height: 2),
          Text(
            'BS: ${p.doctorName}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${_formatDate(p.startDate)} - ${_formatDate(p.endDate)}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            'Sáng ${p.morningTime} · Tối ${p.eveningTime}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Text(
            remaining >= 0 ? 'Còn $remaining ngày' : 'Đã kết thúc',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildEmptyPrescriptionSlot() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddPrescriptionScreen(),
          ),
        );
        if (result == true) _loadData();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Icon(Icons.add_circle_outline, color: Colors.green.shade400, size: 28),
            const SizedBox(height: 8),
            Text(
              'Thêm đơn thuốc',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
          ],
        ),
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
    final p1 = _prescriptions.isNotEmpty ? _prescriptions[0] : null;
    final p2 = _prescriptions.length > 1 ? _prescriptions[1] : null;
    return Container(
      color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 60,
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
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bệnh lý 1',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.green.shade800,
                      ),
                    ),
                    if (p1 != null) ...[
                      Text(
                        p1.diseaseName,
                        style: TextStyle(
                            fontSize: 9, color: Colors.green.shade600),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Sáng ${p1.morningTime} · Tối ${p1.eveningTime}',
                        style: TextStyle(
                            fontSize: 9, color: Colors.green.shade500),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade300),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bệnh lý 2',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: p2 != null
                            ? Colors.blue.shade700
                            : Colors.grey.shade400,
                      ),
                    ),
                    if (p2 != null) ...[
                      Text(
                        p2.diseaseName,
                        style: TextStyle(
                            fontSize: 9, color: Colors.blue.shade500),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Sáng ${p2.morningTime} · Tối ${p2.eveningTime}',
                        style: TextStyle(
                            fontSize: 9, color: Colors.blue.shade400),
                      ),
                    ] else ...[
                      Text(
                        'Không có đơn',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
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
    final isToday = _isToday(day);
    final p1 = _prescriptions.isNotEmpty ? _prescriptions[0] : null;
    final p2 = _prescriptions.length > 1 ? _prescriptions[1] : null;
    final inTreatment1 = p1 != null && _isDateInTreatmentFor(day, p1);
    final inTreatment2 = p2 != null && _isDateInTreatmentFor(day, p2);

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
              width: 60,
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
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Hôm nay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(width: 1, color: Colors.grey.shade300),
            // Cột bệnh lý 1
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: inTreatment1
                    ? _buildPrescriptionCell(day, p1!)
                    : _buildEmptyCell(),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade300),
            // Cột bệnh lý 2
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: p2 == null
                    ? _buildNoSecondPrescriptionCell()
                    : inTreatment2
                        ? _buildPrescriptionCell(day, p2)
                        : _buildEmptyCell(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Prescription cell (per disease column) ──────────

  Widget _buildPrescriptionCell(DateTime date, Prescription prescription) {
    final canToggle = _isToday(date) || !_isPastDate(date);

    Widget buildPeriodBlock(String period, String label, Color labelColor) {
      final status = _getCellStatusFor(date, period, prescription);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          ...prescription.medicines.map((med) {
            final taken = _isTaken(date, med.id, period);
            final dose =
                period == 'morning' ? med.morningDose : med.eveningDose;
            return InkWell(
              onTap: canToggle
                  ? () => _toggleTaken(date, med.id, period)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: med.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${med.shortName} $dose',
                        style: TextStyle(
                          fontSize: 9,
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
                      size: 12,
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
          const SizedBox(height: 2),
          _buildCellStatusBadge(status),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildPeriodBlock(
          'morning',
          'Sáng ${prescription.morningTime}',
          Colors.orange.shade700,
        ),
        const Divider(height: 8, thickness: 0.5),
        buildPeriodBlock(
          'evening',
          'Tối ${prescription.eveningTime}',
          Colors.indigo.shade400,
        ),
      ],
    );
  }

  Widget _buildNoSecondPrescriptionCell() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          '—',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade300,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
    for (final prescription in _prescriptions) {
      for (var day in _weekDays) {
        if (_isDateInTreatmentFor(day, prescription)) {
          for (var med in prescription.medicines) {
            totalDoses += 2;
            if (_isTaken(day, med.id, 'morning')) takenDoses++;
            if (_isTaken(day, med.id, 'evening')) takenDoses++;
          }
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
            ..._prescriptions.asMap().entries.expand((entry) {
              final i = entry.key;
              final p = entry.value;
              return [
                if (i > 0) const Divider(height: 16),
                if (_prescriptions.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Đơn ${i + 1}: ${p.diseaseName}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ...p.medicines.map((med) => _buildMedicineExpansionTile(med)),
              ];
            }),
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

  // ── Notification panel ───────────────────────────────

  void _showNotificationPanel(BuildContext context) {
    final notifications = _buildNotifications();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 8),
                      const Text(
                        'Thông báo & Nhắc nhở',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${notifications.length} mục',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_none,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text(
                                'Không có thông báo mới',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            return notifications[index];
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildNotifications() {
    final notifications = <Widget>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Nhac truoc gio uong sang
    if (now.hour < 7 && _isDateInTreatment(today)) {
      notifications.add(_buildNotificationCard(
        icon: Icons.wb_sunny_outlined,
        color: const Color(0xFF66BB6A),
        title: 'Nhắc nhở buổi sáng',
        subtitle:
            'Còn ${7 - now.hour} giờ nữa đến giờ uống thuốc sáng (${_prescription!.morningTime})',
        time: 'Hôm nay',
        type: 'reminder',
      ));
    }

    // Nhac truoc gio uong toi
    if (now.hour >= 7 && now.hour < 19 && _isDateInTreatment(today)) {
      notifications.add(_buildNotificationCard(
        icon: Icons.nightlight_round,
        color: const Color(0xFF5C6BC0),
        title: 'Nhắc nhở buổi tối',
        subtitle:
            'Còn ${19 - now.hour} giờ nữa đến giờ uống thuốc tối (${_prescription!.eveningTime})',
        time: 'Hôm nay',
        type: 'reminder',
      ));
    }

    // Canh bao thieu lieu sang hom nay
    if (now.hour >= 7 && _isDateInTreatment(today)) {
      final missedMorning = _prescription!.medicines
          .where((m) => !_isTaken(today, m.id, 'morning'))
          .toList();
      if (missedMorning.isNotEmpty) {
        notifications.add(_buildNotificationCard(
          icon: Icons.warning_amber_rounded,
          color: Colors.orange,
          title: 'Thiếu liều sáng',
          subtitle:
              'Bạn chưa uống ${missedMorning.length} thuốc buổi sáng: ${missedMorning.map((m) => m.shortName).join(', ')}',
          time: 'Hôm nay ${_prescription!.morningTime}',
          type: 'warning',
        ));
      }
    }

    // Canh bao thieu lieu toi hom nay
    if (now.hour >= 19 && _isDateInTreatment(today)) {
      final missedEvening = _prescription!.medicines
          .where((m) => !_isTaken(today, m.id, 'evening'))
          .toList();
      if (missedEvening.isNotEmpty) {
        notifications.add(_buildNotificationCard(
          icon: Icons.warning_amber_rounded,
          color: Colors.red,
          title: 'Thiếu liều tối',
          subtitle:
              'Bạn chưa uống ${missedEvening.length} thuốc buổi tối: ${missedEvening.map((m) => m.shortName).join(', ')}',
          time: 'Hôm nay ${_prescription!.eveningTime}',
          type: 'alert',
        ));
      }
    }

    // Thong bao da uong du hom qua
    final yesterday = today.subtract(const Duration(days: 1));
    if (_isDateInTreatment(yesterday)) {
      final allTakenYesterday = _prescription!.medicines.every(
        (m) =>
            _isTaken(yesterday, m.id, 'morning') &&
            _isTaken(yesterday, m.id, 'evening'),
      );
      notifications.add(_buildNotificationCard(
        icon: allTakenYesterday
            ? Icons.check_circle_outline
            : Icons.info_outline,
        color: allTakenYesterday ? Colors.green : Colors.orange,
        title: allTakenYesterday
            ? 'Hôm qua đã uống đủ'
            : 'Hôm qua uống thiếu',
        subtitle: allTakenYesterday
            ? 'Bạn đã tuân thủ đầy đủ liệu trình ngày hôm qua. Tiếp tục phát huy!'
            : 'Có liều thuốc bị thiếu ngày hôm qua. Hãy cố gắng uống đúng giờ hơn.',
        time: 'Hôm qua',
        type: allTakenYesterday ? 'success' : 'warning',
      ));
    }

    // Thong tin lieu trinh
    final remaining = _prescription!.endDate
        .difference(today)
        .inDays;
    if (remaining >= 0) {
      notifications.add(_buildNotificationCard(
        icon: Icons.medical_information,
        color: const Color(0xFF4CAF50),
        title: 'Tiến độ liệu trình',
        subtitle:
            'Còn $remaining ngày trong liệu trình ${_prescription!.treatmentDays} ngày. '
            'Hãy duy trì uống thuốc đều đặn.',
        time: '${_prescription!.diseaseName}',
        type: 'info',
      ));
    }

    return notifications;
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    required String type,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
