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

## Element parameters

The `Element parameters` command is opened from the context menu for a
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

## ActiveXeme schematics

Display files with the `sde` and `xsde` extensions are stored in
`%ProgramData%\Telecontrol\SCADA Client` on each client workstation.

After a new display is added, it becomes available from the `Display`
main menu after the Client is restarted. The schematic folder can also
be opened from the Client with `Settings -> Open schematic folder`.

If a display file or object alias is changed, it is enough to close and
reopen the display in the Client.

### Binding objects

To bind a discrete or measured object to a display, define an alias for
the object in its parameter window.

After the alias is defined, bind it to a display element. Discrete
objects are usually bound to elements with a position property, while
measured objects are commonly bound to text fields.

In the Modus graphical editor, select the display element and set the
alias as the value of the `binding_key` property in the element property
editor (`F11`).

For an arbitrary property binding, use an expression such as
`property_name=alias`.

![]({{ '/img/modus-f11-bus.png' | relative_url }})

To bind several properties, separate them with `;`, for example:
`property_name1=alias1;property_name2=alias2`

![]({{ '/img/modus-f11-breaker.png' | relative_url }})

### Display title

The display title shown in the
[Display]({{ '/en/client/display/' | relative_url }}) menu is stored in
the `sde` and `xsde` files. It can be edited in the Modus graphical
editor through `Display -> Page properties -> About file...` by setting
the `Title` attribute:

![]({{ '/img/modus-scheme.png' | relative_url }})

The Client `Displays` menu then shows the text defined in that title
attribute:

![]({{ '/img/menu-scheme.png' | relative_url }})

## Translation status

This English page is a functional translation of the current Russian
page.
