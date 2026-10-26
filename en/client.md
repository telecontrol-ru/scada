---
title: Client
nav_order: 7
has_children: true
permalink: /en/client/
---

# Client
{:.no_toc}

* TOC
{:toc}

The graphical client is the main operator application. It provides access to diagrams, tables, graphs, event windows, configuration tools, and data export functions.

Main client window:

![]({{ '/img/workbench-window.png' | relative_url }})

## Limitations of version 2.6 {#limitations}

Read this list before working at an operator workstation. Details are behind
the links; the limitations of the whole release are collected under
[Known limitations]({{ '/en/changes/' | relative_url }}#known-limitations).

* **The *Disconnect from Server* command does not load the new user's profile** — hand
  over by closing the client. See [Shift handover](#shift-change).
* **The spoken announcement cannot be turned off from the client.** See
  [Spoken announcement]({{ '/en/client/alarms/' | relative_url }}#speech).
* **The *More → Acknowledge All* command acknowledges every event in the
  system** — for every workstation; the client asks for confirmation first
  and states how many events. See [Common commands](#common-commands).
* **With "Sign in automatically next time" ticked the client signs the last
  account in by itself at start** — to sign in as yourself, hold *Ctrl* (on
  macOS, *Option*) while starting it, or press *Cancel* while the sign-in is
  in progress. See [Automatic sign-in](#auto-login).

## Main areas

The main window contains the title bar, the main menu and a status bar.
Operators work with multiple views inside pages and
can switch between open windows without leaving the application. The window's
regions are described in detail on the
[Operator workbench]({{ '/en/client/workbench/' | relative_url }}) page.

## Menus

The menu bar provides these main groups of commands:

* **Display**: open available schematic displays
* **Table**: *New Table*, *New Custom Table*, *New Data Table* and *Group
  Table*, followed by the tables saved to [Favourites](#pages-and-windows)
* **Graph**: *New Graph*, which opens a new graph window, followed by the
  graphs saved to [Favourites](#pages-and-windows)
* **Item**: the commands that apply to the selected object or device and to
  the active window — the same as the context menu
* **More**: open the current-events panel (*Events*) and the *Event Journal*,
  the object, hardware and file panels, engineering and configuration import
  or export tools, and *Connect to Server...* / *Disconnect from Server* (see
  [Connection to the Server](#connection))
* **Page**: create, rename, duplicate, delete and switch pages
* **Window**: rename, close, restore, and favorite open windows. Its *New*
  item (available while at least one window is open) opens **another main
  window** of the client, in the same session and under the same account.
  Closing one of several main windows does not end the session: the client
  ends it only when the last main window is closed (see
  [Shift handover](#shift-change))
* **Settings**: one item, *Settings...*, which opens the settings screen
* **Help**: open online documentation or show client version. A client
  started with the command-line option `--debug` also has *Debugger* and
  *Debug Information* here; see
  [Debugger]({{ '/en/client/debugger/' | relative_url }})

The settings screen groups the settings into categories:

* **Appearance** — Language, Colour scheme and Style.
* **Events & alarms** — *Sound Alarm on Event*, *Speech*, *Show Events on Arrival*,
  *Hide Events on Acknowledge*, *Flash Main Window on Event*. See
  [Alarm annunciation]({{ '/en/client/alarms/' | relative_url }}).
* **Control** — *Control Confirmation* (on by default) and *Control Success
  Message*. See [Control](#control).
* **Workspace** — *Status Bar*, per client window.

> **Caution.** The status bar is the only place that shows whether the client
> is connected to the Server. Do not turn it off on an operator workstation,
> in any of its main windows.

* **Displays** — *Show Modus topology*, which draws the topology layer over
  Modus displays, and the *Open Displays Folder* action.

See [Settings]({{ '/en/client/workbench/#settings' | relative_url }}) for the
screen itself. *Ctrl+K* opens the
[command palette]({{ '/en/client/workbench/' | relative_url }}#palette):
search for commands and signals by name.

## Status bar

The status bar shows:

* the number of unacknowledged events, "Events: N" (the client's own messages
  are included in it), and the highest severity among the Server's
  unacknowledged events
* the severity threshold ("Severity: N"). The client does not show or count
  events below the threshold at all: they are not in the current-events panel,
  the count or the tiles, and they do not sound the tone or the spoken
  announcement. It is changed from the current-events panel's context menu,
  *Severity → Custom...*; see
  [Severity threshold]({{ '/en/client/alarms/' | relative_url }}#threshold)
* the active user name
* the connection state: "Connected" or "Disconnected"
* the Server round-trip time, "Server: N ms" ("No response" while
  disconnected)

## Pages and windows

The central workspace is divided into pages. A client session can have
multiple pages, but only one is visible at a time. Pages are switched from
the list in the `Page` menu, or with the page buttons on the
[section rail]({{ '/en/client/workbench/#activity-bar' | relative_url }}).

The `Page` menu holds its commands in this order:

1. `New` — create a page;
2. `Duplicate` — copy the page with its content;
3. `Rename` — rename the page;
4. `Delete` — delete the current page, kept last behind a separator.

*Page → Delete* asks for confirmation first. The deleted page's windows go
to the recycle list of closed windows and can be restored from the `Window`
menu. The recycle list keeps the 10 most recently closed windows, so a page
with more windows than that cannot be restored in full.

Windows and panels can be arranged freely inside a page. They can be
docked side by side, stacked as tabs, or restored from the `Window`
menu after accidental closure. The recycle list keeps the 10 most
recently closed windows.

The `Window -> Add to Favourites` command stores a window together with its
content under a user-defined name and folder. Favorited graphs and
tables also appear at the bottom of the corresponding `Graph` and
`Table` menus for quick reopening.

## Connection to the Server {#connection}

The status bar shows the connection state, "Connected" or "Disconnected", with
the round-trip time "Server: N ms" beside it. When an answer takes longer than
3 seconds, the time gains a "no response" marker and the event panel gets the
warning "The server has not answered a ping for N ms…" («Сервер не отвечает на
опрос уже N мс…»); when the Server answers again, the panel shows "The server
is answering again." («Сервер снова отвечает.»).

**Losing the connection.** When the connection to the Server drops — including
when the Server is restarted or stopped — the client
adds a warning to the event panel ("Connection to server … lost. …
Reconnecting in N seconds.", «Соединение с сервером … потеряно. … Повторное
подключение через N с.») and reconnects by itself: the first attempt after
5 seconds, then every 30 seconds until the connection is back. Once it is, the
event panel shows "Connection to server established. Login successful."
(«Соединение с сервером установлено. Вход выполнен.»).

> **Caution.** One connection-lost warning does not sound the tone or the
> spoken announcement, but each of them stays unacknowledged: it shows in the
> "Warning" tile and counts towards the "more than ten unacknowledged events"
> condition (see [Which events raise the
> alarm]({{ '/en/client/alarms/' | relative_url }}#escalation)). Acknowledge
> these messages in the event panel. While the status bar reads "Disconnected", no new
> values or events arrive from the Server and control commands are not carried
> out — do not act on the values on screen.

**Connecting by hand.** *More → Disconnect from Server* and *More → Connect to
Server...* end the session and open the sign-in window. Only one of them is
available at a time: the first while connected, the second while disconnected.
The sign-in window these commands open always waits for input, even with
"Sign in automatically next time" ticked: no password is filled in, and you
sign in by entering a name and password (see [Automatic sign-in](#auto-login)).

**Session ended from another workstation.** If someone signs in with the same
account on another computer and ends your session (see
[Shift handover](#shift-change)), the client says so in the event panel
("Disconnected from server … These credentials are being used to log in from
another workstation.", «Отключено от сервера … С этими учётными данными
выполнен вход на другом рабочем месте.») and does **not** reconnect by itself —
otherwise it would end the session on the other workstation in turn.

## Shift handover {#shift-change}

Each operator works under their own account: the event journal records who
acknowledged an event and whose action caused it, and the workstation's
settings and pages are kept in the user's profile. The profile is saved on
this computer; in addition, the client saves it on the Server when it closes.
Do not count on pages and settings appearing by themselves in the client on
another computer.

To hand over a shift:

1. "Sign in automatically next time" must be off at this workstation —
   otherwise the client signs the outgoing operator's account in by itself at
   start. If it is ticked, the incoming operator holds *Ctrl* (on macOS,
   *Option*) while starting the client, or presses *Cancel* while the sign-in
   is in progress (see [Automatic sign-in](#auto-login)).
2. The outgoing operator makes sure the status bar reads "Connected" and
   closes **all** of the client's main windows (if several were opened with
   *Window → New*). When the last one is closed, the client saves the
   profile on the Server, ends the session and exits.
3. The incoming operator starts the client again and enters their own name
   and password in the sign-in window.

> **Caution.** Closing one of several main windows does **not** end the
> session: the remaining windows keep working under the outgoing operator's
> account. Before leaving, check the taskbar for other client windows.

The profile is written to the Server only when the client exits and on *More
→ Disconnect from Server*. If saving it fails (for example, because there is
no connection to the Server), the client reports "Failed to save the profile
to the server; it is kept on this computer only" («Не удалось сохранить
профиль на сервере; он сохранён только на этом компьютере»). On exit that
message is posted into a client that is already closing, so it is usually
not seen. Close the client only while the status bar reads "Connected";
otherwise changes to pages and settings are not written to the Server and
stay on this computer only.

> **Caution.** Do not hand over with *More → Disconnect from Server*. In the
> current version, after that command and a sign-in under another account the
> client keeps the **previous** operator's pages and settings, and on exit it
> saves them into the **new** operator's profile — overwriting that
> operator's own pages and settings on the Server. *Disconnect from Server* is
> fine for signing in again under the same account.

If the sign-in window is closed, the client stays disconnected; sign in with
*More → Connect to Server...*.

If the account is not allowed several sessions at once and is already in use
on another computer, signing in asks "The specified username is already in use
by another session. Disconnect the open session and continue?". Answering yes
ends the session on the other computer, whose client then stays disconnected.

### Automatic sign-in {#auto-login}

The "Sign in automatically next time" box in the sign-in window stores the
name and password on this computer. While it is ticked, the sign-in window
does not wait for input **when the client starts**: the client signs the last
account straight in. The sign-in window opened by *More → Disconnect from
Server* and *Connect to Server...* always waits for input: the stored password
is not filled in there. Clearing the box and signing in also makes the client
forget the stored password.

> **Caution.** Never tick this box on a shared operator workstation. With it,
> the incoming operator works under the outgoing operator's account: events
> are acknowledged and commands issued in somebody else's name.

How to sign in under another account, or clear the box:

* **Hold *Ctrl* while starting the client** (on macOS, *Option* ⌥) — the
  sign-in window appears with the box cleared and no password. Sign in under
  your own account: the client then remembers that automatic sign-in is off.
* **Press *Cancel* in the sign-in window while automatic sign-in is in
  progress.** The sign-in stops and the window waits for input; a second
  *Cancel* closes the window (at start, the client too). To stop automatic
  sign-in for good, clear the box before signing in.

## Commands {#commands}

The commands for the selected object or device are in its context menu (right
mouse button) and in the **Item** menu. A command that does not apply to
the selection is greyed out, and hovering it shows why.

*Copy*, *Paste* and *Delete* also run from the keyboard: *Ctrl+C*, *Ctrl+V*
and *Delete* (*⌘C* and *⌘V* on macOS). *Delete* asks for confirmation from the
keyboard too. A key acts only when its command applies to the selection; in a
text field or a table, *Ctrl+C* still copies the text of the cells.

**Keys on macOS.** This manual names keys as on Windows. On macOS press *⌘*
instead of *Ctrl* in shortcuts: *Ctrl+K* is *⌘K*, and selecting several rows
with *Ctrl*-click is *⌘*-click. The *Delete* key on a Mac laptop keyboard is
*fn+⌫*.

### Object commands

For the selected object you can open related views or perform actions such
as:

* [Graph]({{ '/en/client/graph/' | relative_url }})
* [Table]({{ '/en/client/table/' | relative_url }})
* [Display]({{ '/en/client/display/' | relative_url }}) — opens the Modus
  schematic that contains the object, or switches to it if it is already open.
  The object's shape is selected on it
* [Data]({{ '/en/client/data/' | relative_url }})
* [Summary]({{ '/en/client/summary/' | relative_url }})
* [Event journal]({{ '/en/client/events/' | relative_url }})
* group table
* *Acknowledge* — acknowledges all of the object's unacknowledged events
* *Unlock* — removes the object's blocking (available only while the object
  is blocked; see [Manual input](#manual-input))
* *Control…* — a control command (see [Control](#control))
* *Manual Input* (see [Manual input](#manual-input))

If a matching window is already open for the same object, the client
switches to it instead of opening a duplicate.

### Device commands

For the selected device you can open:

* [Device watch]({{ '/en/client/device-watch/' | relative_url }})
* [Device metrics]({{ '/en/client/device-metrics/' | relative_url }})

You can also:

* enable communication with the device (*Enable*)
* disable communication with the device (*Disable*)
* in the *Device* submenu, *Poll Device* (makes the Server run a forced full
  poll of the device) and *Synchronize Clock* (makes the Server synchronize the
  device clock with the Server clock)

> **Caution.** *Disable* asks for confirmation first, naming the device;
> declining changes nothing. The command changes the configuration: the
> device stays disabled — across Server
> restarts and for every workstation — until *Enable*. The Control privilege
> (the "Dispatcher" level) is enough for it. While the device is disabled the
> Server does not communicate with it, and all of its objects carry the [С]
> (no connection) flag. Before confirming *Disable*, check the device name in
> the prompt, and remember to enable it again.

A forced poll and clock synchronization are offered on devices only, not on
data objects: select the device itself, for example in the equipment panel.

For retransmission projects, the client edits a destination device's
retransmission table — the rules by which selected objects are forwarded to
upper-level systems. See
[Transmission rules]({{ '/en/client/workbench/#transmission' | relative_url }}).

### Common commands {#common-commands}

Common commands include printing the active window, opening the event window,
and *Acknowledge All*. In the context menu of the event journal and the event
panel it acknowledges only the events that window shows, after its area,
severity and object filters. In the *More* menu and the
[command palette]({{ '/en/client/workbench/' | relative_url }}#palette) it
acknowledges every unacknowledged event the client receives and every client
message, after a confirmation. Other windows' context menus do not carry it. Events below the
[severity threshold]({{ '/en/client/alarms/' | relative_url }}#threshold) are
not received by the client, so this command does not acknowledge them (see
[Event panel](#events-panel)).

> **Caution.** *More → Acknowledge All* acknowledges **every** Server event
> the client has received — across the whole system, not only the objects in
> the active window. The client first asks "Acknowledge all N unacknowledged
> events? Every alarm on the whole system is acknowledged, for every
> workstation."; "No" is the default answer. Acknowledgement is recorded on the
> Server, so those events stop being unacknowledged at every other workstation
> too. Acknowledge from the [event panel](#events-panel) or the event journal,
> where the command acts only on the events shown.

## Control {#control}

A telecontrol or teleadjustment command is issued with *Control…* — in the
object's context menu, in the **Item** menu, or with the button in the
[Inspector]({{ '/en/client/workbench/' | relative_url }}#inspector). It needs
the Control privilege.

The command opens the "Control" dialog: the object's name, "Current value:"
and "New value:". For a discrete (TS) object the new value is picked from the
list of states (the state opposite the current one is proposed); for an analog
(TI) object it is typed as a number. The "Execute" button sends the command.

Until the operator changes the "New value:" field, the proposed value follows
the object's present state: if the state changes while the dialog is open, the
proposal changes with it. Always set the new value explicitly — pick the state
in the list or type the number — even when the proposal is what you want.

A fractional number may be typed with either a decimal point or a decimal
comma: `12.5` and `12,5` are the same.

The "Control" dialog shows the present value with its quality marks: "?"
after a bad value, and the flag letters in square brackets before the value —
[С] no connection, [У] stale, [Н] connection failure, [К] configuration error,
[Р] manual input and the rest, the same letters as in the object tree and
tables (see [Reading values and colours](#quality-legend)). The Inspector
labels a value "Bad" when it is bad, and also when the device connection is
lost, the value is stale, or there is a connection failure or a
configuration error. If [С], [Н], [К] or [У] precedes the value, the equipment's present
state is unknown.

If the object has a control permission condition, the dialog has a
"Condition:" row. It reads "Satisfied" or "Unsatisfied" and updates live.
While the condition is unsatisfied (or its value is bad), "Execute" is
disabled.

### Before a control command {#control-checklist}

1. Check the object's name on the first line of the "Control" dialog (the
   window title just says "Control" and does not name the object).
2. Check the object in a table: its "Quality" column must read "Good" (see
   [Reading values and colours](#quality-legend)).
3. Make sure the status bar reads "Connected".
4. If the command ended in an error, check the object's present state before
   retrying (see [Command result](#control-result)).

### Command confirmation {#control-confirmation}

The *Control Confirmation* setting (*Settings → Settings… → Control*) is on by
default. While it is on, before a command goes to the equipment the client
shows a confirmation box: the object's name, "Present:" and "Command:" — the
present and the commanded values — and the warning "This control command is
sent to physical equipment and cannot be undone remotely. Send it?".

The "Present:" value in the confirmation box carries the same quality marks
as in the "Control" dialog: flag letters in square brackets before the value
and "?" after a bad value. Check them before confirming.

The box's default button is "No": pressing *Enter* **cancels** the command. To
send it, choose "Yes".

> **Caution.** With *Control Confirmation* off, the command goes to the
> equipment as soon as "Execute" is pressed, with no prompt at all, and in
> two-stage control the execute stage follows the select stage automatically,
> with no pause for the operator. Do not turn this setting off at an operator
> workstation.

### Two-stage control

When an object has [two-stage control]({{ '/en/dev/data-items/' | relative_url }})
enabled, the command reaches the device in two stages, as defined by
IEC 60870-5 (SELECT/EXECUTE):

1. **Select.** On "Execute" the client sends a select command at once, without
   a prompt. The device reserves its output for the requested value but
   switches nothing yet.
2. **Operator confirmation.** The prompt is shown only after the select
   succeeds, which is why it opens with "The remote device is ready to execute
   the command." It then reviews the present and commanded values and warns
   that the action cannot be undone remotely, as in one-stage control.

3. **Execute.** Answering yes sends the execute command, and the device
   switches the circuit it already reserved.

Answering no sends a cancel, so the selection is released at once instead of
staying armed until the device's own select timeout expires. Drivers that do
not implement cancel reject it; that rejection is not surfaced to the
operator, because the selection lapses on the device timeout regardless.

One-stage control is a single value write and uses neither stage; the
confirmation box is shown before that write.

### Command result {#control-result}

While the command runs, the dialog's status line shows "Preparing to control..."
or "Controlling...".

* **Success.** The dialog closes. The
  [Event journal]({{ '/en/client/events/' | relative_url }}) gets the Server's
  "Control - Done" event («Управление - Выполнено»). When the *Control Success
  Message* setting is on (it is by default), the event panel also shows a
  Client message naming the signal and the value sent, ending "Operation
  completed successfully".
* **Failure.** A message box titled "Control" (or "Manual Input") shows the
  reason, for example "Not enough rights to perform the operation." The
  control dialog stays open so the command can be retried. The event journal
  records a "Control - Failed (…)" event with the error code in brackets, for
  example "Control - Failed (Bad_Timeout)" («Управление - Ошибка
  (Bad_Timeout)»).

> **Caution.** A failure does not always mean the command was not carried out.
> On a timeout (`Bad_Timeout`) or a connection lost mid-command the device may
> have received and executed the command while the answer never reached the
> Server. Before retrying, check the object's present state — in the
> "Control" dialog, the Inspector, the [object panel](#object-panel) or a
> table: make sure no [С], [Н], [К] or [У] flag precedes the value, the value
> is good, and it has not already become the commanded one. A schematic is
> not enough for this check: it does not show the [С], [Н], [К] and [У] flags.

The same setting turns on messages for other successful operations —
configuration edits, object creation, password changes, unblocking. A failure
is always reported, whatever the setting.

Success messages are client information messages ("Local Event"): they stay
unacknowledged in the event panel until the operator acknowledges them and
are in the "Events: N" count, but the severity tiles do not show them and they
sound neither the tone nor the spoken announcement. Acknowledge them like any
other event — otherwise they hold the event panel open.

### Manual input {#manual-input}

*Manual Input* opens the "Manual Input" dialog: "Current value:", "New value:"
and a "Lock:" checkbox. The "Write" button writes the value. No confirmation
box is shown for manual input, whatever the *Control Confirmation* setting.

On a successful write the dialog closes. When the *Control Success Message*
setting is on (it is by default), the event panel shows a client message:
"Manual Input", the signal's name, the value written and "Operation completed
successfully". A failure is always reported in a message box titled "Manual
Input", whatever the setting.

A manually entered value carries the [Р] (manual) quality flag.

* **Without blocking**, the entered value holds until telemetry next arrives
  from the device, which overwrites it.
* **With blocking** ("Lock:" ticked), the Server ignores telemetry from the
  device and the manual value stays. The object carries the [Б] (blocked) flag.

When the dialog opens, "Lock:" shows whether the object is blocked now.
Clearing the box during manual input does **not** remove the blocking: to
remove it, choose *Unlock* in the object's context menu (available only for a
blocked object). After that, device telemetry is authoritative again, and the
journal records a "Lock removed" event («Блокировка снята»).

Limit values can also be edited from the client. Warning limits must
stay within the configured alarm-limit range.

## Object panel

The object panel is used to browse the object hierarchy, open related
views, and execute object operations. It is available from
`More -> Items`.

The tree starts at the top-level objects and groups: no separate root row
is drawn, because the panel's own title already names what it contains.

The panel shows objects grouped by hierarchy. Values and quality flags
appear to the right of object names, with a quality dot beside the value. For
what the colours, dots and letters mean see
[Reading values and colours](#quality-legend).

Groups show the communication state of the device assigned to that
group. In administration mode, objects can also be dragged between
groups.

The toggle at the left side of each object or group controls whether the
object is included in the current view. Double-clicking an object opens
its graph. Double-clicking a group opens a table for all objects in that
group.

## Reading values and colours {#quality-legend}

The same marks are used in the object tree, tables, the Inspector and the
event journal.

<dl>

<dt>Grey value text</dt>
<dd>The value is bad. Normal text colour means the value is good.</dd>

<dt>A "?" after the value</dt>
<dd>The value is bad, for example <code>41 °C?</code>. It does not mark a lost
connection or a stale value — for those, see the letters in square
brackets.</dd>

<dt>Letters in square brackets before the value</dt>
<dd>Quality flags, shown with their Russian letters: <code>[Р]</code> manual
input, <code>[Б]</code> blocked, <code>[2]</code> backup channel,
<code>[С]</code> no connection, <code>[Н]</code> connection failure,
<code>[К]</code> configuration error, <code>[У]</code> stale, <code>[В]</code> limit
violation. The full list is in
<a href="{{ '/en/architecture/' | relative_url }}#quality-flags">Quality flags</a>.</dd>

<dt>The "Quality" column in a table</dt>
<dd>The value's quality in words (the Russian client shows the Russian
labels):
<ul>
<li>"Good" («Достоверно», green) — the value is good;</li>
<li>"Uncertain" («Неопределённо», amber) — the value is stale, the
<code>[У]</code> flag; the row's cell text is amber too;</li>
<li>"Bad" («Недостоверно», red) — the bad flag, or no connection
<code>[С]</code>, a connection failure <code>[Н]</code> or a configuration
error <code>[К]</code>; the row's cell text is red too;</li>
<li>"No data" («Нет данных») — no value has arrived yet.</li>
</ul>
Unlike the "?", this column does take a lost connection and staleness into
account, so check the object here before a control command.</dd>

<dt>The dot beside a value in the object tree</dt>
<dd>Green — the value is good; red — bad; <b>blinking yellow</b> — the object
has an unacknowledged event (the row's background blinks yellow with it).
There is no separate dot colour for "uncertain" quality — the table's
"Quality" column shows it. No dot is drawn until a
value has arrived, and groups have none — a group shows its device's
connection state instead.</dd>

<dt>The quality label in the Inspector</dt>
<dd>"Good" or "Bad" beside the current value. "Bad" is shown for a value
carrying the bad flag, and also with a lost device connection ([С]), a
connection failure ([Н]), a configuration error ([К]) or a stale value
([У]).</dd>

<dt>Row colour in the journal and the event panel</dt>
<dd>The event's severity: a red fill is "Critical" (800 and above), a yellow
fill "Warning" (600–799), and other rows have no fill. Acknowledging does not
change the row colour; an unacknowledged event is marked with "●" in the first
column. See <a href="{{ '/en/client/events/' | relative_url }}#severity">Severity</a>.</dd>

</dl>

Yellow means different things in different places: in the object tree it is an
unacknowledged event on the object, in the journal it is the "Warning"
severity, in a table it is the "Uncertain" quality.

## Equipment panel

The equipment panel is available from `More -> Hardware`.

It shows the device hierarchy and communication-state indicators for
each device, including disabled channels, enabled channels, and
non-responding devices.

The equipment panel is also the entry point to:

* [Device watch]({{ '/en/client/device-watch/' | relative_url }}) for
  protocol traffic
* [Device metrics]({{ '/en/client/device-metrics/' | relative_url }})
  for service information
* the IEC 61850 data model view for connected IEC 61850 devices

When communication with an IEC 61850 device is established, its data
model appears as a `Model` subtree under the device node. See
[Protocols]({{ '/en/protocols/' | relative_url }}#iec-61850) and
[Development]({{ '/en/development/' | relative_url }}) for the
engineering details behind this view.

## Event panel {#events-panel}

The live event panel ("Current Events") shows the Server's current
unacknowledged events and the client's own messages. Events below the
[severity threshold]({{ '/en/client/alarms/' | relative_url }}#threshold) are
not shown in it.
Operators can acknowledge an event by double-clicking it or with *Acknowledge*
in the context menu. Several events can be acknowledged together by selecting
them with `Shift` (a range) or `Ctrl` (single rows). There is no keyboard
shortcut for acknowledgement.

*Acknowledge All* in the context menu acknowledges only the events the panel
shows: events hidden by the severity threshold, the area or the object list
stay unacknowledged. A collapsed group of repeated alarms is acknowledged
whole. When nothing shown is waiting, the command is unavailable.

With *Show Events on Arrival* on, the panel opens by itself when a new
unacknowledged event arrives, and *Hide Events on Acknowledge* closes it again
once the last one is acknowledged. Both are on the *Settings → Settings… →
Events & alarms* screen; they, the alarm tone and the severity threshold are
covered on the
[alarm annunciation page]({{ '/en/client/alarms/' | relative_url }}).

The event-row context menu exposes commands for the event itself and, if
the event is linked to an object or device, the corresponding object or
device commands as well.

## Files panel

The files panel provides access to Modus schematic files stored on the
Server:

![]({{ '/img/files.png' | relative_url }})

Files can be organized into folders. The context menu supports creating
folders, uploading files, deleting entries, and renaming files or
folders through the `Properties` command.

## Main views

The main operator-facing views:

* [Graph]({{ '/en/client/graph/' | relative_url }})
* [Table]({{ '/en/client/table/' | relative_url }})
* [Summary]({{ '/en/client/summary/' | relative_url }})
* [Data]({{ '/en/client/data/' | relative_url }})
* [Event journal]({{ '/en/client/events/' | relative_url }})
* [Display]({{ '/en/client/display/' | relative_url }})
* [User table]({{ '/en/client/sheet/' | relative_url }})
* [Device watch]({{ '/en/client/device-watch/' | relative_url }})
* [Device metrics]({{ '/en/client/device-metrics/' | relative_url }})
* [Debugger]({{ '/en/client/debugger/' | relative_url }})
* [Portfolios]({{ '/en/client/portfolio/' | relative_url }})
* [Export and import]({{ '/en/client/export/' | relative_url }})
* [Printing]({{ '/en/client/print/' | relative_url }})
* [Reports and analysis]({{ '/en/client/reports/' | relative_url }})

## Related views

See the dedicated pages for:

* [Summary]({{ '/en/client/summary/' | relative_url }})
* [Data]({{ '/en/client/data/' | relative_url }})
* [Device metrics]({{ '/en/client/device-metrics/' | relative_url }})
* [Event journal]({{ '/en/client/events/' | relative_url }})
* [Device watch]({{ '/en/client/device-watch/' | relative_url }})
* [Debugger]({{ '/en/client/debugger/' | relative_url }})
