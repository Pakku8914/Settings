# ============================================================
# fzf — fuzzy finder (https://github.com/junegunn/fzf)
# ============================================================
# キーバインド (Ctrl-R 履歴 / Ctrl-T ファイル挿入 / Alt-C cd) と
# 補完 (例: vim **<TAB>) をまとめて読み込む。fzf 0.48+ の新方式。
source <(fzf --zsh)

# Alt-C(cd) を Ctrl-F に再割当て。標準の forward-char は上書きされる（右移動は → キーで代替）。
bindkey '^F' fzf-cd-widget

# 候補列挙に fd を使用（.gitignore を尊重・隠しファイルも対象・.git は除外）
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# 全 fzf 共通の見た目・操作
export FZF_DEFAULT_OPTS="
  --height 60%
  --layout reverse
  --border rounded
  --info inline
  --prompt '❯ '
  --pointer '▶'
  --marker '✓'
  --color border:#444444,prompt:#87afff,pointer:#ff5faf,marker:#5fff87
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up'
"

# Ctrl-T: ファイルは bat、ディレクトリは eza --tree でプレビュー
export FZF_CTRL_T_OPTS="
  --preview '[ -d {} ] && eza --tree --level=2 --color=always {} || bat --style=numbers --color=always --line-range :200 {}'
  --preview-window right:60%:wrap
"

# Alt-C: 移動先ディレクトリを eza --tree でプレビュー
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --level=2 --color=always {}'
  --preview-window right:50%
"

# Ctrl-R: コマンド履歴。Ctrl-/ で全文プレビュー、Ctrl-Y でクリップボードにコピー
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window down:3:hidden:wrap
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --header 'Ctrl-/: preview  •  Ctrl-Y: copy'
"
