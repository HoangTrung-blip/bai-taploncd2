import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../services/prescription_service.dart';

class AddPrescriptionScreen extends StatefulWidget {
  final Prescription? prescription; // null = create, non-null = edit

  const AddPrescriptionScreen({super.key, this.prescription});

  @override
  State<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _diseaseNameController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _treatmentDaysController = TextEditingController();
  final _morningTimeController = TextEditingController();
  final _eveningTimeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  bool _isSaving = false;

  final List<_MedicineFormData> _medicines = [];

  bool get _isEditing => widget.prescription != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.prescription!;
      _patientNameController.text = p.patientName;
      _diseaseNameController.text = p.diseaseName;
      _doctorNameController.text = p.doctorName;
      _treatmentDaysController.text = p.treatmentDays.toString();
      _morningTimeController.text = p.morningTime;
      _eveningTimeController.text = p.eveningTime;
      _notesController.text = p.notes ?? '';
      _startDate = p.startDate;
      for (final med in p.medicines) {
        _medicines.add(_MedicineFormData.fromMedicine(med));
      }
    } else {
      _morningTimeController.text = '07:00';
      _eveningTimeController.text = '19:00';
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _diseaseNameController.dispose();
    _doctorNameController.dispose();
    _treatmentDaysController.dispose();
    _morningTimeController.dispose();
    _eveningTimeController.dispose();
    _notesController.dispose();
    for (final m in _medicines) {
      m.dispose();
    }
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final parts = controller.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 7,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      controller.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  void _addMedicine() {
    setState(() {
      _medicines.add(_MedicineFormData());
    });
  }

  void _removeMedicine(int index) {
    setState(() {
      _medicines[index].dispose();
      _medicines.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 loại thuốc')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'patientName': _patientNameController.text.trim(),
        'diseaseName': _diseaseNameController.text.trim(),
        'doctorName': _doctorNameController.text.trim(),
        'startDate':
            '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
        'treatmentDays': int.parse(_treatmentDaysController.text.trim()),
        'morningTime': _morningTimeController.text.trim(),
        'eveningTime': _eveningTimeController.text.trim(),
        'notes': _notesController.text.trim(),
        'medicines': _medicines.map((m) => m.toJson()).toList(),
      };

      if (_isEditing) {
        await PrescriptionService.update(widget.prescription!.id, data);
      } else {
        await PrescriptionService.create(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Đã cập nhật đơn thuốc'
                : 'Đã thêm đơn thuốc mới'),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa đơn thuốc' : 'Thêm đơn thuốc'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thông tin bệnh nhân ──
              _buildSectionHeader(
                  Icons.person_outline, 'Thông tin bệnh nhân'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _patientNameController,
                label: 'Tên bệnh nhân *',
                hint: 'Nhập tên bệnh nhân',
                icon: Icons.person,
                validator: _requiredValidator('tên bệnh nhân'),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _diseaseNameController,
                label: 'Tên bệnh chính *',
                hint: 'Nhập tên bệnh chính',
                icon: Icons.medical_information,
                validator: _requiredValidator('tên bệnh'),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _doctorNameController,
                label: 'Bác sĩ điều trị *',
                hint: 'Nhập tên bác sĩ',
                icon: Icons.local_hospital,
                validator: _requiredValidator('tên bác sĩ'),
              ),

              const SizedBox(height: 24),

              // ── Lịch điều trị ──
              _buildSectionHeader(
                  Icons.calendar_month_outlined, 'Lịch điều trị'),
              const SizedBox(height: 12),

              // Ngày bắt đầu
              const Text(
                'Ngày bắt đầu *',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickStartDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.date_range),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _treatmentDaysController,
                label: 'Số ngày điều trị *',
                hint: 'Nhập số ngày',
                icon: Icons.timelapse,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số ngày điều trị';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days <= 0) {
                    return 'Vui lòng nhập số ngày hợp lệ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Giờ uống
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(
                      controller: _morningTimeController,
                      label: 'Giờ uống sáng *',
                      icon: Icons.wb_sunny_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeField(
                      controller: _eveningTimeController,
                      label: 'Giờ uống tối *',
                      icon: Icons.nightlight_round,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _notesController,
                label: 'Ghi chú',
                hint: 'Ghi chú thêm (không bắt buộc)',
                icon: Icons.note_alt_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // ── Danh sách thuốc ──
              _buildSectionHeader(Icons.medication_outlined, 'Danh sách thuốc'),
              const SizedBox(height: 4),
              Text(
                'Thêm các loại thuốc trong đơn',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),

              ..._medicines.asMap().entries.map((entry) {
                return _buildMedicineCard(entry.key, entry.value);
              }),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addMedicine,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm thuốc'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Lưu ──
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isEditing ? 'Cập nhật đơn thuốc' : 'Lưu đơn thuốc',
                    style: const TextStyle(fontSize: 16),
                  ),
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
      ),
    );
  }

  // ── Shared widgets ──

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.green.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: maxLines > 1
                ? Padding(
                    padding: EdgeInsets.only(bottom: (maxLines - 1) * 24.0),
                    child: Icon(icon),
                  )
                : Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickTime(controller),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(controller.text),
          ),
        ),
      ],
    );
  }

  String? Function(String?) _requiredValidator(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Vui lòng nhập $fieldName';
      }
      return null;
    };
  }

  // ── Medicine card ──

  Widget _buildMedicineCard(int index, _MedicineFormData med) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: med.selectedColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    med.nameController.text.isNotEmpty
                        ? med.nameController.text
                        : 'Thuốc ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeMedicine(index),
                  tooltip: 'Xoá thuốc',
                ),
              ],
            ),
            const Divider(height: 16),
            _buildMedField(med.nameController, 'Tên thuốc *', 'Tên đầy đủ'),
            _buildMedField(
                med.shortNameController, 'Tên viết tắt *', 'VD: Para'),
            Row(
              children: [
                Expanded(
                  child: _buildMedField(
                      med.typeController, 'Loại *', 'VD: Viên nén'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMedField(
                      med.ingredientController, 'Thành phần', 'VD: 500mg'),
                ),
              ],
            ),
            _buildMedField(
                med.usageController, 'Công dụng', 'VD: Giảm đau, hạ sốt'),
            Row(
              children: [
                Expanded(
                  child: _buildMedField(
                      med.morningDoseController, 'Liều sáng *', 'VD: 1 viên'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMedField(
                      med.eveningDoseController, 'Liều tối *', 'VD: 1 viên'),
                ),
              ],
            ),
            _buildMedField(med.instructionController, 'Hướng dẫn',
                'VD: Uống sau ăn 30 phút'),
            const SizedBox(height: 8),
            const Text(
              'Màu hiển thị',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _colorOptions.map((color) {
                final isSelected = med.selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () => setState(() => med.selectedColor = color),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedField(
      TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        style: const TextStyle(fontSize: 14),
        validator: label.contains('*')
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bắt buộc';
                }
                return null;
              }
            : null,
      ),
    );
  }

  static const List<Color> _colorOptions = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF009688),
    Color(0xFFFF5722),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFFFFC107),
  ];
}

// ── Medicine form data holder ──

class _MedicineFormData {
  final nameController = TextEditingController();
  final shortNameController = TextEditingController();
  final typeController = TextEditingController();
  final ingredientController = TextEditingController();
  final usageController = TextEditingController();
  final morningDoseController = TextEditingController();
  final eveningDoseController = TextEditingController();
  final instructionController = TextEditingController();
  Color selectedColor = const Color(0xFF4CAF50);

  _MedicineFormData();

  factory _MedicineFormData.fromMedicine(PrescriptionMedicine med) {
    final data = _MedicineFormData();
    data.nameController.text = med.name;
    data.shortNameController.text = med.shortName;
    data.typeController.text = med.type;
    data.ingredientController.text = med.ingredient;
    data.usageController.text = med.usage;
    data.morningDoseController.text = med.morningDose;
    data.eveningDoseController.text = med.eveningDose;
    data.instructionController.text = med.instruction;
    data.selectedColor = med.color;
    return data;
  }

  Map<String, dynamic> toJson() => {
        'name': nameController.text.trim(),
        'shortName': shortNameController.text.trim(),
        'type': typeController.text.trim(),
        'ingredient': ingredientController.text.trim(),
        'usage': usageController.text.trim(),
        'morningDose': morningDoseController.text.trim(),
        'eveningDose': eveningDoseController.text.trim(),
        'instruction': instructionController.text.trim(),
        'color':
            '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
      };

  void dispose() {
    nameController.dispose();
    shortNameController.dispose();
    typeController.dispose();
    ingredientController.dispose();
    usageController.dispose();
    morningDoseController.dispose();
    eveningDoseController.dispose();
    instructionController.dispose();
  }
}
