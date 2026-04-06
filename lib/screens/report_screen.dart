import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedPeriod = 'week';

  // Dữ liệu giả lập cho biểu đồ
  final Map<String, List<_DayData>> _weekData = {
    'week': [
      _DayData('T2', 3, 3),
      _DayData('T3', 3, 2),
      _DayData('T4', 3, 3),
      _DayData('T5', 3, 1),
      _DayData('T6', 3, 3),
      _DayData('T7', 3, 2),
      _DayData('CN', 3, 3),
    ],
  };

  final List<_MedicineReport> _medicineReports = [
    _MedicineReport('Paracetamol', 14, 12, Colors.blue),
    _MedicineReport('Vitamin C', 14, 10, Colors.orange),
    _MedicineReport('Amoxicillin', 7, 5, Colors.purple),
    _MedicineReport('Omeprazol', 7, 7, Colors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo tuân thủ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Row(
              children: [
                _buildPeriodChip('week', 'Tuần'),
                const SizedBox(width: 8),
                _buildPeriodChip('month', 'Tháng'),
              ],
            ),
            const SizedBox(height: 20),

            // Overall compliance
            _buildOverallCard(),
            const SizedBox(height: 20),

            // Bar chart (simplified)
            const Text(
              'Biểu đồ tuân thủ theo ngày',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildBarChart(),
            const SizedBox(height: 24),

            // Per medicine report
            const Text(
              'Theo từng loại thuốc',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ..._medicineReports.map((r) => _buildMedicineReportCard(r)),
          ],
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
      },
      selectedColor: Colors.green.withOpacity(0.2),
    );
  }

  Widget _buildOverallCard() {
    final totalScheduled = _medicineReports.fold<int>(0, (sum, r) => sum + r.scheduled);
    final totalTaken = _medicineReports.fold<int>(0, (sum, r) => sum + r.taken);
    final percentage = (totalTaken / totalScheduled * 100).round();

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

  Widget _buildBarChart() {
    final data = _weekData['week']!;
    return Container(
      height: 200,
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
        children: data.map((d) {
          final percentage = d.taken / d.total;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${d.taken}/${d.total}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Container(
                width: 30,
                height: 120 * percentage,
                decoration: BoxDecoration(
                  color: percentage >= 0.8
                      ? Colors.green.withOpacity(0.7)
                      : Colors.orange.withOpacity(0.7),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
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

  Widget _buildMedicineReportCard(_MedicineReport report) {
    final percentage = (report.taken / report.scheduled * 100).round();
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
                color: report.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.medication, color: report.color),
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
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: report.taken / report.scheduled,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(report.color),
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
  final int total;
  final int taken;

  _DayData(this.day, this.total, this.taken);
}

class _MedicineReport {
  final String name;
  final int scheduled;
  final int taken;
  final Color color;

  _MedicineReport(this.name, this.scheduled, this.taken, this.color);
}
