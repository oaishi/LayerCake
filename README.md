# Layered Response

Get answers in **layers** from Claude and ChatGPT: a quick summary first, then the full response. You can stop reading after any layer.

```markdown
## Summary
Sunlight scatters off air molecules, and blue light scatters much more than red,
so blue reaches your eyes from every part of the sky.

## Response
Sunlight contains every visible color. When it passes through the atmosphere, it
hits nitrogen and oxygen molecules that are far smaller than the light's
wavelength. This causes Rayleigh scattering ...
```

The default layers are **Summary → Response**. You can choose your own:

```
layers: TL;DR: one line | Explain like I'm 5 | Code: a runnable example
```

---

## Contents

- [How it works](#how-it-works)
- [Install](#install)
  - [Claude.ai / Claude Desktop (skill)](#claudeai--claude-desktop-skill)
  - [Claude.ai Projects (no upload needed)](#claudeai-projects-no-upload-needed)
  - [Claude Code (plugin)](#claude-code-plugin)
  - [ChatGPT](#chatgpt)
  - [Other tools](#other-tools)
- [Commands](#commands)
- [Writing your own layers](#writing-your-own-layers)
- [Walkthrough: test it in the Claude app](#walkthrough-test-it-in-the-claude-app)
- [Walkthrough: test it in Claude Code](#walkthrough-test-it-in-claude-code)
- [Layer ideas](#layer-ideas)
- [Troubleshooting](#troubleshooting)
- [Repo layout](#repo-layout)
- [Contributing](#contributing)

---

## How it works

Layering is a mode. When it's on, every reply is split into layers, and each layer goes deeper than the one before it:

1. Each layer starts with a `## Layer name` heading.
2. The first layer alone answers the question.
3. Each later layer adds detail and doesn't repeat earlier layers.
4. Layer length follows the question. A quick question gets quick layers.
5. If a layer doesn't fit a reply (for example, a Code layer on a history question), its heading stays and the layer says so in one line.

You control the mode with short messages like `layers on`, `layers off` and `layers: A | B | C`. In Claude Code you use the `/layers` command instead.

The same rules are packaged in a different form for each tool:

| Tool | Form | How layering stays on |
|---|---|---|
| Claude.ai / Desktop | [Skill](plugins/layered-response/skills/layered-response/SKILL.md) | For the rest of the chat once you turn it on |
| Claude.ai Projects | [Prompt](prompt/layered-response.md) in project instructions | Always on in that project |
| Claude Code | [Plugin](plugins/layered-response/) (hook, command and skill) | Saved setting that lasts between sessions |
| ChatGPT | [Custom GPT or Custom Instructions](chatgpt/README.md) | Always on in that GPT, or in every chat |
| Anything else | [Prompt](prompt/layered-response.md) | Wherever you paste it |

---

## Install

### Claude.ai / Claude Desktop (skill)

Skills need **code execution** turned on: go to **Settings → Capabilities → Code execution and file creation**.

1. **Get the zip.** Either download `layered-response-skill.zip` from the GitHub release, or build it from the repo:
   ```sh
   ./package-skill.sh
   # → dist/layered-response-skill.zip
   ```
2. **Upload it.** Go to **Settings → Capabilities → Skills → Upload skill**, choose the zip, and make sure the skill's toggle is on.
3. **Use it.** In any chat, type `layers on`, then ask a question.

The skill loads when your message matches it, for example "layers on", "answer in layers" or "layers: ...". After that, layering stays on for the rest of that chat.

### Claude.ai Projects (no upload needed)

Use this if you can't upload skills, or if you want layering always on in some chats:

1. Create a **Project** in Claude.ai.
2. Open **Project instructions** and paste in everything from [`prompt/layered-response.md`](prompt/layered-response.md).
3. Every chat in that project starts with layering on. `layers off` and the other commands still work.

### Claude Code (plugin)

From GitHub:

```
/plugin marketplace add YOUR_GITHUB_USERNAME/layered-response
/plugin install layered-response@layered-response
```

From a local copy (handy while you're developing):

```sh
claude --plugin-dir ./plugins/layered-response
```

Layering is **off** after install, and `/layers` turns it on. The setting is stored in `~/.claude/layered-response/state` and applies to every project.

Behind the scenes, a `UserPromptSubmit` hook runs [`layers.sh`](plugins/layered-response/scripts/layers.sh) on every prompt. When layering is on, the script adds the layer instructions to the prompt. The `/layers` command changes the saved setting. The plugin also includes the skill, so you can ask for a single layered answer without turning the mode on.

### ChatGPT

See [chatgpt/README.md](chatgpt/README.md). There are two options:

- **Custom GPT** (recommended): paste [`prompt/layered-response.md`](prompt/layered-response.md) in as the GPT's instructions.
- **Custom Instructions**: paste [`chatgpt/custom-instructions.txt`](chatgpt/custom-instructions.txt), which fits ChatGPT's 1,500-character limit, to turn layering on in every chat.

### Other tools

[`prompt/layered-response.md`](prompt/layered-response.md) is a general prompt. You can paste it into Gemini Gems, an API system prompt, Cursor rules, Open WebUI, or anywhere else that accepts a system prompt.

---

## Commands

| Claude.ai / ChatGPT | Claude Code | Effect |
|---|---|---|
| `layers on` | `/layers on` | Turn layering on |
| `layers off` | `/layers off` | Turn layering off and answer normally |
| (none) | `/layers` | Toggle on/off |
| `layers: A \| B \| C` | `/layers A \| B \| C` | Set your own layers (also turns layering on) |
| `layers reset` | `/layers reset` | Go back to Summary \| Response |
| `layers status` | `/layers status` | Show whether layering is on and list the layers |

In Claude.ai and ChatGPT, a message that only changes a setting gets a one-line confirmation, not a layered reply.

---

## Writing your own layers

```
layers: TL;DR: one line | Explain like I'm 5 | Code: a runnable example, if relevant
        └─name─┘ └desc──┘   └────name only────┘   └name┘ └──────description───────┘
```

- **Separate layers with `|`.** Commas also work when there's no `|`, as in `layers: Short, Long`.
- **Text after the first colon is a description** that tells the model what goes in that layer. Without one, the model uses the most natural reading of the name.
- **Order matters.** Layers appear in the order you list them. Put the shortest layer first.
- **If a description contains commas, separate layers with `|`.** Otherwise each comma starts a new layer.
- In Claude Code, you can also put one layer per line:
  ```
  /layers set
  Answer
  Why: the reasoning
  Sources
  ```

---

## Walkthrough: test it in the Claude app

Try these in order in **one new chat** after installing the [skill](#claudeai--claude-desktop-skill) or setting up a [Project](#claudeai-projects-no-upload-needed). Each step lists what you should see.

> If you used a Project, layering is already on, so you can skip step 1.

### 1. Turn it on

```
layers on
```

✅ **Expect:** a one-line confirmation, such as *"Layers ON: Summary → Response"*, with no headings.

### 2. Ask an ordinary question

```
Why is the sky blue?
```

✅ **Expect:**
- `## Summary`: 1–3 sentences that already answer the question (blue light scatters more).
- `## Response`: the full explanation (Rayleigh scattering, why it's not violet, sunsets).
- Nothing before `## Summary`, and the Response doesn't start by repeating the Summary.

### 3. Ask a short question

```
What's 15% of 80?
```

✅ **Expect:** both layers, but very short. The Summary should be about "12" and the Response a line or two showing the math. The layers shouldn't be padded out.

### 4. Set your own layers

```
layers: TL;DR: one line | Explain like I'm 5 | Expert detail
```

✅ **Expect:** a one-line confirmation listing *TL;DR → Explain like I'm 5 → Expert detail*.

Then ask:

```
How do vaccines work?
```

✅ **Expect:** three headings in that order. The TL;DR is one line. The ELI5 layer uses simple words and an analogy. The Expert layer covers antigens, B and T cells, and memory cells. Each layer adds something new.

### 5. Try a coding preset

```
layers: Answer: one line | Code | Why it works | Gotchas
```

```
How do I reverse a string in Python?
```

✅ **Expect:** `## Answer` with something like *"Use slicing: s[::-1]"*, `## Code` with a code block, then a short explanation and the edge cases (Unicode combining characters, for example).

### 6. Ask something where a layer doesn't fit

With the coding layers still set:

```
Who wrote Hamlet?
```

✅ **Expect:** all four headings are still there, and `## Code` says in one line that it doesn't apply. It shouldn't invent code.

### 7. Check the status

```
layers status
```

✅ **Expect:** layering is ON, and the four coding layers are listed.

### 8. Reset to the defaults

```
layers reset
```

```
What's the difference between TCP and UDP?
```

✅ **Expect:** a confirmation, then a reply with just `## Summary` and `## Response`.

### 9. Turn it off

```
layers off
```

```
Give me three name ideas for a coffee shop.
```

✅ **Expect:** a confirmation, then a normal reply with no layer headings.

### 10. Get a single layered answer (in a new chat)

Start a new chat without turning layering on:

```
Answer this in layers: should I learn Rust or Go first?
```

✅ **Expect:** that one reply comes back layered (Summary → Response). This shows the skill also loads when you just ask for layers.

### Things to watch for

| Symptom | Likely cause |
|---|---|
| No layers at all after `layers on` | The skill didn't load. Check that it's toggled on in Settings and that code execution is enabled. |
| Layers stop partway through a long chat | The instructions dropped out of context. Send `layers on` again, or use a Project. |
| The Response repeats the Summary | The model ignored a rule. Please open an issue with the prompt you used. |

---

## Walkthrough: test it in Claude Code

```sh
claude --plugin-dir ./plugins/layered-response
```

| Step | Type | Expect |
|---|---|---|
| 1 | `/layers status` | `Layered responses: OFF` and `Layers: Summary → Response` |
| 2 | `/layers` | `Layered responses: ON` |
| 3 | `explain what a git rebase is` | A reply with `## Summary`, then `## Response` |
| 4 | `/layers TL;DR \| Steps \| Pitfalls` | `ON` and `Layers: TL;DR → Steps → Pitfalls` |
| 5 | `how do I undo my last commit?` | Three layers in that order |
| 6 | Ask for a code change, e.g. `add a docstring to layers.sh` | Claude edits the file normally, and only its **final** message is layered |
| 7 | Quit, start `claude` again, and ask anything | Still layered, because the setting persists |
| 8 | `/layers reset` then `/layers off` | Back to normal replies |

You can test the script directly without touching your real setting:

```sh
export LAYERED_RESPONSE_HOME=/tmp/layers-test
S=plugins/layered-response/scripts/layers.sh
$S on                                    # turn on
$S "TL;DR: one line | Details"           # set layers (quote it: ; and | are shell syntax)
echo '{"prompt":"hi"}' | $S hook         # prints the instructions Claude receives
$S off; echo '{"prompt":"hi"}' | $S hook # prints nothing
```

---

## Layer ideas

| Use | Layers |
|---|---|
| Default | `Summary \| Response` |
| Learning | `TL;DR \| Explain like I'm 5 \| Expert detail` |
| Coding | `Answer: one line \| Code \| Why it works \| Gotchas` |
| How-to | `Answer \| Steps \| Common mistakes` |
| Research | `Bottom line \| Evidence \| Caveats \| Sources` |
| Decisions | `Recommendation \| Trade-offs \| Alternatives` |
| Writing feedback | `Verdict: one line \| What works \| What to fix \| Rewritten version` |
| Studying | `Key idea \| Example \| Quiz me: 3 questions` |

---

## Troubleshooting

**Claude.ai: "layers on" does nothing.** Check that the skill is uploaded and toggled on, and that code execution is enabled. Try `Use the layered-response skill. layers on`. If skills aren't available on your plan, use the [Project](#claudeai-projects-no-upload-needed) setup instead.

**Claude Code: `/layers` isn't found.** Run `/plugin` and check that `layered-response` is installed and enabled. If another plugin also has a `/layers` command, use `/layered-response:layers`.

**Claude Code: `/layers` asks for permission or fails.** The command runs `scripts/layers.sh` directly. Approve it, or make sure the script is executable: `chmod +x plugins/layered-response/scripts/layers.sh`.

**Claude Code: Windows.** The hook is a bash script. It runs under Git Bash or WSL, which Claude Code on Windows already uses.

**ChatGPT forgets custom layers in a new chat.** That's expected. Custom layers last for one chat. To change the default, edit the default layers in your instructions.

---

## Repo layout

```
.claude-plugin/marketplace.json        Claude Code marketplace entry
plugins/layered-response/
  .claude-plugin/plugin.json           plugin manifest
  commands/layers.md                   /layers command
  hooks/hooks.json                     injects layer instructions on each prompt
  scripts/layers.sh                    state and prompt builder (bash)
  skills/layered-response/SKILL.md     skill for Claude Code and Claude.ai
chatgpt/                               Custom GPT and Custom Instructions setup
prompt/layered-response.md             general prompt for other tools
package-skill.sh                       builds dist/layered-response-skill.zip
```

The rules exist in four copies: `SKILL.md`, `prompt/layered-response.md`, `chatgpt/custom-instructions.txt`, and the hook text in `layers.sh`. If you change them, change all four.

## Contributing

PRs welcome. Ideas include more presets, Cursor or Copilot rules files, a Gemini Gem guide, and per-project settings in Claude Code. Please run through the [walkthrough](#walkthrough-test-it-in-the-claude-app) before opening a PR that changes the rules.

## License

[MIT](LICENSE)
