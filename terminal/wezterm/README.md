# WezTerm 配置

我的 WezTerm 跨平台配置，包含字体回退、主题、键位和 SSH 远程域模块。

## 目录

```text
wezterm.lua
fonts/
  README.md
  JetBrainsMonoNerdFontMono-*.ttf
utils/
  background.lua
  color_scheme.lua
  helpers.lua
  keys.lua
  ssh.lua
scripts/
  install-nerd-font.ps1
  start-work.ps1
  ssh.cmd
  install-yazi.sh
  configure-yazi-ranger.sh
  patch-mdcat-bashrc.sh
examples/
  ssh_config_example.txt
docs/
  terminal-image-display.md
```

## 终端图片支持

当前配置已经包含：

- `enable_kitty_graphics = true`
- `custom_block_glyphs = false`
- `TERM_PROGRAM = "WezTerm"`
- `LC_TERMINAL = "WezTerm"`
- `COLORTERM = "truecolor"`
- Windows 优先字体 `JetBrainsMono Nerd Font Mono`
- 中文回退字体 `Microsoft YaHei UI`
- 符号回退字体 `Segoe UI Symbol`

仓库的 `fonts/` 目录已内置 JetBrains Mono Nerd Font Mono 常用字重，
WezTerm 会通过 `font_dirs` 从配置目录直接加载，无需先安装到系统。
字体来源、许可证和可选系统安装方法见 `fonts/README.md`。

Windows 如需给其他应用安装字体，可运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-nerd-font.ps1
```

## SSH 跳板机

示例配置见：

```text
examples/ssh_config_example.txt
```

WezTerm 内置 SSH 当前不直接支持 `ProxyJump`，但支持 `ProxyCommand`。如果直接使用内置 ProxyCommand 出现：

```text
Fatal: Socket error: Unknown error
```

可以使用本地端口转发，再用 `wezterm ssh` 连接本机转发端口。辅助脚本：

```text
scripts/start-work.ps1
scripts/ssh.cmd
```

把占位符替换为自己的主机、用户名和密钥路径。不要把私钥提交到仓库。

## 远程工具链

无 sudo 安装 Yazi 和 resvg：

```bash
bash scripts/install-yazi.sh
bash scripts/configure-yazi-ranger.sh
bash scripts/patch-mdcat-bashrc.sh
```

## 终端图片排错

完整说明见 [docs/terminal-image-display.md](docs/terminal-image-display.md)。

核心结论：

- 图片协议数据随 SSH 字节流传输，不需要额外开放图片端口。
- 普通 `ssh.exe` 的 ConPTY 可能破坏图片坐标和尺寸。
- Yazi 使用 iTerm2 inline image protocol 时，`ya env` 应显示 `Drivers.matches: Iip`。
- mdcat 必须获得 `TERM_PROGRAM=WezTerm`，否则只显示 `image` 标签。
- Ranger 推荐 `preview_images_method iterm2`，并使用 `ranger_devicons` 插件。

## 已验证版本

- WezTerm 20240203-110809-5046fc22
- Yazi 26.9.1
- resvg 0.49.0
- Nerd Fonts 3.5.1