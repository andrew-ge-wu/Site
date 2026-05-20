---
title: "Day 6 of Jarela: Making the App Easier to Trust"
date: "2026-05-20T22:30:00+02:00"
description: "Day 6 of Jarela: 45 commits that followed through on the integration work, tightened proxy and streaming behavior, and polished the UI so the app feels more dependable."
draft: false
author: "Andrew Wu"
tags: ["LangGraph", "Integrations", "Proxy", "Streaming", "Next.js", "PWA", "Developer Tools", "AI Tooling"]
categories: ["AI Tools", "Development"]
keywords: ["Jarela day 6", "proxy setup", "streaming split", "MCP discovery", "PWA polish", "trustworthy app"]
lastmod: "2026-05-20T22:30:00+02:00"
weight: 1
featured: false
---

# Day 6 of Jarela

> Cross-posted from my development journal in the [Jarela repo](https://github.com/andrew-ge-wu/jarela).

45 commits.

Today was one of those days where the work is easy to underestimate while
you are doing it, and obvious afterward. Nothing here was flashy. That was
the point.

Jarela already had useful capabilities. Day 6 was about making them hold up
in the real world: behind proxies, across reconnects, on smaller screens,
and after I have closed the tab and come back later expecting things to
still make sense.

The biggest change was moving proxy setup into the product itself. It is
now encrypted, editable in-app, and part of the actual user flow instead of
some buried environment-variable ritual. That matters because the proxy is
not just a setting; it is the difference between integrations that work on a
clean home network and integrations that keep working in the places real work
happens.

I also cleaned up the streaming model so a run is submitted separately from
the event subscription. That sounds like a small architecture adjustment, but
it makes reconnects and state handling much easier to reason about. When the
socket drops, I want a clean path back to the same run, not a restart that
throws away context.

The rest of the day was a mix of expansion and cleanup, but the common thread
was still integration quality:

- MCP discovery now uses the official registry, so the app can find new tools
	instead of depending only on what is hardcoded.
- External providers and tools can be hot-loaded, which turns extension work
	into a configuration problem instead of a source change.
- Native GitHub REST tools landed, giving the app a first-class path into the
	GitHub side of my workflow.
- The setup flow is guided instead of empty, which matters because a good
	integration should explain itself the first time you see it.
- Release output now includes per-OS portable bundles, which keeps the install
	story boring in the best possible way.

I also spent a lot of time on the stuff that never looks impressive in a
demo but changes how the app feels after an hour of use: topbar behavior,
safe-area offsets, input alignment, deep links, and PWA reload edges. Those
little fixes are what turn a promising build into something I can actually
live with.

If there is a theme for the day, it is this: reliability is mostly a long
list of small decisions that remove friction. Not a rewrite. Not a big
reveal. Just the steady work of making the system less fragile.