# AIStudy

AIStudy 是一个基于 SwiftUI 开发的 iOS 应用，集成了 DeepSeek AI 聊天功能，提供了流畅的用户界面和丰富的交互体验。

## 功能特性

- 💬 智能对话：支持与 DeepSeek AI 进行自然语言对话
- 🔄 流式响应：实时显示 AI 的回复内容
- 📝 Markdown 支持：支持在消息中使用 Markdown 格式
  - 粗体：`**文本**` 或 `__文本__`
  - 斜体：`*文本*` 或 `_文本_`
  - 链接：`[链接文本](URL)`
  - 代码：`` `代码` ``
  - 代码块：``` ```代码块``` ```
  - 列表：`- ` 或 `1. ` 等
  - 标题：`# 标题`
- 💾 对话历史：保存完整的对话上下文
- 🎨 现代化 UI：使用 SwiftUI 构建的优雅界面
- 📱 响应式设计：适配不同尺寸的 iOS 设备

## 技术栈

- SwiftUI：用于构建用户界面
- Swift：主要开发语言
- Alamofire：网络请求处理
- DeepSeek API：AI 对话服务

## 安装要求

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## 配置说明

1. 克隆项目到本地
2. 配置 API Key：
   - 复制 `Resources/DefaultConfig.plist` 为 `DefaultConfig_Mark.plist`
   - 在 `DefaultConfig_Mark.plist` 中设置你的 API Key：
   ```xml
   <key>deepseek_api_key</key>
   <string>你的API Key</string>
   ```

## 使用方法

1. 启动应用
2. 在输入框中输入消息
3. 点击发送按钮或按回车键发送消息
4. 等待 AI 回复
5. 继续对话

## 项目结构

```
AIStudy/
├── Modules/
│   └── Chat/
│       ├── ChatView.swift      # 聊天界面
│       └── DeepSeekAPI.swift   # API 接口封装
├── Resources/
│   ├── DefaultConfig.plist     # 配置文件（已加入git）
│   └── DefaultConfig_Mark.plist # 配置文件模板（已加入git忽略）
└── README.md
```

## 注意事项

- 请确保有稳定的网络连接
- 需要有效的 DeepSeek API Key
- 建议在真机上测试以获得最佳体验
- `DefaultConfig_Mark.plist` 已加入 git 忽略，请勿提交包含 API Key 的配置文件

## 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进项目。

## 许可证

MIT License 