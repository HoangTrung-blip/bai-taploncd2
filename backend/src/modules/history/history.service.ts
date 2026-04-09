import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { MedicineHistory, HistoryStatus } from './entities/history.entity';
import { CreateHistoryDto } from './dto/create-history.dto';
import { UpdateHistoryDto } from './dto/update-history.dto';
import { HistoryQueryDto } from './dto/history-query.dto';
import { PaginatedResult } from '../../common/dto/paginated-result.dto';

@Injectable()
export class HistoryService {
  constructor(
    @InjectRepository(MedicineHistory)
    private readonly historyRepo: Repository<MedicineHistory>,
  ) {}

  async create(
    userId: string,
    dto: CreateHistoryDto,
  ): Promise<MedicineHistory> {
    const history = this.historyRepo.create({
      medicineId: dto.medicineId,
      medicineName: dto.medicineName,
      dosage: dto.dosage,
      scheduledTime: new Date(dto.scheduledTime),
      takenTime: dto.takenTime ? new Date(dto.takenTime) : undefined,
      status: dto.status,
      period: dto.period,
      userId,
    });
    return this.historyRepo.save(history);
  }

  async findAll(
    userId: string,
    query: HistoryQueryDto,
  ): Promise<PaginatedResult<MedicineHistory>> {
    const { page = 1, limit = 20, startDate, endDate, medicineId, status } = query;

    const qb = this.historyRepo
      .createQueryBuilder('h')
      .where('h.user_id = :userId', { userId });

    if (startDate && endDate) {
      qb.andWhere('h.scheduled_time BETWEEN :startDate AND :endDate', {
        startDate: new Date(startDate),
        endDate: new Date(endDate + 'T23:59:59Z'),
      });
    } else if (startDate) {
      qb.andWhere('h.scheduled_time >= :startDate', {
        startDate: new Date(startDate),
      });
    } else if (endDate) {
      qb.andWhere('h.scheduled_time <= :endDate', {
        endDate: new Date(endDate + 'T23:59:59Z'),
      });
    }

    if (medicineId) {
      qb.andWhere('h.medicine_id = :medicineId', { medicineId });
    }

    if (status) {
      qb.andWhere('h.status = :status', { status });
    }

    qb.orderBy('h.scheduled_time', 'DESC');
    qb.skip((page - 1) * limit).take(limit);

    const [data, total] = await qb.getManyAndCount();

    return {
      data,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(userId: string, id: string): Promise<MedicineHistory> {
    const history = await this.historyRepo.findOne({
      where: { id, userId },
    });
    if (!history) {
      throw new NotFoundException('History record not found');
    }
    return history;
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateHistoryDto,
  ): Promise<MedicineHistory> {
    const history = await this.findOne(userId, id);

    if (dto.status) {
      history.status = dto.status;
    }
    if (dto.takenTime) {
      history.takenTime = new Date(dto.takenTime);
    }

    return this.historyRepo.save(history);
  }

  async markAsTaken(userId: string, id: string): Promise<MedicineHistory> {
    const history = await this.findOne(userId, id);
    history.status = HistoryStatus.TAKEN;
    history.takenTime = new Date();
    return this.historyRepo.save(history);
  }

  async markAsSkipped(userId: string, id: string): Promise<MedicineHistory> {
    const history = await this.findOne(userId, id);
    history.status = HistoryStatus.SKIPPED;
    return this.historyRepo.save(history);
  }

  async getByDate(userId: string, date: string): Promise<MedicineHistory[]> {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    return this.historyRepo.find({
      where: {
        userId,
        scheduledTime: Between(startOfDay, endOfDay),
      },
      order: { scheduledTime: 'ASC' },
    });
  }

  async remove(userId: string, id: string): Promise<void> {
    const history = await this.findOne(userId, id);
    await this.historyRepo.remove(history);
  }
}
