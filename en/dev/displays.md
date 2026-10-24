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

{: .warning }
> **In this version the built-in module shows a display without live
> values.** The display opens and is drawn as it was made in the graphical
> editor, but its elements are not connected to SCADA objects: switching
> device positions and measured values on it are not updated, and binding
> through the `ключ_привязки` property (see [below](#binding)) has no effect.
> To follow the current state, use the Client's tables, summaries and object
> tree.

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

{: .warning }
> In this version the binding described in this section is not shown on the
> display in the Client (see the warning above). It can be done in advance to
> prepare a display for a later version; object aliases are also used in
> [formulas]({{ '/en/formulas/' | relative_url }}).

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

For an arbitrary property binding, use an expression such as
`property_name=alias`.

![]({{ '/img/modus-f11-bus.png' | relative_url }})

To bind several properties, separate them with `;`, for example:
`property_name1=alias1;property_name2=alias2`

![]({{ '/img/modus-f11-breaker.png' | relative_url }})

### Display name in the menu

The Client's `Display` main menu lists each display by **its file name
without the extension**: the file `Substation 1.sde` appears in the menu as
"Substation 1". Give display files names the operator will recognise.

The Modus graphical editor can also store a title in the `sde` or `xsde`
file, through `Display -> Page properties -> About file...`, in the
`Заголовок` ("title") attribute:

![]({{ '/img/modus-scheme.png' | relative_url }})

In this version the Client does not use the `Заголовок` attribute in the menu.

An example of the menu (captured from an earlier Client version, where the
menu was called «Схема»):

![]({{ '/img/menu-scheme.png' | relative_url }})
