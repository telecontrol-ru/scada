---
nav_exclude: true
---

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the documentation site for Telecontrol SCADA (ОИК Телеконтроль), an industrial control system. The site is built with Jekyll and hosted on GitHub Pages using the [Just the Docs](https://just-the-docs.com) theme as a normal gem dependency.

The site is bilingual:

- Russian is the primary documentation tree at `/`
- English lives under `/en/`
- Language switching is driven by `_data/i18n_pages.yml`

## Local Development

```shell
bundle install           # Install dependencies
bundle exec jekyll serve # Serve locally (default: http://localhost:4000)
```

## Site Structure

- **Content pages**:
  - Russian pages live at the root, in `client/`, and in `dev/`
  - English pages live under `en/`, `en/client/`, and `en/dev/`
- **Navigation**: Driven by per-page front matter (`title`, `nav_order`, `parent`, `has_children`). Just the Docs builds the sidebar from this; there is no separate TOC data file.
- **Theme**: `theme: just-the-docs` in `_config.yml`
- **Language switcher**: `_includes/header_custom.html`
- **Language-filtered sidebar nav**: `_includes/sidebar_local.html` and `_includes/site_nav_local.html`, wired from `_layouts/default.html`
- **Page-pair map**: `_data/i18n_pages.yml`
- **Images**: Stored in `img/` (root-level screenshots) and `client/` (client-specific images).

## Front Matter Conventions

Each page must have:

```yaml
---
title: <Russian display title shown in nav and as <h1>>
nav_order: <integer ordering within its level>
permalink: /<url-path>           # optional but recommended
---
```

For pages with children, add `has_children: true`. Child pages reference their parent by title:

```yaml
---
title: График
nav_order: 1
parent: Клиент
permalink: /client/graph
---
```

English child pages use the English parent title:

```yaml
---
title: Graph
nav_order: 1
parent: Client
permalink: /en/client/graph/
---
```

## Key Conventions

- Russian pages can keep Jekyll relative links (`jekyll-relative-links` plugin), e.g. `[Архитектура](architecture)`.
- English pages should prefer `relative_url` links to the final English permalink, e.g. `{{ '/en/client/graph/' | relative_url }}`.
- Mark page-level `<h1>` with `{:.no_toc}` and use `* TOC \n {:toc}` if you want an in-page TOC; Just the Docs also exposes its own auto-generated TOC in the right rail.
- English pages must use site-absolute image paths with `relative_url`, e.g. `![]({{ '/img/structure.png' | relative_url }})`.
- Avoid `../img/...` in English pages because those paths are fragile under `/en/`.
- When adding a translated page, update `_data/i18n_pages.yml` in the same change.
- When adding a new English page, mirror the Russian path under `en/` and use an `/en/.../` permalink.
- When adding a new page, include the front matter above and pick a `nav_order` consistent with neighbors.

## Bilingual Editing Rules

- Keep Russian pages at their existing URLs; do not rename them just to match English titles.
- Only add live RU/EN language-switch links for pages listed in `_data/i18n_pages.yml`.
- Do not link an English page to a non-existent English target; use plain text or keep the Russian fallback only when there is no English counterpart yet.
- Translate by section where possible so terminology stays consistent across sibling pages.
- Prefer expanding existing English pages when the Russian source has gained more detail, rather than creating speculative English stubs.

## Validation

The docs workflow runs three checks before Pages deployment:

- `ruby scripts/validate_i18n_pages.rb`
  - verifies that every RU/EN mapping in `_data/i18n_pages.yml` points to a real page
  - verifies that page permalinks are unique
- `ruby scripts/validate_en_links.rb`
  - blocks fragile `../img/...` paths in English pages
  - blocks non-English internal links from leaking into `en/`
- `bundle exec jekyll build --destination ../_site`

Run the same checks locally before committing docs changes:

```shell
ruby scripts/validate_i18n_pages.rb
ruby scripts/validate_en_links.rb
bundle exec jekyll build --destination ../_site_test
```

## Search

Client-side search via Lunr is enabled in `_config.yml`. The tokenizer is configured to split on whitespace and punctuation so Cyrillic queries work.

## Screenshots under `img/`

Most images under `img/` are produced by an offline screenshot generator
that lives in the scada-client repo (`client/app/screenshot_generator.cpp`).
Every file in `img/` is tagged in
`../client/docs/screenshots/image_manifest.json`
with one of:

- `auto-view` — main-window view; generator renders it via a
  `WindowInfo` registered with the controller registry.
- `auto-dialog` — modal dialog rendered by the generator's dialog
  pipeline.
- `auto-menu` — right-click / popup menu rendered from the command
  registries.
- `auto-state` — device / node state capture (online, offline, …).
- `manual-diagram` — hand-drawn architecture or protocol diagram.
- `manual-modus` — Modus schematic; depends on the ActiveX runtime the
  offline fixture doesn't have.
- `manual-os` — OS-level screenshot (e.g. Windows firewall).
- `obsolete` — no longer referenced from any page; removal candidate.

### Regenerating auto images

From a scada-client checkout:

```shell
cmd.exe /c "cd /d C:\tc\scada && cmake --workflow --preset update-screenshots-dev"
```

For now the workflow updates only the current approved rollout subset:
`client-login.png`, `client-retransmission.png`, `graph-cursor.png`,
and `users.png`.

Then `git diff img/` in scada-docs to review the changes before
committing.

### Adding a new image

1. Decide whether the image can be auto-generated. If yes, add an entry to
   `../client/docs/screenshots/image_manifest.json` with the right `auto-*` tag,
   then extend
   `client/app/screenshot_data.json` in scada-client (see the
   "Regenerating the doc screenshots" subsection of
   `client/docs/design.md` for the JSON schema).
2. If it has to be hand-captured (`manual-*`), still add an entry there
   so future editors don't assume it's auto.
3. Reference it from the right markdown page:
   - Russian root pages can use `![](img/foo.png)`
   - Russian `client/` or `dev/` pages can use `![](../img/foo.png)`
   - English pages should use `![]({{ '/img/foo.png' | relative_url }})`
