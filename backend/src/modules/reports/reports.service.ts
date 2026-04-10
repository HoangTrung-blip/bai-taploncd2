import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { MedicineHistory, HistoryStatus } from '../history/entities/history.entity';
import { Prescription } from '../prescriptions/entities/prescription.entity';
import { ReportQueryDto, ReportPeriod } from './dto/report-query.dto';

export interface AdherenceReport {
  period: string;
  startDate: string;
  endDate: string;
  overall: {
    totalScheduled: number;
    totalTaken: number;
    totalSkipped: number;
    totalMissed: number;
    adherenceRate: number;
  };
  daily: DailyReport[];
  byMedicine: MedicineReport[];
  byPeriod: { morning: PeriodStats; evening: PeriodStats };
}

export interface DailyReport {
  date: string;
  dayName: string;
  totalScheduled: number;
  morningScheduled: number;
  morningTaken: number;
  eveningScheduled: number;
  eveningTaken: number;
}

export interface MedicineReport {
  medicineId: string;
  medicineName: string;
  totalScheduled: number;
  totalTaken: number;
  adherenceRate: number;
}

export interface PeriodStats {
  totalScheduled: number;
  totalTaken: number;
  adherenceRate: number;
}

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(MedicineHistory)
    private readonly historyRepo: Repository<MedicineHistory>,
    @InjectRepository(Prescription)
    private readonly prescriptionRepo: Repository<Prescription>,
  ) {}

  async getAdherenceReport(
    userId: string,
    query: ReportQueryDto,
  ): Promise<AdherenceReport> {
    const { startDate, endDate } = this.resolveDates(query);

    const histories = await this.historyRepo.find({
      where: {
        userId,
        scheduledTime: Between(startDate, endDate),
      },
      order: { scheduledTime: 'ASC' },
    });

    const totalScheduled = histories.length;
    const totalTaken = histories.filter(
      (h) => h.status === HistoryStatus.TAKEN,
    ).length;
    const totalSkipped = histories.filter(
      (h) => h.status === HistoryStatus.SKIPPED,
    ).length;
    const totalMissed = histories.filter(
      (h) => h.status === HistoryStatus.MISSED,
    ).length;

    // Daily breakdown
    const dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    const dailyMap = new Map<string, DailyReport>();
    const current = new Date(startDate);

    while (current <= endDate) {
      const dateStr = current.toISOString().slice(0, 10);
      dailyMap.set(dateStr, {
        date: dateStr,
        dayName: dayNames[current.getDay()],
        totalScheduled: 0,
        morningScheduled: 0,
        morningTaken: 0,
        eveningScheduled: 0,
        eveningTaken: 0,
      });
      current.setDate(current.getDate() + 1);
    }

    for (const h of histories) {
      const dateStr = new Date(h.scheduledTime).toISOString().slice(0, 10);
      const day = dailyMap.get(dateStr);
      if (!day) continue;

      day.totalScheduled++;
      if (h.period === 'morning') {
        day.morningScheduled++;
        if (h.status === HistoryStatus.TAKEN) day.morningTaken++;
      } else {
        day.eveningScheduled++;
        if (h.status === HistoryStatus.TAKEN) day.eveningTaken++;
      }
    }

    // By medicine
    const medicineMap = new Map<string, MedicineReport>();
    for (const h of histories) {
      if (!medicineMap.has(h.medicineId)) {
        medicineMap.set(h.medicineId, {
          medicineId: h.medicineId,
          medicineName: h.medicineName,
          totalScheduled: 0,
          totalTaken: 0,
          adherenceRate: 0,
        });
      }
      const med = medicineMap.get(h.medicineId)!;
      med.totalScheduled++;
      if (h.status === HistoryStatus.TAKEN) med.totalTaken++;
    }

    const byMedicine = Array.from(medicineMap.values()).map((m) => ({
      ...m,
      adherenceRate: m.totalScheduled > 0
        ? Math.round((m.totalTaken / m.totalScheduled) * 100)
        : 0,
    }));

    // By period
    const morningHistories = histories.filter((h) => h.period === 'morning');
    const eveningHistories = histories.filter((h) => h.period === 'evening');

    const morning: PeriodStats = {
      totalScheduled: morningHistories.length,
      totalTaken: morningHistories.filter((h) => h.status === HistoryStatus.TAKEN).length,
      adherenceRate: morningHistories.length > 0
        ? Math.round(
            (morningHistories.filter((h) => h.status === HistoryStatus.TAKEN).length /
              morningHistories.length) * 100,
          )
        : 0,
    };

    const evening: PeriodStats = {
      totalScheduled: eveningHistories.length,
      totalTaken: eveningHistories.filter((h) => h.status === HistoryStatus.TAKEN).length,
      adherenceRate: eveningHistories.length > 0
        ? Math.round(
            (eveningHistories.filter((h) => h.status === HistoryStatus.TAKEN).length /
              eveningHistories.length) * 100,
          )
        : 0,
    };

    return {
      period: query.period || ReportPeriod.WEEK,
      startDate: startDate.toISOString().slice(0, 10),
      endDate: endDate.toISOString().slice(0, 10),
      overall: {
        totalScheduled,
        totalTaken,
        totalSkipped,
        totalMissed,
        adherenceRate:
          totalScheduled > 0
            ? Math.round((totalTaken / totalScheduled) * 100)
            : 0,
      },
      daily: Array.from(dailyMap.values()),
      byMedicine,
      byPeriod: { morning, evening },
    };
  }

  private resolveDates(query: ReportQueryDto): {
    startDate: Date;
    endDate: Date;
  } {
    if (query.startDate && query.endDate) {
      return {
        startDate: new Date(query.startDate),
        endDate: new Date(query.endDate + 'T23:59:59Z'),
      };
    }

    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    if (query.period === ReportPeriod.MONTH) {
      const startDate = new Date(today);
      startDate.setDate(startDate.getDate() - 30);
      return { startDate, endDate: new Date(today.getTime() + 86400000 - 1) };
    }

    // Default: week
    const monday = new Date(today);
    monday.setDate(monday.getDate() - ((monday.getDay() + 6) % 7));
    const sunday = new Date(monday);
    sunday.setDate(sunday.getDate() + 6);
    sunday.setHours(23, 59, 59, 999);
    return { startDate: monday, endDate: sunday };
  }
}
