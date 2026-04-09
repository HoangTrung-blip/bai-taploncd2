import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { SchedulesService } from './schedules.service';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import { UpdateScheduleDto } from './dto/update-schedule.dto';

@ApiTags('Schedules')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('schedules')
export class SchedulesController {
  constructor(private readonly schedulesService: SchedulesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new medicine schedule' })
  create(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateScheduleDto,
  ) {
    return this.schedulesService.create(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all schedules' })
  findAll(@CurrentUser('id') userId: string) {
    return this.schedulesService.findAll(userId);
  }

  @Get('active')
  @ApiOperation({ summary: 'Get active schedules' })
  findActive(@CurrentUser('id') userId: string) {
    return this.schedulesService.findActive(userId);
  }

  @Get('today')
  @ApiOperation({ summary: 'Get today\'s schedules' })
  getTodaySchedules(@CurrentUser('id') userId: string) {
    return this.schedulesService.getTodaySchedules(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a schedule by ID' })
  findOne(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.schedulesService.findOne(userId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a schedule' })
  update(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateScheduleDto,
  ) {
    return this.schedulesService.update(userId, id, dto);
  }

  @Patch(':id/toggle')
  @ApiOperation({ summary: 'Toggle schedule active/inactive' })
  toggleActive(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.schedulesService.toggleActive(userId, id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a schedule' })
  remove(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.schedulesService.remove(userId, id);
  }
}
