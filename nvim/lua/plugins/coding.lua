return {
  {
    "saghen/blink.cmp",
    opts = {
      -- 候補を自動で選ばない。Enter は改行のまま使い、Tab などで候補を選んだときだけ確定する
      completion = { list = { selection = { preselect = false } } },
      keymap = {
        -- スニペットの欄にいて、まだ候補を選び始めていなければ欄の移動を優先する
        -- （docstring を書いている途中で出る補完メニューに Tab を取られないため。欄の中で候補を選ぶときは <C-n> で選び始める）
        ["<Tab>"] = {
          function(cmp)
            if cmp.is_menu_visible() and (cmp.get_selected_item() or not cmp.snippet_active({ direction = 1 })) then
              return cmp.select_next()
            end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = {
          function(cmp)
            if cmp.is_menu_visible() and (cmp.get_selected_item() or not cmp.snippet_active({ direction = -1 })) then
              return cmp.select_prev()
            end
          end,
          "snippet_backward",
          "fallback",
        },
      },
    },
  },

  {
    "kylechui/nvim-surround",
    version = "^4.0.0",
    event = "VeryLazy",
    -- visual モードの S は LazyVim の flash（treesitter 選択）が使うので譲り、gS だけ残す
    init = function()
      vim.g.nvim_surround_no_visual_mappings = true
    end,
    keys = {
      { "gS", "<Plug>(nvim-surround-visual-line)", mode = "x", desc = "Surround selection on new lines" },
    },
  },
}
