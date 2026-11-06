# i3 配置

本目录通过 `link.sh` 链接到 `~/.config/i3`。

## 目录说明

| 路径 | 用途 |
| --- | --- |
| `config` | i3 主配置 |
| `backgrounds/` | 壁纸 |
| `screenshot/` | 全屏、当前窗口、选区截图 |
| `scripts/` | 双屏监听、触控板点击和自然滚动 |
| `brightness/` | 亮度调整辅助脚本 |
| `lock/betterlockscreen` | 锁屏脚本 |
| `install.sh` | 安装辅助命令到 `~/.local/bin` |

## 依赖

Arch/Manjaro：

```bash
sudo pacman -S --needed \
  i3-wm i3status xss-lock feh polybar alacritty dmenu \
  xorg-xrandr xorg-xbacklight xorg-xmodmap xorg-xinput \
  scrot xclip imagemagick bc xorg-xdpyinfo chromium ranger
```

可选：

```bash
sudo pacman -S --needed compton i3lock
```

`betterlockscreen` 还需要 `i3lock-color`、ImageMagick、`xdpyinfo`、`xrandr`、`bc` 和 `feh`。`i3lock-color` 在部分发行版中位于 AUR。

Ubuntu/Debian：

```bash
sudo apt install i3-wm i3status i3lock xss-lock feh polybar alacritty \
  dmenu x11-xserver-utils xinput scrot xclip imagemagick bc x11-utils chromium ranger
```

## 安装与关联

```bash
cd ~/.dotfile
./link.sh
./i3/install.sh
```

确认 `~/.local/bin` 已加入 `PATH`：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## 验证配置

```bash
i3 -C -c ~/.config/i3/config
```

应用修改：

```bash
i3-msg reload
```

涉及启动项变更时使用：

```bash
i3-msg restart
```

## 常用快捷键

| 快捷键 | 功能 |
| --- | --- |
| `Mod+Enter` | Alacritty |
| `Mod+D` | dmenu |
| `Mod+Shift+R` | 重载 i3 |
| `Print` | 全屏截图 |
| `Mod+Print` | 选区截图 |
| `Mod+Shift+Print` | 当前窗口截图 |
| `Mod+Shift+T` | Ranger |
| `Mod+X` | Betterlockscreen |
| `Ctrl+Shift+L` | 关闭屏幕 |
| `Mod+C` | Chromium |

## 截图

截图保存在 `~/Pictures/`，同时复制到剪贴板。依赖：

- `scrot`
- `xclip`

## 双屏处理

`scripts/dual-display.sh` 每两秒检查一次显示布局：

- `HDMI-1` 接入时自动放在 `eDP-1` 右侧，并重新设置双屏壁纸；
- `HDMI-1` 断开时自动关闭残留输出，避免 i3 工作区卡在已拔出的屏幕上。

手动检查：

```bash
xrandr --query
i3-msg -t get_workspaces
```

## 锁屏和关闭屏幕

```bash
~/.local/bin/betterlockscreen -u ~/.config/i3/lock/ante.jpg -l -b 1 dim
~/.local/bin/screen_off
```

## 排查

```bash
i3 -C -c ~/.config/i3/config
bash -n ~/.config/i3/scripts/dual-display.sh
xrandr --query
```

如果拔掉外屏后工作区不可切换：

```bash
xrandr --output HDMI-1 --off
i3-msg reload
```
