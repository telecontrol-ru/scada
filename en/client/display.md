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
> 2.6, is not yet included in the Client packages: its licence terms are not
> settled yet, and it is supplied separately. Without it the
> client works, but instead of the schematic the window shows the message
> "No display runtime is installed." («Модуль отображения мнемосхем не
> установлен.») — in that case contact Telecontrol (see
> [When a schematic is not shown](#not-shown)).

## Live values on a Modus schematic {#live-values}

Shapes of a Modus schematic that the designer bound to SCADA objects (the
`ключ_привязки` property — see
[Binding objects]({{ '/en/dev/displays/' | relative_url }}#binding)) show
those objects' present state and update with it:

* **A switching device** (a shape with the *положение*, "position", property)
  is drawn closed or open from the value of its discrete (ТС) object: a
  non-zero value is closed, zero is open. A breaker square is filled with the
  colours the schematic's settings define for a closed and an open breaker;
  when the schematic defines none, bright green when closed and red when
  open. An **отделитель** (separator) is drawn with the same symbol as in the
  Modus graphics editor, but the whole symbol takes those same colours by
  position; the editor always draws it black.
* **A text field** (a shape with the *текст*, "text", property) shows the
  value of its measured (ТИТ) object the way a table does: with its units and
  with a "?" mark on an unreliable value.
* When a value is **unreliable** or the object is not connected, the
  switching device is hatched in the bad-quality colour: its position on the
  schematic is not confirmed at that moment. Until a value arrives, a device
  stays in the position its designer drew, and a text field keeps its drawn
  text.
* When the object has **unacknowledged events**, a frame in the critical
  alarm colour blinks around the shape until the events are acknowledged (by
  double-clicking the shape, see [Working with a schematic](#working), or in
  the event panel).

Shapes that are not bound are drawn as the designer drew them.

Some Modus shapes are drawn simplified or not drawn yet — for example, the
instruments and controls that the Modus graphics editor draws as pictures.
The list is under
[Known limitations]({{ '/en/changes/' | relative_url }}#limits-upgrade).

> **Caution.** Compared with the 2.5.7 Client, a Modus schematic does **not**
> show a binding of an arbitrary shape property (*property_name=alias* with a
> name other than *положение*, *текст* or *значение_базовое*) or the object's
> limits.

## Live values on a Vidicon schematic {#live-values-vidicon}

Shapes of a Vidicon schematic whose tags name an object's address show that
object's present value and update with it, the way their designer drew them:
a breaker changes colour, a disconnector moves its blade, a value field shows
the value with its units and with a "?" mark on an unreliable value.

If the value is **unreliable** or the object is not connected, the shape is
hatched in the bad-quality colour: its position on the schematic is not
confirmed at that moment. A value field is not hatched: an unreliable value
is marked in it with "?" after the value. When there is no value — the object
is not found, not connected, or has not reported a value yet — the field
shows "?" alone, not the text saved in the schematic.

Until a value arrives, and when an object's value disappears, the shape looks
as it was saved in the schematic; when the connection to the object is lost,
it is hatched as well.

When the object has unacknowledged events, a frame in the critical alarm
colour blinks around the shape until the events are acknowledged in the
event panel.

Fields whose formula uses the address's description or units functions show
the text saved in the schematic while the value is reliable; with an
unreliable value or no value they show "?".

The display module draws these quality marks. If a workstation has a display
module older than the Client, it may not draw them, and the Client's status
bar then shows the warning "Old display runtime: bad values may not be
marked". Install the display module of the same version as the Client.

## Working with a schematic {#working}

What a click does depends on the kind of schematic.

* **Modus schematics** (`.sde`, `.xsde`). A click on a shape bound to an
  object selects that object: the Inspector shows its value, and its commands
  are in the **Item** menu. When several objects are bound to one shape, the
  first is selected. A double-click acknowledges the selected object's
  events; when there are no unacknowledged events and the shape has a
  *гиперссылка* (hyperlink) property, a double-click opens the Modus
  schematic it names. The schematic is looked for relative to the folder of
  the open one and must be inside the workstation's schematics folder —
  copied there or delivered by the Server; a link leading outside that folder
  is not opened. Hyperlinks have not yet been tried on working sites'
  schematics in version 2.6. Bound shapes inside a Graphic Editor group have
  not been checked in version 2.6 — see
  [Binding objects]({{ '/en/dev/displays/' | relative_url }}#binding).
* **Vidicon schematics** (`.vds`) — opened from the same **Display** menu. A
  click on a shape bound to an object selects that object — its commands are
  in the **Item** menu — and adds it to the "Measurements" panel. A
  double-click does nothing: acknowledge events in the event panel. The
  shapes show live values on the schematic itself — see
  [Live values on a Vidicon schematic](#live-values-vidicon).

Clicking a shape that has no object behind it, or empty space on the
schematic, clears the selection: the **Item** menu commands, the Inspector and
acknowledgement then apply to no object — not to the one selected before
either.

## Open the display for a selected object {#goto-object}

When an object is selected in the object panel or in a table, the user
can open the display that contains that object with the `Display`
command in the object's context menu or in the **Item** menu. The command is
available when the client is connected to the Server.

When the command is executed, the system searches for a Modus schematic that
contains the selected object (when several do, one of them is opened).

If a matching display is already open, the existing window is activated.
Otherwise, a new display window is opened.

On the schematic, the shape bound to the object is selected — the same as
clicking it.

The client finds a schematic by the objects bound to its shapes, and it
learns them when the schematic is opened and remembers them on the
workstation. A schematic that has not yet been opened on this workstation may
not be found — open the schematics you need from the **Display** menu once.

If no display contains the selected object, the client shows "Display for item
"…" was not found." («Мнемосхема для сигнала «…» не найдена.»).

## When a schematic is not shown {#not-shown}

Instead of the schematic the window may show one of these messages:

<dl>

<dt>"No display runtime is installed."</dt>
<dd>The client's display module (on Windows, the file
<code>display_runtime.dll</code>; on macOS, <code>libdisplay_runtime.dylib</code>
inside the application) is missing next to the client executable, so
the client works but cannot draw schematics. The second line of the message
gives the reason. The module is a separate library which, in version 2.6,
is not yet included in the Client packages and is supplied separately. The
operator cannot fix
this — contact Telecontrol. Restart the client once the module is in
place.</dd>

<dt>"No display document is assigned to this window."</dt>
<dd>The window was saved without a schematic file. Close it and open the
schematic again from the <b>Display</b> menu.</dd>

<dt>"Cannot open document: …"</dt>
<dd>The schematic file is damaged or in an unsupported format; the reason
follows the colon. Report it to whoever designs the schematics.</dd>

</dl>
