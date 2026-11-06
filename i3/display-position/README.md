# 外接屏位置切换

这个目录包含完整的 i3 外接屏位置管理功能，可以单独复制到其他电脑使用。

## 文件

| 文件 | 用途 |
| --- | --- |
| `i3-display-position` | 命令行和 dmenu 切换工具 |
| `dual-display.sh` | 监听 HDMI 插拔并自动应用位置 |
| `dual-display.conf` | 显示器名称和位置配置 |
| `install.sh` | 把命令安装到 `~/.local/bin` |

## 依赖

Arch/Manjaro：

```bash
sudo pacman -S --needed i3-wm xorg-xrandr feh dmenu
```

Ubuntu/Debian：

```bash
sudo apt install i3-wm x11-xserver-utils feh dmenu
```

脚本还使用 `awk`、`flock`、`mktemp`、`pkill` 和 `i3-msg`，这些通常已随系统安装。

## 安装

```bash
cd ~/.config/i3/display-position
./install.sh
```

确认 `~/.local/bin` 在 `PATH` 中：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

也可以在 `~/.dotfile/i3/` 中统一安装 i3 辅助命令：

```bash
~/.dotfile/i3/install.sh
```

## i3 启动配置

`i3/config` 中需要保留：

```text
exec_always --no-startup-id $HOME/.config/i3/display-position/dual-display.sh
```

修改后执行：

```bash
i3-msg reload
```

## 显示器名称

先查看当前输出名称：

```bash
xrandr --query
xrandr --listmonitors
```

然后编辑 `dual-display.conf`：

```bash
INTERNAL_OUTPUT="eDP-1"
EXTERNAL_OUTPUT="HDMI-1"
EXTERNAL_POSITION="above"
```

`INTERNAL_OUTPUT` 和 `EXTERNAL_OUTPUT` 必须改成目标电脑上的实际名称。例如有些电脑使用 `eDP-1`、`HDMI-1`，也可能使用 `eDP-1`、`DP-1`。

## 使用方法

```bash
i3-display-position above
i3-display-position right
i3-display-position left
i3-display-position below
```

不带参数会打开 dmenu：

```bash
i3-display-position
```

其他命令：

```bash
i3-display-position status  # 查看配置和 XRandR 坐标
i3-display-position cycle   # right -> above -> left -> below 轮换
i3-display-position apply   # 重新应用当前配置
```

i3 快捷键：

```text
Mod + Shift + D
```

## 位置和鼠标移动

| 配置值 | 外接屏位置 | 鼠标进入方向 |
| --- | --- | --- |
| `above` | 内屏上方 | 从内屏上边缘进入 |
| `right` | 内屏右侧 | 从内屏右边缘进入 |
| `left` | 内屏左侧 | 从内屏左边缘进入 |
| `below` | 内屏下方 | 从内屏下边缘进入 |

修改位置后会立即写入配置并应用，不需要注销。

## 复制到其他电脑

把整个 `display-position/` 目录复制到目标电脑的：

```text
~/.config/i3/display-position/
```

然后修改 `dual-display.conf` 中的输出名称，并运行：

```bash
chmod +x ~/.config/i3/display-position/i3-display-position \
  ~/.config/i3/display-position/dual-display.sh
~/.config/i3/display-position/install.sh
```

## 排查

```bash
xrandr --query
xrandr --listmonitors
i3-msg -t get_outputs
pgrep -af dual-display.sh
bash -n ~/.config/i3/display-position/dual-display.sh
```

如果显示器名称错误，脚本不会修改布局，但会将位置保存到配置文件。
