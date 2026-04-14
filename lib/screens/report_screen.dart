import 'package:flutter/material.dart';
import '../services/report_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedPeriod = 'week';
  bool _isLoading = true;
  String? _error;

  // Data from API
  int _overallScheduled = 0;
  int _overallTaken = 0;
  int _overallRate = 0;
  List<_DayData> _weekData = [];
  List<_MedicineReport> _medicineReports = [];
  int _morningScheduled = 0;
  int _morningTaken = 0;
  int _morningRate = 0;
  int _eveningScheduled = 0;
  int _eveningTaken = 0;
  int _eveningRate = 0;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ReportService.getAdherenceReport(period: _selectedPeriod);

      final overall = data['overall'] as Map<String, dynamic>? ?? {};
      _overallScheduled = overall['totalScheduled'] as int? ?? 0;
      _overallTaken = overall['totalTaken'] as int? ?? 0;
      _overallRate = overall['adherenceRate'] as int? ?? 0;

      final daily = data['daily'] as List? ?? [];
      _weekData = daily.map((d) {
        final m = d as Map<String, dynamic>;
        return _DayData(
          m['dayName'] as String? ?? '',
          m['morningScheduled'] as int? ?? 0,
          m['morningTaken'] as int? ?? 0,
          m['eveningScheduled'] as int? ?? 0,
          m['eveningTaken'] as int? ?? 0,
        );
      }).toList();

      final byMedicine = data['byMedicine'] as List? ?? [];
      _medicineReports = byMedicine.map((m) {
        final r = m as Map<String, dynamic>;
        return _MedicineReport(
          r['medicineName'] as String? ?? '',
          r['totalScheduled'] as int? ?? 0,
          r['totalTaken'] as int? ?? 0,
        );
      }).toList();

      final byPeriod = data['byPeriod'] as Map<String, dynamic>? ?? {};
      final morning = byPeriod['morning'] as Map<String, dynamic>? ?? {};
      _morningScheduled = morning['totalScheduled'] as int? ?? 0;
      _morningTaken = morning['totalTaken'] as int? ?? 0;
      _morningRate = morning['adherenceRate'] as int? ?? 0;

      final evening = byPeriod['evening'] as Map<String, dynamic>? ?? {};
      _eveningScheduled = evening['totalScheduled'] as int? ?? 0;
      _eveningTaken = evening['totalTaken'] as int? ?? 0;
      _eveningRate = evening['adherenceRate'] as int? ?? 0;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo tuân thủ'),
        centerTitle: true,
        actions: [
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
                      ElevatedButton(onPressed: _loadReport, child: const Text('Thử lại')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReport,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildPeriodChip('week', 'Tuần'),
                            const SizedBox(width: 8),
                            _buildPeriodChip('month', 'Tháng'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildOverallCard(),
                        const SizedBox(height: 20),
                        _buildMorningEveningProgress(),
                        const SizedBox(height: 20),
                        const Text(
                          'Biểu đồ tuân thủ theo ngày',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        _buildBarChart(),
                        const SizedBox(height: 12),
                        _buildChartLegend(),
                        const SizedBox(height: 24),
                        const Text(
                          'Theo từng loại thuốc',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        ..._medicineReports.map((r) => _buildMedicineReportCard(r)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPeriodChip(String value, String label) {
    final isSelected = _selectedPeriod == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = value;
        });
        _loadReport();
      },
      selectedColor: Colors.green.withOpacity(0.2),
    );
  }

  Widget _buildOverallCard() {
    final totalScheduled = _overallScheduled;
    final totalTaken = _overallTaken;
    final percentage = _overallRate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Tỉ lệ tuân thủ tổng',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage >= 80 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$totalTaken/$totalScheduled',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            percentage >= 80
                ? 'Tốt! Hãy duy trì phong độ này.'
                : 'Cần cải thiện. Hãy uống thuốc đúng giờ hơn.',
            style: TextStyle(
              color: percentage >= 80 ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMorningEveningProgress() {
    return Row(
      children: [
        Expanded(
          child: _buildPeriodCard(
            'Buổi sáng',
            '07:00',
            _morningRate,
            _morningTaken,
            _morningScheduled,
            const Color(0xFF66BB6A),
            Icons.wb_sunny_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPeriodCard(
            'Buổi tối',
            '19:00',
            _eveningRate,
            _eveningTaken,
            _eveningScheduled,
            const Color(0xFF5C6BC0),
            Icons.nightlight_round,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodCard(
    String title,
    String time,
    int percentage,
    int taken,
    int total,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 12),
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$taken/$total liều',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: percentage >= 80
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              percentage >= 80 ? 'Đủ' : 'Thiếu',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: percentage >= 80 ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _weekData.map((d) {
          final morningPct =
              d.morningTotal > 0 ? d.morningTaken / d.morningTotal : 0.0;
          final eveningPct =
              d.eveningTotal > 0 ? d.eveningTaken / d.eveningTotal : 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${d.morningTaken + d.eveningTaken}/${d.morningTotal + d.eveningTotal}',
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 14,
                    height: (130 * morningPct).clamp(4.0, 130.0),
                    decoration: BoxDecoration(
                      color: morningPct >= 0.8
                          ? const Color(0xFF66BB6A)
                          : const Color(0xFFFFB74D),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3)),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 14,
                    height: (130 * eveningPct).clamp(4.0, 130.0),
                    decoration: BoxDecoration(
                      color: eveningPct >= 0.8
                          ? const Color(0xFF5C6BC0)
                          : const Color(0xFFFF8A65),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                d.day,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(const Color(0xFF66BB6A), 'Sáng'),
        const SizedBox(width: 24),
        _legendItem(const Color(0xFF5C6BC0), 'Tối'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMedicineReportCard(_MedicineReport report) {
    final percentage = report.scheduled > 0
        ? (report.taken / report.scheduled * 100).round()
        : 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medication, color: Colors.teal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${report.taken}/${report.scheduled} liều',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: report.scheduled > 0
                          ? report.taken / report.scheduled
                          : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(percentage >= 80 ? Colors.green : Colors.orange),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$percentage%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: percentage >= 80 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayData {
  final String day;
  final int morningTotal;
  final int morningTaken;
  final int eveningTotal;
  final int eveningTaken;

  _DayData(this.day, this.morningTotal, this.morningTaken, this.eveningTotal,
      this.eveningTaken);
}

class _MedicineReport {
  final String name;
  final int scheduled;
  final int taken;

  _MedicineReport(this.name, this.scheduled, this.taken);
}
