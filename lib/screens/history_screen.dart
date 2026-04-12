import 'package:flutter/material.dart';
import '../models/history.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'all';
  List<MedicineHistory> _historyItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _historyItems = await HistoryService.getAll(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
        limit: 500,
      );
      // Sort newest first
      _historyItems.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
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
        title: const Text('Lịch sử uống thuốc'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bo loc
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('all', 'Tất cả'),
                const SizedBox(width: 8),
                _buildFilterChip('taken', 'Đã uống'),
                const SizedBox(width: 8),
                _buildFilterChip('skipped', 'Bỏ lỡ'),
              ],
            ),
          ),

          // Tong quan
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSummaryCard(),
            ),
          const SizedBox(height: 12),

          // Danh sach lich su
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Lỗi: $_error', textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: _loadHistory, child: const Text('Thử lại')),
                          ],
                        ),
                      )
                    : _historyItems.isEmpty
                        ? Center(
                            child: Text(
                              'Chưa có lịch sử',
                              style: TextStyle(color: Colors.grey[400], fontSize: 16),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadHistory,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _historyItems.length,
                              itemBuilder: (context, index) {
                                final item = _historyItems[index];
                                final showDateHeader = index == 0 ||
                                    _dateKey(_historyItems[index - 1].scheduledTime) !=
                                        _dateKey(item.scheduledTime);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showDateHeader)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12, bottom: 6),
                                        child: Text(
                                          _formatDateHeader(item.scheduledTime),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    _buildHistoryItem(item),
                                  ],
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatDateHeader(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    if (date.isAtSameMomentAs(today)) return 'Hôm nay';
    if (date.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Hôm qua';
    }
    final dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
    return '${dayNames[d.weekday - 1]}, ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
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
        _loadHistory();
      },
      selectedColor: Colors.green.withOpacity(0.2),
      checkmarkColor: Colors.green,
    );
  }

  Widget _buildSummaryCard() {
    final taken = _historyItems.where((i) => i.status == 'taken').length;
    final total = _historyItems.length;
    final skipped = total - taken;
    final percentage = total > 0 ? (taken / total * 100).round() : 0;

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
            width: 56,
            height: 56,
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
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
                  'Đã uống $taken/$total liều',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (skipped > 0)
                  Text(
                    'Thiếu $skipped liều',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(MedicineHistory item) {
    final isTaken = item.status == 'taken';
    final timeStr =
        '${item.scheduledTime.hour.toString().padLeft(2, '0')}:${item.scheduledTime.minute.toString().padLeft(2, '0')}';
    final periodLabel = item.period == 'morning' ? 'Sáng' : 'Tối';
    final periodIcon = item.period == 'morning'
        ? Icons.wb_sunny_outlined
        : Icons.nightlight_round;
    final periodColor = item.period == 'morning'
        ? const Color(0xFF66BB6A)
        : const Color(0xFF5C6BC0);

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
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.medicineName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Icon(periodIcon, size: 14, color: periodColor),
            const SizedBox(width: 4),
            Text(
              '$periodLabel $timeStr',
              style: TextStyle(fontSize: 12, color: periodColor),
            ),
            const SizedBox(width: 8),
            Text(
              item.dosage,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: (isTaken ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            isTaken ? 'Đã uống' : 'Bỏ lỡ',
            style: TextStyle(
              color: isTaken ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
