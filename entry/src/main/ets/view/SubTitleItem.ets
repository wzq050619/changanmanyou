import ZonesItem from '../viewmodel/ZonesItem';
@Component
export default struct SubTitleItem{
  @Consume('contentData') contentData:ZonesItem
  build() {
    Column(){
      Column(){
        Text(this.contentData.title)
          .fontSize(24)
          .fontColor('#ffffff')
          .height(32)
          .fontWeight(FontWeight.Medium)
          .margin({top:16})

        Text(this.contentData.subTitle)
          .fontSize(14)
          .fontColor('#ffffff')
          .height(19)
          .opacity(0.6)
          .margin({top:2,bottom:12})
        Image(this.contentData.starLinePic[0])
          .height(20)
          .width(309)
          .margin({bottom:12})

      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Image(this.contentData.subPicTop)
        .height(214)
        .objectFit(ImageFit.Fill)
        .width('100%')

      Column(){
        ForEach(this.contentData.content,(paragraph:string)=>{
          Text(paragraph)
            .width('100%')
            .fontSize(14)
            .fontColor('#E6FFFFFF')
            .lineHeight(24)
            .margin({top:12})
        },(paragraph:string)=>paragraph)
      }
      .width('87%')
      .alignItems(HorizontalAlign.Start)
      .padding({top:12,bottom:20})
    }
    .backgroundColor(this.contentData.backgroundColor)
  }

}