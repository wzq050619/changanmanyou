# 游玩路线地图来源

更新日期：2026-09-29。

四张 PNG 地图基于真实地理数据绘制，不使用 AI 生成路网。底图为 OpenStreetMap 标准地图，景点坐标来自 OpenStreetMap 对象，路线由 OSRM 的 driving profile 按景点顺序规划。这三条线路是自定义游玩路线，不代表官方公交、旅游专线或实时导航。

- 底图：[OpenStreetMap](https://www.openstreetmap.org/)，请求格式 `https://tile.openstreetmap.org/{z}/{x}/{y}.png`。
- 地图版权与许可：[OpenStreetMap Copyright](https://www.openstreetmap.org/copyright)。地图保留 `© OpenStreetMap contributors` 署名。
- 景点查询：[Overpass API](https://overpass-api.de/)。
- 道路规划：[OSRM HTTP API](https://project-osrm.org/docs/v26.4.0/http/)。使用 `overview=full&geometries=geojson` 获取道路折线。

## 景点坐标来源

| 景点 | OpenStreetMap 对象 |
| --- | --- |
| 西安鼓楼 | https://www.openstreetmap.org/way/254488437 |
| 西安钟楼 | https://www.openstreetmap.org/way/254488435 |
| 小雁塔 | https://www.openstreetmap.org/way/1284311674 |
| 陕西历史博物馆 | https://www.openstreetmap.org/way/1419575277 |
| 西安城墙·永宁门 | https://www.openstreetmap.org/way/497244585 |
| 大雁塔 | https://www.openstreetmap.org/way/92223044 |
| 大唐不夜城 | https://www.openstreetmap.org/node/2534820089 |
| 大唐芙蓉园 | https://www.openstreetmap.org/relation/18399358 |
| 华清宫 | https://www.openstreetmap.org/way/88216827 |
| 秦始皇帝陵博物院（兵马俑区域） | https://www.openstreetmap.org/way/71235670 |

路线规划会将景点中心吸附到附近可通行道路，因此路线停车位置可能与景点中心标记存在偏移。

## 项目资源与动画

- `entry/src/main/resources/base/media/ic_train_map.png`：三条线路总览。
- `entry/src/main/resources/base/media/ic_line1.png`、`ic_line2.png`、`ic_line3.png`：单条线路地图。
- 输出图片为 1730×988，动画坐标采用 865×494 基准。
- WGS84 经纬度经 Web Mercator 投影后生成地图和动画坐标；折线简化最大误差为基准坐标的 0.7。
- `TrainsMapModel.ets` 的路线点与各自的线路图同步生成。运行时间、发车间隔和既有演示动画周期未修改。
- 这些图片是离线静态地图，不包含实时路况、定位或导航指令。

生成脚本、原始景点与道路规划响应、地图瓦片缓存及投影坐标存于本机 `D:\Program Files (x86)\Codex-Map-Tools\2026-09-29`。
替换前的地图和相关代码备份存于 `D:\Program Files (x86)\Codex-Map-Backups\2026-09-29-navigation`。

## 地图页底图

`ic_nav_map_xian.png` 使用同一地区的 OpenStreetMap 真实底图，图片分辨率为3072×2048，使用1536×1024逻辑坐标，不叠加游玩路线、线路图例或线路站点。`MapModel.ets` 中10个景点的像素坐标和经纬度同步更新。`MapComponent.ets` 保留固定可见署名。原地图页图片和代码备份位于 `D:\Program Files (x86)\Codex-Map-Backups\2026-09-29-map-page`。
