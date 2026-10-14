import checkinManager from './CheckinManager';
import { readVisits } from './CheckinRules';

@Component
export default struct CheckinPanel {
  @StorageLink('checkinEnabled') private isEnabled: boolean = false;
  @StorageLink('checkinBusy') private busy: boolean = false;
  @StorageLink('checkinStatus') private status: string = '自动打卡未开启';
  @StorageLink('checkinRecords') private records: string = '[]';

  private toggle(): void {
    if (this.isEnabled) {
      checkinManager.setEnabled(false);
      return;
    }
    this.getUIContext().showAlertDialog({
      title: '开启自动打卡',
      message: '应用在前台时获取位置，连续确认进入景点标记 500 米范围后记录到访。退到后台即停止定位，不保存移动轨迹。',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '开启',
        action: () => {
          checkinManager.setEnabled(true);
        }
      }
    });
  }

  build() {
    Column({ space: 4 }) {
      Row({ space: 12 }) {
        Text(`游览足迹 ${readVisits(this.records).length}/10`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_color_black'))
          .layoutWeight(1)
        Button(this.isEnabled ? '关闭自动打卡' : '开启自动打卡')
          .height(32)
          .fontSize(13)
          .backgroundColor($r('app.color.bottom_tabs_font_color_selected'))
          .fontColor(Color.White)
          .enabled(!this.busy)
          .onClick(() => this.toggle())
      }
      Text(this.status)
        .fontSize(12)
        .fontColor($r('app.color.indicator_color'))
      if (this.isEnabled && (this.status.includes('重试') || this.status.includes('超时') || this.status.includes('缺少'))) {
        Text('重试定位')
          .fontSize(14)
          .fontColor($r('app.color.bottom_tabs_font_color_selected'))
          .enabled(!this.busy)
          .onClick(() => {
            checkinManager.retry();
          })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('92%')
    .padding(12)
    .backgroundColor($r('app.color.start_window_background'))
    .borderRadius(16)
  }
}
