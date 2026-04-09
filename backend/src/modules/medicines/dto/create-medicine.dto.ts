import { IsString, IsInt, IsOptional, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateMedicineDto {
  @ApiProperty({ example: 'Omeprazole 20mg' })
  @IsString()
  name: string;

  @ApiProperty({ example: 'Vien nang cung' })
  @IsString()
  type: string;

  @ApiProperty({ example: '1 vien' })
  @IsString()
  dosage: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  imagePath?: string;

  @ApiProperty({ example: 30 })
  @IsInt()
  @Min(0)
  totalQuantity: number;

  @ApiProperty({ example: 30 })
  @IsInt()
  @Min(0)
  remainingQuantity: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  note?: string;
}
