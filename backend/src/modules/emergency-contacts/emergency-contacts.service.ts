import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EmergencyContact } from './entities/emergency-contact.entity';
import { CreateEmergencyContactDto } from './dto/create-emergency-contact.dto';
import { UpdateEmergencyContactDto } from './dto/update-emergency-contact.dto';

@Injectable()
export class EmergencyContactsService {
  constructor(
    @InjectRepository(EmergencyContact)
    private readonly contactRepo: Repository<EmergencyContact>,
  ) {}

  async create(
    userId: string,
    dto: CreateEmergencyContactDto,
  ): Promise<EmergencyContact> {
    const contact = this.contactRepo.create({ ...dto, userId });
    return this.contactRepo.save(contact);
  }

  async findAll(userId: string): Promise<EmergencyContact[]> {
    return this.contactRepo.find({
      where: { userId },
      order: { name: 'ASC' },
    });
  }

  async findOne(userId: string, id: string): Promise<EmergencyContact> {
    const contact = await this.contactRepo.findOne({
      where: { id, userId },
    });
    if (!contact) {
      throw new NotFoundException('Emergency contact not found');
    }
    return contact;
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateEmergencyContactDto,
  ): Promise<EmergencyContact> {
    await this.findOne(userId, id);
    await this.contactRepo.update({ id, userId }, dto);
    return this.findOne(userId, id);
  }

  async remove(userId: string, id: string): Promise<void> {
    const contact = await this.findOne(userId, id);
    await this.contactRepo.remove(contact);
  }
}
