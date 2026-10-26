---
title: Display
nav_order: 2
parent: Client
permalink: /en/client/display/
---

# Display
{:.no_toc}

* TOC
{:toc}

The `Display` window shows Modus schematics (`.sde` and `.xsde` files) and
Vidicon schematics (`.vds` files) stored on the Server. The client draws them with its own display module; the
ActiveXeme component is neither needed nor used. The **Display** menu
lists the available schematics.

> **Caution.** The display module is a separate library which, in version
> 2.6, may not yet be included in the Client installation. Without it the
> client works, but instead of the schematic the window shows the message
> "No display runtime is installed." («Модуль отображения мнемосхем не
> установлен.») — in that case contact Telecontrol (see
> [When a schematic is not shown](#not-shown)).

> **Caution.** In this version schematics open and display **without live
> values**: the display module draws a schematic as its designer drew
> it and does not show the objects' state on it. Colours, switch positions and
> numbers on the schematic do not change with the state of the equipment.
> Watch values and quality in tables and in the
> [object panel]({{ '/en/client/' | relative_url }}#object-panel), and
> alarms in the [event panel]({{ '/en/client/' | relative_url }}#events-panel)
> and the status bar.

## Working with a schematic {#working}

What a click does depends on the kind of schematic.

* **Modus schematics** (`.sde`, `.xsde`). In this version a click on a shape
  does **not** select an object you can work with: the schematic's shapes are
  not linked to objects. To issue a command, acknowledge an event or read a
  value, pick the object in the
  [object tree]({{ '/en/client/' | relative_url }}#object-panel) or a table.
* **Vidicon schematics** (`.vds`) — opened from the same **Display** menu. A
  click on a shape bound to an object selects that object — its commands are
  in the **Item** menu — and adds it to the "Measurements" panel. A
  double-click does nothing: acknowledge events in the event panel.

Clicking a shape that has no object behind it, or empty space on the
schematic, clears the selection: the **Item** menu commands, the Inspector and
acknowledgement then apply to no object — not to the one selected before
either.

## Open the display for a selected object

When an object is selected in the object panel or in a table, the user
can open the display that contains that object with the `Display`
command in the object's context menu or in the **Item** menu. The command is
available when the client is connected to the Server.

When the command is executed, the system searches for a Modus schematic that
contains the selected object (when several do, one of them is opened).

If a matching display is already open, the existing window is activated.
Otherwise, a new display window is opened.

The command only opens the schematic or brings it forward: the object's shape
is **not** selected or highlighted on it. Find the shape yourself and, before
running any command, click it and check the object's name in the Inspector.

If no display contains the selected object, the client shows "Display for item
"…" was not found." («Мнемосхема для сигнала «…» не найдена.»).

## When a schematic is not shown {#not-shown}

Instead of the schematic the window may show one of these messages:

<dl>

<dt>"No display runtime is installed."</dt>
<dd>The client's display module (on Windows, the file
<code>display_runtime.dll</code>) is missing next to the client executable, so
the client works but cannot draw schematics. The second line of the message
gives the reason. The module is a separate library which, in version 2.6,
may not yet be included in the Client installation. The operator cannot fix
this — contact Telecontrol. Restart the client once the module is in
place.</dd>

<dt>"No display document is assigned to this window."</dt>
<dd>The window was saved without a schematic file. Close it and open the
schematic again from the <b>Display</b> menu.</dd>

<dt>"Cannot open document: …"</dt>
<dd>The schematic file is damaged or in an unsupported format; the reason
follows the colon. Report it to whoever designs the schematics.</dd>

</dl>
