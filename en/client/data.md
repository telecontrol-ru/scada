---
title: Data
nav_order: 5
parent: Client
permalink: /en/client/data/
---

# Data
{:.no_toc}

* TOC
{:toc}

The `Data` window displays the history of value changes for the selected
object as a table with the following columns:

| Column | Description |
|---|---|
| Source Timestamp | The value's time at its source, with millisecond precision |
| Value | Object value |
| Quality | Value quality flag |
| Server Timestamp | Time when the Server received the value |

Each row is one change of the value recorded in the archive. The window is
built from the Server's archive: an object without a value archive shows no
rows for past periods (see
[Reports and analysis]({{ '/en/client/reports/' | relative_url }}#archive)).

Clicking the first column header toggles the sort order by time between
ascending and descending.

## Period {#period}

The period is set with the *Period* commands on the command bar — see
[Choosing a period]({{ '/en/client/reports/' | relative_url }}#period). A new
window starts with *Day*. The period is saved with the window.

If you select two or more rows and choose *Graph* or *Summary*, that window
opens over the span from the first to the last selected row.

## Printing and export {#print-export}

The window can be [printed]({{ '/en/client/print/' | relative_url }}) and
[exported]({{ '/en/client/export/' | relative_url }}) to CSV with the *Print*
and *Export to CSV* commands. The printout and the file contain the rows in
the current sort order, but not the object name or the period — add them
yourself.
