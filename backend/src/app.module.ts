import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import databaseConfig from './config/database.config';
import jwtConfig from './config/jwt.config';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { PrescriptionsModule } from './modules/prescriptions/prescriptions.module';
import { MedicinesModule } from './modules/medicines/medicines.module';
import { SchedulesModule } from './modules/schedules/schedules.module';
import { HistoryModule } from './modules/history/history.module';
import { EmergencyContactsModule } from './modules/emergency-contacts/emergency-contacts.module';
import { ReportsModule } from './modules/reports/reports.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { SettingsModule } from './modules/settings/settings.module';
import { SeedModule } from './seed/seed.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [databaseConfig, jwtConfig],
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'better-sqlite3' as const,
        database: configService.get<string>('database.database'),
        autoLoadEntities: true,
        synchronize: configService.get<string>('NODE_ENV') === 'development',
      }),
      inject: [ConfigService],
    }),
    AuthModule,
    UsersModule,
    PrescriptionsModule,
    MedicinesModule,
    SchedulesModule,
    HistoryModule,
    EmergencyContactsModule,
    ReportsModule,
    NotificationsModule,
    SettingsModule,
    SeedModule,
  ],
})
export class AppModule {}
