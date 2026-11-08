# editors/vscode/doc 配置说明

> 本文档由 `dotctl` 的配置目录自动关联。
> 在 `dotctl` 中选中对应配置后按 `h` 查看本文档。

包含以下受管理配置：
- VS Code 设置
- VS Code snippets

## 配置详情

### Editor / VS Code 设置

VS Code 用户设置。

- 安装方式：软链接
- 仓库源：`~/.dotfile/editors/vscode/settings.json`
- 家目录目标：`~/.config/Code/User/settings.json`

**配置组成：**

- `~/.dotfile/editors/vscode/settings.json`

**依赖：**

- 命令 `code`（可选；Arch: `code`, Debian: `code`）

**关联管理项：**

- VS Code snippets

**备注：** 只管理设置文件，不管理 VS Code 的 History、workspaceStorage 和 globalStorage。

### Editor / VS Code snippets

VS Code 自定义代码片段。

- 安装方式：软链接
- 仓库源：`~/.dotfile/editors/vscode/snippets`
- 家目录目标：`~/.config/Code/User/snippets`

**配置组成：**

- `~/.dotfile/editors/vscode/snippets`

**依赖：**

- 命令 `code`（可选；Arch: `code`, Debian: `code`）

**关联管理项：**

- VS Code 设置

## 使用与管理

```bash
~/.dotfile/scripts/dotctl
```

在管理器中按 `Enter` 查看详情，按 `e` 编辑源文件，按 `h` 再次打开本说明。
详细依赖目录和包名维护在 `~/.dotfile/doc/catalog.json`。
