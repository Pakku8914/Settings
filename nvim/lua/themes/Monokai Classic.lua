-- Ported from Ghostty's "Monokai Classic" theme (mbadolato/iTerm2-Color-Schemes)
-- Colors are derived mechanically from the terminal ANSI-16 palette so this
-- matches the Ghostty theme of the same name in ~/.config/ghostty/config.

local M = {}

M.base_30 = {
  white = "#fdfff1",
  darker_black = "#1c1d19",
  black = "#272822",
  black2 = "#2f3029",
  one_bg = "#34362e",
  one_bg2 = "#3d3e35",
  one_bg3 = "#424439",
  grey = "#4d4f43",
  grey_fg = "#55574a",
  grey_fg2 = "#5d5f51",
  light_grey = "#626556",
  red = "#f92672",
  baby_pink = "#fa5c95",
  pink = "#d74fb1",
  line = "#34362e",
  green = "#a6e22e",
  vibrant_green = "#a6e22e",
  nord_blue = "#fd971f",
  blue = "#fd971f",
  yellow = "#e6db74",
  sun = "#e6db74",
  purple = "#ae81ff",
  dark_purple = "#8261bf",
  teal = "#66d9ef",
  orange = "#ef8a73",
  cyan = "#66d9ef",
  statusline_bg = "#2c2e27",
  lightbg = "#3d3e35",
  pmenu_bg = "#fd971f",
  folder_bg = "#fd971f",
}

M.base_16 = {
  base00 = "#272822",
  base01 = "#34362e",
  base02 = "#57584f",
  base03 = "#4d4f43",
  base04 = "#55574a",
  base05 = "#fdfff1",
  base06 = "#ffffff",
  base07 = "#ffffff",
  base08 = "#f92672",
  base09 = "#f92672",
  base0A = "#e6db74",
  base0B = "#a6e22e",
  base0C = "#66d9ef",
  base0D = "#fd971f",
  base0E = "#ae81ff",
  base0F = "#bb1c56",
}

M.type = "dark"

return M
