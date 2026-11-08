#!/usr/bin/env python3
"""Interactive manager for ~/.dotfile.

Uses only the Python standard library. The TUI is built with curses.
"""
from __future__ import annotations

import argparse
import curses
import datetime as _dt
import difflib
import json
import locale
import os
import shlex
import shutil
import subprocess
import sys
import unicodedata
from dataclasses import dataclass
from pathlib import Path

HOME = Path.home()
REPO = Path(__file__).resolve().parent.parent
BACKUP_ROOT = HOME / ".dotfile-backups"
CATALOG_PATH = REPO / "doc" / "catalog.json"


def load_catalog() -> dict:
    try:
        return json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}


CATALOG = load_catalog()

SHELL_BEGIN = "# >>> dotfiles managed block >>>"
SHELL_END = "# <<< dotfiles managed block <<<"
GIT_BEGIN = "# >>> dotfiles managed include >>>"
GIT_END = "# <<< dotfiles managed include <<<"

STATUS_INSTALLED = "installed"
STATUS_PENDING = "pending"
STATUS_CONFLICT = "conflict"
STATUS_SOURCE = "source-missing"

PAIR_RED = 1
PAIR_YELLOW = 2
PAIR_GREEN = 3
PAIR_CYAN = 4
PAIR_MAGENTA = 5
PAIR_GRAY = 6


@dataclass(frozen=True)
class Item:
    item_id: str
    category: str
    name: str
    source_rel: str
    target_rel: str
    kind: str = "link"  # link, shell, git
    marker: str = ""

    @property
    def source(self) -> Path:
        return REPO / self.source_rel

    @property
    def target(self) -> Path:
        return HOME / self.target_rel

    @property
    def kind_label(self) -> str:
        if self.kind == "link":
            return "软链接"
        if self.kind == "git":
            return "Git include"
        return "Shell source 集成"


@dataclass(frozen=True)
class Status:
    code: str
    label: str
    pair: int


LINK_SPECS = [
    ("xorg-xmodmap", "Xorg", "Xmodmap 键盘映射", "desktop/xorg/Xmodmap", ".Xmodmap"),
    ("xorg-xprofile", "Xorg", "Xprofile 输入法环境", "desktop/xorg/xprofile", ".xprofile"),
    ("xorg-xresources", "Xorg", "Xresources 资源设置", "desktop/xorg/Xresources", ".Xresources"),
    ("xorg-xinitrc", "Xorg", "xinitrc", "desktop/xorg/xinitrc", ".xinitrc"),
    ("xorg-xsession", "Xorg", "xsession", "desktop/xorg/xsession", ".xsession"),
    ("xorg-fehbg", "Xorg", "feh 壁纸脚本", "desktop/xorg/fehbg", ".fehbg"),
    ("xorg-modmap", "Xorg", "modmap", "desktop/xorg/modmap", ".modmap"),
    ("xorg-xclients", "Xorg", "Xclients", "desktop/xorg/Xclients", ".Xclients"),
    ("shell-dir-colors", "Shell", "终端目录配色", "shell/dir_colors", ".dir_colors"),
    ("shell-logout", "Shell", "Bash logout", "shell/bash_logout", ".bash_logout"),
    ("terminal-alacritty", "Terminal", "Alacritty", "terminal/alacritty", ".config/alacritty"),
    ("terminal-wezterm", "Terminal", "WezTerm", "terminal/wezterm", ".config/wezterm"),
    ("terminal-tmux", "Terminal", "tmux", "terminal/tmux/tmux.conf", ".config/tmux.conf"),
    ("desktop-i3", "Desktop", "i3 窗口管理器", "desktop/i3", ".config/i3"),
    ("desktop-compton", "Desktop", "Compton", "desktop/compton", ".config/compton"),
    ("desktop-polybar", "Desktop", "Polybar", "desktop/polybar", ".config/polybar"),
    ("desktop-autostart", "Desktop", "桌面自启动项", "desktop/autostart", ".config/autostart"),
    ("desktop-qtcreator-launcher", "Desktop", "Qt Creator 应用菜单启动器", "desktop/gnome/桌面图标/Qt_create.desktop", ".local/share/applications/Qt_create.desktop"),
    ("input-rime", "Input", "Rime 输入法", "input-method/rime", ".config/ibus/rime"),
    ("file-ranger", "Files", "Ranger 文件管理器", "file-manager/ranger", ".config/ranger"),
    ("i3-screen-off", "i3 Tools", "screen_off 命令", "desktop/i3/brightness/screen_off.sh", ".local/bin/screen_off"),
    ("i3-betterlockscreen", "i3 Tools", "betterlockscreen 命令", "desktop/i3/lock/betterlockscreen", ".local/bin/betterlockscreen"),
    ("i3-lock-screen", "i3 Tools", "锁屏命令", "desktop/i3/lock/lock-screen.sh", ".local/bin/lock-screen"),
    ("i3-display-position", "i3 Tools", "显示器位置命令", "desktop/i3/display-position/i3-display-position", ".local/bin/i3-display-position"),
    ("doc-zathura", "Documents", "Zathura PDF", "documents/zathura/zathurarc", ".config/zathura/zathurarc"),
    ("doc-latexmk", "Documents", "latexmk", "documents/latexmk/latexmkrc", ".latexmkrc"),
    ("editor-vscode-settings", "Editor", "VS Code 设置", "editors/vscode/settings.json", ".config/Code/User/settings.json"),
    ("editor-vscode-snippets", "Editor", "VS Code snippets", "editors/vscode/snippets", ".config/Code/User/snippets"),
]

ADAPTER_SPECS = [
    ("shell-bashrc", "Shell", "Bash .bashrc", "shell/bashrc", ".bashrc", "shell", SHELL_BEGIN),
    ("shell-bash-profile", "Shell", "Bash .bash_profile", "shell/bash_profile", ".bash_profile", "shell", SHELL_BEGIN),
    ("shell-profile", "Shell", "POSIX .profile", "shell/profile", ".profile", "shell", SHELL_BEGIN),
    ("git-include", "Git", "全局 Git include", "git/gitconfig", ".gitconfig", "git", GIT_BEGIN),
]


def lexists(path: Path) -> bool:
    return os.path.lexists(os.fspath(path))


def build_items() -> list[Item]:
    items = [
        Item(item_id, category, name, source, target, "link")
        for item_id, category, name, source, target in LINK_SPECS
    ]

    font_root = REPO / "assets" / "fonts"
    if font_root.is_dir():
        for family in sorted(font_root.iterdir(), key=lambda p: p.name.lower()):
            if family.is_dir():
                items.append(
                    Item(
                        f"font-{family.name.lower()}",
                        "Fonts",
                        f"字体 · {family.name}",
                        str(family.relative_to(REPO)),
                        f".local/share/fonts/{family.name}",
                        "link",
                    )
                )

    items.extend(
        Item(item_id, category, name, source, target, kind, marker)
        for item_id, category, name, source, target, kind, marker in ADAPTER_SPECS
    )

    if (HOME / ".zshrc").exists() or shutil.which("zsh"):
        items.append(
            Item("shell-zshrc", "Shell", "Zsh .zshrc", "shell/zshrc", ".zshrc", "shell", SHELL_BEGIN)
        )

    return items


def wiki_path(item: Item) -> Path:
    exact = {
        "desktop-qtcreator-launcher": REPO / "desktop/gnome/doc/wiki.md",
        "editor-vscode-settings": REPO / "editors/vscode/doc/wiki.md",
        "editor-vscode-snippets": REPO / "editors/vscode/doc/wiki.md",
    }
    if item.item_id in exact:
        return exact[item.item_id]
    if item.item_id.startswith("i3-"):
        return REPO / "desktop/i3/doc/wiki.md"
    if item.source.is_dir():
        return item.source / "doc/wiki.md"
    return item.source.parent / "doc/wiki.md"


def symlink_points_to(target: Path, source: Path) -> bool:
    if not target.is_symlink():
        return False
    try:
        return target.resolve(strict=False) == source.resolve(strict=False)
    except OSError:
        return False


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def _effective_compare_path(path: Path) -> Path:
    if path.is_symlink():
        try:
            return path.resolve(strict=True)
        except OSError:
            return path
    return path


def _is_text_file(path: Path, limit: int = 1_500_000) -> bool:
    try:
        if not path.is_file() or path.stat().st_size > limit:
            return False
        data = path.read_bytes()
    except OSError:
        return False
    if b"\0" in data[:4096]:
        return False
    try:
        data.decode("utf-8")
        return True
    except UnicodeDecodeError:
        return False


def _file_diff(source: Path, target: Path, rel: str = "") -> list[str]:
    label = rel or target.name
    if not _is_text_file(source) or not _is_text_file(target):
        try:
            same = source.read_bytes() == target.read_bytes()
        except OSError:
            same = False
        return [f"二进制文件有差异: {label}"] if not same else []

    source_text = source.read_text(encoding="utf-8", errors="replace").splitlines()
    target_text = target.read_text(encoding="utf-8", errors="replace").splitlines()
    if source_text == target_text:
        return []
    return list(
        difflib.unified_diff(
            target_text,
            source_text,
            fromfile=f"target/{label}",
            tofile=f"source/{label}",
            lineterm="",
        )
    )


def _directory_files(root: Path) -> dict[str, Path]:
    result: dict[str, Path] = {}
    if not root.is_dir():
        return result
    for dirpath, dirnames, filenames in os.walk(root, followlinks=False):
        dirnames[:] = sorted(d for d in dirnames if d not in (".git", "__pycache__"))
        for name in sorted(filenames):
            path = Path(dirpath) / name
            try:
                result[str(path.relative_to(root))] = path
            except ValueError:
                continue
    return result


def build_diff(item: Item) -> list[str]:
    source = item.source
    target = item.target
    if not source.exists() and not source.is_symlink():
        return [f"源文件缺失: {source}"]
    if not lexists(target):
        return [f"目标不存在: {target}", "", "安装后会在此路径建立受管理配置。"]

    target_cmp = _effective_compare_path(target)

    if source.is_dir():
        if not target_cmp.is_dir():
            return [f"类型不同: 源是目录，目标是 {target_cmp}"]
        source_files = _directory_files(source)
        target_files = _directory_files(target_cmp)
        lines: list[str] = []
        all_names = sorted(set(source_files) | set(target_files))
        for rel in all_names:
            if rel not in target_files:
                lines.append(f"只存在于源: {rel}")
                continue
            if rel not in source_files:
                lines.append(f"只存在于目标: {rel}")
                continue
            if source_files[rel].read_bytes() == target_files[rel].read_bytes():
                continue
            lines.extend(_file_diff(source_files[rel], target_files[rel], rel))
            lines.append("")
            if len(lines) > 3500:
                lines.append("… 差异过大，已截断")
                break
        return lines or ["没有发现文件差异。"]

    if target_cmp.is_dir():
        return [f"类型不同: 源是文件，目标是目录 {target_cmp}"]
    lines = _file_diff(source, target_cmp)
    return lines or ["没有发现文件差异。"]


_COMMAND_CACHE: dict[str, bool] = {}
_FONT_CACHE: dict[str, bool | None] = {}


def item_meta(item: Item) -> dict:
    meta = CATALOG.get("items", {}).get(item.item_id)
    if isinstance(meta, dict):
        return meta
    if item.category == "Fonts":
        return {
            "description": "由 fontconfig 管理的共享字体家族。",
            "contents": [item.source_rel],
            "dependencies": [{"kind": "command", "name": "fc-cache", "required": False}],
        }
    return {
        "description": "由 ~/.dotfile 管理的配置文件。",
        "contents": [item.source_rel],
        "dependencies": [],
    }


def command_available(name: str) -> bool:
    if name not in _COMMAND_CACHE:
        _COMMAND_CACHE[name] = shutil.which(name) is not None
    return _COMMAND_CACHE[name]


def font_available(family: str) -> bool | None:
    if family in _FONT_CACHE:
        return _FONT_CACHE[family]
    fc_match = shutil.which("fc-match")
    if not fc_match:
        _FONT_CACHE[family] = None
        return None
    try:
        result = subprocess.run(
            [fc_match, "-f", "%{family}\n", family],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=3,
        )
        actual = result.stdout.lower().replace(" ", "")
        wanted = family.lower().replace(" ", "")
        _FONT_CACHE[family] = wanted in actual
    except (OSError, subprocess.SubprocessError):
        _FONT_CACHE[family] = None
    return _FONT_CACHE[family]


def dependency_results(item: Item) -> list[dict]:
    results = []
    for dep in item_meta(item).get("dependencies", []):
        if not isinstance(dep, dict):
            continue
        kind = str(dep.get("kind", "command"))
        name = str(dep.get("name", "")).strip()
        if not name:
            continue
        required = bool(dep.get("required", True))
        if kind == "font":
            available = font_available(name)
        else:
            available = command_available(name)
        results.append({**dep, "kind": kind, "name": name, "required": required, "available": available})
    return results


def get_status(item: Item) -> Status:
    source = item.source
    target = item.target

    if not source.exists() and not source.is_symlink():
        return Status(STATUS_SOURCE, "源缺失", PAIR_RED)

    if item.kind == "link":
        if symlink_points_to(target, source):
            return Status(STATUS_INSTALLED, "已安装", PAIR_GREEN)
        if lexists(target):
            return Status(STATUS_CONFLICT, "冲突", PAIR_RED)
        return Status(STATUS_PENDING, "待安装", PAIR_YELLOW)

    text = read_text(target)
    if item.marker and item.marker in text:
        return Status(STATUS_INSTALLED, "已安装", PAIR_GREEN)
    if symlink_points_to(target, source):
        return Status(STATUS_INSTALLED, "已安装", PAIR_GREEN)
    if lexists(target):
        return Status(STATUS_CONFLICT, "冲突", PAIR_RED)
    return Status(STATUS_PENDING, "待安装", PAIR_YELLOW)


def status_map(items: list[Item]) -> dict[str, Status]:
    return {item.item_id: get_status(item) for item in items}


def backup_path(stamp: str, target: Path) -> Path:
    try:
        rel = target.relative_to(HOME)
    except ValueError:
        rel = Path(target.name)
    return BACKUP_ROOT / stamp / rel


def move_to_backup(target: Path, stamp: str) -> Path:
    backup = backup_path(stamp, target)
    backup.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(os.fspath(target), os.fspath(backup))
    return backup


def copy_to_backup(target: Path, stamp: str) -> Path:
    backup = backup_path(stamp, target)
    backup.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(target, backup, follow_symlinks=False)
    return backup


def make_stamp() -> str:
    return _dt.datetime.now().strftime("%Y%m%d-%H%M%S-%f")


def install_link(item: Item, stamp: str) -> tuple[bool, str]:
    source = item.source
    target = item.target
    if not source.exists() and not source.is_symlink():
        raise RuntimeError(f"源文件缺失: {source}")
    if symlink_points_to(target, source):
        return False, "已安装，无需操作。"

    backup_msg = ""
    if lexists(target):
        backup = move_to_backup(target, stamp)
        backup_msg = f"\n原目标已备份到: {backup}"

    target.parent.mkdir(parents=True, exist_ok=True)
    os.symlink(os.fspath(source), os.fspath(target), target_is_directory=source.is_dir())
    return True, f"已安装: {target} -> {source}{backup_msg}"


def shell_block(source_rel: str) -> str:
    return (
        f"\n{SHELL_BEGIN}\n"
        f"if [ -f \"$HOME/.dotfile/{source_rel}\" ]; then\n"
        f"    . \"$HOME/.dotfile/{source_rel}\"\n"
        f"fi\n"
        f"{SHELL_END}\n"
    )


def git_block(source: Path) -> str:
    return (
        f"\n{GIT_BEGIN}\n"
        f"[include]\n"
        f"    path = {source}\n"
        f"{GIT_END}\n"
    )


def integrate_adapter(item: Item, stamp: str, overwrite: bool = False) -> tuple[bool, str]:
    source = item.source
    target = item.target
    if not source.exists() and not source.is_symlink():
        raise RuntimeError(f"源文件缺失: {source}")

    old = read_text(target)
    if not overwrite:
        if item.marker and item.marker in old:
            return False, "已集成，无需操作。"
        if symlink_points_to(target, source):
            return False, "已通过软链接安装，无需追加集成块。"

    backup_msg = ""
    if lexists(target):
        if target.is_dir():
            raise RuntimeError(f"目标是目录，无法作为配置文件集成: {target}")
        if overwrite or target.is_symlink():
            backup = move_to_backup(target, stamp)
            backup_msg = f"\n原目标已备份到: {backup}"
        else:
            backup = copy_to_backup(target, stamp)
            backup_msg = f"\n原文件已备份到: {backup}"

    target.parent.mkdir(parents=True, exist_ok=True)
    prefix = ""
    if overwrite:
        target.write_text("# Managed by ~/.dotfile.\n", encoding="utf-8")
    elif target.is_file() and target.stat().st_size > 0:
        existing = read_text(target)
        if existing and not existing.endswith("\n"):
            prefix = "\n"
    block = git_block(source) if item.kind == "git" else shell_block(item.source_rel)
    with target.open("a", encoding="utf-8") as fh:
        fh.write(prefix + block)
    action = "已覆盖为受管理配置" if overwrite else "已集成"
    return True, f"{action}: {target}{backup_msg}"


def install_one(item: Item, overwrite: bool = False) -> tuple[bool, str]:
    stamp = make_stamp()
    if item.kind == "link":
        changed, msg = install_link(item, stamp)
        if changed and item.category == "Fonts" and shutil.which("fc-cache"):
            subprocess.run(["fc-cache", "-f"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return changed, msg
    return integrate_adapter(item, stamp, overwrite=overwrite)


def run_bootstrap() -> tuple[bool, str]:
    bootstrap = REPO / "bootstrap.sh"
    if not bootstrap.exists():
        return False, f"找不到 bootstrap.sh: {bootstrap}"
    result = subprocess.run(
        [os.fspath(bootstrap)],
        cwd=os.fspath(REPO),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    return result.returncode == 0, result.stdout


def char_width(ch: str) -> int:
    if unicodedata.combining(ch):
        return 0
    return 2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1


def text_width(text: str) -> int:
    return sum(char_width(ch) for ch in text)


def clip_text(text: str, width: int) -> str:
    if width <= 0:
        return ""
    out = []
    used = 0
    for ch in text:
        w = char_width(ch)
        if used + w > width:
            break
        out.append(ch)
        used += w
    return "".join(out)


def pad_text(text: str, width: int) -> str:
    clipped = clip_text(text, width)
    return clipped + " " * max(0, width - text_width(clipped))


def wrap_text(text: str, width: int) -> list[str]:
    if width <= 0:
        return [""]
    lines: list[str] = []
    for raw in str(text).splitlines() or [""]:
        current = ""
        used = 0
        for ch in raw:
            w = char_width(ch)
            if used + w > width and current:
                lines.append(current)
                current = ""
                used = 0
            current += ch
            used += w
        lines.append(current)
    return lines


class DotfilesTUI:
    def __init__(self, stdscr: curses.window):
        self.stdscr = stdscr
        self.items: list[Item] = []
        self.statuses: dict[str, Status] = {}
        self.selected = 0
        self.offset = 0
        self.message = ""
        self.message_ok = True
        self.refresh()

    def setup(self) -> None:
        curses.curs_set(0)
        self.stdscr.keypad(True)
        if curses.has_colors():
            curses.start_color()
            try:
                curses.use_default_colors()
                bg = -1
            except curses.error:
                bg = curses.COLOR_BLACK
            curses.init_pair(PAIR_RED, curses.COLOR_RED, bg)
            curses.init_pair(PAIR_YELLOW, curses.COLOR_YELLOW, bg)
            curses.init_pair(PAIR_GREEN, curses.COLOR_GREEN, bg)
            curses.init_pair(PAIR_CYAN, curses.COLOR_CYAN, bg)
            curses.init_pair(PAIR_MAGENTA, curses.COLOR_MAGENTA, bg)
            curses.init_pair(PAIR_GRAY, curses.COLOR_WHITE, bg)
        self.stdscr.bkgd(" ", curses.color_pair(PAIR_GRAY))

    def pair(self, num: int) -> int:
        return curses.color_pair(num) if curses.has_colors() else 0

    def refresh(self) -> None:
        self.items = build_items()
        self.statuses = status_map(self.items)
        if self.items:
            self.selected = min(self.selected, len(self.items) - 1)
        else:
            self.selected = 0

    def selected_item(self) -> Item | None:
        if not self.items:
            return None
        return self.items[self.selected]

    def addstr(self, y: int, x: int, text: str, attr: int = 0) -> None:
        try:
            self.stdscr.addstr(y, x, text, attr)
        except curses.error:
            pass

    def summary(self) -> tuple[int, int, int, int]:
        counts = {STATUS_INSTALLED: 0, STATUS_PENDING: 0, STATUS_CONFLICT: 0, STATUS_SOURCE: 0}
        for status in self.statuses.values():
            counts[status.code] = counts.get(status.code, 0) + 1
        return counts[STATUS_INSTALLED], counts[STATUS_PENDING], counts[STATUS_CONFLICT], counts[STATUS_SOURCE]

    def draw(self) -> None:
        self.stdscr.erase()
        height, width = self.stdscr.getmaxyx()
        installed, pending, conflict, missing = self.summary()

        title = "Dotfiles 管理器"
        self.addstr(0, 2, title, self.pair(PAIR_CYAN) | curses.A_BOLD)
        self.addstr(0, 2 + text_width(title) + 2, clip_text(os.fspath(REPO), max(0, width - 28)), self.pair(PAIR_GRAY))

        summary = f"已安装 {installed}  待安装 {pending}  冲突 {conflict}  源缺失 {missing}"
        self.addstr(1, 2, clip_text(summary, max(0, width - 4)), curses.A_BOLD)
        self.addstr(1, max(2, width - 25), "Vim: 独立管理", self.pair(PAIR_GRAY))

        self.addstr(2, 0, "─" * max(1, width - 1), self.pair(PAIR_GRAY))
        header = f"{'类别 / 配置':<50}  {'状态':>8}"
        self.addstr(3, 2, clip_text(header, max(0, width - 4)), curses.A_BOLD)

        list_top = 5
        list_height = max(1, height - list_top - 3)
        if self.selected < self.offset:
            self.offset = self.selected
        if self.selected >= self.offset + list_height:
            self.offset = self.selected - list_height + 1
        self.offset = max(0, min(self.offset, max(0, len(self.items) - list_height)))

        for row_index in range(list_height):
            index = self.offset + row_index
            if index >= len(self.items):
                break
            item = self.items[index]
            status = self.statuses[item.item_id]
            selected = index == self.selected
            y = list_top + row_index
            base_attr = curses.A_REVERSE if selected else 0
            status_width = max(4, text_width(status.label))
            left_width = max(1, width - status_width - 4)
            left = f"{item.category:<12} {item.name}"
            left = pad_text(left, left_width)
            status_text = pad_text(status.label, status_width)

            self.addstr(y, 0, " " * max(0, width - 1), base_attr)
            name_attr = self.pair(status.pair)
            if status.code == STATUS_INSTALLED:
                self.addstr(y, 1, left, base_attr)
            else:
                self.addstr(y, 1, left, name_attr | base_attr | (curses.A_BOLD if status.code != STATUS_INSTALLED else 0))
            self.addstr(y, max(1, width - status_width - 2), status_text, self.pair(status.pair) | base_attr | curses.A_BOLD)

        if self.message:
            message_attr = self.pair(PAIR_GREEN if self.message_ok else PAIR_RED) | curses.A_BOLD
            self.addstr(height - 3, 2, clip_text(self.message, max(0, width - 4)), message_attr)

        footer = "↑/↓ 移动  Enter 详情  e 编辑  h 文档  i 安装/合并  d 差异  o 覆盖  a 全部安装  r 刷新  q/ESC 退出"
        self.addstr(height - 1, 1, clip_text(footer, max(0, width - 2)), self.pair(PAIR_GRAY))
        self.stdscr.refresh()

    def popup(self, title: str, body: str, ok: bool = True) -> None:
        height, width = self.stdscr.getmaxyx()
        max_inner = max(10, min(70, width - 6))
        lines = wrap_text(body, max_inner - 2)
        max_lines = max(4, height - 8)
        if len(lines) > max_lines:
            lines = ["…"] + lines[-(max_lines - 1):]
        box_h = min(height - 4, len(lines) + 5)
        box_w = max_inner
        top = max(1, (height - box_h) // 2)
        left = max(1, (width - box_w) // 2)
        attr = self.pair(PAIR_GREEN if ok else PAIR_RED) | curses.A_BOLD
        self.stdscr.erase()
        for y in range(top, top + box_h):
            self.addstr(y, left, " " * box_w, self.pair(PAIR_GRAY))
        self.addstr(top, left + 2, clip_text(title, box_w - 4), attr)
        for i, line in enumerate(lines[: box_h - 4], 1):
            self.addstr(top + i, left + 2, clip_text(line, box_w - 4), self.pair(PAIR_GRAY))
        self.addstr(top + box_h - 2, left + 2, "按任意键继续", self.pair(PAIR_CYAN))
        self.stdscr.refresh()
        self.stdscr.getch()

    def confirm(self, title: str, body: str) -> bool:
        height, width = self.stdscr.getmaxyx()
        box_w = max(40, min(76, width - 6))
        lines = wrap_text(body, box_w - 4)
        box_h = min(height - 4, len(lines) + 5)
        top = max(1, (height - box_h) // 2)
        left = max(1, (width - box_w) // 2)
        self.stdscr.erase()
        for y in range(top, top + box_h):
            self.addstr(y, left, " " * box_w, self.pair(PAIR_GRAY))
        self.addstr(top, left + 2, clip_text(title, box_w - 4), self.pair(PAIR_CYAN) | curses.A_BOLD)
        for i, line in enumerate(lines[: box_h - 4], 1):
            self.addstr(top + i, left + 2, clip_text(line, box_w - 4), self.pair(PAIR_GRAY))
        self.addstr(top + box_h - 2, left + 2, "y 确认   n/ESC 取消", self.pair(PAIR_YELLOW) | curses.A_BOLD)
        self.stdscr.refresh()
        while True:
            ch = self.stdscr.getch()
            if ch in (ord("y"), ord("Y")):
                return True
            if ch in (ord("n"), ord("N"), 27):
                return False

    def item_by_id(self, item_id: str) -> Item | None:
        for item in self.items:
            if item.item_id == item_id:
                return item
        return None

    def detail_lines(self, item: Item, status: Status) -> list[tuple[str, int, bool]]:
        meta = item_meta(item)
        lines: list[tuple[str, int, bool]] = []
        lines.append((f"状态: {status.label}", status.pair, True))
        lines.append((f"类别: {item.category}", PAIR_GRAY, False))
        lines.append((f"名称: {item.name}", PAIR_GRAY, False))
        lines.append((f"方式: {item.kind_label}", PAIR_GRAY, False))
        lines.append((f"源: {item.source}", PAIR_GRAY, False))
        source_type = "目录" if item.source.is_dir() else "文件"
        lines.append((f"源类型: {source_type}", PAIR_GRAY, False))
        lines.append((f"目标: {item.target}", PAIR_GRAY, False))
        lines.append((f"文档: {wiki_path(item)}", PAIR_GRAY, False))
        if item.target.is_symlink():
            try:
                lines.append((f"当前软链接 -> {os.readlink(item.target)}", PAIR_GRAY, False))
            except OSError:
                lines.append(("当前软链接无法读取", PAIR_RED, False))

        description = str(meta.get("description", "")).strip()
        if description:
            lines.append(("", PAIR_GRAY, False))
            lines.append(("说明:", PAIR_CYAN, True))
            lines.append((description, PAIR_GRAY, False))

        contents = meta.get("contents", [])
        if contents:
            lines.append(("", PAIR_GRAY, False))
            lines.append(("配置组成:", PAIR_CYAN, True))
            for rel in contents:
                path = REPO / str(rel)
                exists = path.exists() or path.is_symlink()
                pair = PAIR_GREEN if exists else PAIR_RED
                marker = "✓" if exists else "✗"
                lines.append((f"[{marker}] {rel}", pair, False))

        related = meta.get("related", [])
        if related:
            lines.append(("", PAIR_GRAY, False))
            lines.append(("关联管理项:", PAIR_CYAN, True))
            for related_id in related:
                related_item = self.item_by_id(str(related_id))
                if not related_item:
                    lines.append((f"[?] 未登记: {related_id}", PAIR_YELLOW, False))
                    continue
                related_status = get_status(related_item)
                lines.append(
                    (
                        f"[{related_status.label}] {related_item.name} -> {related_item.target}",
                        related_status.pair,
                        False,
                    )
                )

        dependencies = dependency_results(item)
        lines.append(("", PAIR_GRAY, False))
        lines.append(("依赖:", PAIR_CYAN, True))
        if not dependencies:
            lines.append(("[✓] 无额外依赖", PAIR_GREEN, False))
        for dep in dependencies:
            available = dep.get("available")
            required = dep.get("required", True)
            if available is True:
                marker, pair = "✓", PAIR_GREEN
            elif available is False and required:
                marker, pair = "✗", PAIR_RED
            elif available is False:
                marker, pair = "○", PAIR_YELLOW
            else:
                marker, pair = "?", PAIR_YELLOW
            label = "字体" if dep.get("kind") == "font" else "命令"
            suffix = "" if required else "（可选）"
            packages = []
            if dep.get("arch"):
                packages.append(f"Arch: {dep['arch']}")
            if dep.get("debian"):
                packages.append(f"Debian: {dep['debian']}")
            package_text = f"  [{', '.join(packages)}]" if packages else ""
            lines.append((f"[{marker}] {label}{suffix}: {dep['name']}{package_text}", pair, False))
        lines.append(("依赖检查只读取本机命令和字体，不联网，也不会自动安装系统包。", PAIR_GRAY, False))

        notes = str(meta.get("notes", "")).strip()
        if notes:
            lines.append(("", PAIR_GRAY, False))
            lines.append(("备注:", PAIR_CYAN, True))
            lines.append((notes, PAIR_YELLOW, False))

        lines.append(("", PAIR_GRAY, False))
        lines.append(("操作:", PAIR_CYAN, True))
        if status.code == STATUS_INSTALLED:
            lines.append(("e 编辑源文件；h 查看 doc/wiki.md；d 查看差异。", PAIR_GRAY, False))
        elif status.code == STATUS_SOURCE:
            lines.append(("源文件缺失，请先修复仓库内容。", PAIR_RED, False))
        elif item.kind == "link":
            lines.append(("e 编辑源文件；h 查看文档；i 接管为软链接；o 强制覆盖；d 查看差异。", PAIR_GRAY, False))
        else:
            lines.append(("e 编辑源文件；h 查看文档；i 合并（保留原内容）；o 覆盖为 shim；d 查看差异。", PAIR_GRAY, False))
        return lines

    def show_detail(self, item: Item) -> None:
        offset = 0
        while True:
            status = get_status(item)
            lines = self.detail_lines(item, status)
            self.stdscr.erase()
            height, width = self.stdscr.getmaxyx()
            title = f"{item.category} / {item.name}"
            self.addstr(0, 2, clip_text(title, max(0, width - 4)), self.pair(PAIR_CYAN) | curses.A_BOLD)
            self.addstr(1, 2, clip_text(f"状态: {status.label}", max(0, width - 4)), self.pair(status.pair) | curses.A_BOLD)
            self.addstr(2, 0, "─" * max(1, width - 1), self.pair(PAIR_GRAY))

            rendered: list[tuple[str, int, bool]] = []
            inner_width = max(10, width - 6)
            for text, pair, bold in lines:
                if not text:
                    rendered.append(("", pair, False))
                    continue
                for wrapped in wrap_text(text, inner_width):
                    rendered.append((wrapped, pair, bold))

            visible = max(1, height - 5)
            offset = max(0, min(offset, max(0, len(rendered) - visible)))
            for row, (text, pair, bold) in enumerate(rendered[offset : offset + visible], 3):
                attr = self.pair(pair) | (curses.A_BOLD if bold else 0)
                self.addstr(row, 2, text, attr)

            if self.message and height >= 3:
                attr = self.pair(PAIR_GREEN if self.message_ok else PAIR_RED) | curses.A_BOLD
                self.addstr(height - 2, 1, clip_text(self.message, max(0, width - 2)), attr)
            footer = "↑/↓ 滚动  e 编辑  h 文档  i 安装/合并  o 覆盖  d 差异  a 全部安装  ESC 返回"
            self.addstr(height - 1, 1, clip_text(footer, max(0, width - 2)), self.pair(PAIR_GRAY))
            self.stdscr.refresh()
            ch = self.stdscr.getch()
            if ch in (27, ord("q"), curses.KEY_LEFT):
                return
            if ch in (curses.KEY_UP, ord("k")):
                offset = max(0, offset - 1)
            elif ch in (curses.KEY_DOWN, ord("j")):
                offset = min(max(0, len(rendered) - visible), offset + 1)
            elif ch == curses.KEY_PPAGE:
                offset = max(0, offset - visible)
            elif ch == curses.KEY_NPAGE:
                offset = min(max(0, len(rendered) - visible), offset + visible)
            elif ch in (ord("e"), ord("E")):
                self.edit_source(item)
            elif ch in (ord("h"), ord("H")):
                self.view_wiki(item)
            elif ch in (ord("i"), ord("I")):
                self.install_selected(item)
            elif ch in (ord("o"), ord("O")):
                self.install_selected(item, overwrite=True)
            elif ch in (ord("d"), ord("D")):
                self.show_diff(item)
            elif ch in (ord("a"), ord("A")):
                self.install_all()

    def view_wiki(self, item: Item) -> None:
        path = wiki_path(item)
        if not path.is_file():
            self.message = f"未找到文档: {path}"
            self.message_ok = False
            return

        raw_pager = os.environ.get("PAGER") or "less -R"
        try:
            command = shlex.split(raw_pager)
        except ValueError as exc:
            self.message = f"分页器命令无效: {exc}"
            self.message_ok = False
            return
        if not command:
            command = ["less", "-R"]
        if shutil.which(command[0]) is None:
            fallback_editor = os.environ.get("EDITOR") or os.environ.get("VISUAL") or "vim"
            command = shlex.split(fallback_editor)
        if not command or shutil.which(command[0]) is None:
            self.message = f"找不到分页器或编辑器，文档位于: {path}"
            self.message_ok = False
            return

        curses.def_prog_mode()
        curses.endwin()
        error: str | None = None
        returncode = 1
        try:
            env = os.environ.copy()
            env.setdefault("LESS", "-R")
            result = subprocess.run(
                command + [os.fspath(path)],
                cwd=os.fspath(REPO),
                env=env,
            )
            returncode = result.returncode
        except Exception as exc:
            error = str(exc)
        finally:
            curses.reset_prog_mode()
            try:
                self.stdscr.refresh()
            except curses.error:
                pass

        if error:
            self.message = f"文档查看失败: {error}"
            self.message_ok = False
        elif returncode == 0:
            self.message = f"已查看文档: {path}"
            self.message_ok = True
        else:
            self.message = f"分页器退出码: {returncode}"
            self.message_ok = False

    def edit_source(self, item: Item) -> None:
        path = item.source
        if not path.exists() and not path.is_symlink():
            self.message = f"源文件不存在，无法编辑: {path}"
            self.message_ok = False
            return

        raw_editor = (
            os.environ.get("EDITOR")
            or os.environ.get("VISUAL")
            or os.environ.get("EDITER")
            or "vim"
        )
        try:
            command = shlex.split(raw_editor)
        except ValueError as exc:
            self.message = f"编辑器命令无效: {exc}"
            self.message_ok = False
            return
        if not command:
            self.message = "编辑器命令为空"
            self.message_ok = False
            return
        if shutil.which(command[0]) is None:
            self.message = f"找不到编辑器: {command[0]}"
            self.message_ok = False
            return

        curses.def_prog_mode()
        curses.endwin()
        error: str | None = None
        returncode = 1
        try:
            result = subprocess.run(
                command + [os.fspath(path)],
                cwd=os.fspath(REPO),
            )
            returncode = result.returncode
        except Exception as exc:
            error = str(exc)
        finally:
            curses.reset_prog_mode()
            try:
                self.stdscr.refresh()
            except curses.error:
                pass

        if error:
            self.message = f"编辑器启动失败: {error}"
            self.message_ok = False
        elif returncode == 0:
            self.message = f"已编辑: {path}"
            self.message_ok = True
        else:
            self.message = f"编辑器退出码: {returncode}"
            self.message_ok = False
        self.refresh()

    def show_diff(self, item: Item) -> None:
        lines = build_diff(item)
        offset = 0
        while True:
            self.stdscr.erase()
            height, width = self.stdscr.getmaxyx()
            title = f"差异: {item.category} / {item.name}"
            self.addstr(0, 2, clip_text(title, max(0, width - 4)), self.pair(PAIR_CYAN) | curses.A_BOLD)
            self.addstr(1, 2, clip_text(f"{item.target}  <->  {item.source}", max(0, width - 4)), self.pair(PAIR_GRAY))
            self.addstr(2, 0, "─" * max(1, width - 1), self.pair(PAIR_GRAY))
            visible = max(1, height - 5)
            offset = max(0, min(offset, max(0, len(lines) - visible)))
            for row, line in enumerate(lines[offset : offset + visible], 3):
                if line.startswith("+++") or line.startswith("---"):
                    attr = self.pair(PAIR_CYAN) | curses.A_BOLD
                elif line.startswith("+"):
                    attr = self.pair(PAIR_GREEN)
                elif line.startswith("-"):
                    attr = self.pair(PAIR_RED)
                elif line.startswith("@@"):
                    attr = self.pair(PAIR_MAGENTA) | curses.A_BOLD
                else:
                    attr = self.pair(PAIR_GRAY)
                self.addstr(row, 1, clip_text(line, max(0, width - 2)), attr)
            footer = "↑/↓ 滚动   PgUp/PgDn 翻页   ESC/q 返回"
            self.addstr(height - 1, 1, clip_text(footer, max(0, width - 2)), self.pair(PAIR_GRAY))
            self.stdscr.refresh()
            ch = self.stdscr.getch()
            if ch in (27, ord("q"), ord("Q"), curses.KEY_LEFT):
                return
            if ch in (curses.KEY_UP, ord("k")):
                offset = max(0, offset - 1)
            elif ch in (curses.KEY_DOWN, ord("j")):
                offset = min(max(0, len(lines) - visible), offset + 1)
            elif ch == curses.KEY_PPAGE:
                offset = max(0, offset - visible)
            elif ch == curses.KEY_NPAGE:
                offset = min(max(0, len(lines) - visible), offset + visible)

    def plan_lines(self) -> tuple[list[tuple[str, int, bool]], int, int, int, int]:
        installed = pending = conflict = missing = 0
        lines: list[tuple[str, int, bool]] = []
        for item in self.items:
            status = get_status(item)
            if status.code == STATUS_INSTALLED:
                installed += 1
                continue
            if status.code == STATUS_PENDING:
                pending += 1
            elif status.code == STATUS_CONFLICT:
                conflict += 1
            elif status.code == STATUS_SOURCE:
                missing += 1

            if item.kind == "link":
                action = "备份并接管为软链接" if status.code == STATUS_CONFLICT else "创建软链接"
            else:
                action = "备份并追加受管理块" if status.code == STATUS_CONFLICT else "创建受管理 shim"
            if status.code == STATUS_SOURCE:
                action = "源文件缺失，无法安装"
            lines.append(
                (
                    f"[{status.label}] {item.category} / {item.name} -> {item.target}  |  {action}",
                    status.pair,
                    False,
                )
            )
        return lines, installed, pending, conflict, missing

    def show_install_plan(self) -> bool:
        lines, installed, pending, conflict, missing = self.plan_lines()
        offset = 0
        while True:
            self.stdscr.erase()
            height, width = self.stdscr.getmaxyx()
            title = "全部安装计划"
            self.addstr(0, 2, title, self.pair(PAIR_CYAN) | curses.A_BOLD)
            summary = f"已安装 {installed}  待安装 {pending}  冲突 {conflict}  源缺失 {missing}"
            self.addstr(1, 2, clip_text(summary, max(0, width - 4)), curses.A_BOLD)
            self.addstr(2, 0, "─" * max(1, width - 1), self.pair(PAIR_GRAY))
            if not lines:
                body = [("所有配置均已安装，无需执行安装。", PAIR_GREEN, True)]
            else:
                body = lines
            rendered: list[tuple[str, int, bool]] = []
            inner_width = max(10, width - 6)
            for text, pair, bold in body:
                for wrapped in wrap_text(text, inner_width):
                    rendered.append((wrapped, pair, bold))
            visible = max(1, height - 5)
            offset = max(0, min(offset, max(0, len(rendered) - visible)))
            for row, (text, pair, bold) in enumerate(rendered[offset : offset + visible], 3):
                attr = self.pair(pair) | (curses.A_BOLD if bold else 0)
                self.addstr(row, 2, clip_text(text, max(0, width - 4)), attr)
            if lines and missing == 0:
                footer = "↑/↓ 滚动   y 确认安装   n/ESC 取消"
            elif lines:
                footer = "存在源缺失，无法全部安装；n/ESC 返回"
            else:
                footer = "按任意键返回"
            self.addstr(height - 1, 1, clip_text(footer, max(0, width - 2)), self.pair(PAIR_GRAY))
            self.stdscr.refresh()
            ch = self.stdscr.getch()
            if not lines:
                return False
            if ch in (ord("y"), ord("Y")):
                return missing == 0
            if ch in (27, ord("n"), ord("N"), ord("q"), ord("Q")):
                return False
            if ch in (curses.KEY_UP, ord("k")):
                offset = max(0, offset - 1)
            elif ch in (curses.KEY_DOWN, ord("j")):
                offset = min(max(0, len(rendered) - visible), offset + 1)
            elif ch == curses.KEY_PPAGE:
                offset = max(0, offset - visible)
            elif ch == curses.KEY_NPAGE:
                offset = min(max(0, len(rendered) - visible), offset + visible)

    def install_all(self) -> None:
        if not self.show_install_plan():
            return
        self.stdscr.erase()
        self.addstr(0, 2, "正在执行 bootstrap.sh …", self.pair(PAIR_CYAN) | curses.A_BOLD)
        self.stdscr.refresh()
        ok, output = run_bootstrap()
        self.refresh()
        tail = "\n".join(output.strip().splitlines()[-14:])
        self.popup("全部安装完成" if ok else "全部安装失败", tail or "无输出", ok)

    def run(self) -> None:
        self.setup()
        while True:
            self.draw()
            ch = self.stdscr.getch()
            if ch in (ord("q"), ord("Q"), 27):
                return
            if ch in (curses.KEY_UP, ord("k")):
                if self.items:
                    self.selected = (self.selected - 1) % len(self.items)
                    self.message = ""
            elif ch in (curses.KEY_DOWN, ord("j")):
                if self.items:
                    self.selected = (self.selected + 1) % len(self.items)
                    self.message = ""
            elif ch in (curses.KEY_PPAGE,):
                self.selected = max(0, self.selected - 10)
            elif ch in (curses.KEY_NPAGE,):
                self.selected = min(len(self.items) - 1, self.selected + 10)
            elif ch in (10, 13, curses.KEY_ENTER):
                item = self.selected_item()
                if item:
                    self.show_detail(item)
                    self.refresh()
            elif ch in (ord("e"), ord("E")):
                item = self.selected_item()
                if item:
                    self.edit_source(item)
            elif ch in (ord("h"), ord("H")):
                item = self.selected_item()
                if item:
                    self.view_wiki(item)
            elif ch in (ord("i"), ord("I")):
                item = self.selected_item()
                if item:
                    self.install_selected(item)
            elif ch in (ord("o"), ord("O")):
                item = self.selected_item()
                if item:
                    self.install_selected(item, overwrite=True)
            elif ch in (ord("d"), ord("D")):
                item = self.selected_item()
                if item:
                    self.show_diff(item)
            elif ch in (ord("a"), ord("A")):
                self.install_all()
            elif ch in (ord("r"), ord("R"), curses.KEY_RESIZE):
                self.refresh()
                self.message = "状态已刷新"
                self.message_ok = True


def print_check(as_json: bool = False) -> int:
    items = build_items()
    statuses = status_map(items)
    if as_json:
        payload = []
        for item in items:
            status = statuses[item.item_id]
            payload.append(
                {
                    "id": item.item_id,
                    "category": item.category,
                    "name": item.name,
                    "kind": item.kind,
                    "source": str(item.source),
                    "target": str(item.target),
                    "status": status.code,
                    "label": status.label,
                }
            )
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        for item in items:
            status = statuses[item.item_id]
            print(f"{status.label:<6} {item.category:<10} {item.name:<24} {item.target}")
    return 0 if all(s.code == STATUS_INSTALLED for s in statuses.values()) else 1


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Manage ~/.dotfile from a Linux terminal")
    parser.add_argument("--check", action="store_true", help="print configuration status and exit")
    parser.add_argument("--json", action="store_true", help="use JSON with --check")
    parser.add_argument("--install-all", action="store_true", help="run bootstrap.sh non-interactively")
    parser.add_argument("--dry-run", action="store_true", help="show link.sh dry-run and exit")
    parser.add_argument("--version", action="version", version="dotctl 1.0")
    args = parser.parse_args(argv)

    if args.check or args.json:
        return print_check(args.json)

    if args.dry_run:
        result = subprocess.run([os.fspath(REPO / "link.sh"), "--dry-run"], cwd=os.fspath(REPO), text=True)
        return result.returncode

    if args.install_all:
        ok, output = run_bootstrap()
        print(output, end="" if output.endswith("\n") else "\n")
        return 0 if ok else 1

    locale.setlocale(locale.LC_ALL, "")
    os.environ.setdefault("ESCDELAY", "25")
    try:
        curses.wrapper(lambda stdscr: DotfilesTUI(stdscr).run())
    except KeyboardInterrupt:
        return 130
    except curses.error as exc:
        print(f"curses error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
