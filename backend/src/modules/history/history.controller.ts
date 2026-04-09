import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { HistoryService } from './history.service';
import { CreateHistoryDto } from './dto/create-history.dto';
import { UpdateHistoryDto } from './dto/update-history.dto';
import { HistoryQueryDto } from './dto/history-query.dto';

@ApiTags('History')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('history')
export class HistoryController {
  constructor(private readonly historyService: HistoryService) {}

  @Post()
  @ApiOperation({ summary: 'Create a history record' })
  create(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateHistoryDto,
  ) {
    return this.historyService.create(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get medicine history with filters and pagination' })
  findAll(
    @CurrentUser('id') userId: string,
    @Query() query: HistoryQueryDto,
  ) {
    return this.historyService.findAll(userId, query);
  }

  @Get('date/:date')
  @ApiOperation({ summary: 'Get history for a specific date (YYYY-MM-DD)' })
  getByDate(
    @CurrentUser('id') userId: string,
    @Param('date') date: string,
  ) {
    return this.historyService.getByDate(userId, date);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a history record by ID' })
  findOne(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.historyService.findOne(userId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a history record' })
  update(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateHistoryDto,
  ) {
    return this.historyService.update(userId, id, dto);
  }

  @Patch(':id/taken')
  @ApiOperation({ summary: 'Mark medicine as taken' })
  markAsTaken(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.historyService.markAsTaken(userId, id);
  }

  @Patch(':id/skipped')
  @ApiOperation({ summary: 'Mark medicine as skipped' })
  markAsSkipped(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.historyService.markAsSkipped(userId, id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a history record' })
  remove(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.historyService.remove(userId, id);
  }
}
