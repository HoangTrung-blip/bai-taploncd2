import { registerAs } from '@nestjs/config';
import { join } from 'path';

export default registerAs('database', () => ({
  type: 'better-sqlite3' as const,
  database: process.env.DB_DATABASE || join(process.cwd(), 'medicine_reminder.db'),
  autoLoadEntities: true,
  synchronize: process.env.NODE_ENV === 'development',
}));
