# Alacritty 配置

`alacritty.toml` 是当前唯一使用的配置，通过 `link.sh` 链接到 `~/.config/alacritty`。

## 依赖

Arch/Manjaro：

```bash
sudo pacman -S --needed alacritty ttf-hack ttf-firacode-nerd ttf-source-code-pro
```

Ubuntu/Debian：

```bash
sudo apt install alacritty fonts-firacode fonts-hack
```

配置中使用的字体包括：

- Hack
- FiraCode Nerd Font
- Source Code Pro

缺少字体时 Alacritty 会自动回退，但显示效果会不同。

## 关联

```bash
cd ~/.dotfile
./link.sh
```

## 验证

```bash
python3 -c 'import tomllib; tomllib.load(open("$HOME/.config/alacritty/alacritty.toml", "rb"))'
alacritty --version
```

修改后重新打开终端，或发送配置重载：

```bash
alacritty msg config
```

## 说明

旧版 `alacritty.yml` 和带年份的 TOML 备份已经删除，避免仓库中出现多个互相冲突的配置入口。
