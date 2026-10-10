import { AIMessage, TravelAI, TravelAIConfig } from './TravelAI';

/** 独立 AI 组件：scenicId < 0 为行程规划，否则为该景点问答。
 * 接入时由宿主传入 config；宿主模块需声明 ohos.permission.INTERNET。
 * 由 TravelAIPage 提供页面入口和本地接口配置。
 */
@Component
export default struct TravelAIComponent {
  config: TravelAIConfig = new TravelAIConfig();
  @Prop showTitle: boolean = true;
  @Prop @Watch('resetConversation') scenicId: number = -1;
  @State private destination: string = '';
  @State private input: string = '';
  @State private messages: AIMessage[] = [];
  @State private loading: boolean = false;
  @State private error: string = '';
  private client: TravelAI = new TravelAI();
  private revision: number = 0;
  private scroller: Scroller = new Scroller();

  aboutToDisappear(): void {
    this.resetConversation();
  }

  private resetConversation(): void {
    this.revision++;
    this.client.reset();
    this.messages = [];
    this.input = '';
    this.error = '';
    this.loading = false;
  }

  private async submit(): Promise<void> {
    if (this.loading) {
      return;
    }
    const question = this.input.trim();
    if (!question || (this.scenicId < 0 && !this.destination.trim())) {
      this.error = this.scenicId < 0 ? '请填写目的地和游玩偏好' : '请输入景点问题';
      return;
    }
    const token = ++this.revision;
    this.loading = true;
    this.error = '';
    try {
      const answer = this.scenicId < 0 ?
        await this.client.plan(this.config, this.destination, question) :
        await this.client.ask(this.config, this.scenicId, question);
      if (token !== this.revision) {
        return;
      }
      const user: AIMessage = {
        role: 'user',
        content: this.scenicId < 0 ? `目的地：${this.destination.trim()}\n偏好：${question}` : question
      };
      const assistant: AIMessage = { role: 'assistant', content: answer };
      this.messages = this.scenicId < 0 ? [user, assistant] : [...this.messages, user, assistant];
      this.input = '';
    } catch (err) {
      if (token === this.revision) {
        const failure = err as Error;
        this.error = failure.message || '网络请求失败，请检查网络后重试';
      }
    } finally {
      if (token === this.revision) {
        this.loading = false;
      }
    }
  }

  @Builder
  ConversationContent() {
    Column({ space: 12 }) {
      Row() {
        Text(this.scenicId < 0 ? '按你的喜好，安排长安之旅' : '了解景点，也可以继续追问')
          .fontSize(14).fontColor($r('app.color.indicator_color')).layoutWeight(1)
        Button('清空', { type: ButtonType.Normal })
          .fontSize(14).fontWeight(FontWeight.Medium).height(32)
          .padding({ left: 12, right: 12 }).borderRadius(16)
          .fontColor($r('app.color.bottom_tabs_font_color_selected'))
          .backgroundColor($r('app.color.start_window_background'))
          .onClick(() => this.resetConversation())
      }.width('100%')
      if (this.scenicId < 0) {
        TextInput({ text: this.destination, placeholder: '目的地，例如：西安城墙、华清宫' })
          .height(48).fontSize(16).borderRadius(16)
          .fontColor($r('app.color.font_color_black'))
          .placeholderColor($r('app.color.indicator_color'))
          .backgroundColor($r('app.color.start_window_background'))
          .maxLength(200).enabled(!this.loading)
          .onChange((value: string) => this.destination = value)
      }
      List({ space: 12, scroller: this.scroller }) {
        ForEach(this.messages, (message: AIMessage) => {
          ListItem() {
            Column({ space: 6 }) {
              Text(message.role === 'user' ? '我' : 'AI 助手').fontSize(14).fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.bottom_tabs_font_color_selected'))
              Text(message.content).fontSize(16).fontColor($r('app.color.font_color_black'))
                .copyOption(CopyOptions.LocalDevice)
            }
            .alignItems(HorizontalAlign.Start).padding(16).width('100%')
            .backgroundColor($r('app.color.start_window_background')).borderRadius(16)
          }
        })
      }.layoutWeight(1).width('100%')
      .onAreaChange(() => this.scroller.scrollEdge(Edge.Bottom))
      if (this.loading) {
        Text('正在生成回答…').fontSize(14).fontColor($r('app.color.indicator_color'))
      }
      if (this.error) {
        Text(this.error).fontSize(14).fontColor($r('app.color.non_operational'))
      }
      TextArea({ text: this.input, placeholder: this.scenicId < 0 ?
        '游玩偏好，例如：一天、喜欢历史建筑、步行少一些' : '询问当前景点，也可以继续追问' })
        .height(100).maxLength(3000).enabled(!this.loading)
        .fontSize(16).borderRadius(16).padding(16)
        .fontColor($r('app.color.font_color_black'))
        .placeholderColor($r('app.color.indicator_color'))
        .backgroundColor($r('app.color.start_window_background'))
        .onChange((value: string) => this.input = value)
      Button(this.scenicId < 0 ? '生成行程' : '发送')
        .width('100%').height(44).fontSize(16).fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.font_color_white'))
        .backgroundColor($r('app.color.bottom_tabs_font_color_selected'))
        .borderRadius(22).enabled(!this.loading)
        .onClick(() => this.submit())
      Text('AI 建议仅供参考，开放及预约信息以景区官方公告为准。')
        .fontSize(12).fontColor($r('app.color.indicator_color'))
    }.width('100%').height('100%').padding({ left: 16, right: 16, bottom: 12 })
  }

  build() {
    if (this.showTitle) {
      Navigation() {
        this.ConversationContent()
      }
      .width('100%').height('100%')
      .title(this.scenicId < 0 ? 'AI 游览规划' : '景点智能问答')
      .titleMode(NavigationTitleMode.Mini)
      .hideBackButton(true).hideToolBar(true)
      .backgroundColor($r('app.color.common_background_color'))
    } else {
      this.ConversationContent()
    }
  }
}
