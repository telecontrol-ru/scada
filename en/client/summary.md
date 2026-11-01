---
title: Summary
nav_order: 4
parent: Client
permalink: /en/client/summary/
---

# Summary
{:.no_toc}

* TOC
{:toc}

A summary is a table with one column per object and one row per time
interval; each cell holds the object's value over that interval, computed
by the chosen [aggregation function](#function). A summary is built from
the Server's archive (see
[Reports and analysis]({{ '/en/client/reports/' | relative_url }})).

For one object or multiple objects, the client can open a `Summary`
table:

![]({{ '/img/menu-summary.png' | relative_url }})

Columns can be added or removed through the object panel by toggling the
selected objects.

When the
[`Graph`]({{ '/en/client/graph/' | relative_url }}) or
[`Data`]({{ '/en/client/data/' | relative_url }}) command is launched
from the `Summary` context menu, the selected object and time interval
are reused.

While data is still being requested from the Server, cell values are shown
in grey text, which takes its normal colour as the data arrives. An empty
cell whose data is still loading looks the same as a cell with no change —
see [Printing and export](#print-export).

## Period {#period}

The period is set with the commands of the *Period* submenu in the **Item**
menu: *15 min*,
*Hour*, *Day*, *Week*, *Month* and *Custom...* — see
[Choosing a period]({{ '/en/client/reports/' | relative_url }}#period). A new
summary starts with the period *Day*, a 1-hour interval and the *Last*
function. The period, interval and function are saved with the window.

## Rows and empty cells {#rows}

Each row is labelled with the **start** of its interval, in the local time of
the computer running the Client. With a 1-hour interval, the row "10:00"
holds the values from 10:00 to 11:00.

An empty cell means that **the archive holds no recorded change of the value
in that interval**. That is not necessarily missing data: if the value did
not change during the whole interval, the archive holds nothing for it and
the cell stays empty — for the *Last* function too. The value in force at the
start of the interval is not carried over from the previous interval.

## Summary size {#limits}

A summary holds at most 10,000 rows.

If the period contains more than 10,000 intervals, the summary ends at row
10,000, and a notice above the table says so: "The summary is limited to
10000 rows and ends at <time>." («Сводка ограничена 10000 строками и
заканчивается в <время>.»); the printout repeats it in its header. For
example, *Month* with a 1-minute
interval stops about 6.9 days after the start of the month, and a custom
90-day period with a 5-minute interval about 34 days after its start. For a week or a month choose an
interval of 5 minutes or longer, and for anything longer than a month 1 hour
or longer; 1 hour or 1 day is usually enough for a report.

More than 1,000 columns can be added, but when a saved window is opened
again (for example after the Client restarts) only the first 1,000 are
restored and the rest are **silently** dropped.

## Aggregation interval {#interval}

The row length is chosen in the *Interval* submenu — in the summary's
context menu, or in the **Item** menu while the summary window is active:
the commands *1-Minute*, *5 min*, *15 min*, *30 min*, *1-Hour*, *12 hours*
and *1-Day*. Intervals are aligned to local
time: hourly intervals start on the hour, daily ones at midnight. If the
computer's time zone observes daylight saving time, in the summer months the
day boundary (and that of 12-hour intervals) is shifted by an hour from
midnight.

## Aggregation function {#function}

The function is chosen in the *Function* submenu — in the summary's context
menu or in the **Item** menu.

The Server (its archive process) computes the functions from the **changes
recorded in the archive** within the interval. **Invalid values are left
out**: a value flagged invalid, offline, stale or misconfigured is skipped.
When the interval holds no valid value, the cell stays empty (*Count* shows
0).

*First*, *Last*, *Count*, *Minimum*, *Maximum* and *Average* work on the
individual recorded points. *Time Average* and *Time Integral* take into
account how long each value was in force: a value holds from the moment it
was recorded until the next recorded change or the end of the interval.

<dl>

<dt>First</dt>
<dd>The first recorded value in the interval.</dd>

<dt>Last</dt>
<dd>The last recorded value in the interval. This is the default.</dd>

<dt>Count</dt>
<dd>The number of valid recorded changes in the interval.</dd>

<dt>Minimum</dt>
<dd>The smallest valid recorded value.</dd>

<dt>Maximum</dt>
<dd>The largest valid recorded value.</dd>

<dt>Average</dt>
<dd>The arithmetic mean of the valid recorded values, ignoring how long each
value was in force. For measurements archived only on change, choose
<i>Time Average</i>.</dd>

<dt>Time Average</dt>
<dd>The time-weighted mean: each value is weighted by how long it was in
force. If, within an hour, the value was 10 for 15 minutes and then 30 for 45
minutes, the time average is 25 while <i>Average</i> is 20.</dd>

<dt>Time Integral</dt>
<dd>The area under the value's curve over the interval — the value times how
long it held, in <b>seconds</b>. For power in kW that is kW·s: divide by 3600
to get energy in kWh. In the example above the integral is 10·900 + 30·2700 =
90,000. Earlier versions called this function <i>Sum</i> and added up the
recorded values; saved windows that used <i>Sum</i> now show the
integral.</dd>

</dl>

**The start of the interval before its first recorded change is not
counted.** The value in force when the interval began is not carried over
from the previous one, so if the value first changed at 10:20, the
10:00–11:00 interval starts at 10:20 for *Time Average* and *Time Integral*,
and the integral covers less than the full hour. An interval in which the
value never changed stays empty (see [Rows and empty cells](#rows)).

Cell values are shown in the object's display format and engineering units.
*Count* and *Time Integral* are plain numbers, without the object's units or
format: the integral's unit is the engineering unit times a second.

## Printing and export {#print-export}

A summary can be [printed]({{ '/en/client/print/' | relative_url }}) and
[exported]({{ '/en/client/export/' | relative_url }}) to CSV. The printout and
the file contain the table and the row labels. The printout opens with a
header: the window title, "Period: <start> – <end>", the aggregation
function and interval ("Maximum, 1-Hour", for example) and "Printed: <time>".
The CSV file does not include the period, the interval or the aggregation
function — note them in the file name.

In both the printout and the CSV file the interval-start column is headed
"Time (interval start)" («Время (начало интервала)»). The printout is not
split into pages by width: a summary
of many objects is squeezed to the width of one page, so its columns become
narrow and their text wraps. For a wide summary choose landscape orientation,
or export it to CSV.

**Wait for loading to finish before printing or exporting.** The printout or
file holds what the table shows when you give the command. A cell whose data
has not arrived yet goes in empty, and cannot be told apart from an interval
with no change. Print or export once no grey values are left and new values
have stopped appearing.
