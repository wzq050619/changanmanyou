/*
优点:
 */
import router from "@ohos.router";
import {CommonConstants as Const} from "../common/constants/CommonConstants";
import {startImage} from "../viewmodel/Startmodel";

@Entry
@Component
struct StartPage {
  private swiper:SwiperController=new SwiperController()
  private data:Resource[]=[]
  private time:number=-1
  @State countdown:number=Const.COUNTDOWN
  @State showSwiper:boolean=false

  aboutToAppear(): void {
    let hours=new Date().getHours()
    if (hours>=Const.MORNING_TIME&&hours<Const.NOON_TIME) {
      this.data=startImage.day
    }else if (hours>=Const.NOON_TIME&&hours<Const.EVENING_TIME) {
      this.data=startImage.noon
    }else if (hours>=Const.EVENING_TIME&&hours<Const.NIGHT_TIME){
      this.data=startImage.duck
    }else {
      this.data=startImage.night
    }
    setTimeout(()=>{
      this.showSwiper=true
      this.startTiming()
    },Const.SPLASH_DURATION)
  }

  startTiming(){
    this.time=setInterval(()=>{
      this.countdown--;
      if (this.countdown===0) {
        this.clearTiming()
        this.jumpToPage()
      }
    },Const.DURATION)
  }

  clearTiming(){
    clearInterval(this.time)
  }

  jumpToPage(){
    this.clearTiming()
    router.replaceUrl({
      url:'pages/MainPage'
    })
  }
  aboutToDisappear(): void {
    this.clearTiming()
  }
  build() {
    Column(){
      Stack(){

        if (this.showSwiper){
          //第二个页面，展示轮播图，按钮，计时器
          Swiper(this.swiper){
            ForEach(this.data,(item:Resource)=>{
              Image(item)
                .width(Const.FULL_SIZE)
                .height(Const.FULL_SIZE)
                .objectFit(ImageFit.Cover)
            })
          }
          .loop(true)
          //末页回绕到首页
          .autoPlay(true)
          .interval(2*Const.DURATION)
          //自动轮播2s
          .duration(Const.DURATION)
          //切换动画时长1s
          .indicatorStyle({
            bottom:$r('app.float.100'),
            color:$r('app.color.swiper_dot_color')
          })
          .curve(Curve.Linear)
          .onChange((index:number)=>{
            console.info(index.toString())
          })
          //计时展示，手动跳过
          Text(){
            Span('跳过')
            Span(`${this.countdown}`)
          }
          .onClick(()=>{
            this.jumpToPage()
          })
          .fontColor(Color.White)
          .fontSize(12)
          .backgroundColor($r('app.color.swiper_jump_bg_color'))
          .width(63)
          .height(25)
          .borderRadius(10)
          .textAlign(TextAlign.Center)
          .position({
            x:300,
            y:50
          })
        }else {
          //第一个页面，白屏加logo
          Image($r('app.media.splash_bg'))
            .width(Const.FULL_PERCENT)
            .height(Const.FULL_PERCENT)
          Image($r('app.media.ic_splash'))
            .width($r('app.float.192'))
            .height($r('app.float.192'))
            .offset({
              y:`-${Const.PERCENTAGE_15}`
            })
            .objectFit(ImageFit.Contain)
          Column(){
            Text(Const.SPLASH_DES)
              .fontSize($r('app.float.font_size_24fp'))
              .fontColor(Color.White)
            Text(Const.SPLASH_WELCOME)
              .fontSize($r('app.float.font_size_16fp'))
              .fontColor(Color.White)
            Text(Const.SPLASH_INFO)
              .fontSize($r('app.float.12fp'))
              .fontColor(Color.White)
              .margin({top:$r('app.float.85')})
          }
          .offset({
            y:Const.PERCENTAGE_25
          })
        }

      }
    }.width(Const.FULL_SIZE)
    .height(Const.FULL_SIZE)
  }
}