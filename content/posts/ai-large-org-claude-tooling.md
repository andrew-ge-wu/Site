---
title: "AI in a Large Organization: Standardizing Claude, Code Quality at Scale, and Where Claude Falls Short"
date: "2026-05-07T20:00:00+02:00"
description: "Lessons from rolling out Claude as a standard developer tool across many teams: how to keep code quality consistent, where Claude struggles on large codebases, and the guardrails that actually work."
img: "articles/ai-large-org/hero.svg"
draft: false
author: "Andrew Wu"
tags: ["AI", "Claude", "Engineering Management", "Code Quality", "Developer Tools", "Platform Engineering", "LLM", "Enterprise"]
categories: ["AI Tools", "Development"]
keywords: ["Claude at scale", "AI developer tooling", "code quality LLM", "enterprise AI tooling", "Claude code review", "AI guardrails", "platform engineering AI", "AGENTS.md", "MCP", "AI in large organizations"]
lastmod: "2026-05-07T20:00:00+02:00"
weight: 1
featured: true
---

# AI in a Large Organization

Rolling out Claude (or any frontier LLM) to one team is easy. Rolling it out to **dozens of teams**, in a regulated org, on codebases that have been around for a decade, is a different problem. Over the last 3 years leading 40+ engineers across model and product development at Visa, I've learned that the bottleneck isn't the model -- it's the **standard tooling**, the **quality guardrails**, and a clear-eyed view of where Claude **still falls short** on large projects.

Here is what has actually worked.

![AI tooling at scale across multiple engineering teams](/img/articles/ai-large-org/hero.svg)

## 1. Treat AI as a Platform, Not a Per-Team Toy

The first mistake every org makes: each team picks its own AI tool, its own IDE plugin, its own prompt patterns. Six months later you have:

- Six different ways of asking "is this code review-ready?"
- No central place to update a security policy or a coding standard
- Secrets and proprietary code leaked through six different vendors

The fix is to treat AI tooling like any other shared developer surface -- **CI, package registry, observability** -- and run it through a **platform team**.

In practice that means:

* **One sanctioned client** (e.g. Claude via a managed enterprise gateway) with logging, DLP, and SSO
* **One standard `AGENTS.md` / `CLAUDE.md` template** every repo inherits
* **One internal MCP server fleet** exposing the same set of safe tools (issue tracker, code search, deploy status, runbooks) to every team
* **One eval harness** that scores model outputs against your golden tasks before you change models or prompts

This is the same pattern as having a single CI system instead of every team running their own Jenkins. Boring, but it's what makes the next two sections possible.

## 2. Standard Tooling: What "One Toolchain, N Teams" Actually Looks Like

Here is the layering I push for in any org of more than a handful of teams:

### 2a. Repo-level: `AGENTS.md` as the contract

Every repo gets an `AGENTS.md` (or `CLAUDE.md`) that captures:

- The **build / test / lint** commands an agent must use, not guess
- **Hot files** the agent should always read first (architecture notes, public APIs)
- **Hands-off zones** (generated code, vendored deps, audit-trail directories)
- The **definition of done**: tests pass, lint clean, security scan clean, docs updated

This file is the single source of truth for both humans and agents. When something goes wrong, you fix it in one place and every team benefits.

### 2b. Org-level: shared instruction packs

On top of the repo file, the platform team ships **org-wide instructions**:

- Coding standards (naming, error handling, logging, observability)
- Security policy (no secrets in code, allowed crypto libs, PII rules)
- Architecture rules (no cross-domain imports, no direct DB calls from edge services)
- Review checklist (what a senior engineer would look for)

Push these as a **read-only layer** the agent always loads. Teams can extend, but they cannot weaken the org policy.

### 2c. MCP servers as the "safe hands"

The dangerous part of an agent isn't the reasoning -- it's the **tools** it can reach. Wrap every dangerous capability in an MCP server the platform team owns:

- `deploy.preview` -- can spin up a preview env, never prod
- `db.read` -- read-only, scoped to the requesting team's schemas
- `secrets.get` -- only ephemeral, only signed requests
- `pr.create` -- always to a feature branch, never to main

Now an agent that goes off the rails fails *safely*, because it physically cannot reach production credentials.

### 2d. One eval harness, run on every change

Before bumping the model version, the prompt template, or any shared instruction, run it against a **golden set** of tasks pulled from real tickets across teams. Score for:

- Task success
- Test pass rate after the agent's edit
- Lint / security regressions
- Hallucinated APIs or files

If a change drops a critical metric, it doesn't ship -- same as a failing build.

## 3. Code Quality Across Multiple Teams

Once Claude is writing or reviewing 30-60% of code across many teams, **quality drifts in ways you don't see in a single-team pilot.** Here is what I keep on every team's dashboard.

### 3a. Pre-commit: shift quality left of the model

Make sure the agent's output goes through the same gates as a human's:

- Formatter and linter (auto-fixed locally)
- Type checker
- Unit tests for changed packages
- Secret scanner
- Architecture rules (e.g. ArchUnit, dependency-cruiser, custom Semgrep rules)

If a rule is mechanically checkable, **never rely on the LLM to remember it**. Encode it.

### 3b. PR-level: AI-assisted review with a human owner

Every PR gets a Claude-generated review *and* a human reviewer who is accountable. The AI review covers the boring 80%: style, obvious bugs, missing tests, security smells. The human focuses on the 20% that actually requires judgment: is this the right design, does it fit the roadmap, is the test actually testing the behavior?

The trap: if you let AI reviews **auto-approve**, quality silently degrades because the model develops a tolerance for its own output style. Always keep a human in the loop, and rotate human reviewers across teams.

### 3c. Track AI-authored code as a first-class metric

You can't manage what you don't measure. Tag commits and PRs as AI-assisted (most enterprise gateways do this for you) and watch:

- **Defect rate** of AI-assisted vs. human-only PRs (per team, per service)
- **Revert rate** within 7 days
- **Test coverage delta** on AI-authored changes
- **Time-to-merge** (a leading indicator that reviewers are rubber-stamping)

When a team's AI-assisted defect rate diverges from the rest, that's a signal -- usually their `AGENTS.md` is stale or their tests are too thin to catch regressions.

### 3d. Architecture fitness functions

LLMs are great at local edits and bad at protecting architecture. Add automated **fitness functions** that fail the build if the agent quietly violates a boundary:

- "No service in `payments/` may import from `risk/internals/`"
- "All public REST endpoints must have an `@RateLimited` annotation"
- "All Kafka producers must declare their topic in the topic registry"

These rules survive every model upgrade and every personnel change. They are the spine of a healthy codebase.

## 4. Where Claude Still Falls Short on Large Projects

Now the honest part. Claude is the best general-purpose coding model I've used, and it is **still not good enough on its own for large enterprise codebases.** Here is where it breaks and what to do about it.

### 4a. Context windows are big, but your monorepo is bigger

A modern context window (200K-1M tokens) sounds enormous until you try to fit a 10-million-line monorepo into it. The model **doesn't know what it doesn't see**, and on cross-cutting changes (renaming a public API, migrating a logging library), it will:

- Miss callers in services it never read
- Re-implement helpers that already exist three packages away
- Break invariants enforced elsewhere in the codebase

**Fix:** invest in **retrieval over the codebase**, not just in bigger contexts. A good repo-aware retrieval layer (semantic + symbol + dependency graph) plus a `repo-search` MCP tool routinely beats raw long context on real refactors. Teach the agent to *search before it writes*.

### 4b. It hallucinates internal APIs with high confidence

Claude has read more open-source code than your senior engineers ever will. It has read **none** of your internal libraries. So when it doesn't know your `com.acme.platform.audit.Logger`, it confidently invents one that looks plausible -- with the wrong package, the wrong method names, and made-up annotations.

**Fix:** make internal APIs first-class context. Generate machine-readable docs (OpenAPI, package indexes, public-symbol manifests) and ship them as MCP tools. A `lookup-symbol` and `find-usages` tool eliminates 90% of this class of hallucination.

### 4c. It loses the plot on long-horizon tasks

Multi-day, multi-PR migrations -- "move every service from JDK 11 to 21", "introduce tenant isolation across 14 services" -- expose Claude's biggest weakness: it has **no durable memory of the plan**. It will redo work, miss steps, and contradict its earlier decisions across sessions.

**Fix:** externalize the plan. Use a **task ledger** (an issue list, a markdown checklist in the repo, or a dedicated MCP `plan` tool) that the agent must read at the start of every session and update at the end. Pair this with a senior engineer who owns the migration -- the agent does the labor, the human owns the strategy.

### 4d. It is a poor judge of business impact

Claude can write a flawless cache eviction policy. It cannot tell you that this cache is the one fronting the EU regulatory feed and a 2-second stale read will get you fined. Business context, customer impact, legal and compliance constraints -- the model has none of it unless you give it.

**Fix:** every critical service ships an `IMPACT.md` next to its code: who uses it, what breaks if it's wrong, what regulations apply. Load it as part of the agent's standing context for that service. Then **escalate, don't autonomously decide** on changes that touch those surfaces.

### 4e. It is still a security risk, even when behaved

Even with a perfect MCP boundary, an LLM will:

- Echo secrets it was given in a debug print
- Suggest `eval`-style patterns that pass review because the rest of the file is fine
- Trust user input it was told to trust
- Fall for prompt injection embedded in tickets, web pages, or third-party code

**Fix:** treat agent output as **untrusted input** to your existing security pipeline. Same SAST, same secret scanning, same dependency review, same red-team prompts in the eval harness. The only difference is you run them on every AI-assisted change, not just on releases.

## 5. What Good Looks Like, in One Picture

- One sanctioned AI client, logged and policy-controlled.
- Every repo carries an `AGENTS.md`. Every org carries a shared instruction pack on top.
- Every dangerous capability is behind an MCP server the platform team owns.
- Every PR -- AI-assisted or not -- goes through the same automated gates.
- Every team's AI-assisted defect rate is a number on a dashboard.
- Every long-horizon program has a human owner and an externalized plan the agent reads each session.
- Every critical service has an `IMPACT.md` the agent must read before touching it.

When this is in place, Claude stops being a per-developer toy and becomes what it should be: a **shared, governed amplifier** for the engineering org. You get the productivity, you keep the quality, and the model's blind spots are covered by the system around it.

---

*If you're standing up AI tooling across multiple teams and want a sober assessment of what works, I do this kind of consulting -- both as a fractional engineering manager and as a platform advisor. Get in touch.*
