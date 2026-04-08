import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Prescription } from '../../prescriptions/entities/prescription.entity';
import { MedicineHistory } from '../../history/entities/history.entity';
import { EmergencyContact } from '../../emergency-contacts/entities/emergency-contact.entity';
import { UserSetting } from '../../settings/entities/user-setting.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @Column({ name: 'full_name' })
  fullName: string;

  @Column({ nullable: true })
  phone: string;

  @Column({ name: 'date_of_birth', type: 'date', nullable: true })
  dateOfBirth: Date;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @OneToMany(() => Prescription, (p) => p.user)
  prescriptions: Prescription[];

  @OneToMany(() => MedicineHistory, (h) => h.user)
  histories: MedicineHistory[];

  @OneToMany(() => EmergencyContact, (c) => c.user)
  emergencyContacts: EmergencyContact[];

  @OneToMany(() => UserSetting, (s) => s.user)
  settings: UserSetting[];
}
