import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum HistoryStatus {
  TAKEN = 'taken',
  SKIPPED = 'skipped',
  SNOOZED = 'snoozed',
  MISSED = 'missed',
}

@Entity('medicine_histories')
export class MedicineHistory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'medicine_id' })
  medicineId: string;

  @Column({ name: 'medicine_name' })
  medicineName: string;

  @Column()
  dosage: string;

  @Column({ name: 'scheduled_time', type: 'datetime' })
  scheduledTime: Date;

  @Column({ name: 'taken_time', type: 'datetime', nullable: true })
  takenTime: Date;

  @Column({
    type: 'text',
    default: HistoryStatus.TAKEN,
  })
  status: HistoryStatus;

  @Column({ name: 'period', nullable: true })
  period: string; // 'morning' | 'evening'

  @ManyToOne(() => User, (u) => u.histories, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
