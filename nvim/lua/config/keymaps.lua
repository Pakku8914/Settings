-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local map = vim.keymap.set

map("n", ";", ":", { desc = "Command mode" })
map("i", "jk", "<Esc>")

-- 以下は VS Code（vscode-neovim）ではウィンドウ・ターミナルを VS Code 側が持つので登録しない
if vim.g.vscode then
  return
end

-- LazyVim は Ctrl+矢印 でリサイズするが、macOS は Ctrl+矢印 を Mission Control に使っていて nvim まで届かないので Alt+矢印 にも割り当てる
map("n", "<A-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<A-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- ターミナルのタブ。<A-j> は LazyVim の行移動に譲り、フォーカスの往復は Cmd+J だけにする
local term_tabs = require("term_tabs")
local all_modes = { "n", "i", "v", "t" }
map(all_modes, "<D-j>", term_tabs.focus_active, { desc = "Terminal Focus/Unfocus" })
map(all_modes, "<A-J>", term_tabs.toggle_active, { desc = "Terminal Toggle" })
map(all_modes, "<D-J>", term_tabs.toggle_active, { desc = "Terminal Toggle" })
map(all_modes, "<A-t>", term_tabs.new_tab, { desc = "Terminal New Tab" })
map(all_modes, "<A-w>", term_tabs.close_tab, { desc = "Terminal Close Tab" })

-- カーソルがターミナルにあればターミナルのタブ、それ以外ならバッファを切り替える
map(all_modes, "<A-S-]>", function()
  if vim.bo.buftype == "terminal" then
    term_tabs.next_tab()
  else
    vim.cmd("BufferLineCycleNext")
  end
end, { desc = "Next Tab (Buffer or Terminal)" })
map(all_modes, "<A-S-[>", function()
  if vim.bo.buftype == "terminal" then
    term_tabs.prev_tab()
  else
    vim.cmd("BufferLineCyclePrev")
  end
end, { desc = "Prev Tab (Buffer or Terminal)" })
