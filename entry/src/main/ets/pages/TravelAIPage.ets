import router from '@ohos.router';
import TravelAIComponent from '../ai/TravelAIComponent';
import { TravelAIConfig } from '../ai/TravelAI';
import { AI_API_KEY } from '../ai/ApiConfig.local';
import { DeviceScreen } from '../common/utils/DeviceScreen';
import zonesViewModel from '../viewmodel/ZonesViewModel';

interface TravelAIParams {
  scenicId?: number;
}

@Entry
@Component
struct TravelAIPage {
  @State private scenicId: number = -1;
  @State private title: string = '游览规划';
  @State private visible: boolean = true;
  @State private safePadding: Padding = { top: 32, bottom: 16 };
  private config: TravelAIConfig = new TravelAIConfig();

  aboutToAppear(): void {
    this.config.apiKey = AI_API_KEY;
    const params = router.getParams() as TravelAIParams | undefined;
    if (params && typeof params.scenicId === 'number') {
      this.scenicId = params.scenicId;
      const zone = zonesViewModel.getZonesList().find(item => item.id === this.scenicId);
      this.title = zone ? zone.title : '景点问答';
    }
    DeviceScreen.getSafeAreaPadding(this.getUIContext()).then((padding: Padding) => {
      this.safePadding = padding;
    });
  }

  onPageShow(): void {
    this.visible = true;
  }

  onPageHide(): void {
    // 移除组件，触发请求取消和资源释放。
    this.visible = false;
  }

  build() {
    Column() {
      Row({ space: 16 }) {
        Button('返回').fontSize(16)
          .fontColor($r('app.color.bottom_tabs_font_color_selected'))
          .backgroundColor($r('app.color.common_background_color'))
          .onClick(() => router.back())
        Text(this.title).fontSize(18).fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_color_black'))
      }.width('100%').padding({ left: 16, right: 16, top: 8, bottom: 8 })
      Column() {
        if (this.visible) {
          TravelAIComponent({ config: this.config, scenicId: this.scenicId })
        }
      }.layoutWeight(1).width('100%')
    }.width('100%').height('100%').padding(this.safePadding)
      .backgroundColor($r('app.color.common_background_color'))
  }
}
