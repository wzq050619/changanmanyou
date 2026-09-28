import  ZonesItem from "../viewmodel/ZonesItem";
import ZonesViewModel from "../viewmodel/ZonesViewModel";
import { router } from "@kit.ArkUI";


@Component
export struct Zones{
  //防止重入，一次拖动只允许一次切换
  private changeIndex:boolean=true
  //数据
  private zonesList:ZonesItem[]=ZonesViewModel.getZonesList()
  //最顶层的卡片下标 初始2
  //最上面的卡片  0  顶层卡片第二张  1
  @State aheadIndex:number= 0
  @State marginBottom:number=0


  getImgCoeddicients(index?:number):number{
    //未传入下标
    if (index===undefined){
      return 0
    }
    let coefficient=this.aheadIndex-index
    let temCoeddicient=Math.abs(coefficient)
    //如果值小于2，就代表这个卡片在正常显示范围里，需要返回大小，参与错排
    if (temCoeddicient<=2) {
      return coefficient
    }
    let datalength=this.zonesList.length
    let tempOffset=datalength-temCoeddicient
    if (tempOffset<=2) {
      if (coefficient>0) {
        return -tempOffset
      }
      return tempOffset
    }
    return 0
  }
  //第x张卡片垂直偏移量
  getOffSetY(index?:number):number{
    if (index===undefined) {
      return 0
    }
    //错层逻辑，负数在上，正数在下
    let offsetIndex=this.getImgCoeddicients(index)
    let tempOffset=Math.abs(offsetIndex)
    //跟手拖动的位移，1/（层数+1）的衰减
    let offsetY=this.marginBottom/(tempOffset+1)
    if (tempOffset===1) {
      //距离为1，偏移量+-100
      offsetY+=-offsetIndex*100
    }
    else if (tempOffset===2) {
      offsetY+=-offsetIndex*(100-10)
    }
    return offsetY
  }
  //切换的动画效果
  StarAnimation(isup:boolean):void{
    animateTo({
      duration:300,
    },()=>{
      let dataLength=this.zonesList.length
      //上一张时，先加datalength-1，防止出现负数的下标
      let tempIndex=isup?this.aheadIndex+1:dataLength+this.aheadIndex-1
      //实现环形循环，切到最后一张卡片的时候，切回第一张
      this.aheadIndex=tempIndex%dataLength
      this.marginBottom=0
    })
  }
  //手势交互
  handlePanGesture(offsetY:number):void{
    if (Math.abs(offsetY)<60) {
      //拖动距离太小，不切换
      this.marginBottom=offsetY
    }else {
      //超过拖动阈值，切换
      if (this.changeIndex) {
        //当进行过切换的时候，changedindex  就改成false
        return
      }
      this.changeIndex=true
      //上划offset<0查看的就是下一张
      //下划offset》0 查看的就是上一张
      this.StarAnimation(offsetY<0)
    }
  }
  build() {
    Navigation(){
      Stack(){
        //10张卡片，全部使用绝对定位控制
        ForEach(this.zonesList,(item:ZonesItem,index?:number)=>{
          Stack({alignContent:Alignment.Bottom}){
            Image(item.thumbnail)
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .borderRadius(16)
              .shadow({
                radius:50,
                color:`rgba(0,0,0,0.3)`,
                offsetY:50/50
              })
            //不透明度逐层递减
              .opacity(1-Math.min(2,Math.abs(this.getImgCoeddicients(index)))*0.1)
            //模糊程度
              .blur(10*Math.abs(this.getImgCoeddicients(index)))
            Column(){
              Text(item.title)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)

              Text(item.subTitle)
                .fontSize(14)
                .fontColor('#CCFFFFFF')
                .margin({top:4})
            }
            .width('100%')
            .padding({left:18,right:18,top:14,bottom:18})
            .alignItems(HorizontalAlign.Start)
            .backgroundColor('#66000000')
          }
          .width(index !==this.aheadIndex&&this.getImgCoeddicients(index)===0
            ?'66%':`${86-10*Math.abs(this.getImgCoeddicients(index))}%`)
          //宽高比
          .aspectRatio(4/3)
          .borderRadius(16)
          .offset({x:0,y:this.getOffSetY(index)})
          //卡片最高为2 逐层递减
          .zIndex(index !==this.aheadIndex&&this.getImgCoeddicients(index)===0
          ?0:2-Math.abs(this.getImgCoeddicients(index)))
        },(item:ZonesItem)=>item.id.toString())
      }
      .width('100%')
      .height('100%')
      .margin({top:50/50})
      .alignContent(Alignment.Center)

      //点击事件
      .onClick(()=>{
        router.push({url:'pages/ContentPage',params:{id:this.zonesList[this.aheadIndex].id}})
      })
      //手指交互效果
      .gesture(
        PanGesture({direction:PanDirection.Vertical})
          .onActionStart((Event:GestureEvent|undefined)=>{
            //手势开始时可能是undefined
            //当判断为空时，直接返回，避免报错
            if (!Event) {
              return
            }
            //切换重置成功 只允许切换一次的效果
            this.changeIndex=false
            this.handlePanGesture(Event.offsetY)
          })
          .onActionUpdate((Event:GestureEvent|undefined)=>{
            //手势移动的过程，实时处理手势跟随
            if (!Event) {
              return
            }
            this.handlePanGesture(Event.offsetY)
          })
          .onActionEnd(()=>{
            //松手 切换->动画停止  拖动阈值，没有达到就复位
            animateTo({
              duration:300
            },()=>{
              this.marginBottom=0
            })
          })
      )

    }.title('区域导览')
    .backgroundColor('#F1F3F5')
    .titleMode(NavigationTitleMode.Full)
    .hideBackButton(true)
  }
}