import { IsString, IsEnum, IsDateString, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { HistoryStatus } from '../entities/history.entity';

export class CreateHistoryDto {
  @ApiProperty()
  @IsString()
  medicineId: string;

  @ApiProperty({ example: 'Omeprazole 20mg' })
  @IsString()
  medicineName: string;

  @ApiProperty({ example: '1 vien' })
  @IsString()
  dosage: string;

  @ApiProperty({ example: '2026-04-06T07:00:00Z' })
  @IsDateString()
  scheduledTime: string;

  @ApiPropertyOptional({ example: '2026-04-06T07:05:00Z' })
  @IsOptional()
  @IsDateString()
  takenTime?: string;

  @ApiProperty({ enum: HistoryStatus, example: 'taken' })
  @IsEnum(HistoryStatus)
  status: HistoryStatus;

  @ApiPropertyOptional({ example: 'morning' })
  @IsOptional()
  @IsString()
  period?: string;
}
