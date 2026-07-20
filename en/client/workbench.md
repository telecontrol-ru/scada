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
workbench": a dark colour scheme (dark / light / high-contrast variants), one
shared palette for severity and quality colours, a section rail on the left, a
context strip with alarm indicators on top, a command palette (*Ctrl+K*) and
an Inspector panel on the right. The experimental interface is **off by
default** and does not change the familiar client look; it is still under
active development and its elements may change.

## Enabling it

The experimental interface is enabled with the `Ux/Experimental` application
setting (QSettings; there is no settings-dialog item yet) or the
`SCADA_UX_EXPERIMENTAL` environment variable. Additional settings:

<dl>

<dt>Ux/Theme</dt>
<dd>Theme variant: <code>dark</code> (default), <code>light</code>,
<code>hc</code> (high contrast).</dd>

<dt>Ux/StyleSheet</dt>
<dd>When <code>false</code>, theming is limited to the colour palette, without
the global stylesheet — for configurations with embedded, style-sensitive
components.</dd>

</dl>

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

## Translation status

This English page matches the Russian page content as of the initial
description of the experimental workbench (enabling, the Table toolbar,
the Inspector).
