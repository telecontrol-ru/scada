---
title: Reports and analysis
nav_order: 15
parent: Client
permalink: /en/client/reports/
---

# Reports and analysis
{:.no_toc}

* TOC
{:toc}

This page is for users who watch the site and prepare reports but neither
control equipment nor change the configuration — an account with neither
the `Operator` nor the `ConfigureAdmin` role (see
[Access rights]({{ '/en/dev/users/' | relative_url }}#access-rights)).
Everything described here is available to such an account, except
acknowledging events, which needs the *Control* or *Configure* right.

The Server license is issued for a term: after it expires the Server
processes refuse requests, and reports stop working — see
[Licensing]({{ '/en/server/' | relative_url }}#licensing).

## Where the data comes from {#archive}

Reports are built from the Server's archive, kept by the `scada-historian`
process. An object that has no value archive assigned has no data for past
periods — not in a summary, not on a graph, not in the Data window.
Archiving is set up by the engineer — see
[Archiving]({{ '/en/dev/history/' | relative_url }}).

While the service of a protocol process (for example,
*Telecontrol SCADA IEC 104*) is stopped or restarting, its objects' values
are not archived; once the service starts, archiving resumes by itself.

If a report for a recent period is empty while the object is working, tell
the administrator: the object may have no archive assigned.

## Choosing a period {#period}

The windows that show data over time — [Graph]({{ '/en/client/graph/' | relative_url }}),
[Summary]({{ '/en/client/summary/' | relative_url }}),
[Data]({{ '/en/client/data/' | relative_url }}) and the
[Event journal]({{ '/en/client/events/' | relative_url }}) — show the time
range set by the commands of the *Period* submenu in the **Item** menu. In
the summary, the
Data window and the event journal they mean:

| Command | Range |
|---|---|
| *15 min*, *Hour* | The current quarter-hour or hour, from its start until now |
| *Day* | From midnight **today** until now |
| *Week* | From Monday of the **current** week |
| *Month* | From the 1st of the **current** month — not the previous month |
| *Custom...* | The bounds set in the *Time Range* dialog |

Summary, Data and the Event journal keep the chosen period with the window.

In the *Time Range* dialog *OK* is disabled while *Start* is not before
*End*. With times set, the start must be strictly before the end; with dates
only (the *Time* group's check box cleared), the start date may equal the end
date — the period then covers that whole day.

### A report for last month {#last-month}

*Month* shows the current, unfinished month. To report on last month:

1. Choose *Custom...*.
2. In the *Time Range* dialog, clear the check box of the *Time* group — only
   dates are then set, and the last day is included in full.
3. In the *Date* group set *Start* to the 1st of last month and *End* to the
   last day of last month, and press *OK*.
4. In the summary choose the *1-Day* interval — one row per day.

Yesterday, or any other finished period, is set the same way.

{: .note }
> In the version 2.5 Client, reopening the *Time Range* dialog with the
> *Time* box cleared shows an *End* date one day later than the one set, and
> pressing *OK* moves the end of the period a day later. If you work with the
> 2.5 Client, check *End* every time you reopen the dialog. Version 2.6 fixes
> this.

## A daily or monthly summary

The typical report is a table of several objects' values aggregated by
interval:

1. Open the object panel — the *Objects* mode on the
   [section rail]({{ '/en/client/workbench/' | relative_url }}#activity-bar)
   on the left (or `More -> Items`) — and select the objects or a group.
2. Choose *Summary*. A table opens with a column per object; objects are
   added and removed with the check boxes in the object panel.
3. Set the [period](#period), for example *Day*, or
   [last month](#last-month).
4. In the summary's context menu (or the **Item** menu), choose the
   aggregation interval in the *Interval* submenu (*1-Minute* to *1-Day*) and
   the aggregation function in the *Function* submenu — see [Summary]({{ '/en/client/summary/' | relative_url }}).
   A summary holds at most 10,000 rows. When the period needs more, the
   summary stops at row 10,000 and a notice above the table says so: "The
   summary is limited to 10000 rows and ends at <time>." («Сводка ограничена
   10000 строками и заканчивается в <время>.»); the printout repeats it in its
   header. A month at a 1-minute interval ends around the 7th. Use an interval
   of at least 5 minutes for a month, and of at least 1 hour for anything
   longer.
5. Wait for the data to load: values still loading are shown in grey text.
   An empty cell that is still loading looks the same as an interval with no
   change, and the printout or file holds whatever the screen shows when you
   give the command — so print or export once no grey values are left and
   new values have stopped appearing.
6. Save or print the result: CSV export
   ([Export and import]({{ '/en/client/export/' | relative_url }})) or
   [printing]({{ '/en/client/print/' | relative_url }}) with a preview. The
   printout opens with a header: the window title, the period, the
   aggregation function and interval ("Maximum, 1-Hour", for example) and the
   time it was printed. The CSV file does not include the period or the
   aggregation function — add them yourself.
   By default the CSV file separates columns with a comma `,`, while
   Microsoft Excel with Russian regional settings expects a semicolon: if
   the file will be opened in Excel, choose the delimiter `;` in the export
   dialog — see [Opening the file in Excel]({{ '/en/client/export/' | relative_url }}#open-in-excel).
   *Export to Excel* is offered only on Windows, on a computer with
   Microsoft Excel installed — see [Export to Excel]({{ '/en/client/export/' | relative_url }}#excel).

How each function is computed is described under
[Aggregation function]({{ '/en/client/summary/' | relative_url }}#function).
In short: invalid values are left out; *Average* is the arithmetic mean of
the recorded values, while *Time Average* and *Time Integral* take into
account how long each value held; the integral is in the engineering unit
times seconds (kW·s for power in kW).

An empty cell means the archive holds no recorded change of the value in
that interval. That also happens when data exists but the value did not
change during the whole interval — see
[Rows and empty cells]({{ '/en/client/summary/' | relative_url }}#rows).

## Analysing a graph

1. Double-click an object in the object panel to open its
   [Graph]({{ '/en/client/graph/' | relative_url }}). If the active window
   is already a graph, the double-click adds the object to that graph
   instead of opening a new one.
2. Set the [period](#period).
3. Use cursors to read values at chosen moments, and limits to see
   excursions.
4. For aggregated values, switch to the summary with the *Summary* command in
   the object's context menu. The minimum, maximum and average in the
   [graph legend]({{ '/en/client/graph/' | relative_url }}#legend) count
   valid values over the visible part of the graph, while the summary counts
   per interval, so for the same period they can differ.

A graph can be [printed or saved as an image]({{ '/en/client/graph/' | relative_url }}#print-export)
— as it is shown on screen. That does not keep its numbers: to keep the
values, open the *Data* or *Summary* window from the graph and print or
export that. From a graph these commands open a window for the **selected
line** only; to get a summary of all the graph's objects at once, build it
from the object panel — see
[A weekly report of several objects](#week-print). A graph shows at most
10,000 points at a time: over a long period the time scale is narrowed
automatically.

## A weekly report of several objects, printed {#week-print}

Several objects' curves over a week can be printed straight from the graph
— set the period and choose *Print* (see
[Graph printing and export]({{ '/en/client/graph/' | relative_url }}#print-export)).
When the report needs numbers, print a summary. For example, three objects
over 7 days:

1. Select all three objects in the object panel and choose *Summary* — one
   summary opens, with a column per object.
2. Set the period to *Custom...*: clear the check box of the *Time* group and
   in the *Date* group set *Start* to the first day and *End* to the seventh
   (see [A report for last month](#last-month)). *Week* does not do this: it
   shows the week from Monday until now.
3. In the *Interval* submenu choose *1-Hour* — 168 rows, one per hour — and
   the [function]({{ '/en/client/summary/' | relative_url }}#function) you
   need, for example *Time Average* or *Maximum*.
4. Wait until no grey values are left in the table, choose *Print*, and pick
   landscape orientation in the print preview.
5. Check the period, function and interval in the printout header: they
   are printed automatically.

## A standing set of objects

If a report is built from the same objects every time, collect them in a
[portfolio]({{ '/en/client/portfolio/' | relative_url }}) (*Portfolio* in
the Client's menus): a named set of objects. Select the portfolio and choose
*Summary* to open a summary of all its objects. Portfolios are personal:
other users do not see them. They are kept in the user profile on this
computer, and when the Client closes it also saves the profile on the Server,
from where it loads it at login on another computer (see
[Where portfolios are kept]({{ '/en/client/portfolio/' | relative_url }}#storage)).

## Events over a period

In the [Event journal]({{ '/en/client/events/' | relative_url }}), set the
[period](#period) to see past events. The event list can be exported to CSV
and printed the same way as tables; for export to Excel and what it needs, see
[Export to Excel]({{ '/en/client/export/' | relative_url }}#excel).

If the event archive cannot be read (for example, the archive process is
unavailable), the journal for the period stays empty **with no error
message**. An empty journal for a period in which there certainly were events
is a reason to tell the administrator, not proof that there were none.

## What the Client does not have {#not-available}

So that you do not look for them, the Client has no

* report templates or scheduled reports — a summary is opened and set up by
  hand each time (the window keeps its period, interval and function);
* comparison of two periods in one summary or on one graph;
* CSV export of a graph: a graph is printed and saved only as an image, and
  its values are kept from the *Data* and *Summary* windows;
* consumption of a cumulative counter per interval. Energy from a power
  measurement comes from *Time Integral* (in kW·s — divide by 3600 for kWh;
  see [Aggregation function]({{ '/en/client/summary/' | relative_url }}#function)).
  If the object is a cumulative counter, the consumption per interval is
  taken as the difference of the *Last* (or *First*) values of neighbouring
  rows. An empty cell then means that the counter did not change in that
  interval, not a zero reading: use the last non-empty value above it;
* event statistics (event counts per period, object or severity);
* text search in event messages in the event journal.
