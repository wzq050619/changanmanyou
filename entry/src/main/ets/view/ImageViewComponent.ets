//查看大图弹窗
import window from "@ohos.window";
import ZoneItem from '../viewmodel/ZonesItem'
import {DeviceScreen } from "../common/utils/DeviceScreen";
@CustomDialog
export struct ImageView {
  //控制器，控制关闭窗口
  private controller: CustomDialogController = new CustomDialogController({
    builder: ImageView(),
  })
  //当前窗口对象
  private windowClass: window.Window | null = null
  //当前屏幕宽高
  private deviceWith: number = 0
  private deviceHeight: number = 0
  //图片实际渲染后的宽高
  private imgWidth: number = 0
  private imgHeight: number = 0
  //缩放后图片显示的高度
  private displayHeight: number = 0
  //共享的数据，打开弹窗的图片下标
  @Consume('contentData') contentData: ZoneItem
  @Prop currentImageId: number = 0
  //手势信息，缩放状态
  //当前缩放比例/缩放基准
  @State curIndex: number = this.currentImageId
  @State isGesture: boolean = false
  @State curScale: number = 1
  @State imgScale: number = 1
  @State imgOffsetX: number = 0
  @State imgOffsetY: number = 0
  @State preOffsetX: number = 0
  @State preOffsetY: number = 0

  //异步去获取到我们当前的窗口，获取窗口宽高
  aboutToAppear(): void {
    let deviceSize = DeviceScreen.getDeviceSize(getContext(this))
    deviceSize.then((data: window.Window) => {
      this.windowClass = data
      let properties = this.windowClass.getWindowProperties()
      this.deviceWith = properties.windowRect.width
      this.deviceHeight = properties.windowRect.height
    })
  }

  //1.检查边界，缩放/移动 图片必须在屏幕的范围内，避免白边
  //图片放大x倍后，允许移动的最大范围=（缩放后的尺寸-屏幕尺寸）/2
  detectBoundary(): void {
    //水平最大偏移量
    let maxOffsetX = this.imgScale * this.deviceWith / 2 - this.deviceWith / 2
    if (vp2px(this.imgOffsetX) > (maxOffsetX)) {
      this.imgOffsetX = px2vp(maxOffsetX)
    }
    if (vp2px(this.imgOffsetX) < -(maxOffsetX)) {
      this.imgOffsetX = -px2vp(maxOffsetX)
    }
    //竖直方向上的最大偏移量
    let maxOffsetY = this.imgScale * this.deviceHeight / 2 - this.deviceHeight / 2
    if (this.imgScale*this.displayHeight>=this.deviceHeight) {
      if (vp2px(this.imgOffsetY) > (maxOffsetY)) {
        this.imgOffsetY = px2vp(maxOffsetY)
      }
      if (vp2px(this.imgOffsetY) < -(maxOffsetY)) {
        this.imgOffsetY = -px2vp(maxOffsetX)
      }
    }
    else {
      //放大后仍然比屏幕矮，竖直方向上无法进行拖动，偏移设为0
      this.imgOffsetY = 0
    }
  }

  //2.按照比例缩放，设置缩放边界，最大缩放四倍
  limitScale(isReset: boolean): void {
    if (this.imgScale < 1) {
      //比原始图片还小
      this.imgScale = 1
      this.curScale = 1
      if (isReset) {
        this.imgOffsetX = 0
        this.imgOffsetY = 0
      }
      this.isGesture = false
    } else if (this.imgScale > 4) {
      this.imgScale = 4
      this.curScale = 4
    } else {
      //1-4
      this.curScale = this.imgScale
    }
  }

  build() {
    Stack() {
      Swiper(){
        ForEach(this.contentData.imageList, (item: ResourceStr) => {
          Column() {
            //顶部空白区域点击关闭弹窗
            Blank().onClick(() => {
              this.controller.close()
            })
            Image(item)
              .width('100%')
              .objectFit(ImageFit.Contain)
              .gesture(
                PinchGesture()
                  .onActionStart(() => {
                    this.isGesture = true
                  })
                  .onActionUpdate((event?: GestureEvent) => {
                    if (!event) {
                      return
                    }
                    this.imgScale = this.curScale * event.scale
                  })
                  .onActionEnd(() => {
                    this.limitScale(false)
                  })
              )
            Blank().onClick(() => {
              this.controller.close()
            })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        })
      }
      .width('100%')
      .height('100%')
      .loop(false)
      .indicatorStyle({ bottom: 200, color: Color.Gray })
      .index(this.curIndex)
      .onChange((index: number) => {
        this.curIndex = index
      })

      .visibility(this.isGesture ? Visibility.Hidden : Visibility.Visible)

      Row() {
        Image(this.contentData.imageList[this.curIndex])
          .objectFit(ImageFit.Contain)
          .scale({ x: this.imgScale, y: this.imgScale })
          .translate({ x: this.imgOffsetX, y: this.imgOffsetY })
          .onComplete((event) => {
            if (!event) {
              return
            }
            //图形渲染回调  记录实际的宽高，按照设备宽高计算显示的宽高
            this.imgWidth = event.width
            this.imgHeight = event.height
            this.displayHeight = this.deviceWith * this.imgHeight / this.imgWidth
          })
      }
      .gesture(
        //双指缩放，实时更新比例 如果松开手，要做边界检测+缩放比例限制
        PinchGesture()
          .onActionUpdate((event?: GestureEvent) => {
            if (!event) {
              return
            }
            this.imgScale = this.curScale * event.scale
          })
          .onActionEnd(() => {
            this.detectBoundary()
            this.limitScale(true)
          })
      )
      .gesture(
        //单指拖动
        PanGesture()
          .onActionStart(()=>{
            this.imgOffsetX=this.preOffsetX
            this.imgOffsetY=this.preOffsetY
          })
          .onActionUpdate((event?:GestureEvent)=>{
            if (!event) {
              return
            }
            this.imgOffsetX=this.preOffsetX+event.offsetX
            this.imgOffsetY=this.preOffsetY+event.offsetY
          })
          .onActionEnd(()=>{
            this.detectBoundary()
          })
      )
      .visibility(this.isGesture ? Visibility.Visible : Visibility.Hidden)
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      direction:GradientDirection.Top,
      colors:[['#ff515151',0.8],['#ff222222',1.0]]
    })
  }

}