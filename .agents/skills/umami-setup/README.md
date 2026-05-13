# umami-setup

A Claude Code skill that wires [Umami](https://umami.is) analytics into a web app — tracker script, optional Core Web Vitals, optional session recorder — all env-var-gated so they can be flipped on/off without a code change.

## Install

```sh
npx skills add Jeffreyyvdb/umami-setup
```

Works with any skills-compatible agent harness (Claude Code, etc.) — see [skills.sh](https://skills.sh/docs).

## What it does

When you tell your agent something like *"add Umami to this project"* or *"replace Vercel Analytics with my self-hosted Umami"*, the skill:

1. Detects the framework from `package.json` / file layout (SvelteKit, Next.js App or Pages router, Nuxt 3, Astro, Vite + React, or plain static HTML).
2. Injects a conditional tracker `<script>` into the root document head, gated on `PUBLIC_UMAMI_SRC` + `PUBLIC_UMAMI_WEBSITE_ID` so unsetting either var disables analytics entirely.
3. Adds `data-performance="true"` to collect Core Web Vitals (LCP / INP / CLS / FCP / TTFB) — requires Umami v3.1.0+ on the server.
4. Optionally emits a second `<script>` for the session recorder, gated on its own `PUBLIC_UMAMI_RECORDER_SRC` so you can toggle recording on/off without touching code.
5. Updates `.env.example` with the three vars and documents the framework-specific prefix (`NEXT_PUBLIC_`, `NUXT_PUBLIC_`, `VITE_`, ...).
6. Walks you through verification (network tab → `GET /script.js`, `POST /api/send` on both first load and SPA route change).

It also includes a triage section for the most common failure mode — "the script request fires but nothing shows up in the Umami dashboard" — which is almost always caused by pasting the dashboard root URL into `PUBLIC_UMAMI_SRC` instead of the full `/script.js` URL.

## Why

- **Self-hosted over Umami Cloud** gives you data sovereignty, but the tracker setup is mostly undocumented per-framework. This skill captures the exact head-injection snippet for each one.
- **Env-var gating by default** so a single unset toggles analytics off in CI, preview deploys, or ad-block-sensitive environments — no feature-flag library needed.
- **`data-performance="true"` is one attribute** that turns Umami into a free Web Vitals dashboard. Easy to miss if you haven't read the docs.

## Requires

- An Umami instance you control — self-hosted or [Umami Cloud](https://cloud.umami.is) — with a created website to get a `website-id`.
- Umami **v3.1.0+** if you want Core Web Vitals. Older releases silently ignore `data-performance="true"`.
- The ability to edit the project's root layout / document head. For plain static HTML, no build system is required; env-var gating simply isn't possible without one.

## Layout

```
.
├── SKILL.md     # frontmatter + framework-specific snippets + verifying + gotchas
└── README.md    # this file
```

No bundled assets — every snippet is copy-pasteable inline.

## License

MIT
