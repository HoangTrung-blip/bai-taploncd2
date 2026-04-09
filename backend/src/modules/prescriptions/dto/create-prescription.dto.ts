import {
  IsString,
  IsInt,
  IsDateString,
  IsArray,
  ValidateNested,
  IsOptional,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreatePrescriptionMedicineDto {
  @ApiProperty({ example: 'Omeprazole 20mg' })
  @IsString()
  name: string;

  @ApiProperty({ example: 'Omeprazole' })
  @IsString()
  shortName: string;

  @ApiProperty({ example: 'Vien nang cung' })
  @IsString()
  type: string;

  @ApiProperty({ example: 'Omeprazole 20mg' })
  @IsString()
  ingredient: string;

  @ApiProperty({ example: 'Uc che bom proton' })
  @IsString()
  usage: string;

  @ApiProperty({ example: '1 vien' })
  @IsString()
  morningDose: string;

  @ApiProperty({ example: '1 vien' })
  @IsString()
  eveningDose: string;

  @ApiProperty({ example: 'Uong truoc an 30 phut' })
  @IsString()
  instruction: string;

  @ApiPropertyOptional({ example: '#4CAF50' })
  @IsOptional()
  @IsString()
  color?: string;
}

export class CreatePrescriptionDto {
  @ApiProperty({ example: 'Nguyễn Văn A' })
  @IsString()
  patientName: string;

  @ApiProperty({ example: 'Viêm dạ dày - Nhiễm H. pylori' })
  @IsString()
  diseaseName: string;

  @ApiProperty({ example: 'BS. Nguyen Van An' })
  @IsString()
  doctorName: string;

  @ApiProperty({ example: '2026-04-06' })
  @IsDateString()
  startDate: string;

  @ApiProperty({ example: 14 })
  @IsInt()
  treatmentDays: number;

  @ApiProperty({ example: '07:00' })
  @IsString()
  morningTime: string;

  @ApiProperty({ example: '19:00' })
  @IsString()
  eveningTime: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ type: [CreatePrescriptionMedicineDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreatePrescriptionMedicineDto)
  medicines: CreatePrescriptionMedicineDto[];
}
