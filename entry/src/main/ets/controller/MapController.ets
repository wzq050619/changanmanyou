import {AddressItem,Location} from "../viewmodel/AddressItem";
import {CommonConstants as Const,PositionType} from "../common/constants/CommonConstants";
import Logger from "../common/utils/Logger";
import { resourceManager } from "@kit.LocalizationKit";
import pan from "@ohos.bluetooth.pan";

const TAG='MapController'
export class MapController{
  private leftTop:Array<number>=[]
  private previousScale:number=0
  private pinchCount:number=0
  private panX:number=0
  private panY:number=0

  //初始化组件，计算地图左上角允许到达的最远位置
  initLeftTop(screenMapWidth:number,mapWidth:number):void{
    this.leftTop=[(screenMapWidth-mapWidth),0]
  }
  //双指捏合
  pinchUpdate(event:GestureEvent,callBack:Function):void{
    let scale=Number.parseFloat(event.scale.toFixed(Const.MAP_SCALE_ACCURACY))
    let ratio=1
    if (this.previousScale!==scale) {
      //向内捏合手势
      if (event.scale<1) {
        ratio=1/Const.MAP_ZOOM_RATIO
        this.pinchCount--
      }else {
      //向外扩张手势
        ratio=Const.MAP_ZOOM_RATIO
        this.pinchCount++
      }
      //放大次数由ZOOM_MAX_TIMES控制，pinchCount记录当前累积次数
      if ((this.pinchCount>Const.ZOOM_MAX_TIMES)) {
        //防止无限增大
        this.pinchCount=Const.ZOOM_MAX_TIMES
        return
      }
      if (this.pinchCount<0) {
        //防止无限缩小
        this.pinchCount=0
        return
      }
      callBack(ratio)
    }
    this.previousScale=scale
  }
  pinchEnd(screenMapWidth:number,mapWidth:number,mapHeight:number):void{
    //x轴的方向边界，地图有右边最多贴到屏幕的右边缘
    let minX=screenMapWidth-mapWidth
    //y轴的方向边界，地图下边最多贴到屏幕的下边缘
    let minY=(1/this.mapMultiples()-1)*mapHeight
    this.leftTop=[minX,minY]
  }
  //双击放大1.1倍，与双指缩放共用ZOOM_MAX_TIMES上限
  tapAction(callBack:Function):void{
    let isMaxTime:boolean=false
    if (++this.pinchCount>Const.ZOOM_MAX_TIMES) {
      this.pinchCount=Const.ZOOM_MAX_TIMES
      //达到上限后保持计数和拖动边界，避免地标定位发生偏移。
      return
    }
    //callback 在组件完成地图的缩放和地标的重算，并返回放大后左上角最远位置
    this.leftTop=callBack(isMaxTime)
  }
  //平移
  panUpdate(event:GestureEvent,callBack:Function){
    let panX=Number.parseInt(event.offsetX.toFixed(0))
    let panY=Number.parseInt(event.offsetY.toFixed(0))
    //只有累积的位移才处理，避免同一位置重复触发回调
    if ((this.panX!=panX)||(this.panY!=panY)) {
      let mapPanX=panX-this.panX
      let mapPanY=panY-this.panY
      //把增量和拖动边界lefttop一起回调
      callBack(mapPanX,mapPanY,this.leftTop)
    }
    this.panX=panX
    this.panY=panY

  }
  //平移操作结束，清零
  panEnd():void{
    this.panX=0
    this.panY=0
  }
  
  //重新计算地标的坐标值，出事的坐标*缩放的倍数-修正的尺寸
  calLandmarkPosition(data:AddressItem):void{
    data.location=data.location?.map((item:Location)=>{
      item.positionX=item.oripositionX*this.mapMultiples()-Const.MAP_LANDMARKS_SIZE/Const.DOUBLE_OR_HALF
      item.positionY=item.oripositionY*this.mapMultiples()-Const.MAP_LANDMARKS_SIZE
      return item
    })
  }
//缩放比例
  mapMultiples():number{
    return Math.pow(Const.MAP_ZOOM_RATIO,this.pinchCount)
  }

  //输入文本查询地标，把资源对象转成字符串，再进行比对
  getResourceString(resource:Resource):string{
    let resourceString:string=''
    try {
      resourceString=getContext(this).resourceManager.getStringSync(resource.id)
    }catch (err){
      Logger.error(TAG,`查询不到`)
    }
    return resourceString
  }
}

let mapController=new MapController()
export default mapController as MapController
