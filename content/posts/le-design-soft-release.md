---
title: "LeDesigner Soft Release: Turn Any Photo Into a 3D LEGO Model in Your Browser"
date: "2026-05-07T10:00:00+02:00"
description: "Announcing the soft release of LeDesigner — an AI-powered web and mobile app that converts images into buildable 3D LEGO models, entirely in the browser."
img: "articles/le-design/splash.png"
draft: false
author: "Andrew Wu"
tags: ["LEGO", "AI", "Computer Vision", "Three.js", "Next.js", "Transformers.js", "WebGL", "Capacitor", "Side Project"]
categories: ["Development", "AI Tools"]
keywords: ["LeDesigner", "LEGO AI", "image to LEGO", "SAM segmentation", "Depth Anything", "3D LEGO model", "browser AI", "Three.js LEGO"]
lastmod: "2026-05-07T10:00:00+02:00"
weight: 1
featured: true
---

# LeDesigner Soft Release

I'm happy to announce the **soft release** of [LeDesigner](https://github.com/) — a side project I've been quietly building over the past few months. LeDesigner takes any photo, segments the subject with AI, estimates depth, and turns it into a buildable 3D LEGO model with a parts list you can export to CSV. Everything runs **entirely in the browser** — no server, no upload, no API key.

![LeDesigner splash](/img/articles/le-design/splash.png)

## What is a "soft release"?

This is not a 1.0. It's an invitation to early users and fellow tinkerers to try the pipeline end-to-end, file issues, and help me prioritize what to polish next. The core flow works on desktop browsers and Android (via Capacitor); iOS support is in the pipeline.

## The Pipeline

LeDesigner is built around a four-stage pipeline that runs locally in Web Workers so the UI stays responsive:

1. **Upload** — drag-and-drop a JPEG, PNG, or WebP.
2. **Segment** — click on the subject; [Segment Anything (SAM)](https://segment-anything.com/) isolates it from the background.
3. **Build** — Depth Anything estimates a depth map, the voxelizer turns that into a 3D grid, and a greedy optimizer merges 1×1 voxels into standard LEGO bricks.
4. **View** — the model renders in Three.js (via `react-three-fiber`) using `InstancedMesh` so even thousand-brick builds stay smooth. A parts table shows brick counts and exports to CSV.

```
Image ──▶ SAM segmentation ──▶ Depth Anything ──▶ Voxelizer
                                                    │
                                                    ▼
              CSV export ◀── Parts table ◀── 3D LEGO viewer ◀── Greedy brick optimizer
```

## Why It's Interesting

A few design decisions made this fun to build:

- **In-browser AI with Transformers.js.** Both SAM and Depth Anything run client-side. After the first download, models are cached and the app works offline.
- **CIE Delta-E color matching.** Mapping arbitrary RGB to the official LEGO palette is a perceptual problem, not a numeric one. Using Delta-E gets noticeably better results than nearest-RGB.
- **Greedy brick optimization.** Naive voxelization gives you a wall of 1×1 plates. A simple greedy merge into 2×2, 2×4, 1×8, etc. cuts brick count dramatically and produces something you'd actually want to build.
- **InstancedMesh rendering.** One draw call for thousands of bricks. WebGL stays happy.

## Tech Stack

- **Next.js 16** (App Router) + **TypeScript**
- **Three.js** via `@react-three/fiber` and `@react-three/drei`
- **Transformers.js** for SAM and Depth Anything
- **Tailwind CSS v4**
- **Capacitor** for Android (and soon iOS) packaging
- **Vitest** for tests

## Try It

The web build is being deployed to Netlify; the Android debug APK is available on request while I sort out Play Store metadata. If you want to run it locally:

```bash
git clone <repo>
cd le-design
npm install
npm run dev   # http://localhost:3000
```

## What's Next

Short-term roadmap for the soft-release period:

- iOS build via Capacitor
- Brick-by-brick build instructions (layered exploded view)
- Better handling of thin or transparent subjects
- Sharable model links (encoded in URL, no backend)
- Optional cloud render for ultra-high voxel counts

If you try it and something breaks — or builds something cool — please let me know. That feedback is the whole point of a soft release.

— Andrew
