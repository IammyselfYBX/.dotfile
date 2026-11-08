#!/usr/bin/env bash
set -euo pipefail
bashrc="$HOME/.bashrc"
backup="$HOME/.bashrc.codex-backup-$(date +%Y%m%d-%H%M%S)"
cp -a "$bashrc" "$backup"
python3 - "$bashrc" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
text = p.read_text(encoding='utf-8')
text = re.sub(r'\n?# >>> CODEX_WEZTERM_IMAGE_ENV >>>.*?# <<< CODEX_WEZTERM_IMAGE_ENV <<<\n?', '\n', text, flags=re.S)
text = text.rstrip() + '''

# >>> CODEX_WEZTERM_IMAGE_ENV >>>
if [[ -n ${SSH_CONNECTION:-} && -z ${TERM_PROGRAM:-} ]]; then
    export TERM_PROGRAM=WezTerm
    export LC_TERMINAL=WezTerm
    export COLORTERM=truecolor
fi
# <<< CODEX_WEZTERM_IMAGE_ENV <<<
'''
p.write_text(text, encoding='utf-8')
PY
printf 'BACKUP=%s\n' "$backup"
bash -ic 'printf "TERM=%s\nTERM_PROGRAM=%s\nCOLORTERM=%s\nMDCAT=%s\n" "$TERM" "$TERM_PROGRAM" "$COLORTERM" "$(command -v mdcat)"' 2>&1