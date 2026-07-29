#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd -P)"
SOURCE="$ROOT/theme"
THEME_ID="preset-hyrule-wilds"
THEMES_ROOT="$HOME/Library/Application Support/CodexDreamSkinStudio/themes"
TARGET="$THEMES_ROOT/$THEME_ID"
ENGINE_ROOT="$HOME/.codex/codex-dream-skin-studio"
SWITCHER="$ENGINE_ROOT/scripts/switch-theme-macos.sh"
INSTALLED_VERSION_FILE="$ENGINE_ROOT/VERSION"
ENGINE_URL="https://github.com/Fei-Away/Codex-Dream-Skin/archive/refs/heads/main.tar.gz"
ENGINE_VERSION_URL="https://raw.githubusercontent.com/Fei-Away/Codex-Dream-Skin/main/macos/VERSION"
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

is_valid_version() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

version_is_newer() {
  local candidate="$1"
  local installed="$2"
  local candidate_major candidate_minor candidate_patch
  local installed_major installed_minor installed_patch

  [[ "$candidate" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || return 1
  candidate_major="${BASH_REMATCH[1]}"
  candidate_minor="${BASH_REMATCH[2]}"
  candidate_patch="${BASH_REMATCH[3]}"
  [[ "$installed" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || return 1
  installed_major="${BASH_REMATCH[1]}"
  installed_minor="${BASH_REMATCH[2]}"
  installed_patch="${BASH_REMATCH[3]}"

  [ "$candidate_major" -gt "$installed_major" ] && return 0
  [ "$candidate_major" -lt "$installed_major" ] && return 1
  [ "$candidate_minor" -gt "$installed_minor" ] && return 0
  [ "$candidate_minor" -lt "$installed_minor" ] && return 1
  [ "$candidate_patch" -gt "$installed_patch" ]
}

install_engine() {
  local installed_version="$1"
  local latest_version="$2"
  local prompt_message
  local archive_version
  local installed_after_update

  if [ -n "$installed_version" ]; then
    prompt_message="检测到 Codex Dream Skin 新版本：${installed_version} → ${latest_version}。升级前需要退出 Codex；未发送的输入可能丢失。"
  elif [ -x "$SWITCHER" ]; then
    prompt_message="检测到版本未知的 Codex Dream Skin。安装器将重新安装最新版 ${latest_version}；升级前需要退出 Codex，未发送的输入可能丢失。"
  else
    prompt_message="没有检测到 Codex Dream Skin。安装器将安装最新版 ${latest_version}；安装前需要退出 Codex，未发送的输入可能丢失。"
  fi

  if ! /usr/bin/osascript - "$prompt_message" <<'APPLESCRIPT' >/dev/null
on run argv
  display dialog (item 1 of argv) buttons {"取消", "退出 Codex 并更新"} default button "退出 Codex 并更新" with icon caution
end run
APPLESCRIPT
  then
    exit 0
  fi

  ENGINE_ARCHIVE="$DOWNLOAD_ROOT/codex-dream-skin.tar.gz"
  /usr/bin/curl --proto '=https' --tlsv1.2 --fail --location --silent --show-error \
    "$ENGINE_URL" --output "$ENGINE_ARCHIVE" \
    || fail "无法从 GitHub 下载 Codex Dream Skin。请检查网络后重试。"

  /usr/bin/tar -xzf "$ENGINE_ARCHIVE" -C "$DOWNLOAD_ROOT" \
    || fail "无法解压 Codex Dream Skin。"
  ENGINE_SOURCE="$DOWNLOAD_ROOT/Codex-Dream-Skin-main/macos"
  [ -x "$ENGINE_SOURCE/scripts/install-dream-skin-macos.sh" ] \
    || fail "下载包缺少 macOS 安装脚本。"
  [ -f "$ENGINE_SOURCE/VERSION" ] || fail "下载包缺少版本信息。"
  archive_version="$(/usr/bin/tr -d '[:space:]' < "$ENGINE_SOURCE/VERSION")"
  is_valid_version "$archive_version" || fail "下载包的版本信息无效。"
  version_is_newer "$archive_version" "$latest_version" || [ "$archive_version" = "$latest_version" ] \
    || fail "下载包版本早于刚刚检测到的最新版本，请稍后重试。"
  if [ -n "$installed_version" ] && ! version_is_newer "$archive_version" "$installed_version"; then
    fail "下载包不是比当前引擎更新的版本，已停止升级。"
  fi

  /usr/bin/osascript -e 'tell application id "com.openai.codex" to quit' >/dev/null 2>&1 || true
  /bin/sleep 2

  "$ENGINE_SOURCE/scripts/install-dream-skin-macos.sh" --no-launchers --no-launch \
    || fail "Codex Dream Skin 安装失败。请确认官方 Codex 已启动过一次并已完全退出。"
  [ -x "$SWITCHER" ] || fail "Codex Dream Skin 安装完成，但没有找到主题切换器。"
  [ -f "$INSTALLED_VERSION_FILE" ] || fail "Codex Dream Skin 安装完成，但没有找到版本信息。"
  installed_after_update="$(/usr/bin/tr -d '[:space:]' < "$INSTALLED_VERSION_FILE")"
  [ "$installed_after_update" = "$archive_version" ] \
    || fail "Codex Dream Skin 安装后的版本与下载版本不一致。"

  cleanup_download
  DOWNLOAD_ROOT=""
  trap - EXIT
}

DOWNLOAD_ROOT="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/codex-hyrule-theme.XXXXXX")" \
  || fail "无法创建临时下载目录。"
trap cleanup_download EXIT

LATEST_VERSION_FILE="$DOWNLOAD_ROOT/latest-version"
/usr/bin/curl --proto '=https' --tlsv1.2 --fail --location --silent --show-error \
  "$ENGINE_VERSION_URL" --output "$LATEST_VERSION_FILE" \
  || fail "无法检查 Codex Dream Skin 更新。为避免继续使用旧版引擎，已停止安装。"
LATEST_VERSION="$(/usr/bin/tr -d '[:space:]' < "$LATEST_VERSION_FILE")"
is_valid_version "$LATEST_VERSION" || fail "Codex Dream Skin 最新版本信息无效。"

INSTALLED_VERSION=""
if [ -x "$SWITCHER" ] && [ -f "$INSTALLED_VERSION_FILE" ]; then
  INSTALLED_VERSION="$(/usr/bin/tr -d '[:space:]' < "$INSTALLED_VERSION_FILE")"
  is_valid_version "$INSTALLED_VERSION" || INSTALLED_VERSION=""
fi

if [ ! -x "$SWITCHER" ] || [ -z "$INSTALLED_VERSION" ] \
  || version_is_newer "$LATEST_VERSION" "$INSTALLED_VERSION"; then
  install_engine "$INSTALLED_VERSION" "$LATEST_VERSION"
else
  cleanup_download
  DOWNLOAD_ROOT=""
  trap - EXIT
fi

[ -f "$SOURCE/theme.json" ] || fail "主题包缺少 theme/theme.json。"
[ -f "$SOURCE/theme.css" ] || fail "主题包缺少 theme/theme.css。"
[ -f "$SOURCE/background.jpg" ] || fail "主题包缺少 theme/background.jpg。"

/bin/mkdir -p "$TARGET"
/bin/chmod 700 "$THEMES_ROOT" "$TARGET" 2>/dev/null || true

IMAGE_TEMP="$TARGET/.background.$$.tmp.jpg"
THEME_TEMP="$TARGET/.theme.$$.tmp.json"
CSS_TEMP="$TARGET/.theme.$$.tmp.css"
cleanup() {
  /bin/rm -f "$IMAGE_TEMP" "$THEME_TEMP" "$CSS_TEMP"
}
trap cleanup EXIT

/bin/cp "$SOURCE/background.jpg" "$IMAGE_TEMP"
/bin/cp "$SOURCE/theme.json" "$THEME_TEMP"
/bin/cp "$SOURCE/theme.css" "$CSS_TEMP"
/bin/chmod 600 "$IMAGE_TEMP" "$THEME_TEMP" "$CSS_TEMP"

# 先发布图片和 Safe CSS，最后发布 theme.json，避免切换器观察到不完整主题。
/bin/mv -f "$IMAGE_TEMP" "$TARGET/background.jpg"
/bin/mv -f "$CSS_TEMP" "$TARGET/theme.css"
/bin/mv -f "$THEME_TEMP" "$TARGET/theme.json"
trap - EXIT

"$SWITCHER" --id "$THEME_ID"

printf '“海拉鲁旷野”主题已经安装并应用。\n'
