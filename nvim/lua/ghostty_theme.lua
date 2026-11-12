-- lua/themes/*.lua（Ghostty から移植したパレット）を colorscheme として適用する。
-- mini.base16 に base_16 を渡したうえで、NvChad の base46 と色が食い違うグループだけを base46 と同じ定義で上書きする
-- （base46 の integrations の defaults / syntax / treesitter / lsp から写した。NvChad から移行しても見た目を変えないため）
local M = {}

local function overrides(p, c)
  return {
    Comment = { fg = c.light_grey },
    LineNr = { fg = c.grey },
    CursorLineNr = { fg = c.white },
    CursorLine = { bg = c.black2 },
    Folded = { fg = c.light_grey, bg = c.black2 },
    Pmenu = { bg = c.one_bg },
    PmenuSel = { fg = c.black, bg = c.pmenu_bg },
    PmenuSbar = { bg = c.one_bg },
    PmenuThumb = { bg = c.grey },
    NormalFloat = { bg = c.darker_black },
    FloatBorder = { fg = c.blue },
    WinSeparator = { fg = c.line },
    VertSplit = { fg = c.line },
    -- mini.base16 は base02（Ghostty の選択色）をこれらの背景にも使う。テーマによっては選択色が原色なので base46 の色に戻す
    StatusLine = { bg = c.statusline_bg },
    WinBar = { bg = "NONE" },
    WinBarNC = { bg = "NONE" },
    MatchParen = { fg = c.white, bg = c.grey },
    LspReferenceText = { bg = c.one_bg3 },
    LspReferenceRead = { bg = c.one_bg3 },
    LspReferenceWrite = { bg = c.one_bg3 },
    -- term_tabs.lua の winbar が使う
    TabLine = { bg = c.darker_black },
    TabLineFill = { bg = c.darker_black },
    TabLineSel = { bold = true },

    ["@annotation"] = { fg = p.base0F },
    ["@attribute"] = { fg = p.base0A },
    ["@comment"] = { fg = c.grey_fg },
    ["@comment.danger"] = { fg = c.black2, bg = c.red },
    ["@comment.note"] = { fg = c.black, bg = c.blue },
    ["@comment.todo"] = { fg = c.grey, bg = c.white },
    ["@comment.warning"] = { fg = c.black2, bg = p.base09 },
    ["@constant.builtin"] = { fg = p.base09 },
    ["@constant.macro"] = { fg = p.base08 },
    ["@diff.delta"] = { fg = c.light_grey },
    ["@error"] = { fg = p.base08 },
    ["@function.builtin"] = { fg = p.base0D },
    ["@function.macro"] = { fg = p.base08 },
    ["@keyword.directive"] = { fg = p.base0A },
    ["@keyword.directive.define"] = { fg = p.base0E },
    ["@keyword.exception"] = { fg = p.base08 },
    ["@keyword.import"] = { fg = p.base0D },
    ["@keyword.repeat"] = { fg = p.base0A },
    ["@keyword.return"] = { fg = p.base0E },
    ["@keyword.storage"] = { fg = p.base0A },
    ["@lsp.type.comment"] = { link = "@comment" },
    ["@lsp.type.decorator"] = { fg = p.base0A },
    ["@lsp.type.macro"] = { fg = p.base08 },
    ["@lsp.type.namespace"] = { fg = p.base08 },
    ["@lsp.type.parameter"] = { fg = p.base08 },
    ["@markup.link"] = { fg = p.base08 },
    ["@markup.link.label"] = { fg = p.base0C },
    ["@markup.link.url"] = { fg = p.base09, underline = true },
    ["@markup.list"] = { fg = p.base08 },
    ["@markup.quote"] = { bg = c.black2 },
    ["@markup.raw"] = { fg = p.base09 },
    ["@module"] = { fg = p.base08 },
    ["@string.escape"] = { fg = p.base0C },
    ["@tag.attribute"] = { fg = p.base08 },
    ["@tag.delimiter"] = { fg = p.base0F },
    ["@type.builtin"] = { fg = p.base0A },
    ["@variable.builtin"] = { fg = p.base09 },
    ["@variable.member"] = { fg = p.base08 },
    ["@variable.member.key"] = { fg = p.base08 },
    ["@variable.parameter"] = { fg = p.base08 },
  }
end

function M.apply(name)
  local t = require("themes." .. name)
  local p, c = t.base_16, t.base_30
  require("mini.base16").setup({ palette = p })
  vim.g.colors_name = (name:lower():gsub(" ", "-"))

  -- mini.base16 は行番号・サイン・折りたたみの列に base01 の背景を付ける。base46 と同じく本文と同じ背景にする
  local gutter_bg = tonumber(p.base01:sub(2), 16)
  for group, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    local is_gutter = group:find("Sign") or group:find("^LineNr") or (group:find("Fold") and group ~= "Folded")
    if is_gutter and hl.bg == gutter_bg then
      hl.bg = nil
      vim.api.nvim_set_hl(0, group, hl)
    end
  end

  for group, spec in pairs(overrides(p, c)) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

return M
