---
title: Export and import
nav_order: 12
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
context menu or from the `Further` menu. The English docs keep the menu
name `Further` as a direct translation placeholder for the current
Russian UI documentation.

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

## Configuration export

The system configuration for groups, discrete signals, and measured
values can be exported to a CSV file for review, editing, and import
back into the system.

Use the `Further -> Export configuration` command. The default output
file is `configuration.csv`.

The exported data includes:

* object identifiers and names
* hierarchy, including parent objects
* object types
* all object-property values
* links between objects

Header format uses `PropertyName @NodeIdentifier`.

## Configuration import

To import configuration, choose `Further -> Import configuration` and
select a previously exported CSV file.

### Import process

1. The file is loaded and validated.
1. The imported configuration is compared with the current one.
1. A change report is shown with three categories:
   * **Create** for new objects not present in the current configuration
   * **Modify** for objects with changed properties, attributes, or links
   * **Delete** for objects missing from the imported file
1. The user confirms or rejects the changes.

Incorrect import usage can cause configuration loss, so the change
report should be reviewed carefully before confirmation.

See also [Editing configuration in MS Excel]({{ '/en/dev/excel/' | relative_url }}).

## Translation status

This English page is a functional translation of the current Russian
reference.
