import {BottomTabsItems} from "./BottomTabsItems";

export const BottomTabslist:Array<BottomTabsItems>=[
  {
  icon:$r('app.media.ic_home'),
  inconSelected:$r('app.media.ic_home_selected'),
  text:$r('app.string.bottom_text_map')
  },
  {
    icon:$r('app.media.ic_find'),
    inconSelected:$r('app.media.ic_find_selected'),
    text:$r('app.string.bottom_text_zones')
  },
  {
    icon:$r('app.media.ic_drive'),
    inconSelected:$r('app.media.ic_drive_selected'),
    text:$r('app.string.bottom_text_trains')
  },
  {
    icon:$r('app.media.ic_user'),
    inconSelected:$r('app.media.ic_user_selected'),
    text:$r('app.string.bottom_text_users')
  }
]