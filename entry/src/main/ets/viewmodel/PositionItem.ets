import {PositionType} from "../common/constants/CommonConstants";

//搜索功能区的图标信息

export class PositionItem{
  icon:Resource=$r('app.media.ic_landmark_bell_tower')
  text:Resource=$r('app.string.bell_tower')

  type:PositionType=PositionType.BELL_TOWER
  lngLat:Array<GeoCoordinates>=[]
  mapPositionX:number=0
  mapPositionY:number=0
}
//地理坐标

export class PixelCoordinates{
  coordinateX:number=0
  coordinateY:number=0
}
//经纬坐标
export class GeoCoordinates{
  latitude:number=0
  longitude:number=0
}
