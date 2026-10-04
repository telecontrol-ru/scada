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
control equipment nor change the configuration (rights "0 — Executive /
viewer",
see [Roles and permissions]({{ '/en/architecture/' | relative_url }}#roles-and-permissions)).
Everything described here is available with those rights, except
acknowledging events, which needs the *Control* or *Configure* right. Also,
with rights "0" portfolios and other profile settings are not saved on the
Server.

## Where the data comes from {#archive}

Reports are built from the Server's archive, kept by the `scada-historian`
process. An object that has no value archive assigned has no data for past
periods — not in a summary, not on a graph, not in the Data window.
Archiving is set up by the engineer — see
[Archiving]({{ '/en/dev/history/' | relative_url }}).

**WARNING: in version 2.6 archiving cannot yet be set up from the Client.**
On an installation made with `scada-setup`:

* an archive cannot be assigned to an object from the Client — the Server
  rejects the change. Only objects that already have an archive assigned
  (for example, ones migrated from version 2.5) are archived;
* after the service of a protocol process (for example,
  *Telecontrol SCADA IEC 104*) is restarted, archiving of its objects' values
  stops until the *Telecontrol SCADA Historian* service is restarted as well.

If a report for a recent period is empty while the object is working, tell
the administrator: archiving may not have resumed after a service restart.

## Choosing a period {#period}

The windows that show data over time — [Graph]({{ '/en/client/graph/' | relative_url }}),
[Summary]({{ '/en/client/summary/' | relative_url }}),
[Data]({{ '/en/client/data/' | relative_url }}) and the
[Event journal]({{ '/en/client/events/' | relative_url }}) — show the time
range set by the *Period* commands on the command bar. In the summary, the
Data window and the event journal they mean:

| Command | Range |
|---|---|
| *15 min*, *Hour* | The current quarter-hour or hour, from its start until now |
| *Day* | From midnight **today** until now |
| *Week* | From Monday of the **current** week |
| *Month* | From the 1st of the **current** month — not the previous month |
| *Custom...* | The bounds set in the *Time Range* dialog |

Summary, Data and the Event journal keep the chosen period with the window.

### A report for last month {#last-month}

*Month* shows the current, unfinished month. To report on last month:

1. Choose *Custom...*.
2. In the *Time Range* dialog, clear the check box of the *Time* group — only
   dates are then set, and the last day is included in full.
3. In the *Date* group set *Start* to the 1st of last month and *End* to the
   last day of last month, and press *OK*.
4. In the summary choose the *1-Day* interval — one row per day.

Yesterday, or any other finished period, is set the same way.

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
4. Choose the aggregation interval (*1-Minute* to *1-Day*) and the
   aggregation function — see [Summary]({{ '/en/client/summary/' | relative_url }}).
   A summary holds at most 10,000 rows and **silently** stops at the last
   one: a month at a 1-minute interval ends around the 7th. Use an interval
   of at least 5 minutes for a month.
5. Save or print the result: CSV export
   ([Export and import]({{ '/en/client/export/' | relative_url }})) or
   [printing]({{ '/en/client/print/' | relative_url }}) with a preview. The
   period and the aggregation function are not included in the printout or
   the file — add them yourself. *Export to Excel* works only on Windows with
   Microsoft Excel installed, and only when the Client was started with the
   `--excel` option — see [Export to Excel]({{ '/en/client/export/' | relative_url }}#excel).

How each function is computed is described under
[Aggregation function]({{ '/en/client/summary/' | relative_url }}#function).
In short: *Sum* and *Average* are computed over recorded changes, not over
time, so they give neither energy nor a time-weighted average; invalid values
are included; *Maximum* over negative values currently shows about 0.

An empty cell means the archive holds no recorded change of the value in
that interval. That also happens when data exists but the value did not
change during the whole interval — see
[Rows and empty cells]({{ '/en/client/summary/' | relative_url }}#rows).

## Analysing a graph

1. Double-click an object in the object panel to open its
   [Graph]({{ '/en/client/graph/' | relative_url }}).
2. Set the [period](#period).
3. Use cursors to read values at chosen moments, and limits to see
   excursions.
4. For aggregated values, switch to the summary with the *Summary* command on
   the command bar or in the object's context menu.

A graph cannot be printed or exported. To keep the values, open the *Data*
or *Summary* window from the graph and print or export that. A graph shows at
most 10,000 points at a time: over a long period the time scale is narrowed
automatically.

## A standing set of objects

If a report is built from the same objects every time, collect them in a
[portfolio]({{ '/en/client/portfolio/' | relative_url }}): a named list of
objects. Select the portfolio and choose *Summary* to open a summary of all
its objects. Portfolios are personal: other users do not see them, and with
rights "0" they are kept on this computer only (see
[Where portfolios are kept]({{ '/en/client/portfolio/' | relative_url }}#storage)).

## Events over a period

In the [Event journal]({{ '/en/client/events/' | relative_url }}), set the
[period](#period) to see past events. The event list can be exported to CSV
and printed the same way as tables.

## What the Client does not have {#not-available}

So that you do not look for them, the Client has no

* report templates or scheduled reports — a summary is opened and set up by
  hand each time (the window keeps its period, interval and function);
* comparison of two periods in one summary or on one graph;
* printing or export of graphs;
* event statistics (event counts per period, object or severity);
* text search in event messages in the event journal.
