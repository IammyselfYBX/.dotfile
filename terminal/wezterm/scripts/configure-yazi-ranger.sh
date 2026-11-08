#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"

YAZI_VERSION="26.9.1"
YAZI_DIR="$HOME/opt/yazi-$YAZI_VERSION"
YAZI_ZIP="${1:-/tmp/codex-yazi.zip}"
RESVG_TGZ="${2:-/tmp/codex-resvg.tar.gz}"

mkdir -p "$HOME/opt" "$HOME/.local/bin" "$HOME/.config/yazi" "$HOME/.config/ranger"

if [[ ! -x "$YAZI_DIR/yazi" || ! -x "$YAZI_DIR/ya" ]]; then
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  unzip -oq "$YAZI_ZIP" -d "$tmpdir"
  rm -rf "$YAZI_DIR"
  mv "$tmpdir/yazi-x86_64-unknown-linux-gnu" "$YAZI_DIR"
  chmod +x "$YAZI_DIR/yazi" "$YAZI_DIR/ya"
  rm -rf "$tmpdir"
  trap - EXIT
fi

ln -sfn "$YAZI_DIR/yazi" "$HOME/.local/bin/yazi"
ln -sfn "$YAZI_DIR/ya" "$HOME/.local/bin/ya"
tar -xzf "$RESVG_TGZ" -C "$HOME/.local/bin" resvg
chmod +x "$HOME/.local/bin/resvg"

if ! grep -q '^# CODEX_LOCAL_BIN$' "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# CODEX_LOCAL_BIN\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.bashrc"
fi

python3 - <<'PY'
from pathlib import Path
import json
import re

home = Path.home()

rc = home / '.config/ranger/rc.conf'
rc.parent.mkdir(parents=True, exist_ok=True)
text = rc.read_text(encoding='utf-8') if rc.exists() else ''
text = re.sub(r'\n?# >>> CODEX_RANGER_IMAGE >>>.*?# <<< CODEX_RANGER_IMAGE <<<\n?', '\n', text, flags=re.S)
text = text.rstrip() + '''

# >>> CODEX_RANGER_IMAGE >>>
set preview_images true
set preview_images_method iterm2
set iterm2_font_width 19
set iterm2_font_height 47
# <<< CODEX_RANGER_IMAGE <<<
'''
rc.write_text(text, encoding='utf-8')

yazi = home / '.config/yazi/yazi.toml'
text = yazi.read_text(encoding='utf-8') if yazi.exists() else ''
lines = text.splitlines()
header = re.compile(r'^\s*\[preview\]\s*(?:#.*)?$')
any_header = re.compile(r'^\s*\[')
desired = {
    'image_filter': 'lanczos3',
    'image_quality': '90',
    'max_width': '1600',
    'max_height': '1600',
}
rendered = [f'{k} = {json.dumps(v) if k == "image_filter" else v}' for k, v in desired.items()]
idx = next((i for i, line in enumerate(lines) if header.match(line)), None)
if idx is None:
    if lines and lines[-1].strip():
        lines.append('')
    lines.append('[preview]')
    lines.extend(rendered)
else:
    end = next((i for i in range(idx + 1, len(lines)) if any_header.match(lines[i])), len(lines))
    section = [lines[idx]]
    inserted = False
    for line in lines[idx + 1:end]:
        m = re.match(r'^\s*([A-Za-z0-9_-]+)\s*=', line)
        if m and m.group(1) in desired:
            if not inserted:
                section.extend(rendered)
                inserted = True
            continue
        section.append(line)
    if not inserted:
        section.extend(rendered)
    lines[idx:end] = section
mgr_header = re.compile(r'^\s*\[mgr\]\s*(?:#.*)?$')
mgr_idx = next((i for i, line in enumerate(lines) if mgr_header.match(line)), None)
if mgr_idx is None:
    if lines and lines[-1].strip():
        lines.append('')
    lines.append('[mgr]')
    lines.append('ratio = [1, 2, 5]')
else:
    mgr_end = next((i for i in range(mgr_idx + 1, len(lines)) if any_header.match(lines[i])), len(lines))
    found_ratio = False
    for i in range(mgr_idx + 1, mgr_end):
        if re.match(r'^\s*ratio\s*=', lines[i]):
            lines[i] = 'ratio = [1, 2, 5]'
            found_ratio = True
            break
    if not found_ratio:
        lines.insert(mgr_idx + 1, 'ratio = [1, 2, 5]')
yazi.write_text('\n'.join(lines).rstrip() + '\n', encoding='utf-8')
PY

echo 'REMOTE_USER='$(id -un)
echo 'REMOTE_HOST='$(hostname)
echo 'YAZI='$(command -v yazi)
echo 'YA='$(command -v ya)
echo 'RESVG='$(command -v resvg)
yazi --version
ya --version
resvg --version
ranger --version 2>/dev/null || true
echo 'RANGER_IMAGE_CONFIG:'
grep -A4 'CODEX_RANGER_IMAGE' "$HOME/.config/ranger/rc.conf"
echo 'YAZI_PREVIEW_CONFIG:'
sed -n '/^\[preview\]/,/^\[/p' "$HOME/.config/yazi/yazi.toml" | head -12