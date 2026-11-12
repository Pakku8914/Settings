-- Ported from Ghostty's "Xcode Dark" theme (mbadolato/iTerm2-Color-Schemes)
-- Colors are derived mechanically from the terminal ANSI-16 palette so this
-- matches the Ghostty theme of the same name in ~/.config/ghostty/config.

local M = {}

M.base_30 = {
  white = "#dfdfe0",
  darker_black = "#202025",
  black = "#292a30",
  black2 = "#303138",
  one_bg = "#35363e",
  one_bg2 = "#3c3d46",
  one_bg3 = "#40424c",
  grey = "#4a4c57",
  grey_fg = "#51535f",
  grey_fg2 = "#585a67",
  light_grey = "#5d5f6d",
  red = "#ff8170",
  baby_pink = "#ffa094",
  pink = "#ff7e8e",
  line = "#35363e",
  green = "#78c2b3",
  vibrant_green = "#acf2e4",
  nord_blue = "#4eb0cc",
  blue = "#6bdfff",
  yellow = "#d9c97c",
  sun = "#ffa14f",
  purple = "#ff7ab2",
  dark_purple = "#bf5c86",
  teal = "#dabaff",
  orange = "#eaa977",
  cyan = "#b281eb",
  statusline_bg = "#2e2f36",
  lightbg = "#3c3d46",
  pmenu_bg = "#6bdfff",
  folder_bg = "#6bdfff",
}

M.base_16 = {
  base00 = "#292a30",
  base01 = "#35363e",
  base02 = "#414453",
  base03 = "#4a4c57",
  base04 = "#51535f",
  base05 = "#dfdfe0",
  base06 = "#ececed",
  base07 = "#f9f9f9",
  base08 = "#ff8170",
  base09 = "#ff8170",
  base0A = "#d9c97c",
  base0B = "#78c2b3",
  base0C = "#b281eb",
  base0D = "#4eb0cc",
  base0E = "#ff7ab2",
  base0F = "#bf6154",
}

M.type = "dark"

return M
