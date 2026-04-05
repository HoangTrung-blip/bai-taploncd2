import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'all';

  final List<_HistoryData> _historyItems = [
    _HistoryData(
      medicineName: 'Paracetamol',
      dosage: '1 viên',
      scheduledTime: DateTime.now().subtract(const Duration(hours: 2)),
      takenTime: DateTime.now().subtract(const Duration(hours: 2, minutes: -5)),
      status: 'taken',
    ),
    _HistoryData(
      medicineName: 'Vitamin C',
      dosage: '2 viên',
      scheduledTime: DateTime.now().subtract(const Duration(hours: 5)),
      takenTime: DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
      status: 'taken',
    ),
    _HistoryData(
      medicineName: 'Amoxicillin',
      dosage: '1 viên',
      scheduledTime: DateTime.now().subtract(const Duration(hours: 8)),
      takenTime: null,
      status: 'skipped',
    ),
    _HistoryData(
      medicineName: 'Omeprazol',
      dosage: '1 viên',
      scheduledTime: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      takenTime: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      status: 'taken',
    ),
    _HistoryData(
      medicineName: 'Paracetamol',
      dosage: '1 viên',
      scheduledTime: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
      takenTime: DateTime.now().subtract(const Duration(days: 1, hours: 11, minutes: 50)),
      status: 'taken',
    ),
    _HistoryData(
      medicineName: 'Vitamin C',
      dosage: '2 viên',
      scheduledTime: DateTime.now().subtract(const Duration(days: 1, hours: 16)),
      takenTime: null,
      status: 'skipped',
    ),
    _HistoryData(
      medicineName: 'Siro ho',
      dosage: '10ml',
      scheduledTime: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      takenTime: DateTime.now().subtract(const Duration(days: 2, hours: 5, minutes: 55)),
      status: 'taken',
    ),
  ];

  List<_HistoryData> get _filteredItems {
    if (_selectedFilter == 'all') return _historyItems;
    return _historyItems.where((item) => item.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử uống thuốc'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('all', 'Tất cả'),
                const SizedBox(width: 8),
                _buildFilterChip('taken', 'Đã uống'),
                const SizedBox(width: 8),
                _buildFilterChip('skipped', 'Bỏ qua'),
              ],
            ),
          ),

          // Summary card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSummaryCard(),
          ),
          const SizedBox(height: 12),

          // History list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(_filteredItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: Colors.green.withOpacity(0.2),
      checkmarkColor: Colors.green,
    );
  }

  Widget _buildSummaryCard() {
    final taken = _historyItems.where((i) => i.status == 'taken').length;
    final total = _historyItems.length;
    final percentage = (taken / total * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            percentage >= 80 ? Colors.green : Colors.orange,
            percentage >= 80 ? Colors.green.shade300 : Colors.orange.shade300,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tỉ lệ tuân thủ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Đã uống $taken/$total lần',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(_HistoryData item) {
    final isTaken = item.status == 'taken';
    final timeStr =
        '${item.scheduledTime.hour.toString().padLeft(2, '0')}:${item.scheduledTime.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${item.scheduledTime.day}/${item.scheduledTime.month}/${item.scheduledTime.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (isTaken ? Colors.green : Colors.red).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isTaken ? Icons.check_circle : Icons.cancel,
            color: isTaken ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          item.medicineName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${item.dosage} - $dateStr lúc $timeStr',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Text(
          isTaken ? 'Đã uống' : 'Bỏ qua',
          style: TextStyle(
            color: isTaken ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _HistoryData {
  final String medicineName;
  final String dosage;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final String status;

  _HistoryData({
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
  });
}
