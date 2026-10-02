//设备信息的工具类
//异步去获取当前的窗口，用于大图弹窗里获取设备宽高
//详情页的首图缩放功能进行计算
import display from "@ohos.display";
import window from "@ohos.window";
import { UIContext } from "@ohos.arkui.UIContext";
export class DeviceScreen{
  // 全屏模式下读取系统避让区，将像素高度转换为布局使用的 vp。
  public static async getSafeAreaPadding(uiContext: UIContext): Promise<Padding> {
    try {
      const context = uiContext.getHostContext()
      if (!context) {
        return { top: 32, bottom: 0 }
      }
      const currentWindow = await window.getLastWindow(context)
      const systemArea = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      const navigationArea = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      return {
        top: uiContext.px2vp(systemArea.topRect.height),
        bottom: uiContext.px2vp(Math.max(systemArea.bottomRect.height, navigationArea.bottomRect.height))
      }
    } catch {
      // 编辑器预览或窗口暂不可用时，先保留顶部留白。
      return { top: 32, bottom: 0 }
    }
  }
  //返回当前窗口promise，供调用方then，去读取window
  public static getDeviceSize(context:Context):Promise<window.Window>{
    return window.getLastWindow(context)
  }
  //读取：默认显示：像素高*（基准DPI/实际DPI）=逻辑高度vp
  public static getDeviceHeight():number{
    let displayObject=display.getDefaultDisplaySync()
    let screenPixelHeight=displayObject.height
    let screenDensityDPI=displayObject.densityDPI
    //160为基准的DPI，用于把物理像素换算成vp
    return screenPixelHeight*(160/screenDensityDPI)
  }
}

