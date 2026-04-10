import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserSetting } from './entities/user-setting.entity';
import { BulkUpdateSettingsDto } from './dto/update-setting.dto';

const DEFAULT_SETTINGS: Record<string, string> = {
  sound_enabled: 'true',
  vibration_enabled: 'true',
  push_notification_enabled: 'true',
  snooze_minutes: '10',
  cloud_sync_enabled: 'false',
};

@Injectable()
export class SettingsService {
  constructor(
    @InjectRepository(UserSetting)
    private readonly settingRepo: Repository<UserSetting>,
  ) {}

  async getAll(userId: string): Promise<Record<string, string>> {
    const settings = await this.settingRepo.find({ where: { userId } });
    const result = { ...DEFAULT_SETTINGS };
    for (const s of settings) {
      result[s.key] = s.value;
    }
    return result;
  }

  async get(userId: string, key: string): Promise<string> {
    const setting = await this.settingRepo.findOne({
      where: { userId, key },
    });
    return setting?.value ?? DEFAULT_SETTINGS[key] ?? '';
  }

  async set(userId: string, key: string, value: string): Promise<UserSetting> {
    let setting = await this.settingRepo.findOne({
      where: { userId, key },
    });

    if (setting) {
      setting.value = value;
    } else {
      setting = this.settingRepo.create({ userId, key, value });
    }

    return this.settingRepo.save(setting);
  }

  async bulkUpdate(
    userId: string,
    dto: BulkUpdateSettingsDto,
  ): Promise<Record<string, string>> {
    for (const [key, value] of Object.entries(dto.settings)) {
      await this.set(userId, key, value);
    }
    return this.getAll(userId);
  }
}
