---
title: Experimental interface
nav_order: 15
parent: Client
permalink: /en/client/workbench/
---

# Experimental interface
{:.no_toc}

* TOC
{:toc}

The client ships an experimental interface variant — an "operator
workbench". The experimental interface is **off by default** and does not
change the familiar client look; it is still under active development and its
elements may change.

![]({{ '/img/workbench-window.png' | relative_url }})

The workbench regions:

- **Section rail** (left) — switches between the overview, alarms, trends,
  substations and tables; the Alarms section carries an unacknowledged-events
  badge.
- **Context strip** (top) — the search/command field and the state
  indicators: severity tiles ("Critical N", "Warning N", "Unacknowledged N",
  highlighted while alarms are active; with more than ten unacknowledged
  alarms the counters give way to a single "Alarm flood" indicator), the user
  and role, the connection state and the server version.
- **Object explorer** — the object tree with a "Filter" field and quality
  dots: green — good, amber — uncertain, red — bad.
- **Workspace tabs** — the open windows (journal, tables, graphs, schematic
  displays) as editor-style tabs.
- **Right-hand panels** — Inspector, Device diagnostics, Access rights,
  Transmission rule; they fill from the current selection.
- **Status strip** (bottom) — the event summary, the user and role, the
  connection, and the server address and version.

The dark theme is the default; light and high-contrast variants are available
(`Ux/Theme`). Values and timestamps in all tables render in a monospace font. Dialogs — login, control and manual input, limits, password
change, period selection, object creation, About — follow the same theme.

## Enabling it

The experimental interface is enabled with the *Settings → Experimental UX*
menu item (a client restart is required), the `Ux/Experimental` application
setting (QSettings), or the `SCADA_UX_EXPERIMENTAL` environment variable.
Additional settings:

<dl>

<dt>Ux/Theme</dt>
<dd>Theme variant: <code>dark</code> (default), <code>light</code>,
<code>hc</code> (high contrast).</dd>

<dt>Ux/StyleSheet</dt>
<dd>When <code>false</code>, theming is limited to the colour palette, without
the global stylesheet — for configurations with embedded, style-sensitive
components.</dd>

</dl>

## [](#palette)Command palette

![]({{ '/img/command-palette.png' | relative_url }})

*Ctrl+K* (or clicking the search field in the context strip) opens the command
palette: an input line filtering as you type, every registered command and
window-open action, plus signal search by name — a chosen signal opens in a
table. *Enter* runs the selected entry.

## [](#table-toolbar)Table: the toolbar

![]({{ '/img/table-workspace.png' | relative_url }})

In the experimental interface the [Table]({{ '/en/client/table/' | relative_url }}) window gains a toolbar
above the grid:

<dl>

<dt>+ Add signal</dt>
<dd>Opens the editor on the table's trailing row ("Enter expression") to type
an object alias or a formula.</dd>

<dt>Delete Row, Move Up, Move Down</dt>
<dd>Actions on the selected rows — the same commands as the context menu.
Commands that do not apply to the current selection (for example, with no row
selected) are greyed out.</dd>

<dt>Sort: Name / Channel</dt>
<dd>The row sort key (see <a href="{{ '/en/client/table/' | relative_url }}#sort">Sorting</a>); the active
key is highlighted.</dd>

<dt>To graph, CSV, Print</dt>
<dd>Opens a graph for the selected object, exports the table to CSV, prints.
These buttons appear when the corresponding command is available in the
current session and the window is active.</dd>

</dl>

In addition, values and timestamps in all tables render in a monospace font —
digits stay aligned and do not shift as values update — and two columns appear
next to the value: "Quality" with a textual quality flag, and "Trend" with a
mini-graph of the value over the last hour, updating live.

## [](#journal)Event journal as an alarm surface

![]({{ '/img/events-alarm-surface.png' | relative_url }})

In the experimental interface the [event journal]({{ '/en/client/events/' | relative_url }})
reads as an alarm surface:

- **Pending dot** — the leading column marks every unacknowledged row with a
  severity-coloured dot (red — critical, amber — warning), and such a row's
  "Acknowledge Time" cell reads "— pending —". The dot stays out of exports
  and printouts — it is display chrome, not part of the record.
- **Named severity** — the "Severity" column names the alarm band next to the
  number ("Critical 80", "Warning 60").
- **Areas sidebar** — to the left of the journal, "All areas" and the
  top-level object areas; an area with unacknowledged events carries their
  count. Selecting an area filters the journal to it; the other areas keep
  their counts meanwhile.
- **Footer strip** — below the journal, a summary of the displayed
  unacknowledged events ("Unacknowledged: N · highest: Critical 80"; a quiet
  journal reads "No unacknowledged events") and an *Acknowledge All* button
  running the same command as the context menu. The button is disabled when
  there is nothing to acknowledge.

A live alarm that also appears in the read history shows as one row — the
journal does not duplicate it with its historical copy.

## [](#transmission)Transmission rules

![]({{ '/img/transmission-rules.png' | relative_url }})

The transmission window (a device's "signal → address" rule list) renders in
the workbench theme, and selecting a rule fills the Transmission-rule panel
on the right:

![]({{ '/img/transmission-rule.png' | relative_url }})

The panel shows the source signal (with its TS/TI type tag), the destination
device, the protocol and the address (IOA); the address is editable behind
Revert/Apply when a write path is available.

## [](#inspector)Inspector

![]({{ '/img/inspector-panel.png' | relative_url }})

The Inspector panel (on the right) reflects the active window's current
selection:

- the object's name and its address — a node identifier or a formula;
- the current value in large type with its quality flag ("Good" / "Bad");
- the time of the last update;
- a *Control…* button that opens the two-stage command confirmation. The
  button is disabled when the object is not commandable — for example, for a
  computed expression.

Selecting a table row — including a formula row — fills the Inspector; the
value keeps updating while the row stays selected. Clicking an element on a
schematic display selects it in the Inspector as well.

![]({{ '/img/inspector-event.png' | relative_url }})

Selecting a row in the [event journal]({{ '/en/client/events/' | relative_url }})
shows the event card in the Inspector: the source and its address, the
severity (band name and number), the message, the event time and the
acknowledgement state ("— pending —" while unacknowledged). The *Acknowledge*
button runs the journal's own acknowledge command and is disabled for
already-acknowledged events.

## Translation status

This English page matches the Russian page content as of the description of
the experimental workbench: the shell walkthrough, enabling, the command
palette, the Table toolbar, the event journal's alarm surface, the
transmission rules, and the Inspector.
