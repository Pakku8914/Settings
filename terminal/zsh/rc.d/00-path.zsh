# ============================================================
# PATH — 以降のモジュールが使うコマンド（gh, fzf, zoxide など）を使えるようにする
# ============================================================

# 非ログインシェル（nvim の :terminal など）は親の PATH を引き継いだうえでここを再実行するので、重複を自動で除く
typeset -U path

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# rbenv / pyenv。init はシェル関数も定義するので、PATH を引き継ぐだけでは足りず、対話シェルごとに実行する
eval "$(rbenv init - --no-rehash zsh)"
export PYENV_ROOT="$HOME/.pyenv"
path=("$PYENV_ROOT/bin" $path)
eval "$(pyenv init -)"

# ユーザーローカル bin / Antigravity
path=("$HOME/.local/bin" "$HOME/.antigravity/antigravity/bin" $path)
