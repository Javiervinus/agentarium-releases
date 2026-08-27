#!/bin/sh
# Instalador de Agentarium (macOS y Linux). Uso:
#   curl -fsSL https://raw.githubusercontent.com/Javiervinus/agentarium-releases/main/install.sh | sh
#
# Qué hace: detecta tu sistema y chip, descarga el binario del último release,
# verifica su SHA-256, lo instala en ~/.local/bin/agentarium, lo deja arrancando
# con tu sesión (LaunchAgent / systemd --user), instala los hooks de Claude Code
# y abre la web. Todo sin sudo. Variables opcionales:
#   AGENTARIUM_INSTALL_DIR=/otra/ruta   AGENTARIUM_NO_SERVICE=1   AGENTARIUM_NO_HOOKS=1
#   AGENTARIUM_NO_OPEN=1                AGENTARIUM_VERSION=v0.2.0 (por defecto: latest)
set -eu

REPO="${AGENTARIUM_RELEASES_REPO:-Javiervinus/agentarium-releases}"
INSTALL_DIR="${AGENTARIUM_INSTALL_DIR:-${HOME}/.local/bin}"
VERSION="${AGENTARIUM_VERSION:-latest}"
PORT_URL="http://127.0.0.1:${AGENTARIUM_PORT:-4517}"

say() { printf '%s\n' "$*"; }
fail() { printf 'agentarium: %s\n' "$*" >&2; exit 1; }

os=$(uname -s | tr '[:upper:]' '[:lower:]')
case "${os}" in
  darwin|linux) ;;
  *) fail "sistema no soportado por este instalador: ${os} (Windows: descarga agentarium-windows-x64.exe del release)" ;;
esac
arch=$(uname -m)
case "${arch}" in
  arm64|aarch64) arch=arm64 ;;
  x86_64|amd64) arch=x64 ;;
  *) fail "arquitectura no soportada: ${arch}" ;;
esac
asset="agentarium-${os}-${arch}"

if [ "${VERSION}" = "latest" ]; then
  base="https://github.com/${REPO}/releases/latest/download"
else
  base="https://github.com/${REPO}/releases/download/${VERSION}"
fi

command -v curl >/dev/null 2>&1 || fail "necesito curl"

tmp=$(mktemp -d 2>/dev/null || mktemp -d -t agentarium)
trap 'rm -rf "${tmp}"' EXIT

say "▸ descargando ${asset} (${VERSION}) de ${REPO} ..."
curl -fsSL "${base}/${asset}" -o "${tmp}/${asset}" || fail "no pude descargar ${base}/${asset}"
curl -fsSL "${base}/checksums.txt" -o "${tmp}/checksums.txt" || fail "no pude descargar checksums.txt"

expected=$(grep " ${asset}\$" "${tmp}/checksums.txt" | awk '{print $1}' | head -1)
[ -n "${expected}" ] || fail "checksums.txt no lista ${asset}"
if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "${tmp}/${asset}" | awk '{print $1}')
else
  actual=$(shasum -a 256 "${tmp}/${asset}" | awk '{print $1}')
fi
[ "${actual}" = "${expected}" ] || fail "checksum incorrecto: se aborta"
say "▸ checksum verificado"

mkdir -p "${INSTALL_DIR}"
chmod +x "${tmp}/${asset}"
mv -f "${tmp}/${asset}" "${INSTALL_DIR}/agentarium"
bin="${INSTALL_DIR}/agentarium"
say "▸ instalado en ${bin} ($("${bin}" --version))"

if [ -z "${AGENTARIUM_NO_SERVICE:-}" ]; then
  "${bin}" install-service || say "  (no se pudo instalar el arranque automático; corre \`agentarium\` a mano)"
fi
if [ -z "${AGENTARIUM_NO_HOOKS:-}" ]; then
  "${bin}" install-hooks || say "  (no se pudieron instalar los hooks; el estado se infiere igual)"
fi

case ":$PATH:" in
  *":${INSTALL_DIR}:"*) ;;
  *) say "ℹ agrega ${INSTALL_DIR} a tu PATH para usar el comando \`agentarium\` (p. ej. en ~/.zshrc o ~/.bashrc):"
     say "    export PATH=\"${INSTALL_DIR}:\${PATH}\"" ;;
esac

if [ -z "${AGENTARIUM_NO_SERVICE:-}" ]; then
  say "✓ Agentarium corre en ${PORT_URL} (arranca solo con tu sesión)."
  if [ -z "${AGENTARIUM_NO_OPEN:-}" ]; then
    sleep 1
    if [ "${os}" = darwin ]; then open "${PORT_URL}" 2>/dev/null || true; else xdg-open "${PORT_URL}" 2>/dev/null || true; fi
  fi
else
  say "✓ Instalado. Arráncalo con: ${bin}"
fi
say "  Actualizar: agentarium update · Quitar: agentarium uninstall-service && agentarium uninstall-hooks && rm ${bin}"
