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

- **Section rail** (left) — three zones: the **sidebar modes**, the profile's
  **pages** on their own band, and the **pinned commands** at the foot.
  Described [below](#activity-bar). The unacknowledged-events count lives in
  the context strip.
- **Context strip** (top) — the search/command field and the alarm state:
  severity tiles ("Critical N", "Warning N", "Unacknowledged N",
  highlighted while alarms are active; with more than ten unacknowledged
  alarms the counters give way to a single "Alarm flood" indicator). The user,
  the connection state and the server address are not shown here — they appear
  in the status strip only.
- **Object explorer** — the object tree with a "Filter" field and quality
  dots: green — good, amber — uncertain, red — bad.
- **Workspace tabs** — the open windows (journal, tables, graphs, schematic
  displays) as editor-style tabs.
- **Right-hand panels** — Inspector, Device diagnostics, Access rights,
  Transmission rule; they fill from the current selection.
- **Status strip** (bottom) — the event summary, the minimum severity, the
  highest active severity, the user and role, the connection state, the server
  round-trip time, and the server address and version. This is the only place
  the user and the connection details are shown.

The server round-trip time is the age of an outstanding ping, so a growing
number means no answer is arriving. Past 3 seconds the cell gains a "no
response" marker and a warning is added to the journal: either the connection
has degraded, or the client itself has stopped running — the operating system
can suspend a client whose window is not visible, which halts data and events,
not only the display. A separate event reports when the server answers again.

By default the appearance follows the operating system; dark, light and
high-contrast variants are also available
(*Settings → Settings… → Colour scheme*).
Values and timestamps in all tables render in a monospace font. Dialogs — login, control and manual input, limits, password
change, period selection, object creation, About — follow the same theme.

## [](#activity-bar)The section rail

A narrow strip down the left edge of the window, in three zones. It **never
opens a workspace tab** — each zone answers a different level of navigation.

![](../../img/workbench-activity-rail.png)

<dl>

<dt>Sidebar modes (top)</dt>
<dd>Select <b>what the sidebar shows</b>: Objects (the object tree and
portfolios), Devices (the hardware tree), Files (files and favourites), Nodes
(the address space) and Administration (the administrator's section list). A
mode changes only what fills the sidebar — it never opens a tab and never
changes the page. Nodes and Administration are for administrators only: for
everyone else those buttons are <b>hidden</b>, not disabled.</dd>

<dt>Pages (middle, on their own band)</dt>
<dd>The profile's pages; each one replaces the whole workspace. A button
carries the page's chosen icon, or its position when no icon is set; the title
and the position are both in the tooltip (<code>2 · Alarms</code>), because
neither fits a 52px button. "+" creates a page. The band behind this group is
what keeps the active-page marker from reading as a mode marker: a mode and a
page are active at the same time, and the two markers are drawn alike.</dd>

<dt>Pinned commands (bottom)</dt>
<dd>Settings opens the <a href="#settings-dialog">settings dialog</a>; Users
opens the account list. A pinned command opens <b>in the current page</b>, the
way any window does, so the page marker stays lit. Users is for administrators
only and is hidden for everyone else.</dd>

</dl>

A page can be **moved by dragging**: a line between the buttons shows where it
will land. The gap between two buttons and the area below the last one are both
valid drop positions.

Right-click a page button for its menu:

<dl>

<dt>Open page</dt>
<dd>Switch to it. Absent when the page is already open.</dd>

<dt>Rename…</dt>
<dd>Set the title. Acts on the current page.</dd>

<dt>Duplicate</dt>
<dd>Copy the page with its layout and windows, and switch to the copy. The copy
is taken after saving, so it carries what is on screen rather than what was
last saved.</dd>

<dt>Move up / Move down</dt>
<dd>Reorder without dragging. Up is unavailable on the first page, down on the
last.</dd>

<dt>Icon</dt>
<dd>Choose the page's icon; "None" restores the position number.</dd>

<dt>Delete page</dt>
<dd>Delete the page and its layout. Kept apart from the other items so it is
not reached by habit.</dd>

</dl>

The rail's markers are a **projection of real state**, not a memory of the last
click. If the open panes match no mode — because one was closed by hand, say —
the mode marker clears rather than claiming something that is not there.

## [](#settings-dialog)The settings dialog

*Settings → Settings…* opens the client's settings. The Settings button at the
foot of the [section rail](#activity-bar) opens the same dialog — one command
behind both, so the settings live in exactly one place.

![](../../img/settings-dialog.png)

Settings apply **immediately**, as the menu items did: there is nothing to
confirm, so the dialog carries Close alone. The checkboxes are the status bar
and toolbar visibility, control confirmation and the control success message,
event behaviour (show, hide, flash the window, sound) and — where the platform
supports speech synthesis — spoken announcements. A disabled checkbox explains
why in its tooltip. The lists at the foot are Language, Style and Colour
scheme.

## Enabling it

The experimental interface is chosen in the *Settings → Settings…* dialog,
from the **Colour scheme** list — next to *Style*, and behaving the same way:
the choice applies immediately, with no restart.

<dl>

<dt>Classic</dt>
<dd>The client's ordinary look: the operating system's appearance, with the
experimental interface off. The default.</dd>

<dt>Follow system</dt>
<dd>The experimental interface in whichever appearance — light or dark — the
operating system is set to. A desktop appearance switch applies
immediately.</dd>

<dt>Dark, Light, High contrast</dt>
<dd>The experimental interface in an explicitly chosen appearance. Such a
choice does not follow the operating system.</dd>

</dl>

The choice is saved when the client exits and restored on the next start.

**Colours change immediately, the layout after a restart.** Switching between
appearances (from dark to light, say) applies in full. Crossing between
Classic and any experimental-interface appearance also changes what the
workbench contains — the activity bar, the context bar and the Inspector —
and that is built when the client starts. The client says so when you cross
that boundary.

### Additional settings

The menu choice is kept in the application settings (QSettings), which can
also be set in advance — when rolling the client out to many machines, say.

<dl>

<dt>Ux/Experimental</dt>
<dd>Whether the experimental interface is on. Corresponds to choosing anything
other than Classic.</dd>

<dt>Ux/Theme</dt>
<dd>Appearance variant: <code>system</code> (default, follows the OS),
<code>dark</code>, <code>light</code>, <code>hc</code> (high contrast).
Mirrors the menu choice.</dd>

<dt>Ux/StyleSheet</dt>
<dd>When <code>false</code>, theming is limited to the colour palette, without
the global stylesheet — for configurations with embedded, style-sensitive
components. Not exposed in the menu.</dd>

</dl>

## [](#menu-reasons)Why a command is unavailable

When a context-menu command is disabled, hovering it shows a tooltip with
the reason — "The signal has no output channel" for *Control…*, say, or
"Nothing is waiting to be acknowledged" for *Acknowledge All*. That makes
it clear whether the command is blocked by the object's state or simply
does not apply to the current selection.

Commands that are unavailable outright (without the Control privilege, for
example) are not listed in the menu at all; for a selected object the
[Inspector](#inspector) shows that reason instead.

## [](#login)Signing in

![]({{ '/img/workbench-login.png' | relative_url }})

Under the experimental interface the sign-in window gains a header with the
product mark and name, and a "Connecting to:" line below the fields showing
which server and protocol the client is about to use. The line follows the
fields as you change them, which helps avoid signing in to the wrong server.
The fields themselves and the sign-in flow are unchanged.

## [](#overview)The Overview landing page

![]({{ '/img/workbench-overview.png' | relative_url }})

A fresh profile (no saved pages) opens on the Overview page — the
operator's working screen: the sidebar with the object tree on the left, a
dominant trend on top (about two thirds of the screen) with the
active-alarm table under it (the event journal in current mode,
unacknowledged events only), and the Inspector on the right.

The sidebar hosts several panes: "Objects" (the object tree with its filter
and quality dots), "Favorites" and "Portfolio". The tabs along the bottom of
the panel switch between them; "Objects" is the one open by default. The severity summary stays
visible in the top-bar tiles throughout. The trend is empty until the
operator adds signals to it; the page layout is saved in the profile as a
regular page.

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

- **Row colour is severity.** An alarm row is coloured by its severity (red —
  critical, amber — warning); routine events stay unfilled so the eye is drawn
  only to alarms. Acknowledging does not change the row's colour.
- **Pending dot** — the leading column marks every unacknowledged row with a
  dot, and such a row's "Acknowledge Time" cell reads "— pending —". The dot
  carries the acknowledgement state and the row colour carries the severity,
  so a pending critical alarm still reads red. The dot stays out of exports
  and printouts — it is display chrome, not part of the record.
- **Named severity** — the "Severity" column names the alarm band next to the
  number ("Critical 800", "Warning 600").
- **Areas sidebar** — to the left of the journal, "All areas" and the
  top-level object areas; an area with unacknowledged events carries their
  count. Selecting an area filters the journal to it; the other areas keep
  their counts meanwhile.
- **Footer strip** — below the journal, a summary of the displayed
  unacknowledged events ("Unacknowledged: N · highest: Critical 800"; a quiet
  journal reads "No unacknowledged events") and an *Acknowledge All* button
  running the same command as the context menu. The button is disabled when
  there is nothing to acknowledge.

A live alarm that also appears in the read history shows as one row — the
journal does not duplicate it with its historical copy.

## [](#transmission)Transmission rules

![]({{ '/img/transmission-rules.png' | relative_url }})

The transmission window (a device's "signal → address" rule list) renders in
the workbench theme. A destination rail on the left lists every
retransmission destination device with its rule count; picking a destination
switches the table to its rules, and the count updates as rules are added or
removed. Selecting a rule fills the Transmission-rule panel on the right:

![]({{ '/img/transmission-rule.png' | relative_url }})

The panel shows the source signal (with its TS/TI type tag), the destination
device, the protocol and the address (IOA); the address is editable behind
Revert/Apply when a write path is available.

## [](#display)Schematic display

![]({{ '/img/substation-display.png' | relative_url }})

Under the experimental interface the schematic (single-line) display window
gains a toolbar (a "Live" indicator, zoom / fit / 100% / export) and two bay
strips below it: "Measurements" — the selected signals' values with their
update times — and "Recent events" — the active (unacknowledged) alarms with
their severity, time, object and message. The diagram geometry is unchanged.

## [](#inspector)Inspector

![]({{ '/img/inspector-panel.png' | relative_url }})

The Inspector panel (on the right) reflects the active window's current
selection:

- the object's name and its address — a node identifier or a formula;
- the current value in large type with its quality flag ("Good" / "Bad");
- the time of the last update;
- the signal's limits — every configured band ("HiHi", "Hi", "Lo", "LoLo").
  The band the current value has crossed is coloured and labelled, so it is
  clear which limit tripped. The section is hidden for signals that configure
  no limits;
- a *Control…* button that opens the two-stage command confirmation. When
  control is unavailable, the reason appears under the button: the object
  cannot be controlled (a computed expression or a folder, for example), the
  signal has no output channel, or the session lacks the Control privilege.

Selecting a table row — including a formula row — fills the Inspector; the
value keeps updating while the row stays selected. Clicking an element on a
schematic display selects it in the Inspector as well.

![]({{ '/img/inspector-event.png' | relative_url }})

Selecting a row in the [event journal]({{ '/en/client/events/' | relative_url }})
shows the event card in the Inspector: the source and its address, the
severity (band name and number), the message, the event time and the
acknowledgement state ("— pending —" while unacknowledged). The *Acknowledge*
button runs the journal's own acknowledge command and is disabled for
already-acknowledged events. The *To graph* button opens a graph of the
event's source, so you can jump from an alarm message straight to the
signal's trend. The button is disabled when the event's source could not be
resolved.

Below that, the "History" section shows the event's own lifecycle: when it
was raised, when the server received it (that row appears only when delivery
lagged, so the gap shows the delay) and when it was acknowledged. For a
pending event the last row — "Awaiting acknowledgement" — carries no time.

## Translation status

This English page matches the Russian page content as of the description of
the experimental workbench: the shell walkthrough, enabling, the command
palette, the Table toolbar, the event journal's alarm surface, the
transmission rules, and the Inspector.

## [](#administration)Administration

The experimental interface adds an **Administration** mode to the activity
bar — a fifth one after Objects, Devices, Files and Nodes. It is available only
to an account holding the configure right: without it the mode is not shown at
all, rather than shown and disabled.

Its explorer lists the administrative windows: Users, Roles, Password policy,
Databases, Formats, Simulated Signals. The list is built from the commands the
shell can actually carry out, so a window missing from the build, or one this
session may not open, is simply not offered.

### [](#users)Users

The Users window reads the server's standard account list and shows, for each
account: its name, description, **roles**, and whether it is enabled. A
disabled account cannot log in.

The Roles column *is* the permission model: the server grants rights by role,
not by the former pair of access-right bits. An account may hold several roles
at once, and their permissions combine. "None" means the account holds no
role — it can log in and nothing more; "No data" means the role list could not
be read, which is not the same thing.

### [](#roles)Roles

The Roles window lists every role on the server together with its members. The
Type column distinguishes standard roles, which cannot be deleted, from custom
roles created in this installation. The window is read-only: changing a role's
membership is a privileged operation performed on the server.

### [](#password-policy)Password policy

The Password policy window shows what the server requires of a new password:
the permitted length, the required character classes, and the written
description of the rule configured in this installation. These are not client
settings — they are the rules the server itself validates against.

The same rules apply when changing a password: the dialog warns about a
mismatch before sending the request, but the server always makes the final
decision.

### [](#set-password)Setting a password

The *Set Password…* command behaves differently depending on whose account it
is:

- **your own** — the current password must be entered;
- **someone else's** (an administrator reset) — the current-password field is
  not shown: the server does not check it, so asking for it would be
  misleading.

### [](#audit-log)Audit log

The Audit log window is the event journal narrowed to audit events: who did
what to accounts, passwords and role membership. Both successful and refused
operations are recorded — a log showing only what succeeded cannot answer who
*tried*.

The window is available to administrators only. It carries no acknowledgement
controls: an audit entry records what happened, and there is nothing in it to
acknowledge.
