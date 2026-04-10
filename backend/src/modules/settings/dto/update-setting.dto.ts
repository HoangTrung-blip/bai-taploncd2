import { IsString, IsObject } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateSettingDto {
  @ApiProperty({ example: 'true' })
  @IsString()
  value: string;
}

export class BulkUpdateSettingsDto {
  @ApiProperty({
    description: 'Key-value pairs of settings to update',
    additionalProperties: { type: 'string' },
    example: {
      sound_enabled: 'true',
      vibration_enabled: 'true',
      push_notification_enabled: 'true',
      snooze_minutes: '10',
      cloud_sync_enabled: 'false',
    },
  })
  @IsObject()
  settings: Record<string, string>;
}
