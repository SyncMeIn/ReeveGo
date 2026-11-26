#!/usr/bin/env sh
set -eu

REPO="SyncMeIn/ReeveGo"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
case "$OS" in
  linux|darwin) ;;
  *) echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac
case "$ARCH" in
  x86_64|amd64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

ASSET="reeve-go-${OS}-${ARCH}"
BASE_URL="https://github.com/${REPO}/releases/latest/download"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading ${ASSET} from ${REPO}..."
curl -fsSL "${BASE_URL}/${ASSET}" -o "${TMP_DIR}/${ASSET}"
curl -fsSL "${BASE_URL}/sha256sums.txt" -o "${TMP_DIR}/sha256sums.txt"

echo "Verifying SHA-256 checksum..."
if command -v sha256sum >/dev/null 2>&1; then
  (cd "$TMP_DIR" && sha256sum -c sha256sums.txt --ignore-missing)
elif command -v shasum >/dev/null 2>&1; then
  WANT="$(grep " ${ASSET}$" "${TMP_DIR}/sha256sums.txt" | awk '{print $1}')"
  GOT="$(shasum -a 256 "${TMP_DIR}/${ASSET}" | awk '{print $1}')"
  if [ "$WANT" != "$GOT" ]; then
    echo "Checksum mismatch! want=$WANT got=$GOT" >&2
    exit 1
  fi
fi

mkdir -p "${INSTALL_DIR}"
install -m 755 "${TMP_DIR}/${ASSET}" "${INSTALL_DIR}/reeve-go"
echo "Installed to ${INSTALL_DIR}/reeve-go"
"${INSTALL_DIR}/reeve-go" --version || true
