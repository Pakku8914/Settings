# ============================================================
# cd 後に現在地とファイル一覧を表示する（zsh の chpwd フック）
# ============================================================
chpwd() {
  print -r -- "-----------"
  print -rn -- "current_dir: "
  print -P -- '%~'
  print -r -- "-----------"
  print -r -- "file_lists:"
  eza -l . --no-filesize --no-time --icons --classify=always
  print -r -- "-----------"
}
