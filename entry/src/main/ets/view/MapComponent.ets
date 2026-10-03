//地图地标，搜索部分的图标
import {AddressItem,Location} from "../viewmodel/AddressItem";
import {PositionItem} from "../viewmodel/PositionItem";
import {CommonConstants as Const,PositionType} from "../common/constants/CommonConstants";
//日志
import Logger from "../common/utils/Logger";
//地图数据，对应的方法
import MapModel from "../viewmodel/MapModel";
import {PositionList} from "../viewmodel/MapModel";
//地图控制类
import MapController from "../controller/MapController";

@Component
export struct Map{
  private panOption:PanGestureOptions=new PanGestureOptions({direction:PanDirection.All})
  @State screenMapWidth:number=0
  @State screenHeight:number=0
  @State mapWidth:number=0
  @State mapHeight:number=0
  @State mapX:number=0
  @State mapY:number=0
  @Provide data:AddressItem=new AddressItem()

  build() {
    Stack({
      alignContent:Alignment.BottomEnd
    }){
      Column(){
        Stack({alignContent:Alignment.TopStart}){
          ForEach(this.data.location,(item:Location)=>{
            Image(this.data.icon)
              .width(Const.MAP_LANDMARKS_SIZE)
              .height(Const.MAP_LANDMARKS_SIZE)
              .offset({x:item.positionX,y:item.positionY})
            Text(this.data.name)
              .fontSize($r('app.float.map_text_size'))
              .fontColor(this.data.textColor)
              .fontWeight(FontWeight.Bold)
              .offset({
                x:item.positionX+Const.MAP_TEXT_OFFSET_X,
                y:item.positionY+Const.MAP_TEXT_OFFSET_Y
              })
          },(item:Location)=>JSON.stringify(item))
        }
        .width(this.mapWidth)
        .height(this.mapHeight)
        .backgroundImage($r('app.media.ic_nav_map_xian'))
        .backgroundImageSize(ImageSize.Cover)
        .offset({x:this.mapX,y:this.mapY})
      }
      .height(Const.FULL_PERCENT)
      .width(Const.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .onAreaChange((oldVal:Area,newVal:Area)=>{
        if (this.screenMapWidth===0||this.screenHeight===0) {
          this.screenMapWidth=Number(newVal.width)
          this.screenHeight=Number(newVal.height)
          //地图高度默认为父组件的高度
          this.mapHeight=this.screenHeight
          //地图的宽度 是由地图原始的宽高比得来的
          //地图的宽度=地图像素宽度1536/高度1024×显示高度
          this.mapWidth=Const.MAP_WIDTH*this.mapHeight/Const.MAP_HEIGHT
          this.mapX=(this.screenMapWidth-this.mapWidth)/Const.DOUBLE_OR_HALF
          //默认屏幕显示在地图的中心

          //初始化组件
          MapController.initLeftTop(this.screenMapWidth,this.mapWidth)
        }
      })

      .gesture(
        GestureGroup(GestureMode.Exclusive,
        //捏合的手势
        PinchGesture({fingers:Const.MAP_FINGER_COUNT})
          //获取两根手指
          .onActionUpdate((event:GestureEvent)=>{
            MapController.pinchUpdate(event,(ratio:number)=>{
              Logger.warn('这')
              this.mapWidth*=ratio
              this.mapHeight*=ratio
              //根据本次缩放的比例，来时实计算地图宽高
              let offsetX=(1-ratio)*(this.screenMapWidth/Const.DOUBLE_OR_HALF-this.mapX)
              let offsetY=(1-ratio)*(this.mapHeight/Const.MAP_ZOOM_RATIO/Const.DOUBLE_OR_HALF-this.mapY)
              this.mapX+=offsetX
              this.mapY+=offsetY
              //地标在现有比例地图上的坐标位置
              //新地标=初始地表*缩放的倍数-数字（修正常数）
              //修正常数    x坐标 减去半个图标的宽度    y坐标 减去一个图标的高度
              this.data.location=this.data.location?.map((item:Location)=>{
                item.positionX=item.oripositionX*MapController.mapMultiples()-Const.MAP_LANDMARKS_SIZE/Const.DOUBLE_OR_HALF
                item.positionY=item.oripositionY*MapController.mapMultiples()-Const.MAP_LANDMARKS_SIZE
                return item
              })
              //缩放后检查地图是否超出可视边界
              this.zoomOutCheck()
            })
          })
          //捏合/放开操作结束，重新计算边界基准数值
          .onActionEnd(()=>{
            MapController.pinchEnd(this.screenMapWidth,this.mapWidth,this.mapHeight)
          }),
          //双击手势，双击屏幕可以放大1.1倍
          TapGesture({count:Const.MAP_FINGER_COUNT})
          //count连续双击的次数
            .onAction(()=>{
              //内部捏合操作缩放公用pinchcount计数，总次数不能超过4次
              MapController.tapAction((isMaxTime:Boolean)=>{
                if (isMaxTime) {
                  return[]
                  //已经到最大值了，不再进行缩放，直接返回
                }
                this.mapWidth*=Const.MAP_ZOOM_RATIO
                this.mapHeight*=Const.MAP_ZOOM_RATIO
                let offsetX=(1-Const.MAP_ZOOM_RATIO)*(this.screenMapWidth/Const.DOUBLE_OR_HALF-this.mapX)
                let offsetY=(1-Const.MAP_ZOOM_RATIO)*(this.mapHeight/Const.MAP_ZOOM_RATIO/Const.DOUBLE_OR_HALF-this.mapY)
                this.mapX+=offsetX
                this.mapY+=offsetY
                //地标在现有比例地图上的坐标位置
                //新地标=初始地表*缩放的倍数-数字（修正常数）
                //修正常数    x坐标 减去半个图标的宽度    y坐标 减去一个图标的高度
                this.data.location=this.data.location?.map((item:Location)=>{
                  item.positionX=item.oripositionX*MapController.mapMultiples()-Const.MAP_LANDMARKS_SIZE/Const.DOUBLE_OR_HALF
                  item.positionY=item.oripositionY*MapController.mapMultiples()-Const.MAP_LANDMARKS_SIZE
                  return item
                })
                //计算放大后的地图左上角运行到达的最远位置，作为新的基准
                //minX=屏幕宽度-地图宽度
                //minY=地图高/缩放比例-地图高度
                //返回值中还是要写回lefttop中
                let minX=this.screenMapWidth-this.mapWidth
                let minY=this.mapHeight/MapController.mapMultiples()-this.mapHeight
                return [minX,minY]
              })
            }),
          //平移手势，单指拖动地图
          PanGesture(this.panOption)
          //panOption direction:pandirction.All  可以操控上下左右都响应
            .onActionUpdate((event:GestureEvent)=>{
              MapController.panUpdate(event,(mapPanX:number,mapPanY:number,lefttTop:Array<number>)=>{
                //按照位移增量去移动地图
                this.mapX+=mapPanX
                this.mapY+=mapPanY
                //限制：四个边界去设置，让地图永远不会被拖出可视区域
                if (this.mapX<lefttTop[0]) {
                  this.mapX = lefttTop[0]
                }
                if (this.mapX>0) {
                  this.mapX=0
                }
                if (this.mapY>0) {
                  this.mapY=0
                }
                if (this.mapY<lefttTop[1]) {
                  this.mapY=lefttTop[1]
                }
              })
            })
            .onActionEnd(()=>{
              //拖动结束以后清零panUpdate
              MapController.panEnd()

            })
          )
      )
      //固定显示地图署名，拖动或放大地图时保持可见。
      Text('© OpenStreetMap contributors')
        .fontSize(10)
        .fontColor('#475569')
        .backgroundColor('#EFFFFFFF')
        .padding(4)
        .position({x:8,y:8})
      //功能控制区-----搜索面板
      CustomPanel({
        screenMapWidth: $screenMapWidth,
        screenHeight: $screenHeight,
        mapWidth: $mapWidth,
        mapHeight: $mapHeight,
        mapX: $mapX,
        mapY: $mapY
      })

    }
  }

  //判断地图是否超出边界，
  zoomOutCheck():void{
    //mapx mapy大于0 地图左/上超出屏幕左/上边缘
    if (this.mapX>0) {
      this.mapX=0
    }
    if (this.mapY>0) {
      this.mapY=0
    }
    //mapX+mapwidth<屏幕宽度的情况  地图宽度没有铺满整个屏幕
    //mapy+mapheight<屏幕宽度 的情况地图纵向上没有铺满整个屏幕
    if ((this.mapX+this.mapWidth)<this.screenMapWidth) {
      this.mapX=this.screenMapWidth-this.mapWidth
    }
    if ((this.mapY+this.mapHeight)<this.mapHeight/MapController.mapMultiples()) {
      this.mapY=this.mapHeight/MapController.mapMultiples()-this.mapHeight
    }
  }
}
@Component
struct PositionGird{
  positionItem:PositionItem=new PositionItem()
  build() {
    Column(){
      Image(this.positionItem.icon)
        .width($r('app.float.navigation_panel_icon_size'))
        .height($r('app.float.navigation_panel_icon_size'))
        .margin($r('app.float.navigation_panel_icon_margin'))
      Text(this.positionItem.text)
        .fontSize($r('app.float.navigation_icon_text'))
    }
  }
}
//搜索区域
@Component
struct CustomPanel{
  //图标，透明度，高度，展开压缩状态，地图图标，父子双向绑定数据
  //地标位置
  @State positionList:Array<PositionItem>=PositionList
  //透明度
  @State panelOpacity:number=Const.PANEL_HIGH_OPACITY
  //高度
  @State panelHeight:number=Const.PANEL_FULL_HEIGHT
  //展开压缩状态
  @State flag:boolean=true
  @State isDownImage:boolean=true

  @State imageEnable:boolean=true
  @State iconOpacity:number=Const.PANEL_HIGH_OPACITY
  //地图图标的双向绑定
  @Consume data:AddressItem
  @Link screenMapWidth:number
  @Link screenHeight:number
  @Link mapWidth:number
  @Link mapHeight:number
  @Link mapX:number
  @Link mapY:number
  build() {
    Column(){

      //展开和缩起的图标
      Column(){
        Image(this.isDownImage?$r('app.media.ic_panel_down'):$r('app.media.ic_panel_up'))
          .enabled(this.imageEnable)
          .height($r('app.float.navigation_icon_down'))
          .onClick(()=>{
            this.upAndDown()
          })
      }
      .opacity(this.iconOpacity)
      .backgroundColor($r('app.color.custom_panel_background'))
      .borderRadius({
        topLeft:$r('app.float.navigation_panel_radius'),
        topRight:$r('app.float.navigation_panel_radius')
      })
      .width(Const.FULL_PERCENT)

      //搜索模块具体内容
      Column(){
        Search({placeholder:Const.PANEL_PLACEHOLDER})
          .height($r('app.float.navigation_search_height'))
          .width(Const.SEARCHBAR_WIDTH)
          .onSubmit((value:string)=>{
            //点击搜索的图标，进行回调
            this.positionList.forEach((item:PositionItem)=>{
              //foreach找到里面的所有元素
              if (MapController.getResourceString(item.text)===value) {
                this.data=MapModel.calCoordinateByMapPosition(item.mapPositionX,item.mapPositionY,item.type,
                  this.mapWidth,this.mapHeight)
                MapController.calLandmarkPosition(this.data)
                this.setFirstLandmarkscenter()
                this.upAndDown()
              }
            },(item:PositionItem)=>JSON.stringify(item))
          })
        Grid(){
          ForEach(this.positionList,(item:PositionItem)=>{
            GridItem(){
              PositionGird({positionItem:item})
                .enabled(this.imageEnable)
                .onClick(()=>{
                  this.data=MapModel.calCoordinateByMapPosition(item.mapPositionX,item.mapPositionY,item.type,
                    this.mapWidth,this.mapHeight)
                  MapController.calLandmarkPosition(this.data)
                  this.setFirstLandmarkscenter()
                  this.upAndDown()

                })
            }
          },(item:PositionItem)=>JSON.stringify(item))
        }
        .columnsTemplate(Const.GRID_COLUMNS)
        .columnsGap($r('app.float.navigation_column_gap'))
        .rowsGap($r('app.float.navigation_row_gap'))
        .padding($r('app.float.navigation_grid_padding'))
      }
      .opacity(this.panelOpacity)
      .height(this.panelHeight)
      .animation({
        duration:Const.ANIMATION_DURATION,
        curve:Curve.EaseOut,
        iterations:1,
        playMode:PlayMode.Normal
      })
      .backgroundColor($r('app.color.custom_panel_background'))
    }
    .width(Const.FULL_PERCENT)
    .borderRadius($r('app.float.navigation_panel_radius'))
  }
  upAndDown(){
    this.imageEnable=false
    if (this.isDownImage) {
      this.panelOpacity=0
      this.panelHeight=0
      this.iconOpacity=Const.PANEL_LOW_OPACITY
    }else {
      this.panelHeight=Const.PANEL_FULL_HEIGHT
      this.panelOpacity=Const.PANEL_HIGH_OPACITY
      this.iconOpacity=Const.PANEL_HIGH_OPACITY
    }
    this.isDownImage=!this.isDownImage
    this.imageEnable=true
  }
  //地表进行初始化后，默认将第一个去展示在中央
  setFirstLandmarkscenter():void{
    let location:Location[]=this.data.location??[]
    if (location.length>0) {
      this.mapX=this.screenMapWidth/Const.DOUBLE_OR_HALF-location[0].positionX-
        Const.MAP_LANDMARKS_SIZE/Const.DOUBLE_OR_HALF
      if (this.mapX>0) {
        this.mapX=0
      }
      if (this.mapX<this.screenMapWidth-this.mapWidth) {
        this.mapX=this.screenMapWidth-this.mapWidth
      }
      //右下角是否超出边界
      this.mapY=this.screenHeight/Const.DOUBLE_OR_HALF-location[0].positionY-Const.MAP_LANDMARKS_SIZE
      if (this.mapY>0) {
        this.mapY=0
      }
      if (this.mapY<(this.screenHeight-this.mapHeight)) {
        this.mapY=this.screenHeight-this.mapHeight
      }
    }
  }
}
