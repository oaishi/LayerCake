---
name: layercake
description: Answers in stacked layers, by default a short Summary followed by the full Response, and lets the user turn layering on or off or define their own layers (e.g. "TL;DR | Explanation | Code"). Use when the user says "layers on", "layered mode", "answer in layers", "summary first", sets custom layers with "layers: ...", or says "layers off".
---

# LayerCake

Answer in **layers**: each one is a complete take on the answer, and each goes deeper than the one before it. A reader can stop after any layer and still have what they need.

## Turning it on and off

Once this skill is in use, layering stays ON for the rest of the conversation until the user changes it. The user controls it with short messages (case doesn't matter):

| Message | Effect |
|---|---|
| `layers on` | Turn layering on |
| `layers off` | Turn layering off and answer normally |
| `layers: A \| B \| C` | Use custom layers, in that order (also turns layering on) |
| `layers reset` | Go back to the default layers |
| `layers status` | Show whether layering is on and list the current layers |

When a message only changes settings, reply with one confirmation line, for example "Layers ON: TL;DR → Details → Code". Don't layer that reply.

## Layers

**Default:**
1. **Summary**: 1–3 sentences that give the gist of the answer.
2. **Response**: the full answer, as you would normally write it.

**Custom layers** are separated by `|` (or by commas when there is no `|`). A layer can have a description after a colon, which tells you what goes in it:

```
layers: TL;DR: one line | Explain like I'm 5 | Code: a runnable example
```

A layer with no description gets the most natural reading of its name.

## Format

- Start each layer with a level-2 heading of its name (`## Summary`) and put nothing before the first layer.
- Keep the layers in the order the user gave.

## Rules

- Earlier layers are shorter and give the gist; later layers go deeper. Someone who reads only the first layer should still get the answer.
- Later layers add detail. They don't restate earlier layers.
- Match length to the question. A short question gets short layers.
- If a layer doesn't fit this reply, keep its heading and say so in one line.
- When you use tools or work in steps, layer only your final reply, not progress updates.

## Example

User: *Why is the sky blue?*

```markdown
## Summary
Sunlight scatters off air molecules, and blue light scatters much more than red, so blue reaches your eyes from every part of the sky.

## Response
Sunlight contains every visible color. When it passes through the atmosphere, it hits nitrogen and oxygen molecules that are far smaller than the light's wavelength. This causes **Rayleigh scattering**, which grows sharply as wavelength gets shorter (∝ 1/λ⁴), so blue light (~450 nm) scatters about 5× more than red (~700 nm).

That scattered blue light comes at you from every direction, so the whole sky looks blue. Violet scatters even more, but sunlight contains less of it and our eyes are less sensitive to it. At sunset, light travels through much more air, most of the blue is scattered away before it reaches you, and the reds and oranges are left.
```
