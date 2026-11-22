---
title: Drawing and editing
nav_order: 1
parent: Designer
grand_parent: Development
permalink: /en/dev/designer/drawing/
---

# Drawing and editing
{:.no_toc}

* TOC
{:toc}

## Tools {#tools}

The drawing tools are on the *Tools* bar at the left edge of the window. One
tool is active at a time.

| Tool | What it does | Key |
|---|---|---|
| Select | Select, move and resize | `V` |
| Line | Line | `L` |
| Rect | Rectangle | `R` |
| Ellipse | Ellipse | `E` |
| Arc | Arc — a quarter of an ellipse | `A` |
| Text | Text box | `X` |
| Button | Button | `B` |
| Polyline | Polyline | `P` |
| Rotate Mode | Corner handles rotate the shape instead of resizing it | `Shift+R` |
| Connection Point | Points that line ends snap to | `Shift+C` |

To draw a shape, pick a tool, drag out its box on the schematic and release;
*Select* is active again afterwards.

### Arc {#arc}

An arc is a quarter of an ellipse. Press where it starts and release where it
ends: the arc leaves the start point horizontally and meets the end point
vertically, and the drag box becomes its bounding box. Drag the other way to
bow it into the opposite corner. The arc is not filled; resizing stretches it
to the new box.

### Polyline {#polyline}

1. Click to place the first vertex.
2. Click to add each further vertex — a line follows the pointer.
3. **Double-click** places the last vertex and finishes the polyline.
4. `Esc` cancels the polyline at any time.

The polyline is open and unfilled; it moves, resizes and formats like any
other shape.

### Connection points {#connection-points}

Connection points are the places on a shape that line ends snap to. Each
point is stored relative to its shape, so it rotates, stretches and flips
with it.

1. Turn on the *Connection Point* tool (`Shift+C`).
2. Hover over a shape — over a shape that will take a point the pointer
   becomes a crosshair.
3. Click to place a point (snapped to grid, guides and other points first).
4. Turn on *View — Connection Points* to see the points' blue crosses.

Each placement is undone in one step. The drawing tools, the *Connection
Point* tool and dragging line ends all snap to nearby connection points — so
a line end lands exactly on another shape's point.

## Selecting {#selecting}

- **Click** selects a shape.
- Repeated clicks at one point over a group cycle through the shapes under
  the pointer: the group first, then the group's shape under the pointer,
  then the group again (the order follows the group's behaviour, see
  [Grouping](#grouping)).
- **Shift+click** or a **rubber band** adds shapes to the selection.
- `Ctrl+A` (*Edit — Select All*) selects every shape, `Delete` deletes the
  selected ones.

Selection handles: eight squares at the corners and side midpoints; a line
has its begin, end and two intermediate handles. The first selected shape has
lime handles, the others aqua; the box of a flipped shape is red (the first)
or magenta. A shape with object handles turned off shows none, and handles
locked by protection or a layer show as small white diamonds and do not
drag.

## Moving and resizing {#moving}

- Drag the selection to move it.
- With `Shift` held the move keeps to one axis — whichever the pointer has
  travelled further along; you can press and release `Shift` mid-drag.
- Dragging with `Ctrl` copies the selection: the originals stay put and the
  copies follow the pointer, all in one undo step. *Edit — Duplicate*
  (`Ctrl+D`) puts a copy next to the original.
- Drag a corner or side handle to resize; with `Shift` to keep proportions.

Exact position, size and angle are set in
[Position and size]({{ '/en/dev/designer/properties/' | relative_url }}#transform)
on the Properties panel.

### Moving with the arrow keys {#nudging}

| Keys | Step |
|---|---|
| Arrow | one ruler division — between the labelled marks |
| `Ctrl` + arrow | the grid step from *Tools — Ruler & Grid...* |
| `Alt` + arrow | one screen pixel; wins over `Ctrl` if both are held |

The ruler division follows the zoom. A run of presses is undone with one
`Ctrl+Z`.

## Rotating and flipping {#rotating}

By 90° — *Shape — Rotate 90° Right / Left* (`Ctrl+R` / `Ctrl+L`), the
*Rotate and flip* button on the *Arrange* bar, or the context menu's
*Object* submenu, which also flips horizontally and vertically.

By any angle — turn on **Rotate Mode** (`Shift+R`):

- the corner handles become circles: dragging any handle rotates the shape
  around its pin, marked with a circle and crosshair;
- the handles follow the rotated shape;
- width, height and position do not change — only the angle;
- with `Shift` held the angle moves in 15° steps.

Shapes drawn in the Designer have their pin in the middle; an imported shape
may have it elsewhere and then rotates around it. Pick *Select* (`V`) to go
back to normal selection.

## Text on a shape {#text}

**Double-click** a shape to edit its text; `Esc` or a click outside the shape
finishes.

## Undo and redo {#undo}

`Ctrl+Z` / `Ctrl+Y`. Each schematic has its own history. Everything is
undoable: drawing, moving and resizing (a drag is one step), deleting,
grouping, order, pasting and dropping stencils, applying formatting dialogs
and buttons, rotating, flipping and aligning. The *Edit* menu names the step
it will undo or redo, e.g. *Undo Move*; so do the toolbar buttons' tooltips.

## Context menu {#context-menu}

A right-click on the schematic opens the context menu; a right-click on an
unselected shape selects it first.

| Group | Commands |
|---|---|
| Clipboard | Cut, Copy, Paste |
| View | Zoom to Fit, zoom 400/200/100/50%, Grid, Guides, Connection Points, Custom Properties, Transform, Layers... |
| Format | Text..., Fill..., Line..., Behavior..., Protection..., Layer Membership... |
| Object | Bring to Front, Send to Back, Group, Ungroup, rotate left and right, flip |
| Bottom | Delete, Select All |

A command is enabled only when it applies: *Group* for two or more shapes,
*Format — Line...* for a single shape, *Paste* when the clipboard holds
shapes. *Bring to Front* and *Send to Back* need exactly one selected shape.

## Grouping {#grouping}

| Action | Command |
|---|---|
| Group the selection | *Shape — Group* (`Ctrl+G`) |
| Ungroup | *Shape — Ungroup* (`Ctrl+Shift+G`) |
| Group again | *Shape — Regroup* |

The same commands are on the *Order and group* button of the *Arrange* bar.
A group is selected whole first; a second click at the same point selects
the group's shape under the pointer. The order is set by the group's
behaviour — group first, members first or group only (the
[Behavior dialog]({{ '/en/dev/designer/formatting/' | relative_url }}#behavior)).

## Shape order {#z-order}

*Shape — Bring to Front* (`Ctrl+Shift+]`) draws the shape above all others,
*Send to Back* (`Ctrl+Shift+[`) below all. Both act on one selected shape.
