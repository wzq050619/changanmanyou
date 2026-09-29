//存放动画结构单元
@Observed
export class AnimationItem{
  //设备可视窗口的高度
  screenHeight:number=0
  //列表累计滚动高度
  offsetSum:number=0
  //详情页List的滚动控制器
  scrollerForList:Scroller=new Scroller()
  //标题/箭头的透明度
  arrowIconOpacity:number=1
  //首图高度的百分比
  imageHeight:number=100
  //列表，顶部 0， 中部  1，底部 2
  listPosition:number=0
  //地理位置图片
  geogrophicPictype:string='geography_light'
  //小标题，设计风格，建筑信息，地理位置
  iconTitle:string='景点介绍'
  //吸顶图标
  scaleIcon:Array<number>=[1,0,0]
  //当前列表的下标
  currentListIndex:number=0
}