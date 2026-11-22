---
title: Designer
nav_order: 6.5
parent: Development
permalink: /en/dev/designer/
---

# Designer — the Vidicon schematic editor
{:.no_toc}

* TOC
{:toc}

The Designer creates and edits Vidicon schematics — *vds* files — and stencil
libraries — *vdc* files. The Client shows a finished schematic in its
`Display` window; how schematic elements get the values of SCADA objects is
described in [Vidicon displays]({{ '/en/dev/displays/' | relative_url }}#vidicon).

The Designer also opens Modus schematics (*sde*, *xsde*), to convert them to
the Vidicon format. Such a schematic is saved only as *vds*; the original
Modus file is left unchanged. Check the schematic after converting it:
elements with no Vidicon counterpart may look different.

The Designer's interface language follows the system, or the choice in
*View — Language*; this page gives the English names.

## Installation {#install}

The Designer is part of the Windows Client package
`telecontrol-scada-<version>.msi`, which creates *Дизайнер* (Designer)
shortcuts on the desktop and in the *Start — ОИК Телеконтроль* menu.
**That package is not yet published for version 2.6** — see
[Getting started]({{ '/en/getting-started/' | relative_url }}).

## The Designer window {#window}

![The Designer window with the TEC-1 schematic]({{ '/img/designer-window-en.png' | relative_url }})

From top to bottom:

- **The menu** — File, Edit, View, Format, Shape, Tools, Window, Help.
- **One row of toolbars**: *Standard* (new, open, save, undo, redo, cut, copy,
  paste), *Arrange* (alignment, order and grouping, rotation and flipping) and
  *Format* (colours, lines, style and font). In a narrow window the last
  *Format* controls — font and text alignment — move into the `»` menu at its
  right end.
- **The Formula bar** — edits the formula of the chosen cell of the selected
  shape (see [Properties and formulas](#properties)).

On the left are the vertical *Tools* bar with the drawing tools, and the
*Stencils* and *Navigator* panels. On the right is the *Transform* panel with
*Properties* and *Custom Properties* below it. Panels stacked as tabs switch
by the tabs above them; any panel can be closed or reopened from the *View*
menu.

At the bottom is the **status bar**: the pointer's coordinates over the
schematic, the size of the selected shape (or the page size when nothing is
selected), the *Grid* and *Snap* toggles, and the zoom.

Each open schematic is a tab of its own. The tab strip appears when a second
schematic is opened; with one, its name is in the window title.

## Creating, opening and saving {#files}

![The Standard toolbar]({{ '/img/designer-toolbar-standard-en.png' | relative_url }}){: width="407"}

| Command | Shortcut |
|---|---|
| *File — New* | `Ctrl+N` |
| *File — Open...* (*vds*, *vdc*, *sde*, *xsde*) | `Ctrl+O` |
| *File — Save* | `Ctrl+S` |
| *File — Save As...* | — |
| *File — Recent Files* | — |
| *File — Print...* | `Ctrl+P` |

A schematic with unsaved changes is marked with an asterisk `*` on its tab
and in the window title. **If you close such a schematic** — its tab, the
Designer window or the whole program — the Designer asks whether to save the
changes: you can save them, discard them, or cancel the close.

Opening a file while an empty new *Untitled* schematic that you have not
changed is in front replaces it.

## Drawing {#drawing}

The drawing tools are on the *Tools* bar at the left edge of the window. One
tool is active at a time.

| Tool | What it does | Key |
|---|---|---|
| Select | Select and move shapes | `V` |
| Line | Line | `L` |
| Rect | Rectangle | `R` |
| Ellipse | Ellipse | `E` |
| Arc | Arc — a quarter of an ellipse | `A` |
| Text | Text box | `X` |
| Button | Button | `B` |
| Polyline | Polyline | `P` |
| Rotate Mode | Corner handles rotate the shape around its pin instead of resizing it | `Shift+R` |
| Connection Point | Points that line ends snap to | `Shift+C` |

- The arrow keys move the selection by one ruler division, with `Ctrl` by one
  grid step, with `Alt` by one screen pixel.
- Dragging with `Ctrl` held copies the selection; *Edit — Duplicate*
  (`Ctrl+D`) puts a copy next to the original.
- *Edit — Cut*, *Copy*, *Paste*, *Delete* and *Select All* (`Ctrl+A`) work as
  usual.

## Stencils {#stencils}

![The Stencils panel]({{ '/img/designer-stencils-en.png' | relative_url }}){: width="262"}

The *Stencils* panel shows the symbols of the current schematic (the
*Document* tab) and of the open stencil libraries. Drag a symbol onto the
schematic to place it. The *Search* field keeps the symbols whose name
contains what you type. The `☰` button next to it switches the panel from
icons to a list that shows each name in full.

- *File — Open Stencil...* (`Ctrl+Shift+O`) opens a *vdc* library.
- *File — Open Default Stencils* (`F3`) opens every library in the stencil
  folder set in *Tools — Options...*.
- *File — Synchronize Stencils...* updates the schematic's symbols from a
  reference library.
- *Shape — Create Master from Selection* asks for a name and makes a new
  symbol on the *Document* tab from the selected shapes.

## Formatting {#format}

![The Format toolbar]({{ '/img/designer-toolbar-format-en.png' | relative_url }}){: width="925"}

The *Format* bar is unavailable until something is selected. From left to
right:

- **Fill colour, line colour, text colour** — the strip under the icon shows
  the selection's current colour (chequered when the selected shapes differ);
- **line width, line pattern, arrow style** — clicking the button re-applies
  the value it shows, the arrow beside it opens the list;
- the document **style**, the **font** and the **size**;
- **bold, italic, underline**;
- **text alignment** — horizontal and vertical, one button with a list.

Detailed settings are in the *Format* menu: *Line...*, *Fill...*, *Text...*,
*Behavior...*, *Document...* (page size and colour), *Layers...* and
*Styles...*.

## Arranging {#arrange}

![The Arrange toolbar]({{ '/img/designer-toolbar-arrange-en.png' | relative_url }}){: width="147"}

The *Arrange* bar has three buttons with lists of the same commands as the
*Shape* menu:

| Button | Commands |
|---|---|
| Align | left, right, top or bottom edges, or centres — for two or more shapes |
| Order and group | Bring to Front (`Ctrl+Shift+]`), Send to Back (`Ctrl+Shift+[`), Group (`Ctrl+G`), Ungroup (`Ctrl+Shift+G`), Regroup |
| Rotate and flip | 90° right (`Ctrl+R`) and left (`Ctrl+L`), flip horizontal and vertical |

## Properties and formulas {#properties}

![The Properties panel with a shape selected]({{ '/img/designer-properties-en.png' | relative_url }}){: width="360"}

![The Transform panel]({{ '/img/designer-transform-en.png' | relative_url }}){: width="360"}

Every shape is described by a table of cells: section — row — cell (for
example *Object — XForm — PinX*). A cell holds a number or a formula.

- **The Properties panel** shows the cells of the selected shape, or of the
  document when nothing is selected. The *Filter* field keeps the rows whose
  name or value contains what you type. Colours are shown as a swatch and an
  `RGB(r,g,b)` value, Windows system colours by name. The `ƒx` button
  (`Ctrl+``) shows formulas instead of computed values. The *Bound values*
  section at the top lists every cell of the shape set by a formula. Copying
  a value and all properties is in the table's context menu.
- **The Formula bar**: select a shape, choose a cell in the list on the left
  (or click its row in the Properties panel), type a formula and accept it
  with the check-mark button or `Enter`; `Esc` or the cross button restores
  the previous formula. The `f(x)` button (`Ctrl+Space`) inserts a built-in
  function.
- **The Transform panel** sets the position, size, angle and resize behaviour
  of the selected shape; each change is undone in one step.
- **The Custom Properties panel** shows the shape's *Prop* section; its
  *Define...* button adds, removes and renames them.
- *Shape — Properties* (`Alt+Enter`) opens the Properties panel.

To make a schematic element show the value of a SCADA object, put the
object's address in its tag (section *Tag*, cell *Raw*) and read the tag's
value in the element's formulas — see
[Vidicon displays]({{ '/en/dev/displays/' | relative_url }}#vidicon).

**The Navigator** shows every shape of the schematic as a tree; a row is
named after the shape's name, its text or its master. Clicking a row selects
the shape on the schematic.

![The Navigator panel]({{ '/img/designer-navigator-en.png' | relative_url }}){: width="262"}

## Viewing the schematic {#view}

- **Scroll** — the mouse wheel or two fingers on a touchpad; with `Shift` the
  wheel scrolls sideways.
- **Zoom** — `Ctrl` + wheel or a touchpad pinch (zooming around the pointer),
  `Ctrl++` and `Ctrl+-`, *View — Zoom to Fit* (`Ctrl+0`), or the zoom field in
  the status bar, which also takes a typed value such as `150%`.
- **Pan** — drag with the space bar held.
- *View — Center Selection* (`Alt+C`) puts the selection in the middle of the
  window.

The *View* menu turns the grid, guides, connection points and rulers on and
off, and snapping to the grid, to guides and to ruler subdivisions. The grid
and grid snapping are also toggled by the *Grid* and *Snap* buttons in the
status bar. Add a guide by dragging it from a ruler onto the schematic, and
remove it by dragging it back. The grid and ruler spacing is set in
*Tools — Ruler & Grid...*.

## Keyboard shortcuts {#keys}

*Help — Keyboard Shortcuts* lists every menu command that has a shortcut. The
main ones:

| Keys | Action |
|---|---|
| `Ctrl+N` / `Ctrl+O` / `Ctrl+S` | New / open / save |
| `Ctrl+Z` / `Ctrl+Y` | Undo / redo |
| `Ctrl+X` / `Ctrl+C` / `Ctrl+V` | Cut / copy / paste |
| `Ctrl+A` / `Ctrl+D` / `Delete` | Select all / duplicate / delete |
| `Ctrl+G` / `Ctrl+Shift+G` | Group / ungroup |
| `Ctrl+R` / `Ctrl+L` | Rotate 90° right / left |
| `Alt+Enter` | Properties panel |
| `Ctrl++` / `Ctrl+-` / `Ctrl+0` | Zoom in / out / to fit |
| Space + drag | Pan the schematic |
| `Ctrl+F6` / `Ctrl+Shift+F6` / `Ctrl+F4` | Next / previous / close tab |
| `Esc` | Cancel the current action, leave text editing |
