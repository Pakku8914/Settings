# 手動セットアップ手順（install.sh を使わない場合）

`install.sh` が行っていることを、1 ステップずつ手で実行する手順書。各章の最後に動作確認がある。
章ごとに独立しているので、ターミナルだけ・nvim だけといった部分的な導入もできる（依存は「0. 準備」と「1. Homebrew」だけ）。

> **リンクとコピーのどちらにするか**
> この手順は `ln -s`（シンボリックリンク）で配置する。アプリ側で設定を変えるとリポジトリのファイルが直接書き換わるので、そのままコミットできる。
> 端末ごとに独立させたい場合は、`ln -s` を `cp` に（ディレクトリは `cp -R` に）置き換えればよい。その場合、変更はリポジトリに反映されない。

---

## 0. 準備

```sh
# git などの開発ツール（Homebrew のインストーラも内部で使う）
xcode-select --install

git clone <このリポジトリ> ~/InProgress/Settings

# 以降のコマンドで使う変数（このシェルの中でだけ有効）
DOTFILES=~/InProgress/Settings
```

### 既存の設定を退避する

すでに設定ファイルがある端末では、`ln -s` が「File exists」で失敗するので先に退避しておく。

```sh
mkdir -p ~/dotfiles-backup
for f in ~/.zshenv ~/.zprofile ~/.zshrc ~/.p10k.zsh ~/.config/zsh/rc.d ~/.config/ghostty/config ~/.config/nvim ~/.claude/statusline.sh; do
  [ -e "$f" ] && mv "$f" ~/dotfiles-backup/
done
```

> `~/.zprofile` はこの構成では使わない（理由は README の「zsh のファイルの分け方」）。残っていると PATH の設定などが二重に走るので、ほかと一緒に退避する。
> 旧構成（`~/.config/zsh/rc.d/` に秘密情報のファイルを置いていた PC）から移行する場合は、退避する**前に** `05-secrets.zsh` などを `~/.config/zsh/local.d/` に移しておく（2-3）。

## 1. Homebrew とパッケージ

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

brew bundle --file="$DOTFILES/Brewfile"
```

`brew bundle` を使わずに入れる場合:

```sh
brew install git fzf fd bat eza zoxide gh pyenv rbenv neovim node ripgrep tree-sitter-cli jq
brew install --cask ghostty visual-studio-code font-udev-gothic-nf
```

> VS Code を公式サイトから入れてある場合、cask は「already an App」で失敗する。そのままでよければ `visual-studio-code` を外す。Homebrew の管理下に移すなら `brew install --cask --adopt visual-studio-code` を使う。

**確認**: `which nvim fzf fd bat eza zoxide gh` がすべてパスを返す。

---

## 2. ターミナル（Ghostty + zsh）

### 2-1. oh-my-zsh とプラグイン

公式のインストーラは `~/.zshrc` を上書きするので使わず、`git clone` で入れる。

```sh
OMZ=~/.oh-my-zsh
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git                  "$OMZ/custom/themes/powerlevel10k"
git clone --depth=1 https://github.com/jeffreytse/zsh-vi-mode.git                 "$OMZ/custom/plugins/zsh-vi-mode"
git clone --depth=1 https://github.com/Aloxaf/fzf-tab.git                         "$OMZ/custom/plugins/fzf-tab"
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git          "$OMZ/custom/plugins/zsh-autosuggestions"
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git      "$OMZ/custom/plugins/zsh-syntax-highlighting"
git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search.git "$OMZ/custom/plugins/zsh-history-substring-search"
```

### 2-2. zsh の設定ファイル

```sh
ln -s "$DOTFILES/terminal/zsh/zshenv"   ~/.zshenv
ln -s "$DOTFILES/terminal/zsh/zshrc"    ~/.zshrc
ln -s "$DOTFILES/terminal/zsh/p10k.zsh" ~/.p10k.zsh

mkdir -p ~/.config/zsh
ln -s "$DOTFILES/terminal/zsh/rc.d" ~/.config/zsh/rc.d
```

> `rc.d` はディレクトリごとリンクするので、リポジトリでモジュールを追加・改名すればそのまま反映される。PC 固有・秘密のモジュールは、リンクの外の `~/.config/zsh/local.d/` に置く（次の 2-3）。`~/.zshrc` が両方を番号順に混ぜて読む。

### 2-3. シークレット（local.d）

```sh
mkdir -p ~/.config/zsh/local.d
cp "$DOTFILES/terminal/zsh/local.d/05-secrets.zsh.example" ~/.config/zsh/local.d/05-secrets.zsh
chmod 600 ~/.config/zsh/local.d/05-secrets.zsh

gh auth login                                 # GITHUB_PERSONAL_ACCESS_TOKEN はここから取得される
nvim ~/.config/zsh/local.d/05-secrets.zsh     # BACKLOG_ORG_UZONE_API_KEY を記入
```

### 2-4. （任意）業務用の AWS 関数

`30-aws-functions.zsh`（`rds_connection` / `ecs_connection`）はリポジトリに含めていない。必要な PC では、元の Mac から `~/.config/zsh/local.d/30-aws-functions.zsh` にコピーするだけで読み込まれる。

### 2-5. Ghostty

```sh
mkdir -p ~/.config/ghostty
ln -s "$DOTFILES/terminal/ghostty/config" ~/.config/ghostty/config
```

> Ghostty は macOS では `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` も読み込む。そこにファイルがあると両方の設定が有効になるので、残すなら内容が重複していないか確認する。

### 確認

Ghostty を再起動して、次の状態になっていれば OK。

- [ ] 背景が濃い紺（`#1d1d26`）、文字が薄い紫で、ピンクのアクセントがある
- [ ] プロンプトが 2 行（1 行目: OS アイコン・ディレクトリ・git の状態 / 2 行目: `❯`）
- [ ] `cd ~` で「current_dir: ~」とファイル一覧が表示される
- [ ] `Ctrl-R` で fzf の履歴検索、`Ctrl-T` でファイル選択（右にプレビュー）
- [ ] `Esc` で vi のノーマルモードに入れる
- [ ] `echo $EDITOR` が `nvim` を返す
- [ ] `alias ls` が `ls=eza` を返す（nvim の `:terminal` の中でも同じ）

---

## 3. Neovim

```sh
ln -s "$DOTFILES/nvim" ~/.config/nvim

# 1. lockfile を控える（初回インストールで書き換えられることがあるため。理由は下記）
cp ~/.config/nvim/lazy-lock.json /tmp/lazy-lock.json

# 2. プラグインをインストールする（1〜2 分）
nvim --headless +qa

# 3. 控えた lockfile を戻し、プラグインをそのバージョンにそろえる
cp /tmp/lazy-lock.json ~/.config/nvim/lazy-lock.json
nvim --headless "+Lazy! restore" +qa
```

> **なぜ lockfile を控えるのか**: 1 回目の起動では、LazyVim の中で定義されているプラグインの一部が lockfile の版ではなく最新版で入り、lockfile もその版に書き換わることがある（実際に mini.ai で起きた）。元の lockfile に戻してから restore すれば、全プラグインが固定バージョンにそろう。
>
> 手順 2 で `[mason.nvim] Neovim exited while the following packages were installing` と出ることがある。裏で始まったインストールが nvim の終了で中断されただけで、次に起動したときに入り直すので無視してよい。

続けて `nvim` を通常どおり起動して、次の 2 つを行う。

1. LSP・フォーマッタ・debugpy（Mason）と treesitter のパーサが自動で入るので、通知が落ち着くまで待つ（Mason の進み具合は `:Mason` で見られる）。
2. `:checkhealth lazyvim` で致命的なエラーがないことを確認する。

### 確認

- [ ] 背景色が Ghostty と同じ（`:lua print(vim.api.nvim_get_hl(0,{name='Normal'}).bg)` が `1908006`（= `#1d1d26`）を返す）
- [ ] `Space` → `e` でエクスプローラが開く
- [ ] `Alt+T` でターミナルタブが開き、`Cmd+J` でエディタとの間を移動できる
- [ ] Python ファイルの `def` の直下で `"""` と入力すると docstring が展開される

> `Alt` のキーマップは Ghostty の `macos-option-as-alt = true`（2-5）が前提。

---

## 4. VS Code

### 4-1. `code` コマンド

Homebrew の cask で入れた場合はすでにパスが通っている。公式サイトから入れた場合は、VS Code のコマンドパレット（`Cmd+Shift+P`）で **Shell Command: Install 'code' command in PATH** を実行する。

### 4-2. 設定ファイル

VS Code を終了してから実行する。

```sh
VSU="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSU"
for f in settings.json keybindings.json; do
  [ -e "$VSU/$f" ] && mv "$VSU/$f" ~/dotfiles-backup/
  ln -s "$DOTFILES/vscode/$f" "$VSU/$f"
done
```

### 4-3. 拡張機能（マーケットプレイス）

拡張機能は `vscode/extensions/` にグループごとに分けてある。`common.txt` はどの PC にも入れ、ほかのグループは必要な PC でだけ入れる（グループの一覧は README を参照）。

```sh
cd "$DOTFILES/vscode/extensions"

# 共通（必須）
awk '!/^#/ && NF {print $1}' common.txt | xargs -L 1 code --install-extension

# 必要なグループを追加する（例: markdown）
awk '!/^#/ && NF {print $1}' markdown.txt | xargs -L 1 code --install-extension
```

> 各ファイルには 1 行に 1 つ拡張の ID が書いてあり、`#` 以降はコメント。`awk` でコメントと空行を除いて ID だけを取り出している。

### 4-4. 自作テーマ（Tinacious Design Dark (nvim)）

マーケットプレイスにないので、リポジトリ内のソースを `.vsix` にまとめてインストールする。`nvim-tinacious-design-dark/` の中身は `.vsix` の構成そのものなので、zip にするだけでよい。

```sh
cd "$DOTFILES/vscode/nvim-tinacious-design-dark"
zip -r /tmp/nvim-tinacious-design-dark.vsix '[Content_Types].xml' extension.vsixmanifest extension
code --install-extension /tmp/nvim-tinacious-design-dark.vsix
```

GUI で入れる場合は、拡張機能ビューの「…」メニュー →「VSIX からのインストール…」で同じファイルを選ぶ。

### 4-5. Settings Sync

Settings Sync を有効にしていると、同期された設定とこのリポジトリの設定が上書きし合う。どちらを正とするか決めて、リポジトリを正とするなら Settings Sync で「設定」と「キーボード ショートカット」の同期をオフにする。

### 確認

- [ ] 配色テーマが「Tinacious Design Dark (nvim)」、アイコンが JetBrains 風になっている
- [ ] エディタのフォントが UDEV Gothic NF（日本語と英数字の幅が 2:1 になる）
- [ ] `Cmd+J` でターミナルとエディタの間を移動できる
- [ ] `Cmd+K` で Claude Code のパネルにフォーカスが移る
- [ ] エディタで vim の操作ができる（vscode-neovim）

---

## 5. Claude Code のステータスライン

```sh
mkdir -p ~/.claude
ln -s "$DOTFILES/claude/statusline.sh" ~/.claude/statusline.sh
```

`~/.claude/settings.json` に次のキーを足す（ファイルが無ければ `{ }` で囲んで新規作成）。ほかのキーはそのまま残す。

```json
"statusLine": {
  "type": "command",
  "command": "bash ~/.claude/statusline.sh",
  "padding": 0
}
```

> パスを `/Users/<ユーザー名>/...` と書くと、ユーザー名が違う PC で動かなくなる。`~` で書く。

### 確認

- [ ] `claude` を起動すると、入力欄の下に 2 行のステータスライン（モデル・CTX・5h・7d のバーと、ディレクトリ・ブランチ）が出る

---

## うまくいかないとき

| 症状 | 原因と対処 |
|---|---|
| `ln: ... File exists` | 既存のファイルがある。「0. 準備」の退避を実行する |
| zsh 起動時に `rbenv: command not found` など | Homebrew のパッケージが入っていない。「1. Homebrew」を実行する |
| プロンプトのアイコンが□になる | Nerd Font がない。Ghostty の既定フォントには含まれているので、`font-family` を変えた場合は Nerd Font を指定する |
| nvim の `Alt` キーマップが効かない | Ghostty の `macos-option-as-alt` が有効になっていない（2-5） |
| nvim で `module 'config.lazy' not found` | `~/.config/nvim` のリンク先が `nvim/` ディレクトリになっていない。`ls -l ~/.config/nvim` で確認する |
| 初回セットアップ後に `git status` で `nvim/lazy-lock.json` が変更扱いになる | 3 の lockfile の控え・復元を飛ばした。`git -C "$DOTFILES" restore nvim/lazy-lock.json` のあと `nvim --headless "+Lazy! restore" +qa` を実行する |
