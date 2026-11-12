-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.g.lazyvim_python_lsp = "basedpyright"

-- VS Code の renderWhitespace と同じく、空白文字を記号で表示する
vim.opt.listchars = "tab:▸ ,lead:·,trail:·,extends:>,precedes:<,nbsp:+"
