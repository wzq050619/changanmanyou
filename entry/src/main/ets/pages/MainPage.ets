import {BottomTabslist} from "../viewmodel/BottomTabsModel";
import {CommonConstants as Count } from "../common/constants/CommonConstants";
import { Map } from '../view/MapComponent'
import { Zones } from "../view/ZoneConmponent";
import {Trains} from "../view/TrainsComponent";
import { PersonalCenter } from "../view/PersonalCenter";
import { DeviceScreen } from "../common/utils/DeviceScreen";



@Entry
@Component
struct MainPage {
  @State systemPadding: Padding = { top: 32, bottom: 0 }

  // 标题和底部标签栏避开系统状态栏、手势导航区。
  aboutToAppear(): void {
    DeviceScreen.getSafeAreaPadding(this.getUIContext()).then((padding: Padding) => {
      this.systemPadding = padding
    })
  }

  @State@Watch('onIndexChange') bottomTabIndex:number=0
  private controller:TabsController=new TabsController()

  onIndexChange(){
    this.controller.changeIndex(this.bottomTabIndex)
  }

  @Builder Tabbuilder(index:number,name:string){
    Column(){
      Image(this.bottomTabIndex===index?BottomTabslist[index].inconSelected:BottomTabslist[index].icon)
        .width(Count.ICON_SIZE)
        .height(Count.ICON_SIZE)
        .objectFit(ImageFit.Contain)

      Text(BottomTabslist[index].text)
        .fontSize(16)
        .opacity(Count.OPACITY)
        .fontColor(this.bottomTabIndex===index?$r('app.color.bottom_tabs_font_color_selected'):$r('app.color.bottom_tabs_font_color'))
        .margin({top:5})
    }
    .justifyContent(FlexAlign.Center)
    .width(Count.FULL_PERCENT)
    .height(Count.FULL_PERCENT)
    .border({width:{top:Count.BORDER_WIDTH},color:$r('app.color.color_border')})
    .backgroundColor($r('app.color.bottom_tabs_background_color'))
  }
  build() {

    Flex({
      direction:FlexDirection.Column,alignItems:ItemAlign.End,justifyContent:FlexAlign.End
    }){
      Tabs({barPosition:BarPosition.End,index:0,controller:this.controller}){


        TabContent(){
         Map()
        }.tabBar(this.Tabbuilder(0,'Map'))

        TabContent(){
          Zones()
        }.tabBar(this.Tabbuilder(1,'Zone'))

        TabContent(){
          Trains()
        }.tabBar(this.Tabbuilder(2,'Train'))

        TabContent(){
          PersonalCenter()
        }.tabBar(this.Tabbuilder(3,'User'))
      }
      .width(Count.FULL_PERCENT)
      .height(Count.FULL_PERCENT)
      .vertical(false)
      .scrollable(false)
      .barHeight(56)
      .onChange((index:number)=>{
        this.bottomTabIndex=index
      })
    }.width(Count.FULL_PERCENT)
      .height(Count.FULL_PERCENT)
      .padding(this.systemPadding)
      .backgroundColor($r('app.color.common_background_color'))
  }
}