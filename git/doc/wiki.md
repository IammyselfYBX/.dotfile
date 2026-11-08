# git/doc 配置说明

> 本文档由 `dotctl` 的配置目录自动关联。
> 在 `dotctl` 中选中对应配置后按 `h` 查看本文档。

管理项：**全局 Git include**

## 配置详情

### Git / 全局 Git include

全局 Git include 配置，通过 .gitconfig 的 include 块接入。

- 安装方式：Git include
- 仓库源：`~/.dotfile/git/gitconfig`
- 家目录目标：`~/.gitconfig`

**配置组成：**

- `~/.dotfile/git/gitconfig`

**依赖：**

- 命令 `git`（必需；Arch: `git`, Debian: `git`）
- 命令 `git-lfs`（可选；Arch: `git-lfs`, Debian: `git-lfs`）

**备注：** 机器专属用户名、邮箱和代理可以继续保留在 ~/.gitconfig。

## 使用与管理

```bash
~/.dotfile/scripts/dotctl
```

在管理器中按 `Enter` 查看详情，按 `e` 编辑源文件，按 `h` 再次打开本说明。
详细依赖目录和包名维护在 `~/.dotfile/doc/catalog.json`。
