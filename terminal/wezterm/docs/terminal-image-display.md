# 终端图片显示配置与排错

这份文档记录 WezTerm + SSH 跳板机 + 远程 Linux 下图片显示问题的完整配置思路。

## 原理

WezTerm 支持：

- iTerm2 inline image protocol
- Kitty graphics protocol
- Sixel

图片程序把图片编码成终端转义序列，通过 SSH 字节流发送给 WezTerm。跳板机只负责 TCP 转发，不需要理解或单独开放图片端口。

故障通常分成四层：

1. 应用层：Yazi、Ranger、mdcat 是否真的输出图片协议
2. 协议层：iTerm2、Kitty 或 Sixel 是否匹配终端
3. 传输层：普通 `ssh.exe`、ConPTY、tmux 是否改写终端状态
4. 渲染层：WezTerm 图片支持和 Nerd Font 是否正常

## WezTerm 配置

```lua
enable_kitty_graphics = true,
custom_block_glyphs = false,

font = wezterm.font_with_fallback({
    { family = "JetBrainsMono Nerd Font Mono", weight = "Regular" },
    { family = "Microsoft YaHei UI", weight = "Regular" },
    { family = "Segoe UI Symbol", weight = "Regular" },
}),

set_environment_variables = {
    TERM_PROGRAM = "WezTerm",
    LC_TERMINAL = "WezTerm",
    COLORTERM = "truecolor",
},
```

安装 Nerd Font：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-nerd-font.ps1
```

验证 `U+E0BF`：

```powershell
wezterm.exe --config-file .\wezterm.lua ls-fonts --text ([string][char]0xE0BF)
```

输出应指向 `JetBrainsMono Nerd Font Mono` 的实际字体文件，而不是 WezTerm 内置占位字形。

## SSH 跳板

示例配置：

```sshconfig
Host bastion
    HostName bastion.example.com
    User jumpuser
    Port 11988
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host work
    HostName 203.0.113.10
    Port 2223
    User deploy
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    ProxyCommand C:/Windows/System32/OpenSSH/ssh.exe -q -W %h:%p bastion
    RequestTTY yes
```

WezTerm 内置 SSH 不支持 `ProxyJump`，但支持 `ProxyCommand`。如果内置 ProxyCommand 出现 Socket 错误，可以用本地端口转发：

```powershell
ssh -N -o ExitOnForwardFailure=yes -L 22222:203.0.113.10:2223 bastion
wezterm.exe ssh -o IdentityFile=C:/Users/<user>/.ssh/id_ed25519 -o IdentitiesOnly=yes deploy@127.0.0.1:22222
```

## 远程 shell 环境

在 `~/.bashrc` 中加入：

```bash
export PATH="$HOME/.local/bin:$PATH"

if [[ -n ${SSH_CONNECTION:-} && -z ${TERM_PROGRAM:-} ]]; then
    export TERM_PROGRAM=WezTerm
    export LC_TERMINAL=WezTerm
    export COLORTERM=truecolor
fi
```

mdcat 只依赖环境变量检测终端。缺少 `TERM_PROGRAM=WezTerm` 时，它只会显示 `image` 标签。

## Yazi

```toml
[mgr]
ratio = [1, 2, 5]

[preview]
image_filter = "lanczos3"
image_quality = 90
max_width = 1600
max_height = 1600
```

验证：

```bash
ya env
```

期望：

```text
brand: WezTerm
Drivers.matches: Iip
```

## Ranger

`~/.config/ranger/rc.conf`：

```text
set preview_images true
set preview_images_method iterm2
set iterm2_font_width 19
set iterm2_font_height 47
set draw_borders true
default_linemode devicons
```

文件图标需要 `ranger_devicons`：

```bash
mkdir -p ~/.config/ranger/plugins
git clone --depth 1 https://github.com/alexanderjeurissen/ranger_devicons \
  ~/.config/ranger/plugins/ranger_devicons
```

Ranger 文字字体由 WezTerm 决定，`iterm2_font_width/height` 只影响图片尺寸和位置。

## 常见问题

### 只显示 `image`

检查远端：

```bash
printf 'TERM_PROGRAM=%s\n' "$TERM_PROGRAM"
```

必须是：

```text
TERM_PROGRAM=WezTerm
```

### 图片在右下角或被裁切

优先确认是否使用原生 `wezterm ssh` 会话，而不是普通 `ssh.exe` 的 ConPTY 会话。

### 退出图片后出现 `10;rgb:...`

这是终端能力探测回复泄漏到 shell 的输入流，不是图片内容或 Ranger 字体。

处理：

```bash
reset
```

并重新打开原生 `wezterm ssh` 会话。

### 缺字 `U+E0BF`

安装 `JetBrainsMono Nerd Font Mono`，并设置：

```lua
custom_block_glyphs = false
```

### Ranger 图标显示成方块

确认：

```text
~/.config/ranger/plugins/ranger_devicons/__init__.py
```

存在，并且 `rc.conf` 中有 `default_linemode devicons`。

## 验证清单

```bash
printf 'TERM=%s TERM_PROGRAM=%s COLORTERM=%s\n' \
  "$TERM" "$TERM_PROGRAM" "$COLORTERM"

command -v yazi
command -v mdcat
command -v resvg

test -f ~/.config/ranger/plugins/ranger_devicons/__init__.py && echo PLUGIN_OK
```