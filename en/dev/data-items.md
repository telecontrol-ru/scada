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

Only accounts holding the Configure right (see
[Users]({{ '/en/dev/users/' | relative_url }})) can create, configure,
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
condition is true, control is enabled in the Client's Control window (see the
Control condition property below for details and limitations):

![]({{ '/img/ti-remote-control-enabled.png' | relative_url }})

Otherwise, control is blocked:

![]({{ '/img/ti-remote-control-disabled.png' | relative_url }})

## Transformations and formulas

Incoming values can be:

* inverted for discrete objects
* transformed by a linear scale for measured values
* calculated using a [formula]({{ '/en/formulas/' | relative_url }})

Object configuration is edited through either `Properties` for a single
object or `Element Properties` for an object group.

![]({{ '/img/menu-parameters.png' | relative_url }})

## Creating objects

Objects can be created only inside an object group, and groups can be
nested inside other groups. The first group is created at the root of the
object tree, All objects («Все объекты»): select it and choose
`Create -> Group`. Objects are created in the selected group with
`Create -> Status signal object` and `Create -> Analogue measurement object`
(Russian UI: «Объект ТС», «Объект ТИТ»).

Single objects or object series are created through the `Create` menu:

![]({{ '/img/menu-create-object.png' | relative_url }})

### Bulk create {#bulk-create}

The `Multiple Create…` command opens a wizard that creates a whole set of
objects from one pattern. It has three steps.

<dl>

<dt>Target and type</dt>
<dd>"What to create" — data items. In this version the list has no
"Transmission rules" entry: the wizard opened by <code>Multiple Create…</code>
is given no source objects, and a rule forwards an existing object.
Transmission rules are created by ticking objects in the object tree — see
<a href="{{ '/en/dev/devices/' | relative_url }}#retransmission">Retransmission to a dispatch centre</a>.
For data items it also asks for the "Item type"
(discrete or analog), the "Device" that is their source, and a "Source path
template": the channel address on that device, with the same index tokens as
the name template (see below). Each object gets that address in its Channel
field, exactly as if the device and channel had been chosen in its properties
by hand. For an IEC 60870-5 device it is the information object address (for
example <code>1{nn}</code>); for MODBUS it is a MODBUS channel address (for
example <code>HOLDREG:INT16:{n}</code>). With no device selected, or an empty
template, the objects are created without a source.</dd>

<dt>Pattern: naming and addressing</dt>
<dd>The "Name template", "NodeId template" and "Source path template" take
index tokens:
<code>{n}</code> is the index in decimal, <code>{nn}</code> zero-padded to two
digits, <code>{hex}</code> in hexadecimal. Any other text is copied verbatim,
so "TS{n} current" at index 8 yields "TS8 current". The range comes from
"Start index", "Count" and "Index step". Data items have no "IOA start" and
"IOA step" fields: those belong to transmission rules, which the wizard does
not create in this version.

The "NodeId template" sets the new objects' identifiers in OPC UA form. The
Server accepts only numeric identifiers in the object type's namespace:
<code>ns=1;i=…</code> for TS and <code>ns=2;i=…</code> for TIT. The value the
wizard proposes (<code>ns=2;s=RTU.TS{n}.I</code>) is a string identifier, and
the Server will not create such objects. <strong>The simplest is to clear the
field:</strong> the Server then assigns free numbers itself, as it does for an
ordinary create.

A live preview is built below — a row-number / Name / NodeId / IOA / Status
grid. Status
marks each row "new", "exists" (such a node is already there) or "address out
of range", and a "N new, M conflict" summary sits under the grid.</dd>

<dt>Review and create</dt>
<dd>States how many rows will be created out of the total: "Will create N of
M". Conflicting rows are not counted, so running the wizard again over the same
NodeId pattern completes the set rather than duplicating it. With an empty
NodeId template existing objects are not recognised, and running it again
creates them a second time.</dd>

</dl>

Example: create five TIT objects "Feeder current 1" … "Feeder current 5"
reading addresses 101–105 of an IEC 60870-5 device:

| Field | Value |
|---|---|
| What to create | Data items |
| Item type | Analog (TIT) |
| Device | the IEC 60870 device |
| Source path template | `1{nn}` |
| Name template | `Feeder current {n}` |
| NodeId template | empty |
| Start index | 1 |
| Count | 5 |
| Index step | 1 |

For index 1 the template `1{nn}` gives `101`, for index 5 it gives `105`.

The Pattern step, with its live preview:

![]({{ '/img/bulk-create.png' | relative_url }})

Once created, the objects' parameters can be edited in the usual way.

### Service objects

Service objects can also be created for a specific device:

![]({{ '/img/menu-create-object-service.png' | relative_url }})

## Deleting, copying, and moving objects

Objects and groups can be deleted through the `Delete` menu:

![]({{ '/img/menu-delete-object.png' | relative_url }})

Copying is available through the `Copy` commands:

![]({{ '/img/menu-copy-object.png' | relative_url }})

Objects and groups can also be dragged inside the object tree.

## Object properties

Measured-object properties are configured in the object Properties
window:

![]({{ '/img/ti-parameters.png' | relative_url }})

{: .note }
> In the Properties window the device and channel fields are grouped under
> three rows, and are labelled differently from the names used below:
>
> | Group in the window (Russian UI) | Field label in the window | Field in this manual |
> |---|---|---|
> | Primary input («Основной ввод») | Device | Device |
> | Primary input («Основной ввод») | Channel | Channel |
> | Backup input («Резервный ввод») | Device (backup) | Backup device |
> | Backup input («Резервный ввод») | Channel (backup) | Backup channel |
> | Output («Вывод») | Device (control) | Control device |
> | Output («Вывод») | Channel (control) | Control channel |
>
> In this version the Russian Client also shows these six field labels in
> English.

The main parameter groups are:

<dl>

<dt>Browse Name (Russian UI: «Обозначение»)</dt>
<dd>In the Attributes group: the identifier the Server assigned to the object
when it was created, for example <code>TIT.646</code>.
<a href="{{ '/en/formulas/' | relative_url }}">Formulas</a> and the Control
condition refer to the object by it.</dd>

<dt>Value archive</dt>
<dd>Selects the archive where object values are stored for later analysis
in graphs, summaries, and the event journal. The retention depth belongs to
the archive, not to the object. See
<a href="{{ '/en/dev/history/' | relative_url }}">Archiving</a>.
<strong>WARNING: in version 2.6 the Server refuses an archive assignment made
from the Client</strong> on an installation made with <code>scada-setup</code> as
separate processes; to assign archives to new objects, contact Telecontrol.
Details are on the <a href="{{ '/en/dev/history/' | relative_url }}">Archiving</a>
page.</dd>

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
<code>SELECT/EXECUTE</code>. If disabled, the command is executed in a single
stage. Default: Yes. The SELECT stage is sent only with the IEC 60870-5
command <code>C_SC_NA_1</code>; for other IEC 60870-5 commands and for MODBUS
devices it is skipped and only EXECUTE is performed. Set No if the device
does not support select-before-operate.</dd>

<dt>Lock</dt>
<dd>Yes — the object ignores values from the device and keeps the value set by
manual input (quality flag <code>B</code>). Default: No. See
<a href="{{ '/en/architecture/' | relative_url }}#manual-write">Manual input and blocking</a>.</dd>

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
references discrete-object aliases or their designations, such as
<code>TS.1379</code> (see <a href="{{ '/en/formulas/' | relative_url }}">Formulas</a>).
Do not start it with <code>=</code>. The condition is checked only by the Client's Control window: commands
arriving by retransmission from a dispatch centre or from external OPC UA
clients are not checked against it, so it does not replace an interlock on
the Server or in the device. Use a device-channel reference (for example
<code>{IEC_DEV.1!5}</code>) only as the whole expression: inside an expression such as
<code>{IEC_DEV.1!5} = 1</code> the Client does not find it, the condition is never
met and control stays blocked — refer to the TS object that receives the
channel's value instead.</dd>

<dt>Stale timeout, s</dt>
<dd>If the value is not updated within this interval, it is marked as
stale.</dd>

<dt>Display parameters</dt>
<dd>For discrete objects, selects the display format used in the UI.
The available formats can be managed from <code>More -&gt; Formats</code>.</dd>

<dt>Inversion</dt>
<dd>Used only for discrete objects to invert the received state.</dd>

<dt>Transformation</dt>
<dd>For measured values, defines how incoming data is processed. Default:
None. <strong>WARNING: in this version the list may offer no choices</strong>,
and then linear scaling cannot be switched on from the Client — see
<a href="{{ '/en/dev/devices/' | relative_url }}#enum-lists">Fields with a list
of values</a>.
  <dl>
  <dt>Linear</dt>
  <dd>Applies offset and scale transformation.</dd>
  <dt>None</dt>
  <dd>Disables transformation.</dd>
  </dl>
</dd>

<dt>Logical minimum and maximum</dt>
<dd>Define the logical value range and the Y-axis range used by
graphs. Defaults: minimum −100, maximum 100. Set the logical range of every
TIT object to its real scale; otherwise graphs show it on a −100…100
scale.</dd>

<dt>Physical minimum and maximum</dt>
<dd>Define the physical value range used in linear scaling. Defaults:
minimum 0, maximum 65535.</dd>

<dt>Alias</dt>
<dd>A unique system-wide alias used in formulas, logical expressions,
tables, graphs, and schematic bindings. Aliases may contain Cyrillic or
Latin letters and digits, but no spaces, and must be no longer than 50
characters. For a <a href="{{ '/en/formulas/' | relative_url }}">formula</a>
to reach an alias, it must start with a letter or <code>_</code>.</dd>

<dt>Severity (Russian UI: «Важность»)</dt>
<dd>A number from 1 to 1000, default 10. The object's events carry it, and it
colours and filters them in the event journal and the current-event
panel.</dd>

<dd>Event rows are coloured by severity:</dd>

* 800 and above: red background ("Critical", alarm)
* 600 to 799: yellow background ("Warning")
* below 600: not highlighted

<dd>An unacknowledged event is marked by a dot in the first column and by
"— pending —" in the acknowledge-time column; the row colour comes from the
severity alone. See <a href="{{ '/en/client/events/' | relative_url }}#severity">Severity</a>.</dd>

<dt>Range limiting</dt>
<dd>Clamps the value to the logical range.</dd>

<dt>Aperture</dt>
<dd>Filtering group, TIT only: the smallest change of value that is accepted;
smaller changes are ignored. In the object's units; 0 (default) means no
filtering.</dd>

<dt>Deadband</dt>
<dd>Filtering group, TIT only: values smaller in magnitude than this are
forced to zero. In the object's units; 0 (default) means unused.</dd>

<dt>Limits</dt>
<dd>Limits group, TIT only: low alarm, low warning, high warning and high alarm
limit. An empty value means the limit is not set. They can be changed here or
with the Limits command — see
<a href="{{ '/en/architecture/' | relative_url }}#limits">Limit checks</a>.
Changing a limit needs the Control right: without it the limits are read-only
in the properties, even with the Configure right.
<strong>WARNING: a limit event gets the object's Severity</strong> (10 by
default), and at that severity it is not highlighted. Give an object with
limits a Severity of 600 or higher for its limit events to show as warnings,
or 800 or higher to show as alarms.</dd>

<dt>Display</dt>
<dd>Controls how a measured value is formatted:
  <dl>
  <dt>Engineering units</dt>
  <dd>The unit suffix shown after the value.</dd>
  <dt>Format</dt>
  <dd>A number pattern the value is displayed with; the default is
  <code>0.####</code>. The number of characters after the point is the number
  of decimal places the value is rounded to. A <code>0</code> after the point
  is a required digit and is always shown; a <code>#</code> is optional, and
  trailing zeros in its place are dropped. The part before the point has no
  effect. Examples: <code>0.####</code> — up to four decimals (10.5 is shown
  with one decimal place, 10 with none); <code>0.00</code> — always two
  (10 is shown as 10.00); <code>0</code> — a whole number. The pattern always
  uses a point, whatever decimal separator the screen shows.</dd>
  </dl>
</dd>

<dt>Simulation</dt>
<dd>Simulation group. Yes — the object takes its values not from the device
but from the simulation signal chosen in the Simulation signal field. Default:
No. An object group has the same flag: when it is on for the group, every
object in it that has a signal chosen is simulated.</dd>

<dt>Simulation signal</dt>
<dd>Simulation group: the signal that feeds the object in simulation. Without
the Simulation flag on (on the object or its group) this choice has no
effect.

Signals are created in the Simulated signals window (<code>More -&gt; Simulated
signals</code>) with <code>Create -&gt; Simulation signal</code>. A signal has a Type — the
waveform (default: random; the list may offer no choices, see
<a href="{{ '/en/dev/devices/' | relative_url }}#enum-lists">Fields with a list of values</a>) —
Period, ms (60000), Phase, ms (0) and Update, ms (1000). See also
<a href="{{ '/en/client/workbench/' | relative_url }}#simulation-items">Simulated signals</a>.</dd>

</dl>
