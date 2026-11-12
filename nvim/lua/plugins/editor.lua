-- ターミナルしか表示されていないと snacks は編集先(main)にターミナルの窓を選び、そこでファイルを開いてしまう。
-- その場合だけ、先にターミナルの上へ空の窓を作って編集先にする
local function ensure_editor_win(picker)
  local main = picker.main
  if not main or vim.bo[vim.api.nvim_win_get_buf(main)].buftype ~= "terminal" then
    return
  end
  picker.main = vim.api.nvim_win_call(main, function()
    vim.cmd("aboveleft new")
    return vim.api.nvim_get_current_win()
  end)
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      {
        "<leader>gv",
        function()
          vim.cmd(require("diffview.lib").get_current_view() and "DiffviewClose" or "DiffviewOpen")
        end,
        desc = "Diffview Toggle",
      },
      { "<leader>gV", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            -- explorer の setup は actions.confirm を自前の関数で上書きするので、opts.actions ではなく setup の結果を包む
            config = function(opts)
              opts = require("snacks.picker.source.explorer").setup(opts)
              local confirm = opts.actions.confirm
              opts.actions.confirm = function(picker, item, action)
                if item and not item.dir and not picker.input.filter.meta.searching then
                  ensure_editor_win(picker)
                end
                return confirm(picker, item, action)
              end
              return opts
            end,
          },
        },
      },
    },
  },
}
