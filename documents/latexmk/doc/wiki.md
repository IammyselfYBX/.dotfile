# documents/latexmk/doc 配置说明

> 本文档由 `dotctl` 的配置目录自动关联。
> 在 `dotctl` 中选中对应配置后按 `h` 查看本文档。

管理项：**latexmk**

## 配置详情

### Documents / latexmk

LaTeX 编译和语法检查配置。

- 安装方式：软链接
- 仓库源：`~/.dotfile/documents/latexmk/latexmkrc`
- 家目录目标：`~/.latexmkrc`

**配置组成：**

- `~/.dotfile/documents/latexmk/latexmkrc`
- `~/.dotfile/documents/latexmk/texcheck.sh`

**依赖：**

- 命令 `latexmk`（必需；Arch: `texlive-core`, Debian: `latexmk`）
- 命令 `pdflatex`（必需；Arch: `texlive-core`, Debian: `texlive-latex-base`）
- 命令 `xelatex`（可选；Arch: `texlive-xetex`, Debian: `texlive-xetex`）
- 命令 `chktex`（可选；Arch: `chktex`, Debian: `chktex`）

## 使用与管理

```bash
~/.dotfile/scripts/dotctl
```

在管理器中按 `Enter` 查看详情，按 `e` 编辑源文件，按 `h` 再次打开本说明。
详细依赖目录和包名维护在 `~/.dotfile/doc/catalog.json`。
