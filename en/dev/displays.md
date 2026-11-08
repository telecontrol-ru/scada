---
title: Displays
nav_order: 4
parent: Development
permalink: /en/dev/displays/
---

# Electronic schematics and element parameters
{:.no_toc}

* TOC
{:toc}

## Element properties

The `Element Properties` command is opened from the context menu for a
selected object group:

![]({{ '/img/menu-parameters-elements.png' | relative_url }})

The table-based editing mode simplifies work with many objects. Objects
appear in rows and their parameters appear in columns:

![]({{ '/img/menu-parameters-elements-copy.png' | relative_url }})

Cells can be filled by dragging the selection from the lower-right
corner, similarly to Microsoft Excel. If a cell value ends in a number,
the number is incremented or decremented automatically during the fill
operation. Hold `Ctrl` while dragging to disable the automatic number
change.

The table context menu also provides `Copy` and `Paste` operations for
objects.

## Modus schematics

Displays — files with the `sde` and `xsde` extensions — are **created and
edited in the Modus graphical editor**. The editor is not part of the SCADA
delivery: it is a separate Windows program supplied by its maker, MODUS
([swman.ru](http://swman.ru/)). The SCADA Client **shows** the displays
itself, with its built-in module; workstations do not need the ActiveXeme
component for that.

Elements bound to SCADA objects with the `ключ_привязки` property (see
[below](#binding)) show the present positions and values in the Client; what
exactly is shown is described in
[Live values on a Modus schematic]({{ '/en/client/display/' | relative_url }}#live-values).

A finished display can be placed in one of two ways:

* copy the file to the displays folder on every client workstation: on
  Windows `%ProgramData%\Telecontrol\SCADA Client`, on macOS
  `~/Library/Application Support/Telecontrol/SCADA Client` (in the user's home
  folder). The Client opens that folder with the main-menu command
  `Settings -> Open Displays Folder` (Russian UI: «Настройки — Открыть папку
  мнемосхем»), which is available while at least one window is open in the
  Client;
* upload the file once to the Server, which then serves it to every Client —
  see [Server files]({{ '/en/dev/server-files/' | relative_url }}).

A display added to a workstation's folder becomes available from the
`Display` main menu (Russian UI: «Мнемосхема») after the Client is restarted.

If a display file or object alias is changed, it is enough to close and
reopen the display in the Client.

### Binding objects {#binding}

To bind a discrete or measured object to a display, define an alias for
the object in its Properties window (the Alias field), opened with
`Properties` from the object's context menu. An alias may consist of Latin
and Cyrillic letters, digits and the underscore `_`, must start with a letter
or `_`, and must not contain spaces.

After the alias is defined, bind it to a display element. Discrete objects
are bound to elements that have the `положение` ("position") property, and
measured objects to text fields that have the `текст` ("text") property.
These are the editor's own Russian property names and are typed as shown.

In the Modus graphical editor, select the display element and set the
alias as the value of the `ключ_привязки` ("binding key") property in the
element property editor (`F11`).

The value of `ключ_привязки` can be a
[formula]({{ '/en/formulas/' | relative_url }}) over aliases as well as a
single alias — the same as in tables.

For an arbitrary property binding, use an expression such as
`property_name=alias`. Several bindings of one element are separated by `;`.

A `;` or `=` separates bindings, or a property from its formula, only
outside parentheses `( )`, quotes `" "` and a channel reference `{ }`. So
a formula may contain them: `!(TS.1 = TS.2)` and
`текст={MODBUS_DEVICES.1!INT16:40001;swapbytes}` are one binding each.

> **Caution.** When a single word of letters, digits and `_` stands before
> the first `=` outside parentheses, the Client takes it as the property
> name. So write a comparison of an alias without a dot in parentheses:
> `(TS_Q1 = 1)`, not `TS_Q1 = 1` — otherwise the property becomes `TS_Q1`.
> The 2.5.7 Client split the value at every `;` and at the first `=`
> anywhere, so formulas containing these characters work from version 2.6
> only.

Elements combined into a group in the Graphic Editor have not been checked
in the 2.6 Client. If a bound element inside a group shows no value or
cannot be selected with a click, ungroup it.

The 2.6 Client shows bindings of the *положение*,
*текст* and *значение_базовое* properties; a binding of any other property is
kept in the display but not shown in the Client.

A shape's *гиперссылка* (hyperlink) property names the schematic a
double-click on it opens in the Client (when the shape's object has no
unacknowledged events). Give the file name of a Modus schematic (`.sde` or
`.xsde`) relative to the folder holding the schematic itself, for example
`Seti320.sde` or `../Substations/T_1.sde`. The file must be inside the
workstation's schematics folder — copied there or delivered by the Server
(see above); the Client does not open a link leading outside that folder.
Hyperlinks have not yet been tried on working sites' schematics in version
2.6: check the jumps on your own site's schematics.

The Client draws a breaker's position with the fill colours that the
switching-device table in the schematic's settings defines for a closed and
an open breaker. When the table defines no colour, or a transparent one, the
breaker is filled bright green when closed and red when open. Each device
takes its colours from the rows of its own object type: a separator from the
separator's rows (closed and open), not the breaker's, and also falls back to
bright green and red; its symbol's lines take the position colour too. A
separator given a voltage class on the schematic is drawn in that voltage's
colour, as the Modus graphics editor draws it, and does not show its position
by colour; read such a separator's position in a table or the Inspector. The
separator's colouring needs the next build of the display module (see
[A display module from an earlier build]({{ '/en/client/display/' | relative_url }}#old-runtime)).

![]({{ '/img/modus-f11-bus.png' | relative_url }})

To bind several properties, separate them with `;`, for example:
`property_name1=alias1;property_name2=alias2`

![]({{ '/img/modus-f11-breaker.png' | relative_url }})

### Display name in the menu

The Client's `Display` main menu lists a display by its title. The title is
stored in the `sde` or `xsde` file in the Modus graphical editor, through
`Display -> Page properties -> About file...`, in the `Заголовок` ("title")
attribute:

![]({{ '/img/modus-scheme.png' | relative_url }})

The Client reads the title when the display is opened and remembers it on the
workstation. So a new display that has never been opened, and a display
without a title (or with «без имени», "untitled", which the editor sets by
default), is listed by **its file name without the extension**: the file
`Substation 1.sde` appears in the menu as "Substation 1". Give display files
names the operator will recognise in that case too.

An example of the menu (captured from an earlier Client version, where the
menu was called «Схема»):

![]({{ '/img/menu-scheme.png' | relative_url }})

## Vidicon displays {#vidicon}

The Client shows Vidicon displays — files with the *vds* extension — in the
same `Display` window. A shape takes an object's value through its tags: in
each tag (the shape's *Tag* section) the *Raw* field holds the object's
address, for example `{VIDICON.Share.1\Substation.TS.Breaker 1}`, and the
shape's formulas read the tag's value (`Tag.State`) — that is how a breaker
changes colour and a disconnector moves its blade. The Client subscribes to
each address the way it does to a formula in a table, and re-evaluates the
shape's formulas whenever the value changes. A value field whose formula is
`Tag.<tag name>` shows the value as a table does, with its units.

See [Live values on a Vidicon schematic]({{ '/en/client/display/' | relative_url }}#live-values-vidicon).
