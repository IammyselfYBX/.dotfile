# Ranger 配置

本目录通过 `link.sh` 链接到 `~/.config/ranger`。

## 功能

- 图片和视频缩略图
- 目录预览
- Devicons 图标
- 自定义快捷键

## 依赖

Arch/Manjaro：

```bash
sudo pacman -S --needed ranger imagemagick ffmpegthumbnailer perl-image-exiftool
```

图片预览使用 `ueberzug`。如果仓库中没有对应包，可安装 AUR 提供的 `ueberzug`，或改用 `ueberzugpp` 并调整 `rc.conf` 中的 `preview_images_method`。

Ubuntu/Debian：

```bash
sudo apt install ranger imagemagick ffmpegthumbnailer exiftool
```

## 关联

```bash
cd ~/.dotfile
./link.sh
chmod +x ~/.config/ranger/scope.sh
```

## 验证

```bash
ranger --version
~/.config/ranger/scope.sh --help
```

启动：

```bash
ranger
```

## 注意

`__pycache__/` 属于运行时生成文件，已经加入 `.gitignore`，不会提交到仓库。
