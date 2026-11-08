# desktop/i3/doc 配置说明

> 本文档由 `dotctl` 的配置目录自动关联。
> 在 `dotctl` 中选中对应配置后按 `h` 查看本文档。

包含以下受管理配置：
- i3 窗口管理器
- screen_off 命令
- betterlockscreen 命令
- 锁屏命令
- 显示器位置命令

## 配置详情

### Desktop / i3 窗口管理器

i3 窗口管理器主配置，包含快捷键、Polybar 启动、截图、锁屏、触控板和显示器位置处理。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/i3`
- 家目录目标：`~/.config/i3`

**配置组成：**

- `~/.dotfile/desktop/i3/config`
- `~/.dotfile/desktop/i3/brightness`
- `~/.dotfile/desktop/i3/display-position`
- `~/.dotfile/desktop/i3/lock`
- `~/.dotfile/desktop/i3/screenshot`
- `~/.dotfile/desktop/i3/scripts`

**依赖：**

- 命令 `i3`（必需；Arch: `i3-wm`, Debian: `i3-wm`）
- 命令 `i3-msg`（必需；Arch: `i3-wm`, Debian: `i3-wm`）
- 命令 `feh`（必需；Arch: `feh`, Debian: `feh`）
- 命令 `polybar`（必需；Arch: `polybar`, Debian: `polybar`）
- 命令 `alacritty`（必需；Arch: `alacritty`, Debian: `alacritty`）
- 命令 `dmenu`（可选；Arch: `dmenu`, Debian: `dmenu`）
- 命令 `xmodmap`（必需；Arch: `xorg-xmodmap`, Debian: `x11-xserver-utils`）
- 命令 `xset`（必需；Arch: `xorg-xset`, Debian: `x11-xserver-utils`）
- 命令 `xinput`（必需；Arch: `xorg-xinput`, Debian: `xinput`）
- 命令 `scrot`（必需；Arch: `scrot`, Debian: `scrot`）
- 命令 `xclip`（必需；Arch: `xclip`, Debian: `xclip`）
- 命令 `convert`（必需；Arch: `imagemagick`, Debian: `imagemagick`）
- 命令 `bc`（必需；Arch: `bc`, Debian: `bc`）
- 命令 `chromium`（可选；Arch: `chromium`, Debian: `chromium`）
- 命令 `ranger`（必需；Arch: `ranger`, Debian: `ranger`）
- 命令 `i3lock`（必需；Arch: `i3lock`, Debian: `i3lock`）
- 命令 `xrandr`（必需；Arch: `xorg-xrandr`, Debian: `x11-xserver-utils`）
- 命令 `xbacklight`（可选；Arch: `xorg-xbacklight`, Debian: `xbacklight`）
- 命令 `ibus-daemon`（必需；Arch: `ibus`, Debian: `ibus`）

**关联管理项：**

- screen_off 命令
- betterlockscreen 命令
- 锁屏命令
- 显示器位置命令

**备注：** i3 本身不绘制 GTK 桌面图标；Ranger/终端中的 Nerd Font 图标由字体提供。

### i3 Tools / screen_off 命令

立即关闭屏幕的 i3 辅助命令。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/i3/brightness/screen_off.sh`
- 家目录目标：`~/.local/bin/screen_off`

**配置组成：**

- `~/.dotfile/desktop/i3/brightness/screen_off.sh`

**依赖：**

- 命令 `xset`（必需；Arch: `xorg-xset`, Debian: `x11-xserver-utils`）

### i3 Tools / betterlockscreen 命令

基于 i3lock 的锁屏辅助脚本。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/i3/lock/betterlockscreen`
- 家目录目标：`~/.local/bin/betterlockscreen`

**配置组成：**

- `~/.dotfile/desktop/i3/lock/betterlockscreen`

**依赖：**

- 命令 `i3lock`（必需；Arch: `i3lock`, Debian: `i3lock`）
- 命令 `convert`（必需；Arch: `imagemagick`, Debian: `imagemagick`）
- 命令 `bc`（必需；Arch: `bc`, Debian: `bc`）
- 命令 `xrandr`（必需；Arch: `xorg-xrandr`, Debian: `x11-xserver-utils`）
- 命令 `xset`（必需；Arch: `xorg-xset`, Debian: `x11-xserver-utils`）

### i3 Tools / 锁屏命令

使用锁屏壁纸和 i3lock 的锁屏命令。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/i3/lock/lock-screen.sh`
- 家目录目标：`~/.local/bin/lock-screen`

**配置组成：**

- `~/.dotfile/desktop/i3/lock/lock-screen.sh`
- `~/.dotfile/assets/wallpapers/lockscreen-wallpaper.png`

**依赖：**

- 命令 `i3lock`（必需；Arch: `i3lock`, Debian: `i3lock`）
- 命令 `xset`（必需；Arch: `xorg-xset`, Debian: `x11-xserver-utils`）

### i3 Tools / 显示器位置命令

切换 HDMI 显示器相对位置的 i3 命令，并持久化配置。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/i3/display-position/i3-display-position`
- 家目录目标：`~/.local/bin/i3-display-position`

**配置组成：**

- `~/.dotfile/desktop/i3/display-position/i3-display-position`
- `~/.dotfile/desktop/i3/display-position/dual-display.sh`
- `~/.dotfile/desktop/i3/display-position/dual-display.conf`

**依赖：**

- 命令 `xrandr`（必需；Arch: `xorg-xrandr`, Debian: `x11-xserver-utils`）
- 命令 `i3-msg`（必需；Arch: `i3-wm`, Debian: `i3-wm`）
- 命令 `dmenu`（可选；Arch: `dmenu`, Debian: `dmenu`）
- 命令 `awk`（必需；Arch: `gawk`, Debian: `gawk`）
- 命令 `flock`（必需；Arch: `util-linux`, Debian: `util-linux`）
- 命令 `pkill`（必需；Arch: `procps-ng`, Debian: `procps`）


## 启动与运行行为

当前 i3 使用 `Mod4`，即键盘上的 Super/Windows 键，本文后续简写为 `Mod`。

启动时会执行：

- `xset s off; xset -dpms`：关闭 X11 自动熄屏和自动 DPMS。
- 启动 `nm-applet` 网络托盘。
- 运行 `display-position/dual-display.sh` 处理外接显示器和热插拔。
- 使用 `xmodmap ~/.Xmodmap` 应用 Caps Lock / Escape 交换。
- 启动 IBus 输入法。
- 运行 `scripts/touchpad-settings.sh` 应用触控板设置。
- 运行 `~/.config/polybar/launch.sh` 启动 Polybar。
- 窗口间距为 12px，普通窗口边框为 1px。

注意：i3 不会自动锁屏或自动熄屏。锁屏需要手动按 `Mod+L`，关闭屏幕按 `Ctrl+Shift+L`。

## 完整快捷键

### 应用与命令

| 快捷键 | 动作 |
|---|---|
| `Mod+Return` | 打开 WezTerm |
| `Mod+Shift+Return` | 打开 Alacritty |
| `Mod+D` | 使用 `dmenu_run` 启动应用 |
| `Mod+C` | 打开 Chromium |
| `Mod+Shift+T` | 在 Alacritty 中打开 Ranger |
| `Mod+Shift+D` | 打开显示器位置菜单 `i3-display-position` |

### i3 会话与窗口

| 快捷键 | 动作 |
|---|---|
| `Mod+Shift+Q` | 关闭当前窗口 |
| `Mod+Shift+C` | 重新加载 i3 配置 |
| `Mod+Shift+R` | 通过 `exec i3 reload` 重新加载配置 |
| `Mod+Shift+E` | 显示退出 i3 的确认窗口 |
| `Mod+Shift+Space` | 当前窗口在平铺/浮动之间切换 |
| `Mod+Space` | 在平铺窗口和浮动窗口之间切换焦点 |
| `Mod+A` | 聚焦父容器 |
| `Mod+Shift+Minus` | 将当前窗口移动到 scratchpad |
| `Mod+Minus` | 显示 scratchpad 窗口 |
| `Mod+鼠标拖动` | 移动浮动窗口 |

### 焦点切换

| 快捷键 | 动作 |
|---|---|
| `Mod+H` | 聚焦左边窗口 |
| `Mod+J` | 聚焦下边窗口 |
| `Mod+K` | 聚焦上边窗口 |
| `Mod+;` | 聚焦右边窗口 |
| `Mod+Left` | 聚焦左边窗口 |
| `Mod+Down` | 聚焦下边窗口 |
| `Mod+Up` | 聚焦上边窗口 |
| `Mod+Right` | 聚焦右边窗口 |

### 移动窗口

| 快捷键 | 动作 |
|---|---|
| `Mod+Shift+H` | 将窗口向左移动 |
| `Mod+Shift+J` | 将窗口向左移动 |
| `Mod+Shift+K` | 将窗口向下移动 |
| `Mod+Shift+L` | 将窗口向上移动 |
| `Mod+Shift+;` | 将窗口向右移动 |
| `Mod+Shift+Left` | 将窗口向左移动 |
| `Mod+Shift+Down` | 将窗口向下移动 |
| `Mod+Shift+Up` | 将窗口向上移动 |
| `Mod+Shift+Right` | 将窗口向右移动 |

当前配置里焦点键和移动键的 `j/k` 语义并不完全对称：焦点使用 `j=下、k=上`，移动使用 `Mod+Shift+J=左、Mod+Shift+K=下`。这是当前配置文件的实际行为。

### 布局与分屏

| 快捷键 | 动作 |
|---|---|
| `Mod+Shift+H` | 水平分屏 |
| `Mod+V` | 垂直分屏 |
| `Mod+F` | 切换当前窗口全屏 |
| `Mod+S` | 切换为堆叠布局 |
| `Mod+W` | 切换为标签页布局 |
| `Mod+E` | 在分屏布局之间切换 |

### 工作区

| 快捷键 | 动作 |
|---|---|
| `Mod+1` 到 `Mod+9` | 切换到工作区 1–9 |
| `Mod+0` | 切换到工作区 10 |
| `Mod+Shift+1` 到 `Mod+Shift+9` | 将当前窗口移动到工作区 1–9 |
| `Mod+Shift+0` | 将当前窗口移动到工作区 10 |

### 调整窗口大小模式

按 `Mod+R` 进入 resize 模式。

| resize 模式快捷键 | 动作 |
|---|---|
| `J` | 减小宽度 |
| `K` | 增加高度 |
| `L` | 减小高度 |
| `;` | 增加宽度 |
| `Left` | 减小宽度 |
| `Down` | 增加高度 |
| `Up` | 减小高度 |
| `Right` | 增加宽度 |
| `Return` | 返回默认模式 |
| `Caps_Lock` | 返回默认模式 |
| `Mod+R` | 返回默认模式 |

### 截图

| 快捷键 | 动作 |
|---|---|
| `Print` | 截取整个屏幕并保存到 `~/Pictures` |
| `Mod+Shift+Print` | 截取当前窗口并保存 |
| `Mod+Print` | 鼠标选择区域并保存到 `~/Pictures` |
| `Mod+Shift+S` | 鼠标选择区域，仅复制到剪贴板，不保存文件 |

### 锁屏、亮度和声音

| 快捷键 | 动作 |
|---|---|
| `Mod+L` | 使用 `lock-screen.sh` 锁定屏幕 |
| `Ctrl+Shift+L` | 立即关闭屏幕 |
| `XF86MonBrightnessUp` | 屏幕亮度增加 10 |
| `XF86MonBrightnessDown` | 屏幕亮度减少 10 |
| `XF86AudioRaiseVolume` | 主音量增加 |
| `XF86AudioLowerVolume` | 主音量减少 |
| `XF86AudioMute` | 切换静音 |

### 常用验证命令

```bash
# 检查 i3 配置语法
i3 -C -c ~/.config/i3/config

# 重新加载配置
i3-msg reload

# 查看当前显示器
xrandr --query

# 查看当前工作区
i3-msg -t get_workspaces
```

## 配套命令

i3 配置会使用以下由 `dotctl` 统一管理的命令：

```text
~/.local/bin/screen_off
~/.local/bin/betterlockscreen
~/.local/bin/lock-screen
~/.local/bin/i3-display-position
```

执行：

```bash
~/.dotfile/scripts/dotctl
```

选中 i3 主配置后：

- `e`：编辑 `desktop/i3/config`
- `h`：打开本 wiki
- `d`：查看当前差异
- `i`：安装或合并
- `o`：备份并覆盖


## 使用与管理

```bash
~/.dotfile/scripts/dotctl
```

在管理器中按 `Enter` 查看详情，按 `e` 编辑源文件，按 `h` 再次打开本说明。
详细依赖目录和包名维护在 `~/.dotfile/doc/catalog.json`。
