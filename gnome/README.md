# GNOME / 桌面启动器配置

本目录保存桌面启动器示例，不会由 `link.sh` 自动安装。

## Qt Creator 启动器

文件：`桌面图标/Qt_create.desktop`

安装到应用菜单：

```bash
mkdir -p ~/.local/share/applications
ln -sf ~/.dotfile/gnome/桌面图标/Qt_create.desktop \
  ~/.local/share/applications/Qt_create.desktop
update-desktop-database ~/.local/share/applications
```

安装到桌面：

```bash
mkdir -p ~/Desktop
ln -sf ~/.dotfile/gnome/桌面图标/Qt_create.desktop ~/Desktop/Qt_create.desktop
```

## 修改路径

当前示例使用：

```text
Exec=/opt/qtcreator-4.4.1/bin/qtcreator
Icon=/opt/qtcreator-4.4.1/QtProject-qtcreator
```

如果 Qt Creator 安装位置不同，需要把这两行改成实际路径。

## 验证

```bash
desktop-file-validate ~/.dotfile/gnome/桌面图标/Qt_create.desktop
```

i3 本身不负责绘制桌面图标；如需在桌面显示图标，需要额外的桌面图标管理程序。
