import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

describe('AuthController', () => {
  let controller: AuthController;
  let authService: jest.Mocked<Partial<AuthService>>;

  const mockAuthResult = {
    user: { id: 'uuid-1', email: 'test@example.com', fullName: 'Nguyễn Văn A' },
    accessToken: 'mock-jwt-token',
  };

  beforeEach(async () => {
    authService = {
      register: jest.fn().mockResolvedValue(mockAuthResult),
      login: jest.fn().mockResolvedValue(mockAuthResult),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [{ provide: AuthService, useValue: authService }],
    }).compile();

    controller = module.get<AuthController>(AuthController);
  });

  describe('register', () => {
    it('gọi authService.register với đúng tham số', async () => {
      const dto: RegisterDto = {
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Nguyễn Văn A',
      };

      const result = await controller.register(dto);

      expect(authService.register).toHaveBeenCalledWith(dto);
      expect(result).toEqual(mockAuthResult);
    });
  });

  describe('login', () => {
    it('gọi authService.login với đúng tham số', async () => {
      const dto: LoginDto = {
        email: 'test@example.com',
        password: 'password123',
      };

      const result = await controller.login(dto);

      expect(authService.login).toHaveBeenCalledWith(dto);
      expect(result).toEqual(mockAuthResult);
    });
  });
});
