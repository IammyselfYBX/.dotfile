# assets/fonts/JetBrainsMono/doc 配置说明

> 本文档由 `dotctl` 的配置目录自动关联。
> 在 `dotctl` 中选中对应配置后按 `h` 查看本文档。

管理项：**字体 · JetBrainsMono**

## 配置详情

### Fonts / 字体 · JetBrainsMono

共享 JetBrainsMono Nerd Font，供 WezTerm、Ranger 等使用。

- 安装方式：软链接
- 仓库源：`~/.dotfile/assets/fonts/JetBrainsMono`
- 家目录目标：`~/.local/share/fonts/JetBrainsMono`

**配置组成：**

- `~/.dotfile/assets/fonts/JetBrainsMono/JetBrainsMonoNerdFontMono-Regular.ttf`

**依赖：**

- 命令 `fc-cache`（必需；Arch: `fontconfig`, Debian: `fontconfig`）
- 命令 `fc-match`（必需；Arch: `fontconfig`, Debian: `fontconfig`）

## 使用与管理

```bash
~/.dotfile/scripts/dotctl
```

在管理器中按 `Enter` 查看详情，按 `e` 编辑源文件，按 `h` 再次打开本说明。
详细依赖目录和包名维护在 `~/.dotfile/doc/catalog.json`。
