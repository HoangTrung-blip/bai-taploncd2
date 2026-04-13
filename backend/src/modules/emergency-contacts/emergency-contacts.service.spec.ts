import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotFoundException } from '@nestjs/common';
import { EmergencyContactsService } from './emergency-contacts.service';
import { EmergencyContact } from './entities/emergency-contact.entity';

describe('EmergencyContactsService', () => {
  let service: EmergencyContactsService;
  let repo: jest.Mocked<Partial<Repository<EmergencyContact>>>;

  const userId = 'user-uuid-1';

  const mockContact: Partial<EmergencyContact> = {
    id: 'contact-uuid-1',
    name: 'BS. Nguyễn Văn An',
    phone: '0912345678',
    relationship: 'Bác sĩ',
    userId,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    repo = {
      create: jest.fn().mockImplementation((dto) => ({ ...dto })),
      save: jest.fn().mockImplementation((entity) =>
        Promise.resolve({ ...mockContact, ...entity }),
      ),
      find: jest.fn().mockResolvedValue([mockContact]),
      findOne: jest.fn().mockResolvedValue(mockContact),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
      remove: jest.fn().mockResolvedValue(mockContact),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        EmergencyContactsService,
        { provide: getRepositoryToken(EmergencyContact), useValue: repo },
      ],
    }).compile();

    service = module.get<EmergencyContactsService>(EmergencyContactsService);
  });

  describe('create', () => {
    it('tạo liên hệ khẩn cấp mới', async () => {
      const dto = {
        name: 'Trần Thị C',
        phone: '0987654321',
        relationship: 'Người thân',
      };

      const result = await service.create(userId, dto);

      expect(repo.create).toHaveBeenCalledWith({ ...dto, userId });
      expect(repo.save).toHaveBeenCalled();
      expect(result).toBeDefined();
    });
  });

  describe('findAll', () => {
    it('trả về danh sách liên hệ khẩn cấp', async () => {
      const result = await service.findAll(userId);

      expect(repo.find).toHaveBeenCalledWith({
        where: { userId },
        order: { name: 'ASC' },
      });
      expect(result).toEqual([mockContact]);
    });
  });

  describe('findOne', () => {
    it('trả về liên hệ khi tìm thấy', async () => {
      const result = await service.findOne(userId, 'contact-uuid-1');
      expect(result).toEqual(mockContact);
    });

    it('trả về lỗi NotFoundException khi không tìm thấy', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);
      await expect(service.findOne(userId, 'invalid-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('update', () => {
    it('cập nhật liên hệ khẩn cấp thành công', async () => {
      const dto = { phone: '0999888777' };
      const result = await service.update(userId, 'contact-uuid-1', dto);

      expect(repo.update).toHaveBeenCalledWith(
        { id: 'contact-uuid-1', userId },
        dto,
      );
      expect(result).toBeDefined();
    });
  });

  describe('remove', () => {
    it('xóa liên hệ khẩn cấp thành công', async () => {
      await service.remove(userId, 'contact-uuid-1');
      expect(repo.remove).toHaveBeenCalledWith(mockContact);
    });

    it('trả về lỗi khi xóa liên hệ không tồn tại', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);
      await expect(service.remove(userId, 'invalid-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
