#!/usr/bin/env bash
set -euo pipefail

YAZI_VERSION="26.9.1"
RESVG_VERSION="0.49.0"
ARCH="$(uname -m)"

case "$ARCH" in
  x86_64|amd64)
    YAZI_ASSET="yazi-x86_64-unknown-linux-gnu.zip"
    YAZI_DIR="yazi-x86_64-unknown-linux-gnu"
    RESVG_ASSET="resvg-linux-x86_64.tar.gz"
    ;;
  aarch64|arm64)
    YAZI_ASSET="yazi-aarch64-unknown-linux-gnu.zip"
    YAZI_DIR="yazi-aarch64-unknown-linux-gnu"
    RESVG_ASSET="resvg-linux-aarch64.tar.gz"
    ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

for command in curl unzip tar; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Missing required command: $command" >&2
    exit 1
  fi
done

mkdir -p "$HOME/opt" "$HOME/.local/bin"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "Downloading Yazi $YAZI_VERSION for $ARCH..."
curl -fL \
  -o "$TMPDIR/yazi.zip" \
  "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/${YAZI_ASSET}"

unzip -oq "$TMPDIR/yazi.zip" -d "$TMPDIR"
rm -rf "$HOME/opt/yazi-$YAZI_VERSION"
mv "$TMPDIR/$YAZI_DIR" "$HOME/opt/yazi-$YAZI_VERSION"
chmod +x "$HOME/opt/yazi-$YAZI_VERSION/yazi" "$HOME/opt/yazi-$YAZI_VERSION/ya"
ln -sfn "$HOME/opt/yazi-$YAZI_VERSION/yazi" "$HOME/.local/bin/yazi"
ln -sfn "$HOME/opt/yazi-$YAZI_VERSION/ya" "$HOME/.local/bin/ya"

echo "Downloading resvg $RESVG_VERSION for $ARCH..."
curl -fL \
  -o "$TMPDIR/resvg.tar.gz" \
  "https://github.com/linebender/resvg/releases/download/v${RESVG_VERSION}/${RESVG_ASSET}"
tar -xzf "$TMPDIR/resvg.tar.gz" -C "$HOME/.local/bin" resvg
chmod +x "$HOME/.local/bin/resvg"

echo
echo "Installed:"
"$HOME/.local/bin/yazi" --version || true
"$HOME/.local/bin/ya" --version || true
"$HOME/.local/bin/resvg" --version || true

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *)
    echo
    echo "Add this to ~/.bashrc and run 'source ~/.bashrc':"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    ;;
esac