#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd -P)"
SOURCE="$ROOT/theme"
THEME_ID="preset-hyrule-wilds"
THEMES_ROOT="$HOME/Library/Application Support/CodexDreamSkinStudio/themes"
TARGET="$THEMES_ROOT/$THEME_ID"
SWITCHER="$HOME/.codex/codex-dream-skin-studio/scripts/switch-theme-macos.sh"
ENGINE_URL="https://github.com/Fei-Away/Codex-Dream-Skin/archive/refs/heads/main.tar.gz"
DOWNLOAD_ROOT=""

fail() {
  printf '安装失败：%s\n' "$1" >&2
  /usr/bin/osascript - "$1" <<'APPLESCRIPT' >/dev/null 2>&1 || true
on run argv
  display alert "海拉鲁旷野主题安装失败" message (item 1 of argv) as warning
end run
APPLESCRIPT
  exit 1
}

cleanup_download() {
  if [ -n "$DOWNLOAD_ROOT" ] && [ -d "$DOWNLOAD_ROOT" ]; then
    /bin/rm -rf "$DOWNLOAD_ROOT"
  fi
}

install_engine() {
  if ! /usr/bin/osascript <<'APPLESCRIPT' >/dev/null
display dialog "没有检测到 Codex Dream Skin。安装引擎前需要退出 Codex；未发送的输入可能丢失。安装器将从公开 GitHub 仓库下载最新版本。" buttons {"取消", "退出 Codex 并安装"} default button "退出 Codex 并安装" with icon caution
APPLESCRIPT
  then
    exit 0
  fi

  /usr/bin/osascript -e 'tell application id "com.openai.codex" to quit' >/dev/null 2>&1 || true
  /bin/sleep 2

  DOWNLOAD_ROOT="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/codex-hyrule-theme.XXXXXX")" \
    || fail "无法创建临时下载目录。"
  trap cleanup_download EXIT

  ENGINE_ARCHIVE="$DOWNLOAD_ROOT/codex-dream-skin.tar.gz"
  /usr/bin/curl --proto '=https' --tlsv1.2 --fail --location --silent --show-error \
    "$ENGINE_URL" --output "$ENGINE_ARCHIVE" \
    || fail "无法从 GitHub 下载 Codex Dream Skin。请检查网络后重试。"

  /usr/bin/tar -xzf "$ENGINE_ARCHIVE" -C "$DOWNLOAD_ROOT" \
    || fail "无法解压 Codex Dream Skin。"
  ENGINE_SOURCE="$DOWNLOAD_ROOT/Codex-Dream-Skin-main/macos"
  [ -x "$ENGINE_SOURCE/scripts/install-dream-skin-macos.sh" ] \
    || fail "下载包缺少 macOS 安装脚本。"

  "$ENGINE_SOURCE/scripts/install-dream-skin-macos.sh" --no-launch \
    || fail "Codex Dream Skin 安装失败。请确认官方 Codex 已启动过一次并已完全退出。"
  [ -x "$SWITCHER" ] || fail "Codex Dream Skin 安装完成，但没有找到主题切换器。"

  cleanup_download
  DOWNLOAD_ROOT=""
  trap - EXIT
}

[ -x "$SWITCHER" ] || install_engine
[ -f "$SOURCE/theme.json" ] || fail "主题包缺少 theme/theme.json。"
[ -f "$SOURCE/background.jpg" ] || fail "主题包缺少 theme/background.jpg。"

/bin/mkdir -p "$TARGET"
/bin/chmod 700 "$THEMES_ROOT" "$TARGET" 2>/dev/null || true

IMAGE_TEMP="$TARGET/.background.$$.tmp.jpg"
THEME_TEMP="$TARGET/.theme.$$.tmp.json"
cleanup() {
  /bin/rm -f "$IMAGE_TEMP" "$THEME_TEMP"
}
trap cleanup EXIT

/bin/cp "$SOURCE/background.jpg" "$IMAGE_TEMP"
/bin/cp "$SOURCE/theme.json" "$THEME_TEMP"
/bin/chmod 600 "$IMAGE_TEMP" "$THEME_TEMP"

# 先发布图片，最后发布 theme.json，避免主题配置引用尚未复制完成的背景。
/bin/mv -f "$IMAGE_TEMP" "$TARGET/background.jpg"
/bin/mv -f "$THEME_TEMP" "$TARGET/theme.json"
trap - EXIT

"$SWITCHER" --id "$THEME_ID"

printf '“海拉鲁旷野”主题已经安装并应用。\n'
