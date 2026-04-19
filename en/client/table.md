---
title: Table
nav_order: 3
parent: Client
permalink: /en/client/table/
---

# Table
{:.no_toc}

* TOC
{:toc}

The `Table` window displays current object values in a grid. Each row
represents one object, and the columns show the current value together
with related information such as quality flags, the time of the last
value change, the time of the last device update, and recent system
events.

Selecting a row activates object-specific commands in the command bar.
Right-clicking opens a context menu for the selected object and row.
Multiple rows can be selected with `Shift` and `Ctrl`.

Rows can be added from the object panel by enabling objects, or by
typing an object alias directly into the last row of the table. In
addition to aliases, formulas can be used instead of direct object
references.

Deleting a selected row removes it from the table view. Double-clicking
an object row opens that object's graph.

If there are unacknowledged events for an object, the value cell starts
blinking. In that state, double-clicking the row acknowledges the
related events for the object. The rightmost column shows the most
recent unacknowledged system event, and a tooltip can preview the first
few events.

Rows can be reordered with `Ctrl+Up` and `Ctrl+Down`, or with the
context-menu commands.

## Context menu

The row context menu includes:

<dl>

<dt>Object commands</dt>
<dd>Commands for the selected object, such as
<a href="{{ '/en/client/graph/' | relative_url }}">Graph</a>,
<a href="{{ '/en/client/table/' | relative_url }}">Table</a>,
<a href="{{ '/en/client/display/' | relative_url }}">Display</a>,
<a href="{{ '/en/client/data/' | relative_url }}">Data</a>,
<a href="{{ '/en/client/summary/' | relative_url }}">Summary</a>, and
<a href="{{ '/en/client/events/' | relative_url }}">Event journal</a>.</dd>

<dt>Acknowledge all</dt>
<dd>Acknowledges all active events for table objects.</dd>

<dt>Rename (F2)</dt>
<dd>Lets the user edit the formula or object reference for the selected
row.</dd>

<dt>Move up / Move down</dt>
<dd>Changes the row order inside the table.</dd>

<dt>Delete</dt>
<dd>Removes the selected rows from the table.</dd>

<dt>Sort</dt>
<dd>Provides name-based and channel-based sorting options.</dd>

</dl>

## Formulas

Instead of selecting an object from the object panel, a formula can be
entered in the first column. Formulas allow computed values based on one
or more objects. They support object references by alias, arithmetic
operators, and built-in functions.

See the syntax reference in [Formulas]({{ '/en/formulas/' | relative_url }}).

## Sorting

Two sort modes are available from the `Sort` submenu:

<dl>

<dt>By name</dt>
<dd>Sort rows alphabetically, using a natural number order so names like
`Object 2` appear before `Object 10`.</dd>

<dt>By channels</dt>
<dd>Sort rows first by object type and then by input-channel number to
group values by device channels.</dd>

</dl>

The active sort mode is marked in the menu.

## Translation status

This English page is a functional translation of the main table
behavior. The Russian page still contains the more detailed
authoritative wording.
