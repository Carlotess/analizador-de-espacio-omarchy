#!/bin/bash
# Instala (o desinstala con --uninstall) el Analizador de espacio para Omarchy.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"
NAUT="$HOME/.local/share/nautilus/scripts"
SCRIPTS=("Analizador de espacio grafico")
OLD_SCRIPTS=("Analizar espacio" "Analizar espacio (grafico)")   # nombres de versiones anteriores

if [[ "${1:-}" == "--uninstall" ]]; then
  rm -f "$BIN/treemap" "$BIN/treemap.html" "$BIN/.treemap.html" "$BIN/android-du"
  for s in "${SCRIPTS[@]}" "${OLD_SCRIPTS[@]}"; do rm -f "$NAUT/$s"; done
  echo "Desinstalado."
  exit 0
fi

# Dependencias (solo avisa; no instala nada por su cuenta)
missing=()
for c in python3 chromium du df; do command -v "$c" >/dev/null || missing+=("$c")
done
command -v adb >/dev/null || echo "Aviso: falta 'adb' (solo para escanear Android). Instálalo con: sudo pacman -S android-tools"
if ((${#missing[@]})); then
  echo "Faltan dependencias obligatorias: ${missing[*]}" >&2
  exit 1
fi

mkdir -p "$BIN" "$NAUT"
install -m 755 "$DIR/bin/treemap" "$DIR/bin/android-du" "$BIN/"
install -m 644 "$DIR/bin/treemap.html" "$BIN/"
rm -f "$BIN/.treemap.html"   # nombre usado por versiones anteriores
for s in "${OLD_SCRIPTS[@]}"; do rm -f "$NAUT/$s"; done   # quita las opciones antiguas
for s in "${SCRIPTS[@]}"; do install -m 755 "$DIR/nautilus/$s" "$NAUT/$s"; done

case ":$PATH:" in *":$BIN:"*) ;; *) echo "Aviso: $BIN no está en tu PATH." ;; esac
nautilus -q 2>/dev/null || true
echo "Listo. Click derecho en una carpeta > Scripts > Analizador de espacio grafico."
