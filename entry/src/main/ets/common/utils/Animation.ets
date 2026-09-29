import { AnimationItem } from '../../viewmodel/AnimationItem';
export class Animation {
  //吸顶图标切换
  public static changeTitleIcon(animationItem: AnimationItem) {
    let imageHeightVP = (animationItem.screenHeight * animationItem.imageHeight) / 100;
    let firstStarLine = imageHeightVP + 350 + 500 - 80;
    let secondStarLine = firstStarLine + 500;
    let thirdStarLine = secondStarLine + 500;
    //累计滚动量
    animationItem.offsetSum = animationItem.scrollerForList.currentOffset().yOffset;
    //滚动到阈值，标记位置
    if (animationItem.offsetSum > 10) {
      animationItem.listPosition = 1;
    }
    //图片颜色的更换
    if (animationItem.offsetSum > firstStarLine + 500 / 2) {
      if (animationItem.geogrophicPictype !== 'geography_light') {
        animationItem.geogrophicPictype = 'geography_light';
      }
    }
    if (animationItem.offsetSum <= firstStarLine + 500 / 2) {
      if (animationItem.geogrophicPictype !== 'geography_dark') {
        animationItem.geogrophicPictype = 'geography_dark';
      }
    }
    //吸顶图标的切换
    if (animationItem.currentListIndex === 2) {
      let targetIndex = 0;
      if ((animationItem.offsetSum > firstStarLine) &&
        (animationItem.offsetSum < secondStarLine)) {
        targetIndex = 1;
      } else if ((animationItem.offsetSum >= secondStarLine) &&
        (animationItem.offsetSum < thirdStarLine)) {
        targetIndex = 2;
      }
      //标题内容和比例
      let targetTitles: Array<string> = ['景点介绍', '游览建议', '地理位置'];
      let targetScales: Array<Array<number>> = [[1, 0, 0], [0, 1, 0], [0, 0, 1]];
      //标题变化才赋值
      if (animationItem.iconTitle !== targetTitles[targetIndex]) {
        animationItem.iconTitle = targetTitles[targetIndex];
      }
      //标题比例变化才赋值
      let targetScale = targetScales[targetIndex];
      let isSame = animationItem.scaleIcon.length === targetScale.length;

      //逐项比对防止每帧都创建新数组
      for (let i = 0; isSame && i < targetScale.length; i++) {
        if (animationItem.scaleIcon[i] !== targetScale[i]) {
          isSame = false;
        }
      }
      if (!isSame) {
        animationItem.scaleIcon = targetScale;
      }
    }
  }
  //首图缩放
  public static controlImageScale(animationItem: AnimationItem, offset: number, state: ScrollState): number {
    //上划offset>0，缩小空间>40，等比例缩小首图，降低透明度
    if ((offset > 0) && (animationItem.imageHeight > 40)) {
      let offsetHeight = (Math.abs(offset) * 100) / Number(animationItem.screenHeight);
      let heightOffset = animationItem.imageHeight - 40 > offsetHeight ?
        offsetHeight : animationItem.imageHeight - 40;
      animationItem.imageHeight = animationItem.imageHeight - heightOffset;
      //按比例降低透明度
      animationItem.arrowIconOpacity = animationItem.arrowIconOpacity - heightOffset / (100 - 40);
      return 0;
    }
    //下滑offset<0，按比例放大首图，恢复透明度
    if ((animationItem.listPosition === 0) && (offset < 0) && (animationItem.imageHeight < 100)) {
      let offsetHeight = (Math.abs(offset) * 100) / Number(animationItem.screenHeight);
      let heightOffset = 100 - animationItem.imageHeight > offsetHeight ?
        offsetHeight : 100 - animationItem.imageHeight;
      const imageHeight: number = animationItem.imageHeight;
      animationItem.imageHeight = imageHeight + heightOffset;
      const arrowIconOpacity: number = animationItem.arrowIconOpacity;
      animationItem.arrowIconOpacity = arrowIconOpacity + heightOffset / (100 - 40);
      return 0;
    }
    //惯性滑动
    if ((state === ScrollState.Scroll) && (offset < -40) && (animationItem.imageHeight === 100)) {
      return 0;
    }
    return offset;
  }
}
