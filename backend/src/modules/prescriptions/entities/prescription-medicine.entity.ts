import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { Prescription } from './prescription.entity';
import { MedicineSchedule } from '../../schedules/entities/schedule.entity';

@Entity('prescription_medicines')
export class PrescriptionMedicine {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ name: 'short_name' })
  shortName: string;

  @Column()
  type: string;

  @Column({ type: 'text' })
  ingredient: string;

  @Column({ type: 'text' })
  usage: string;

  @Column({ name: 'morning_dose' })
  morningDose: string;

  @Column({ name: 'evening_dose' })
  eveningDose: string;

  @Column({ type: 'text' })
  instruction: string;

  @Column({ default: '#4CAF50' })
  color: string;

  @ManyToOne(() => Prescription, (p) => p.medicines, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'prescription_id' })
  prescription: Prescription;

  @Column({ name: 'prescription_id' })
  prescriptionId: string;

  @OneToMany(() => MedicineSchedule, (s) => s.prescriptionMedicine)
  schedules: MedicineSchedule[];
}
