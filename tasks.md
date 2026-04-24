---
nav_exclude: true
---

# Documentation tasks

Gaps between the published user docs at
<https://telecontrol-ru.github.io/scada/> and the use cases /
functional requirements declared in the client requirements document at
[`client/docs/requirements.md`](https://github.com/alexsmn/scada-client/blob/main/docs/requirements.md).

Each entry below names the requirements-doc identifier (UC-* / FR-*), the
existing docs file if any, and the gap in one or two sentences.
**Note:** these are *documentation* tasks, not feature work — the
features themselves already exist in the client.

Tasks are grouped by area. New entries go under the matching cluster
or, if none fits, into **Misc** — never as a flat top-level entry.

## Event journal and alarms

### Write a real Event Journal page

Covers UC-5, FR-6. `client/events.md` is currently a stub (one
screenshot). Document filtering by severity / item / area, the time-range
picker, acknowledgement flow, severity colour scheme (normal / warning /
critical), and the relationship to the live event panel in the main
window.

### Document alarm presentation: auto-show, flash, sound

Covers UC-4. Currently mentioned in passing in `client.md`. Explain the
auto-show / auto-hide / flash behaviour, the sound notifications, and
where the user changes those settings.

### Document the quality and severity indicator letters

Architecture covers the data-quality flags (К, С, Н, Р, 2, Б, У, В) and
event-importance ranges, but no user-facing page explains what they
mean in the live UI or how to act on them.

## Control commands

### Write commands and two-stage confirmation

Covers UC-7, FR-5. Control-channel setup is in `dev/data-items.md`, but
there is no walkthrough of the operator-side write dialog: opening it,
the SELECT / EXECUTE two-stage flow, the manual-value variant, the
result and failure UI.

## Back-end selection and authentication

### Document the login dialog and back-end selection

Covers UC-17, FR-14, FR-1. `getting-started.md` shows the login dialog
without explaining the *Server* field, the back-end selector, or how to
connect to OPC UA and Vidicon endpoints alongside the default Scada
back-end.

### Connecting to an OPC UA back-end from the client

Covers FR-1. `server.md` documents the **server-side** OPC UA module.
There is nothing on using the client as an OPC UA client: target URL
format, certificate handling, address-space browsing, address
translation.

### Connecting to a Vidicon back-end from the client

Covers FR-1, FR-20. `server.md` mentions Vidicon integration. The
client-side Vidicon flow (login, display rendering, what works and
what doesn't) is undocumented.

## File transfer and file system

### Unified server-files page from the operator's perspective

Covers UC-10. Today the topic is fragmented: `dev/server-files.md`
covers the engineer's view, `server.md` covers configuration,
`client.md` mentions the file panel. Add a single operator-facing page
covering the file panel, upload, download, refresh, and the local
file cache.

## Re-transmission rules

### Re-transmission rules editor

Covers UC-19. The Transmission view is mentioned in `client.md` as
*"Таблица ретрансляции"* with no follow-up. Document creating a rule,
binding source / destination items, supported protocols, and what
happens at run-time.

## Modus schematics

### End-to-end Modus schematic workflow

Covers UC-11, FR-19. `client/display.md` is a 250-word navigation note;
`dev/displays.md` covers the binding `ключ_привязки` syntax. Combine
into a single workflow: create a schematic, bind elements to data
items, set up click-to-navigate hotspots, overlay live values, and
troubleshoot.

## Profile and window layout management

### Document profile save / load and multiple profiles

Covers UC-16, FR-10. Window layouts are persisted implicitly. Add a
short page explaining where the profile lives, what it stores
(layouts, page definitions, favourites, alarm colours), how to reset
or export it, and how multiple profiles per user work (if they do).

## Connection state

### Connection state and reconnect behaviour

Covers FR-7. The status bar shows connection state and the client
reconnects with backoff after a drop. Neither is documented; users
have no way to tell what the symbols mean or how long a reconnect
will take.

## Permissions

### Permission matrix per view and per command

Covers FR-16. `dev/users.md` lists the four roles in 150 words.
Explain which views and which menu commands are gated on
`WIN_REQUIRES_ADMIN` and what a non-admin user actually sees.

## View types missing dedicated pages

The requirements doc lists ~20 reusable view types in FR-9. Twelve of them
have docs today; the rest do not. Each needs at least a short feature
page on the operator side (some already have engineer-side docs under
`dev/`).

### Watch view (real-time value list)

Covers UC-1, FR-3. Watch is the canonical "live values" view but has
no dedicated page; live monitoring is currently described only in
passing inside `client.md` and `client/sheet.md`.

### Node Properties dialog

Covers UC-12 (engineer side). The properties grid for any selected
node is the main configuration entry point and has no page of its own.

### Table editor (`TableEditor` window)

Used for bulk editing collections of nodes. Distinct from the read-only
`Table` view documented in `client/table.md`.

### Users grid (`Users` window)

`dev/users.md` describes role *concepts* in 150 words; the actual Users
table window — list, create, edit, password reset — is not documented.

### Formats editor (`TsFormats` window)

The TS-format editor where ON / OFF labels and colours are configured.
Referenced indirectly from `dev/data-items.md`.

### Simulation Signals editor

`dev/data-items.md` mentions emulation as a per-item option. The
*Simulation Signals* window itself (where simulated periodic, sine,
random etc. signals are defined) has no page.

### Historical Databases editor

The configuration of separate historical databases (depths, write
rates, item subscriptions) is undocumented. Architecture mentions
multiple historical DBs; there is no UI walkthrough.

### Vidicon display window

Covers UC-11, FR-20. Mentioned only in `server.md`. Add an operator
page describing what the display window shows and how it interacts
with live data.

## Theming and appearance

### Document Fusion style and colour customisation

Covers FR-18. The default style is Fusion and the alarm / bad-value
colours are configurable from settings. Neither the style switcher nor
the colour palette is documented.

## Command-line reference

### Comprehensive command-line option list

Covers FR-23. Only `--debug` (in `client/debugger.md`) is documented.
Add a reference page covering all the switches: verbose-logging,
log-service-read, log-service-browse, log-service-history,
log-service-event, log-service-model-change-event,
log-service-node-semantics-change-event, locale override.

## Localisation

### How to ship the client in another language

Covers UC-21, FR-17. The shipped UI is Russian-only. If a non-Russian
deployment is wanted, document the `.ts` / `.qm` workflow,
`LocaleName` setting, and which strings cannot currently be
translated. (Skip this entry if Russian is intended to remain the
only shipped locale.)

## Misc

### Web (Wt) interface parity matrix

Covers UC-20. `client/web.md` lists capabilities and limitations as
prose. A small parity matrix (Qt vs Wt, per view type) would let
users see at a glance what works in the web client and what doesn't.

## Out of scope (no user docs needed)

These requirements-doc items are intentionally internal and do
**not** need user-facing documentation:

- **FR-21** Offline screenshot generator. Developer / CI tooling.
- **FR-22** Metrics and traces for centralised observability. Internal
  to the client and the operations team's monitoring stack.
- All non-functional requirements (NFR-1..11) — architecture and
  implementation details, covered in
  [`client/docs/requirements.md`](https://github.com/alexsmn/scada-client/blob/main/docs/requirements.md).
