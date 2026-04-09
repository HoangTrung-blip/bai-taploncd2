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
import { MedicinesService } from './medicines.service';
import { CreateMedicineDto } from './dto/create-medicine.dto';
import { UpdateMedicineDto } from './dto/update-medicine.dto';

@ApiTags('Medicines')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('medicines')
export class MedicinesController {
  constructor(private readonly medicinesService: MedicinesService) {}

  @Post()
  @ApiOperation({ summary: 'Add a new medicine to inventory' })
  create(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateMedicineDto,
  ) {
    return this.medicinesService.create(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all medicines' })
  findAll(@CurrentUser('id') userId: string) {
    return this.medicinesService.findAll(userId);
  }

  @Get('low-stock')
  @ApiOperation({ summary: 'Get medicines with low stock (<=5)' })
  getLowStock(@CurrentUser('id') userId: string) {
    return this.medicinesService.getLowStock(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a medicine by ID' })
  findOne(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.medicinesService.findOne(userId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a medicine' })
  update(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateMedicineDto,
  ) {
    return this.medicinesService.update(userId, id, dto);
  }

  @Patch(':id/stock')
  @ApiOperation({ summary: 'Update medicine stock quantity (positive to add, negative to subtract)' })
  updateStock(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body('quantity') quantity: number,
  ) {
    return this.medicinesService.updateStock(userId, id, quantity);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a medicine' })
  remove(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.medicinesService.remove(userId, id);
  }
}
