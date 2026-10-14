import { PositionList } from '../viewmodel/MapModel';
import { PositionType } from '../common/constants/CommonConstants';

export interface VisitRecord {
  scenicType: number;
  visitedAt: number;
}

export interface LocationSample {
  latitude: number;
  longitude: number;
  accuracy: number;
  timestamp: number;
}

interface ScenicMapping {
  type: number;
  id: number;
}

export const SCENIC_MAPPING: ScenicMapping[] = [
  { type: PositionType.BELL_TOWER, id: 0 },
  { type: PositionType.XIAN_CITY_WALL, id: 1 },
  { type: PositionType.DRUM_TOWER, id: 2 },
  { type: PositionType.DATANG_EVERBRIGHT_CITY, id: 3 },
  { type: PositionType.GIANT_WILD_GOOSE_PAGODA, id: 4 },
  { type: PositionType.HUAQING_PALACE, id: 5 },
  { type: PositionType.SHAANXI_HISTORY_MUSEUM, id: 6 },
  { type: PositionType.SMALL_WILD_GOOSE_PAGODA, id: 7 },
  { type: PositionType.TANG_PARADISE, id: 8 },
  { type: PositionType.TERRACOTTA_ARMY_MUSEUM, id: 9 }
];

export function scenicTypeForId(id: number): number {
  return SCENIC_MAPPING.find(item => item.id === id)?.type ?? -1;
}

export function scenicIdForType(type: number): number {
  return SCENIC_MAPPING.find(item => item.type === type)?.id ?? -1;
}

export function readVisits(json: string): VisitRecord[] {
  let decoded: VisitRecord[];
  try {
    decoded = JSON.parse(json) as VisitRecord[];
  } catch (_) {
    return [];
  }
  if (!Array.isArray(decoded)) {
    return [];
  }
  const result: VisitRecord[] = [];
  decoded.forEach((record: VisitRecord) => {
    if (record && scenicIdForType(record.scenicType) >= 0 &&
      Number.isFinite(record.visitedAt) && record.visitedAt > 0 &&
      !result.some(item => item.scenicType === record.scenicType)) {
      result.push({ scenicType: record.scenicType, visitedAt: record.visitedAt });
    }
  });
  return result;
}

export function distanceMeters(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const rad = Math.PI / 180;
  const dLat = (lat2 - lat1) * rad;
  const dLon = (lon2 - lon1) * rad;
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(lat1 * rad) * Math.cos(lat2 * rad) * Math.sin(dLon / 2) ** 2;
  return 6371000 * 2 * Math.asin(Math.sqrt(Math.max(0, Math.min(1, a))));
}

export function validSample(sample: LocationSample, now: number): boolean {
  return Number.isFinite(sample.latitude) && Math.abs(sample.latitude) <= 90 &&
    Number.isFinite(sample.longitude) && Math.abs(sample.longitude) <= 180 &&
    Number.isFinite(sample.accuracy) && sample.accuracy > 0 && sample.accuracy <= 100 &&
    Number.isFinite(sample.timestamp) && now - sample.timestamp >= 0 && now - sample.timestamp <= 30000;
}

export class CheckinRules {
  private candidates: Map<number, number> = new Map();

  reset(): void {
    this.candidates.clear();
  }

  evaluate(sample: LocationSample, records: VisitRecord[], now: number): number[] {
    if (!validSample(sample, now)) {
      this.reset();
      return [];
    }
    const arrived: number[] = [];
    PositionList.forEach(spot => {
      const coordinate = spot.lngLat[0];
      if (!coordinate || records.some(record => record.scenicType === spot.type)) {
        this.candidates.delete(spot.type);
        return;
      }
      const distance = distanceMeters(sample.latitude, sample.longitude, coordinate.latitude, coordinate.longitude);
      if (distance > 500) {
        this.candidates.delete(spot.type);
        return;
      }
      const first = this.candidates.get(spot.type);
      if (first === undefined || sample.timestamp - first > 30000 || sample.timestamp < first) {
        this.candidates.set(spot.type, sample.timestamp);
      } else if (sample.timestamp - first >= 5000) {
        arrived.push(spot.type);
      }
    });
    return arrived;
  }
}
