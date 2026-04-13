import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotFoundException } from '@nestjs/common';
import { SchedulesService } from './schedules.service';
import { MedicineSchedule, ScheduleFrequency } from './entities/schedule.entity';

describe('SchedulesService', () => {
  let service: SchedulesService;
  let repo: jest.Mocked<Partial<Repository<MedicineSchedule>>>;

  const userId = 'user-uuid-1';

  const mockSchedule: Partial<MedicineSchedule> = {
    id: 'sched-uuid-1',
    medicineName: 'Omeprazole 20mg',
    dosage: '1 viên',
    times: ['08:00', '20:00'],
    frequency: ScheduleFrequency.DAILY,
    weekDays: undefined,
    startDate: new Date('2026-04-06'),
    endDate: undefined,
    isActive: true,
    userId,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    repo = {
      create: jest.fn().mockImplementation((dto) => ({ ...dto })),
      save: jest.fn().mockImplementation((entity) =>
        Promise.resolve({ ...mockSchedule, ...entity }),
      ),
      find: jest.fn().mockResolvedValue([mockSchedule]),
      findOne: jest.fn().mockResolvedValue(mockSchedule),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
      remove: jest.fn().mockResolvedValue(mockSchedule),
      createQueryBuilder: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SchedulesService,
        { provide: getRepositoryToken(MedicineSchedule), useValue: repo },
      ],
    }).compile();

    service = module.get<SchedulesService>(SchedulesService);
  });

  describe('create', () => {
    it('tạo lịch uống thuốc mới thành công', async () => {
      const dto = {
        medicineName: 'Amoxicillin 500mg',
        dosage: '1 viên',
        times: ['07:00', '19:00'],
        frequency: ScheduleFrequency.DAILY,
        startDate: '2026-04-10',
      };

      const result = await service.create(userId, dto);

      expect(repo.create).toHaveBeenCalled();
      expect(repo.save).toHaveBeenCalled();
      expect(result).toBeDefined();
    });
  });

  describe('findAll', () => {
    it('trả về tất cả lịch uống thuốc của người dùng', async () => {
      const result = await service.findAll(userId);

      expect(repo.find).toHaveBeenCalledWith({
        where: { userId },
        order: { createdAt: 'DESC' },
      });
      expect(result).toEqual([mockSchedule]);
    });
  });

  describe('findActive', () => {
    it('trả về các lịch uống thuốc đang hoạt động', async () => {
      const result = await service.findActive(userId);

      expect(repo.find).toHaveBeenCalledWith({
        where: { userId, isActive: true },
        order: { startDate: 'ASC' },
      });
      expect(result).toEqual([mockSchedule]);
    });
  });

  describe('findOne', () => {
    it('trả về lịch khi tìm thấy', async () => {
      const result = await service.findOne(userId, 'sched-uuid-1');

      expect(result).toEqual(mockSchedule);
    });

    it('trả về lỗi NotFoundException khi không tìm thấy', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);

      await expect(service.findOne(userId, 'invalid-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('update', () => {
    it('cập nhật lịch uống thuốc thành công', async () => {
      const dto = { medicineName: 'Updated Medicine' };
      const result = await service.update(userId, 'sched-uuid-1', dto);

      expect(repo.update).toHaveBeenCalled();
      expect(result).toBeDefined();
    });
  });

  describe('remove', () => {
    it('xóa lịch uống thuốc thành công', async () => {
      await service.remove(userId, 'sched-uuid-1');
      expect(repo.remove).toHaveBeenCalled();
    });
  });

  describe('toggleActive', () => {
    it('đổi trạng thái hoạt động của lịch', async () => {
      const result = await service.toggleActive(userId, 'sched-uuid-1');

      expect(result.isActive).toBe(false); // was true, toggled to false
    });
  });

  describe('getTodaySchedules', () => {
    it('trả về lịch uống thuốc hôm nay', async () => {
      const mockQb = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue([mockSchedule]),
      };
      (repo.createQueryBuilder as jest.Mock).mockReturnValue(mockQb as any);

      const result = await service.getTodaySchedules(userId);

      expect(mockQb.where).toHaveBeenCalledWith('s.user_id = :userId', { userId });
      expect(result).toEqual([mockSchedule]);
    });
  });
});
