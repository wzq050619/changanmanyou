import {TrainsLine,TrainsMap} from "../viewmodel/TrainsMap";
import {PositionList} from "../viewmodel/TrainsMapModel";
import {JSON} from "@kit.ArkTS";
import TrainsTrack from "./TrainsTrackComponent";

//全部路线图0 1 2
//三条路线的运营状态 （路线名+运行状态+发车间隔）
//判断  当前运营状态  运营中 绿色   非运营 红色   发车间隔 灰色弱化
@Component
export struct Trains{
  @State trainsMapData:TrainsMap[]=PositionList

  //三条线路的展开或者收缩效果
  @StorageLink(`showLineOne`) showLineOne:boolean=false
  @StorageLink(`showLineTwo`) showLineTwo:boolean=false
  @StorageLink(`showLineThree`) showLineThree:boolean=false
  isOperating(line?:number):boolean{
    if (line === undefined) {
      return false
    }
    let ret:boolean
    switch (line){
      case TrainsLine.LINE_ONE:
        //运行时段示例：09:00–21:00
        ret=this.checkTime('09:00','21:00')
        break
      case TrainsLine.LINE_TWO:
        ret=this.checkTime('09:00','20:00') &&!this.checkWeekend()
        break
      case TrainsLine.LINE_THREE:
        ret=(this.checkTime('08:00','18:00')&&!this.checkWeekend())||(this.checkTime('08:00','18:00')&&this.checkWeekend())
        break
      default :
      //不在显示的三条线内
        ret=true
    }
    return ret
  }

  checkTime(startTime:string,endTime:string):boolean{
    const date =new Date()
    const dateStr=`${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()} `
    const startDate=new Date(dateStr+startTime).getTime()
    const endDate=new Date(dateStr+endTime).getTime()
    const currentDate=date.getTime()

    return currentDate>=startDate && currentDate<=endDate
  }
  checkWeekend():boolean{
    const date =new Date()
    const weekday=date.getDay()
    return weekday===0||weekday===6
  }
  changeShowMap(line?:number){
    if (line===undefined) {
      return
    }
    switch (line){
      case TrainsLine.LINE_ONE:
        this.showLineOne=!this.showLineOne
        break;
      case TrainsLine.LINE_TWO:
        this.showLineTwo=!this.showLineTwo
        break;
      case TrainsLine.LINE_THREE:
        this.showLineThree=!this.showLineThree
        break;
    }
  }
  //查询每条路线处于什么状态
  fetchShowMap(line?:number):boolean{
    if (line===undefined) {
      return false
    }
    let ret:boolean
    switch (line){
      case TrainsLine.LINE_ONE:
        ret=this.showLineOne
        break
      case TrainsLine.LINE_TWO:
        ret=this.showLineTwo
        break
      case TrainsLine.LINE_THREE:
        ret=this.showLineThree
        break
      default :
        ret=false
    }
    return ret
  }
  build() {
    Navigation(){
      Column({space:12}){
        Image($r('app.media.ic_train_map'))
          .aspectRatio(1.75)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)

        //三条运营路线
        List({space:12}){
          ForEach(this.trainsMapData,(item:TrainsMap,index?:number)=>{
            ListItem(){
              Column({space:12}){
                Row(){
                  //路线名+运行状态+发车间隔
                  Text(){
                    Span(`${index?index+1:1}号线`)
                    Span(this.isOperating(index)?'(运营中)':'(非运营)')
                      .fontColor(this.isOperating(index)?'#ff35b83c':'#ffe90000')
                      .fontSize(14)
                      .fontWeight(500)
                  }
                  Text(`约${item.interval}分钟/趟`)
                    .fontColor('#99000000')
                    .fontSize(14)
                    .fontWeight(400)

                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Center)

                .onClick(()=>{
                  this.changeShowMap(index)
                  this.trainsMapData=this.trainsMapData.slice(0)
                })

                if (this.fetchShowMap(index)&&this.isOperating(index)) {
                  //第一个参数表示的当前线路是否展开
                  //第二个参数表示是否在运营时间内

                  //展开的具体内容
                  TrainsTrack({
                    trainsInfo:this.trainsMapData[index?index:0],
                    trainLine:index?index:0
                  })
                }
              }
              .borderRadius(8)
              .padding({
                top:17,
                bottom:18,
                left:12,
                right:12
              })
            }
          },(item:TrainsMap)=>JSON.stringify(item))
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.None)
      }
      .padding({left:12,right:12})
      .height('100%')
    }
    .title('游玩路线')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(true)
    .hideBackButton(true)
    .backgroundColor('#FFF1F3F5')
  }
}
