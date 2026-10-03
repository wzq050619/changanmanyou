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

//景点图标、名称和真实经纬度；像素坐标与1536×1024新底图同步投影。

export const PositionList:Array<PositionItem>=[
  {
    icon:$r('app.media.ic_landmark_bell_tower'),
    text:$r('app.string.bell_tower'),
    type:PositionType.BELL_TOWER,
    lngLat:[{longitude:108.9423419, latitude:34.2610119}],
    mapPositionX:309.58,
    mapPositionY:674.52
  },
  {
    icon:$r('app.media.ic_landmark_city_wall'),
    text:$r('app.string.xian_city_wall'),
    type:PositionType.XIAN_CITY_WALL,
    lngLat:[{longitude:108.9423226, latitude:34.2528}],
    mapPositionX:309.52,
    mapPositionY:701.85
  },
  {
    icon:$r('app.media.ic_landmark_drum_tower'),
    text:$r('app.string.drum_tower'),
    type:PositionType.DRUM_TOWER,
    lngLat:[{longitude:108.9388419, latitude:34.2617601}],
    mapPositionX:299.95,
    mapPositionY:672.03
  },
  {
    icon:$r('app.media.ic_landmark_everbright_city'),
    text:$r('app.string.datang_everbright_city'),
    type:PositionType.DATANG_EVERBRIGHT_CITY,
    lngLat:[{longitude:108.9594054, latitude:34.2163961}],
    mapPositionX:356.5,
    mapPositionY:822.95
  },
  {
    icon:$r('app.media.ic_landmark_giant_pagoda'),
    text:$r('app.string.giant_wild_goose_pagoda'),
    type:PositionType.GIANT_WILD_GOOSE_PAGODA,
    lngLat:[{longitude:108.9594259, latitude:34.2197968}],
    mapPositionX:356.56,
    mapPositionY:811.63
  },
  {
    icon:$r('app.media.ic_landmark_huaqing_palace'),
    text:$r('app.string.huaqing_palace'),
    type:PositionType.HUAQING_PALACE,
    lngLat:[{longitude:109.2074268, latitude:34.3650509}],
    mapPositionX:1038.6,
    mapPositionY:328.11
  },
  {
    icon:$r('app.media.ic_landmark_shaanxi_museum'),
    text:$r('app.string.shaanxi_history_museum'),
    type:PositionType.SHAANXI_HISTORY_MUSEUM,
    lngLat:[{longitude:108.9503285, latitude:34.2257568}],
    mapPositionX:331.54,
    mapPositionY:791.81
  },
  {
    icon:$r('app.media.ic_landmark_small_pagoda'),
    text:$r('app.string.small_wild_goose_pagoda'),
    type:PositionType.SMALL_WILD_GOOSE_PAGODA,
    lngLat:[{longitude:108.9373484, latitude:34.2408075}],
    mapPositionX:295.84,
    mapPositionY:741.75
  },
  {
    icon:$r('app.media.ic_landmark_tang_paradise'),
    text:$r('app.string.tang_paradise'),
    type:PositionType.TANG_PARADISE,
    lngLat:[{longitude:108.9703951, latitude:34.2145475}],
    mapPositionX:386.73,
    mapPositionY:829.09
  },
  {
    icon:$r('app.media.ic_landmark_terracotta_army'),
    text:$r('app.string.terracotta_army_museum'),
    type:PositionType.TERRACOTTA_ARMY_MUSEUM,
    lngLat:[{longitude:109.2750227, latitude:34.3872158}],
    mapPositionX:1224.5,
    mapPositionY:254.26
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
