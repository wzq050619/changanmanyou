import router from '@ohos.router'
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

// 姓名、手机号编辑弹窗；保存成功后才关闭。
@CustomDialog
struct ProfileEditDialog {
  controller?: CustomDialogController
  title: string = ''
  @Link savedValue: string
  isPhone: boolean = false
  onSave: (value: string) => boolean = () => false
  @State value: string = ''
  @State error: string = ''

  aboutToAppear(): void {
    this.value = this.savedValue
  }

  build() {
    Column({ space: 16 }) {
      Text(`修改${this.title}`).fontSize(20).fontWeight(FontWeight.Medium)
      TextInput({ text: this.value, placeholder: `请输入${this.title}` })
        .type(this.isPhone ? InputType.PhoneNumber : InputType.Normal)
        .maxLength(this.isPhone ? 11 : 30)
        .onChange((value: string) => {
          this.value = value
          this.error = ''
        })
      if (this.error.length > 0) {
        Text(this.error).fontSize(13).fontColor($r('app.color.non_operational'))
      }
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor($r('app.color.common_background_color'))
          .fontColor($r('app.color.font_color_black'))
          .onClick(() => this.controller?.close())
        Button('保存')
          .layoutWeight(1)
          .backgroundColor($r('app.color.bottom_tabs_font_color_selected'))
          .onClick(() => {
            const value = this.value.trim()
            if (value.length === 0) {
              this.error = `${this.title}不能为空`
            } else if (this.isPhone && !/^\d{11}$/.test(value)) {
              this.error = '手机号必须为 11 位数字'
            } else if (this.onSave(value)) {
              // 持久化成功后，通过双向绑定立即更新父组件。
              this.savedValue = value
              this.controller?.close()
            } else {
              this.error = '保存失败，请重试'
            }
          })
      }
      .width('100%')
    }
    .padding(24)
    .width('100%')
    .backgroundColor($r('app.color.start_window_background'))
    .borderRadius(20)
  }
}

// 点击头像查看大图，点击图片即可关闭。
@CustomDialog
struct AvatarPreviewDialog {
  controller?: CustomDialogController

  build() {
    Column({ space: 16 }) {
      Image($r('app.media.ic_header'))
        .width('100%')
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
      Text('点击图片关闭').fontSize(14).fontColor(Color.White)
    }
    .width('85%')
    .onClick(() => this.controller?.close())
  }
}

// “我的”标签页：资料展示、姓名和手机号编辑、头像预览、关于页面入口。
@Component
export struct PersonalCenter {
  // 行高随内容区高度调整；保持可读字号，小屏仍允许滚动。
  @State rowHeight: number = 36
  @State userName: string = 'P13 花钱小王子'
  @State phone: string = '13800008888'
  private profileStore?: preferences.Preferences
  private nameDialog: CustomDialogController = new CustomDialogController({
    builder: ProfileEditDialog({
      title: '姓名', savedValue: this.userName,
      onSave: (value: string): boolean => this.saveProfile('name', value)
    }),
    customStyle: true,
    autoCancel: true
  })
  private phoneDialog: CustomDialogController = new CustomDialogController({
    builder: ProfileEditDialog({
      title: '手机号', savedValue: this.phone, isPhone: true,
      onSave: (value: string): boolean => this.saveProfile('phone', value)
    }),
    customStyle: true,
    autoCancel: true
  })
  private avatarDialog: CustomDialogController = new CustomDialogController({
    builder: AvatarPreviewDialog(),
    customStyle: true,
    autoCancel: true,
    maskColor: '#E6000000'
  })

  // 读取本地资料；其他展示字段沿用参考图中的示例数据。
  aboutToAppear(): void {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      this.profileStore = preferences.getPreferencesSync(context, { name: 'personal_profile' })
      this.userName = this.profileStore.getSync('name', this.userName) as string
      this.phone = this.profileStore.getSync('phone', this.phone) as string
    } catch {
      this.getUIContext().getPromptAction().showToast({ message: '本地资料读取失败' })
    }
  }

  aboutToDisappear(): void {
    this.nameDialog.close()
    this.phoneDialog.close()
    this.avatarDialog.close()
  }

  // 再次校验并持久化；弹窗通过 @Link 同步更新页面资料。
  private saveProfile(field: string, value: string): boolean {
    if (value.trim().length === 0 || (field === 'phone' && !/^\d{11}$/.test(value))) {
      return false
    }
    if (!this.profileStore) {
      return false
    }
    try {
      this.profileStore.putSync(field, value)
      this.profileStore.flushSync()
      return true
    } catch {
      return false
    }
  }

  @Builder
  Icon(icon: Resource, color: ResourceColor = $r('app.color.indicator_color')) {
    Image(icon).width(20).height(20).fillColor(color)
  }

  // 卡片标题使用项目蓝色图标。
  @Builder
  CardTitle(title: string, icon: Resource) {
    Row({ space: 12 }) {
      this.Icon(icon, $r('app.color.bottom_tabs_font_color_selected'))
      Text(title).fontSize(18).fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.font_color_black'))
    }
    .width('100%')
    .height(34)
    .border({ width: { bottom: 0.5 }, color: $r('app.color.common_background_color') })
  }

  // 通用信息行：只有可点击的条目显示右侧箭头。
  @Builder
  InfoRow(label: string, value: string, icon: Resource, action: () => void = () => {},
    clickable: boolean = false, last: boolean = false) {
    Row({ space: 12 }) {
      this.Icon(icon)
      Text(label).fontSize(14).fontColor($r('app.color.indicator_color'))
      // 可编辑内容直接读取页面状态，避免 Builder 按值传参保留旧内容。
      Text(label === '姓名' ? this.userName : label === '手机号' ?
        this.phone.substring(0, 3) + '****' + this.phone.substring(7) : value).fontSize(14).fontColor($r('app.color.color_gradient_1'))
        .layoutWeight(1).textAlign(TextAlign.End)
      if (clickable) {
        Image($r('app.media.profile_right')).width(14).height(14)
          .fillColor($r('app.color.indicator_color'))
      }
    }
    .width('100%')
    .constraintSize({ minHeight: this.rowHeight })
    .padding({ top: 5, bottom: 5 })
    .border({ width: { bottom: last ? 0 : 0.5 }, color: $r('app.color.common_background_color') })
    .onClick(() => {
      if (clickable) {
        action()
      }
    })
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 8 }) {
          // 头像与资料摘要，点击头像弹出大图。
          Row({ space: 12 }) {
            Image($r('app.media.ic_header')).width(72).height(72)
              .objectFit(ImageFit.Contain).borderRadius(36)
              .accessibilityText('查看头像大图')
              .onClick((): void => this.avatarDialog.open())
            Column({ space: 6 }) {
              Text(this.userName).fontSize(22).fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.font_color_black'))
              Text('在职').fontSize(12).fontColor(Color.White)
                .backgroundColor($r('app.color.bottom_tabs_font_color_selected'))
                .padding({ left: 12, right: 12, top: 3, bottom: 3 }).borderRadius(12)
              Text('技术部 · 前端开发工程师').fontSize(14)
                .fontColor($r('app.color.indicator_color'))
            }
            .layoutWeight(1).alignItems(HorizontalAlign.Start)
          }
          .width('100%').padding({ top: 4, bottom: 4 })

          // 基本信息：姓名和手机号可编辑，头像预览保留在顶部，入职时间统一展示在企业卡片。
          Column() {
            this.CardTitle('基本信息', $r('app.media.profile_user'))
            this.InfoRow('姓名', this.userName, $r('app.media.profile_user'),
              (): void => this.nameDialog.open(), true)
            this.InfoRow('工号', 'P013', $r('app.media.profile_id'))
            this.InfoRow('手机号', `${this.phone.substring(0, 3)}****${this.phone.substring(7)}`,
              $r('app.media.profile_phone'), (): void => this.phoneDialog.open(), true)
            this.InfoRow('邮箱', 'p13@example.com', $r('app.media.profile_mail'), () => {}, false, true)
          }
          .width('100%').padding({ left: 16, right: 16, bottom: 4 })
          .backgroundColor($r('app.color.start_window_background')).borderRadius(16)

          // 教育背景：参考图中的示例资料。
          Column() {
            this.CardTitle('教育背景', $r('app.media.profile_education'))
            this.InfoRow('毕业院校', '某某大学', $r('app.media.profile_user'))
            this.InfoRow('专业', '计算机科学与技术', $r('app.media.profile_education'))
            this.InfoRow('学历', '本科', $r('app.media.profile_education'), () => {}, false, true)
          }
          .width('100%').padding({ left: 16, right: 16, bottom: 4 })
          .backgroundColor($r('app.color.start_window_background')).borderRadius(16)

          // 企业信息：公司入口改为跳转到已完成的关于页面。
          Column() {
            this.CardTitle('企业信息', $r('app.media.profile_company'))
            this.InfoRow('公司名称', '长安漫游', $r('app.media.profile_company'), () => {
              router.pushUrl({ url: 'pages/AboutPage' }).catch(() => {
                this.getUIContext().getPromptAction().showToast({ message: '页面打开失败，请重试' })
              })
            }, true)
            this.InfoRow('所属部门', '技术部', $r('app.media.profile_company'))
            this.InfoRow('职位', '前端开发工程师', $r('app.media.profile_user'))
            this.InfoRow('入职时间', '2023-06-01', $r('app.media.profile_calendar'), () => {}, false, true)
          }
          .width('100%').padding({ left: 16, right: 16, bottom: 4 })
          .backgroundColor($r('app.color.start_window_background')).borderRadius(16)

          Text('本页为示例内容，可点击修改。').fontSize(12)
            .fontColor($r('app.color.indicator_color'))
        }
        .width('100%').padding({ left: 16, right: 16, bottom: 8 })
      }
      .width('100%').height('100%').scrollBar(BarState.Off)
      .align(Alignment.Top)
      .onAreaChange((_oldArea: Area, newArea: Area) => {
        // 摘要、卡片标题和间距约占 250vp，剩余高度分配给 11 行资料。
        this.rowHeight = Math.max(30, Math.min(46, (Number(newArea.height) - 250) / 11))
      })
    }
    .width('100%').height('100%')
    // 与区域导览、游玩路线页面统一使用紧凑标题栏。
    .title('个人信息')
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .hideToolBar(true)
    .backgroundColor($r('app.color.common_background_color'))
  }
}
