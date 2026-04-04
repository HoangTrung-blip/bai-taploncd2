import 'package:flutter/material.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final List<_MedicineData> _medicines = [
    _MedicineData(
      name: 'Paracetamol',
      type: 'Viên nén',
      dosage: '1 viên',
      remaining: 20,
      total: 30,
    ),
    _MedicineData(
      name: 'Vitamin C',
      type: 'Viên nén',
      dosage: '2 viên',
      remaining: 15,
      total: 30,
    ),
    _MedicineData(
      name: 'Amoxicillin',
      type: 'Viên nang',
      dosage: '1 viên',
      remaining: 3,
      total: 20,
    ),
    _MedicineData(
      name: 'Omeprazol',
      type: 'Viên nang',
      dosage: '1 viên',
      remaining: 10,
      total: 14,
    ),
    _MedicineData(
      name: 'Siro ho',
      type: 'Siro',
      dosage: '10ml',
      remaining: 80,
      total: 100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách thuốc'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _medicines.length,
        itemBuilder: (context, index) {
          return _buildMedicineCard(_medicines[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-medicine');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMedicineCard(_MedicineData medicine) {
    final double percentage = medicine.remaining / medicine.total;
    final bool isLow = medicine.remaining <= 5;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showMedicineDetail(medicine);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Medicine icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getTypeColor(medicine.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(medicine.type),
                  color: _getTypeColor(medicine.type),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Medicine info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          medicine.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isLow) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Sắp hết',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medicine.type} - Liều: ${medicine.dosage}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    // Stock bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRoundedRect(
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isLow ? Colors.red : Colors.green,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Còn ${medicine.remaining}/${medicine.total}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLow ? Colors.red : Colors.grey[600],
                            fontWeight: isLow ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Viên nén':
        return Icons.medication;
      case 'Viên nang':
        return Icons.medication_outlined;
      case 'Siro':
        return Icons.local_drink;
      case 'Tiêm':
        return Icons.vaccines;
      default:
        return Icons.medical_services;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Viên nén':
        return Colors.blue;
      case 'Viên nang':
        return Colors.purple;
      case 'Siro':
        return Colors.orange;
      case 'Tiêm':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  void _showMedicineDetail(_MedicineData medicine) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                medicine.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Loại thuốc', medicine.type),
              _buildDetailRow('Liều lượng', medicine.dosage),
              _buildDetailRow('Còn lại', '${medicine.remaining} / ${medicine.total}'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Chỉnh sửa'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add-schedule');
                      },
                      icon: const Icon(Icons.alarm_add),
                      label: const Text('Đặt lịch'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _medicines.remove(medicine);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã xóa ${medicine.name}')),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Xóa thuốc', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        ],
      ),
    );
  }
}

class ClipRoundedRect extends StatelessWidget {
  final Widget child;
  const ClipRoundedRect({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: child,
    );
  }
}

class _MedicineData {
  final String name;
  final String type;
  final String dosage;
  int remaining;
  final int total;

  _MedicineData({
    required this.name,
    required this.type,
    required this.dosage,
    required this.remaining,
    required this.total,
  });
}
