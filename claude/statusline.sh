#!/bin/bash
# Claude Code statusline (2 lines)
# 1: model │ effort │ CTX ▓..% │ 5h ▓..% ↻HH:MM │ 7d ▓..%
# 2: ~/dir │  branch
input=$(cat)
j() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

# ===== 見た目の設定（ここを変えれば調整可能） =====
ASCII=0          # 1: bar/区切り/branch記号/resetをASCIIに（曖昧幅・フォント非対応端末向け）
WIDTH=10         # バー分割数
if [ "$ASCII" = 1 ]; then FILL='#'; EMPTY='-'; SEPG='|'; BRG='git:'; RSG='R'
else FILL='▓'; EMPTY='░'; SEPG='│'; BRG=' '; RSG='↻'; fi
C_LOW=$'\033[32m'; C_MID=$'\033[33m'; C_HI=$'\033[31m'
DIM=$'\033[2m'; BOLD=$'\033[1m'; CYAN=$'\033[36m'; MAGENTA=$'\033[95m'; RST=$'\033[0m'
SEP="${DIM} ${SEPG} ${RST}"

# ===== データ抽出 =====
DISP=$(j '.model.display_name // "?"')
MID=$(j '.model.id // empty')
EFFORT=$(j '.effort.level // empty')
CTX=$(j '.context_window.used_percentage // empty')
FIVE=$(j '.rate_limits.five_hour.used_percentage // empty')
FRESET=$(j '.rate_limits.five_hour.resets_at // empty')
SEVEN=$(j '.rate_limits.seven_day.used_percentage // empty')
DIR=$(j '.workspace.current_dir // empty')

# model + version（display_name に数字が無ければ id から抽出）
if printf '%s' "$DISP" | grep -q '[0-9]'; then MODEL="$DISP"
else VER=$(printf '%s' "$MID" | grep -oE '[0-9]+-[0-9]+' | head -1 | tr '-' '.')
     MODEL="$DISP${VER:+ $VER}"; fi

# dir（先頭 $HOME を ~ に）
case "$DIR" in
  "$HOME") DISPDIR="~" ;;
  "$HOME"/*) DISPDIR="~${DIR#$HOME}" ;;
  *) DISPDIR="$DIR" ;;
esac

# branch（worktreeのブランチもcwd基準で取得。detached時は短縮SHA）
BRANCH=""
if [ -n "$DIR" ] && git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
  [ -z "$BRANCH" ] && BRANCH=$(git -C "$DIR" rev-parse --short HEAD 2>/dev/null)
fi

# ===== ヘルパ =====
to_int() { printf '%.0f' "${1:-0}" 2>/dev/null || echo 0; }
bar() { local p; p=$(to_int "$1"); (( p<0 ))&&p=0; (( p>100 ))&&p=100
  local f=$(( (p*WIDTH+50)/100 )) e i b=''; e=$(( WIDTH-f ))
  for ((i=0;i<f;i++)); do b+="$FILL"; done
  for ((i=0;i<e;i++)); do b+="$EMPTY"; done; printf '%s' "$b"; }
color() { local p; p=$(to_int "$1"); local c="$C_LOW"
  (( p>=50 ))&&c="$C_MID"; (( p>=80 ))&&c="$C_HI"; printf '%s%s%s' "$c" "$2" "$RST"; }
join() { local out="" x; for x in "$@"; do [ -n "$out" ] && out+="$SEP"; out+="$x"; done; printf '%s' "$out"; }

# ===== 1行目: メトリクス =====
m=("${MAGENTA}model: ${MODEL}${RST}")
[ -n "$EFFORT" ] && m+=("${CYAN}effort: ${EFFORT}${RST}")
if [ -n "$CTX" ]; then ci=$(to_int "$CTX"); m+=("CTX $(color "$ci" "$(bar "$ci") ${ci}%")"); fi
if [ -n "$FIVE" ]; then f=$(to_int "$FIVE"); seg="5h $(color "$f" "$(bar "$f") ${f}%")"
  if [ -n "$FRESET" ]; then rt=$(date -r "$FRESET" '+%H:%M' 2>/dev/null)
    [ -n "$rt" ] && seg+=" ${DIM}${RSG}${rt}${RST}"; fi
  m+=("$seg"); fi
if [ -n "$SEVEN" ]; then s=$(to_int "$SEVEN"); m+=("7d $(color "$s" "$(bar "$s") ${s}%")"); fi

# ===== 2行目: dir | branch =====
d=()
[ -n "$DISPDIR" ] && d+=("$DISPDIR")
[ -n "$BRANCH" ] && d+=("${DIM}${BRG}${RST}${BRANCH}")

printf '%s\n' "$(join "${m[@]}")"
[ ${#d[@]} -gt 0 ] && printf '%s\n' "$(join "${d[@]}")"
