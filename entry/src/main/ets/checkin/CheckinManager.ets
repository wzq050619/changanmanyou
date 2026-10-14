import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { promptAction } from '@kit.ArkUI';
import { CheckinRules, LocationSample, validSample } from './CheckinRules';
import { CheckinStore } from './CheckinStore';

class CheckinManager {
  private context?: common.UIAbilityContext;
  private store: CheckinStore = new CheckinStore();
  private rules: CheckinRules = new CheckinRules();
  private ready: Promise<void> = Promise.resolve();
  private initialized: boolean = false;
  private foreground: boolean = false;
  private enabled: boolean = false;
  private listening: boolean = false;
  private busy: boolean = false;
  private generation: number = 0;
  private timer: number = -1;
  private locationCallback?: (location: geoLocationManager.Location) => void;
  private errorCallback?: (error: geoLocationManager.LocationError) => void;
  private switchCallback?: (enabled: boolean) => void;
  private readonly permissions: Permissions[] = [
    'ohos.permission.APPROXIMATELY_LOCATION',
    'ohos.permission.LOCATION'
  ];

  initialize(context: common.UIAbilityContext): void {
    this.context = context;
    AppStorage.setOrCreate('checkinEnabled', false);
    AppStorage.setOrCreate('checkinBusy', false);
    AppStorage.setOrCreate('checkinStatus', '正在读取游览足迹');
    AppStorage.setOrCreate('checkinRecords', '[]');
    this.ready = this.store.initialize(context).then((enabled: boolean) => {
      this.initialized = true;
      this.enabled = enabled;
      AppStorage.setOrCreate('checkinEnabled', enabled);
      this.status(enabled ? '自动打卡已开启' : '自动打卡未开启');
    }).catch(() => {
      this.status('游览足迹读取失败，请重新打开应用');
    });
  }

  private status(text: string): void {
    AppStorage.setOrCreate('checkinStatus', text);
  }

  private setBusy(value: boolean): void {
    this.busy = value;
    AppStorage.setOrCreate('checkinBusy', value);
  }

  async setEnabled(value: boolean): Promise<void> {
    if (this.busy) {
      return;
    }
    this.setBusy(true);
    try {
      await this.ready;
      if (!this.context || !this.initialized) {
        throw new Error('打卡存储未就绪，请重新打开应用');
      }
      if (value) {
        await abilityAccessCtrl.createAtManager().requestPermissionsFromUser(this.context, this.permissions);
        if (!await this.hasPrecisePermission()) {
          throw new Error('需要精确定位权限，请在系统设置中允许后重试');
        }
        if (!geoLocationManager.isLocationEnabled()) {
          throw new Error('系统定位未开启，请开启后重试');
        }
      }
      await this.store.saveEnabled(value);
      this.enabled = value;
      AppStorage.setOrCreate('checkinEnabled', value);
      if (value) {
        await this.resume();
      } else {
        this.stop();
        this.status('自动打卡已关闭');
      }
    } catch (error) {
      this.status((error as Error).message || '自动打卡设置保存失败，请重试');
    } finally {
      this.setBusy(false);
    }
  }

  async retry(): Promise<void> {
    if (this.busy) {
      return;
    }
    this.stop();
    await this.setEnabled(true);
  }

  onForeground(): void {
    this.foreground = true;
    this.resume();
  }

  onBackground(): void {
    this.foreground = false;
    this.stop();
    if (this.enabled) {
      this.status('应用在后台，自动打卡已暂停');
    }
  }

  destroy(): void {
    this.foreground = false;
    this.stop();
  }

  private async hasPrecisePermission(): Promise<boolean> {
    const info = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    const access = abilityAccessCtrl.createAtManager();
    return this.permissions.every(permission => access.checkAccessTokenSync(info.appInfo.accessTokenId, permission) ===
      abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
  }

  private async resume(): Promise<void> {
    const token = this.generation;
    try {
      await this.ready;
      if (!this.foreground || !this.enabled || !this.initialized || this.listening || token !== this.generation) {
        return;
      }
      if (!await this.hasPrecisePermission()) {
        this.status('缺少精确定位权限，请在系统设置中允许后重试');
        return;
      }
      if (!geoLocationManager.isLocationEnabled()) {
        this.status('系统定位未开启，请开启后重试');
        return;
      }
      if (!this.foreground || !this.enabled || this.listening || token !== this.generation) {
        return;
      }
      this.locationCallback = (location: geoLocationManager.Location) => {
        this.receive(location, token);
      };
      this.errorCallback = () => {
        if (token === this.generation) {
          this.stop();
          this.status('定位失败，请检查定位权限和系统定位后重试');
        }
      };
      this.switchCallback = (enabled: boolean) => {
        if (!enabled && token === this.generation) {
          this.stop();
          this.status('系统定位已关闭，请开启后重试');
        }
      };
      geoLocationManager.on('locationError', this.errorCallback);
      geoLocationManager.on('locationEnabledChange', this.switchCallback);
      geoLocationManager.on('locationChange', {
        priority: geoLocationManager.LocationRequestPriority.ACCURACY,
        scenario: geoLocationManager.LocationRequestScenario.DAILY_LIFE_SERVICE,
        timeInterval: 10,
        distanceInterval: 0,
        maxAccuracy: 0
      }, this.locationCallback);
      this.listening = true;
      this.status('正在定位，到达景点范围后自动打卡');
      this.watchdog(token);
    } catch (_) {
      if (token === this.generation) {
        this.stop();
        this.status('无法启动定位，请检查权限和系统定位后重试');
      }
    }
  }

  private watchdog(token: number): void {
    if (this.timer !== -1) {
      clearTimeout(this.timer);
    }
    this.timer = setTimeout(() => {
      this.timer = -1;
      if (token === this.generation) {
        this.stop();
        this.status('定位等待超时，请到室外后重试');
      }
    }, 30000);
  }

  private async receive(location: geoLocationManager.Location, token: number): Promise<void> {
    if (token !== this.generation || !this.foreground || !this.enabled) {
      return;
    }
    const now = Date.now();
    const sample: LocationSample = {
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      timestamp: location.timeStamp
    };
    const arrived = this.rules.evaluate(sample, this.store.getRecords(), now);
    if (!validSample(sample, now)) {
      this.status('定位精度不足或位置已过期，等待准确位置');
      return;
    }
    this.watchdog(token);
    this.status('自动打卡中 · 景点标记 500 米内确认到访');
    if (arrived.length === 0) {
      return;
    }
    try {
      const saved = await this.store.saveVisits(arrived, now);
      if (saved.length > 0 && token === this.generation && this.foreground) {
        this.status(`已自动记录 ${saved.length} 个到访景点`);
        try {
          promptAction.showToast({ message: `打卡成功，已新增 ${saved.length} 个到访景点` });
        } catch (_) {}
      }
    } catch (_) {
      if (token === this.generation) {
        this.status('打卡保存失败，下次有效定位将重试');
      }
    }
  }

  private stop(): void {
    this.generation++;
    this.rules.reset();
    if (this.timer !== -1) {
      clearTimeout(this.timer);
      this.timer = -1;
    }
    if (this.locationCallback) {
      try {
        geoLocationManager.off('locationChange', this.locationCallback);
      } catch (_) {}
    }
    if (this.errorCallback) {
      try {
        geoLocationManager.off('locationError', this.errorCallback);
      } catch (_) {}
    }
    if (this.switchCallback) {
      try {
        geoLocationManager.off('locationEnabledChange', this.switchCallback);
      } catch (_) {}
    }
    this.locationCallback = undefined;
    this.errorCallback = undefined;
    this.switchCallback = undefined;
    this.listening = false;
  }
}

export default new CheckinManager();
