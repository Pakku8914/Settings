local function find_venv_python(root)
  -- { vim.env.VIRTUAL_ENV, ... } と書くと、VIRTUAL_ENV が nil のとき ipairs が先頭で止まり .venv を見ないので、配列を順に組み立てる
  local dirs = {}
  if vim.env.VIRTUAL_ENV then
    dirs[#dirs + 1] = vim.env.VIRTUAL_ENV
  end
  if root then
    dirs[#dirs + 1] = root .. "/.venv"
  end
  for _, dir in ipairs(dirs) do
    local py = dir .. "/bin/python"
    if vim.uv.fs_stat(py) then
      return py
    end
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
        basedpyright = {
          -- マーカー (pyproject.toml / .git 等) が無い学習用ディレクトリでは、開いたファイルのあるディレクトリを root にする。
          -- root が無いと同じフォルダの `import calc` のようなローカルモジュールが解決されない
          root_dir = function(bufnr, on_dir)
            local markers = vim.lsp.config.basedpyright.root_markers
            on_dir(vim.fs.root(bufnr, markers) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
          end,
          -- プロジェクトの .venv / $VIRTUAL_ENV があればその python を使い、サードパーティ製ライブラリも補完対象にする。
          -- クライアントは起動時に config.settings の参照を持つので、テーブルを差し替えず中身を書き換える
          before_init = function(_, config)
            local py = find_venv_python(config.root_dir)
            if py then
              config.settings.python = vim.tbl_extend("force", config.settings.python or {}, { pythonPath = py })
            end
          end,
          settings = {
            basedpyright = {
              disableOrganizeImports = true,
              -- basedpyright 既定の "recommended" は既存コードで警告が大量に出るため Pylance 相当に緩める
              -- (プロジェクト側の pyproject.toml [tool.basedpyright] があればそちらが優先される)
              analysis = { typeCheckingMode = "standard" },
            },
          },
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
      },
    },
  },

  -- dap.core + lang.python は debugpy を自動では入れない（dap-python が使う debugpy-adapter はこのパッケージに入っている）
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "debugpy" } },
  },
}
