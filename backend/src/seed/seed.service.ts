import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User } from '../modules/users/entities/user.entity';
import { Prescription } from '../modules/prescriptions/entities/prescription.entity';
import { PrescriptionMedicine } from '../modules/prescriptions/entities/prescription-medicine.entity';
import { MedicineHistory, HistoryStatus } from '../modules/history/entities/history.entity';
import { EmergencyContact } from '../modules/emergency-contacts/entities/emergency-contact.entity';
import { UserSetting } from '../modules/settings/entities/user-setting.entity';
import { MedicineSchedule, ScheduleFrequency } from '../modules/schedules/entities/schedule.entity';

@Injectable()
export class SeedService implements OnModuleInit {
  private readonly logger = new Logger(SeedService.name);

  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    @InjectRepository(Prescription)
    private readonly prescriptionRepo: Repository<Prescription>,
    @InjectRepository(PrescriptionMedicine)
    private readonly prescriptionMedicineRepo: Repository<PrescriptionMedicine>,
    @InjectRepository(MedicineHistory)
    private readonly historyRepo: Repository<MedicineHistory>,
    @InjectRepository(EmergencyContact)
    private readonly contactRepo: Repository<EmergencyContact>,
    @InjectRepository(UserSetting)
    private readonly settingRepo: Repository<UserSetting>,
    @InjectRepository(MedicineSchedule)
    private readonly scheduleRepo: Repository<MedicineSchedule>,
  ) {}

  async onModuleInit() {
    if (process.env.NODE_ENV !== 'development') return;

    const userCount = await this.userRepo.count();
    if (userCount > 0) {
      this.logger.log('Database already seeded, skipping...');
      return;
    }

    this.logger.log('Seeding database...');
    await this.seed();
    this.logger.log('Database seeded successfully!');
  }

  async seed() {
    // 1. Create demo user
    const hashedPassword = await bcrypt.hash('123456', 12);
    const user = await this.userRepo.save(
      this.userRepo.create({
        email: 'demo@medicine.app',
        password: hashedPassword,
        fullName: 'Nguyen Van Demo',
        phone: '0901234567',
      }),
    );

    // 2. Create prescription (H. pylori treatment - matches sample_prescription.dart)
    const prescription = await this.prescriptionRepo.save(
      this.prescriptionRepo.create({
        patientName: 'Nguyễn Văn Demo',
        diseaseName: 'Viêm dạ dày - Nhiễm Helicobacter pylori',
        doctorName: 'BS. Nguyễn Văn An',
        startDate: new Date('2026-04-06'),
        treatmentDays: 14,
        morningTime: '07:00',
        eveningTime: '19:00',
        isActive: true,
        userId: user.id,
      }),
    );

    // 3. Create prescription medicines (4 medicines matching Flutter sample)
    const medicinesData = [
      {
        name: 'Omeprazole 20mg',
        shortName: 'Omeprazole',
        type: 'Viên nang cứng',
        ingredient: 'Omeprazole 20mg (dưới dạng vi hạt bao tan trong ruột)',
        usage: 'Ức chế bơm proton, giảm tiết acid dạ dày, hỗ trợ lành vết loét niêm mạc',
        morningDose: '1 viên',
        eveningDose: '1 viên',
        instruction: 'Uống trước ăn 30 phút. Nuốt nguyên viên với nước, không nhai hoặc nghiền.',
        color: '#4CAF50',
      },
      {
        name: 'Amoxicillin 500mg',
        shortName: 'Amoxicillin',
        type: 'Viên nang',
        ingredient: 'Amoxicillin trihydrat tương đương Amoxicillin 500mg',
        usage: 'Kháng sinh nhóm beta-lactam, tiêu diệt vi khuẩn Helicobacter pylori gây viêm loét dạ dày',
        morningDose: '2 viên',
        eveningDose: '2 viên',
        instruction: 'Uống sau ăn no. Nuốt nguyên viên với nhiều nước. Uống đủ liệu trình, không tự ý ngưng.',
        color: '#2196F3',
      },
      {
        name: 'Clarithromycin 500mg',
        shortName: 'Clarithromycin',
        type: 'Viên nén bao phim',
        ingredient: 'Clarithromycin 500mg',
        usage: 'Kháng sinh nhóm macrolid, phối hợp diệt trừ vi khuẩn Helicobacter pylori',
        morningDose: '1 viên',
        eveningDose: '1 viên',
        instruction: 'Uống sau ăn. Nuốt nguyên viên, không nhai, bẻ hoặc nghiền nát.',
        color: '#9C27B0',
      },
      {
        name: 'Gastropulgite',
        shortName: 'Gastropulgite',
        type: 'Gói bột pha hỗn dịch uống',
        ingredient: 'Attapulgite morite hoạt hoá 2,5g; Gel khô nhôm hydroxyd và magnésium carbonat đồng kết tủa 0,5g',
        usage: 'Bảo vệ niêm mạc dạ dày, trung hoà acid dịch vị, giảm đau thượng vị và đầy bụng',
        morningDose: '1 gói',
        eveningDose: '1 gói',
        instruction: 'Pha gói bột với nửa cốc nước, khuấy đều. Uống sau ăn 2 giờ hoặc khi đau dạ dày.',
        color: '#FF9800',
      },
    ];

    const medicines: PrescriptionMedicine[] = [];
    for (const m of medicinesData) {
      const med = await this.prescriptionMedicineRepo.save(
        this.prescriptionMedicineRepo.create({
          ...m,
          prescriptionId: prescription.id,
        }),
      );
      medicines.push(med);
    }

    // 4. Create schedules for each medicine
    for (const med of medicines) {
      await this.scheduleRepo.save(
        this.scheduleRepo.create({
          times: ['07:00', '19:00'],
          frequency: ScheduleFrequency.DAILY,
          startDate: new Date('2026-04-06'),
          endDate: new Date('2026-04-19'),
          isActive: true,
          prescriptionMedicineId: med.id,
          userId: user.id,
          medicineName: med.name,
          dosage: `Sáng: ${med.morningDose}, Tối: ${med.eveningDose}`,
        }),
      );
    }

    // 5. Create history records (past days: all taken, today: 2 morning taken)
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startDate = new Date('2026-04-06');

    const endSeed = today < startDate ? startDate : today;

    for (
      let d = new Date(startDate);
      d <= endSeed;
      d = new Date(d.getTime() + 86400000)
    ) {
      const dateStr = d.toISOString().slice(0, 10);
      const isToday =
        d.getFullYear() === today.getFullYear() &&
        d.getMonth() === today.getMonth() &&
        d.getDate() === today.getDate();

      for (let i = 0; i < medicines.length; i++) {
        const med = medicines[i];

        // Morning entry
        const morningTime = new Date(`${dateStr}T07:00:00`);
        const morningTaken = !isToday || i < 2;
        await this.historyRepo.save(
          this.historyRepo.create({
            medicineId: med.id,
            medicineName: med.name,
            dosage: med.morningDose,
            scheduledTime: morningTime,
            takenTime: morningTaken
              ? new Date(morningTime.getTime() + (3 + i) * 60000)
              : undefined,
            status: morningTaken ? HistoryStatus.TAKEN : HistoryStatus.SKIPPED,
            period: 'morning',
            userId: user.id,
          }),
        );

        // Evening entry (only for past days, not today)
        if (!isToday) {
          const eveningTime = new Date(`${dateStr}T19:00:00`);
          await this.historyRepo.save(
            this.historyRepo.create({
              medicineId: med.id,
              medicineName: med.name,
              dosage: med.eveningDose,
              scheduledTime: eveningTime,
              takenTime: new Date(eveningTime.getTime() + (5 + i) * 60000),
              status: HistoryStatus.TAKEN,
              period: 'evening',
              userId: user.id,
            }),
          );
        }
      }
    }

    // 6. Create emergency contacts
    await this.contactRepo.save([
      this.contactRepo.create({
        name: 'BS. Nguyễn Văn A',
        phone: '0901234567',
        relationship: 'Bác sĩ',
        userId: user.id,
      }),
      this.contactRepo.create({
        name: 'Trần Thị B',
        phone: '0912345678',
        relationship: 'Người thân',
        userId: user.id,
      }),
    ]);

    // 7. Create default settings
    const defaultSettings: Record<string, string> = {
      sound_enabled: 'true',
      vibration_enabled: 'true',
      push_notification_enabled: 'true',
      snooze_minutes: '10',
      cloud_sync_enabled: 'false',
    };

    for (const [key, value] of Object.entries(defaultSettings)) {
      await this.settingRepo.save(
        this.settingRepo.create({ userId: user.id, key, value }),
      );
    }
  }
}
