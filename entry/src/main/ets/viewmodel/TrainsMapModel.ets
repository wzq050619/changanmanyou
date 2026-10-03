import { TrainsLine,TrainsMap , Position} from './TrainsMap';

//火车行驶一圈的时间
//按照总路线 来计算每帧刷新延迟   ----定时器
class TrainsMapModel{
  //计算一圈总长度
  calcDelay(distance:number,line:number):number{
    let ret:number=0
    switch (line){
      //每个单位耗时=时间/距离
      case TrainsLine.LINE_ONE:
        //10分钟
        ret=600000/distance
        break
      case TrainsLine.LINE_TWO:
        //17分钟
        ret=1020000/distance
        break
      case TrainsLine.LINE_THREE:
        //37分钟
        ret=2220000/distance
        break
      default :
        ret=0
    }
    return ret
  }
  //计算移动一个单位要多久
  calDistance(data:Position[]):number{
    let sumDistance:number=0
    //当前线路坐标的点数
    const length=data.length
    //遍历所有的坐标轴
    data.forEach((item:Position,index:number)=>{
      const startX=item.x
      const startY=item.y
      //第几条线路的起点 以及当下的坐标
      const endX=index===length-1?data[0].x:data[index+1].x
      const endY=index===length-1?data[0].y:data[index+1].y
      //到最后一个点的时候，连接最后一个点和第一个点，保证整个线路是连续不断的圆
      if (Math.abs(startX-endX)>=Math.abs(startY-endY)) {
        sumDistance+=Math.abs(startX-endX)
      }else {
        sumDistance+=Math.abs(startY-endY)
      }
    })
    return sumDistance
  }
  //根据当前的时间 推算已经行驶的距离长度
  //已经行驶的距离=一圈的总路程*（自发车时间%一圈的耗时）/一圈的耗时
  travelDistance(distance:number,startTime:string,line:number):number{
    let ret:number=0
    const date=new Date()
    const dateStr=`${date.getFullYear()}-${date.getMonth()+1}-${date.getDate()}`
    //发车时刻
    const startDate=new Date(date.getFullYear(),date.getMonth(),date.getDate(),Number(startTime.split(':')[0]),Number(startTime.split(':')[1])).getTime()
    //当前时间
    const currentDate=date.getTime()
    //已经过去的毫秒数
    //当前时间是早于发车时间的，diff就是负数，改成0
    const diff=Math.max(0,currentDate-startDate)

    switch (line){
      case TrainsLine.LINE_ONE:
        ret=distance*(diff%600000)/600000
        break
      case TrainsLine.LINE_TWO:
        ret=distance*(diff%1020000)/1020000
        break
      case TrainsLine.LINE_THREE:
        ret=distance*(diff%2220000)/2220000
        break
      default :
        ret=0
    }
    return Number (ret.toFixed(2))
  }
  //两个坐标点 连线方向角
  fetchDirection(startX:number,startY:number,endX:number,endY:number):number{
    //返回值兜底，起点和终点重合的情况下 保持为0
    let ret:number=0

    //判断垂直线段。如果起始的y大于终点y在向上开 方向角0
    //如果起始y小于终点y在向下开方向角180
    if (startX===endX) {
      return startY>endY?0:90*2
    }

    //判断水平方向。如果起始的x大于终点x在向左开 方向角-90
    //如果起始x小于终点x在向右开方向角90
    if (startY===endY) {
      return startX>endX?-90:90
    }


    let angle =this.calcAngle(startX,startY,endX,endY)
    //两个坐标连线计算夹角
    if (startX>endX&&startY>endY) {
      //第一象限向左上方移动
      //角度偏移=-（90-angle）
      ret=-(90-angle)
    }
    if (startX>endX&&startY<endY) {
      //第二象限向左下方移动
      ret =-90-angle
    }
    if (startX<endX&&startY>endY) {
      //第三象限向右上方移动
      ret=90-angle
    }
    if (startX<endX&&startY<endY) {
      //第四象限向右下方移动
      ret=90+angle
    }
    return ret
  }
  //计算两坐标之间的角度
  calcAngle(startX:number,startY:number,endX:number,endY:number):number {
    const x=Math.abs(startX-endX)
    const y=Math.abs(startY-endY)
    const radianA=Math.atan(y/x)
    const angleA=Math.round(180/Math.PI*radianA)
    return angleA
  }
  //火车每帧在x/y上的移动比例
  //每次x移动多少
  fethRatioX(start:Position,end:Position):number{
    let diffx=start.x-end.x
    let diffy=start.y-end.y
    if (Math.abs(diffx)>=Math.abs(diffy)) {
      return -diffx/Math.abs(diffx)
    }
    else {
      return -Number((diffx/Math.abs(diffy)).toFixed(2))
    }
  }
  //每次y移动多少
  fethRatioY(start:Position,end:Position):number{
    let diffx=start.x-end.x
    let diffy=start.y-end.y
    if (Math.abs(diffy)>=Math.abs(diffx)) {
      return -diffy/Math.abs(diffy)
    }
    else {
      return -Number((diffy/Math.abs(diffx)).toFixed(2))
    }
  }
}
//创建导出实例
let trainsMapModel=new TrainsMapModel()
export default trainsMapModel as TrainsMapModel

//真实地图坐标：OSM 经纬度经 Web Mercator 投影后映射到 865×494。
//路线按 OSRM 道路规划生成，仍属于自定义游玩路线。
export const PositionList: Array<TrainsMap> = [
  {
    imgBg: $r('app.media.ic_line1'),
    interval: 10,
    lineData: [
      { x: 402.73, y: 64.92 },
      { x: 406.33, y: 64.17 },
      { x: 406.27, y: 60.7 },
      { x: 401.81, y: 60.01 },
      { x: 398.99, y: 60.74 },
      { x: 398.94, y: 64.23 },
      { x: 402.69, y: 64.92 },
      { x: 402.44, y: 70.92 },
      { x: 365.87, y: 69.28 },
      { x: 366.3, y: 253.02 },
      { x: 404.07, y: 252.95 },
      { x: 404.14, y: 283.91 },
      { x: 405.16, y: 285.17 },
      { x: 411.6, y: 285.12 },
      { x: 405.16, y: 285.17 },
      { x: 404.14, y: 283.91 },
      { x: 404.07, y: 252.95 },
      { x: 429.82, y: 252.88 },
      { x: 427.93, y: 434.0 },
      { x: 485.5, y: 434.0 },
      { x: 485.54, y: 429.74 },
      { x: 491.52, y: 429.74 },
      { x: 491.6, y: 414.85 },
      { x: 494.33, y: 414.19 },
      { x: 494.8, y: 410.99 },
      { x: 499.5, y: 410.81 },
      { x: 499.5, y: 408.26 },
      { x: 430.42, y: 407.08 },
      { x: 431.79, y: 181.51 },
      { x: 432.52, y: 178.82 },
      { x: 436.3, y: 174.68 },
      { x: 437.23, y: 172.08 },
      { x: 437.7, y: 147.7 },
      { x: 437.38, y: 139.12 },
      { x: 431.84, y: 132.39 },
      { x: 431.83, y: 78.15 },
      { x: 432.79, y: 75.47 },
      { x: 435.9, y: 72.19 },
      { x: 436.38, y: 69.58 },
      { x: 434.83, y: 66.46 },
      { x: 431.3, y: 65.14 },
      { x: 423.48, y: 70.15 },
      { x: 402.44, y: 70.92 },
      { x: 402.73, y: 64.92 },
    ]


  },
  {
    imgBg: $r('app.media.ic_line2'),
    interval: 17,
    lineData: [
      { x: 218.7, y: 88.36 },
      { x: 218.7, y: 107.46 },
      { x: 205.49, y: 107.46 },
      { x: 205.36, y: 119.56 },
      { x: 367.44, y: 120.62 },
      { x: 368.53, y: 122.86 },
      { x: 367.95, y: 214.55 },
      { x: 377.58, y: 214.55 },
      { x: 367.77, y: 214.35 },
      { x: 368.53, y: 122.86 },
      { x: 366.61, y: 120.4 },
      { x: 415.62, y: 120.11 },
      { x: 429.9, y: 116.24 },
      { x: 429.17, y: 113.95 },
      { x: 420.47, y: 116.66 },
      { x: 411.0, y: 117.85 },
      { x: 336.55, y: 117.38 },
      { x: 339.03, y: 283.23 },
      { x: 410.43, y: 283.15 },
      { x: 413.71, y: 281.5 },
      { x: 415.29, y: 278.9 },
      { x: 415.53, y: 265.11 },
      { x: 418.04, y: 261.21 },
      { x: 498.18, y: 256.94 },
      { x: 510.37, y: 257.32 },
      { x: 511.26, y: 262.99 },
      { x: 510.51, y: 267.24 },
      { x: 498.19, y: 293.82 },
      { x: 495.21, y: 306.77 },
      { x: 495.19, y: 364.0 },
      { x: 542.68, y: 434.0 },
      { x: 564.4, y: 423.99 },
      { x: 574.33, y: 421.72 },
      { x: 659.64, y: 421.0 },
      { x: 659.64, y: 419.94 },
      { x: 638.04, y: 419.99 },
      { x: 638.04, y: 399.9 },
      { x: 642.39, y: 398.87 },
      { x: 645.01, y: 396.32 },
      { x: 646.19, y: 393.41 },
      { x: 645.57, y: 389.85 },
      { x: 643.03, y: 387.3 },
      { x: 633.6, y: 382.19 },
      { x: 630.37, y: 376.78 },
      { x: 628.64, y: 367.32 },
      { x: 604.77, y: 349.46 },
      { x: 595.51, y: 337.36 },
      { x: 590.18, y: 335.27 },
      { x: 562.01, y: 335.22 },
      { x: 558.05, y: 336.5 },
      { x: 551.55, y: 343.96 },
      { x: 543.93, y: 348.93 },
      { x: 542.02, y: 353.22 },
      { x: 544.15, y: 369.23 },
      { x: 546.71, y: 370.93 },
      { x: 554.52, y: 371.96 },
      { x: 565.0, y: 388.88 },
      { x: 565.02, y: 422.43 },
      { x: 555.61, y: 425.97 },
      { x: 543.33, y: 432.88 },
      { x: 496.41, y: 364.02 },
      { x: 496.87, y: 304.33 },
      { x: 499.38, y: 294.45 },
      { x: 512.51, y: 264.6 },
      { x: 506.14, y: 234.92 },
      { x: 436.34, y: 203.59 },
      { x: 433.57, y: 201.15 },
      { x: 432.12, y: 126.1 },
      { x: 429.17, y: 113.95 },
      { x: 420.47, y: 116.66 },
      { x: 411.0, y: 117.85 },
      { x: 259.61, y: 116.9 },
      { x: 259.61, y: 60.0 },
      { x: 236.33, y: 60.0 },
      { x: 236.33, y: 65.63 },
      { x: 225.96, y: 66.03 },
      { x: 224.94, y: 67.55 },
      { x: 224.9, y: 73.11 },
      { x: 220.61, y: 73.16 },
      { x: 218.88, y: 74.57 },
      { x: 218.7, y: 88.36 },
    ]
  },
  {
    imgBg: $r('app.media.ic_line3'),
    interval: 37,
    lineData: [
      { x: 102.97, y: 407.94 },
      { x: 101.07, y: 408.77 },
      { x: 102.08, y: 410.72 },
      { x: 102.12, y: 423.62 },
      { x: 100.67, y: 425.35 },
      { x: 100.61, y: 432.66 },
      { x: 102.24, y: 434.0 },
      { x: 103.58, y: 432.85 },
      { x: 103.69, y: 427.11 },
      { x: 102.31, y: 423.5 },
      { x: 102.31, y: 410.72 },
      { x: 103.38, y: 408.83 },
      { x: 102.4, y: 406.94 },
      { x: 102.7, y: 372.19 },
      { x: 104.98, y: 367.91 },
      { x: 137.92, y: 368.22 },
      { x: 161.18, y: 366.76 },
      { x: 164.99, y: 363.56 },
      { x: 181.48, y: 355.01 },
      { x: 211.35, y: 342.81 },
      { x: 245.64, y: 342.48 },
      { x: 255.97, y: 339.67 },
      { x: 264.73, y: 339.47 },
      { x: 270.61, y: 332.05 },
      { x: 282.73, y: 330.62 },
      { x: 301.75, y: 323.95 },
      { x: 315.32, y: 322.6 },
      { x: 320.78, y: 319.97 },
      { x: 328.75, y: 312.61 },
      { x: 337.45, y: 312.77 },
      { x: 345.38, y: 310.71 },
      { x: 346.93, y: 304.8 },
      { x: 360.06, y: 287.39 },
      { x: 398.06, y: 265.4 },
      { x: 409.95, y: 253.46 },
      { x: 429.07, y: 239.17 },
      { x: 450.23, y: 228.04 },
      { x: 476.49, y: 203.44 },
      { x: 492.11, y: 193.04 },
      { x: 503.01, y: 176.85 },
      { x: 515.12, y: 162.4 },
      { x: 519.28, y: 159.12 },
      { x: 534.29, y: 153.84 },
      { x: 550.44, y: 151.12 },
      { x: 565.45, y: 150.25 },
      { x: 586.57, y: 145.45 },
      { x: 591.01, y: 146.79 },
      { x: 612.01, y: 160.86 },
      { x: 612.02, y: 163.98 },
      { x: 615.79, y: 167.36 },
      { x: 612.02, y: 163.98 },
      { x: 612.01, y: 160.86 },
      { x: 606.68, y: 157.42 },
      { x: 625.09, y: 158.74 },
      { x: 628.35, y: 142.8 },
      { x: 630.13, y: 138.96 },
      { x: 640.66, y: 131.53 },
      { x: 660.52, y: 122.78 },
      { x: 712.78, y: 118.73 },
      { x: 717.49, y: 114.21 },
      { x: 719.54, y: 114.17 },
      { x: 719.54, y: 112.2 },
      { x: 721.47, y: 110.96 },
      { x: 740.66, y: 107.15 },
      { x: 740.26, y: 112.61 },
      { x: 747.74, y: 112.8 },
      { x: 748.39, y: 104.76 },
      { x: 764.24, y: 99.74 },
      { x: 764.24, y: 93.84 },
      { x: 762.87, y: 89.48 },
      { x: 756.75, y: 79.72 },
      { x: 749.01, y: 71.69 },
      { x: 741.33, y: 68.2 },
      { x: 722.31, y: 62.69 },
      { x: 686.11, y: 60.08 },
      { x: 638.41, y: 70.43 },
      { x: 631.61, y: 68.33 },
      { x: 628.36, y: 72.9 },
      { x: 616.84, y: 80.02 },
      { x: 608.33, y: 86.82 },
      { x: 600.66, y: 95.43 },
      { x: 583.1, y: 122.25 },
      { x: 572.35, y: 135.43 },
      { x: 538.4, y: 164.54 },
      { x: 507.53, y: 197.8 },
      { x: 496.95, y: 206.48 },
      { x: 468.84, y: 225.02 },
      { x: 425.97, y: 262.22 },
      { x: 411.13, y: 271.94 },
      { x: 377.88, y: 290.49 },
      { x: 346.26, y: 316.18 },
      { x: 337.05, y: 320.84 },
      { x: 327.65, y: 323.22 },
      { x: 302.04, y: 325.35 },
      { x: 294.45, y: 328.8 },
      { x: 282.4, y: 338.03 },
      { x: 279.2, y: 339.39 },
      { x: 267.52, y: 339.05 },
      { x: 264.11, y: 337.64 },
      { x: 262.21, y: 339.24 },
      { x: 255.52, y: 339.53 },
      { x: 246.0, y: 342.26 },
      { x: 210.85, y: 342.71 },
      { x: 180.18, y: 355.2 },
      { x: 164.74, y: 363.33 },
      { x: 161.16, y: 366.29 },
      { x: 151.15, y: 366.63 },
      { x: 151.07, y: 407.24 },
      { x: 146.9, y: 408.88 },
      { x: 102.97, y: 407.94 },
    ]
  }
]
