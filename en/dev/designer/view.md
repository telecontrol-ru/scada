---
title: Rulers, grid and view
nav_order: 5
parent: Designer
grand_parent: Development
permalink: /en/dev/designer/view/
---

# Rulers, grid and view
{:.no_toc}

* TOC
{:toc}

## Zoom and scrolling {#zoom}

- **Scroll** — the mouse wheel or two fingers on a touchpad; with `Shift` the
  wheel scrolls sideways.
- **Zoom** — `Ctrl` + wheel (`⌘` + scroll on macOS) or a touchpad pinch (zooming around the pointer),
  `Ctrl++` and `Ctrl+-`, *View — Zoom to Fit* (`Ctrl+0`), the zoom field in
  the status bar (which takes a typed value such as `150%`), or the context
  menu's *View* zoom entries (400, 200, 100, 50%).
- **Pan** — drag with the space bar held.
- *View — Center Selection* (`Alt+C`) puts the selection in the middle of the
  window.
- *View — Zoom to Selection* (`Ctrl+2`) zooms so the selected shapes fill the
  window, and centres them.

## Rulers {#rulers}

![A schematic with rulers and grid]({{ '/img/designer-grid-en.png' | relative_url }}){: width="539"}

A horizontal ruler runs along the top of the schematic and a vertical one
along the left. The labels are page coordinates; the divisions refine and
coarsen with the zoom. Both rulers mark the pointer's position in red, and
the selection with three black marks: left edge, centre and right edge (top,
middle and bottom on the vertical ruler).

*View — Rulers* hides and shows the rulers. The spacing between labelled
divisions is set in *Tools — Ruler & Grid...*.

## Guides {#guides}

Guides are non-printing lines that shapes snap to.

| Action | How |
|---|---|
| Create a vertical guide | press on the left ruler and drag right onto the schematic |
| Create a horizontal guide | press on the top ruler and drag down onto the schematic |
| Move | drag the guide |
| Delete | drag the guide back onto the ruler |
| Show or hide | *View — Guides* |
| Snapping | *View — Snap to Guides* |

Guides are drawn as blue dashed lines; the one being dragged turns orange.

## Grid and snapping {#grid}

- *View — Grid* or the *Grid* button in the status bar — show or hide the
  grid.
- *View — Snap to Grid* or the *Snap* button in the status bar — snap shape
  edges to grid points.
- *View — Snap to Ruler Subdivisions* snaps to the ruler's divisions instead
  of the grid. The grid step is fixed by the document while the ruler's
  divisions follow the zoom, so at some zoom levels one is much coarser than
  the other; with both on, an edge snaps to whichever is nearer.
- *View — Snap to Guides* — to guides.

Shapes always snap to connection points within reach, even when the points
themselves are hidden.

Grid lines are never drawn closer than 8 pixels apart: zoomed out, every 2nd,
5th, 10th, 20th… line is drawn, so the grid does not hide the schematic.
Snapping still uses every step of the document's grid.

## Preview {#preview}

![The Preview window]({{ '/img/designer-preview-en.png' | relative_url }}){: width="640"}

*View — Preview* (`F5`) shows the open schematic the way the Client will
draw it, so its bindings can be checked before it reaches the operators.
On the right are the schematic's data sources — the addresses in its shapes'
*Tag* rows (the full address is in the tooltip). Type a value and pick a
quality: the shapes bound to that source take the look they will have at
that value at once — a breaker turns green at 1, for example. An empty value
returns a shape to the look the schematic was saved with; *Reset Values*
clears them all.

While the Designer is connected to a Server (*Tools — Connect to
Server...*), the window shows the schematic with the Server's current
values: the *Server* column shows each source's value, and the shapes take
the look it gives them. A typed value replaces the Server's until it is
cleared — a way to check how the schematic will show an alarm without
touching the plant. A source the Server does not have is marked "Not on the
Server"; one it has but has had no value for yet — a signal whose device has
not reported since the Server started — reads "No value yet".

The window only shows: the schematic cannot be changed in it, and the values
typed are sent nowhere — the Designer writes nothing to the Server. It follows edits in the schematic window and
switching between schematics, keeping the values typed. If no *Tag* row names
a data source, the window says so.

## The View menu {#view-menu}

| Command | Action |
|---|---|
| Grid | show or hide the grid (on by default) |
| Guides | show or hide guides |
| Connection Points | show or hide every shape's connection points (off by default) |
| Rulers | show or hide the rulers (on by default) |
| Snap to Grid | snap shape edges to the grid |
| Snap to Guides | snap to guides |
| Snap to Ruler Subdivisions | snap to the ruler's divisions (off by default) |
| Preview (`F5`) | show the schematic with the Server's or typed-in values, as the Client will draw it ([Preview](#preview)) |

The same menu holds the zoom, the panels and the Formula bar, and the
language, style and renderer (see
[The Designer window]({{ '/en/dev/designer/' | relative_url }}#settings)).

## The Tools menu {#tools-menu}

*Tools — Connect to Server...* and *Disconnect from Server* open and close
the connection for the [Tags]({{ '/en/dev/designer/properties/' | relative_url }}#server-tags) panel
and for the Server's values in the [Preview](#preview) window.

### Ruler & Grid {#ruler-grid}

*Tools — Ruler & Grid...* — settings of the current schematic; they are stored
in the document.

| Setting | Effect |
|---|---|
| Grid Spacing X / Y | the distance between grid lines in page units; also the step of grid snapping and of moving with `Ctrl` + arrows |
| Ruler Density X / Y | the smallest distance in screen pixels between labelled ruler divisions — larger means coarser divisions; also the step of moving with the arrows and of ruler snapping |

Changes take effect as soon as you press *OK*.

### Options {#options}

*Tools — Options...* — settings of the program rather than of a schematic;
they are remembered.

| Setting | Effect |
|---|---|
| Stencils folder | the folder *File — Open Default Stencils* (`F3`) opens libraries from; type a path or pick one with *Browse...* |
