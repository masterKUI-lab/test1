# 海拉鲁旷野 · Codex 主题

一套面向 macOS 官方 Codex Desktop 的非官方同人主题。主题包含林克与塞尔达的旷野背景，并统一调整 Codex 的侧栏、面板、卡片、输入框、文字、边框和强调色。

![海拉鲁旷野主题背景](./theme/background.jpg)

## 效果特点

- 青绿、天蓝、暖金色的旷野配色
- 左侧保留低信息安全区，避免遮挡 Codex 首页内容
- 首页突出完整背景，任务页自动降低图片干扰
- 原生侧栏、项目选择、任务内容和输入框保持可交互
- 不修改官方 `.app`、`app.asar` 或代码签名

## 使用要求

- macOS
- 已安装并至少启动过一次官方 Codex Desktop
- 每次运行安装器检查引擎更新时可以访问 GitHub

Codex 本身不会读取本目录中的主题文件。[Codex Dream Skin](https://github.com/Fei-Away/Codex-Dream-Skin) 是负责加载主题和注入样式的运行引擎。本主题按新版简化主题包提供 `theme.json`、受限的 `theme.css` 和背景图。本安装器每次运行都会检查仓库 `main` 分支的版本：没有安装时安装最新版；发现已安装版本较旧或版本信息异常时，询问用户后升级或重新安装；只有版本相同或更高时才直接使用。

## 一键安装

1. 从 GitHub 下载并解压本仓库。
2. 双击 `Install Hyrule Theme.command`。
3. 如果没有检测到 Dream Skin，或者检测到引擎需要更新，确认提示后允许安装器退出 Codex 并安装或升级引擎。
4. 安装器会把主题复制到用户主题库，并自动切换到“海拉鲁旷野”。

安装器始终以 Dream Skin 仓库 `main` 分支公布的版本为准，不固定提交或版本号。每次运行都会联网检查版本；发现新版时直接升级，不继续使用旧版。版本相同或本机版本更高时不会重复下载完整引擎；如果无法确认上游版本，安装器会停止，避免静默使用可能过期的引擎。

如果 macOS 没有将 `.command` 文件识别为可执行文件，可以在终端运行：

```bash
chmod +x "./Install Hyrule Theme.command"
./Install\ Hyrule\ Theme.command
```

安装器不会依赖仓库所在路径，也不会写死用户名。主题安装后的稳定位置是：

```text
~/Library/Application Support/CodexDreamSkinStudio/themes/preset-hyrule-wilds
```

安装完成后，可以移动或删除下载的仓库副本，不影响已经安装的主题。

## 从菜单切换

打开 macOS 菜单栏的 `🎨 Skin`：

```text
已保存的主题
└── 海拉鲁旷野
```

点击主题名即可重新应用。菜单没有及时更新时，点击“刷新”或等待约 10 秒。

## 只更换背景并保留主题配色

将新的 16:9 图片处理为 `2560 × 1440` JPEG，替换：

```text
theme/background.jpg
```

不要修改 `theme/theme.json` 中的 `image` 文件名。替换后重新运行安装器，侧栏、面板、输入框和强调色都会保持不变，只更新背景。

图片应为纯背景，不要包含 Codex 窗口、侧栏、按钮、输入框、文字、Logo 或水印。主题包内的背景图必须不超过 10 MiB。

## 目录结构

```text
codex-hyrule-theme/
├── Install Hyrule Theme.command
├── NOTICE.md
├── README.md
└── theme/
    ├── background.jpg
    ├── theme.css
    └── theme.json
```

## 声明

这是非官方同人项目，与 Nintendo、The Legend of Zelda、Breath of the Wild、Tears of the Kingdom 或相关权利方没有关联、授权、赞助或背书关系。

安装脚本和主题配置可以按仓库的软件许可证使用；`theme/background.jpg` 不包含在 MIT 软件许可中。角色、名称、商标及相关知识产权归各自权利人。详细说明见 [NOTICE.md](./NOTICE.md)。
