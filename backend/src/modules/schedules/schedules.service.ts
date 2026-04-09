import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MedicineSchedule } from './entities/schedule.entity';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import { UpdateScheduleDto } from './dto/update-schedule.dto';

@Injectable()
export class SchedulesService {
  constructor(
    @InjectRepository(MedicineSchedule)
    private readonly scheduleRepo: Repository<MedicineSchedule>,
  ) {}

  async create(
    userId: string,
    dto: CreateScheduleDto,
  ): Promise<MedicineSchedule> {
    const schedule = this.scheduleRepo.create({
      medicineName: dto.medicineName,
      dosage: dto.dosage,
      times: dto.times,
      frequency: dto.frequency,
      weekDays: dto.weekDays,
      startDate: new Date(dto.startDate),
      endDate: dto.endDate ? new Date(dto.endDate) : undefined,
      prescriptionMedicineId: dto.prescriptionMedicineId,
      userId,
    });
    return this.scheduleRepo.save(schedule);
  }

  async findAll(userId: string): Promise<MedicineSchedule[]> {
    return this.scheduleRepo.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async findActive(userId: string): Promise<MedicineSchedule[]> {
    return this.scheduleRepo.find({
      where: { userId, isActive: true },
      order: { startDate: 'ASC' },
    });
  }

  async findOne(userId: string, id: string): Promise<MedicineSchedule> {
    const schedule = await this.scheduleRepo.findOne({
      where: { id, userId },
    });
    if (!schedule) {
      throw new NotFoundException('Schedule not found');
    }
    return schedule;
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateScheduleDto,
  ): Promise<MedicineSchedule> {
    await this.findOne(userId, id);
    await this.scheduleRepo.update({ id, userId }, {
      ...dto,
      ...(dto.startDate && { startDate: new Date(dto.startDate) }),
      ...(dto.endDate && { endDate: new Date(dto.endDate) }),
    } as Partial<MedicineSchedule>);
    return this.findOne(userId, id);
  }

  async remove(userId: string, id: string): Promise<void> {
    const schedule = await this.findOne(userId, id);
    await this.scheduleRepo.remove(schedule);
  }

  async toggleActive(
    userId: string,
    id: string,
  ): Promise<MedicineSchedule> {
    const schedule = await this.findOne(userId, id);
    schedule.isActive = !schedule.isActive;
    return this.scheduleRepo.save(schedule);
  }

  async getTodaySchedules(userId: string): Promise<MedicineSchedule[]> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return this.scheduleRepo
      .createQueryBuilder('s')
      .where('s.user_id = :userId', { userId })
      .andWhere('s.is_active = true')
      .andWhere('s.start_date <= :today', { today: today.toISOString() })
      .andWhere('(s.end_date IS NULL OR s.end_date >= :today)', {
        today: today.toISOString(),
      })
      .orderBy('s.times', 'ASC')
      .getMany();
  }
}
