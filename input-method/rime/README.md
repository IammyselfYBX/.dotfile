# IBus Rime 配置

本目录通过 `link.sh` 链接到 `~/.config/ibus/rime`。

## 依赖

Arch/Manjaro：

```bash
sudo pacman -S --needed ibus ibus-rime
```

Ubuntu/Debian：

```bash
sudo apt install ibus ibus-rime
```

## 关联

```bash
cd ~/.dotfile
./link.sh
```

## 启动和重载

```bash
ibus-daemon -drx
ibus engine rime
```

修改词库或方案后，可通过重新启动 IBus 让 Rime 重新部署：

```bash
ibus-daemon -drx
```

## 目录结构

| 路径 | 用途 |
| --- | --- |
| `default.custom.yaml` | 用户全局设置 |
| `luna_pinyin/` | 明月拼音方案、扩展词库和自定义配置 |
| `wubi86_jidian/` | 五笔86简点方案 |
| `color_schemes/` | Rime 配色 |
| `symbols.custom.yaml` | 符号定义 |
| `weasel.custom.yaml` | 外观设置 |
| 根目录的 `luna_pinyin.*.yaml` | 指向 `luna_pinyin/` 内实际文件的符号链接 |
| 根目录的 `wubi86_jidian*.yaml` | 指向 `wubi86_jidian/` 内实际文件的符号链接 |

## 生成文件

以下目录不纳入版本管理：

- `build/`
- `sync/`
- `*.userdb/`
- `*.userdb.old/`

## 排查

```bash
ibus engine
ibus list-engine | grep -i rime
find ~/.config/ibus/rime -maxdepth 1 -xtype l
```

最后一条用于检查 Rime 根目录中是否有失效的符号链接。
