---
title: "Day 4 of Jarela: Integrations That Can Live in the Middle of My Work"
date: "2026-05-18T22:30:00+02:00"
description: "Day 4 of Jarela: 30 commits focused on Microsoft Graph for mail and calendar, Google Calendar cleanup, and the security work that makes integrations safe enough to keep using."
draft: false
author: "Andrew Wu"
tags: ["LangGraph", "Integrations", "Microsoft Graph", "Google Calendar", "Next.js", "Security", "AI Tooling", "Developer Tools"]
categories: ["AI Tools", "Development"]
keywords: ["Jarela day 4", "Microsoft Graph Outlook integration", "Google Calendar cleanup", "encrypted secrets at rest", "CSRF origin guards", "integration security"]
lastmod: "2026-05-18T22:30:00+02:00"
weight: 1
featured: false
---

# Day 4 of Jarela

> Cross-posted from my development journal in the [Jarela repo](https://github.com/andrew-ge-wu/jarela).

30 commits.

Today was the point where the app stopped feeling like a side project and
started feeling like part of the stack I actually use.

The big step was Microsoft Graph for mail and calendar. Outlook is now a real
integration, not a checkbox. That meant more than just wiring endpoints: I had
to make the auth flow legible, keep the app registration steps clear enough to
revisit later, and make sure the UI actually explains what is connected.

I also tightened the edges around it, because integrations are only as useful
as the trust around them:

- Encrypted secrets at rest, so tokens and configuration do not sit in plain
	text.
- CSRF and origin guards, so the integration surface is not open to easy
	abuse.
- Health redaction, so diagnostics do not leak more than they should.
- Secret scanning, so mistakes are easier to catch before they become state.

That support work matters because integrations only hold up when the auth
story, the docs, and the deployment path all make sense together. If the
connection works but the setup is confusing, it is not really an integration;
it is just a fragile demo.

I also kept the rest of the system aligned with that change:

- Google Calendar support got cleaned up so the Google side feels as deliberate
	as the Microsoft side.
- The platform story was written out more clearly for Windows, macOS, and Linux.
- CI/CD via GitHub Actions makes the integrations part of a repeatable build,
	not a hand-run ritual.
- Production build hygiene keeps the release path boring, which is exactly
	what integration work wants.

The day felt less like adding one more feature and more like laying down the
pieces that let the integrations behave like they belong there.