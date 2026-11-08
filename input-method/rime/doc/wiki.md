# input-method/rime/doc 配置说明

> 本文档由 `dotctl` 的配置目录自动关联。
> 在 `dotctl` 中选中对应配置后按 `h` 查看本文档。

管理项：**Rime 输入法**

## 配置详情

### Input / Rime 输入法

IBus Rime 输入法配置、词典和配色。

- 安装方式：软链接
- 仓库源：`~/.dotfile/input-method/rime`
- 家目录目标：`~/.config/ibus/rime`

**配置组成：**

- `~/.dotfile/input-method/rime/default.custom.yaml`
- `~/.dotfile/input-method/rime/luna_pinyin.custom.yaml`
- `~/.dotfile/input-method/rime/wubi86_jidian`
- `~/.dotfile/input-method/rime/color_schemes`

**依赖：**

- 命令 `ibus`（必需；Arch: `ibus`, Debian: `ibus`）
- 命令 `ibus-daemon`（必需；Arch: `ibus`, Debian: `ibus`）

**备注：** 需要系统安装 ibus-rime；运行数据 build、sync 和 userdb 已排除出版本控制。

## 使用与管理

```bash
~/.dotfile/scripts/dotctl
```

在管理器中按 `Enter` 查看详情，按 `e` 编辑源文件，按 `h` 再次打开本说明。
详细依赖目录和包名维护在 `~/.dotfile/doc/catalog.json`。
