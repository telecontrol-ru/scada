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

The `Display` window shows Modus schematics (`.sde` and `.xsde` files) stored
on the Server. The client draws them with its built-in display module; the
ActiveXeme component is neither needed nor used. The **Display** menu
lists the available schematics.

> **Caution.** In this version schematics open and display **without live
> values**: the built-in display module draws a schematic as its designer drew
> it and does not bind its shapes to objects. Colours, switch positions and
> numbers on the schematic do not change with the state of the equipment.
> Watch values and quality in tables, in the
> [object panel]({{ '/en/client/' | relative_url }}#object-panel) and in the
> [Inspector]({{ '/en/client/workbench/' | relative_url }}#inspector), and
> alarms in the [event panel]({{ '/en/client/' | relative_url }}#events-panel)
> and the status bar.

## Working with a schematic {#working}

Clicking a shape bound to an object selects that object: the
[Inspector]({{ '/en/client/workbench/' | relative_url }}#inspector) shows its
value and quality, and the object's commands are in the **Item** menu.
Double-clicking a shape acknowledges the selected object's unacknowledged
events. Clicking empty space on the schematic clears the selection.

> **Caution.** Clicking a shape that has **no** object behind it moves the
> selection frame to it, but the **previous** object stays selected.
> *Control…*, the **Item** menu, the Inspector and double-click
> acknowledgement then apply to that earlier object, not to the framed shape.
> Before *Control…* and before a double-click, always check the object's name
> in the Inspector (and, in the "Control" dialog, the object's name there). To
> start again, click empty space on the schematic — that clears the selection.

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
gives the reason. The operator cannot fix this — contact Telecontrol. Restart
the client once the module is in place.</dd>

<dt>"No display document is assigned to this window."</dt>
<dd>The window was saved without a schematic file. Close it and open the
schematic again from the <b>Display</b> menu.</dd>

<dt>"Cannot open document: …"</dt>
<dd>The schematic file is damaged or in an unsupported format; the reason
follows the colon. Report it to whoever designs the schematics.</dd>

</dl>
