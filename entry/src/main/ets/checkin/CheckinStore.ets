import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { readVisits, VisitRecord } from './CheckinRules';

export class CheckinStore {
  private store?: preferences.Preferences;
  private records: VisitRecord[] = [];
  private queue: Promise<void> = Promise.resolve();

  async initialize(context: common.UIAbilityContext): Promise<boolean> {
    this.store = await preferences.getPreferences(context, { name: 'scenic_checkin' });
    const raw = await this.store.get('records', '[]') as string;
    this.records = readVisits(raw);
    AppStorage.setOrCreate('checkinRecords', JSON.stringify(this.records));
    return await this.store.get('enabled', false) as boolean;
  }

  getRecords(): VisitRecord[] {
    return this.records.slice();
  }

  saveEnabled(enabled: boolean): Promise<void> {
    const operation = this.queue.then(async () => {
      const store = this.store;
      if (!store) {
        throw new Error('打卡存储尚未就绪');
      }
      const previous = await store.get('enabled', false);
      try {
        await store.put('enabled', enabled);
        await store.flush();
      } catch (_) {
        await store.put('enabled', previous);
        throw new Error('自动打卡设置保存失败');
      }
    });
    this.queue = operation.then(() => {}, () => {});
    return operation;
  }

  saveVisits(types: number[], timestamp: number): Promise<number[]> {
    const operation = this.queue.then(async (): Promise<number[]> => {
      const store = this.store;
      if (!store) {
        throw new Error('打卡存储尚未就绪');
      }
      const added = types.filter(type => !this.records.some(record => record.scenicType === type));
      if (added.length === 0) {
        return [];
      }
      const next: VisitRecord[] = this.records.slice();
      added.forEach(type => {
        next.push({
          scenicType: type,
          visitedAt: timestamp
        });
      });
      try {
        await store.put('records', JSON.stringify(next));
        await store.flush();
      } catch (error) {
        // 恢复内存缓存，后续 flush 不应意外提交失败记录。
        await store.put('records', JSON.stringify(this.records));
        throw new Error('打卡保存失败');
      }
      this.records = next;
      AppStorage.setOrCreate('checkinRecords', JSON.stringify(next));
      return added;
    });
    this.queue = operation.then(() => {}, () => {});
    return operation;
  }
}
