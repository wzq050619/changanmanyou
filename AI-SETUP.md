# AI 功能配置

本项目新增了 AI 游览规划和景点问答：主页的 AI 标签用于生成行程，景点详情页的“问问 AI”按钮用于当前景点的问答和追问。

## 首次配置

1. 将 `entry/src/main/ets/ai/ApiConfig.example.ets` 复制为同目录下的 `ApiConfig.local.ets`。
2. 在本地文件的 `AI_API_KEY` 中填入自己的 API 密钥。
3. 在 `entry/src/main/ets/ai/TravelAI.ets` 的 `TravelAIConfig` 中检查 `endpoint` 和 `model`，调整为自己的服务地址和可用模型。请求采用兼容 OpenAI Chat Completions 的 JSON 格式。
4. 使用 DevEco Studio 打开项目并配置所需的 HarmonyOS SDK。设备需要联网；接口鉴权、模型权限和额度由所用服务决定。

`ApiConfig.local.ets` 已加入 `.gitignore`，仓库只提供空密钥示例。克隆后须先创建这个本地文件，否则页面导入该配置时无法编译。不要提交真实密钥、本机 SDK 配置、签名文件或包含密钥的编译产物。

AI 回答依据项目内的景点资料生成，不提供实时票价、预约状态、导航或路况。开放与预约信息需要自行核对景区官方公告。
