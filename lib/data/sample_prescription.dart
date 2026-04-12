import 'package:flutter/material.dart';
import '../models/prescription.dart';

/// Đơn thuốc thật: Điều trị viêm dạ dày do nhiễm Helicobacter pylori
/// Phác đồ 3 thuốc chuẩn (PPI + 2 kháng sinh) kết hợp thuốc bảo vệ niêm mạc
/// Liệu trình: 14 ngày, chia 2 lần/ngày (sáng - tối)
Prescription createSamplePrescription() {
  return Prescription(
    id: 'rx_001',
    patientName: 'Nguyễn Văn Demo',
    diseaseName: 'Viêm dạ dày - Nhiễm Helicobacter pylori',
    doctorName: 'BS. Nguyễn Văn An',
    startDate: DateTime(2026, 4, 6), // Thứ 2, 06/04/2026
    treatmentDays: 14,
    morningTime: '07:00',
    eveningTime: '19:00',
    medicines: [
      PrescriptionMedicine(
        id: 'med_01',
        name: 'Omeprazole 20mg',
        shortName: 'Omeprazole',
        type: 'Viên nang cứng',
        ingredient:
            'Omeprazole 20mg (dưới dạng vi hạt bao tan trong ruột)',
        usage:
            'Ức chế bơm proton, giảm tiết acid dạ dày, hỗ trợ lành vết loét niêm mạc',
        morningDose: '1 viên',
        eveningDose: '1 viên',
        instruction:
            'Uống trước ăn 30 phút. Nuốt nguyên viên với nước, không nhai hoặc nghiền.',
        color: const Color(0xFF4CAF50),
      ),
      PrescriptionMedicine(
        id: 'med_02',
        name: 'Amoxicillin 500mg',
        shortName: 'Amoxicillin',
        type: 'Viên nang',
        ingredient:
            'Amoxicillin trihydrat tương đương Amoxicillin 500mg',
        usage:
            'Kháng sinh nhóm beta-lactam, tiêu diệt vi khuẩn Helicobacter pylori gây viêm loét dạ dày',
        morningDose: '2 viên',
        eveningDose: '2 viên',
        instruction:
            'Uống sau ăn no. Nuốt nguyên viên với nhiều nước. Uống đủ liệu trình, không tự ý ngưng.',
        color: const Color(0xFF2196F3),
      ),
      PrescriptionMedicine(
        id: 'med_03',
        name: 'Clarithromycin 500mg',
        shortName: 'Clarithromycin',
        type: 'Viên nén bao phim',
        ingredient: 'Clarithromycin 500mg',
        usage:
            'Kháng sinh nhóm macrolid, phối hợp diệt trừ vi khuẩn Helicobacter pylori',
        morningDose: '1 viên',
        eveningDose: '1 viên',
        instruction:
            'Uống sau ăn. Nuốt nguyên viên, không nhai, bẻ hoặc nghiền nát.',
        color: const Color(0xFF9C27B0),
      ),
      PrescriptionMedicine(
        id: 'med_04',
        name: 'Gastropulgite',
        shortName: 'Gastropulgite',
        type: 'Gói bột pha hỗn dịch uống',
        ingredient:
            'Attapulgite morite hoạt hoá 2,5g; Gel khô nhôm hydroxyd và magnésium carbonat đồng kết tủa 0,5g',
        usage:
            'Bảo vệ niêm mạc dạ dày, trung hoà acid dịch vị, giảm đau thượng vị và đầy bụng',
        morningDose: '1 gói',
        eveningDose: '1 gói',
        instruction:
            'Pha gói bột với nửa cốc nước, khuấy đều. Uống sau ăn 2 giờ hoặc khi đau dạ dày.',
        color: const Color(0xFFFF9800),
      ),
    ],
  );
}
