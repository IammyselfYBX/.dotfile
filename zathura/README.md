# Zathura 配置

`zathurarc` 通过 `link.sh` 链接到 `~/.config/zathura/zathurarc`。

## 依赖

Arch/Manjaro：

```bash
sudo pacman -S --needed zathura zathura-pdf-mupdf
```

Ubuntu/Debian：

```bash
sudo apt install zathura
```

## 关联

```bash
cd ~/.dotfile
./link.sh
```

## 配置内容

- 深色阅读界面
- 自动重着色
- 窗口默认宽度 800、高度 1000
- 选中文本复制到系统剪贴板

## 验证

```bash
zathura --version
```

打开 PDF：

```bash
zathura document.pdf
```

常用操作：

| 按键 | 功能 |
| --- | --- |
| `Ctrl+O` | 打开文件 |
| `J` / `K` | 向下 / 向上滚动 |
| `R` | 旋转页面 |
| `/` | 搜索 |
| `Ctrl+C` | 复制选中文本 |
