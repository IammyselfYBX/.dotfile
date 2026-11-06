# Compton 配置

`compton` 是窗口合成器配置，通过 `link.sh` 链接到 `~/.config/compton/compton`。

## 依赖

Arch/Manjaro：

```bash
sudo pacman -S --needed compton
```

如果系统已经使用 Picom：

```bash
sudo pacman -S --needed picom
```

Ubuntu/Debian：

```bash
sudo apt install compton
```

## 关联

```bash
cd ~/.dotfile
./link.sh
```

## 启用

i3 配置中的 Compton 启动行默认被注释。确认显卡和驱动工作正常后，在 `i3/config` 中启用：

```text
exec --no-startup-id compton --config ~/.config/compton/compton
```

应用：

```bash
pkill compton 2>/dev/null || true
compton --config ~/.config/compton/compton --daemon
```

使用 Picom 时：

```bash
picom --config ~/.config/compton/compton --daemon
```

## 验证

```bash
compton --config ~/.config/compton/compton --diagnostics
```

不同 Compton/Picom 版本支持的选项可能不同，出现启动错误时先检查版本：

```bash
compton --version
picom --version
```
