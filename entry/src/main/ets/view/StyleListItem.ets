import ZoneItem from '../viewmodel/ZonesItem'
import imageAnimation from "../view/ImageAnimation";

@Component
export default struct StyleListItem{
  @Consume('contentData') contentData:ZoneItem
  build() {
    Column(){
      ForEach(this.contentData.content,(item:ResourceStr)=>{
        Text(item)
          .width('87%')
          .fontSize(14)
          .margin({bottom:24})
      },(item:ResourceStr)=>JSON.stringify(item))
      Column(){
        //横向滑动模块
        imageAnimation()
      }
      .width('87%')
      .height('42%')
      .margin({top:24,bottom:48})
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .height(500)

  }
}