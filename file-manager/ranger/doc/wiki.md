# file-manager/ranger/doc 配置说明

> 本文档由 `dotctl` 的配置目录自动关联。
> 在 `dotctl` 中选中对应配置后按 `h` 查看本文档。

管理项：**Ranger 文件管理器**

## 配置详情

### Files / Ranger 文件管理器

Ranger 文件管理器配置、预览脚本和 devicons 插件。

- 安装方式：软链接
- 仓库源：`~/.dotfile/file-manager/ranger`
- 家目录目标：`~/.config/ranger`

**配置组成：**

- `~/.dotfile/file-manager/ranger/rc.conf`
- `~/.dotfile/file-manager/ranger/scope.sh`
- `~/.dotfile/file-manager/ranger/commands.py`
- `~/.dotfile/file-manager/ranger/plugins`

**依赖：**

- 命令 `ranger`（必需；Arch: `ranger`, Debian: `ranger`）
- 命令 `python3`（必需；Arch: `python`, Debian: `python3`）
- 命令 `file`（必需；Arch: `file`, Debian: `file`）
- 命令 `w3m`（可选；Arch: `w3m`, Debian: `w3m`）
- 命令 `pdftoppm`（可选；Arch: `poppler`, Debian: `poppler-utils`）
- 命令 `convert`（可选；Arch: `imagemagick`, Debian: `imagemagick`）
- 命令 `ffmpegthumbnailer`（可选；Arch: `ffmpegthumbnailer`, Debian: `ffmpegthumbnailer`）
- 命令 `chafa`（可选；Arch: `chafa`, Debian: `chafa`）
- 命令 `bat`（可选；Arch: `bat`, Debian: `bat`）
- 命令 `highlight`（可选；Arch: `highlight`, Debian: `highlight`）
- 命令 `atool`（可选；Arch: `atool`, Debian: `atool`）
- 命令 `unrar`（可选；Arch: `unrar`, Debian: `unrar`）
- 命令 `7z`（可选；Arch: `p7zip`, Debian: `p7zip-full`）
- 命令 `mediainfo`（可选；Arch: `mediainfo`, Debian: `mediainfo`）
- 字体 `JetBrainsMono Nerd Font Mono`（必需）

**关联管理项：**

- 字体 · JetBrainsMono

**备注：** devicons 和终端图标依赖 Nerd Font；预览工具缺失时 Ranger 仍可用，但部分预览不可用。

## 使用与管理

```bash
~/.dotfile/scripts/dotctl
```

在管理器中按 `Enter` 查看详情，按 `e` 编辑源文件，按 `h` 再次打开本说明。
详细依赖目录和包名维护在 `~/.dotfile/doc/catalog.json`。
