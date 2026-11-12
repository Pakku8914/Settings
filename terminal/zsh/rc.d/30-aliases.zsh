# ============================================================
# エイリアス
# oh-my-zsh も ls / ll / la を定義する（ls -G / ls -lh / ls -lAh）ので、それより後のここで上書きする
# grep は rg に置き換えない。-r などオプションの意味が違い、黙って違う結果を返すため（rg は直接打つ）
# ============================================================
alias ls='eza --icons'
alias ll='eza -l --icons --git --no-user'
alias la='eza -la --icons --git --no-user'
alias tree='eza --tree --icons'
alias cat='bat'
alias vim='nvim'
alias python='python3'
