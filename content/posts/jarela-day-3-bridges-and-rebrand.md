---
title: "Day 3 of Jarela: WhatsApp Bridges, Native Gmail, and a Rebrand With a State Migration"
date: "2026-05-17T22:40:00+02:00"
description: "Day 3 of building a lightweight LangGraph GUI. The app stops being a chat window and becomes an endpoint: WhatsApp via Baileys with proper @lid routing, native Gmail with drafts-only sending, hotloaded providers, and a full rebrand from langGUI to Jarela complete with state migration."
draft: false
author: "Andrew Wu"
tags: ["LangGraph", "WhatsApp", "Baileys", "Gmail", "OAuth", "MCP", "Bridges", "Multi-Agent", "Self-Hosted", "AI Tooling", "Conventional Commits"]
categories: ["AI Tools", "Development"]
keywords: ["LangGraph WhatsApp bridge", "Baileys @lid routing", "Gmail OAuth desktop", "drafts-only AI email", "MCP isolation", "hotload LLM providers", "rebrand state migration", "Jarela day 3", "langGUI rename"]
lastmod: "2026-05-17T22:40:00+02:00"
weight: 1
featured: false
---

# Day 3 of Jarela

> Cross-posted from my development journal in the
> [Jarela repo](https://github.com/andrew-ge-wu/jarela).

Today the app stopped being a chat window and became an **endpoint**.
It can receive WhatsApp messages, draft Gmail replies, embed maps in
its responses, know where I am if I let it. It also got a new name —
**Jarela**.

**30 commits.** Most are small fixes; two are structural.

## Bridges, with WhatsApp first

The structural one. I introduced a **Bridge** concept: an inbound
channel that routes messages from somewhere-else into an agent thread,
and routes the agent's reply back out. WhatsApp via Baileys is the first
implementation, written so the next bridge (Telegram, SMS, whatever)
drops into the same shape. The decision is captured in
[ADR-0004](https://github.com/andrew-ge-wu/jarela/blob/main/docs/adr/0004-bridges-and-whatsapp-baileys.md).

Things that bit me:

- **Baileys rejects pairing unless you announce a recognized browser
  identifier.** `Browsers.ubuntu('Chrome')` works. The default
  Macintosh/Safari string doesn't. I tried to revert this twice
  thinking I'd misremembered; I had not.
- **Show the right device name in WhatsApp's linked-devices list.**
  Started as "LangGUI", became "Jarela" later in the day.
- **WhatsApp has two parallel JID namespaces.** The classic
  `@s.whatsapp.net` and the newer `@lid` (linked-device IDs). Some
  messages arrive with the `@lid` as the primary `remoteJid` and the
  real number as `remoteJidAlt`. Route on the alt when present, or
  you'll never reply to the right thread.
- **Show a typing indicator while the agent composes.** Otherwise the
  sender thinks the message went to a black hole.

Plus a chat picker in the route editor (no more pasting raw JIDs),
phone-number lookup, and "pin self in chat picker" for the case where I
want the agent to be able to message me back from itself.

Agent-side toggle: **"never reply"** — silent / read-only on bridges.
Useful for a watcher agent that should log and notify but never send
anything outbound.

Two bridge follow-ups that fell out of the design naturally: allow
self-chat routing without a reply loop (otherwise the agent talks to
itself forever) and silence unrouted-chat notifications (otherwise every
group chat I'm in pings the desktop).

## Gmail, natively

Then the outbound side. `feat(tools/gmail)`: search / read / draft /
label / trash. **Drafts-only** for send. I'm not letting an LLM send
mail on my behalf without me clicking the button, full stop. The agent
does the drudgery, I click send.

OAuth was the actual work:

1. `scripts/gmail-oauth.mjs` — a loopback OAuth helper for Desktop
   credentials, run once locally to mint a refresh token.
2. Then I moved it in-app: a **Connect Gmail** button on the tool
   card runs the OAuth dance from inside the running server, exchanges
   the code, stores the refresh token in the local SQLite.
3. An in-card setup guide with the GCP step-by-step (create project →
   enable Gmail API → consent screen → desktop credentials → here's the
   redirect URI) — because every time I do this from scratch I forget
   two steps.

The lesson: **drafts-only is the right default for any "send" action.**
The audit trail matters more than the convenience.

## Maps in chat + opt-in location

- Render Google Maps embeds from a ` ```map ` code fence. The agent
  emits coordinates, the user sees a map, the API key is injected
  server-side and never ships to the client.
- Opt-in browser geolocation sharing with a `get_user_location` tool.
  Off by default. The agent has to ask for it, the browser has to grant
  it, and the grant is per-thread.

## Provider hotloading

```
feat(providers): hotload external ModelProviders from ~/.langgui/providers/
```

Drop a TypeScript/JS module in that directory, restart, and it's a
first-class provider in the agent factory — same shape as the built-in
adapters. This was the first time the project crossed from **"my
thing"** to **"platform for my thing"**. The next provider I add can
live outside the repo entirely.

I didn't plan for it on day 1. Today it took 90 minutes and made
everything downstream easier.

## MCP isolation

```
fix(mcp): isolate per-server connection failures so one broken
server doesn't poison the rest
```

Before today, a single MCP server failing to start broke the whole tool
registry. Now each server lives in its own try/catch and the rest come
up fine. Obvious in hindsight, painful in practice.

## Installer + scheduled task fixes

- Use `powershell` directly for the scheduled-task action. The previous
  indirection through `cmd` was eating non-zero exit codes silently.
- Clear install-dir contents in place — don't remove the dir itself,
  because removing it breaks the scheduled task's working-directory
  reference.

## The big one: rebrand to Jarela

```
feat!: rebrand to Jarela with state migration and refreshed logo set
```

LangGUI was a working title. I always meant to rename it. The hard part
wasn't search-and-replace — it was the **state migration**: the SQLite
checkpoint and the local stores live at `~/.langgui`, and I wasn't
about to lose three days of conversations. So:

1. On startup, if `~/.jarela` doesn't exist and `~/.langgui` does, move
   it. Single rename, atomic on the same filesystem, safe to retry.
2. Refresh the logo set (favicons, PWA manifest, apple-touch-icon).
3. Update WhatsApp's announced device name from "LangGUI" to "Jarela".
4. Marked breaking with `!` and a `BREAKING CHANGE:` footer per
   Conventional Commits v1.0.0 — anyone (me, mostly) who has an old
   `~/.langgui` directory gets it migrated automatically, but the
   default state directory has changed.

Smaller follow-ups: an expanded README that actually lists the
features and providers, a Windows task runner (`make.ps1` + `make.cmd`),
and the iOS PWA icon got a white background because on a dark home
screen the dark "J" on the dark blue background I had was invisible.

## What I learned

- **Bridges are the shape, not just WhatsApp.** Modeling the inbound
  channel as a generic Bridge with route + identity + reply policy paid
  off within hours. The "never reply" toggle and the self-chat loop fix
  both fell out naturally instead of being per-channel hacks.
- **Drafts-only is the right default for any "send" action.** Audit
  trail > convenience.
- **Hotloading providers is when a script becomes a platform.** Don't
  plan for it on day 1; it's cheap to add the moment the seams are
  obvious.
- **Renames are state migrations.** The string-replace took ten
  minutes. Making sure no one lost a thread took the rest.
- **Conventional Commits v1.0.0 strictness pays off the second time
  you `git log`.** I rewrote earlier commits to comply mid-day. The
  new ones I wrote correctly the first time. Worth it.

That's the first three days. The honeymoon "44 commits in a day" rate
isn't sustainable and isn't the point. The point is that the box is on,
it's mine, and it works.

---

*Repo: [github.com/andrew-ge-wu/jarela](https://github.com/andrew-ge-wu/jarela).
Personal project, no roadmap, no SLA. Just notes from the workshop.*
