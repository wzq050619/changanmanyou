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
  @State private scenicSubtitle: string = '';
  @State private scenicImage: ResourceStr = $r('app.media.scenic_bell_tower');
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
      if (zone) {
        this.scenicSubtitle = zone.subTitle;
        this.scenicImage = zone.thumbnail;
      }
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
      Row({ space: 18 }) {
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.about_back')).width(20).height(20)
            .fillColor($r('app.color.font_color_black'))
        }
          .width(32).height(40).backgroundColor(Color.Transparent)
          .accessibilityText('返回')
          .onClick(() => router.back())
        Text(this.scenicId < 0 ? 'AI 游览规划' : '景点问询')
          .fontSize(22).fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_color_black'))
      }.width('100%').height(56).padding({ left: 12, right: 16 })
      if (this.scenicId >= 0 && this.scenicSubtitle) {
        Row({ space: 12 }) {
          Image(this.scenicImage).width(56).height(56)
            .objectFit(ImageFit.Cover).borderRadius(12)
          Column({ space: 6 }) {
            Text(this.title).fontSize(18).fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.font_color_black'))
            Text(this.scenicSubtitle).fontSize(14)
              .fontColor($r('app.color.indicator_color'))
          }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        }.padding(16).borderRadius(16)
          .backgroundColor($r('app.color.start_window_background'))
          .margin({ left: 16, right: 16, bottom: 12 })
      }
      Column() {
        if (this.visible) {
          TravelAIComponent({ config: this.config, scenicId: this.scenicId, showTitle: false })
        }
      }.layoutWeight(1).width('100%')
    }.width('100%').height('100%').padding(this.safePadding)
      .backgroundColor($r('app.color.common_background_color'))
  }
}
