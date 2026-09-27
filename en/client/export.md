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

Data from [tables]({{ '/en/client/table/' | relative_url }}),
[summaries]({{ '/en/client/summary/' | relative_url }}),
[event journals]({{ '/en/client/events/' | relative_url }}), and
[device watch]({{ '/en/client/device-watch/' | relative_url }}) windows
can be exported to a CSV file.

To export data, choose the `Export to CSV` command from the window's
context menu or from the `More` menu.

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

## Export to Excel

Tables and summaries also support direct export to Microsoft Excel.

## Configuration export and import

The Server's configuration is exported and imported with `More -> Export
Configuration...` and `Import Configuration...`, in the OPC UA NodeSet (XML)
format. See [Configuration export and import]({{ '/en/dev/excel/' | relative_url }}).
