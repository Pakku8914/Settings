# ============================================================
# zsh-history-substring-search のキーバインド
# 入力途中の文字列にマッチする履歴だけを ↑↓ でたどる。
# vicmd（ノーマルモード）では k / j でも辿れる ※multiline の k/j 移動は上書き
# ============================================================
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
