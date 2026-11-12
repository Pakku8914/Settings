-- ターミナルのタブ機能。Snacks.terminal が返すウィンドウ(snacks.win)を1タブに1つ持ち、
-- その配列を「タブ」として管理する薄いレイヤーとして実装している。

local M = {}

local tabs = {} -- 順序付き配列: { {id=string, term=snacks.win|nil, buf=number|nil}, ... }。配列の位置 = タブ番号
local active = nil -- tabs のインデックス。タブが1つも無ければ nil
local next_id = 1 -- 一意なターミナルID生成用の単調増加カウンタ(再利用しない)
local buf_to_tab = {} -- [bufnr] = id (自前の逆引き。理由は下記 TermClose オートコマンドのコメント参照)
-- Snacks.terminal は count で端末を区別する。LazyVim の <C-/>（count 1〜）と重ならない番号を使う
local COUNT_BASE = 1000

-- シェルが OSC 0/1/2 でタイトルを設定すると nvim が b:term_title に反映する
-- (75-term-title.zsh 参照)。未設定ならタブID をそのまま出す。
local function tab_label(tab)
  if tab.buf and vim.api.nvim_buf_is_valid(tab.buf) then
    local title = vim.b[tab.buf].term_title
    if title and title ~= "" then
      return title
    end
  end
  return tab.id
end

local function build_winbar()
  if #tabs == 0 then
    return "%#TabLineFill#"
  end

  local segs = {}
  for i, tab in ipairs(tabs) do
    local hl = (i == active) and "TabLineSel" or "TabLine"
    segs[#segs + 1] = ("%%#%s# %d:%s "):format(hl, i, tab_label(tab))
  end
  segs[#segs + 1] = "%#TabLineFill#"
  return table.concat(segs)
end

local function apply_winbar(win)
  if win and win ~= -1 then
    vim.wo[win].winbar = build_winbar()
  end
end

local function show_tab(tab)
  if tab.term and tab.term:buf_valid() then
    tab.term:show()
  else
    tab.term = Snacks.terminal.open(nil, {
      count = COUNT_BASE + tonumber(tab.id:match("%d+$")),
      -- 終了時の後片付けは下の TermClose で行う。Snacks に任せると close_tab の jobstop を異常終了としてエラー通知する
      auto_close = false,
      win = { position = "bottom", height = 0.3 },
    })
    tab.buf = tab.term.buf
    buf_to_tab[tab.buf] = tab.id
  end
  apply_winbar(tab.term.win)
end

local function hide_active_if_visible()
  if not active then
    return
  end
  local tab = tabs[active]
  if tab.term and tab.term:win_valid() then
    tab.term:hide()
  end
end

local function find_tab_by_id(id)
  for i, tab in ipairs(tabs) do
    if tab.id == id then
      return i
    end
  end
end

local function forget_tab(idx)
  local tab = tabs[idx]
  local was_active = idx == active
  table.remove(tabs, idx)

  if #tabs == 0 then
    active = nil
  elseif was_active then
    active = math.min(idx, #tabs)
  elseif active and idx < active then
    active = active - 1
  end

  buf_to_tab[tab.buf] = nil
  return tab, was_active
end

local function finish_close(tab, was_active, kill_job)
  if tab.buf and vim.api.nvim_buf_is_valid(tab.buf) then
    if kill_job then
      local ok, job_id = pcall(function()
        return vim.b[tab.buf].terminal_job_id
      end)
      if ok and job_id then
        pcall(vim.fn.jobstop, job_id)
      end
    end

    local win = vim.fn.bufwinid(tab.buf)
    if win ~= -1 then
      pcall(vim.api.nvim_win_close, win, true)
    end
    pcall(vim.api.nvim_buf_delete, tab.buf, { force = true })
  end

  if was_active then
    if active then
      show_tab(tabs[active])
    end
  elseif active then
    local cur = tabs[active]
    apply_winbar(cur.buf and vim.fn.bufwinid(cur.buf) or -1)
  end
end

--------------------------- user api -------------------------------

function M.new_tab()
  hide_active_if_visible()
  local tab = { id = "term_tab_" .. next_id, buf = nil }
  next_id = next_id + 1
  table.insert(tabs, tab)
  active = #tabs
  show_tab(tab)
end

local function cycle_tab(offset)
  if #tabs == 0 then
    M.new_tab() -- タブが無い状態での切り替えはタブ1の作成として扱う
    return
  end

  if #tabs == 1 then
    return -- 1つしか無いので切り替え不要
  end

  hide_active_if_visible()
  active = ((active - 1 + offset) % #tabs) + 1
  show_tab(tabs[active])
end

function M.next_tab()
  cycle_tab(1)
end

function M.prev_tab()
  cycle_tab(-1)
end

function M.close_tab()
  if not active then
    vim.notify("[term_tabs] no active tab", vim.log.levels.WARN)
    return
  end

  local tab, was_active = forget_tab(active)
  finish_close(tab, was_active, true)
end

function M.toggle_active()
  if not active then
    M.new_tab()
    return
  end

  local tab = tabs[active]
  if tab.term and tab.term:win_valid() then
    tab.term:hide()
  else
    show_tab(tab)
  end
end

function M.focus_active()
  if vim.bo.buftype == "terminal" then
    vim.cmd("wincmd p") -- ターミナルは表示したままエディタへ戻る
    return
  end

  if not active then
    M.new_tab()
    return
  end

  local tab = tabs[active]
  if tab.buf and vim.api.nvim_buf_is_valid(tab.buf) and vim.fn.bufwinid(tab.buf) ~= -1 then
    vim.api.nvim_set_current_win(vim.fn.bufwinid(tab.buf))
    vim.cmd("startinsert")
  else
    show_tab(tab)
  end
end

--------------------------- autocmds -------------------------------

-- close_tab で先にバッファを消した後にも TermClose が届くことがあるため、
-- 作成時に埋めた自前の buf_to_tab で、まだ管理中のタブかどうかを判定する。
vim.api.nvim_create_autocmd("TermClose", {
  callback = function(args)
    local id = buf_to_tab[args.buf]
    if not id then
      return
    end

    local idx = find_tab_by_id(id)
    if not idx then
      buf_to_tab[args.buf] = nil
      return
    end

    local tab, was_active = forget_tab(idx)
    vim.schedule(function()
      finish_close(tab, was_active, false)
    end)
  end,
})

--------------------------- title refresh -------------------------------

-- b:term_title の更新に対応するイベントが無いため、表示中のタブがあれば
-- winbar を定期的に描き直してタイトル変化(cd・コマンド実行)を反映する。
local refresh_timer = vim.uv.new_timer()
refresh_timer:start(
  500,
  500,
  vim.schedule_wrap(function()
    for _, tab in ipairs(tabs) do
      if tab.buf and vim.api.nvim_buf_is_valid(tab.buf) then
        local win = vim.fn.bufwinid(tab.buf)
        if win ~= -1 then
          apply_winbar(win)
        end
      end
    end
  end)
)

return M
