---
title: Event journal
nav_order: 3
parent: Client
permalink: /en/client/events/
---

# Event journal
{:.no_toc}

* TOC
{:toc}

Events are shown in two windows:

* **The event panel** — the current alarms: unacknowledged events and
  acknowledged alarms that still stand (see [Alarm states](#alarm-states)).
* **The event journal** — every event in the chosen [period](#period),
  acknowledged ones included, with who acknowledged them and when.

## Event panel

Opened with `More -> Events`, it docks at the bottom of the main window under
the title "Current Events". By default the panel opens by itself when an event
arrives and hides once every event is acknowledged, even if acknowledged
alarms that still stand remain in it — controlled by the
*Show Events on Arrival* and *Hide Events on Acknowledge*
[settings]({{ '/en/client/workbench/' | relative_url }}#settings).

![Event panel]({{ '/img/events.png' | relative_url }})

*The event panel with unacknowledged events*

The *Severity* group of the panel's context menu sets the
[severity threshold]({{ '/en/client/alarms/' | relative_url }}#threshold):
*All* shows every event, *Custom...* only those at or above the severity you
enter. The threshold is remembered and stays in force until you choose *All*.

The threshold acts on this panel only: events below it are in the context
strip's tiles, sound the tone and the spoken announcement, and are acknowledged by
*More → Acknowledge All* in the main menu. The panel's own *Acknowledge All*
acknowledges only the events it shows. See
[Severity threshold]({{ '/en/client/alarms/' | relative_url }}#threshold).

## Alarm states {#alarm-states}

Since Client 2.6.11 the event panel tells an alarm's state apart from its
acknowledgement. A [limit]({{ '/en/architecture/' | relative_url }}#limits)
alarm takes one row in the panel: a return to normal adds no new row but
changes the state of the existing one, and the row shows the time and message
of the latest change. The *State* column spells the state out:

| State | What it means | How the row looks |
|---|---|---|
| "Active, unacknowledged" | The value is outside the limit and nobody has acknowledged the alarm | Severity fill, "●" mark |
| "Active, acknowledged" | The alarm is acknowledged, but the value is still outside the limit | No fill, text in the severity colour |
| "Returned to normal, unacknowledged" | The value returned to normal before anyone acknowledged the alarm | No fill, "●" mark |
| "Event, unacknowledged" | An event with no alarm state, such as a manual input or a client message | Severity fill, "●" mark |

A row leaves the panel once the alarm is both acknowledged and back to normal.
So an acknowledged alarm that still stands stays in the panel, and an alarm
that returned to normal before it was acknowledged stays until it is
acknowledged. An event with no alarm state leaves the panel as soon as it is
acknowledged. Acknowledging a row acknowledges every change of that alarm.

The Server reports an alarm state for limit alarms only; every other event is
shown as "Event". A 2.5.7 Server reports no alarm states, and all its events
are shown as "Event". Alarms from a third-party OPC UA server are taken as
standing until acknowledged and leave the panel once acknowledged.

The severity tiles in the context strip count the alarms that stand, and the
"Unacknowledged" tile the unacknowledged ones, those back to normal included;
see [What is always visible]({{ '/en/client/alarms/' | relative_url }}#always-visible).

## Event journal

Opened with `More -> Event Journal`; each use opens a new window. By default
the journal shows the current day's events; the window title names the period
("Event Journal for Day", "… for Week", "… for Month"), with "(Filter)"
appended when a filter is set.

A journal can also be opened for chosen objects: select them and choose
*Events* in the *Open* group of the context menu. That journal shows only
their events. The active-alarm table on the
[Overview]({{ '/en/client/workbench/' | relative_url }}#overview) page is an
event journal opened with [*Unacknowledged Only*](#filters) already set.

New events appear in the journal at once; past events are loaded from the
Server when the window opens and whenever the period changes.

![Event journal]({{ '/img/events-alarm-surface.png' | relative_url }})

*The event journal for a day: unacknowledged events carry a dot in the first column, and the foot shows a summary and the Acknowledge All button.*

## Acknowledgement

Acknowledging confirms the operator has seen an event. Ways to do it:

* *Acknowledge* in the context menu — acknowledges the selected rows.
* *Acknowledge All* — in the context menu and as a button below the journal —
  acknowledges every event the journal shows.
* The *Acknowledge* button on an event card in the inspector.
* With an object selected (in the object tree, on a display), the acknowledge
  command acknowledges all of that object's unacknowledged events.

Since Client 2.6.11 a **double-click** on a row of the journal or the event
panel acknowledges nothing: it brings the inspector forward with that event's
card, so that the operator reads the event first and then acknowledges it
with the card's *Acknowledge* button or the context-menu command. In earlier
Clients a double-click acknowledged the selected events.

*Acknowledge All* acknowledges only the events shown in this window: the
area, severity, object and unacknowledged-only filters apply to it, and events
they hide stay unacknowledged. A collapsed group of repeated alarms is
acknowledged whole, every repeat included.

When more than one unacknowledged event is shown, *Acknowledge All* asks
first: "Acknowledge the N events shown in this journal? Events hidden by its
filters stay unacknowledged." («Квитировать события, показанные в журнале
(N)? События, скрытые фильтрами, останутся неквитированными.»), where N counts
the events, the repeats in collapsed groups included. "No" is the default
button, so *Enter* answers "No". An event that arrives while the question is
open stays unacknowledged. A single event is acknowledged at once, without a
question.

There is no keyboard shortcut for acknowledgement.

When a command is unavailable its tooltip says why: "Select an event to
acknowledge", "The selected events are already acknowledged", or "No event
shown here is waiting to be acknowledged", and since Client 2.6.8, for a user
without the right to acknowledge, "Acknowledging requires the Control or
Configure privilege" (such a user can still acknowledge the client's own
messages).

If the Server refuses an acknowledgement — for example because the user lacks
the right to acknowledge — the event stays unacknowledged and the event panel
shows a Client message, "Event acknowledgement" («Квитирование событий»), with
the reason, for example "Not enough rights to perform the operation". The
acknowledgement can be retried.

Acknowledging a Server event applies **system-wide**: the event becomes
acknowledged for every Client. The journal's *Acknowledged By* and *Acknowledge
Time* columns keep the user and time; an unacknowledged event shows
"— pending —" there.

The client's own messages ("Local Event") are acknowledged **on this
workstation only**: they are not sent to the Server, other workstations do not
have them, and they are not kept across a restart of the client. Since Client
2.6.8 unacknowledged client messages are kept across a sign-out with
*Disconnect from Server*: the next operator, whichever account they sign in
with, sees them in the event panel and the journal, and they still raise the
alarm; only acknowledging removes one. In Clients 2.6.0–2.6.4 they were lost at
every sign-out.

When more than ten events are unacknowledged, repeats of the same message from
the same source collapse into one row marked "×N". Acknowledging that row
acknowledges every event collapsed into it.

## Period {#period}

The period is set in the filter bar above the journal (*Period*: *15 min*,
*Hour*, *Day*, *Week*, *Month*) or from **Item → Period** in the main menu
while the journal window is active, which adds *Custom...* — a dialog with an
exact start and end date and time.

* *Day* starts at midnight, *Week* on Monday, *Month* on the 1st.
* *15 min* and *Hour* start at the beginning of the current 15-minute interval
  or hour — not "the last 15 minutes" or "the last hour".

The chosen period is kept with the window.

## Filters {#filters}

* **Min. severity** — show only events at or above a severity (0 to 1000;
  0 means *All*). The context menu's *Severity -> Custom...* sets the same.
* **Unacknowledged Only** — hide acknowledged events.
* **The area list** on the left — *All areas* and the top-level object
  groups, each with its count of unacknowledged events. Choosing a group keeps
  the events of that group and everything inside it.
* **Objects** — a journal opened for selected objects shows only their events.
* **Search messages** — the *Search…* box at the right of the filter bar
  (Client 2.6.11 and later). It keeps the events whose message contains the text you typed,
  ignoring upper and lower case. The journal is filtered once you stop typing,
  or at once when you press Enter; clear the box to see every event again.

There is no filter by event type. The period, the search text, the object list
and the column layout are kept with the window; the minimum severity and
*Unacknowledged Only* are not.

## Statistics {#statistics}

The **Statistics…** button at the right of the filter bar (Client 2.6.11 and
later) opens *Event Statistics* — how many events the journal shows:

![Event Statistics]({{ '/img/event-statistics.png' | relative_url }})

* by severity — *Critical*, *Warning*, *Routine* and *Total*;
* by object — the objects with the most events first.

Beside each count is how many of those events are unacknowledged. The counts
are of what the journal shows now, with every filter applied: set the
[period](#period), severity, area or search text before you open the window.
Repeats of one alarm that the journal folds into one row are each counted.
The window is a snapshot taken when it opens: events that arrive later are not
in it.

**Copy** puts both tables on the clipboard with tabs between the columns —
paste them into Excel and every number lands in a cell of its own. The audit
log has no *Statistics…* button.

## Columns

| Column | Contents |
|---|---|
| ● | Marks an unacknowledged event |
| Time | Date and time of the event, with milliseconds |
| Item | The object or device the event came from; "Local Event" for the Client's own messages |
| Message | The event text |
| Severity | The number and its range name: "Critical 800", "Warning 600" |
| State | The alarm state in words: "Active, unacknowledged", "Returned to normal", "Event, acknowledged" and so on |
| Value | The object's value at the time of the event |
| User | The user whose action caused the event |
| Acknowledged By | The user who acknowledged the event |
| Acknowledge Time | When it was acknowledged |

Events are sorted by time, newest first, by default. The event panel has no
*Acknowledged By* and *Acknowledge Time* columns.

## Severity {#severity}

Severity is a number from 1 to 1000. Rows of severity 800 and above are red
("Critical"), 600 to 799 yellow ("Warning"), and the rest are in the ordinary
colour. Only a row that is waiting to be acknowledged and still active is
filled; once acknowledged, and in archive records, the severity colour stays
on the row's text. The summary line below the
journal shows the number of unacknowledged events and the highest severity
among them.

For the other colours and marks — the quality dots in the object tree, grey
text for bad values, the quality letters — see
[Reading values and colours]({{ '/en/client/' | relative_url }}#quality-legend).

An object's event severity is set in its properties — see
[Data objects]({{ '/en/dev/data-items/' | relative_url }}).

## Kinds of events

* **State changes** of discrete (TS) objects.
* **Limit violations** and returns to normal (see
  [Limit checks]({{ '/en/architecture/' | relative_url }}#limits)).
* **Manual input** and **unblocking**.
* **Switching to the backup or primary** data source — "Switched to backup
  source", "Switched to primary source". Server 2.6 raises these
  events; a 2.5.7 Server raises none. The event takes the object's severity:
  a switch on a critical object is a critical event, with the tone and an
  acknowledgement. When a channel fails, every object it feeds raises its own
  event, and more than ten make an
  [alarm flood]({{ '/en/client/alarms/' | relative_url }}#escalation). If something else
  changed at the same moment, the texts are joined with "; ", for example
  "State change; Switched to backup source". No event is raised if the backup
  source's value is bad.
* **Control commands** — the preparation, the command and its result (see
  [Command result]({{ '/en/client/' | relative_url }}#control-result)).
* **Client messages** ("Local Event") — for example about the connection to
  the Server and the results of operations.

Sign-ins, failed ones included, and changes to accounts, passwords and roles
go only to the audit log, which administrators open — see
[Operator workbench]({{ '/en/client/workbench/' | relative_url }}#audit-log).
They do not appear in the event journal, the events panel or the Overview
page's active-alarm table. Records of control commands stay in the event
journal.

## Export and printing

The journal can be exported to CSV or Excel (Excel on Windows only) and
printed — see [Export]({{ '/en/client/export/' | relative_url }})
and [Printing]({{ '/en/client/print/' | relative_url }}). Exports contain the
events themselves: collapsed repeats are expanded by default (the *Expand
grouped rows* option of the CSV export dialog; an Excel export always expands
them), and the "●" mark is left out. A printout shows one row per event.
