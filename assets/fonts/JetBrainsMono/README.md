# WezTerm 内置字体

本目录包含 WezTerm 配置使用的 JetBrains Mono Nerd Font Mono：

```text
JetBrainsMonoNerdFontMono-Regular.ttf
JetBrainsMonoNerdFontMono-Bold.ttf
JetBrainsMonoNerdFontMono-Italic.ttf
JetBrainsMonoNerdFontMono-BoldItalic.ttf
```

字体版本：Nerd Fonts v3.5.1  
字体项目：https://github.com/ryanoasis/nerd-fonts  
许可证：SIL Open Font License 1.1，完整文本见 `OFL.txt`。

## WezTerm 直接加载

仓库根目录的 `wezterm.lua` 已配置：

```lua
font_dirs = { wezterm.config_dir .. "/fonts" },
```

因此 WezTerm 会从当前配置目录的 `fonts/` 加载字体，**不需要先安装到系统**。
克隆仓库并建立 `~/.config/wezterm` 软链接后，完全退出并重新启动 WezTerm 即可。

验证字体是否被识别：

```bash
wezterm --config-file "$HOME/wezterm/wezterm.lua" ls-fonts --text "ABC 中文 󰇄"
```

## Linux 系统安装（可选）

如果还需要在 Alacritty、浏览器或其他程序中使用同一字体，可以安装到用户字体目录：

```bash
mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNerdFontMono"
cp "$HOME/wezterm/fonts/"*.ttf "$HOME/.local/share/fonts/JetBrainsMonoNerdFontMono/"
fc-cache -fv
fc-list | grep -i "JetBrainsMono Nerd Font Mono"
```

Manjaro / Arch Linux 也可以直接安装：

```bash
sudo pacman -S --needed ttf-jetbrains-mono-nerd
```

## macOS 系统安装（可选）

```bash
mkdir -p "$HOME/Library/Fonts"
cp "$HOME/wezterm/fonts/"*.ttf "$HOME/Library/Fonts/"
```

或使用 Homebrew：

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

## Windows 系统安装（可选）

在资源管理器中打开 `fonts` 目录，选中四个 `.ttf` 文件，右键选择“安装”或
“为所有用户安装”。安装完成后重启 WezTerm。

WezTerm 本身会优先通过仓库内的 `font_dirs` 加载字体，系统安装主要用于其他应用。
