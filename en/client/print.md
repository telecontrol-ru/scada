---
title: Printing
nav_order: 14
parent: Client
permalink: /en/client/print/
---

# Printing
{:.no_toc}

* TOC
{:toc}

The contents of the [Table]({{ '/en/client/table/' | relative_url }}),
[Summary]({{ '/en/client/summary/' | relative_url }}),
[Data]({{ '/en/client/data/' | relative_url }}),
[Event journal]({{ '/en/client/events/' | relative_url }}) and
[Device watch]({{ '/en/client/device-watch/' | relative_url }}) windows can
be printed with print preview. Graphs, displays and user tables cannot be
printed.

## Start printing

To print the contents of the active window, choose `Print`
from the context menu.

## Print preview

Before printing, the client shows a preview window that allows the user
to:

* inspect the print layout
* configure printer settings
* choose the page orientation

## What the printout contains {#contents}

The printout contains:

* a header: the window title; for a window with a period, "Period: <start> –
  <end>"; for a summary, the aggregation function and interval ("Maximum,
  1 hour", for example); "Printed: <time>";
* the column headers, on the first row of the table;
* the data rows; for a summary, the start time of each interval on the left;
* a page number at the bottom of each sheet.

The event journal is printed **one row per event**, even where the window
folds repeats into one row. The *Expand grouped rows* option of the
[CSV export]({{ '/en/client/export/' | relative_url }}) dialog does not
affect printing.

From the [Table]({{ '/en/client/table/' | relative_url }}) window the
printout gets only the visible columns, in their on-screen order. Hidden
columns — the `Source` column with formulas and object identifiers, for
example — are not printed.

The table continues onto further pages by rows. It is **not** split by
width: every column is squeezed to the page width, so a wide table (a summary
of many objects, for example) prints in narrow columns with wrapped text.
Choose landscape orientation in the print preview, or export the data to
CSV ([Export and import]({{ '/en/client/export/' | relative_url }})).

The printout holds what the window shows when you give the command. Print a
summary once it has finished loading — see
[Summary: printing and export]({{ '/en/client/summary/' | relative_url }}#print-export).
