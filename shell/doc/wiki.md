# shell/doc 配置说明

> 本文档由 `dotctl` 的配置目录自动关联。
> 在 `dotctl` 中选中对应配置后按 `h` 查看本文档。

包含以下受管理配置：
- 终端目录配色
- Bash logout
- Bash .bashrc
- Bash .bash_profile
- POSIX .profile

## 配置详情

### Shell / 终端目录配色

终端 ls/dircolors 配色定义。

- 安装方式：软链接
- 仓库源：`~/.dotfile/shell/dir_colors`
- 家目录目标：`~/.dir_colors`

**配置组成：**

- `~/.dotfile/shell/dir_colors`

**依赖：**

- 命令 `dircolors`（可选；Arch: `coreutils`, Debian: `coreutils`）

### Shell / Bash logout

Bash 登录 shell 退出时执行的配置。

- 安装方式：软链接
- 仓库源：`~/.dotfile/shell/bash_logout`
- 家目录目标：`~/.bash_logout`

**配置组成：**

- `~/.dotfile/shell/bash_logout`

**依赖：**

- 命令 `bash`（必需；Arch: `bash`, Debian: `bash`）

### Shell / Bash .bashrc

Bash 交互式配置。现有 .bashrc 通过受管理 source 块接入，不直接覆盖发行版默认文件。

- 安装方式：Shell source 集成
- 仓库源：`~/.dotfile/shell/bashrc`
- 家目录目标：`~/.bashrc`

**配置组成：**

- `~/.dotfile/shell/bashrc`

**依赖：**

- 命令 `bash`（必需；Arch: `bash`, Debian: `bash`）

### Shell / Bash .bash_profile

Bash 登录配置。现有 .bash_profile 通过受管理 source 块接入。

- 安装方式：Shell source 集成
- 仓库源：`~/.dotfile/shell/bash_profile`
- 家目录目标：`~/.bash_profile`

**配置组成：**

- `~/.dotfile/shell/bash_profile`

**依赖：**

- 命令 `bash`（必需；Arch: `bash`, Debian: `bash`）

### Shell / POSIX .profile

POSIX 登录配置。现有 .profile 通过受管理 source 块接入。

- 安装方式：Shell source 集成
- 仓库源：`~/.dotfile/shell/profile`
- 家目录目标：`~/.profile`

**配置组成：**

- `~/.dotfile/shell/profile`

**依赖：**

- 命令 `bash`（必需；Arch: `bash`, Debian: `bash`）

## 使用与管理

```bash
~/.dotfile/scripts/dotctl
```

在管理器中按 `Enter` 查看详情，按 `e` 编辑源文件，按 `h` 再次打开本说明。
详细依赖目录和包名维护在 `~/.dotfile/doc/catalog.json`。
