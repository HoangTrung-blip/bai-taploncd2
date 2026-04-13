import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SettingsService } from './settings.service';
import { UserSetting } from './entities/user-setting.entity';

describe('SettingsService', () => {
  let service: SettingsService;
  let repo: jest.Mocked<Partial<Repository<UserSetting>>>;

  const userId = 'user-uuid-1';

  const mockSetting: Partial<UserSetting> = {
    id: 'setting-uuid-1',
    key: 'sound_enabled',
    value: 'true',
    userId,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    repo = {
      create: jest.fn().mockImplementation((dto) => ({ ...dto })),
      save: jest.fn().mockImplementation((entity) =>
        Promise.resolve({ ...mockSetting, ...entity }),
      ),
      find: jest.fn().mockResolvedValue([mockSetting]),
      findOne: jest.fn().mockResolvedValue(mockSetting),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SettingsService,
        { provide: getRepositoryToken(UserSetting), useValue: repo },
      ],
    }).compile();

    service = module.get<SettingsService>(SettingsService);
  });

  describe('getAll', () => {
    it('trả về tất cả cài đặt bao gồm giá trị mặc định', async () => {
      const result = await service.getAll(userId);

      expect(result).toHaveProperty('sound_enabled', 'true');
      expect(result).toHaveProperty('vibration_enabled', 'true');
      expect(result).toHaveProperty('push_notification_enabled', 'true');
      expect(result).toHaveProperty('snooze_minutes', '10');
      expect(result).toHaveProperty('cloud_sync_enabled', 'false');
    });
  });

  describe('get', () => {
    it('trả về giá trị cài đặt khi tồn tại', async () => {
      const result = await service.get(userId, 'sound_enabled');
      expect(result).toBe('true');
    });

    it('trả về giá trị mặc định khi cài đặt chưa được lưu', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);

      const result = await service.get(userId, 'vibration_enabled');
      expect(result).toBe('true');
    });

    it('trả về chuỗi rỗng khi không có giá trị mặc định', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);

      const result = await service.get(userId, 'unknown_key');
      expect(result).toBe('');
    });
  });

  describe('set', () => {
    it('cập nhật cài đặt đã tồn tại', async () => {
      const result = await service.set(userId, 'sound_enabled', 'false');

      expect(repo.save).toHaveBeenCalled();
      expect(result).toBeDefined();
    });

    it('tạo cài đặt mới khi chưa tồn tại', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);

      await service.set(userId, 'new_key', 'new_value');

      expect(repo.create).toHaveBeenCalledWith({
        userId,
        key: 'new_key',
        value: 'new_value',
      });
      expect(repo.save).toHaveBeenCalled();
    });
  });

  describe('bulkUpdate', () => {
    it('cập nhật nhiều cài đặt cùng lúc', async () => {
      const dto = {
        settings: {
          sound_enabled: 'false',
          vibration_enabled: 'false',
        },
      };

      const result = await service.bulkUpdate(userId, dto);

      expect(result).toBeDefined();
      expect(repo.findOne).toHaveBeenCalled();
    });
  });
});
