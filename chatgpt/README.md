# LayerCake for ChatGPT

ChatGPT has no plugin system for changing how it formats replies, so there are two ways to set this up.

## Option A: a Custom GPT (recommended)

Layering is on in every chat you start with this GPT, and the rest of ChatGPT is unaffected.

1. Go to **Explore GPTs → Create → Configure**.
2. Fill in:
   - **Name:** LayerCake
   - **Description:** Answers in layers: a quick summary, then the full response. Set your own layers with "layers: A | B | C".
   - **Instructions:** paste everything in [`../prompt/layercake.md`](../prompt/layercake.md).
   - **Conversation starters:**
     - `Why is the sky blue?`
     - `layers: TL;DR | Explain like I'm 5 | Expert detail`
     - `layers: Answer | Steps | Common mistakes`
     - `layers status`
3. Save. You can share it with a link or publish it to the GPT Store.

## Option B: Custom Instructions (every chat)

This turns layering on for all your ChatGPT chats. You can still say `layers off` in any chat.

1. Go to **Settings → Personalization → Custom instructions**.
2. Paste [`custom-instructions.txt`](custom-instructions.txt) into **"What traits should ChatGPT have?"** (the field may have a slightly different name in your version).

The same text also works as a **Project** instruction, which limits layering to the chats in that project.
