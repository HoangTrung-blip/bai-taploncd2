import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ReportsService, AdherenceReport } from './reports.service';
import { MedicineHistory, HistoryStatus } from '../history/entities/history.entity';
import { Prescription } from '../prescriptions/entities/prescription.entity';
import { ReportPeriod } from './dto/report-query.dto';

describe('ReportsService', () => {
  let service: ReportsService;
  let historyRepo: jest.Mocked<Partial<Repository<MedicineHistory>>>;
  let prescriptionRepo: jest.Mocked<Partial<Repository<Prescription>>>;

  const userId = 'user-uuid-1';

  const mockHistories: Partial<MedicineHistory>[] = [
    {
      id: 'h1',
      medicineId: 'med-1',
      medicineName: 'Omeprazole 20mg',
      dosage: '1 viên',
      scheduledTime: new Date('2026-04-10T07:00:00Z'),
      takenTime: new Date('2026-04-10T07:05:00Z'),
      status: HistoryStatus.TAKEN,
      period: 'morning',
      userId,
    },
    {
      id: 'h2',
      medicineId: 'med-1',
      medicineName: 'Omeprazole 20mg',
      dosage: '1 viên',
      scheduledTime: new Date('2026-04-10T19:00:00Z'),
      takenTime: undefined,
      status: HistoryStatus.MISSED,
      period: 'evening',
      userId,
    },
    {
      id: 'h3',
      medicineId: 'med-2',
      medicineName: 'Amoxicillin 500mg',
      dosage: '1 viên',
      scheduledTime: new Date('2026-04-10T07:00:00Z'),
      takenTime: new Date('2026-04-10T07:10:00Z'),
      status: HistoryStatus.TAKEN,
      period: 'morning',
      userId,
    },
  ];

  beforeEach(async () => {
    historyRepo = {
      find: jest.fn().mockResolvedValue(mockHistories),
    };

    prescriptionRepo = {};

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReportsService,
        { provide: getRepositoryToken(MedicineHistory), useValue: historyRepo },
        { provide: getRepositoryToken(Prescription), useValue: prescriptionRepo },
      ],
    }).compile();

    service = module.get<ReportsService>(ReportsService);
  });

  describe('getAdherenceReport', () => {
    it('tính toán đúng tỷ lệ tuân thủ uống thuốc', async () => {
      const result = await service.getAdherenceReport(userId, {
        period: ReportPeriod.CUSTOM,
        startDate: '2026-04-10',
        endDate: '2026-04-10',
      });

      expect(result.overall.totalScheduled).toBe(3);
      expect(result.overall.totalTaken).toBe(2);
      expect(result.overall.totalMissed).toBe(1);
      expect(result.overall.adherenceRate).toBe(67); // 2/3 = 66.67 -> round = 67
    });

    it('phân loại đúng theo buổi sáng và tối', async () => {
      const result = await service.getAdherenceReport(userId, {
        period: ReportPeriod.CUSTOM,
        startDate: '2026-04-10',
        endDate: '2026-04-10',
      });

      expect(result.byPeriod.morning.totalScheduled).toBe(2);
      expect(result.byPeriod.morning.totalTaken).toBe(2);
      expect(result.byPeriod.morning.adherenceRate).toBe(100);
      expect(result.byPeriod.evening.totalScheduled).toBe(1);
      expect(result.byPeriod.evening.totalTaken).toBe(0);
      expect(result.byPeriod.evening.adherenceRate).toBe(0);
    });

    it('phân loại đúng theo từng loại thuốc', async () => {
      const result = await service.getAdherenceReport(userId, {
        period: ReportPeriod.CUSTOM,
        startDate: '2026-04-10',
        endDate: '2026-04-10',
      });

      expect(result.byMedicine).toHaveLength(2);
      const omeprazole = result.byMedicine.find(
        (m) => m.medicineName === 'Omeprazole 20mg',
      )!;
      expect(omeprazole.totalScheduled).toBe(2);
      expect(omeprazole.totalTaken).toBe(1);
      expect(omeprazole.adherenceRate).toBe(50);
    });

    it('báo cáo theo tuần mặc định', async () => {
      const result = await service.getAdherenceReport(userId, {});

      expect(result.period).toBe(ReportPeriod.WEEK);
      expect(result).toHaveProperty('daily');
      expect(result).toHaveProperty('byMedicine');
      expect(result).toHaveProperty('byPeriod');
    });

    it('trả về tỷ lệ 0% khi không có lịch sử', async () => {
      (historyRepo.find as jest.Mock).mockResolvedValue([]);

      const result = await service.getAdherenceReport(userId, {
        period: ReportPeriod.CUSTOM,
        startDate: '2026-04-20',
        endDate: '2026-04-20',
      });

      expect(result.overall.totalScheduled).toBe(0);
      expect(result.overall.adherenceRate).toBe(0);
    });
  });
});
