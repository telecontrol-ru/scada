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

To export data, choose the `Export to CSV` command on the command bar or in
the window's context menu.

### Export options

During export, the client shows a dialog for CSV format parameters:

<dl>

<dt>Encoding</dt>
<dd>

* System encoding, used by default
* Unicode (`UTF-8`)

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

</dl>

The chosen format settings are stored in the user profile and reused by
later exports.

After export finishes, the client offers to open the file in the
associated application.

### What the file contains

The file holds **the cell text as shown in the window**, not numbers: values
in the object's display format, with engineering units and with a `?` after
invalid values; times as strings. Microsoft Excel may open such values as
text, and the decimal separator in the file may not match your Windows
settings. To calculate with them in Excel, remove the units and replace the
decimal separator if needed (*Find and Replace* or *Data - Text to
Columns*).

The window title, and a summary's period and aggregation function, are not
written to the file — put them in the file name.

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
