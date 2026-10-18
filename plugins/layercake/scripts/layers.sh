#!/usr/bin/env bash
# layercake: keeps the on/off state and the layer list, and prints the
# instructions that the UserPromptSubmit hook injects into each prompt.
#
# Usage:
#   layers.sh hook             print the injected instructions if layering is ON
#   layers.sh [ARGS]           manage state (ARGS may also arrive on stdin)
#     (nothing) | toggle       flip ON/OFF
#     on | off | status | reset | help
#     set SPEC                 e.g. "TL;DR: one line | Details | Code example"
#     SPEC                     shorthand for "set SPEC"
#
# SPEC is a list of layers separated by "|" (or by "," when there is no "|").
# Each layer is "Name" or "Name: what this layer should contain".

set -u

STATE_DIR="${LAYERCAKE_HOME:-$HOME/.claude/layercake}"
STATE_FILE="$STATE_DIR/state"
DEFAULT_LAYERS="Summary: 1-3 sentences that give the gist of the answer | Response: your full answer, as you would normally write it"

enabled="off"
layers="$DEFAULT_LAYERS"

load() {
  [ -f "$STATE_FILE" ] || return 0
  while IFS='=' read -r key value; do
    case "$key" in
      enabled) enabled="$value" ;;
      layers) [ -n "$value" ] && layers="$value" ;;
    esac
  done < "$STATE_FILE"
}

save() {
  mkdir -p "$STATE_DIR"
  printf 'enabled=%s\nlayers=%s\n' "$enabled" "$layers" > "$STATE_FILE"
}

# Prints one "name<TAB>description" line per layer.
parse_layers() {
  local sep=','
  case "$1" in *'|'*) sep='|' ;; esac
  printf '%s\n' "$1" | awk -v sep="$sep" '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    {
      count = split($0, parts, sep)
      for (i = 1; i <= count; i++) {
        item = trim(parts[i])
        if (item == "") continue
        c = index(item, ":")
        if (c > 0) { name = trim(substr(item, 1, c - 1)); desc = trim(substr(item, c + 1)) }
        else { name = item; desc = "" }
        if (name != "") print name "\t" desc
      }
    }'
}

# Re-serializes a SPEC so it is always stored with "|" separators.
normalize_layers() {
  parse_layers "$1" | awk -F '\t' '
    { item = ($2 == "") ? $1 : $1 ": " $2; out = out (NR > 1 ? " | " : "") item }
    END { print out }'
}

layer_list() {
  parse_layers "$layers" | awk -F '\t' -v indent="$1" '
    { printf "%s%d. %s", indent, NR, $1; if ($2 != "") printf " — %s", $2; print "" }'
}

layer_names() {
  parse_layers "$layers" | awk -F '\t' '{ out = out (NR > 1 ? " → " : "") $1 } END { print out }'
}

status() {
  local state
  state=$(printf '%s' "$enabled" | tr '[:lower:]' '[:upper:]')
  echo "LayerCake: $state"
  echo "Layers: $(layer_names)"
  layer_list "  "
}

hook() {
  # Don't layer the reply to /layers itself.
  if grep -Eq '"prompt"[[:space:]]*:[[:space:]]*"/(layercake:)?layers'; then
    return 0
  fi
  [ "$enabled" = "on" ] || return 0
  cat <<EOF
<layercake>
Layered responses are ON. Structure your final reply to the user as the layers below, in this order. Start each layer with a level-2 Markdown heading of its name (for example "## $(parse_layers "$layers" | head -n 1 | cut -f 1)") and put nothing before the first layer.

$(layer_list "")

Rules:
- Earlier layers are shorter and give the gist; later layers go deeper. Someone who reads only the first layer should still get the answer.
- Later layers add detail. They don't restate earlier layers.
- Match length to the question. A short question gets short layers.
- If a layer doesn't fit this reply, keep its heading and say so in one line.
- Apply this only to your final reply for the turn, not to tool calls or progress updates.
</layercake>
EOF
}

usage() {
  cat <<'EOF'
/layers                 toggle layered responses on/off
/layers on | off        turn on or off
/layers status          show the current state and layers
/layers reset           go back to the defaults: Summary | Response
/layers A | B | C       use your own layers (and turn on)
/layers TL;DR: one line | Details | Code: a runnable example
EOF
}

load

if [ "${1:-}" = "hook" ]; then
  hook
  exit 0
fi

if [ $# -gt 0 ]; then
  raw="$*"
elif [ ! -t 0 ]; then
  raw=$(cat)
else
  raw=""
fi

# Join multi-line input with "|" so each line can be its own layer.
raw=$(printf '%s\n' "$raw" | awk '
  { gsub(/^[ \t]+|[ \t]+$/, "") }
  NF { out = out (out == "" ? "" : " | ") $0 }
  END { print out }')

command=$(printf '%s' "$raw" | awk '{ print tolower($1) }')
case "$raw" in
  *[[:space:]]*) rest="${raw#*[[:space:]]}" ;;
  *) rest="" ;;
esac

case "$command" in
  "" | toggle)
    if [ "$enabled" = "on" ]; then enabled="off"; else enabled="on"; fi
    save; status ;;
  on | off)
    enabled="$command"; save; status ;;
  status)
    status ;;
  reset)
    layers="$DEFAULT_LAYERS"; enabled="on"; save; status ;;
  help | -h | --help)
    usage ;;
  *)
    [ "$command" = "set" ] && spec="$rest" || spec="$raw"
    spec=$(normalize_layers "$spec")
    if [ -z "$spec" ]; then
      echo "No layers given." >&2
      usage >&2
      exit 1
    fi
    layers="$spec"; enabled="on"; save; status ;;
esac
