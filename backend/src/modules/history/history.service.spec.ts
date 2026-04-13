import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotFoundException } from '@nestjs/common';
import { HistoryService } from './history.service';
import { MedicineHistory, HistoryStatus } from './entities/history.entity';

describe('HistoryService', () => {
  let service: HistoryService;
  let repo: jest.Mocked<Partial<Repository<MedicineHistory>>>;

  const userId = 'user-uuid-1';

  const mockHistory: Partial<MedicineHistory> = {
    id: 'hist-uuid-1',
    medicineId: 'med-uuid-1',
    medicineName: 'Omeprazole 20mg',
    dosage: '1 viên',
    scheduledTime: new Date('2026-04-10T07:00:00Z'),
    takenTime: new Date('2026-04-10T07:05:00Z'),
    status: HistoryStatus.TAKEN,
    period: 'morning',
    userId,
    createdAt: new Date(),
  };

  beforeEach(async () => {
    repo = {
      create: jest.fn().mockImplementation((dto) => ({ ...dto })),
      save: jest.fn().mockImplementation((entity) =>
        Promise.resolve({ ...mockHistory, ...entity }),
      ),
      find: jest.fn().mockResolvedValue([mockHistory]),
      findOne: jest.fn().mockResolvedValue(mockHistory),
      remove: jest.fn().mockResolvedValue(mockHistory),
      createQueryBuilder: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        HistoryService,
        { provide: getRepositoryToken(MedicineHistory), useValue: repo },
      ],
    }).compile();

    service = module.get<HistoryService>(HistoryService);
  });

  describe('create', () => {
    it('tạo lịch sử uống thuốc mới', async () => {
      const dto = {
        medicineId: 'med-uuid-1',
        medicineName: 'Omeprazole 20mg',
        dosage: '1 viên',
        scheduledTime: '2026-04-10T07:00:00Z',
        status: HistoryStatus.TAKEN,
        period: 'morning',
      };

      const result = await service.create(userId, dto);

      expect(repo.create).toHaveBeenCalled();
      expect(repo.save).toHaveBeenCalled();
      expect(result).toBeDefined();
    });
  });

  describe('findAll', () => {
    it('trả về lịch sử uống thuốc có phân trang', async () => {
      const mockQb = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        take: jest.fn().mockReturnThis(),
        getManyAndCount: jest.fn().mockResolvedValue([[mockHistory], 1]),
      };
      (repo.createQueryBuilder as jest.Mock).mockReturnValue(mockQb as any);

      const result = await service.findAll(userId, { page: 1, limit: 20 });

      expect(result.data).toEqual([mockHistory]);
      expect(result.total).toBe(1);
      expect(result.totalPages).toBe(1);
    });

    it('lọc lịch sử theo khoảng thời gian', async () => {
      const mockQb = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        take: jest.fn().mockReturnThis(),
        getManyAndCount: jest.fn().mockResolvedValue([[], 0]),
      };
      (repo.createQueryBuilder as jest.Mock).mockReturnValue(mockQb as any);

      await service.findAll(userId, {
        page: 1,
        limit: 20,
        startDate: '2026-04-01',
        endDate: '2026-04-15',
      });

      expect(mockQb.andWhere).toHaveBeenCalledWith(
        'h.scheduled_time BETWEEN :startDate AND :endDate',
        expect.any(Object),
      );
    });

    it('lọc lịch sử theo thuốc', async () => {
      const mockQb = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        take: jest.fn().mockReturnThis(),
        getManyAndCount: jest.fn().mockResolvedValue([[], 0]),
      };
      (repo.createQueryBuilder as jest.Mock).mockReturnValue(mockQb as any);

      await service.findAll(userId, {
        page: 1,
        limit: 20,
        medicineId: 'med-uuid-1',
      });

      expect(mockQb.andWhere).toHaveBeenCalledWith(
        'h.medicine_id = :medicineId',
        { medicineId: 'med-uuid-1' },
      );
    });
  });

  describe('findOne', () => {
    it('trả về bản ghi lịch sử khi tìm thấy', async () => {
      const result = await service.findOne(userId, 'hist-uuid-1');
      expect(result).toEqual(mockHistory);
    });

    it('trả về lỗi NotFoundException khi không tìm thấy', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);
      await expect(service.findOne(userId, 'invalid-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('markAsTaken', () => {
    it('đánh dấu thuốc đã uống', async () => {
      const result = await service.markAsTaken(userId, 'hist-uuid-1');

      expect(result.status).toBe(HistoryStatus.TAKEN);
      expect(result.takenTime).toBeDefined();
    });
  });

  describe('markAsSkipped', () => {
    it('đánh dấu thuốc đã bỏ qua', async () => {
      const result = await service.markAsSkipped(userId, 'hist-uuid-1');
      expect(result.status).toBe(HistoryStatus.SKIPPED);
    });
  });

  describe('getByDate', () => {
    it('trả về lịch sử uống thuốc theo ngày', async () => {
      const result = await service.getByDate(userId, '2026-04-10');

      expect(repo.find).toHaveBeenCalledWith({
        where: {
          userId,
          scheduledTime: expect.any(Object),
        },
        order: { scheduledTime: 'ASC' },
      });
      expect(result).toEqual([mockHistory]);
    });
  });

  describe('remove', () => {
    it('xóa bản ghi lịch sử thành công', async () => {
      await service.remove(userId, 'hist-uuid-1');
      expect(repo.remove).toHaveBeenCalledWith(mockHistory);
    });
  });
});
