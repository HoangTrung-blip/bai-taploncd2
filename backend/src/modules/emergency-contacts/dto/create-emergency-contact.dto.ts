import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateEmergencyContactDto {
  @ApiProperty({ example: 'BS. Nguyen Van An' })
  @IsString()
  name: string;

  @ApiProperty({ example: '0912345678' })
  @IsString()
  phone: string;

  @ApiProperty({ example: 'Bac si' })
  @IsString()
  relationship: string;
}
