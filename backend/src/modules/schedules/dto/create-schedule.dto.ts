import {
  IsString,
  IsArray,
  IsEnum,
  IsOptional,
  IsDateString,
  IsBoolean,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ScheduleFrequency } from '../entities/schedule.entity';

export class CreateScheduleDto {
  @ApiProperty({ example: 'Omeprazole 20mg' })
  @IsString()
  medicineName: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  dosage?: string;

  @ApiProperty({ example: ['08:00', '20:00'] })
  @IsArray()
  @IsString({ each: true })
  times: string[];

  @ApiProperty({ enum: ScheduleFrequency, example: 'daily' })
  @IsEnum(ScheduleFrequency)
  frequency: ScheduleFrequency;

  @ApiPropertyOptional({ example: [1, 3, 5] })
  @IsOptional()
  @IsArray()
  weekDays?: number[];

  @ApiProperty({ example: '2026-04-06' })
  @IsDateString()
  startDate: string;

  @ApiPropertyOptional({ example: '2026-04-19' })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  prescriptionMedicineId?: string;
}
