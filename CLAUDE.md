# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the documentation site for Telecontrol SCADA (ОИК Телеконтроль), a Russian-language industrial control system. The site is built with Jekyll and hosted on GitHub Pages using the `jekyll-theme-slate` theme.

All documentation content is written in Russian.

## Local Development

```shell
bundle install           # Install dependencies
bundle exec jekyll serve # Serve locally (default: http://localhost:4000)
```

## Site Structure

- **Content pages**: Markdown files at the root and in `client/` — each corresponds to a documentation page
- **Navigation**: Defined in `_data/toc.yml` — add entries here when creating new pages
- **Layout**: Single layout in `_layouts/default.html` with a left sidebar TOC (`_includes/toc.html`)
- **Styling**: Custom SCSS in `assets/css/style.scss` extending the Slate theme; left 20% is the fixed TOC sidebar
- **Images**: Stored in `img/` (root-level screenshots) and `client/` (client-specific images)

## Key Conventions

- Pages use `layout: default` in front matter
- Internal links use Jekyll relative links (`jekyll-relative-links` plugin) — link to filenames without extensions (e.g., `[Архитектура](architecture)`)
- The TOC sidebar is auto-generated from `_data/toc.yml`; page order there determines navigation order
- Images are referenced with relative paths (e.g., `![](img/structure.png)`)
