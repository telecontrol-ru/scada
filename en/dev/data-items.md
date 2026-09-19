---
title: Data items
nav_order: 3
parent: Development
permalink: /en/dev/data-items/
---

# Data-item configuration
{:.no_toc}

* TOC
{:toc}

Only system administrators and SCADA engineers can create, configure,
delete, copy, or move data items and groups.

Each [data item]({{ '/en/architecture/' | relative_url }}#data-items)
can use up to two data sources for hot standby. If the primary source
loses validity, the system switches to the backup source automatically
and switches back when the primary source recovers.

Each data item can also define one control channel. The control channel
may even be the same exchange channel used as the source of the item's
data.

## Control conditions

A control channel can include a logical control condition. When the
condition is true, control is enabled:

![]({{ '/img/ti-remote-control-enabled.png' | relative_url }})

Otherwise, control is blocked:

![]({{ '/img/ti-remote-control-disabled.png' | relative_url }})

## Transformations and formulas

Incoming values can be:

* inverted for discrete objects
* transformed by a linear scale for measured values
* calculated using a [formula]({{ '/en/formulas/' | relative_url }})

Object configuration is edited through either `Parameters` for a single
object or `Element parameters` for an object group.

![]({{ '/img/menu-parameters.png' | relative_url }})

## Creating objects

Objects can be created only inside an object group, and groups can be
nested inside other groups.

Single objects or object series are created through the `Create` menu:

![]({{ '/img/menu-create-object.png' | relative_url }})

### Bulk create

The `Multiple Create…` command opens a wizard that creates a whole set of
objects from one pattern. It has three steps.

<dl>

<dt>Target and type</dt>
<dd>"What to create" — data items, or transmission rules (the latter is offered
only when there is something for a rule to forward, that is when source objects
are already selected). For data items it also asks for the "Item type"
(discrete or analog), the "Device" that is their source, and a "Source path
template".</dd>

<dt>Pattern: naming and addressing</dt>
<dd>A "Name template" and a "NodeId template" with index tokens:
<code>{n}</code> is the index in decimal, <code>{nn}</code> zero-padded to two
digits, <code>{hex}</code> in hexadecimal. Any other text is copied verbatim,
so "TS{n} current" at index 8 yields "TS8 current". The range comes from
"Start index", "Count" and "Index step", and for transmission rules from "IOA
start" and "IOA step" as well: a data item is not addressed on a link, so it
has no IOA fields.

A live preview is built below — a Name / NodeId / IOA / Status grid. Status
marks each row "new", "exists" (such a node is already there) or "address out
of range", and a "N new, M conflict" summary sits under the grid.</dd>

<dt>Review and create</dt>
<dd>States how many rows will be created out of the total: "Will create N of
M". Conflicting rows are not counted, so running the wizard again over the same
pattern completes the set rather than duplicating it.</dd>

</dl>

Once created, the objects' parameters can be edited in the usual way.

The wizard replaced an earlier bulk-create dialog with "Name prefix", "Starting
number", "Count", "Address prefix" and "Starting address" fields — it does the
same thing, but from a pattern, and it shows the result before creating it:

![]({{ '/img/menu-create-object-ts-ti.png' | relative_url }})

### Service objects

Service objects can also be created for a specific device:

![]({{ '/img/menu-create-object-service.png' | relative_url }})

## Deleting, copying, and moving objects

Objects and groups can be deleted through the `Delete` menu:

![]({{ '/img/menu-delete-object.png' | relative_url }})

Copying is available through the `Copy` commands:

![]({{ '/img/menu-copy-object.png' | relative_url }})

Objects and groups can also be dragged inside the object tree.

## Object parameters

Measured-object parameters are configured in the object properties
window:

![]({{ '/img/ti-parameters.png' | relative_url }})

The main parameter groups are:

<dl>

<dt>Value archive</dt>
<dd>Defines the historical retention depth in days and selects the
archive where object values are stored for later analysis in graphs,
summaries, and the event journal.</dd>

<dt>Name</dt>
<dd>The display name used everywhere in the system. Names do not have to
be unique; full object identification is based on the full path through
the parent groups.</dd>

<dt>Control channel</dt>
<dd>The channel address used for a control command in the protocol
format required by the selected device.</dd>

<dt>Control device</dt>
<dd>Selects the device used as the control-data source for remote
commands.</dd>

<dt>Two-stage control</dt>
<dd>Enables the IEC 60870 two-stage control workflow
`SELECT/EXECUTE`. If disabled, the command is executed in a single
stage.</dd>

<dt>Channel</dt>
<dd>Defines either the information-object address in the selected
protocol format or a calculated [formula]({{ '/en/formulas/' | relative_url }})
when no device is selected.</dd>

<dt>Device</dt>
<dd>Selects the primary source device. If no device is selected, the
channel field is interpreted as a formula.</dd>

<dt>Backup channel</dt>
<dd>Defines the information channel or service object for the backup data
source.</dd>

<dt>Backup device</dt>
<dd>Selects the backup source device.</dd>

<dt>Control condition</dt>
<dd>A logical expression that enables or blocks control. It usually
references discrete-object aliases or their internal object numbers.</dd>

<dt>Stale timeout, s</dt>
<dd>If the value is not updated within this interval, it is marked as
stale.</dd>

<dt>Display parameters</dt>
<dd>For discrete objects, selects the display format used in the UI.
The available formats can be managed from `More -> Formats`.</dd>

<dt>Inversion</dt>
<dd>Used only for discrete objects to invert the received state.</dd>

<dt>Transformation</dt>
<dd>For measured values, defines how incoming data is processed:
  <dl>
  <dt>Linear</dt>
  <dd>Applies offset and scale transformation.</dd>
  <dt>None</dt>
  <dd>Disables transformation.</dd>
  </dl>
</dd>

<dt>Logical minimum and maximum</dt>
<dd>Define the logical value range and the Y-axis range used by
graphs.</dd>

<dt>Physical minimum and maximum</dt>
<dd>Define the physical value range used in linear scaling.</dd>

<dt>Alias</dt>
<dd>A unique system-wide alias used in formulas, logical expressions,
tables, graphs, and schematic bindings. Aliases may contain Cyrillic or
Latin letters and digits, but no spaces, and must be no longer than 50
characters.</dd>

<dt>Importance</dt>
<dd>A decimal value from `0` to `1,000,000,000` used for event coloring
and filtering in the event journal and current-event panel.</dd>

<dd>Acknowledged events are typically shown with these severity zones:</dd>

* importance `< 60`: black text on white background
* importance `< 80`: black text on yellow background
* importance `> 80`: black text on red background

<dd>Unacknowledged events are shown with black text on a green
background until acknowledgement.</dd>

<dt>Range limiting</dt>
<dd>Clamps the value to the logical range.</dd>

<dt>Display</dt>
<dd>Controls how a measured value is formatted:
  <dl>
  <dt>Engineering units</dt>
  <dd>The unit suffix shown after the value.</dd>
  <dt>Format</dt>
  <dd>The number of decimal places.</dd>
  </dl>
</dd>

<dt>Emulation</dt>
<dd>Enables signal emulation. The emulation type is selected from the
configured list of simulated signals under `More -> Simulated
signals`.</dd>

</dl>

## Translation status

This English page is now a substantially fuller engineering reference.
The Russian page still remains the fullest low-level source.
