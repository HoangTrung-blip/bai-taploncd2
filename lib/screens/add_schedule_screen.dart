import 'package:flutter/material.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  String _selectedMedicine = 'Paracetamol';
  String _selectedFrequency = 'daily';
  final List<String> _selectedTimes = ['08:00'];
  final List<bool> _selectedWeekDays = [false, true, false, true, false, true, false];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  final List<String> _medicines = [
    'Paracetamol',
    'Vitamin C',
    'Amoxicillin',
    'Omeprazol',
    'Siro ho',
  ];

  final Map<String, String> _frequencyLabels = {
    'daily': 'Hàng ngày',
    'alternate': 'Cách ngày',
    'weekly': 'Theo tuần',
    'interval': 'Theo chu kỳ giờ',
  };

  final List<String> _weekDayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lịch nhắc'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select medicine
            const Text(
              'Chọn thuốc',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMedicine,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.medication),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _medicines.map((m) {
                return DropdownMenuItem(value: m, child: Text(m));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMedicine = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Frequency
            const Text(
              'Tần suất uống',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _frequencyLabels.entries.map((entry) {
                final isSelected = _selectedFrequency == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFrequency = entry.key;
                    });
                  },
                  selectedColor: Colors.green.withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Week days (if weekly)
            if (_selectedFrequency == 'weekly') ...[
              const Text(
                'Chọn các ngày trong tuần',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedWeekDays[index] = !_selectedWeekDays[index];
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedWeekDays[index]
                            ? Colors.green
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _weekDayNames[index],
                          style: TextStyle(
                            color: _selectedWeekDays[index]
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
            ],

            // Times
            const Text(
              'Giờ uống thuốc',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ..._selectedTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.green),
                  title: Text(
                    time,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  trailing: index > 0
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedTimes.removeAt(index);
                            });
                          },
                        )
                      : null,
                  onTap: () => _pickTime(index),
                ),
              );
            }),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedTimes.add('12:00');
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm giờ uống'),
            ),
            const SizedBox(height: 24),

            // Date range
            const Text(
              'Thời gian áp dụng',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateCard(
                    'Từ ngày',
                    _startDate,
                    () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateCard(
                    'Đến ngày',
                    _endDate,
                    () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Preview card
            _buildPreviewCard(),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã lưu lịch nhắc uống thuốc'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.alarm_add),
                label: const Text('Lưu lịch nhắc', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Không giới hạn',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xem trước lịch nhắc',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text('Thuốc: $_selectedMedicine'),
          Text('Tần suất: ${_frequencyLabels[_selectedFrequency]}'),
          Text('Giờ uống: ${_selectedTimes.join(", ")}'),
          if (_selectedFrequency == 'weekly')
            Text(
              'Các ngày: ${_getSelectedDaysText()}',
            ),
        ],
      ),
    );
  }

  String _getSelectedDaysText() {
    final days = <String>[];
    for (int i = 0; i < 7; i++) {
      if (_selectedWeekDays[i]) {
        days.add(_weekDayNames[i]);
      }
    }
    return days.isEmpty ? 'Chưa chọn' : days.join(', ');
  }

  Future<void> _pickTime(int index) async {
    final parts = _selectedTimes[index].split(':');
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
    if (time != null) {
      setState(() {
        _selectedTimes[index] =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }
}
