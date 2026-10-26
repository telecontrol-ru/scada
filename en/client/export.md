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

The client first asks for the file. It proposes the folder of the last
export, and the file name defaults to the window title (with colons replaced
by hyphens). It then shows a dialog for CSV format parameters:

<dl>

<dt>Encoding</dt>
<dd>

* System, used by default
* Unicode (UTF-8)

On Windows, *System* is the Windows code page (Windows-1251 on Russian
Windows). That is the encoding Microsoft Excel assumes for a file without a
byte-order mark, so such a file opens in Excel by double-clicking it.
Characters the code page does not have are written as `?`. On macOS the
system encoding is UTF-8, and the file is written as with *Unicode (UTF-8)*.

*Unicode (UTF-8)* is UTF-8 with a byte-order mark (BOM), from which Excel
recognises the encoding. Choose it when the data holds characters the system
encoding does not have, or when the file will be opened on a computer with a
different Windows language.

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

With either encoding the file opens in Microsoft Excel by double-clicking
it, and non-Latin text such as Russian names reads correctly. Excel then takes
the column delimiter from the Windows regional settings rather than from the
file: if a row's values all land in one column, export again with the
delimiter Windows uses (a semicolon `;` for Russian settings), or open the
file with *Data — From Text/CSV* in Excel and set *Delimiter* to the one
chosen at export.

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

From the [Table]({{ '/en/client/table/' | relative_url }}) window the file
gets only the visible columns, in their on-screen order. Hidden columns — the
`Source` column with formulas and object identifiers, for example — are not
exported. The same applies to export to Excel.

In a summary, the first column, holding the interval start time, is headed
"Time (interval start)" («Время (начало интервала)»).

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
