# desktop/gnome/doc 配置说明

> 本文档由 `dotctl` 的配置目录自动关联。
> 在 `dotctl` 中选中对应配置后按 `h` 查看本文档。

管理项：**Qt Creator 应用菜单启动器**

## 配置详情

### Desktop / Qt Creator 应用菜单启动器

Qt Creator 应用菜单启动器，安装到 ~/.local/share/applications。

- 安装方式：软链接
- 仓库源：`~/.dotfile/desktop/gnome/桌面图标/Qt_create.desktop`
- 家目录目标：`~/.local/share/applications/Qt_create.desktop`

**配置组成：**

- `~/.dotfile/desktop/gnome/桌面图标/Qt_create.desktop`

**依赖：**

- 命令 `qtcreator`（可选；Arch: `qtcreator`, Debian: `qtcreator`）
- 命令 `desktop-file-validate`（可选；Arch: `desktop-file-utils`, Debian: `desktop-file-utils`）
- 命令 `update-desktop-database`（可选；Arch: `desktop-file-utils`, Debian: `desktop-file-utils`）

**备注：** .desktop 中的 Qt Creator 路径需要与机器上的实际安装路径一致。

## 使用与管理

```bash
~/.dotfile/scripts/dotctl
```

在管理器中按 `Enter` 查看详情，按 `e` 编辑源文件，按 `h` 再次打开本说明。
详细依赖目录和包名维护在 `~/.dotfile/doc/catalog.json`。
