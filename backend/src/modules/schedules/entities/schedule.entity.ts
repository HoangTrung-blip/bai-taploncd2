import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { PrescriptionMedicine } from '../../prescriptions/entities/prescription-medicine.entity';
import { User } from '../../users/entities/user.entity';

export enum ScheduleFrequency {
  DAILY = 'daily',
  ALTERNATE = 'alternate',
  WEEKLY = 'weekly',
}

@Entity('medicine_schedules')
export class MedicineSchedule {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('simple-array')
  times: string[];

  @Column({
    type: 'text',
    default: ScheduleFrequency.DAILY,
  })
  frequency: ScheduleFrequency;

  @Column({ name: 'week_days', type: 'simple-array', nullable: true })
  weekDays: number[];

  @Column({ name: 'start_date', type: 'date' })
  startDate: Date;

  @Column({ name: 'end_date', type: 'date', nullable: true })
  endDate: Date;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @ManyToOne(() => PrescriptionMedicine, (pm) => pm.schedules, {
    onDelete: 'CASCADE',
    nullable: true,
  })
  @JoinColumn({ name: 'prescription_medicine_id' })
  prescriptionMedicine: PrescriptionMedicine;

  @Column({ name: 'prescription_medicine_id', nullable: true })
  prescriptionMedicineId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'medicine_name' })
  medicineName: string;

  @Column({ nullable: true })
  dosage: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
