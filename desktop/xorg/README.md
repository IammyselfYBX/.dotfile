# Xorg 配置

## 文件

| 文件 | 链接到 | 用途 |
| --- | --- | --- |
| `Xmodmap` | `~/.Xmodmap` | 交换 Caps Lock 和 Escape |
| `xprofile` | `~/.xprofile` | 设置 IBus 环境变量并启动输入法 |

## 依赖

Arch/Manjaro：

```bash
sudo pacman -S --needed xorg-server xorg-xinit xorg-xmodmap ibus
```

Ubuntu/Debian：

```bash
sudo apt install xorg xinit x11-xserver-utils ibus
```

## 关联

```bash
cd ~/.dotfile
./link.sh
```

## 应用

```bash
xmodmap ~/.Xmodmap
```

`~/.xprofile` 通常由显示管理器或 X 会话在登录时读取。修改后需要注销并重新登录。

## 验证

```bash
xmodmap -pke | grep -E 'Caps_Lock|Escape'
printenv GTK_IM_MODULE XMODIFIERS QT_IM_MODULE
```

## 注意

如果使用 Wayland 会话，`xmodmap` 和 `~/.xprofile` 不会按 Xorg 会话的方式生效。
