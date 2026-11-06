# latexmk / LaTeX 配置

## 文件

| 文件 | 用途 |
| --- | --- |
| `latexmkrc` | 默认使用 XeLaTeX，编译输出到 `Build/`，编译后调用 Zathura 预览 |
| `texcheck.sh` | 对 `main.tex` 做语法检查 |

`link.sh` 会把 `latexmkrc` 链接到 `~/.latexmkrc`。

## 依赖

Arch/Manjaro：

```bash
sudo pacman -S --needed texlive-core texlive-latexextra texlive-fontsextra \
  texlive-langchinese latexmk zathura zathura-pdf-mupdf
```

Ubuntu/Debian：

```bash
sudo apt install texlive-full latexmk zathura
```

如果使用 TeX Live 官方安装包，请确保 `latexmk`、`xelatex` 和 `biber` 位于 `PATH` 中。

## 关联

```bash
cd ~/.dotfile
./link.sh
```

## 验证

```bash
latexmk -v
xelatex -v
python3 -c 'print(open("$HOME/.latexmkrc").read().count("$pdf_mode=5"))'
```

## 使用

```bash
latexmk main.tex
latexmk -pvc main.tex
latexmk -c
latexmk -C
```

语法检查：

```bash
bash ~/.dotfile/latexmk/texcheck.sh
```

`texcheck.sh` 默认检查当前目录下的 `main.tex`。
