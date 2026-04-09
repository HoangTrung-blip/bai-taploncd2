import { IsEnum, IsOptional, IsDateString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { HistoryStatus } from '../entities/history.entity';

export class UpdateHistoryDto {
  @ApiPropertyOptional({ enum: HistoryStatus })
  @IsOptional()
  @IsEnum(HistoryStatus)
  status?: HistoryStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  takenTime?: string;
}
