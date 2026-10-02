import router from '@ohos.router'
import { DeviceScreen } from '../common/utils/DeviceScreen'

const CHANGAN_IMAGE: Resource = $r('app.media.changan_about_banner')

// 图片预览
@CustomDialog
struct ChanganImageDialog {
  controller?: CustomDialogController

  build() {
    Stack() {
      Image(CHANGAN_IMAGE)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
    .onClick(() => this.controller?.close())
  }
}

// 页面
@Entry
@Preview
@Component
struct AboutPage {
  @State systemPadding: Padding = { top: 32, bottom: 0 }

  // 独立路由页面自行预留状态栏和手势导航空间。
  aboutToAppear(): void {
    DeviceScreen.getSafeAreaPadding(this.getUIContext()).then((padding: Padding) => {
      this.systemPadding = padding
    })
  }
  // 配置图片弹窗
  private imageDialog: CustomDialogController = new CustomDialogController({
    builder: ChanganImageDialog(),
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
    maskColor: '#E6000000',
    width: '100%',
    height: '100%',
    backgroundColor: Color.Transparent
  })

  // 页面离开时关闭图片弹窗，避免弹窗继续显示。
  aboutToDisappear(): void {
    this.imageDialog.close()
  }

  // 通用图标：默认使用项目蓝色，也可传入其他颜色资源。
  @Builder
  Icon(icon: Resource, color: ResourceColor = $r('app.color.bottom_tabs_font_color_selected')) {
    Image(icon)
      .width(24)
      .height(24)
      .fillColor(color)
  }

  // 卡片标题
  @Builder
  SectionTitle(title: string, icon: Resource = $r('app.media.about_landmark')) {
    Row({ space: 12 }) {
      this.Icon(icon)
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.font_color_black'))
    }
    .width('100%')
    .margin({ bottom: 8 })
  }

  // 漫游体验项目：统一使用项目蓝色圆形背景和白色图标。
  @Builder
  ExploreItem(title: string, icon: Resource) {
    Column({ space: 6 }) {
      Stack() {
        this.Icon(icon, $r('app.color.font_color_white'))
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor($r('app.color.bottom_tabs_font_color_selected'))
      Text(title)
        .fontSize(16)
        .fontColor($r('app.color.font_color_black'))
    }
    .layoutWeight(1)
  }

  // 项目概览信息
  @Builder
  InfoRow(label: string, value: string, icon: Resource, last: boolean = false) {
    Row({ space: 12 }) {
      this.Icon(icon, $r('app.color.indicator_color'))
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.indicator_color'))
      Text(value)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
        .fontSize(14)
        .fontColor($r('app.color.color_gradient_1'))
    }
    .width('100%')
    .constraintSize({ minHeight: 32 })
    .padding({ top: 4, bottom: 4 })
    .border({ width: { bottom: last ? 0 : 0.5 }, color: $r('app.color.common_background_color') })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row({ space: 18 }) {
        Button({ type: ButtonType.Normal }) {
          this.Icon($r('app.media.about_back'), $r('app.color.font_color_black'))
        }
        .width(32)
        .height(40)
        .backgroundColor(Color.Transparent)
        .accessibilityText('返回')
        .onClick(() => router.back())
        Text('关于长安漫游')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_color_black'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 16 })

      Column({ space: 8 }) {
        // 主题图片+内容
        Stack({ alignContent: Alignment.Start }) {
          Image(CHANGAN_IMAGE)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
          Column({ space: 8 }) {
            Text('一城古韵 · 一路风景')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.font_color_white'))
            Text('从钟楼出发，慢慢读懂长安')
              .fontSize(14)
              .fontColor($r('app.color.font_color_white'))
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          // 添加从深到浅的遮罩，提高白色文字的可读性。
          .linearGradient({ angle: 90, colors: [['#99000000', 0], ['#00000000', 1]] })
        }
        .width('100%')
        .layoutWeight(1)
        .borderRadius(12)
        .clip(true)
        .accessibilityText('查看长安主题图片')
        .onClick(() => this.imageDialog.open())

        // 项目简介
        Column() {
          this.SectionTitle('项目简介')
          Text('长安漫游是一款围绕西安景点打造的城市漫游应用。在这里，可以浏览钟楼、城墙等地标的介绍与图集，结合地图了解景点位置。沿着街巷慢慢走，在古建与烟火之间，发现属于自己的长安印象。')
            .width('100%')
            .fontSize(14)
            .lineHeight(20)
            .fontColor($r('app.color.indicator_color'))
        }
        .width('100%')
        .padding(12)
        .backgroundColor($r('app.color.start_window_background'))
        .borderRadius(14)

        // 漫游体验
        Column() {
          this.SectionTitle('漫游体验', $r('app.media.about_compass'))
          Row() {
            this.ExploreItem('赏景', $r('app.media.about_landmark'))
            this.ExploreItem('寻古', $r('app.media.about_book'))
            this.ExploreItem('漫步', $r('app.media.about_walk'))
            this.ExploreItem('出行', $r('app.media.about_compass'))
          }
          .width('100%')
        }
        .width('100%')
        .padding(12)
        .backgroundColor($r('app.color.start_window_background'))
        .borderRadius(14)

        // 项目概览
        Column() {
          this.SectionTitle('项目概览')
          this.InfoRow('应用名称', '长安漫游', $r('app.media.about_landmark'))
          this.InfoRow('漫游城市', '陕西 · 西安', $r('app.media.about_compass'))
          this.InfoRow('浏览内容', '景点 / 图集 / 地图', $r('app.media.about_book'))
          this.InfoRow('漫游方式', '赏景 · 寻古 · 慢行', $r('app.media.about_walk'), true)
        }
        .width('100%')
        .padding(12)
        .backgroundColor($r('app.color.start_window_background'))
        .borderRadius(14)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 4, bottom: 12 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(this.systemPadding)
    .backgroundColor($r('app.color.common_background_color'))
  }
}
