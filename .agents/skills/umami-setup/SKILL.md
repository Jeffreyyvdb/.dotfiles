---
name: umami-setup
description: Wire Umami analytics into a web app — tracker script, optional Core Web Vitals, optional session recorder — all env-var-gated so they can be flipped on/off without a code change. Use whenever the user mentions Umami, asks to add or install analytics on a self-hosted analytics backend, wants to replace Vercel Analytics / Google Analytics / Plausible, says "add Umami to this project," or pastes an Umami tracker snippet asking where it goes. Works for SvelteKit, Next.js (App and Pages routers), Nuxt, Astro, Vite + React/Vue, and plain static HTML. Also use when a user reports their Umami dashboard shows no data and asks why — this skill includes the standard debugging checklist.
---

# Umami setup

Wires a self-hosted (or Umami Cloud) tracker into a web app in three steps:

1. **Tracker script** — emitted in the document `<head>`, gated on two env vars.
2. **Core Web Vitals** — one `data-performance="true"` attribute on the same tag.
3. **Session recorder** (optional) — a second `<script>` gated on its own env var so it can be toggled without a code change.

Everything is opt-in via env vars. Unset → no scripts injected → zero network calls to Umami. This matters for CI, preview deploys, and environments where the user wants analytics off entirely.

## Standard env vars

Use these names across all frameworks. For frameworks that require a prefix (Next.js → `NEXT_PUBLIC_`, Vite → `VITE_`), prepend accordingly and document the mapping in `.env.example`.

| Var | Required? | Example |
|---|---|---|
| `PUBLIC_UMAMI_SRC` | yes, for tracker | `https://umami.example.com/script.js` |
| `PUBLIC_UMAMI_WEBSITE_ID` | yes, for tracker | `f5a2a82d-44c3-45b9-9cb6-be327bd78e86` |
| `PUBLIC_UMAMI_RECORDER_SRC` | no, enables recorder when set | `https://umami.example.com/recorder.js` |

> **Critical — URL paths differ by script:**
> - `PUBLIC_UMAMI_SRC` ends in `/script.js` (the tracker).
> - `PUBLIC_UMAMI_RECORDER_SRC` ends in `/recorder.js` (the session recorder).
>
> Both must be **full URLs**, not the dashboard root. A common mistake is pasting `https://umami.example.com/` (the dashboard) into `PUBLIC_UMAMI_SRC`. The browser loads the dashboard's HTML as a script, fails silently, and zero pageviews land. When the user says "I see the request go out but no data shows up in Umami," check this first.

## Workflow

1. **Detect the framework.** Read `package.json` (look for `svelte`, `next`, `nuxt`, `astro`, `vite`), and scan for `index.html`, `src/routes/+layout.svelte`, `app/layout.tsx`, `pages/_document.tsx`, etc. If you can't tell, ask the user.
2. **Open the matching section below** and copy the snippet into the root document head of the app.
3. **Update `.env.example`** with the three vars, empty by default, with a short comment on what each does. Don't commit `.env` / `.env.local`.
4. **Tell the user the verification steps** (see § Verifying). The single most common failure is step 1's URL gotcha — call it out explicitly.

Keep the change minimal. This skill is meant to be a drop-in — resist the urge to add abstraction layers, feature flags, or helper libraries unless the user asks.

## SvelteKit

Put the head snippet in the root layout — `src/routes/+layout.svelte`, **not** a nested one — so it covers every route, SSR or SPA.

```svelte
<script lang="ts">
  import { env } from '$env/dynamic/public';

  const umamiSrc = env.PUBLIC_UMAMI_SRC;
  const umamiWebsiteId = env.PUBLIC_UMAMI_WEBSITE_ID;
  const umamiRecorderSrc = env.PUBLIC_UMAMI_RECORDER_SRC;
</script>

<svelte:head>
  {#if umamiSrc && umamiWebsiteId}
    <script
      defer
      src={umamiSrc}
      data-website-id={umamiWebsiteId}
      data-performance="true"
    ></script>
  {/if}
  {#if umamiRecorderSrc && umamiWebsiteId}
    <script
      defer
      src={umamiRecorderSrc}
      data-website-id={umamiWebsiteId}
      data-sample-rate="1"
      data-mask-level="moderate"
      data-max-duration="300000"
    ></script>
  {/if}
</svelte:head>
```

- SvelteKit requires the `PUBLIC_` prefix for browser-exposed env vars.
- `$env/dynamic/public` is read at runtime — flipping Umami on or off in production is an env change, not a rebuild. If the project standardises on `$env/static/public`, use that instead (build-time).
- Umami v2 auto-tracks SvelteKit client-side navigations via the History API patch. No `afterNavigate` hook needed.

## Next.js (App Router)

In `app/layout.tsx`:

```tsx
import Script from 'next/script';

const UMAMI_SRC = process.env.NEXT_PUBLIC_UMAMI_SRC;
const UMAMI_WEBSITE_ID = process.env.NEXT_PUBLIC_UMAMI_WEBSITE_ID;
const UMAMI_RECORDER_SRC = process.env.NEXT_PUBLIC_UMAMI_RECORDER_SRC;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        {children}
        {UMAMI_SRC && UMAMI_WEBSITE_ID && (
          <Script
            src={UMAMI_SRC}
            data-website-id={UMAMI_WEBSITE_ID}
            data-performance="true"
            strategy="afterInteractive"
          />
        )}
        {UMAMI_RECORDER_SRC && UMAMI_WEBSITE_ID && (
          <Script
            src={UMAMI_RECORDER_SRC}
            data-website-id={UMAMI_WEBSITE_ID}
            data-sample-rate="1"
            data-mask-level="moderate"
            data-max-duration="300000"
            strategy="afterInteractive"
          />
        )}
      </body>
    </html>
  );
}
```

- Next.js requires the `NEXT_PUBLIC_` prefix (not `PUBLIC_`). Document the mapping in `.env.example`.
- Use `next/script` with `strategy="afterInteractive"` so it doesn't block first paint.
- `NEXT_PUBLIC_*` are **inlined at build time**. Toggling Umami on or off requires a rebuild, not just an env change.

## Next.js (Pages Router)

In `pages/_document.tsx`:

```tsx
import { Html, Head, Main, NextScript } from 'next/document';

const UMAMI_SRC = process.env.NEXT_PUBLIC_UMAMI_SRC;
const UMAMI_WEBSITE_ID = process.env.NEXT_PUBLIC_UMAMI_WEBSITE_ID;
const UMAMI_RECORDER_SRC = process.env.NEXT_PUBLIC_UMAMI_RECORDER_SRC;

export default function Document() {
  return (
    <Html>
      <Head>
        {UMAMI_SRC && UMAMI_WEBSITE_ID && (
          <script
            defer
            src={UMAMI_SRC}
            data-website-id={UMAMI_WEBSITE_ID}
            data-performance="true"
          />
        )}
        {UMAMI_RECORDER_SRC && UMAMI_WEBSITE_ID && (
          <script
            defer
            src={UMAMI_RECORDER_SRC}
            data-website-id={UMAMI_WEBSITE_ID}
            data-sample-rate="1"
            data-mask-level="moderate"
            data-max-duration="300000"
          />
        )}
      </Head>
      <body>
        <Main />
        <NextScript />
      </body>
    </Html>
  );
}
```

## Nuxt 3

In `app.vue` (or a dedicated plugin), use `useHead`:

```vue
<script setup lang="ts">
const config = useRuntimeConfig();
const src = config.public.umamiSrc as string | undefined;
const websiteId = config.public.umamiWebsiteId as string | undefined;
const recorderSrc = config.public.umamiRecorderSrc as string | undefined;

useHead({
  script: [
    ...(src && websiteId
      ? [{
          defer: true,
          src,
          'data-website-id': websiteId,
          'data-performance': 'true',
        }]
      : []),
    ...(recorderSrc && websiteId
      ? [{
          defer: true,
          src: recorderSrc,
          'data-website-id': websiteId,
          'data-sample-rate': '1',
          'data-mask-level': 'moderate',
          'data-max-duration': '300000',
        }]
      : []),
  ],
});
</script>
```

Expose the vars in `nuxt.config.ts`:

```ts
export default defineNuxtConfig({
  runtimeConfig: {
    public: {
      umamiSrc: '',
      umamiWebsiteId: '',
      umamiRecorderSrc: '',
    },
  },
});
```

Env vars: `NUXT_PUBLIC_UMAMI_SRC`, `NUXT_PUBLIC_UMAMI_WEBSITE_ID`, `NUXT_PUBLIC_UMAMI_RECORDER_SRC`.

## Astro

In the shared head component (e.g. `src/components/BaseHead.astro` or `src/layouts/Layout.astro`):

```astro
---
const UMAMI_SRC = import.meta.env.PUBLIC_UMAMI_SRC;
const UMAMI_WEBSITE_ID = import.meta.env.PUBLIC_UMAMI_WEBSITE_ID;
const UMAMI_RECORDER_SRC = import.meta.env.PUBLIC_UMAMI_RECORDER_SRC;
---

{UMAMI_SRC && UMAMI_WEBSITE_ID && (
  <script
    is:inline
    defer
    src={UMAMI_SRC}
    data-website-id={UMAMI_WEBSITE_ID}
    data-performance="true"
  />
)}

{UMAMI_RECORDER_SRC && UMAMI_WEBSITE_ID && (
  <script
    is:inline
    defer
    src={UMAMI_RECORDER_SRC}
    data-website-id={UMAMI_WEBSITE_ID}
    data-sample-rate="1"
    data-mask-level="moderate"
    data-max-duration="300000"
  />
)}
```

`is:inline` is important — without it, Astro tries to bundle the external script and silently drops the `data-*` attributes.

## Vite + React / Vue (plain Vite, not SvelteKit / Nuxt)

Option A — edit `index.html` directly with Vite env-var substitution:

```html
<!-- in <head> -->
<script defer
  src="%VITE_UMAMI_SRC%"
  data-website-id="%VITE_UMAMI_WEBSITE_ID%"
  data-performance="true"></script>
```

Vite replaces `%VITE_*%` tokens at build time. Downside: if the env var is empty the tag still renders (with empty `src`) — the browser swallows it, but it's a wasted tag. For a real on/off toggle, prefer Option B.

Option B — inject from app code on mount (React example):

```tsx
import { useEffect } from 'react';

export function UmamiScripts() {
  useEffect(() => {
    const src = import.meta.env.VITE_UMAMI_SRC;
    const websiteId = import.meta.env.VITE_UMAMI_WEBSITE_ID;
    const recorderSrc = import.meta.env.VITE_UMAMI_RECORDER_SRC;
    if (!src || !websiteId) return;

    const make = (s: string, extra: Record<string, string> = {}) => {
      const el = document.createElement('script');
      el.defer = true;
      el.src = s;
      el.dataset.websiteId = websiteId;
      for (const [k, v] of Object.entries(extra)) el.dataset[k] = v;
      document.head.appendChild(el);
      return el;
    };

    const tracker = make(src, { performance: 'true' });
    const recorder = recorderSrc
      ? make(recorderSrc, {
          sampleRate: '1',
          maskLevel: 'moderate',
          maxDuration: '300000',
        })
      : null;

    return () => {
      tracker.remove();
      recorder?.remove();
    };
  }, []);

  return null;
}
```

Mount `<UmamiScripts />` once in the root component.

## Plain static HTML

No env-var gating is possible without a build step — just edit `<head>`:

```html
<script defer src="https://umami.example.com/script.js"
  data-website-id="YOUR_WEBSITE_ID"
  data-performance="true"></script>

<!-- Optional recorder — delete to disable -->
<script defer src="https://umami.example.com/recorder.js"
  data-website-id="YOUR_WEBSITE_ID"
  data-sample-rate="1"
  data-mask-level="moderate"
  data-max-duration="300000"></script>
```

If the user wants conditional injection without a framework, suggest either (a) picking one of the setups above, or (b) a tiny inline `<script>` that checks a server-set cookie/meta tag and injects the tracker dynamically.

## `.env.example` template

Append this block:

```
# Umami analytics — self-hosted or Umami Cloud. Leave PUBLIC_UMAMI_SRC and
# PUBLIC_UMAMI_WEBSITE_ID unset to disable entirely. Must be the full tracker
# URL ending in /script.js, not the dashboard root.
PUBLIC_UMAMI_SRC=""
PUBLIC_UMAMI_WEBSITE_ID=""

# Optional session recorder — set to enable, unset to kill instantly.
PUBLIC_UMAMI_RECORDER_SRC=""
```

(Swap the prefix per framework: `NEXT_PUBLIC_`, `NUXT_PUBLIC_`, `VITE_`, etc.)

## Verifying

After wiring the snippet, walk the user through this — most failures get caught at step 1 or 2.

1. **Hit `$PUBLIC_UMAMI_SRC` in the browser.** Should return JavaScript that starts with `(function(){...}` or similar. If it returns HTML, the URL is wrong (probably the dashboard root). Fix before going further.
2. **Open devtools → Network**, load any page of the app:
   - GET to `.../script.js` should be `200` and served as JS.
   - POST to `.../api/send` should fire on initial load, return `200`.
   - `window.umami` should be defined in the console.
3. **Trigger a client-side navigation** (SPA link click). A **second** POST to `/api/send` should fire. If not, the tracker isn't mounted on every route — move the snippet up to the root layout.
4. **Dashboard check.** Events take ~30 s to surface in the Umami UI. If `/api/send` returns 2xx but events don't appear, the `data-website-id` is wrong.
5. **Disable path.** Unset the env vars and reload. There should be zero Umami requests in the Network tab. Confirms the gating works for CI / preview deploys.

## Gotchas

- **Mind the script paths.** `PUBLIC_UMAMI_SRC` ends in `/script.js` (tracker), `PUBLIC_UMAMI_RECORDER_SRC` ends in `/recorder.js` (recorder). Pasting the dashboard root into either is the #1 cause of "script loads but no data appears." If the user renamed `TRACKER_SCRIPT_NAME` on the Umami server, adjust accordingly.
- **Performance (Core Web Vitals) needs Umami v3.1.0+.** Older instances ignore `data-performance="true"` silently — no error, just no vitals data.
- **The recorder reuses `PUBLIC_UMAMI_WEBSITE_ID`** — no separate ID.
- **Adblockers target `/script.js` and `/api/send` by default.** If bypassing ad-block matters, rename the tracker on the Umami server (`TRACKER_SCRIPT_NAME`) and self-host under a non-`umami.` subdomain (`stats.example.com`).
- **SPA navigation is auto-tracked** in Umami v2 via `history.pushState` patching. Don't reach for `afterNavigate` / `router.afterEach` / `useRouter().events` unless verification step 3 actually fails.
- **Put the script in the root layout**, not a per-page head. Putting it in one page means route changes away from that page lose tracking.
- **Don't commit `.env` / `.env.local`.** Only commit `.env.example` with empty values.
- **Respect Do Not Track.** Umami does by default; if the user wants to override, that's `data-do-not-track="false"` on the tracker tag — but check the user actually wants this.

## When the user reports "no data in Umami"

Run this triage in order — stop at the first failure:

1. **URL gotcha.** Open `$PUBLIC_UMAMI_SRC` in a browser. HTML response → wrong URL. Must end in `/script.js`.
2. **Env vars actually set in the running environment.** In Next.js remember `NEXT_PUBLIC_*`, not `PUBLIC_*`. Check Vercel/Dokploy/wherever the app is deployed.
3. **Script tag actually in the rendered HTML.** `curl <app-url> | grep umami`. If missing, the conditional isn't firing — check env var values.
4. **Umami server reachable from the browser's network.** Devtools Network: is `/api/send` returning `200`? `4xx` → website-id mismatch. `0` / blocked → adblocker or CORS.
5. **Umami version.** For performance data specifically, confirm the server is v3.1.0+.
