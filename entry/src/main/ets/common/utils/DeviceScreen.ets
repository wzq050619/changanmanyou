//设备信息的工具类
//异步去获取当前的窗口，用于大图弹窗里获取设备宽高
//详情页的首图缩放功能进行计算
import display from "@ohos.display";
import window from "@ohos.window";
export class DeviceScreen{
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

