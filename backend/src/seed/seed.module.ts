import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SeedService } from './seed.service';
import { User } from '../modules/users/entities/user.entity';
import { Prescription } from '../modules/prescriptions/entities/prescription.entity';
import { PrescriptionMedicine } from '../modules/prescriptions/entities/prescription-medicine.entity';
import { MedicineHistory } from '../modules/history/entities/history.entity';
import { EmergencyContact } from '../modules/emergency-contacts/entities/emergency-contact.entity';
import { UserSetting } from '../modules/settings/entities/user-setting.entity';
import { MedicineSchedule } from '../modules/schedules/entities/schedule.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      User,
      Prescription,
      PrescriptionMedicine,
      MedicineHistory,
      EmergencyContact,
      UserSetting,
      MedicineSchedule,
    ]),
  ],
  providers: [SeedService],
  exports: [SeedService],
})
export class SeedModule {}
