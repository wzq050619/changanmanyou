import ZonesItem from './ZonesItem';

/**
 *  区域介绍显示模型类
 *
 *  延伸改造说明（Day3AM）：
 *  1. 12 个区域（A~L、M，跳过 I）的文字与颜色资源原为
 *     $r('app.string.xxx') / $r('app.color.xxx') 引用，现全部硬编码为具体值；
 *  2. 图片资源（缩略图、轮播图、图集、建筑图、星轨图等）无法硬编码，
 *     保持 $r('app.media.xxx') 资源引用不变；
 *  3. 取数方法 getZonesList / getZonesByIndex 与参考工程保持一致。
 *
 * @author 却家庭
 * @version 1.0
 * @date 2024.06.02
 */
class ZonesViewModel {
  // 返回全部区域列表（供 Zones 组件 ForEach 渲染堆叠卡片）
  getZonesList(): ZonesItem[] {
    return defaultList;
  }

  // 按下标取单个区域（供详情页根据路由参数取数据）
  getZonesByIndex(index: number): ZonesItem {
    return defaultList[index];
  }
}

// 单例导出：整个应用共享同一份数据模型，避免重复实例化
let zonesViewModel = new ZonesViewModel();

export default zonesViewModel as ZonesViewModel;

/* 12 个区域的原始数据（文字/颜色已硬编码，图片保持 $r('app.media.xxx') 引用）
 * 每个区域字段含义：
 *   id                 区域编号（路由传参用）
 *   title / subTitle   区域名称与副标题（原 $r('app.string.area_name_x') 等）
 *   createTime         建成年代（原 $r('app.string.create_year_2015')）
 *   content            介绍正文两段（原 $r('app.string.introduction_paragraph_*')）
 *   buildingInformation 建筑信息（原 $r('app.string.build_information_x')）
 *   backgroundColor    主题背景色（原 $r('app.color.introduction_*')）
 *   其余 thumbnail / swiperPic / imageList 等均为图片资源引用，保持不变 */
const defaultList: ZonesItem[] = [
  {
    id: 0,
    title: '西安钟楼',
    subTitle: '古都中轴线上的城市地标',
    thumbnail: $r('app.media.scenic_bell_tower'),
    swiperPic: $r('app.media.scenic_bell_tower'),
    createTime: '古都核心地标',
    content: ['钟楼位于西安老城中心，重檐攒尖顶与青砖台基共同构成醒目的城市轮廓。它连接东西南北四条大街，也是理解西安城内空间格局的合适起点。',
      '夜间亮灯后，暖色木构与周边城市灯光形成鲜明对比；白天则更适合观察斗拱、檐角和台基细节。'],
    subPicTop: $r('app.media.scenic_bell_tower'),
    subPicBottom: $r('app.media.scenic_bell_tower'),
    titleIcon: $r('app.media.ic_title_top_A'),
    imageList: [$r('app.media.ic_A_1'), $r('app.media.ic_A_2'), $r('app.media.ic_A_3'), $r('app.media.ic_A_4'),
    $r('app.media.ic_A_5')],
    buildingInformation: '推荐从钟楼环形通道周边取景，傍晚至蓝调时刻画面层次较好。钟楼与鼓楼距离较近，可以安排在同一段步行线路中游览。',
    buildingPic: $r('app.media.scenic_bell_tower'),
    geographyPic: $r('app.media.ic_nav_map_xian'),
    geographyPicLight: $r('app.media.ic_nav_map_xian'),
    // 原 $r('app.color.introduction_page_green')
    backgroundColor: '#6F3B2C',
    starLinePic: [$r('app.media.ic_starLine_A_light'), $r('app.media.ic_starLine_A_dark')]
  },
  {
    id: 1,
    title: '西安城墙',
    subTitle: '沿城垣俯瞰古今长安',
    thumbnail: $r('app.media.scenic_city_wall'),
    swiperPic: $r('app.media.scenic_city_wall'),
    createTime: '明清古城防御体系',
    content: ['西安城墙环绕明清时期的城市核心，城门、角楼、敌楼和连续的青砖城垣保存了清晰的防御体系轮廓。登城后可以从较高视角观察老城街巷。',
      '宽阔的城墙顶适合步行，也能形成长距离透视构图。日出、日落时砖墙纹理和城楼剪影更加突出。'],
    subPicTop: $r('app.media.scenic_city_wall'),
    subPicBottom: $r('app.media.scenic_city_wall'),
    titleIcon: $r('app.media.ic_title_top_B'),
    imageList: [$r('app.media.ic_B_1'), $r('app.media.ic_B_2'), $r('app.media.ic_B_3'), $r('app.media.ic_B_4'),
      $r('app.media.ic_B_5')],
    buildingInformation: '可以选择永宁门附近登城。短线以城门和城楼为主，长线再考虑环城骑行。城墙顶部较为开阔，夏季注意防晒，冬季注意风力。',
    buildingPic: $r('app.media.scenic_city_wall'),
    geographyPic: $r('app.media.ic_nav_map_xian'),
    geographyPicLight: $r('app.media.ic_nav_map_xian'),
    backgroundColor: '#7A302A',
    starLinePic: [$r('app.media.ic_starLine_B_light'), $r('app.media.ic_starLine_B_dark')]
  },
  {
    id: 2,
    title: '西安鼓楼',
    subTitle: '飞檐与鼓声里的老城记忆',
    thumbnail: $r('app.media.scenic_drum_tower'),
    swiperPic: $r('app.media.scenic_drum_tower'),
    createTime: '老城传统木构地标',
    content: ['鼓楼与钟楼东西呼应，是西安老城中极具辨识度的传统木构建筑。层叠屋檐、彩绘构件和高台基，使建筑在街区中保持庄重的视觉中心。',
      '鼓楼周边连接多条老城街巷，适合把建筑参观与城市漫步结合起来。夜景照明会进一步强化屋檐轮廓。'],
    subPicTop: $r('app.media.scenic_drum_tower'),
    subPicBottom: $r('app.media.scenic_drum_tower'),
    titleIcon: $r('app.media.ic_title_top_C'),
    imageList: [$r('app.media.ic_C_1'), $r('app.media.ic_C_2'), $r('app.media.ic_C_3'), $r('app.media.ic_C_4'),
      $r('app.media.ic_C_5')],
    buildingInformation: '建议与钟楼安排在同一条线路中游览。拍摄正立面后，可以沿周边街巷寻找侧面檐角与城市街景同框的角度。',
    buildingPic: $r('app.media.scenic_drum_tower'),
    geographyPic: $r('app.media.ic_nav_map_xian'),
    geographyPicLight: $r('app.media.ic_nav_map_xian'),
    backgroundColor: '#734035',
    starLinePic: [$r('app.media.ic_starLine_C_light'), $r('app.media.ic_starLine_C_dark')]
  },
  {
    id: 3,
    title: '大唐不夜城',
    subTitle: '夜色中的盛唐主题街区',
    thumbnail: $r('app.media.scenic_everbright_city'),
    swiperPic: $r('app.media.scenic_everbright_city'),
    createTime: '曲江夜游街区',
    content: ['大唐不夜城以大雁塔周边的步行空间为轴线，通过唐风建筑、灯光、雕塑和公共表演营造连续的夜游体验。',
      '华灯初上后，街区的纵深、树阵和暖色灯带会形成完整的视觉节奏。节假日客流较大，游览时需要留出更多时间。'],
    subPicTop: $r('app.media.scenic_everbright_city'),
    subPicBottom: $r('app.media.scenic_everbright_city'),
    titleIcon: $r('app.media.ic_title_top_D'),
    imageList: [$r('app.media.ic_D_1'), $r('app.media.ic_D_2'), $r('app.media.ic_D_3'), $r('app.media.ic_D_4'),
      $r('app.media.ic_D_5')],
    buildingInformation: '建议傍晚到达，从大雁塔方向逐步向南游览。拍照时可以利用中轴线以及两侧连续灯光形成对称构图。',
    buildingPic: $r('app.media.scenic_everbright_city'),
    geographyPic: $r('app.media.ic_nav_map_xian'),
    geographyPicLight: $r('app.media.ic_nav_map_xian'),
    backgroundColor: '#65506F',
    starLinePic: [$r('app.media.ic_starLine_D_light'), $r('app.media.ic_starLine_D_dark')]
  },
  {
    id: 4,
    title: '大雁塔',
    subTitle: '古塔与长安佛教文化',
    thumbnail: $r('app.media.scenic_giant_pagoda'),
    swiperPic: $r('app.media.scenic_giant_pagoda'),
    createTime: '大慈恩寺历史建筑',
    content: ['大雁塔坐落于大慈恩寺内，方形砖塔轮廓简洁挺拔，是西安南部城市天际线的重要标志。塔体层层收分，近看能够感受到砖石结构的沉稳秩序。',
      '寺院空间适合安静参观，外围广场则提供更加开阔的远观视角。近景建筑细节与远景塔身具有不同的观赏体验。'],
    subPicTop: $r('app.media.scenic_giant_pagoda'),
    subPicBottom: $r('app.media.scenic_giant_pagoda'),
    titleIcon: $r('app.media.ic_title_top_E'),
    imageList: [$r('app.media.ic_E_1'), $r('app.media.ic_E_2'), $r('app.media.ic_E_3'), $r('app.media.ic_E_4'),
      $r('app.media.ic_E_5')],
    buildingInformation: '想观察建筑细节可以进入寺院，想拍摄完整塔身可在外围广场寻找机位。可以与陕西历史博物馆或大唐不夜城安排在同一天。',
    buildingPic: $r('app.media.scenic_giant_pagoda'),
    geographyPic: $r('app.media.ic_nav_map_xian'),
    geographyPicLight: $r('app.media.ic_nav_map_xian'),
    backgroundColor: '#8A652C',
    starLinePic: [$r('app.media.ic_starLine_E_lighter'), $r('app.media.ic_starLine_E_dark')]
  },
  {
    id: 5,
    title: '华清宫',
    subTitle: '骊山脚下的宫苑遗韵',
    thumbnail: $r('app.media.scenic_huaqing_palace'),
    swiperPic: $r('app.media.scenic_huaqing_palace'),
    createTime: '临潼宫苑景区',
    content: ['华清宫依骊山而建，宫苑建筑、温泉文化与山地景观共同构成游览主线。园内水面、廊桥和殿宇层层展开，整体气质与西安市区景点不同。',
      '游览时可以把建筑空间和骊山背景结合起来观察。秋季山色和水景层次较为丰富，晴天午后光线则相对强烈。'],
    subPicTop: $r('app.media.scenic_huaqing_palace'),
    subPicBottom: $r('app.media.scenic_huaqing_palace'),
    titleIcon: $r('app.media.ic_title_top_F'),
    imageList: [$r('app.media.ic_F_1'), $r('app.media.ic_F_2'), $r('app.media.ic_F_3'), $r('app.media.ic_F_4'),
      $r('app.media.ic_F_5')],
    buildingInformation: '园区范围较大，建议预留半天并穿舒适的鞋。可以先按主线参观宫苑，再根据时间和体力决定是否延伸到骊山相关区域。',
    buildingPic: $r('app.media.scenic_huaqing_palace'),
    geographyPic: $r('app.media.ic_nav_map_xian'),
    geographyPicLight: $r('app.media.ic_nav_map_xian'),
    backgroundColor: '#38636B',
    starLinePic: [$r('app.media.ic_starLine_F_lighter'), $r('app.media.ic_starLine_F_dark')]
  },
  {
    id: 6,
    title: '陕西历史博物馆',
    subTitle: '从文物读懂古都时间线',
    thumbnail: $r('app.media.scenic_shaanxi_museum'),
    swiperPic: $r('app.media.scenic_shaanxi_museum'),
    createTime: '陕西历史文化展陈',
    content: ['陕西历史博物馆以丰富馆藏呈现陕西地区漫长的历史脉络。馆舍采用唐风建筑语言，轴线明确、屋顶舒展，外部空间与展陈主题保持一致。',
      '相比单纯浏览展柜，按照时代顺序参观更容易建立完整认识。热门展品前停留人数较多，建议提前确定最想参观的部分。'],
    subPicTop: $r('app.media.scenic_shaanxi_museum'),
    subPicBottom: $r('app.media.scenic_shaanxi_museum'),
    titleIcon: $r('app.media.ic_title_top_G'),
    imageList: [$r('app.media.ic_G_1'), $r('app.media.ic_G_2'), $r('app.media.ic_G_3'), $r('app.media.ic_G_4'),
      $r('app.media.ic_G_5')],
    buildingInformation: '应提前按照官方预约要求安排行程，入馆后先确认展厅分布。馆内文字说明较多，完整参观需要预留充足时间。',
    buildingPic: $r('app.media.scenic_shaanxi_museum'),
    geographyPic: $r('app.media.ic_nav_map_xian'),
    geographyPicLight: $r('app.media.ic_nav_map_xian'),
    backgroundColor: '#45677F',
    starLinePic: [$r('app.media.ic_starLine_G_light'), $r('app.media.ic_starLine_G_dark')]
  },
  {
    id: 7,
    title: '小雁塔',
    subTitle: '闹市中的清幽古塔',
    thumbnail: $r('app.media.scenic_small_pagoda'),
    swiperPic: $r('app.media.scenic_small_pagoda'),
    createTime: '荐福寺历史文化片区',
    content: ['小雁塔位于荐福寺历史文化片区，塔身比例秀丽，周边古树与院落营造出安静克制的空间氛围。它与大雁塔风格不同，更适合慢速步行和观察细节。',
      '从院落中轴线远望，塔身会被树木和传统建筑自然框住。春秋两季光线柔和，庭院层次也更加丰富。'],
    subPicTop: $r('app.media.scenic_small_pagoda'),
    subPicBottom: $r('app.media.scenic_small_pagoda'),
    titleIcon: $r('app.media.ic_title_top_H'),
    imageList: [$r('app.media.ic_H_1'), $r('app.media.ic_H_2'), $r('app.media.ic_H_3'), $r('app.media.ic_H_4'),
      $r('app.media.ic_H_5')],
    buildingInformation: '适合安排一至两小时慢游。拍摄时不要只截取塔身，可以保留院门、树枝或者石径作为前景。',
    buildingPic: $r('app.media.scenic_small_pagoda'),
    geographyPic: $r('app.media.ic_nav_map_xian'),
    geographyPicLight: $r('app.media.ic_nav_map_xian'),
    backgroundColor: '#7A6038',
    starLinePic: [$r('app.media.ic_starLine_H_light'), $r('app.media.ic_starLine_H_dark')]
  },
  {
    id: 8,
    title: '大唐芙蓉园',
    subTitle: '曲江水岸的唐风园林',
    thumbnail: $r('app.media.scenic_tang_paradise'),
    swiperPic: $r('app.media.scenic_tang_paradise'),
    createTime: '曲江唐风文化园区',
    content: ['大唐芙蓉园以湖面和唐风建筑群组织游线，亭台、桥梁、柳岸与水中倒影是主要景观。园区在白天和夜间呈现两种不同气质。',
      '傍晚入园可以同时看到自然光与夜景灯光的转换。沿湖行走时，建筑倒影和前景植物能够形成较完整的画面层次。'],
    subPicTop: $r('app.media.scenic_tang_paradise'),
    subPicBottom: $r('app.media.scenic_tang_paradise'),
    titleIcon: $r('app.media.ic_title_top_J'),
    imageList: [$r('app.media.ic_J_1'), $r('app.media.ic_J_2'), $r('app.media.ic_J_3'), $r('app.media.ic_J_4'),
      $r('app.media.ic_J_5')],
    buildingInformation: '建议围绕湖区选择一段完整步行线路，避免在多个点位之间频繁折返。夜间活动和开放信息应以园区当天公告为准。',
    buildingPic: $r('app.media.scenic_tang_paradise'),
    geographyPic: $r('app.media.ic_nav_map_xian'),
    geographyPicLight: $r('app.media.ic_nav_map_xian'),
    backgroundColor: '#3E6B52',
    starLinePic: [$r('app.media.ic_starLine_J_lighter'), $r('app.media.ic_starLine_J_dark')]
  },
  {
    id: 9,
    title: '秦始皇帝陵博物院',
    subTitle: '地下军阵与秦代文明',
    thumbnail: $r('app.media.scenic_terracotta_army'),
    swiperPic: $r('app.media.scenic_terracotta_army'),
    createTime: '秦代遗址与文物展示',
    content: ['秦始皇帝陵博物院以兵马俑坑及相关遗址、文物展示为核心。成排陶俑与考古探方共同呈现出强烈的空间尺度。',
      '不同展区的信息密度较高。先理解整体布局，再观察陶俑的服饰、发式和姿态差异，会比只看规模更有收获。'],
    subPicTop: $r('app.media.scenic_terracotta_army'),
    subPicBottom: $r('app.media.scenic_terracotta_army'),
    titleIcon: $r('app.media.ic_title_top_K'),
    imageList: [$r('app.media.ic_K_1'), $r('app.media.ic_K_2'), $r('app.media.ic_K_3'), $r('app.media.ic_K_4'),
      $r('app.media.ic_K_5')],
    buildingInformation: '景区与西安市区有一定距离，建议预留大半天。展厅内不要使用闪光灯，并遵守现场参观和拍摄规定。',
    buildingPic: $r('app.media.scenic_terracotta_army'),
    geographyPic: $r('app.media.ic_nav_map_xian'),
    geographyPicLight: $r('app.media.ic_nav_map_xian'),
    backgroundColor: '#6D563A',
    starLinePic: [$r('app.media.ic_starLine_K_light'), $r('app.media.ic_starLine_K_dark')]
  }
];
