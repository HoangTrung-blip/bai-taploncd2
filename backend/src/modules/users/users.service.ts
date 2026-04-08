import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async create(data: {
    email: string;
    password: string;
    fullName: string;
  }): Promise<User> {
    const user = this.userRepository.create(data);
    return this.userRepository.save(user);
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }

  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  async update(id: string, data: Partial<User>): Promise<User> {
    await this.userRepository.update(id, data);
    return this.userRepository.findOneOrFail({ where: { id } });
  }

  async getProfile(userId: string) {
    const user = await this.userRepository.findOneOrFail({
      where: { id: userId },
      select: ['id', 'email', 'fullName', 'phone', 'dateOfBirth', 'createdAt'],
    });
    return user;
  }
}
