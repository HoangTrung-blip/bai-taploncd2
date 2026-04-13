import { Test, TestingModule } from '@nestjs/testing';
import { MedicinesController } from './medicines.controller';
import { MedicinesService } from './medicines.service';

describe('MedicinesController', () => {
  let controller: MedicinesController;
  let service: jest.Mocked<Partial<MedicinesService>>;

  const userId = 'user-uuid-1';
  const mockMedicine = {
    id: 'med-uuid-1',
    name: 'Omeprazole 20mg',
    type: 'Viên nang cứng',
    dosage: '1 viên',
    totalQuantity: 30,
    remainingQuantity: 25,
    userId,
  };

  beforeEach(async () => {
    service = {
      create: jest.fn().mockResolvedValue(mockMedicine),
      findAll: jest.fn().mockResolvedValue([mockMedicine]),
      findOne: jest.fn().mockResolvedValue(mockMedicine),
      update: jest.fn().mockResolvedValue(mockMedicine),
      remove: jest.fn().mockResolvedValue(undefined),
      getLowStock: jest.fn().mockResolvedValue([]),
      updateStock: jest.fn().mockResolvedValue(mockMedicine),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [MedicinesController],
      providers: [{ provide: MedicinesService, useValue: service }],
    }).compile();

    controller = module.get<MedicinesController>(MedicinesController);
  });

  it('tạo thuốc mới', async () => {
    const dto = { name: 'Test', type: 'Viên', dosage: '1', totalQuantity: 10, remainingQuantity: 10 };
    await controller.create(userId, dto);
    expect(service.create).toHaveBeenCalledWith(userId, dto);
  });

  it('lấy danh sách tất cả thuốc', async () => {
    const result = await controller.findAll(userId);
    expect(service.findAll).toHaveBeenCalledWith(userId);
    expect(result).toEqual([mockMedicine]);
  });

  it('lấy thuốc theo ID', async () => {
    const result = await controller.findOne(userId, 'med-uuid-1');
    expect(service.findOne).toHaveBeenCalledWith(userId, 'med-uuid-1');
    expect(result).toEqual(mockMedicine);
  });

  it('cập nhật thuốc', async () => {
    const dto = { name: 'Updated' };
    await controller.update(userId, 'med-uuid-1', dto);
    expect(service.update).toHaveBeenCalledWith(userId, 'med-uuid-1', dto);
  });

  it('xóa thuốc', async () => {
    await controller.remove(userId, 'med-uuid-1');
    expect(service.remove).toHaveBeenCalledWith(userId, 'med-uuid-1');
  });

  it('lấy danh sách thuốc sắp hết', async () => {
    await controller.getLowStock(userId);
    expect(service.getLowStock).toHaveBeenCalledWith(userId);
  });

  it('cập nhật số lượng thuốc trong kho', async () => {
    await controller.updateStock(userId, 'med-uuid-1', 5);
    expect(service.updateStock).toHaveBeenCalledWith(userId, 'med-uuid-1', 5);
  });
});
