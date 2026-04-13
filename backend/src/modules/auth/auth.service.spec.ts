import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { ConflictException, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';

jest.mock('bcrypt');

describe('AuthService', () => {
  let service: AuthService;
  let usersService: Record<string, jest.Mock>;
  let jwtService: Record<string, jest.Mock>;

  const mockUser = {
    id: 'user-uuid-1',
    email: 'test@example.com',
    password: '$2b$12$hashedpassword',
    fullName: 'Nguyễn Văn A',
    phone: null,
    dateOfBirth: null,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    prescriptions: [],
    histories: [],
    emergencyContacts: [],
    settings: [],
  };

  beforeEach(async () => {
    usersService = {
      findByEmail: jest.fn(),
      create: jest.fn(),
    };

    jwtService = {
      sign: jest.fn().mockReturnValue('mock-jwt-token'),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UsersService, useValue: usersService },
        { provide: JwtService, useValue: jwtService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('register', () => {
    const registerDto = {
      email: 'newuser@example.com',
      password: 'password123',
      fullName: 'Nguyễn Văn B',
    };

    it('đăng ký thành công với thông tin hợp lệ', async () => {
      usersService.findByEmail.mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('$2b$12$hashedpassword');
      usersService.create.mockResolvedValue({
        ...mockUser,
        id: 'new-user-uuid',
        email: registerDto.email,
        fullName: registerDto.fullName,
      });

      const result = await service.register(registerDto);

      expect(result).toHaveProperty('accessToken', 'mock-jwt-token');
      expect(result.user).toEqual({
        id: 'new-user-uuid',
        email: registerDto.email,
        fullName: registerDto.fullName,
      });
      expect(usersService.findByEmail).toHaveBeenCalledWith(registerDto.email);
      expect(bcrypt.hash).toHaveBeenCalledWith(registerDto.password, 12);
      expect(usersService.create).toHaveBeenCalledWith({
        email: registerDto.email,
        password: '$2b$12$hashedpassword',
        fullName: registerDto.fullName,
      });
    });

    it('trả về lỗi ConflictException khi email đã tồn tại', async () => {
      usersService.findByEmail.mockResolvedValue(mockUser as any);

      await expect(service.register(registerDto)).rejects.toThrow(
        ConflictException,
      );
      expect(usersService.create).not.toHaveBeenCalled();
    });

    it('mã hóa mật khẩu với salt rounds = 12', async () => {
      usersService.findByEmail.mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashed');
      usersService.create.mockResolvedValue({ ...mockUser, password: 'hashed' });

      await service.register(registerDto);

      expect(bcrypt.hash).toHaveBeenCalledWith('password123', 12);
    });
  });

  describe('login', () => {
    const loginDto = {
      email: 'test@example.com',
      password: 'password123',
    };

    it('đăng nhập thành công với thông tin hợp lệ', async () => {
      usersService.findByEmail.mockResolvedValue(mockUser as any);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      const result = await service.login(loginDto);

      expect(result).toHaveProperty('accessToken', 'mock-jwt-token');
      expect(result.user).toEqual({
        id: mockUser.id,
        email: mockUser.email,
        fullName: mockUser.fullName,
      });
    });

    it('trả về lỗi UnauthorizedException khi email không tồn tại', async () => {
      usersService.findByEmail.mockResolvedValue(null);

      await expect(service.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('trả về lỗi UnauthorizedException khi mật khẩu sai', async () => {
      usersService.findByEmail.mockResolvedValue(mockUser as any);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(service.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('so sánh mật khẩu đúng cách', async () => {
      usersService.findByEmail.mockResolvedValue(mockUser as any);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);

      await service.login(loginDto);

      expect(bcrypt.compare).toHaveBeenCalledWith(
        loginDto.password,
        mockUser.password,
      );
    });
  });
});
