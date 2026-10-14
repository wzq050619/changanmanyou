import router from '@ohos.router';
import { DeviceScreen } from '../common/utils/DeviceScreen';
import zonesViewModel from '../viewmodel/ZonesViewModel';
import { readVisits, scenicIdForType, VisitRecord } from '../checkin/CheckinRules';

@Entry
@Component
struct FootprintsPage {
  @StorageLink('checkinRecords') private records: string = '[]';
  @State private safePadding: Padding = { top: 32, bottom: 16 };

  aboutToAppear(): void {
    DeviceScreen.getSafeAreaPadding(this.getUIContext()).then((padding: Padding) => {
      this.safePadding = padding;
    });
  }

  private visits(): VisitRecord[] {
    return readVisits(this.records).sort((a, b) => b.visitedAt - a.visitedAt);
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 18 }) {
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.about_back'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.font_color_black'))
        }
        .width(32)
        .height(40)
        .backgroundColor(Color.Transparent)
        .accessibilityText('返回')
        .onClick(() => {
          router.back();
        })
        Text('游览足迹')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_color_black'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 16 })
      Text(`已到访 ${this.visits().length}/10 个景点`)
        .fontSize(16)
        .fontColor($r('app.color.indicator_color'))
      if (this.visits().length === 0) {
        Column({ space: 12 }) {
          Text('还没有游览足迹')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
          Text('在地图开启自动打卡，到达景点标记 500 米范围后会自动记录。')
            .fontSize(14)
            .fontColor($r('app.color.indicator_color'))
            .textAlign(TextAlign.Center)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding(24)
      } else {
        List({ space: 12 }) {
          ForEach(this.visits(), (record: VisitRecord) => {
            ListItem() {
              Row({ space: 12 }) {
                Image(zonesViewModel.getZonesByIndex(scenicIdForType(record.scenicType)).thumbnail)
                  .width(64)
                  .height(64)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(12)
                Column({ space: 6 }) {
                  Text(zonesViewModel.getZonesByIndex(scenicIdForType(record.scenicType)).title)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.font_color_black'))
                  Text(`首次到访：${new Date(record.visitedAt).toLocaleString()}`)
                    .fontSize(12)
                    .fontColor($r('app.color.indicator_color'))
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Image($r('app.media.profile_right'))
                  .width(14)
                  .height(14)
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.start_window_background'))
              .borderRadius(16)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/ContentPage',
                  params: {
                    id: scenicIdForType(record.scenicType)
                  }
                });
              })
            }
          }, (record: VisitRecord) => record.scenicType.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .padding(this.safePadding)
    .backgroundColor($r('app.color.common_background_color'))
  }
}
