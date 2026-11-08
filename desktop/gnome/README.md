# GNOME / 桌面启动器配置

本目录保存桌面启动器，由 `dotctl` 统一链接到应用菜单。

## Qt Creator 启动器

文件：`桌面图标/Qt_create.desktop`

安装到应用菜单：

```bash
~/.dotfile/scripts/dotctl
```

在 `dotctl` 中选中 `Qt Creator 应用菜单启动器` 并按 `i` 安装。

## 修改路径

当前示例使用：

```text
Exec=/opt/qtcreator-4.4.1/bin/qtcreator
Icon=/opt/qtcreator-4.4.1/QtProject-qtcreator
```

如果 Qt Creator 安装位置不同，需要把这两行改成实际路径。

## 验证

```bash
desktop-file-validate ~/.dotfile/desktop/gnome/桌面图标/Qt_create.desktop
```

i3 本身不负责绘制桌面图标；如需在桌面显示图标，需要额外的桌面图标管理程序。
