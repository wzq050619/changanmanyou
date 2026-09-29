import ZonesItem from '../viewmodel/ZonesItem';
import zoneViewModel from '../viewmodel/ZonesViewModel'

@Component
export default struct SwiperListItem{

  private swiperController:SwiperController=new SwiperController()
  @State zoneList:ZonesItem[]=zoneViewModel.getZonesList()
  @Prop imageHeight:number=0
  @Prop currentZonesId:number=0
  @Prop arrowIconOpacity:number=0
  @Consume('contentData') contentData:ZonesItem

  build() {
    Stack({alignContent:Alignment.Bottom}){
      Swiper(this.swiperController){
        ForEach(this.zoneList,(item:ZonesItem)=>{
          Image(item.swiperPic)
            .width('100%')
            .height(this.imageHeight+'%')
            .objectFit(ImageFit.Cover)
        },(item:ZonesItem)=>item.id.toString())
      }
      //初始定位到当前区域对应的图片
      .index(this.currentZonesId)
      .indicator(true)
      //显示分页的指示点
      .loop(true)
      //开启循环播放
      .cachedCount(3)
      //预加载，可以提前加载前后各三张图片
      .curve(Curve.EaseOut)
      .onChange((index:number)=>{
        this.currentZonesId=index
        this.getIntroductionData()
      })
      Text(this.contentData.title)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .opacity(this.arrowIconOpacity)
        .width('100%')
        .height(38)
        .fontColor('#ffffff')
        .textAlign(TextAlign.Center)
        .margin({bottom:120})
        .animation({
          duration:1000,
          curve:Curve.EaseOut
        })
      Image($r('app.media.ic_arrow_down'))
        .width(34)
        .height(10)
        .margin({bottom:63})
        .opacity(this.arrowIconOpacity)
        .animation({
          duration:1000,
          curve:Curve.EaseOut
        })
    }
  }
  getIntroductionData(){
    this.contentData=this.zoneList.filter((item)=>
    item.id===this.currentZonesId)[0]
  }

}
