# i3 配置

本目录通过 `link.sh` 链接到 `~/.config/i3`。

## 目录说明

| 路径 | 用途 |
| --- | --- |
| `config` | i3 主配置 |
| `backgrounds/` | 壁纸 |
| `screenshot/` | 全屏、当前窗口、选区截图 |
| `scripts/` | 触控板点击和自然滚动 |
| `display-position/` | 外接屏位置切换、监听、配置和说明 |
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
| `Mod+Shift+D` | 选择外接屏位置 |
| `Mod+X` | Betterlockscreen |
| `Ctrl+Shift+L` | 关闭屏幕 |
| `Mod+C` | Chromium |

## 截图

截图保存在 `~/Pictures/`，同时复制到剪贴板。依赖：

- `scrot`
- `xclip`

## 双屏处理

`display-position/dual-display.sh` 每两秒检查一次显示布局，并根据 `display-position/dual-display.conf` 自动放置外接屏。

配置文件：

```text
~/.config/i3/display-position/dual-display.conf
```

脚本内置默认值是 `right`。当前仓库配置为 `above`：

```bash
INTERNAL_OUTPUT="eDP-1"
EXTERNAL_OUTPUT="HDMI-1"
EXTERNAL_POSITION="above"
```

`EXTERNAL_POSITION` 支持：

| 值 | 外接屏位置 | 鼠标方向 |
| --- | --- | --- |
| `right` | 内屏右侧 | 从内屏右边缘移到外屏 |
| `left` | 内屏左侧 | 从内屏左边缘移到外屏 |
| `above` | 内屏上方 | 从内屏上边缘移到外屏 |
| `below` | 内屏下方 | 从内屏下边缘移到外屏 |

例如改回右侧：

```bash
sed -i 's/^EXTERNAL_POSITION=.*/EXTERNAL_POSITION="right"/' \
  ~/.config/i3/display-position/dual-display.conf

pkill -f '^bash .*dual-display.sh$' || true
i3-msg 'exec --no-startup-id $HOME/.config/i3/display-position/dual-display.sh'
```

监听脚本会等待旧进程释放锁，再按新配置重新应用布局。

也可以使用统一命令修改并立即应用：

```bash
i3-display-position above
i3-display-position right
i3-display-position left
i3-display-position below
```

不带参数会打开 dmenu 菜单；`Mod+Shift+D` 绑定了同一个菜单：

```bash
i3-display-position
```

其他命令：

```bash
i3-display-position status  # 查看配置和实际坐标
i3-display-position cycle   # right -> above -> left -> below 轮换
i3-display-position apply   # 重新应用当前配置
```

如果命令不存在，先重新执行安装脚本：

```bash
~/.dotfile/i3/install.sh
```

完整说明见 [`display-position/README.md`](display-position/README.md)。

也可以直接手动测试：

```bash
# 右侧
xrandr --output HDMI-1 --auto --right-of eDP-1

# 左侧
xrandr --output HDMI-1 --auto --left-of eDP-1

# 上方
xrandr --output HDMI-1 --auto --above eDP-1

# 下方
xrandr --output HDMI-1 --auto --below eDP-1

feh --bg-fill ~/.config/i3/backgrounds/little.png
```

查看当前布局：

```bash
xrandr --query
xrandr --listmonitors
i3-msg -t get_workspaces
```

鼠标只能从两块屏幕的实际重叠边缘移动过去。例如外接屏在内屏正上方时，鼠标从内屏上边缘移动到外屏下边缘。两块屏幕分辨率不同时，重叠区域会以 `xrandr` 的实际坐标为边界。

关闭显示器后如果工作区卡在已拔出的屏幕上，监听脚本会自动执行：

```bash
xrandr --output HDMI-1 --off
```

## 锁屏和关闭屏幕

```bash
~/.local/bin/betterlockscreen -u ~/.config/i3/lock/ante.jpg -l -b 1 dim
~/.local/bin/screen_off
```

## 排查

```bash
i3 -C -c ~/.config/i3/config
bash -n ~/.config/i3/display-position/dual-display.sh
xrandr --query
```

如果拔掉外屏后工作区不可切换：

```bash
xrandr --output HDMI-1 --off
i3-msg reload
```
