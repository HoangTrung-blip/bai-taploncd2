import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotFoundException } from '@nestjs/common';
import { MedicinesService } from './medicines.service';
import { Medicine } from './entities/medicine.entity';

describe('MedicinesService', () => {
  let service: MedicinesService;
  let repo: jest.Mocked<Partial<Repository<Medicine>>>;

  const userId = 'user-uuid-1';

  const mockMedicine = {
    id: 'med-uuid-1',
    name: 'Omeprazole 20mg',
    type: 'Viên nang cứng',
    dosage: '1 viên',
    imagePath: null,
    totalQuantity: 30,
    remainingQuantity: 25,
    note: 'Uống trước ăn',
    userId,
    user: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  } as unknown as Medicine;

  beforeEach(async () => {
    repo = {
      create: jest.fn().mockImplementation((dto) => ({ ...dto })),
      save: jest.fn().mockImplementation((entity) => Promise.resolve({ ...mockMedicine, ...entity })),
      find: jest.fn().mockResolvedValue([mockMedicine]),
      findOne: jest.fn().mockResolvedValue(mockMedicine),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
      remove: jest.fn().mockResolvedValue(mockMedicine),
      createQueryBuilder: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MedicinesService,
        { provide: getRepositoryToken(Medicine), useValue: repo },
      ],
    }).compile();

    service = module.get<MedicinesService>(MedicinesService);
  });

  describe('create', () => {
    it('tạo thuốc mới thành công', async () => {
      const dto = {
        name: 'Amoxicillin 500mg',
        type: 'Viên nang',
        dosage: '1 viên',
        totalQuantity: 20,
        remainingQuantity: 20,
      };

      const result = await service.create(userId, dto);

      expect(repo.create).toHaveBeenCalledWith({ ...dto, userId });
      expect(repo.save).toHaveBeenCalled();
      expect(result).toBeDefined();
    });
  });

  describe('findAll', () => {
    it('trả về danh sách thuốc của người dùng', async () => {
      const result = await service.findAll(userId);

      expect(repo.find).toHaveBeenCalledWith({
        where: { userId },
        order: { name: 'ASC' },
      });
      expect(result).toEqual([mockMedicine]);
    });
  });

  describe('findOne', () => {
    it('trả về thuốc khi tìm thấy', async () => {
      const result = await service.findOne(userId, 'med-uuid-1');

      expect(repo.findOne).toHaveBeenCalledWith({
        where: { id: 'med-uuid-1', userId },
      });
      expect(result).toEqual(mockMedicine);
    });

    it('trả về lỗi NotFoundException khi không tìm thấy thuốc', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);

      await expect(service.findOne(userId, 'invalid-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('update', () => {
    it('cập nhật thuốc thành công', async () => {
      const dto = { name: 'Omeprazole 40mg' };

      const result = await service.update(userId, 'med-uuid-1', dto);

      expect(repo.update).toHaveBeenCalledWith(
        { id: 'med-uuid-1', userId },
        dto,
      );
      expect(result).toBeDefined();
    });

    it('trả về lỗi khi cập nhật thuốc không tồn tại', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);

      await expect(
        service.update(userId, 'invalid-id', { name: 'Test' }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('remove', () => {
    it('xóa thuốc thành công', async () => {
      await service.remove(userId, 'med-uuid-1');

      expect(repo.remove).toHaveBeenCalledWith(mockMedicine);
    });

    it('trả về lỗi khi xóa thuốc không tồn tại', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);

      await expect(service.remove(userId, 'invalid-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('getLowStock', () => {
    it('trả về danh sách thuốc sắp hết (số lượng <= 5)', async () => {
      const mockQb = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue([
          { ...mockMedicine, remainingQuantity: 3 },
        ]),
      };
      (repo.createQueryBuilder as jest.Mock).mockReturnValue(mockQb as any);

      const result = await service.getLowStock(userId);

      expect(mockQb.where).toHaveBeenCalledWith('m.user_id = :userId', { userId });
      expect(mockQb.andWhere).toHaveBeenCalledWith('m.remaining_quantity <= 5');
      expect(result).toHaveLength(1);
      expect(result[0].remainingQuantity).toBe(3);
    });
  });

  describe('updateStock', () => {
    it('tăng số lượng thuốc trong kho', async () => {
      const result = await service.updateStock(userId, 'med-uuid-1', 5);

      expect(result.remainingQuantity).toBe(30); // 25 + 5
    });

    it('giảm số lượng thuốc nhưng không xuống dưới 0', async () => {
      const result = await service.updateStock(userId, 'med-uuid-1', -100);

      expect(result.remainingQuantity).toBe(0);
    });
  });
});
