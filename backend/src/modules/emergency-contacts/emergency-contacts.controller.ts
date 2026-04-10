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
import { EmergencyContactsService } from './emergency-contacts.service';
import { CreateEmergencyContactDto } from './dto/create-emergency-contact.dto';
import { UpdateEmergencyContactDto } from './dto/update-emergency-contact.dto';

@ApiTags('Emergency Contacts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('emergency-contacts')
export class EmergencyContactsController {
  constructor(
    private readonly emergencyContactsService: EmergencyContactsService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create an emergency contact' })
  create(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateEmergencyContactDto,
  ) {
    return this.emergencyContactsService.create(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all emergency contacts' })
  findAll(@CurrentUser('id') userId: string) {
    return this.emergencyContactsService.findAll(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get an emergency contact by ID' })
  findOne(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.emergencyContactsService.findOne(userId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update an emergency contact' })
  update(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateEmergencyContactDto,
  ) {
    return this.emergencyContactsService.update(userId, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete an emergency contact' })
  remove(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.emergencyContactsService.remove(userId, id);
  }
}
