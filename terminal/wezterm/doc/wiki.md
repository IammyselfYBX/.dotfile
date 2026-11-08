# terminal/wezterm/doc 配置说明

> 本文档由 `dotctl` 的配置目录自动关联。
> 在 `dotctl` 中选中对应配置后按 `h` 查看本文档。

管理项：**WezTerm**

## 配置详情

### Terminal / WezTerm

WezTerm 跨平台终端配置，保留 docs、examples 和 scripts。

- 安装方式：软链接
- 仓库源：`~/.dotfile/terminal/wezterm`
- 家目录目标：`~/.config/wezterm`

**配置组成：**

- `~/.dotfile/terminal/wezterm/wezterm.lua`
- `~/.dotfile/terminal/wezterm/utils`
- `~/.dotfile/terminal/wezterm/docs`
- `~/.dotfile/terminal/wezterm/examples`
- `~/.dotfile/terminal/wezterm/scripts`

**依赖：**

- 命令 `wezterm`（必需；Arch: `wezterm`, Debian: `wezterm`）
- 命令 `mdcat`（可选）
- 字体 `JetBrainsMono Nerd Font Mono`（必需）

**关联管理项：**

- 字体 · JetBrainsMono

**备注：** 字体从 assets/fonts/JetBrainsMono 加载；mdcat 仅用于终端图片/Markdown 辅助。

## 使用与管理

```bash
~/.dotfile/scripts/dotctl
```

在管理器中按 `Enter` 查看详情，按 `e` 编辑源文件，按 `h` 再次打开本说明。
详细依赖目录和包名维护在 `~/.dotfile/doc/catalog.json`。
