# ============================================================
# oh-my-zsh — テーマ・プラグイン・本体の読み込み（補完の compinit もここで済む）
# ============================================================

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# テーマ: Powerlevel10k（プロンプト設定の本体は 99-p10k.zsh / ~/.p10k.zsh）
ZSH_THEME="powerlevel10k/powerlevel10k"

# プラグインの並び順が重要:
#   - zsh-vi-mode を先頭側に（下の ZVM_INIT_MODE=sourcing で即初期化）
#   - fzf-tab は compinit 後・widget をラップするプラグインより前
#   - zsh-syntax-highlighting は zsh-history-substring-search より前
#   - zsh-history-substring-search は最後（構文ハイライトの後に読む規約）
plugins=(
  git
  zsh-vi-mode
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

# zsh-vi-mode を「ソース時に即初期化」する。既定の遅延初期化だと初回
# プロンプト表示時にキーマップがリセットされ、配列で後ろに並ぶプラグインや
# 末尾の fzf 用 bindkey が消えてしまう。sourcing なら以降の設定が生き残る。
ZVM_INIT_MODE=sourcing

source $ZSH/oh-my-zsh.sh
