import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotFoundException } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { Notification } from './entities/notification.entity';

describe('NotificationsService', () => {
  let service: NotificationsService;
  let repo: jest.Mocked<Partial<Repository<Notification>>>;

  const userId = 'user-uuid-1';

  const mockNotification: Partial<Notification> = {
    id: 'notif-uuid-1',
    title: 'Nhắc uống thuốc',
    body: 'Đã đến giờ uống Omeprazole 20mg',
    data: undefined,
    isRead: false,
    userId,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    repo = {
      create: jest.fn().mockImplementation((dto) => ({ ...dto })),
      save: jest.fn().mockImplementation((entity) =>
        Promise.resolve({ ...mockNotification, ...entity }),
      ),
      find: jest.fn().mockResolvedValue([mockNotification]),
      findOne: jest.fn().mockResolvedValue(mockNotification),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
      remove: jest.fn().mockResolvedValue(mockNotification),
      count: jest.fn().mockResolvedValue(3),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationsService,
        { provide: getRepositoryToken(Notification), useValue: repo },
      ],
    }).compile();

    service = module.get<NotificationsService>(NotificationsService);
  });

  describe('create', () => {
    it('tạo thông báo mới', async () => {
      const data = {
        userId,
        title: 'Nhắc uống thuốc',
        body: 'Đến giờ uống thuốc sáng',
      };

      const result = await service.create(data);

      expect(repo.create).toHaveBeenCalledWith(data);
      expect(repo.save).toHaveBeenCalled();
      expect(result).toBeDefined();
    });
  });

  describe('findAll', () => {
    it('trả về tất cả thông báo (tối đa 50)', async () => {
      const result = await service.findAll(userId);

      expect(repo.find).toHaveBeenCalledWith({
        where: { userId },
        order: { createdAt: 'DESC' },
        take: 50,
      });
      expect(result).toEqual([mockNotification]);
    });
  });

  describe('findUnread', () => {
    it('trả về các thông báo chưa đọc', async () => {
      const result = await service.findUnread(userId);

      expect(repo.find).toHaveBeenCalledWith({
        where: { userId, isRead: false },
        order: { createdAt: 'DESC' },
      });
    });
  });

  describe('markAsRead', () => {
    it('đánh dấu thông báo đã đọc', async () => {
      const result = await service.markAsRead(userId, 'notif-uuid-1');

      expect(result.isRead).toBe(true);
    });

    it('trả về lỗi khi thông báo không tồn tại', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);

      await expect(
        service.markAsRead(userId, 'invalid-id'),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('markAllAsRead', () => {
    it('đánh dấu tất cả thông báo đã đọc', async () => {
      await service.markAllAsRead(userId);

      expect(repo.update).toHaveBeenCalledWith(
        { userId, isRead: false },
        { isRead: true },
      );
    });
  });

  describe('getUnreadCount', () => {
    it('trả về số lượng thông báo chưa đọc', async () => {
      const result = await service.getUnreadCount(userId);

      expect(repo.count).toHaveBeenCalledWith({
        where: { userId, isRead: false },
      });
      expect(result).toBe(3);
    });
  });

  describe('remove', () => {
    it('xóa thông báo thành công', async () => {
      await service.remove(userId, 'notif-uuid-1');
      expect(repo.remove).toHaveBeenCalledWith(mockNotification);
    });

    it('trả về lỗi khi xóa thông báo không tồn tại', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);
      await expect(service.remove(userId, 'invalid-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
