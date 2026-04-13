import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UsersService } from './users.service';
import { User } from './entities/user.entity';

describe('UsersService', () => {
  let service: UsersService;
  let repo: jest.Mocked<Partial<Repository<User>>>;

  const mockUser: Partial<User> = {
    id: 'user-uuid-1',
    email: 'test@example.com',
    password: 'hashedpassword',
    fullName: 'Nguyễn Văn A',
    phone: '0912345678',
    dateOfBirth: new Date('1990-01-01'),
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(async () => {
    repo = {
      create: jest.fn().mockImplementation((dto) => ({ ...dto })),
      save: jest.fn().mockImplementation((entity) =>
        Promise.resolve({ ...mockUser, ...entity }),
      ),
      findOne: jest.fn().mockResolvedValue(mockUser),
      findOneOrFail: jest.fn().mockResolvedValue(mockUser),
      update: jest.fn().mockResolvedValue({ affected: 1 }),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: getRepositoryToken(User), useValue: repo },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  describe('create', () => {
    it('tạo người dùng mới', async () => {
      const data = {
        email: 'newuser@example.com',
        password: 'hashedpassword',
        fullName: 'Trần Văn B',
      };

      const result = await service.create(data);

      expect(repo.create).toHaveBeenCalledWith(data);
      expect(repo.save).toHaveBeenCalled();
      expect(result).toBeDefined();
    });
  });

  describe('findByEmail', () => {
    it('trả về người dùng khi tìm thấy email', async () => {
      const result = await service.findByEmail('test@example.com');

      expect(repo.findOne).toHaveBeenCalledWith({
        where: { email: 'test@example.com' },
      });
      expect(result).toEqual(mockUser);
    });

    it('trả về null khi không tìm thấy email', async () => {
      (repo.findOne as jest.Mock).mockResolvedValue(null);

      const result = await service.findByEmail('notfound@example.com');
      expect(result).toBeNull();
    });
  });

  describe('findById', () => {
    it('trả về người dùng khi tìm thấy ID', async () => {
      const result = await service.findById('user-uuid-1');

      expect(repo.findOne).toHaveBeenCalledWith({
        where: { id: 'user-uuid-1' },
      });
      expect(result).toEqual(mockUser);
    });
  });

  describe('update', () => {
    it('cập nhật thông tin người dùng', async () => {
      const data = { fullName: 'Nguyễn Văn B' };

      const result = await service.update('user-uuid-1', data);

      expect(repo.update).toHaveBeenCalledWith('user-uuid-1', data);
      expect(repo.findOneOrFail).toHaveBeenCalledWith({
        where: { id: 'user-uuid-1' },
      });
      expect(result).toBeDefined();
    });
  });

  describe('getProfile', () => {
    it('trả về thông tin hồ sơ người dùng (không bao gồm mật khẩu)', async () => {
      const result = await service.getProfile('user-uuid-1');

      expect(repo.findOneOrFail).toHaveBeenCalledWith({
        where: { id: 'user-uuid-1' },
        select: ['id', 'email', 'fullName', 'phone', 'dateOfBirth', 'createdAt'],
      });
      expect(result).toBeDefined();
    });
  });
});
