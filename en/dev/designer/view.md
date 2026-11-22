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

The same menu holds the zoom, the panels and the Formula bar, and the
language, style and renderer (see
[The Designer window]({{ '/en/dev/designer/' | relative_url }}#settings)).

## The Tools menu {#tools-menu}

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
