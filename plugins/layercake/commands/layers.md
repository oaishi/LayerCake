---
description: Toggle layered responses, or set your own layers
argument-hint: "[on | off | status | reset | Layer 1 | Layer 2 | ...]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/layers.sh:*)
---

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/layers.sh" <<'LAYERS_ARGS'
$ARGUMENTS
LAYERS_ARGS
```

The output above comes from the layercake plugin. Confirm the result to the user in one short line, for example "LayerCake is ON: Summary → Response". If the output is a usage message, show it as is. Don't run any other tools, and don't format this reply in layers.
