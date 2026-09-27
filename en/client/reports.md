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
Everything described here is available with those rights.

Reports are built from the Server's archive: an object that has no value
archive assigned has no data for past periods. Archiving is set up by the
engineer — see [Archiving]({{ '/en/dev/history/' | relative_url }}).

## Choosing a period {#period}

The windows that show data over time — [Graph]({{ '/en/client/graph/' | relative_url }}),
[Summary]({{ '/en/client/summary/' | relative_url }}),
[Data]({{ '/en/client/data/' | relative_url }}) and the
[Event journal]({{ '/en/client/events/' | relative_url }}) — show the time
range set by the *Period* commands on the command bar: *15 min*, *Hour*,
*Day*, *Week*, *Month* and *Custom...*. The last one opens a dialog for exact
start and end times. Summary, Data and the Event journal keep the chosen
period with the window.

## A daily or monthly summary

The typical report is a table of several objects' values aggregated by
interval:

1. Open the object panel (`More -> Objects`) and select the objects or a
   group.
2. Choose *Summary*. A table opens with a column per object; objects are
   added and removed with the check boxes in the object panel.
3. Set the [period](#period), for example *Day* or *Month*.
4. Choose the aggregation interval (1 minute to 1 day) and the aggregation
   function (*Count*, *Start*, *End*, *Minimum*, *Maximum*, *Sum*,
   *Average*) — see [Summary]({{ '/en/client/summary/' | relative_url }}).
5. Save or print the result: *Export to Excel*, CSV export
   ([Export and import]({{ '/en/client/export/' | relative_url }})), or
   [printing]({{ '/en/client/print/' | relative_url }}) with a preview.

An empty cell means the archive holds no data for that interval.

## Analysing a graph

1. Double-click an object in the object panel to open its
   [Graph]({{ '/en/client/graph/' | relative_url }}).
2. Set the [period](#period).
3. Use cursors to read values at chosen moments, and limits to see
   excursions.
4. For aggregated values, switch to the summary with the *Summary* command on
   the command bar or in the object's context menu.

## A standing set of objects

If a report is built from the same objects every time, collect them in a
[portfolio]({{ '/en/client/portfolio/' | relative_url }}): a named list of
objects from which the summary and graphs are easy to open.

## Events over a period

In the [Event journal]({{ '/en/client/events/' | relative_url }}), set the
[period](#period) to see past events. The event list can be exported to CSV
and printed the same way as tables.
