import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { PrescriptionMedicine } from './prescription-medicine.entity';

@Entity('prescriptions')
export class Prescription {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'patient_name', default: '' })
  patientName: string;

  @Column({ name: 'disease_name' })
  diseaseName: string;

  @Column({ name: 'doctor_name' })
  doctorName: string;

  @Column({ name: 'start_date', type: 'date' })
  startDate: Date;

  @Column({ name: 'treatment_days', type: 'int' })
  treatmentDays: number;

  @Column({ name: 'morning_time' })
  morningTime: string;

  @Column({ name: 'evening_time' })
  eveningTime: string;

  @Column({ nullable: true })
  notes: string;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @ManyToOne(() => User, (u) => u.prescriptions, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;

  @OneToMany(() => PrescriptionMedicine, (pm) => pm.prescription, {
    cascade: true,
    eager: true,
  })
  medicines: PrescriptionMedicine[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
