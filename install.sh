#!/usr/bin/env bash
# 使い方: ./install.sh [all|brew|terminal|nvim|vscode|claude]...   (引数なし = all)
# 既存ファイルは ~/.dotfiles-backup/<日時>/ に退避してからシンボリックリンクを張る。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

backup() {
  local dst="$1" bak="$BACKUP${1#"$HOME"}"
  [[ -e "$dst" || -L "$dst" ]] || return 0
  mkdir -p "$(dirname "$bak")"
  mv "$dst" "$bak"
  echo "backup: $dst -> $bak"
}

link() {
  local src="$REPO/$1" dst="$2"
  [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]] && return 0
  backup "$dst"
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "link:   $dst -> $src"
}

clone() {
  [[ -d "$2" ]] || git clone --depth=1 "https://github.com/$1.git" "$2"
}

install_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  brew bundle --file="$REPO/Brewfile"
}

install_terminal() {
  link terminal/ghostty/config "$HOME/.config/ghostty/config"

  link terminal/zsh/zshenv   "$HOME/.zshenv"
  link terminal/zsh/zshrc    "$HOME/.zshrc"
  link terminal/zsh/p10k.zsh "$HOME/.p10k.zsh"
  link terminal/zsh/rc.d     "$HOME/.config/zsh/rc.d"

  # zprofile は使わない（README 参照）。残っていると PATH の設定などが二重に走るので退避する
  backup "$HOME/.zprofile"

  # local.d は PC 固有・秘密のモジュール置き場（リポジトリ外）。テンプレートのうち、まだ無いものだけ作る
  local f name local_d="$HOME/.config/zsh/local.d"
  mkdir -p "$local_d"
  for f in "$REPO"/terminal/zsh/local.d/*.example; do
    name="$(basename "$f" .example)"
    [[ -e "$local_d/$name" ]] && continue
    install -m 600 "$f" "$local_d/$name"
    echo "created: $local_d/$name (値を記入してください)"
  done

  # 公式インストーラは ~/.zshrc を上書きするので使わず clone する
  local omz="$HOME/.oh-my-zsh"
  clone ohmyzsh/ohmyzsh                        "$omz"
  clone romkatv/powerlevel10k                  "$omz/custom/themes/powerlevel10k"
  clone jeffreytse/zsh-vi-mode                 "$omz/custom/plugins/zsh-vi-mode"
  clone Aloxaf/fzf-tab                         "$omz/custom/plugins/fzf-tab"
  clone zsh-users/zsh-autosuggestions          "$omz/custom/plugins/zsh-autosuggestions"
  clone zsh-users/zsh-syntax-highlighting      "$omz/custom/plugins/zsh-syntax-highlighting"
  clone zsh-users/zsh-history-substring-search "$omz/custom/plugins/zsh-history-substring-search"
}

install_nvim() {
  link nvim "$HOME/.config/nvim"
  # 初回の起動では LazyVim の import 経由のプラグインの一部が lockfile ではなく最新版で入り、lockfile も書き換わる
  # （実際に mini.ai で起きた）。退避→インストール→復元→restore で固定版にそろえる
  local lock="$REPO/nvim/lazy-lock.json" saved
  saved="$(mktemp)"
  cp "$lock" "$saved"
  nvim --headless +qa
  cp "$saved" "$lock"
  rm -f "$saved"
  nvim --headless "+Lazy! restore" +qa
}

# $1: 追加で入れる拡張グループ（カンマ区切り。all で全グループ）。common は常に入る
install_vscode() {
  local dir="$REPO/vscode/extensions" files=("$REPO/vscode/extensions/common.txt") g
  if [[ "${1:-}" == all ]]; then
    files=("$dir"/*.txt)
  elif [[ -n "${1:-}" ]]; then
    for g in ${1//,/ }; do
      if [[ ! -f "$dir/$g.txt" ]]; then
        echo "unknown extension group: $g (候補: $(basename -a -s .txt "$dir"/*.txt | tr '\n' ' '))" >&2
        exit 1
      fi
      files+=("$dir/$g.txt")
    done
  fi

  local user="$HOME/Library/Application Support/Code/User"
  link vscode/settings.json    "$user/settings.json"
  link vscode/keybindings.json "$user/keybindings.json"

  local code="code"
  command -v code >/dev/null 2>&1 || code="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"

  # 1 行 1 ID。# で始まる行と、ID の後ろの空白以降（行末コメント）は読み飛ばす
  local ext args=()
  while read -r ext _; do
    [[ -z "$ext" || "$ext" == \#* ]] || args+=(--install-extension "$ext")
  done < <(cat "${files[@]}")
  "$code" "${args[@]}"

  # 自作テーマはマーケットプレイスに無いので、ソースから .vsix を組み立ててインストールする
  local tmp
  tmp="$(mktemp -d)"
  (cd "$REPO/vscode/nvim-tinacious-design-dark" && zip -qr "$tmp/theme.vsix" '[Content_Types].xml' extension.vsixmanifest extension)
  "$code" --install-extension "$tmp/theme.vsix"
  rm -rf "$tmp"
}

install_claude() {
  link claude/statusline.sh "$HOME/.claude/statusline.sh"
  # settings.json は権限やプラグインなどほかの設定も持ち、Claude Code 自身も書き換えるので、
  # 丸ごとリンクせず statusLine だけ書き込む。mv でなく cat > で戻すのは、元のパーミッションを保つため
  local settings="$HOME/.claude/settings.json" tmp
  [[ -f "$settings" ]] || echo '{}' >"$settings"
  tmp="$(mktemp)"
  jq '.statusLine = {type: "command", command: "bash ~/.claude/statusline.sh", padding: 0}' "$settings" >"$tmp"
  cat "$tmp" >"$settings"
  rm -f "$tmp"
  echo "set:    statusLine in $settings"
}

[[ $# -eq 0 ]] && set -- all
for target in "$@"; do
  case "$target" in
    all) install_brew; install_terminal; install_nvim; install_vscode; install_claude ;;
    brew | terminal | nvim | vscode | claude) "install_$target" ;;
    vscode:*) install_vscode "${target#vscode:}" ;;
    *) echo "usage: $0 [all|brew|terminal|nvim|vscode|vscode:<group,...>|vscode:all|claude]..." >&2; exit 1 ;;
  esac
done
