import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotFoundException } from '@nestjs/common';
import { PrescriptionsService } from './prescriptions.service';
import { Prescription } from './entities/prescription.entity';
import { PrescriptionMedicine } from './entities/prescription-medicine.entity';

describe('PrescriptionsService', () => {
  let service: PrescriptionsService;
  let prescriptionRepo: jest.Mocked<Partial<Repository<Prescription>>>;
  let medicineRepo: jest.Mocked<Partial<Repository<PrescriptionMedicine>>>;

  const userId = 'user-uuid-1';

  const mockPrescription: Partial<Prescription> = {
    id: 'presc-uuid-1',
    patientName: 'Nguyễn Văn A',
    diseaseName: 'Viêm dạ dày',
    doctorName: 'BS. Trần Văn B',
    startDate: new Date('2026-04-06'),
    treatmentDays: 14,
    morningTime: '07:00',
    eveningTime: '19:00',
    notes: 'Uống đúng giờ',
    isActive: true,
    userId,
    medicines: [],
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    prescriptionRepo = {
      create: jest.fn().mockImplementation((dto) => ({ ...dto })),
      save: jest.fn().mockImplementation((entity) =>
        Promise.resolve({ ...mockPrescription, ...entity }),
      ),
      find: jest.fn().mockResolvedValue([mockPrescription]),
      findOne: jest.fn().mockResolvedValue(mockPrescription),
      remove: jest.fn().mockResolvedValue(mockPrescription),
    };

    medicineRepo = {
      create: jest.fn().mockImplementation((dto) => ({ ...dto })),
      delete: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PrescriptionsService,
        { provide: getRepositoryToken(Prescription), useValue: prescriptionRepo },
        { provide: getRepositoryToken(PrescriptionMedicine), useValue: medicineRepo },
      ],
    }).compile();

    service = module.get<PrescriptionsService>(PrescriptionsService);
  });

  describe('create', () => {
    it('tạo đơn thuốc mới với danh sách thuốc', async () => {
      const dto = {
        patientName: 'Nguyễn Văn A',
        diseaseName: 'Viêm dạ dày',
        doctorName: 'BS. Trần Văn B',
        startDate: '2026-04-06',
        treatmentDays: 14,
        morningTime: '07:00',
        eveningTime: '19:00',
        medicines: [
          {
            name: 'Omeprazole 20mg',
            shortName: 'Omeprazole',
            type: 'Viên nang cứng',
            ingredient: 'Omeprazole 20mg',
            usage: 'Ức chế bơm proton',
            morningDose: '1 viên',
            eveningDose: '1 viên',
            instruction: 'Uống trước ăn 30 phút',
          },
        ],
      };

      const result = await service.create(userId, dto);

      expect(prescriptionRepo.create).toHaveBeenCalled();
      expect(prescriptionRepo.save).toHaveBeenCalled();
      expect(result).toBeDefined();
    });
  });

  describe('findAll', () => {
    it('trả về tất cả đơn thuốc của người dùng', async () => {
      const result = await service.findAll(userId);

      expect(prescriptionRepo.find).toHaveBeenCalledWith({
        where: { userId },
        relations: ['medicines'],
        order: { createdAt: 'DESC' },
      });
      expect(result).toEqual([mockPrescription]);
    });
  });

  describe('findActive', () => {
    it('trả về các đơn thuốc đang hoạt động', async () => {
      const result = await service.findActive(userId);

      expect(prescriptionRepo.find).toHaveBeenCalledWith({
        where: { userId, isActive: true },
        relations: ['medicines'],
        order: { startDate: 'DESC' },
      });
    });
  });

  describe('findOne', () => {
    it('trả về đơn thuốc khi tìm thấy', async () => {
      const result = await service.findOne(userId, 'presc-uuid-1');
      expect(result).toEqual(mockPrescription);
    });

    it('trả về lỗi NotFoundException khi không tìm thấy', async () => {
      (prescriptionRepo.findOne as jest.Mock).mockResolvedValue(null);
      await expect(service.findOne(userId, 'invalid-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('remove', () => {
    it('xóa đơn thuốc thành công', async () => {
      await service.remove(userId, 'presc-uuid-1');
      expect(prescriptionRepo.remove).toHaveBeenCalledWith(mockPrescription);
    });
  });

  describe('deactivate', () => {
    it('vô hiệu hóa đơn thuốc thành công', async () => {
      const result = await service.deactivate(userId, 'presc-uuid-1');
      expect(result.isActive).toBe(false);
    });
  });
});
