---
title: User table
nav_order: 11
parent: Client
permalink: /en/client/sheet/
---

# User table
{:.no_toc}

* TOC
{:toc}

A user table is a spreadsheet-style window for monitoring and
displaying data in an arbitrary tabular layout. Columns are labeled with
letters (`A`, `B`, `C`, and so on), and rows are labeled with numbers
(`1`, `2`, `3`, and so on).

To create a user table, choose `Table -> New user table` from the main
menu.

## Formula bar

The top part of the window contains the formula bar. When a cell is
selected, its contents are shown there. To edit a cell, select it and
type text or a formula in the formula bar, or double-click the cell
directly.

Press `Enter` or `Tab` to confirm the input.

## Cells

Cells can contain:

* text values
* references to data objects through formulas, updated in real time
* mathematical expressions

When a cell is linked to a data object, its value updates automatically
when the server data changes.

## Edit mode

Cell editing is available only in edit mode, which is enabled by an
administrator. In edit mode, formatting commands become available from
the context menu.

## Formatting

For the selected cell range, the user can set:

* **background color**
* **alignment**: left, center, or right
* **conditional formatting** to change the cell appearance based on its
  value

## Table size

Rows and columns are inserted from the header context menu, the same way
they are in familiar spreadsheet editors:

* right-click a **row header** (the number on the left) for `Insert 1 row
  above` or `Insert 1 row below`;
* right-click a **column header** (the letter on top) for `Insert 1 column
  left` or `Insert 1 column right`.

An insertion shifts the existing cells and discards nothing: a cell's
contents and its formatting travel with it.

Below the last row there is an **+ Add row** bar that appends a row to the
end of the table.

Deleting rows and columns is not supported yet.

{: .note }
> Inserting rows and columns is available in the web interface. In the
> desktop Client, the size of a user table is set when the table is created.

## Cell blinking

Cells whose values have changed can blink to draw the operator's
attention.

## Translation status

This English page is a direct translation of the current Russian page.
