import router from '@ohos.router'
import SwiperListItem from '../view/SwiperListItem';
import ZonesItem from '../viewmodel/ZonesItem';
import zoneViewModel from '../viewmodel/ZonesViewModel'
import SubTitleItem from "../view/SubTitleItem";
import BuildListItem from "../view/BuildListItem";
import StyleListItem from "../view/StyleListItem";
import {Animation} from "../common/utils/Animation";
import {AnimationItem} from "../viewmodel/AnimationItem";
import {DeviceScreen} from "../common/utils/DeviceScreen";

@Entry
@Component
struct ContentPage {
  @State zoneList: ZonesItem[] = zoneViewModel.getZonesList()
  @Provide('contentData') contentData: ZonesItem = zoneViewModel.getZonesList()[0]
  @State currentZonesId: number = 0
  @Provide animationItem: AnimationItem = new AnimationItem()
  @State isReachStart: boolean = false

  //是否已经回到顶部

  //吸顶图标  图标的缩放
  @Builder
  TitleIcon(src: ResourceStr, scale: number) {
    Column() {
      Image(src)
        .width(56)
        .height(36)
        .objectFit(ImageFit.Contain)
        .syncLoad(true)
        //开启同步加载
        .scale({ x: scale,y:scale })
        .opacity(scale)
        .animation({
          duration: 500,
          curve: Curve.EaseOut
        })
    }
    .width(64)
    .height(44)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  //顶部吸顶， 区域小图+图标+标题  详细滚动贴顶显示
  @Builder
  StickyHeader() {
    Column() {
      Image(this.contentData.subPicBottom)
        .height(120)
        .objectFit(ImageFit.Fill)
        .width('100%')
        .autoResize(false)
        .interpolation(ImageInterpolation.Medium)
        .syncLoad(true)
        .backgroundColor(this.contentData.backgroundColor)
      Stack({ alignContent: Alignment.Bottom }) {
        Image(this.contentData.titleIcon)
          .height(24)
          .width(57)
          .syncLoad(true)
          .margin({ bottom: 23 })

        //三块内容对应的图标
        this.TitleIcon($r('app.media.ic_design_style'), this.animationItem.scaleIcon[0])
        this.TitleIcon($r('app.media.ic_building'), this.animationItem.scaleIcon[1])
        this.TitleIcon($r('app.media.ic_geography_icon'), this.animationItem.scaleIcon[2])
      }
      .width('100%')
      .height(76)

      Text(this.animationItem.iconTitle)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 18 })
        .fontColor('#000000')
        .height(14)
        .fontSize(10)
    }
    .width('100%')
    .backgroundColor('#F1F3F5')
    .height(229)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  zhangeweizhi() {
    Column()
      .height(160)
  }

  //转场的效果
  pageTransition() {
    PageTransitionEnter({ duration: 800 })
      .slide(SlideEffect.Bottom)
      .scale({
        x: 0,
        y: 0,
        centerX: '50%',
        centerY: '50%'
      })
    PageTransitionExit({ delay: 300 })
      .slide(SlideEffect.Bottom)
      .scale({
        x: 0,
        y: 0,
        centerX: '50%',
        centerY: '50%'
      })
  }
  build() {
    Column(){
      Stack({alignContent:Alignment.Bottom}){
        Column(){
          List({scroller:this.animationItem.scrollerForList}){
            ListItem(){
              SwiperListItem({
                imageHeight:this.animationItem.imageHeight,
                currentZonesId:this.currentZonesId,
                arrowIconOpacity:this.animationItem.arrowIconOpacity
              })
            }
            ListItem(){
              SubTitleItem()
            }
            ListItemGroup({header:this.StickyHeader(),footer:this.zhangeweizhi()}){
              ListItem(){
                StyleListItem()
              }
              ListItem(){
                BuildListItem({type:'building'})
              }
              ListItem(){
                BuildListItem({type:this.animationItem.geogrophicPictype})
              }
            }
          }
          .width('100%')
          .height('100%')
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
          .sticky(StickyStyle.Header)
          .cachedCount(3)
          .onReachStart(()=>{
            this.restParameters()
          })
          //记录可见的图片下标
          .onScrollIndex((start:number)=>{
            this.animationItem.currentListIndex=start
          })
          //列表滚动到底部，标记
          .onReachEnd(()=>{
            this.animationItem.listPosition=2
          })
          //滚动的过程中，小图标变化更新
          .onScrollFrameBegin((offset:number,state:ScrollState)=>{
            let realOffset=Animation.controlImageScale(this.animationItem,offset,state)
            return {offsetRemain:realOffset}
          })
          .onDidScroll(() => {
            this.startAnimation()
          })
          //右下角点击快速回到顶部
          //左上角返回主页
        }
        .height('100%')

        Button({ type: ButtonType.Normal }) {
          Row({ space: 8 }) {
            Image($r('app.media.ic_ai_tab_selected')).width(20).height(20)
              .objectFit(ImageFit.Contain)
            Text('景点问询').fontSize(14).fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.bottom_tabs_font_color_selected'))
          }
        }
          .height(40).padding({ left: 16, right: 16 }).borderRadius(20)
          .backgroundColor($r('app.color.start_window_background'))
          .margin({ bottom: 33 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/TravelAIPage', params: { scenicId: this.currentZonesId } })
          })
        //底部返回顶部按钮
        Image($r('app.media.ic_up_icon'))
          .height(40)
          .aspectRatio(1)
          .margin({bottom:33,left:308})
          .onClick(()=>{
            this.scrollToTop()
          })
          .opacity(1-this.animationItem.arrowIconOpacity)
        //返回主页按钮
        Image($r('app.media.ic_home_back'))
          .height(40)
          .aspectRatio(1)
          .margin({bottom:this.animationItem.screenHeight-80,right:308})
          .onClick(()=>{
            router.back()
          })
      }
      .height('100%')
    }
    .height('100%')
  }
  aboutToAppear() {
    try {
      let params = router.getParams() as Record<string,Object>
      this.currentZonesId=params.id as number
    }catch (e){
      console.error('路由传参失败');
    }
    //按照id筛选当前区域写了的contendata
    this.getIntroductionData()
    this.animationItem.screenHeight=DeviceScreen.getDeviceHeight()
  }
  //滚动过程。调用animation更新图标
  startAnimation(){
    Animation.changeTitleIcon(this.animationItem)
  }
  restParameters(){
    this.animationItem.listPosition=0
    if (this.isReachStart) {
      this.animationItem.imageHeight = 100
      this.animationItem.arrowIconOpacity = 1
    }
    this.isReachStart=false
  }

  getIntroductionData(){
    //fitter 返回id 去匹配数组
    this.contentData=this.zoneList.filter((item)=>item.id===this.currentZonesId)[0]
  }

  //abouttoappear  通过路由传id
  //会滚时触发的动画效果
  scrollToTop(){
    if (this.animationItem.listPosition!==0) {
      this.isReachStart=true
      this.animationItem.scrollerForList.scrollTo({
        xOffset:0,
        yOffset:0,
        animation:{
          duration:Math.max(200,this.animationItem.offsetSum/5),
          curve:Curve.Linear
        }
      })

    }
    else {
      this.animationItem.imageHeight=100
      this.animationItem.arrowIconOpacity=1
    }
  }
}
