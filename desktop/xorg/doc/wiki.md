# desktop/xorg/doc 配置说明

> 本文档由 `dotctl` 的配置目录自动关联。
> 在 `dotctl` 中选中对应配置后按 `h` 查看本文档。

包含以下受管理配置：
- Xmodmap 键盘映射
- Xprofile 输入法环境
- Xresources 资源设置
- xinitrc
- xsession
- feh 壁纸脚本
- modmap
- Xclients

## 配置详情

### Xorg / Xmodmap 键盘映射

X11 键盘映射，当前主要用于交换 Caps Lock 与 Escape。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/xorg/Xmodmap`
- 家目录目标：`~/.Xmodmap`

**配置组成：**

- `~/.dotfile/desktop/xorg/Xmodmap`

**依赖：**

- 命令 `xmodmap`（必需；Arch: `xorg-xmodmap`, Debian: `x11-xserver-utils`）

### Xorg / Xprofile 输入法环境

X 会话启动时的输入法环境变量，并启动 IBus。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/xorg/xprofile`
- 家目录目标：`~/.xprofile`

**配置组成：**

- `~/.dotfile/desktop/xorg/xprofile`

**依赖：**

- 命令 `ibus-daemon`（必需；Arch: `ibus`, Debian: `ibus`）
- 命令 `xmodmap`（必需；Arch: `xorg-xmodmap`, Debian: `x11-xserver-utils`）

### Xorg / Xresources 资源设置

X11 资源设置，例如 Xft DPI。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/xorg/Xresources`
- 家目录目标：`~/.Xresources`

**配置组成：**

- `~/.dotfile/desktop/xorg/Xresources`

**依赖：**

- 命令 `xrdb`（必需；Arch: `xorg-xrdb`, Debian: `x11-xserver-utils`）

### Xorg / xinitrc

startx 启动脚本，加载 Xresources/Xmodmap 并启动桌面会话。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/xorg/xinitrc`
- 家目录目标：`~/.xinitrc`

**配置组成：**

- `~/.dotfile/desktop/xorg/xinitrc`

**依赖：**

- 命令 `xrdb`（必需；Arch: `xorg-xrdb`, Debian: `x11-xserver-utils`）
- 命令 `xmodmap`（必需；Arch: `xorg-xmodmap`, Debian: `x11-xserver-utils`）

### Xorg / xsession

X 会话入口，当前启动 GNOME Session。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/xorg/xsession`
- 家目录目标：`~/.xsession`

**配置组成：**

- `~/.dotfile/desktop/xorg/xsession`

**依赖：**

- 命令 `gnome-session`（必需；Arch: `gnome-session`, Debian: `gnome-session`）

### Xorg / feh 壁纸脚本

使用 feh 设置桌面壁纸，图片来自 assets/wallpapers。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/xorg/fehbg`
- 家目录目标：`~/.fehbg`

**配置组成：**

- `~/.dotfile/desktop/xorg/fehbg`
- `~/.dotfile/assets/wallpapers/desktop-wallpaper.png`

**依赖：**

- 命令 `feh`（必需；Arch: `feh`, Debian: `feh`）

### Xorg / modmap

额外的键盘映射配置。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/xorg/modmap`
- 家目录目标：`~/.modmap`

**配置组成：**

- `~/.dotfile/desktop/xorg/modmap`

**依赖：**

- 命令 `xmodmap`（必需；Arch: `xorg-xmodmap`, Debian: `x11-xserver-utils`）

### Xorg / Xclients

XDM/GDM/KDM 登录时启动 xinitrc 的包装脚本。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/xorg/Xclients`
- 家目录目标：`~/.Xclients`

**配置组成：**

- `~/.dotfile/desktop/xorg/Xclients`

**依赖：**

- 命令 `bash`（必需；Arch: `bash`, Debian: `bash`）

## 使用与管理

```bash
~/.dotfile/scripts/dotctl
```

在管理器中按 `Enter` 查看详情，按 `e` 编辑源文件，按 `h` 再次打开本说明。
详细依赖目录和包名维护在 `~/.dotfile/doc/catalog.json`。
