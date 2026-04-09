import { IsOptional, IsDateString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { PaginationDto } from '../../../common/dto/pagination.dto';

export class HistoryQueryDto extends PaginationDto {
  @ApiPropertyOptional({ example: '2026-04-06' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ example: '2026-04-19' })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional()
  @IsOptional()
  medicineId?: string;

  @ApiPropertyOptional({ enum: ['taken', 'skipped', 'snoozed', 'missed'] })
  @IsOptional()
  status?: string;
}
