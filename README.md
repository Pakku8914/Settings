# Settings

VS Code / ターミナル（Ghostty + zsh）/ Neovim の設定を、別の Mac でも同じ操作感・同じ見た目で使うためのリポジトリ。

```
.
├── install.sh        # 一括セットアップ（シンボリックリンク + 依存の導入）
├── Brewfile          # 3つの環境が依存する CLI / アプリ / フォント
├── docs/
│   └── manual-setup.md   # install.sh を使わない場合の手順書
├── vscode/
├── terminal/
│   ├── ghostty/
│   └── zsh/
├── nvim/
└── claude/           # Claude Code のステータスライン
```

## セットアップ

```sh
xcode-select --install
git clone <このリポジトリ> ~/InProgress/Settings
cd ~/InProgress/Settings
./install.sh                            # すべて (brew → terminal → nvim → vscode → claude)
./install.sh terminal nvim              # 一部だけ
./install.sh vscode:markdown            # VS Code の拡張は共通 + 指定したグループ（vscode:all で全グループ）
```

- 既存のファイルは `~/.dotfiles-backup/<日時>/` に退避してからシンボリックリンクを張る。
- 何度実行しても同じ結果になる（リンク済み・clone 済みのものはスキップ）。
- `install.sh` を使わない場合は [docs/manual-setup.md](docs/manual-setup.md) を参照。

### 初回だけ手でやること

1. `gh auth login` を実行し、`~/.config/zsh/local.d/05-secrets.zsh` に残りの値を書く
2. nvim を一度起動し、LSP・フォーマッタ（Mason）と treesitter のパーサが入り終わるまで待つ（`install.sh` の実行中に出る mason の `Installation was aborted` は、このとき入り直すので無視してよい）
3. VS Code の Settings Sync を使っている場合は、このリポジトリと同期のどちらを正とするか決める（両方を有効にすると上書きし合う）

## 設定項目の一覧

### 見た目の統一

3つの環境は **Tinacious Design Dark** で色をそろえている。

| | テーマ | フォント |
|---|---|---|
| Ghostty | 組み込みテーマ `Tinacious Design Dark` | Ghostty 既定（14pt） |
| nvim | `nvim/lua/themes/Tinacious Design Dark.lua`（Ghostty の ANSI パレットを移植し、mini.base16 で配色） | ターミナルに従う |
| VS Code | `vscode/nvim-tinacious-design-dark/`（nvim テーマを移植した自作拡張） | UDEV Gothic NF（15pt） |

### vscode/

| ファイル | 配置先 | 主な内容 |
|---|---|---|
| `settings.json` | `~/Library/Application Support/Code/User/` | テーマ / JetBrains アイコン / UDEV Gothic NF 15pt（エディタ・ターミナル・チャット等すべて）/ 保存時フォーマット / 末尾空白・末尾改行の除去 / 空白の可視化 / Claude Code をパネルに配置・Ctrl+Enter で送信 / vscode-neovim の affinity |
| `keybindings.json` | 同上 | Cmd+J: ターミナル⇔エディタ / Cmd+Shift+J: ターミナル表示切替 / Cmd+K: Claude Code / Cmd+T・W・D・L・[ ]: ターミナルにフォーカスがあるときはターミナル操作、それ以外ではエディタ操作 / Alt+矢印: ペインのサイズ変更 / Ctrl+N: エクスプローラ / Cmd+E: エクスプローラ / Cmd+R: Gemini |
| `extensions/*.txt` | — | 拡張機能の一覧をグループごとに分けたもの（下表） |
| `nvim-tinacious-design-dark/` | `~/.vscode/extensions/` | 自作テーマ拡張のソース。中身は `.vsix` の構成そのままで、zip にすればインストールできる |

#### 拡張機能のグループ

一覧には必須の拡張だけを置いている。`common` はどの PC にも入れ、それ以外のグループは必要な PC でだけ指定する。言語ごとの拡張（Python, Salesforce など）は PC によって変わるので一覧に入れず、必要になった PC でその都度入れる。

| グループ | 拡張 |
|---|---|
| `common` | Claude Code, VSCode Neovim, JetBrains Icon Theme, 日本語パック, Code Spell Checker, indent-rainbow, Trailing Spaces, Rainbow CSV, YAML |
| `markdown` | markdownlint, Markdown All in One, Markdown Preview Enhanced, Markdown PDF |

グループを増やすときは `vscode/extensions/<グループ名>.txt` を作り、`./install.sh vscode:<グループ名>` で入れる。一覧には起点となる拡張だけを書けばよく、拡張パックや依存関係で入るものは自動でインストールされる（例: `salesforce.salesforcedx-vscode` を 1 つ書けば 22 個が入る）。

### terminal/

| ファイル | 配置先 | 主な内容 |
|---|---|---|
| `ghostty/config` | `~/.config/ghostty/config` | テーマ / 14pt / 日本語 UI / 余白 / Option を Alt として扱う / Cmd+J・Cmd+Shift+J を nvim に渡す |
#### zsh のファイルの分け方

| ファイル | 配置先 | 読まれるタイミング | 置くもの |
|---|---|---|---|
| `zsh/zshenv` | `~/.zshenv` | すべての zsh（スクリプト・`zsh -c` も） | 値を代入するだけの汎用の環境変数（`LANG`, `EDITOR`, `VISUAL`）。コマンドは実行しない |
| `zsh/zshrc` | `~/.zshrc` | 対話シェル（ターミナルのタブ・nvim の `:terminal`） | p10k の instant prompt と、モジュールを読むローダーだけ |
| `zsh/rc.d/` | `~/.config/zsh/rc.d`（ディレクトリごとリンク） | zshrc から番号順 | 設定の本体。1 機能 1 ファイル |
| `zsh/local.d/*.example` | `~/.config/zsh/local.d/` に**コピー** | rc.d と混ぜて番号順 | PC 固有・秘密のモジュール（リポジトリ外）。rc.d と同じ名前なら local.d を優先 |
| `zsh/p10k.zsh` | `~/.p10k.zsh` | `rc.d/99-p10k.zsh` から | `p10k configure` が生成したプロンプト設定（classic・2 行・Nerd Font v3） |

**`.zprofile` は使わない。** macOS のターミナルは、タブごとにシェルをログインシェル（`.zprofile` を読む）かつ対話シェル（`.zshrc` を読む）として起動するので、2 つに分ける意味がない。それどころか、`.zprofile` に書いた設定は次の 2 つの理由で効かない。

- nvim の `:terminal` は非ログインシェルなので、`.zprofile` を読まない
- `.zprofile` は macOS の `/etc/zshrc` や oh-my-zsh より前に読まれるので、そこで決めた値（履歴サイズ・`ls` のエイリアスなど）が後から上書きされる

**PATH は例外として `zshenv` に書かない。** ログインシェルでは `/etc/zprofile` の `path_helper` が PATH を並べ替えてしまうので、その後に読まれる `rc.d/00-path.zsh` で設定する。

#### モジュールの番号

| 番号 | 層 | 理由 |
|---|---|---|
| 00–09 | 土台（PATH・秘密情報） | 後のモジュールが使うコマンドや変数を先に用意する |
| 10–19 | oh-my-zsh | プラグインと補完を初期化する |
| 20–89 | 機能ごとの設定 | oh-my-zsh より後に読むので、その既定値を上書きできる |
| 90–99 | プロンプト | 最後に読む |

| モジュール | 主な内容 |
|---|---|
| `rc.d/00-path.zsh` | Homebrew / rbenv / pyenv / `~/.local/bin` / Antigravity。重複は自動で除く |
| `local.d/05-secrets.zsh` | トークン類（テンプレートは `zsh/local.d/05-secrets.zsh.example`） |
| `rc.d/10-oh-my-zsh.zsh` | oh-my-zsh とプラグイン（git, zsh-vi-mode, fzf-tab, autosuggestions, syntax-highlighting, history-substring-search） |
| `rc.d/20-options.zsh` | 履歴 10 万件 / 日本語のファイル名をエスケープせずに表示 |
| `rc.d/30-aliases.zsh` | `ls`/`ll`/`la`/`tree`→eza（アイコン付き。`ll`/`la` は git の状態も表示）, `cat`→bat, `vim`→nvim, `python`→python3。`grep` はオプションの意味が違うので rg に置き換えない |
| `rc.d/40-fzf.zsh` | Ctrl-R 履歴 / Ctrl-T ファイル / Ctrl-F ディレクトリ移動。fd で候補を出し、bat・eza でプレビュー |
| `rc.d/50-zoxide.zsh` | `z <キーワード>` でディレクトリ移動 |
| `rc.d/60-keybindings.zsh` | ↑↓（ノーマルモードでは k/j）で入力中の文字列に一致する履歴だけをたどる |
| `rc.d/70-hooks.zsh` | cd したあとに現在地とファイル一覧を表示 |
| `rc.d/75-term-title.zsh` | タブ名を「ディレクトリ — コマンド」にする（nvim のターミナルタブ名にも使われる） |
| `rc.d/80-integrations.zsh` | 外部アプリとの連携（Logi Build Haptics。アプリが入っている PC でだけ読む） |
| `rc.d/99-p10k.zsh` | p10k の読み込み |

### nvim/

[LazyVim](https://www.lazyvim.org)（starter）をベースにした構成。キーが重なるときは LazyVim の既定を優先し、自作の機能は空いているキーに割り当てている。

| ファイル | 主な内容 |
|---|---|
| `init.lua`, `lua/config/lazy.lua` | lazy.nvim の bootstrap と LazyVim の読み込み |
| `lazyvim.json` | 有効にしている extras（lang.python, lang.markdown, dap.core, coding.neogen, vscode）。`:LazyExtras` で切り替えるとこのファイルが書き換わる |
| `lazy-lock.json` | プラグインのバージョン固定（`:Lazy restore` でこの状態に戻せる） |
| `lua/config/options.lua` | Python の LSP を basedpyright にする / 空白文字の可視化 |
| `lua/config/keymaps.lua` | 下の表のキー |
| `lua/config/autocmds.lua` | Python で docstring の自動展開を有効化 |
| `lua/plugins/coding.lua` | 補完（blink.cmp）: 候補を自動で選ばない・Enter は改行のまま・Tab で候補選択とスニペット移動 / nvim-surround |
| `lua/plugins/lsp.lua` | basedpyright（.venv / `$VIRTUAL_ENV` を自動検出。プロジェクトのマーカーが無いフォルダでも同じフォルダの import を解決）/ html / cssls / 保存時に ruff で import 整理 + フォーマット / debugpy |
| `lua/plugins/editor.lua` | diffview / エクスプローラ（隠しファイルと .gitignore の対象も表示。ターミナルしか無いときはその上に開く） |
| `lua/plugins/colorscheme.lua` | テーマ `tinacious-design-dark` |
| `lua/ghostty_theme.lua`, `colors/*.lua` | Ghostty のパレット（`lua/themes/*.lua`）を mini.base16 で配色にする。24 テーマとも `:colorscheme` / `<leader>uC` で選べる |
| `lua/term_tabs.lua` | Snacks.terminal の上に作った、ターミナルのタブ機能（自作） |
| `lua/py_docstring.lua` | `"""` を入力すると neogen で docstring を展開（自作） |

#### 追加・変更したキー

それ以外は LazyVim の既定（`<leader>` を押すと which-key に一覧が出る）。

| キー | 動作 |
|---|---|
| `;` / `jk`（挿入モード） | `:` / Esc（VS Code でも有効） |
| Cmd+J | ターミナルとエディタのフォーカスを行き来する（タブが無ければ作る） |
| Alt+Shift+J / Cmd+Shift+J | ターミナルの表示・非表示 |
| Alt+T / Alt+W | ターミナルのタブを追加 / 閉じる |
| Alt+Shift+] / [ | 次 / 前のタブ（ターミナルにいればターミナルのタブ、それ以外はバッファ） |
| Alt+矢印 | ウィンドウのサイズ変更（macOS は Ctrl+矢印 を Mission Control が使うため） |
| `<leader>gv` / `<leader>gV` | diffview の開閉 / 今のファイルの履歴 |
| `gS`（ビジュアル） | 選択範囲を前後の行で囲む（nvim-surround。ビジュアルの `S` は flash に譲った） |

NvChad から移行して位置が変わった主なキー: エクスプローラは `<leader>e`、Alt+J/K は行の移動（ターミナルのフォーカスは Cmd+J だけ）、docstring の生成は `<leader>cn`、Markdown の表示切替は `<leader>um`、DAP は `<leader>d*`。

### claude/

| ファイル | 主な内容 |
|---|---|
| `statusline.sh` | Claude Code のステータスライン（2 行）。1 行目: モデル / effort / コンテキスト使用率 / 5 時間・7 日の利用上限（バー + %、50% で黄・80% で赤）/ 5 時間枠のリセット時刻。2 行目: カレントディレクトリ / git ブランチ |

`~/.claude/statusline.sh` にリンクし、`~/.claude/settings.json` には `statusLine` だけを書き込む。settings.json はほかの設定（権限・プラグインなど）も持ち Claude Code 自身も書き換えるので、ファイルごとは管理しない。
見た目はスクリプト冒頭の `ASCII`（記号を ASCII にする）と `WIDTH`（バーの分割数）で変えられる。

### Brewfile

| 用途 | パッケージ |
|---|---|
| terminal | ghostty, git, fzf, fd, bat, eza, zoxide, gh, pyenv, rbenv |
| nvim | neovim, node（Mason が LSP を npm で入れるため）, ripgrep（全文検索）, tree-sitter-cli（treesitter のパーサのビルド） |
| vscode | visual-studio-code, font-udev-gothic-nf |
| claude | jq（ステータスラインが Claude Code から受け取る JSON を読むため） |

## リポジトリに含めていないもの

| 対象 | 理由 / 扱い |
|---|---|
| `05-secrets.zsh` の値 | 秘密情報。テンプレートだけを置いている |
| `30-aws-functions.zsh` | 業務用の AWS アカウント ID・MFA ARN・ローカルのパスを含むため。必要な PC では `~/.config/zsh/local.d/` に置けば自動で読まれる |
| VS Code の `globalStorage` / `workspaceStorage` / `History` / `sync` | 設定ではなく状態データ |
| Warp（`~/.warp`） | アプリがインストールされておらず、いま使っているターミナルは Ghostty |
| Zed / git の設定 | 今回は対象外 |

## 設定を変えたら

シンボリックリンクなので、各アプリで設定を変えるとこのリポジトリのファイルが直接書き換わる。あとはコミットするだけでよい。

```sh
# VS Code の拡張を追加・削除したあと: 該当するグループのファイル（vscode/extensions/*.txt）に ID を 1 行追記・削除する
# ID は拡張機能ビューの歯車 →「拡張機能 ID のコピー」で取れる

# zsh に設定を足すとき: 上の番号の規則に沿って rc.d/ にモジュールを追加する（PC 固有・秘密なら ~/.config/zsh/local.d/）
# p10k configure をやり直したとき: ~/.zshrc への追記を提案されるが、99-p10k.zsh で読んでいるので断る

# nvim のプラグインを更新したあと（:Lazy update で lazy-lock.json が更新される）
git add nvim/lazy-lock.json
# :LazyExtras で extras を切り替えたあと
git add nvim/lazyvim.json
```
