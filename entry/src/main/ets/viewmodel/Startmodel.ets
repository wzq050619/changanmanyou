interface IStart{
  day:Resource[];
  noon:Resource[];
  duck:Resource[];
  night:Resource[];
}
export const startImage:IStart={
  day:[$r('app.media.splash1'),$r('app.media.splash2'),$r('app.media.splash3')],
  noon:[$r('app.media.splash4'),$r('app.media.splash5'),$r('app.media.splash6')],
  duck:[$r('app.media.splash7'),$r('app.media.splash8'),$r('app.media.splash9')],
  night:[$r('app.media.splash10'),$r('app.media.splash11'),$r('app.media.splash12')]
}