---
title: Operator workbench
nav_order: 16
parent: Client
permalink: /en/client/workbench/
---

# Operator workbench
{:.no_toc}

* TOC
{:toc}

The client window is laid out as an operator workbench: the section rail on
the left, the context strip along the top, workspace tabs in the middle, the
selection-driven panels on the right and the status strip at the foot. All of
those regions are described below.

![]({{ '/img/workbench-window.png' | relative_url }})

The workbench regions:

- **Section rail** (left) — three zones: the **sidebar modes**, the profile's
  **pages**, and the **pinned commands** at the foot. Described
  [below](#activity-bar).
- **Context strip** (top) — the [path](#breadcrumb), the search/command field
  and the alarm state: the severity tiles "Critical N", "Warning N" and
  "Unacknowledged N" (highlighted while alarms are active), and beside them a
  flashing "Unacknowledged critical" indicator while a critical event is
  unacknowledged and an "Alarm flood (N)" indicator while more than ten events
  are unacknowledged. The tiles and indicators count the Server's events and
  the client's own warnings and errors; the client's information messages are
  counted only by "Events: N" in the status strip (see
  [Alarm annunciation]({{ '/en/client/alarms/' | relative_url }}#escalation)).
  The user, the connection state and the server address are not shown here —
  they appear in the status strip only.
- **Object explorer** — the object tree with a "Filter" field and quality
  dots: green — good, red — bad, blinking yellow — the object has an
  unacknowledged event. See
  [Reading values and colours]({{ '/en/client/' | relative_url }}#quality-legend). The tree starts at its
  content: the pane's own title already names it, so no separate root row is
  drawn. The same holds for the Devices, Files and Nodes panes.
- **Workspace tabs** — the open windows (journal, tables, graphs, schematic
  displays) as editor-style tabs.
- **Right-hand panels** — Inspector, Device diagnostics, Access rights,
  Transmission rule; they fill from the current selection.
- **Status strip** (bottom) — the event summary, the minimum severity, the
  highest active severity, the user and role, the connection state, the server
  round-trip time, and the server address and version. This is the only place
  the user and the connection details are shown.

> **Caution.** The status bar can be hidden (*Settings → Settings… →
> Workspace → Status Bar*, separately for each main window), and then nothing
> in that window reports a lost connection to the Server except the messages
> in the event panel. Do not hide the status bar at an operator workstation.

The server round-trip time is the age of an outstanding ping, so a growing
number means no answer is arriving. Past 3 seconds the cell gains a "no
response" marker and the event panel gets the warning "The server has not
answered a ping for N ms…": either the connection has degraded, or the client
itself has stopped running — the operating system can suspend a client whose
window is not visible, which halts data and events, not only the display. When
the server answers again, the event panel shows "The server is answering
again.".

By default the appearance follows the operating system; dark, light and
high-contrast variants are also available
([*Settings → Settings… → Colour scheme*](#appearance)).
Values and timestamps in all tables render in a monospace font. Dialogs — login, control and manual input, limits, password
change, period selection, object creation, About — follow the same theme.

## The section rail {#activity-bar}

A narrow strip down the left edge of the window, in three zones. It **never
opens a workspace tab** — each zone answers a different level of navigation.

![]({{ '/img/workbench-activity-rail.png' | relative_url }})

<dl>

<dt>Sidebar modes (top)</dt>
<dd>Select <b>what the sidebar shows</b>: Objects (the object tree and
portfolios), Devices (the hardware tree), Files (files and favourites), Nodes
(the address space) and Administration (the administrator's section list). A
mode changes only what fills the sidebar — it never opens a tab and never
changes the page. Nodes and Administration are for administrators only: for
everyone else those buttons are <b>hidden</b>, not disabled.</dd>

<dt>Pages (middle, on a background of their own)</dt>
<dd>The profile's pages; each one replaces the whole workspace. A button
carries the page's chosen icon, or its position when no icon is set; the title
and the position are both in the tooltip (<code>2 · Alarms</code>), because
the title does not fit the narrow button. "+" creates a page. A mode and a page
are marked alike and are active at the same time; the page buttons sit on a
background of their own so the two markers are not confused.</dd>

<dt>Pinned commands (bottom)</dt>
<dd>Settings opens the <a href="#settings">settings</a>; Users
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
<dd>Delete the page and its layout. It comes last and is kept apart from the
other items — in this menu and in the main <i>Page</i> menu — so it is not
reached by habit. The client asks for confirmation before deleting. The
deleted page's windows go to the recycle list of closed windows and can be
restored from the <i>Window</i> menu; the list keeps the 10 most recently
closed windows.</dd>

</dl>

The mode marker shows what is open now, not which button was pressed last. If
the open panes match no mode — because one was closed by hand, say — the mode
marker clears.

## The path {#breadcrumb}

The left of the context strip states where the workspace currently is:
**page → view → selected object**. It is the only region that names the
object: the section rail names the mode and the page, the tab names the view,
and neither says what the view is pointed at.

The page and the object are shown in bold. When nothing is selected in the
view, the path ends at the view; when the view is named after its object, the
object's name is not repeated. No object is named for a multiple selection. A
long path is shortened to fit the strip.

## Settings {#settings}

*Settings → Settings…* opens the client's settings. The Settings button at the
foot of the [section rail](#activity-bar) opens the same thing — one command
behind both, so the settings live in exactly one place.

![]({{ '/img/settings.png' | relative_url }})

The settings screen opens over the main window: a search field along the top,
the categories down the left with the number of settings in each, and scope
tabs above the list — All, This client, Profile, This window.

Every setting carries a description and a scope label, so it is visible which
ones are kept on this computer only and which are in the user's profile,
which the client also saves on the Server when it closes; do not count on
those settings appearing by themselves in the client on another computer. Settings apply **immediately**: there is nothing to confirm, and the
screen closes from the close button in its header. Settings in the Profile
scope are kept in the user's profile on the Server. The profile is written to
the Server when the client exits and on *More → Disconnect from Server*, not
at the moment a setting changes. If the profile cannot be saved on the
Server, the client reports "Failed to save the profile to the server; it is
kept on this computer only" — but on exit that message appears in a client
that is already closing and is usually not seen. So close the client only
while the status bar reads "Connected".

| Category | Settings |
|---|---|
| Appearance | Language, Colour scheme, Style |
| Events & alarms | Sound Alarm on Event, Speech, Show Events on Arrival, Hide Events on Acknowledge, Flash Main Window on Event — see [Alarm annunciation]({{ '/en/client/alarms/' | relative_url }}) |
| Control | Control Confirmation, Control Success Message — see [Control]({{ '/en/client/' | relative_url }}#control) |
| Workspace | Status Bar |
| Displays | Show Modus topology; the Open Displays Folder action |

*Speech* switches the spoken announcement on and off; on a computer without a
speech-synthesis voice it is shown disabled — see
[Spoken announcement]({{ '/en/client/alarms/' | relative_url }}#speech).

## Appearance {#appearance}

The appearance is chosen in *Settings → Settings…*, from the
**Colour scheme** list — next to *Style*, and behaving the same way: the
choice applies immediately and in full, with no restart.

<dl>

<dt>Follow system</dt>
<dd>Whichever appearance — light or dark — the operating system is set to. The
default; a desktop appearance switch applies immediately.</dd>

<dt>Dark, Light, High contrast</dt>
<dd>An explicitly chosen appearance, which does not follow the operating
system. Dark is the recommended control-room setting.</dd>

</dl>

The choice is saved when the client exits and restored on the next start.

Alarm severity, data quality and switchgear state keep their colours whatever
the appearance: those are safety signals, and their values are the same in
every scheme.

### Presetting the appearance

The appearance choice is kept on the computer, in the operating-system user's
settings: on Windows in the registry, under
`HKEY_CURRENT_USER\Software\Telecontrol\Telecontrol SCADA Client\Ux`. The
values can be set in advance — when rolling the client out to many machines,
say.

<dl>

<dt>Ux/Theme</dt>
<dd>Appearance variant: <code>system</code> (default, follows the OS),
<code>dark</code>, <code>light</code>, <code>hc</code> (high contrast).
Mirrors the Colour scheme list.</dd>

<dt>Ux/StyleSheet</dt>
<dd>When <code>false</code>, theming is limited to the colour palette, without
the global stylesheet — for configurations with embedded, style-sensitive
components. Not shown on the settings screen.</dd>

</dl>

## Why a command is unavailable {#menu-reasons}

When a context-menu command is disabled, hovering it shows a tooltip with
the reason — "The signal has no output channel" for *Control…*, say, or
"No event shown here is waiting to be acknowledged" for *Acknowledge All* in
the event journal. That makes
it clear whether the command is blocked by the object's state or simply
does not apply to the current selection.

Commands that are unavailable outright (without the Control privilege, for
example) are not listed in the menu at all; for a selected object the
[Inspector](#inspector) shows that reason instead.

## Signing in {#login}

![]({{ '/img/workbench-login.png' | relative_url }})

The sign-in window has a "Server:" row (the server type and the address), a
user name, a password and a "Sign in automatically next time" box. Signing in
is described in [Getting started]({{ '/en/getting-started/' | relative_url }}#client-start).

The server type is picked from the list left of the address; the list is shown
only when the client supports more than one type. To work with the SCADA Server,
choose **"Telecontrol"**.

The OPC UA security settings — the mode, the client certificate and the
private key — sit behind a "Security and certificates" disclosure. It is shown
only for the "OPC UA" server type, and it opens by itself when any of them
already carries a value. The "Telecontrol" type does not have it.

When the client supports only one server type, a "Connecting to: …" line
naming it appears below the fields.

## The Overview landing page {#overview}

![]({{ '/img/workbench-overview.png' | relative_url }})

A fresh profile (no saved pages) opens on the Overview page — the
operator's working screen: the sidebar with the object tree on the left, a
dominant trend on top (about two thirds of the screen) with the
active-alarm table under it (the event journal in current mode,
unacknowledged events only), and the Inspector on the right.

The sidebar carries the "Objects" mode's panes: "Objects" (the object tree
with its filter and quality dots) and "Portfolio". The tabs along the bottom
of the panel switch between them; "Objects" is the one open by default. Other
modes' panes are absent from the page — "Favorites", for one, belongs to the
"Files" mode, and the sidebar is conformed to whichever mode is selected. The severity summary stays
visible in the top-bar tiles throughout. The trend is empty until the
operator adds signals to it; the page layout is saved in the profile as a
regular page.

## Command palette {#palette}

![]({{ '/img/command-palette.png' | relative_url }})

*Ctrl+K* (or clicking the search field in the context strip) opens the command
palette: an input line filtering as you type, every registered command and
window-open action, plus signal search by name — a chosen signal opens in a
table. *Enter* runs the selected entry.

## Table: the toolbar {#table-toolbar}

![]({{ '/img/table-workspace.png' | relative_url }})

The [Table]({{ '/en/client/table/' | relative_url }}) window carries a toolbar
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

## Event journal as an alarm panel {#journal}

The [event journal]({{ '/en/client/events/' | relative_url }}) reads as an
alarm panel:

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
  running the same command as the context menu. The button acknowledges only
  the events the journal shows — after the selected area, the minimum
  severity, the object list and the unacknowledged-only filter; events the
  filters hide stay unacknowledged. The button is disabled when nothing shown
  is waiting to be acknowledged.

A live alarm that also appears in the read history shows as one row — the
journal does not duplicate it with its historical copy.

## Transmission rules {#transmission}

Transmission forwards SCADA objects to upper-level systems. Every destination
device has its own rule table, and one rule binds one SCADA object to one
information-channel address in the remote system. The mechanism is described
on the [Architecture]({{ '/en/architecture/' | relative_url }}) page.

![]({{ '/img/client-retransmission.png' | relative_url }})

### Opening the table

The **Transmission table** command opens the rule table of the selected
device. It is available when the selection is a destination device (not a
communication link) and the user holds the configure permission. The
destination device itself is created in the configuration like any other
device — the command opens its table, it does not create the device.

The destination rail on the left lists every retransmission destination
device with its rule count; picking a destination switches the table to its
rules, and the count updates as rules are added or removed.

### Protocol

A rule's protocol follows from the destination device's type and is not
chosen separately. **Modbus**, **IEC 60870-5-104** and **IEC 61850** are
supported. A device whose type declares no transmittable items does not
appear in the destination rail.

### Creating a rule

The table is filled from the [object tree]({{ '/en/client/' | relative_url }}):
tick an object and a rule for it appears in the table under the Object
column; clearing the tick deletes the rule. The ticks in the tree always
match the contents of the open table.

Each new rule needs a destination address, typed directly into the table's
Address column. The Object column is not editable — the source is set only by
the tick in the tree.

Selected rules are removed with the **Delete** command, which requires the
delete-node permission.

### The Transmission-rule panel

Selecting a rule fills the Transmission-rule panel on the right:

![]({{ '/img/transmission-rule.png' | relative_url }})

The panel shows the source signal (with its TS/TI type tag), the destination
device, the protocol and the address (IOA); the address is editable behind
Revert/Apply when a write path is available.

### What happens at run time

The rules are executed by the Server, not the client — the client only edits
the table. The Server then sends the listed objects' values to the remote
system over the destination device's protocol, and relays control commands
arriving from the remote system at those addresses back to the equipment.
Table changes take effect without restarting the client.

## Schematic display {#display}

![]({{ '/img/substation-display.png' | relative_url }})

A Vidicon display window (`.vds` files) carries a toolbar (a connection pill,
zoom / fit / 100% / export) and two bay strips below it: "Measurements" — the
values of the signals whose shapes the operator has clicked, with their update
times — and "Recent events" — the unacknowledged events of **the whole
system** (not only this display's objects), up to the 50 latest, with their
severity, time, object and message. The diagram geometry is unchanged. Modus
schematics (`.sde`, `.xsde`) have no such toolbar or strips; see
[Display]({{ '/en/client/display/' | relative_url }}).

The connection pill follows the connection to the Server: it reads "Live"
while the client is connected and turns to a red "Offline" while it is
disconnected; see
[Connection to the Server]({{ '/en/client/' | relative_url }}#connection).

> **Caution.** In this version the schematics themselves show no live
> values — read values and their quality in the "Measurements" strip and in
> the [Inspector](#inspector).

## Inspector {#inspector}

![]({{ '/img/inspector-panel.png' | relative_url }})

The Inspector panel (on the right) reflects the active window's current
selection:

- the object's name and its address — a node identifier or a formula;
- the current value in large type with its quality flag ("Good" / "Bad").
  "Bad" is shown not only for a value carrying the bad flag but also when the
  device connection is lost ([С]), on a connection failure ([Н]) or a
  configuration error ([К]), and when the value is stale ([У]);
- the time of the last update;
- the signal's limits — every configured band ("HiHi", "Hi", "Lo", "LoLo").
  The band the current value has crossed is coloured and labelled, so it is
  clear which limit tripped. The section is hidden for signals that configure
  no limits;
- a *Control…* button that opens the
  [control dialog]({{ '/en/client/' | relative_url }}#control). When
  control is unavailable, the reason appears under the button: the object
  cannot be controlled (a computed expression or a folder, for example), the
  signal has no output channel, or the session lacks the Control privilege.

Selecting a table row — including a formula row — fills the Inspector; the
value keeps updating while the row stays selected. Clicking a shape bound to
an object on a schematic display selects that object in the Inspector as well.
Clicking a shape with no object behind it, or empty space on the schematic,
clears the selection; see
[Working with a schematic]({{ '/en/client/display/' | relative_url }}#working).

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

### Series {#inspector-series}

When a chart series is selected, a **Series** section appears below the
element card — how that line is drawn:

* the colour palette, one swatch per colour; the series' current colour is
  ringed, and clicking another swatch recolours the line. It is the one field
  in the section that writes.
* "Own pane" — whether the series has a graph pane to itself
* "Show dots" and "Stepped" — how the line is drawn

Those last three are read-outs rather than switches: the graph window owns
these modes (see [Graph]({{ '/en/client/graph/' | relative_url }})).

The section belongs to the selection, not to the panel: it disappears with the
selection, so another object's card is never shown carrying the previous
view's series.

## Administration {#administration}

The activity bar carries an **Administration** mode — a fifth one after
Objects, Devices, Files and Nodes. It is available only
to an account holding the configure right: without it the mode is not shown at
all, rather than shown and disabled.

Its explorer lists the administrative windows: Users, Roles, Password policy,
Audit log, Databases, Formats, Simulated Signals. A window missing from the installation, or one this session may not open,
is not offered.

### Users {#users}

The Users window reads the server's standard account list and shows, for each
account: its name, description, **roles**, and whether it is enabled. A
disabled account cannot log in.

The Roles column *is* the permission model: the server grants rights by role. An account may hold several roles
at once, and their permissions combine. "None" means the account holds no
role — it can log in and nothing more; "No data" means the role list could not
be read, which is not the same thing.

### Roles {#roles}

The Roles window lists every role on the server together with its members. The
Type column distinguishes standard roles, which cannot be deleted, from custom
roles created in this installation. The window is read-only: changing a role's
membership is a privileged operation performed on the server.

### Password policy {#password-policy}

The Password policy window shows what the server requires of a new password:
the permitted length, the required character classes, and the written
description of the rule configured in this installation. These are not client
settings — they are the rules the server itself validates against.

The same rules apply when changing a password: the dialog warns about a
mismatch before sending the request, but the server always makes the final
decision.

### Setting a password {#set-password}

The *Set Password…* command behaves differently depending on whose account it
is:

- **your own** — the current password must be entered;
- **someone else's** (an administrator reset) — the current-password field is
  not shown: the server does not check it, so asking for it would be
  misleading.

### Audit log {#audit-log}

The Audit log window is the event journal narrowed to audit events: who did
what to accounts, passwords and role membership. Both successful and refused
operations are recorded — a log showing only what succeeded cannot answer who
*tried*.

The window is available to administrators only. It carries no acknowledgement
controls: an audit entry records what happened, and there is nothing in it to
acknowledge.

### Databases {#historical-db}

The Databases window lists the history databases configured on the server and,
for each, its state: Depth (days) — how long values are kept, Items — how many
objects write into it, Written values, Write queue, Write latency (µs), and how
long event and value cleanup take. A growing write queue means the database is
not keeping up with the incoming data.

Object and device parameters point at these databases: an object's value
archive and a device's event archive are chosen from this list. Configuring the
databases on the server side is described under
[Server]({{ '/en/server/#history' | relative_url }}).

### Formats {#ts-formats}

The Formats window defines how two-state (discrete) signals look on screen.
Each format is a pair of states: "Label 0" and "Label 1" — the texts the states
are captioned with — and "Colour 0" and "Colour 1" — the colours they are drawn
in. A colour is chosen from the client's palette by name, not entered as RGB
components.

A format is assigned to an object in its parameters (see
[Data items]({{ '/en/dev/data-items/' | relative_url }})), so one edit to a
format changes every object it is assigned to.

### Simulated signals {#simulation-items}

The Simulated signals window lists the signals the server generates itself,
with no device involved. Each carries a Type — the waveform — a Period (ms), a
Phase (ms) and an Update interval (ms) saying how often a new value is
produced. Simulated signals are used for commissioning and training: they let
displays, graphs and alarms be exercised before any equipment is connected.

## Nodes {#nodes}

The **Nodes** mode shows the whole OPC UA address space — from the server's
root folder along hierarchical references — rather than objects and equipment
alone. It is available only to an account holding the configure right and,
like Administration, is hidden from everyone else.

It is a diagnostic view of the configuration: it shows everything the server
publishes, including the service branches that the Objects and Devices panes do
not carry. The tree starts at the root folder's contents — no separate root row
is drawn.

