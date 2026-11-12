-- Ported from Ghostty's "Xcode WWDC" theme (mbadolato/iTerm2-Color-Schemes)
-- Colors are derived mechanically from the terminal ANSI-16 palette so this
-- matches the Ghostty theme of the same name in ~/.config/ghostty/config.

local M = {}

M.base_30 = {
  white = "#e7e8eb",
  darker_black = "#20232a",
  black = "#292c36",
  black2 = "#30333f",
  one_bg = "#343844",
  one_bg2 = "#3b3f4d",
  one_bg3 = "#3f4453",
  grey = "#484d5f",
  grey_fg = "#4e5467",
  grey_fg2 = "#555b70",
  light_grey = "#596076",
  red = "#bb383a",
  baby_pink = "#cc6a6b",
  pink = "#b93865",
  line = "#343844",
  green = "#94c66e",
  vibrant_green = "#94c66e",
  nord_blue = "#8884c5",
  blue = "#8884c5",
  yellow = "#d28e5d",
  sun = "#d28e5d",
  purple = "#b73999",
  dark_purple = "#892b73",
  teal = "#00aba4",
  orange = "#c8674d",
  cyan = "#00aba4",
  statusline_bg = "#2d313c",
  lightbg = "#3b3f4d",
  pmenu_bg = "#8884c5",
  folder_bg = "#8884c5",
}

M.base_16 = {
  base00 = "#292c36",
  base01 = "#343844",
  base02 = "#494d5c",
  base03 = "#484d5f",
  base04 = "#4e5467",
  base05 = "#e7e8eb",
  base06 = "#f5f5f7",
  base07 = "#ffffff",
  base08 = "#bb383a",
  base09 = "#bb383a",
  base0A = "#d28e5d",
  base0B = "#94c66e",
  base0C = "#00aba4",
  base0D = "#8884c5",
  base0E = "#b73999",
  base0F = "#8c2a2c",
}

M.type = "dark"

return M
