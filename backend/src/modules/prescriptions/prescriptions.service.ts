import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Prescription } from './entities/prescription.entity';
import { PrescriptionMedicine } from './entities/prescription-medicine.entity';
import { CreatePrescriptionDto } from './dto/create-prescription.dto';
import { UpdatePrescriptionDto } from './dto/update-prescription.dto';

@Injectable()
export class PrescriptionsService {
  constructor(
    @InjectRepository(Prescription)
    private readonly prescriptionRepo: Repository<Prescription>,
    @InjectRepository(PrescriptionMedicine)
    private readonly medicineRepo: Repository<PrescriptionMedicine>,
  ) {}

  async create(
    userId: string,
    dto: CreatePrescriptionDto,
  ): Promise<Prescription> {
    const prescription = this.prescriptionRepo.create({
      patientName: dto.patientName,
      diseaseName: dto.diseaseName,
      doctorName: dto.doctorName,
      startDate: new Date(dto.startDate),
      treatmentDays: dto.treatmentDays,
      morningTime: dto.morningTime,
      eveningTime: dto.eveningTime,
      notes: dto.notes,
      userId,
      medicines: dto.medicines.map((m) =>
        this.medicineRepo.create({
          name: m.name,
          shortName: m.shortName,
          type: m.type,
          ingredient: m.ingredient,
          usage: m.usage,
          morningDose: m.morningDose,
          eveningDose: m.eveningDose,
          instruction: m.instruction,
          color: m.color || '#4CAF50',
        }),
      ),
    });

    return this.prescriptionRepo.save(prescription);
  }

  async findAll(userId: string): Promise<Prescription[]> {
    return this.prescriptionRepo.find({
      where: { userId },
      relations: ['medicines'],
      order: { createdAt: 'DESC' },
    });
  }

  async findActive(userId: string): Promise<Prescription[]> {
    return this.prescriptionRepo.find({
      where: { userId, isActive: true },
      relations: ['medicines'],
      order: { startDate: 'DESC' },
    });
  }

  async findOne(userId: string, id: string): Promise<Prescription> {
    const prescription = await this.prescriptionRepo.findOne({
      where: { id, userId },
      relations: ['medicines'],
    });
    if (!prescription) {
      throw new NotFoundException('Prescription not found');
    }
    return prescription;
  }

  async update(
    userId: string,
    id: string,
    dto: UpdatePrescriptionDto,
  ): Promise<Prescription> {
    const prescription = await this.findOne(userId, id);

    if (dto.medicines) {
      await this.medicineRepo.delete({ prescriptionId: id });
      prescription.medicines = dto.medicines.map((m) =>
        this.medicineRepo.create({
          name: m.name,
          shortName: m.shortName,
          type: m.type,
          ingredient: m.ingredient,
          usage: m.usage,
          morningDose: m.morningDose,
          eveningDose: m.eveningDose,
          instruction: m.instruction,
          color: m.color || '#4CAF50',
          prescriptionId: id,
        }),
      );
    }

    Object.assign(prescription, {
      ...(dto.patientName !== undefined && { patientName: dto.patientName }),
      ...(dto.diseaseName && { diseaseName: dto.diseaseName }),
      ...(dto.doctorName && { doctorName: dto.doctorName }),
      ...(dto.startDate && { startDate: new Date(dto.startDate) }),
      ...(dto.treatmentDays && { treatmentDays: dto.treatmentDays }),
      ...(dto.morningTime && { morningTime: dto.morningTime }),
      ...(dto.eveningTime && { eveningTime: dto.eveningTime }),
      ...(dto.notes !== undefined && { notes: dto.notes }),
    });

    return this.prescriptionRepo.save(prescription);
  }

  async remove(userId: string, id: string): Promise<void> {
    const prescription = await this.findOne(userId, id);
    await this.prescriptionRepo.remove(prescription);
  }

  async deactivate(userId: string, id: string): Promise<Prescription> {
    const prescription = await this.findOne(userId, id);
    prescription.isActive = false;
    return this.prescriptionRepo.save(prescription);
  }
}
