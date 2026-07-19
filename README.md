# Codex Skills Collection

这个仓库用于开源和维护 Codex Skill。每个 skill 放在 `skills/<skill-name>/` 下。

当前包含：

- `zelda-style-image-prompt`：生成塞尔达原版游戏实况截图风格的图片提示词
- `codex-hyrule-theme`：面向 macOS Codex Desktop 的“海拉鲁旷野”独立主题安装包

## 安装

先克隆仓库：

```bash
git clone https://github.com/xiaoTN/zelda-style-image-prompt.git
```

安装到全局 Codex skills：

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
cp -R zelda-style-image-prompt/skills/zelda-style-image-prompt \
  "${CODEX_HOME:-$HOME/.codex}/skills/zelda-style-image-prompt"
```

或安装到当前项目：

```bash
mkdir -p .codex/skills
cp -R zelda-style-image-prompt/skills/zelda-style-image-prompt \
  .codex/skills/zelda-style-image-prompt
```

安装后重启 Codex，让 skill 被重新扫描。

## 使用

在 Codex 里直接提出需求：

```text
使用 zelda-style-image-prompt，帮我写一个北京故宫的塞尔达风格图片提示词，不用出图。
```

skill 会输出可直接交给图片生成模型的最终提示词代码块。

## 声明

本仓库的 skill 部分只包含提示词写作规则和参考文档，不包含游戏原始模型、字体、音频或任天堂官方资源。`codex-hyrule-theme/theme/background.jpg` 是 AI 生成的同人主题背景，不属于任天堂官方素材，也不包含在仓库 MIT 软件许可的授权范围内；具体说明见该主题目录的 `NOTICE.md`。

本项目与 Nintendo、The Legend of Zelda、Breath of the Wild、Tears of the Kingdom 或其权利方没有关联、授权、赞助或背书关系。项目中出现的游戏名称、角色名称和商标仅用于描述提示词风格与兼容场景。

使用本仓库中的 skill 生成、发布或商用任何内容时，请自行确认是否符合相关平台规则、模型服务条款和知识产权要求。

## License

MIT
