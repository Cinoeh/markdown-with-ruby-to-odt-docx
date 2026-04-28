#!/usr/bin/env bash
set -e

# =============================================================
#  Markdown (with ruby tags) → DOCX + ODT Converter
#  Requires: pandoc, python3
#  Filters & scripts are expected in the same directory as this script.
# =============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILTER_DOCX="$SCRIPT_DIR/ruby-filter-docx.lua"
FILTER_ODT="$SCRIPT_DIR/ruby-filter-odt.lua"
POST_PROCESS="$SCRIPT_DIR/post-process-odt.py"

# ── Colors ──────────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; N='\033[0m'

info()  { echo -e "${B}[INFO]${N} $*"; }
ok()    { echo -e "${G}[OK]${N} $*"; }
warn()  { echo -e "${Y}[WARN]${N} $*"; }
err()   { echo -e "${R}[ERR]${N} $*" >&2; }

# ── Dependency check ────────────────────────────────────────
check_deps() {
  local ok=true
  command -v pandoc >/dev/null 2>&1 || { err "pandoc not found"; ok=false; }
  command -v python3  >/dev/null 2>&1 || { err "python3 not found"; ok=false; }
  for f in "$FILTER_DOCX" "$FILTER_ODT" "$POST_PROCESS"; do
    [ -f "$f" ] || { err "Missing: $f"; ok=false; }
  done
  $ok || exit 1
}

# ── Interactive input ───────────────────────────────────────
interactive_mode() {
  local input output_dir out_docx out_odt

  echo -e "${B}============================================${N}"
  echo -e "${B}  Markdown → DOCX / ODT  Converter${N}"
  echo -e "${B}  (supporting <ruby> tags)${N}"
  echo -e "${B}============================================${N}"
  echo

  # Input file
  while true; do
    read -r -p "Input markdown file: " input
    input="${input/#\~/$HOME}"
    input="$(realpath -m "$input" 2>/dev/null || echo "$input")"
    [ -f "$input" ] && break
    err "File not found: $input"
  done

  # Output directory
  read -r -p "Output directory [default: $(dirname "$input")]: " output_dir
  output_dir="${output_dir/#\~/$HOME}"
  [ -z "$output_dir" ] && output_dir="$(dirname "$input")"
  mkdir -p "$output_dir" 2>/dev/null || {
    err "Cannot create output directory: $output_dir"; exit 1
  }
  output_dir="$(cd "$output_dir" && pwd)"

  # File base name
  local base
  base="$(basename "$input" .md)"
  base="$(basename "$base" .markdown)"
  read -r -p "Output base name [default: $base]: " out_base
  [ -z "$out_base" ] && out_base="$base"

  # Formats
  local do_docx=true do_odt=true
  read -r -p "Convert to DOCX? (Y/n): " ans
  [[ "$ans" =~ ^[nN] ]] && do_docx=false
  read -r -p "Convert to ODT?  (Y/n): " ans
  [[ "$ans" =~ ^[nN] ]] && do_odt=false
  $do_docx || $do_odt || { err "Nothing to do."; exit 1; }

  # Overwrite?
  local overwrite=true
  local would_exist=""
  $do_docx && would_exist+=" $output_dir/${out_base}.docx"
  $do_odt  && would_exist+=" $output_dir/${out_base}.odt"
  for f in $would_exist; do
    [ -f "$f" ] && warn "Exists: $f" && overwrite=false
  done
  if ! $overwrite; then
    read -r -p "Overwrite existing files? (y/N): " ans
    [[ "$ans" =~ ^[yY] ]] && overwrite=true || { err "Aborted."; exit 1; }
  fi

  # ── Execute ──────────────────────────────────────────
  echo
  info "Converting..."

  if $do_docx; then
    out_docx="$output_dir/${out_base}.docx"
    info "  → DOCX: $out_docx"
    pandoc "$input" \
      --lua-filter="$FILTER_DOCX" \
      -o "$out_docx" \
      -f markdown 2>&1 </dev/null | while IFS= read -r line; do echo "  [pandoc] $line"; done
    ok "  DOCX done"
  fi

  if $do_odt; then
    out_odt="$output_dir/${out_base}.odt"
    info "  → ODT: $out_odt"
    pandoc "$input" \
      --lua-filter="$FILTER_ODT" \
      -o "$out_odt" \
      -f markdown 2>&1 </dev/null | while IFS= read -r line; do echo "  [pandoc] $line"; done
    python3 "$POST_PROCESS" "$out_odt"
    ok "  ODT done"
  fi

  echo
  echo -e "${G}============================================${N}"
  echo -e "${G}  Done!${N}"
  $do_docx && echo "  DOCX: $out_docx"
  $do_odt  && echo "  ODT:  $out_odt"
  echo -e "${G}============================================${N}"
}

# ── CLI mode (non-interactive, with flags) ──────────────────
cli_mode() {
  local input="" output_dir="" out_base="" do_docx=true do_odt=true

  while [ $# -gt 0 ]; do
    case "$1" in
      -i|--input)    shift; input="$1";;
      -o|--output)   shift; output_dir="$1";;
      -b|--base)     shift; out_base="$1";;
      --docx-only)   do_odt=false;;
      --odt-only)    do_docx=false;;
      -h|--help)     echo "Usage: $0 [-i input.md] [-o outdir] [-b basename] [--docx-only|--odt-only]"; exit 0;;
      *)             err "Unknown: $1"; exit 1;;
    esac
    shift
  done

  [ -z "$input" ] && { err "No input file"; exit 1; }
  [ -f "$input" ] || { err "File not found: $input"; exit 1; }
  input="$(realpath "$input")"

  [ -z "$output_dir" ] && output_dir="$(dirname "$input")"
  mkdir -p "$output_dir"
  output_dir="$(cd "$output_dir" && pwd)"

  [ -z "$out_base" ] && out_base="$(basename "$input" .md)"
  out_base="$(basename "$out_base" .markdown)"

  $do_docx && pandoc "$input" --lua-filter="$FILTER_DOCX" -o "$output_dir/${out_base}.docx" -f markdown
  if $do_odt; then
    pandoc "$input" --lua-filter="$FILTER_ODT" -o "$output_dir/${out_base}.odt" -f markdown
    python3 "$POST_PROCESS" "$output_dir/${out_base}.odt"
  fi
  ok "Done"
}

# ── Main ────────────────────────────────────────────────────
check_deps
if [ $# -eq 0 ]; then
  interactive_mode
else
  cli_mode "$@"
fi
