import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ReportsService } from './reports.service';
import { ReportQueryDto } from './dto/report-query.dto';

@ApiTags('Reports')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Get('adherence')
  @ApiOperation({ summary: 'Get adherence report (week/month/custom)' })
  getAdherenceReport(
    @CurrentUser('id') userId: string,
    @Query() query: ReportQueryDto,
  ) {
    return this.reportsService.getAdherenceReport(userId, query);
  }
}
