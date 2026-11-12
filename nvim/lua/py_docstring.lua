-- def/class 直下で `"""` を入力したら neogen で docstring テンプレートを展開する
local M = {}

local group = vim.api.nvim_create_augroup("py_docstring", { clear = true })
local ns = vim.api.nvim_create_namespace("py_docstring")

-- TextChangedI は挿入と削除を区別できない。展開後の `[TODO:description]` を backspace で
-- 消し切った行は `"""` 入力直後とまったく同じ形になり、そのままでは再展開してしまう。
-- 直前の行を覚えておき、同じ行で文字が増えたときだけ入力とみなす
local prev = {}

local function record(buf)
  prev[buf] = { row = vim.api.nvim_win_get_cursor(0)[1], len = #vim.api.nvim_get_current_line() }
end

-- 閉じていない `"""` があると以降がすべて文字列として解析され構文木が壊れるため、
-- その行を pass に置き換えた状態で「def/class 本体の先頭文か」を判定する
local function docstring_target(buf, row, indent)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  lines[row + 1] = indent .. "pass"
  local root = vim.treesitter.get_string_parser(table.concat(lines, "\n"), "python"):parse()[1]:root()

  local stmt = root:named_descendant_for_range(row, #indent, row, #indent)
  if stmt:type() ~= "pass_statement" then
    return nil
  end
  local block = stmt:parent()
  if block:type() ~= "block" or not block:named_child(0):equal(stmt) then
    return nil
  end
  return ({ function_definition = "func", class_definition = "class" })[block:parent():type()]
end

local function on_text_changed(buf)
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local before = prev[buf]
  record(buf)

  -- 自動括弧が閉じ側を補うと `"""|"""`、補わないと `"""|` になる
  local indent = line:match('^(%s*)"""$') or line:match('^(%s*)""""""$')
  if not indent or col ~= #indent + 3 then
    return
  end
  if not before or before.row ~= row or before.len >= #line then
    return
  end

  local target = docstring_target(buf, row - 1, indent)
  if not target then
    return
  end

  -- undo を区切り、u 一回で `"""` 入力直後に戻れるようにする(テンプレート不要なときの逃げ道)
  vim.o.undolevels = vim.o.undolevels

  -- neogen はバッファ自体の構文木を読むので、バッファ側も pass に置き換えてから生成し、生成後に消す
  vim.api.nvim_set_current_line(indent .. "pass")
  local mark = vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, {})
  require("neogen").generate({ type = target })
  local pass_row = vim.api.nvim_buf_get_extmark_by_id(buf, ns, mark, {})[1]
  vim.api.nvim_buf_del_extmark(buf, ns, mark)
  vim.api.nvim_buf_set_lines(buf, pass_row, pass_row + 1, true, {})

  -- 展開後の placeholder 行を基準にし直す(消したときに挿入と誤判定しないため)
  record(buf)
end

function M.attach(buf)
  vim.api.nvim_clear_autocmds({ group = group, buffer = buf })
  prev[buf] = nil
  -- 挿入セッションごとに基準を取り直す(前回セッションの残骸と比較しないため)
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    buffer = buf,
    callback = function()
      record(buf)
    end,
  })
  vim.api.nvim_create_autocmd("TextChangedI", {
    group = group,
    buffer = buf,
    callback = function()
      on_text_changed(buf)
    end,
  })
end

return M
