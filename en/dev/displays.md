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
`Properties` from the object's context menu.

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
`property_name=alias`. The 2.6 Client shows bindings of the *положение*,
*текст* and *значение_базовое* properties; a binding of any other property is
kept in the display but not shown in the Client.

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
