---
title: Export and import
nav_order: 13
parent: Client
permalink: /en/client/export/
---

# Export and import
{:.no_toc}

* TOC
{:toc}

## Export to CSV

Data from the [Table]({{ '/en/client/table/' | relative_url }}),
[Summary]({{ '/en/client/summary/' | relative_url }}),
[Data]({{ '/en/client/data/' | relative_url }}),
[Event journal]({{ '/en/client/events/' | relative_url }}) and
[Device watch]({{ '/en/client/device-watch/' | relative_url }}) windows
can be exported to a CSV file. Graphs, displays and user tables cannot be
exported.

To export data, choose the `Export to CSV` command in the window's
context menu.

### Export options

The client first asks for the file. The file name defaults to the window
title (with colons replaced by hyphens). It then shows a dialog for CSV format parameters:

<dl>

<dt>Encoding</dt>
<dd>

* System, used by default
* Unicode (UTF-8)

**WARNING: in this version the encoding choice has no effect.** With either
choice the file is written in UTF-8 without a byte-order mark (BOM).

</dd>

<dt>Delimiter</dt>
<dd>

* Comma `,`, used by default
* Semicolon `;`
* Colon `:`
* Tab
* Space
* A custom character

</dd>

<dt>Quote character</dt>
<dd>

* Double quote `"`, used by default
* Single quote `'`
* A custom character

</dd>

<dt>Expand grouped rows</dt>
<dd>Shown only for windows that fold repeats into one row (the event
journal). When checked (the default), every folded event is written to the
file as its own row; when cleared, the rows are written as the window shows
them.</dd>
</dl>

The chosen format settings are stored in the user profile and reused by
later exports.

After export finishes, the client offers to open the file in the
associated application.

### Opening the file in Excel {#open-in-excel}

Do not open the file by double-clicking it: Microsoft Excel then reads it in
the Windows system code page, and non-Latin text such as Russian names turns
into unreadable characters. Instead, in Excel choose *Data — From Text/CSV*,
pick the file, and set *File Origin* to *65001: Unicode (UTF-8)* and
*Delimiter* to the one chosen at export.

In this version a text editor on Windows may show an empty line after each
row of the file.

### What the file contains {#contents}

The file holds **the cell text as shown in the window**, not numbers: values
in the object's display format, with engineering units and with a `?` after
invalid values; times as strings. Microsoft Excel may open such values as
text, and the decimal separator in the file may not match your Windows
settings. To calculate with them in Excel, remove the units and replace the
decimal separator if needed (*Find and Replace* or *Data - Text to
Columns*).

The window title, and a summary's period and aggregation function, are not
written to the file — put them in the file name.

**WARNING: from the [Table]({{ '/en/client/table/' | relative_url }}) window,
the file gets every column, hidden ones included.** The `Trend` column is
always empty in the file, and the `Source` column holds formulas and object
identifiers. Delete the columns you do not need in the file yourself. The
same applies to export to Excel.

In a summary, the first column, holding the interval start time, is headed
`Time`.

The file holds what the window shows when you give the command. Export a
summary once it has finished loading — see
[Summary: printing and export]({{ '/en/client/summary/' | relative_url }}#print-export).

## Export to Excel {#excel}

The `Export to Excel` command opens the window's data in a new Microsoft
Excel workbook. It is offered for the same windows as CSV export and writes
the same cell text, but works only when both of these hold:

* the Client runs on Windows and Microsoft Excel is installed;
* the Client was started with the `--excel` command-line option — for
  example, append it to the *Target* field in the Client shortcut's
  properties.

Without `--excel` the command is unavailable. If Excel is not installed, the
export ends with the message "Export failed. Please check that Microsoft
Excel is installed correctly."

## Configuration export and import

The Server's configuration is exported and imported with `More -> Export
Configuration...` and `Import Configuration...`, in the OPC UA NodeSet (XML)
format. See [Configuration export and import]({{ '/en/dev/excel/' | relative_url }}).
