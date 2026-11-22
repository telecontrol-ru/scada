---
title: Table
nav_order: 5
parent: Client
permalink: /en/client/table/
---

# Table
{:.no_toc}

* TOC
{:toc}

The `Table` window displays current object values in a grid. Each row
represents one object, and the columns show the current value together
with related information:

* `Name` — the object name;
* `Value` — the current value;
* `Quality` — the value's quality mark;
* `Trend` — a mini-graph of the object's recent values;
* `Source Timestamp` — the time the value refers to at its source (for
  example, a timestamp sent by the device), not when it was received;
* `Server Timestamp` — when the Server received the value;
* `Change Time` — when the value last changed;
* `Event` — the most recent unacknowledged system event for the object;
* `Source` — what the row is bound to: an object identifier or a formula.

Right-clicking any column header opens the list of columns: clear a check box
to hide that column, and set it to bring the column back. The last visible
column cannot be hidden. The set of visible columns is saved with the window.

The [printout]({{ '/en/client/print/' | relative_url }}#contents) and the
[export]({{ '/en/client/export/' | relative_url }}#contents) contain only the
visible columns, in their on-screen order; hidden columns are neither printed
nor exported.

Selecting a row activates object-specific commands in the **Item** menu.
Right-clicking opens a context menu for the selected object and row.
Multiple rows can be selected with `Shift` and `Ctrl`.

Rows can be added from the object panel by enabling objects, or by
typing an object alias directly into the last row of the table. In
addition to aliases, formulas can be used instead of direct object
references (see [Formulas](#formulas)).

The `Delete` key removes the selected row from the table. Rows can also be
removed from the object panel: unchecking an object there removes every row
of the table that names it. Double-clicking an object row opens that object's
graph.

If there are unacknowledged events for an object, the value cell starts
blinking. In that state, double-clicking the row acknowledges all of the
object's events. The `Event` («Событие») column shows the most recent
unacknowledged system event for the object; when there are several, their
count is shown first, in square brackets. Hovering the mouse over the «Имя» (Name)
cell of a row with events shows, after a short delay, the first three events in a tooltip. All
of the object's events can be seen in the event journal: select the row and
choose the *Events* («События») command.

**An account with neither the `Operator` nor the `ConfigureAdmin` role
cannot acknowledge events** (see
[Access rights]({{ '/en/dev/users/' | relative_url }}#access-rights)):
acknowledgement needs the *Control* or *Configure* right. Since Client 2.6.8
the acknowledge commands are unavailable to such a user, with the reason
"Acknowledging requires the Control or Configure privilege", and
double-clicking a blinking row opens the graph like any other row. In Clients
2.6.0–2.6.4 the command looked available, the Server rejected it, and a
double-click on a blinking row did not open the graph.

Rows can be reordered with `Ctrl+Up` and `Ctrl+Down`, or with the
context-menu commands.

The window carries a [toolbar]({{ '/en/client/workbench/' | relative_url }}#table-toolbar)
above the grid with these same commands, a "Quality" column, and monospace
rendering of values and timestamps.

## Context menu

The row context menu includes the following commands. Commands that do not
apply to the current selection (for example *Delete Row* or *Move Up* with no
row selected) are greyed out:

<dl>

<dt>Rename (F2)</dt>
<dd>Lets the user edit the formula or object reference for the selected
row.</dd>

<dt>Move Up / Move Down</dt>
<dd>Changes the row order inside the table.</dd>

<dt>Delete Row</dt>
<dd>Removes the selected rows from the table.</dd>

<dt>Sort</dt>
<dd>Provides name-based and channel-based sorting options.</dd>

</dl>

The same menu then lists the commands for the selected object, such as
[Graph]({{ '/en/client/graph/' | relative_url }}),
[Table]({{ '/en/client/table/' | relative_url }}),
[Display]({{ '/en/client/display/' | relative_url }}),
[Data]({{ '/en/client/data/' | relative_url }}),
[Summary]({{ '/en/client/summary/' | relative_url }}) and
[Event journal]({{ '/en/client/events/' | relative_url }}).

## Formulas {#formulas}

Instead of selecting an object from the object panel, a formula can be
entered in the first column. Formulas allow computed values based on one
or more objects. They support object references by alias, arithmetic
operators, and built-in functions.

See the syntax reference in [Formulas]({{ '/en/formulas/' | relative_url }}).

## Sorting {#sort}

Two sort modes are available from the `Sort` submenu:

<dl>

<dt>Name</dt>
<dd>Sort rows alphabetically, using a natural number order so names like
`Object 2` appear before `Object 10`.</dd>

<dt>Channel</dt>
<dd>Sort rows first by object type and then by input-channel number to
group values by device channels.</dd>

</dl>

The active sort mode is marked in the menu.
