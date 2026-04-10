import {
  Controller,
  Get,
  Put,
  Patch,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { SettingsService } from './settings.service';
import { UpdateSettingDto, BulkUpdateSettingsDto } from './dto/update-setting.dto';

@ApiTags('Settings')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('settings')
export class SettingsController {
  constructor(private readonly settingsService: SettingsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all user settings' })
  getAll(@CurrentUser('id') userId: string) {
    return this.settingsService.getAll(userId);
  }

  @Get(':key')
  @ApiOperation({ summary: 'Get a specific setting by key' })
  async get(
    @CurrentUser('id') userId: string,
    @Param('key') key: string,
  ) {
    const value = await this.settingsService.get(userId, key);
    return { key, value };
  }

  @Put(':key')
  @ApiOperation({ summary: 'Update a single setting' })
  set(
    @CurrentUser('id') userId: string,
    @Param('key') key: string,
    @Body() dto: UpdateSettingDto,
  ) {
    return this.settingsService.set(userId, key, dto.value);
  }

  @Patch('bulk')
  @ApiOperation({ summary: 'Update multiple settings at once' })
  bulkUpdate(
    @CurrentUser('id') userId: string,
    @Body() dto: BulkUpdateSettingsDto,
  ) {
    return this.settingsService.bulkUpdate(userId, dto);
  }
}
