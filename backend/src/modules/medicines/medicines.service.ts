import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Medicine } from './entities/medicine.entity';
import { CreateMedicineDto } from './dto/create-medicine.dto';
import { UpdateMedicineDto } from './dto/update-medicine.dto';

@Injectable()
export class MedicinesService {
  constructor(
    @InjectRepository(Medicine)
    private readonly medicineRepo: Repository<Medicine>,
  ) {}

  async create(userId: string, dto: CreateMedicineDto): Promise<Medicine> {
    const medicine = this.medicineRepo.create({ ...dto, userId });
    return this.medicineRepo.save(medicine);
  }

  async findAll(userId: string): Promise<Medicine[]> {
    return this.medicineRepo.find({
      where: { userId },
      order: { name: 'ASC' },
    });
  }

  async findOne(userId: string, id: string): Promise<Medicine> {
    const medicine = await this.medicineRepo.findOne({
      where: { id, userId },
    });
    if (!medicine) {
      throw new NotFoundException('Medicine not found');
    }
    return medicine;
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateMedicineDto,
  ): Promise<Medicine> {
    await this.findOne(userId, id);
    await this.medicineRepo.update({ id, userId }, dto);
    return this.findOne(userId, id);
  }

  async remove(userId: string, id: string): Promise<void> {
    const medicine = await this.findOne(userId, id);
    await this.medicineRepo.remove(medicine);
  }

  async getLowStock(userId: string): Promise<Medicine[]> {
    return this.medicineRepo
      .createQueryBuilder('m')
      .where('m.user_id = :userId', { userId })
      .andWhere('m.remaining_quantity <= 5')
      .orderBy('m.remaining_quantity', 'ASC')
      .getMany();
  }

  async updateStock(
    userId: string,
    id: string,
    quantity: number,
  ): Promise<Medicine> {
    const medicine = await this.findOne(userId, id);
    medicine.remainingQuantity = Math.max(0, medicine.remainingQuantity + quantity);
    return this.medicineRepo.save(medicine);
  }
}
