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
import { PrescriptionsService } from './prescriptions.service';
import { CreatePrescriptionDto } from './dto/create-prescription.dto';
import { UpdatePrescriptionDto } from './dto/update-prescription.dto';

@ApiTags('Prescriptions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('prescriptions')
export class PrescriptionsController {
  constructor(private readonly prescriptionsService: PrescriptionsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new prescription' })
  create(
    @CurrentUser('id') userId: string,
    @Body() dto: CreatePrescriptionDto,
  ) {
    return this.prescriptionsService.create(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all prescriptions' })
  findAll(@CurrentUser('id') userId: string) {
    return this.prescriptionsService.findAll(userId);
  }

  @Get('active')
  @ApiOperation({ summary: 'Get active prescriptions' })
  findActive(@CurrentUser('id') userId: string) {
    return this.prescriptionsService.findActive(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a prescription by ID' })
  findOne(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.prescriptionsService.findOne(userId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a prescription' })
  update(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdatePrescriptionDto,
  ) {
    return this.prescriptionsService.update(userId, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a prescription' })
  remove(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.prescriptionsService.remove(userId, id);
  }

  @Patch(':id/deactivate')
  @ApiOperation({ summary: 'Deactivate a prescription' })
  deactivate(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.prescriptionsService.deactivate(userId, id);
  }
}
