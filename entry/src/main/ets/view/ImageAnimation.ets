import ZoneItem from '../viewmodel/ZonesItem'
import {ImageView} from "../view/ImageViewComponent";
import pan from '@ohos.bluetooth.pan';

@Component
export default struct ImageAnimation{
  @State currentIndex:number=2
  @Consume('contentData') contentData:ZoneItem
  dialogController:CustomDialogController=new CustomDialogController({
    builder:ImageView({currentImageId:this.currentIndex}),
    customStyle:true,
    alignment:DialogAlignment.Bottom
  })

  getImgCoefficients(index?:number){
    if (index===undefined) {
      return 0
    }
    let coefficient=this.currentIndex-index
    let tempCoefficient=Math.abs(coefficient)

    if (tempCoefficient<=2) {
      return coefficient
    }
    let dataLength=this.contentData.imageList.length
    let tempOffset=dataLength-tempCoefficient
    if (tempOffset<=2) {
      if (coefficient>0) {
        return -tempOffset
      }
      return tempOffset
    }
    return 0
  }

  getoffSetX(index?:number){
    if (index===undefined) {
      return 0
    }
    let offsetIndex=this.getImgCoefficients(index)
    let tempOffset=Math.abs(offsetIndex)
    let offsetX=0
    if (tempOffset===1) {
      offsetX=-70*offsetIndex
    }
    else if (tempOffset===2) {
      offsetX=-45*offsetIndex
    }
    return offsetX
  }
  starAnimation(isLeft:boolean){
    animateTo({
      duration:300,
    },()=>{
      let dataLength=this.contentData.imageList.length
      let tempIndex=isLeft?this.currentIndex+1:this.currentIndex-1+dataLength
      this.currentIndex=tempIndex%dataLength
    })
  }
  build() {
    Stack(){
      ForEach(this.contentData.imageList,(item:ResourceStr,index?:number)=>{
        Row(){
          Image(item)
            .opacity(1-0.1*Math.min(2,Math.abs(this.getImgCoefficients(index))))
            .objectFit(ImageFit.Contain)
            .borderRadius(8)
        }
        .aspectRatio(16/21)
        .borderRadius(8)
        .offset({
          x:this.getoffSetX(index),
          y:0
        })
        .blur(10*Math.abs(this.getImgCoefficients(index)))
        .zIndex(index !==this.currentIndex&&this.getImgCoefficients(index)===0?
          0:2-Math.abs(this.getImgCoefficients(index)))
        .height(index!==this.currentIndex&&this.getImgCoefficients(index)===0?
          '78%':`${100-7*Math.abs(this.getImgCoefficients(index))}%`)
        .onClick(()=>{
          this.dialogController.open()
        })
      },(item:Resource)=>JSON.stringify(item))
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
    .gesture(
      PanGesture({direction:PanDirection.Horizontal})
        .onActionStart((event?:GestureEvent)=>{
          if (!event) {
            return
          }
          this.starAnimation(event.offsetX<0)
        })
    )
  }
}