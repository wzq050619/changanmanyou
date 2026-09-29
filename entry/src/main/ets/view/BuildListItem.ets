import ZonesItem from '../viewmodel/ZonesItem';

@Component
export default struct BuildListItem{
  @Prop type:string=''
  @Consume('contentData') contentData:ZonesItem
  build() {
    Column(){
      Image(this.contentData.starLinePic[1])
        .width('87%')
        .height(20)
        .margin({bottom:30})
      if (this.type==='building'){
        Text(this.contentData.buildingInformation)
          .width('87%')
          .fontSize(14)
          .fontColor('#E6FFFFFF')
          .lineHeight(24)
          .letterSpacing(0)
      }
      //按照type分支选择不同的图片
      Column(){
        if (this.type==='building'){
          Image(this.contentData.buildingPic)
            .width('100%')
            .aspectRatio(4/3)
            .objectFit(ImageFit.Cover)
            .borderRadius(24)
            .margin({top:24})
        }else {
          Image(this.type==='geography_light'?this.contentData.geographyPicLight:this.contentData.geographyPic)
            .width('100%')
            .aspectRatio(3/2)
            .objectFit(ImageFit.Cover)
            .borderRadius(24)
            .margin({top:24})
        }
      }

      .width('87%')
      .margin({bottom:67})
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}