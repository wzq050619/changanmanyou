import { TrainsMap,Position} from '../viewmodel/TrainsMap';
import {TrainsLine} from "../viewmodel/TrainsMap";
import {image} from "@kit.ImageKit";
import TrainsMapModel from "../viewmodel/TrainsMapModel";

//三层堆叠
  //第一层 canvas  背景图按路线范围缩放，保持路线全景
  //第二层 img层   火车头的方向箭头，根据方法进行旋转
  //第三层 canvas  火车图标 +红色光圈 每帧进行重绘
@Component
export default struct TrainsTrack{
  //第一层画布的配置,抗锯齿=让所有的斜线和圆弧边缘平滑
  private setting:RenderingContextSettings=new RenderingContextSettings(true)
  //第一层画布的2D绘图
  private context:CanvasRenderingContext2D=new CanvasRenderingContext2D(this.setting)

  //第二层
  private setting1:RenderingContextSettings=new RenderingContextSettings(true)
  private contextTrainLine:CanvasRenderingContext2D=new CanvasRenderingContext2D(this.setting1)

  //线路背景图的位图
  private imgBgBitmap:ImageBitmap|undefined=undefined

  //火车图标+红色光圈
  private imgTrain:ImageBitmap|undefined=undefined
  private imgCircle:ImageBitmap|undefined=undefined

  //线路图
  trainLine:number=0

  //可视窗口的宽高
  @State canvasWidth:number=0
  @State canvasHeight:number=0
  //小火车的坐标
  @State trainX:number=0
  @State trainY:number=0
  //地图缩放比例与居中偏移，火车使用同一套坐标转换
  @State mapScale:number=1
  //地图偏移量
  @State bgX:number=0
  @State bgY:number=0
  //当前火车行驶到哪一条线段
  @State currentIndex:number=0
  //火车车头旋转的角度
  @State rotateAngle:number=-205
  //当前线段起点和终点坐标
  @State positionStart:Position=new Position()
  @State positionEnd:Position=new Position()
  //总距离
  @State sumDistance:number=0
  //定时器,每帧刷新的时间
  @State delay:number=10
  //定时器,回收定时器(后台运行,整个画布,虽然关闭了,但是后台还在不断的刷新)
  private intervalId:number=-1
  //当前路线的所有数据(地图,坐标,发车间隔)
  @ObjectLink trainsInfo:TrainsMap

  //1.解码三张图片 2.计算总距离 3.用距离计算新的间隔 4.按照当前时间定位火车
  aboutToAppear(): void {
    //解码三张图片,地图图标红色光圈
    this.imgBgBitmap=this.LoadImageBitmap(this.trainsInfo.imgBg)
    this.imgTrain=this.LoadImageBitmap($r('app.media.ic_train'))
    this.imgCircle=this.LoadImageBitmap($r('app.media.ic_circle'))
    this.sumDistance=TrainsMapModel.calDistance(this.trainsInfo.lineData)
    this.delay=TrainsMapModel.calcDelay(this.sumDistance,this.trainLine)
    this.fetchStartPosition()
  }
  private LoadImageBitmap(res:Resource):ImageBitmap|undefined{
    try {
      //定位
      const context=getContext(this)
      const fileDate:Uint8Array=context.resourceManager.getMediaContentSync(res.id)
      const imageSource:image.ImageSource=image.createImageSource(fileDate.buffer as ArrayBuffer)

      //解码参数
      const options:image.DecodingOptions={
        editable:true,
        desiredPixelFormat:image.PixelMapFormat.RGBA_8888
      }
      const pixeMap:image.PixelMap=imageSource.createPixelMapSync(options)
      return new ImageBitmap(pixeMap)
    }catch (err){
      console.error('解码失败,在此处修改')
      return undefined
    }
  }
  //计算初始位置,按照当前的时间--->当前已经行驶了多少距离--->现在在哪个座标段上
  fetchStartPosition(){
    const travelDistance=TrainsMapModel.travelDistance(
      this.sumDistance,this.fetchStartTime(this.trainLine),this.trainLine)
      //总距离*(已经过的毫秒数%一圈行驶的毫秒数)/一圈的毫秒数===已经行驶的距离
      this.calcFirstDistance(this.trainsInfo.lineData,travelDistance)
}

  fetchStartTime(index: number): string {
    let ret='08:00'
    const date=new Date()
    const weekday=date.getDay()
    if (index===TrainsLine.LINE_THREE&&(weekday===6||weekday===0)) {
      ret='07:57'
    }
    return ret
  }
  //已经行驶的距离---->火车在哪个坐标段
  calcFirstDistance(data:Position[],travelDistance:number){
    //把从第0段的线段累加,和已经行驶的距离比大小
    const length=data.length
    let sumDistance:number=0
    for (let index = 0; index < length; index++) {
      if (sumDistance>travelDistance) {
        //累加路程        行驶路程
        this.currentIndex=index-1
        this.trainX=data[index-1].x
        this.trainY=data[index-1].y
        //将火车吸附到当前段点的起点坐标上



        //火车位置,画布边界限定
        break

      }else {
        //没有超过,继续进行累加
        const startX=data[index].x
        const startY=data[index].y

        //当处于最后一个坐标的时候,回到初始的坐标,完成闭环
        const endX=index===length-1?data[0].x:data[index+1].x
        const endY=index===length-1?data[0].y:data[index+1].y
        if (Math.abs(startX-endX)>=Math.abs(startY-endY)) {
          sumDistance+=Math.abs(startX-endX)
        }else {
          sumDistance+=Math.abs(startY-endY)
        }
      }
    }
  }
  //根据路线范围适配窗口，四周留出空间，避免图标贴边。
  fitRoute(w:number,h:number){
    const points=this.trainsInfo.lineData
    if (w<=48||h<=48||points.length===0) {
      return
    }
    let minX=points[0].x
    let maxX=points[0].x
    let minY=points[0].y
    let maxY=points[0].y
    points.forEach((point:Position)=>{
      minX=Math.min(minX,point.x)
      maxX=Math.max(maxX,point.x)
      minY=Math.min(minY,point.y)
      maxY=Math.max(maxY,point.y)
    })
    this.mapScale=Math.min((w-48)/Math.max(1,maxX-minX),(h-48)/Math.max(1,maxY-minY))
    this.bgX=w/2-(minX+maxX)/2*this.mapScale
    this.bgY=h/2-(minY+maxY)/2*this.mapScale
    //地图足够大时限制偏移，减少边缘空白，同时保持路线可见。
    if (865*this.mapScale>=w) {
      this.bgX=Math.max(24-minX*this.mapScale,
        Math.min(w-24-maxX*this.mapScale,Math.max(w-865*this.mapScale,Math.min(0,this.bgX))))
    }
    if (494*this.mapScale>=h) {
      this.bgY=Math.max(24-minY*this.mapScale,
        Math.min(h-24-maxY*this.mapScale,Math.max(h-494*this.mapScale,Math.min(0,this.bgY))))
    }
  }

  //火车位置的重绘，火车更新到下一个坐标 旋转角度
  drawTrainPosition(){
    //不能传无效的位图给绘制
    if (!this.imgBgBitmap||!this.imgTrain||!this.imgCircle) {
      return
    }
    if (Math.abs(this.trainX-this.positionEnd.x)<=2&&Math.abs(this.trainY-this.positionEnd.y)<=2) {
      this.trainX=this.positionEnd.x
      this.trainY=this.positionEnd.y
      if (this.currentIndex===this.trainsInfo.lineData.length-2) {
        this.currentIndex=0
      }else {
        this.currentIndex+=1
      }
    }
    //获取下一段的起点/终点
    this.positionStart=this.trainsInfo.lineData[this.currentIndex]
    this.positionEnd=this.trainsInfo.lineData[this.currentIndex+1]

    //车头的旋转角
    this.rotateAngle=-115+TrainsMapModel.fetchDirection(this.positionStart.x,this.positionStart.y,this.positionEnd.x,this.positionEnd.y)

    //清屏,清空火车和背景画布
    this.contextTrainLine.clearRect(0,0,this.canvasWidth,this.canvasHeight)
    this.context.clearRect(0,0,this.canvasWidth,this.canvasHeight)

    //火车坐标推进
    this.trainX+=TrainsMapModel.fethRatioX(this.positionStart,this.positionEnd)
    this.trainY+=TrainsMapModel.fethRatioY(this.positionStart,this.positionEnd)
    //地图重绘
    this.context.drawImage(this.imgBgBitmap,this.bgX,this.bgY,865*this.mapScale,494*this.mapScale)
    this.contextTrainLine.drawImage(
      this.imgTrain,
      this.trainX*this.mapScale+this.bgX-5,
      this.trainY*this.mapScale+this.bgY-5.5,
      10,
      10
    )
    //火车图标的重绘
    this.contextTrainLine.drawImage(
      this.imgCircle,
      this.trainX*this.mapScale+this.bgX-16,
      this.trainY*this.mapScale+this.bgY-16,
      32,
      32
    )
  }
  //画布定时器销毁
  aboutToDisappear(){
    if (this.intervalId!==-1) {
      clearInterval(this.intervalId)
    }
  }

  build() {
    Stack(){
      //背景画布，火车的指向箭头   火车图标画布
      Canvas(this.context)
        .width('100%')
        .aspectRatio(865/494)
        .borderRadius(4)
      //绘制画布
        .onReady(()=>{
          this.canvasWidth=this.context.width
          this.canvasHeight=this.context.height
          this.fitRoute(this.canvasWidth,this.canvasHeight)
          if (this.imgBgBitmap) {
            this.context.drawImage(this.imgBgBitmap,this.bgX,this.bgY,865*this.mapScale,494*this.mapScale)
          }
        })
        //窗口尺寸变化后重新适配路线。
        .onSizeChange((oldSize:SizeOptions,newSize:SizeOptions)=>{
          this.canvasWidth=Number(newSize.width)
          this.canvasHeight=Number(newSize.height)
          this.fitRoute(this.canvasWidth,this.canvasHeight)
        })
      Image($r('app.media.ic_train_arrow'))
        .width(28)
        .height(28)
        .position({
          x:this.trainX*this.mapScale+this.bgX-14,
          y:this.trainY*this.mapScale+this.bgY-14
          //箭头坐标=火车坐标×地图缩放比例+地图偏移量-14
        })
        .rotate({x:0,y:0,z:1,angle:this.rotateAngle})
      Canvas(this.contextTrainLine)
        .width('100%')
        .aspectRatio(865/494)
        .borderRadius(4)
        .onReady(() => {
          if (this.imgTrain && this.imgCircle) {
            this.contextTrainLine.drawImage(
              this.imgTrain,
              this.trainX * this.mapScale + this.bgX - 5,
              this.trainY * this.mapScale + this.bgY - 5.5,
              10,
              10
            )

            this.contextTrainLine.drawImage(
              this.imgCircle,
              this.trainX * this.mapScale + this.bgX - 16,
              this.trainY * this.mapScale + this.bgY - 16,
              32,
              32
            )
          }

          // 设置定时器
          this.intervalId = setInterval(() => {
            // 创建定时器，并且返回id，存入成员变量里
            this.drawTrainPosition()
            // 重绘+回调
          }, this.delay)
        })
      //保留可见地图署名，避免缩放裁切掉图片中的署名。
      Text('© OpenStreetMap contributors')
        .fontSize(8)
        .fontColor('#475569')
        .backgroundColor('#EFFFFFFF')
        .padding({left:4,right:4})
        .width('100%')
        .textAlign(TextAlign.End)
        .position({x:0,y:this.canvasHeight-14})
    }
    .clip(true)
  }
}

