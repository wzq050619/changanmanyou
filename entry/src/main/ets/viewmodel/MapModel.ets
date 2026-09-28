import {AddressItem,Location} from "./AddressItem";
import {PositionItem} from "./PositionItem";
import {CommonConstants as Const,PositionType} from "../common/constants/CommonConstants";
import MapController from "../controller/MapController";

class MapModel{
  calCoordinateByMapPosition(positionX:number,positionY:number,type:number,mapWidth:number,
    mapHeight:number):AddressItem{
    let addressItem=new AddressItem()
    addressItem.name=mapLandmarksName[type-1]
    addressItem.icon=mapLandmarksIcon[type-1]
    addressItem.textColor=mapLandmarksColor[type-1]
    let mapMultiples=MapController.mapMultiples()
    let baseMapWidth=mapWidth/mapMultiples
    let baseMapHeight=mapHeight/mapMultiples
    let locationX=positionX*baseMapWidth/Const.MAP_WIDTH
    let locationY=positionY*baseMapHeight/Const.MAP_HEIGHT
    addressItem.location=[new Location(locationX,locationY)]
    return addressItem
  }
}
let  mapModel=new MapModel()
export default mapModel as MapModel

//地表数据 图标  名称  经纬度  序号

export const PositionList:Array<PositionItem>=[
  {
    icon:$r('app.media.ic_landmark_bell_tower'),
    text:$r('app.string.bell_tower'),
    type:PositionType.BELL_TOWER,
    lngLat:[{longitude:108.942000, latitude:34.261000}],
    mapPositionX:344,
    mapPositionY:344
  },
  {
    icon:$r('app.media.ic_landmark_city_wall'),
    text:$r('app.string.xian_city_wall'),
    type:PositionType.XIAN_CITY_WALL,
    lngLat:[{longitude:108.942350, latitude:34.253139}],
    mapPositionX:561,
    mapPositionY:336
  },
  {
    icon:$r('app.media.ic_landmark_drum_tower'),
    text:$r('app.string.drum_tower'),
    type:PositionType.DRUM_TOWER,
    lngLat:[{longitude:108.938840, latitude:34.261760}],
    mapPositionX:348,
    mapPositionY:278
  },
  {
    icon:$r('app.media.ic_landmark_everbright_city'),
    text:$r('app.string.datang_everbright_city'),
    type:PositionType.DATANG_EVERBRIGHT_CITY,
    lngLat:[{longitude:108.959300, latitude:34.211500}],
    mapPositionX:392,
    mapPositionY:782
  },
  {
    icon:$r('app.media.ic_landmark_giant_pagoda'),
    text:$r('app.string.giant_wild_goose_pagoda'),
    type:PositionType.GIANT_WILD_GOOSE_PAGODA,
    lngLat:[{longitude:108.959354, latitude:34.219842}],
    mapPositionX:409,
    mapPositionY:673
  },
  {
    icon:$r('app.media.ic_landmark_huaqing_palace'),
    text:$r('app.string.huaqing_palace'),
    type:PositionType.HUAQING_PALACE,
    lngLat:[{longitude:109.211500, latitude:34.363900}],
    mapPositionX:1254,
    mapPositionY:272
  },
  {
    icon:$r('app.media.ic_landmark_shaanxi_museum'),
    text:$r('app.string.shaanxi_history_museum'),
    type:PositionType.SHAANXI_HISTORY_MUSEUM,
    lngLat:[{longitude:108.950330, latitude:34.225760}],
    mapPositionX:430,
    mapPositionY:560
  },
  {
    icon:$r('app.media.ic_landmark_small_pagoda'),
    text:$r('app.string.small_wild_goose_pagoda'),
    type:PositionType.SMALL_WILD_GOOSE_PAGODA,
    lngLat:[{longitude:108.937358, latitude:34.240803}],
    mapPositionX:175,
    mapPositionY:546
  },
  {
    icon:$r('app.media.ic_landmark_tang_paradise'),
    text:$r('app.string.tang_paradise'),
    type:PositionType.TANG_PARADISE,
    lngLat:[{longitude:108.967480, latitude:34.216930}],
    mapPositionX:642,
    mapPositionY:715
  },
  {
    icon:$r('app.media.ic_landmark_terracotta_army'),
    text:$r('app.string.terracotta_army_museum'),
    type:PositionType.TERRACOTTA_ARMY_MUSEUM,
    lngLat:[{longitude:109.275450, latitude:34.386120}],
    mapPositionX:1367,
    mapPositionY:102
  },
]
//文本信息
const mapLandmarksName:Array<Resource>=[
  $r('app.string.bell_tower'),
  $r('app.string.xian_city_wall'),
  $r('app.string.drum_tower'),
  $r('app.string.datang_everbright_city'),
  $r('app.string.giant_wild_goose_pagoda'),
  $r('app.string.huaqing_palace'),
  $r('app.string.shaanxi_history_museum'),
  $r('app.string.small_wild_goose_pagoda'),
  $r('app.string.tang_paradise'),
  $r('app.string.terracotta_army_museum'),
]
//颜色
const mapLandmarksColor:Array<Resource>=[
  $r('app.color.bell_tower_color'),
  $r('app.color.xian_city_wall_color'),
  $r('app.color.drum_tower_color'),
  $r('app.color.datang_everbright_city_color'),
  $r('app.color.giant_wild_goose_pagoda_color'),
  $r('app.color.huaqing_palace_color'),
  $r('app.color.shaanxi_history_museum_color'),
  $r('app.color.small_wild_goose_pagoda_color'),
  $r('app.color.tang_paradise_color'),
  $r('app.color.terracotta_army_museum_color'),
]
//图标
const mapLandmarksIcon:Array<Resource>=[
  $r('app.media.ic_landmark_bell_tower'),
  $r('app.media.ic_landmark_city_wall'),
  $r('app.media.ic_landmark_drum_tower'),
  $r('app.media.ic_landmark_everbright_city'),
  $r('app.media.ic_landmark_giant_pagoda'),
  $r('app.media.ic_landmark_huaqing_palace'),
  $r('app.media.ic_landmark_shaanxi_museum'),
  $r('app.media.ic_landmark_small_pagoda'),
  $r('app.media.ic_landmark_tang_paradise'),
  $r('app.media.ic_landmark_terracotta_army'),
]
