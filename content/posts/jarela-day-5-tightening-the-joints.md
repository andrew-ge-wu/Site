---
title: "Day 5 of Jarela: Tightening the Joints"
date: "2026-05-19T22:30:00+02:00"
description: "Day 5 of Jarela: 27 commits focused on proxy support, EventSource streaming boundaries, MCP discovery, hot-loaded providers, and the integration plumbing that keeps things working."
draft: false
author: "Andrew Wu"
tags: ["LangGraph", "Integrations", "Proxy", "EventSource", "MCP", "Next.js", "AI Tooling", "Developer Tools"]
categories: ["AI Tools", "Development"]
keywords: ["Jarela day 5", "proxy configuration", "EventSource streaming", "MCP Registry discovery", "hot-loading providers", "integration manifests"]
lastmod: "2026-05-19T22:30:00+02:00"
weight: 1
featured: false
---

# Day 5 of Jarela

> Cross-posted from my development journal in the [Jarela repo](https://github.com/andrew-ge-wu/jarela).

27 commits.

Day 5 picked up where Day 4 left off.

The work was less about adding something brand new and more about tightening
the joints so yesterday’s integrations would hold under pressure.

Proxy support moved into the product, with settings persisted, applied at
runtime, and exposed in the UI instead of living only in config files. That
sounds like a small change until you try to live behind a proxy and realize
how many tools quietly assume direct internet access.

The streaming boundary got cleaned up too. Run submission and event
subscription are now separate, which makes reconnects and re-attachment much
easier to reason about. It also makes the system easier to debug: if the send
path is fine but the listener is lagging, I can see that difference instead of
guessing at it.

The rest stayed in the same lane, but each part matters in a different way:

- MCP Registry discovery means the app can discover tools instead of requiring
	every integration to be hardcoded up front.
- Hot-loading external providers and tools means the platform can grow without
	turning every change into a release-cycle problem.
- Native GitHub REST tools add another real integration surface, not just a
	mock or placeholder.
- Integration-manifest onboarding makes the setup story explain itself instead
	of forcing the user to reverse-engineer it.
- Tailscale and launchctl cleanup make the whole thing more survivable when it
	is running as a service on a real machine.

This was the kind of day that makes the system feel sturdier without adding
noise. The shape is clearer now: fewer loose ends, fewer surprises, more of
the infrastructure you only notice when it is missing.