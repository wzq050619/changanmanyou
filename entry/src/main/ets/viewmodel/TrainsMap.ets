//包含背景图，发车间隔，沿线坐标
export enum TrainsLine{
LINE_ONE=0,
LINE_TWO=1,
LINE_THREE=2,
}
export class Position{
  x:number=0
  y:number=0
}
@Observed
export class TrainsMap{
  imgBg:ImageBitmap=new ImageBitmap('common/images/ic_line1.png')
  interval:number=0
  lineData:Array<Position> = []
}