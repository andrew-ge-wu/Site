---
title: "Day 1 of Jarela: Building My Own Lightweight Claude-Code-ish Replacement"
date: "2026-05-17T22:30:00+02:00"
description: "I got tired of how complex my openclaw setup had gotten — too many tools, too many integrations I never used. So I started building a small LangGraph-based GUI for multi-agent workflows on my own laptop. This is day 1: 31 commits, a lot of streaming/reconnection pain, and three different GitHub Copilot auth flavors to untangle."
draft: false
author: "Andrew Wu"
tags: ["LangGraph", "Claude Code", "Multi-Agent", "Next.js", "Personal Projects", "Developer Tools", "AI Tooling", "WebSocket", "SQLite", "Self-Hosted"]
categories: ["AI Tools", "Development"]
keywords: ["LangGraph GUI", "Claude Code alternative", "multi-agent local app", "self-hosted AI agent", "LangGraph Next.js", "agent runtime", "personal AI tooling", "openclaw replacement", "Jarela"]
lastmod: "2026-05-17T22:30:00+02:00"
weight: 1
featured: false
---

# Day 1 of Jarela

> Cross-posted from my development journal in the [Jarela repo](https://github.com/andrew-ge-wu/jarela).
> The project was called **langGUI** at the time; I rebranded it to **Jarela** on day 3.

I've been recently playing with openclaw. I was so into the capability and
the integrations — all those tools, all those connectors — that I kept
piling things on. But in reality I only need a handful of them. It's too
complex to my liking.

So I thought: maybe I can build a lightweight LangGraph GUI, multiple
agents for different tasks, each with its own instructions and its own
model. And here we go — **langGUI**, my small project to replace my
openclaw setup.

The mental model is dead simple:

- **Agents** are recipes (model + system prompt + tools).
- **Threads** are conversations.
- **The runtime** is LangGraph with a SQLite checkpoint so I can close
  the tab and come back later.

Everything lives under `~/.langgui` on the local box. No cloud, no
telemetry, no "sign in with X" — just me on my laptop talking to whichever
model is best for the task.

## What I got working

**Day 1: 31 commits.** Not pretty, not cohesive — this is the "throw the
walls up and check they hold" day.

The core loop landed first: Next.js App Router + a LangGraph agent
runtime + a SQLite checkpointer. Then I bolted on the obvious chrome:
a chat view, an agent selector, a message bubble that renders markdown,
streaming via WebSocket — and a fallback over SSE, because mobile drops
the WS the moment the screen sleeps.

A few things I knew I'd want from day one:

### Multiple providers, one agent shape

Anthropic, OpenAI, Gemini, GitHub Copilot, DeepSeek — agents just pick
a `provider + model` pair. Most of the day's "Copilot fix" commits were
me untangling GitHub's three different auth flavors:

- OAuth **device-flow** tokens (what VS Code Copilot uses internally),
- **Personal access tokens** (PATs),
- **GitHub Models API** tokens (a different surface entirely).

They look like one product. They are not one product. The catalog
endpoint behaves differently for each, the chat endpoint behaves
differently for each, and the only way I got it stable was to route
PATs explicitly to the Models API and reserve the Copilot endpoints
for device-flow tokens.

### Background work that wakes itself up

A scheduler that wakes on SSE subscribe so a cron-driven agent can
ping me when something happens. Teams-style in-app toasts for the
result, click-to-jump straight to the thread that emitted it.

### Don't lose what's in flight

Three small details that matter more than they sound:

- Auto-scroll only when content actually grows (not on every re-render).
- A message queue so anything I type during streaming gets drained as
  part of the same turn, not silently dropped.
- A streaming bubble that survives the `done` event so the layout
  doesn't jump when the agent's last token lands.

### Identity over Tailscale

Wired Tailscale identity passthrough on both the HTTP middleware and
the WebSocket upgrade. When I open this from my phone over the tailnet,
the server already knows it's me — no login screen, no shared password.
Loopback gets a free pass for local dev.

### Auto-start on Windows

A scheduled-task installer so the box boots, logs in, and the app is
already there waiting. The whole point of this is to be ambient — if I
have to remember to start it, I won't use it.

## What I learned

A few things I want to remember:

- **Streaming is the easy part. Reconnection is the hard part.** I had
  the happy path live in under an hour. I spent the rest of the day on
  the cases where the socket dies mid-token: mobile Safari throttling,
  screen sleeps, tab backgrounding, Tailscale path renegotiation.
- **Scheduler + SSE + Next.js's hot-reload is a quiet trap.** I lost
  an hour to the scheduler getting collected and re-instantiated
  because a module reload created a second instance. Pin it to
  `globalThis` and move on.
- **GitHub Copilot's API surface is not one API.** Device-flow tokens,
  PATs, and the Models registry are three doors that look like one.
  Plan for that.

A few rough edges I left for tomorrow-me: the early Copilot commits
have plain English subject lines ("Fix this", "Handle that") — no
`type(scope):` prefix. I hadn't fully committed to Conventional Commits
yet on day 1. Past-me, learn to type a colon.

That's enough for a day. Tomorrow: tools — the file toolkit, the
WhatsApp bridge, and a lot of "this is what should have been on day 1"
fixes to the chat experience.

---

*If you want to follow along, the repo is open at
[github.com/andrew-ge-wu/jarela](https://github.com/andrew-ge-wu/jarela).
It's a personal project — no roadmap, no SLA, no warranty. Just notes
from the workshop.*
