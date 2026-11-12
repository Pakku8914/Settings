# ============================================================
# ターミナルのタイトルを OSC エスケープシーケンスで設定する。
# アイドル時: "<ディレクトリ名> — zsh"、コマンド実行中: "<ディレクトリ名> — <コマンド名>"
# iTerm2/Warp/nvim(:terminal) など OSC 0/1/2 を解釈するアプリでタブ名に反映される。
# ============================================================
autoload -Uz add-zsh-hook

_term_title_set() {
  local dir="${PWD##*/}"
  [[ "$PWD" == "$HOME" ]] && dir="~"
  print -n "\e]0;${dir} — $1\a"
}

_term_title_precmd() {
  _term_title_set "zsh"
}

_term_title_preexec() {
  _term_title_set "${1%% *}"
}

add-zsh-hook precmd _term_title_precmd
add-zsh-hook preexec _term_title_preexec
