---
title: Formatting
nav_order: 2
parent: Designer
grand_parent: Development
permalink: /en/dev/designer/formatting/
---

# Formatting
{:.no_toc}

* TOC
{:toc}

## The Format bar {#format-bar}

![The Format toolbar]({{ '/img/designer-toolbar-format-en.png' | relative_url }}){: width="925"}

The bar is unavailable until something is selected. From left to right:

- **Fill colour, line colour, text colour** — a click opens the colour picker
  and applies the colour to every selected shape. The strip under the icon
  shows the selection's current colour (chequered when the shapes differ).
- **Line width** (`0`–`9` pixels), **line pattern** (no line, solid, dash,
  dot, dash-dot, short dash) and **arrow style** (no arrows, end, begin,
  both). Clicking the button re-applies the value it shows; the arrow beside
  it opens the list.
- **Style** — applies one of the document's styles to the selected shapes, or
  detaches them from a style (*(No Style)*). Unnamed styles are listed as
  `Style <number>`.
- **Font** and **size**.
- **Bold, italic, underline**.
- **Text alignment** — left, center, right and top, middle, bottom — one
  button with a list; the button shows the current horizontal alignment.

Every change is one undo step.

## The Format menu dialogs {#dialogs}

The dialogs open from the *Format* menu or the context menu's *Format*
submenu.

| Dialog | What it sets |
|---|---|
| **Line...** | weight, colour, pattern (the same six as on the bar), and the begin and end arrows — seven kinds each |
| **Fill...** | fill and background colours, pattern, gradient, picture, foreground and background transparency |
| **Text...** | font, size, style, alignment and colour of the text |
| **Behavior...** | object type (1-D or 2-D), handles and alignment box, printing, resize mode, group behaviour, double-click action |
| **Protection...** | locks: width, height, move in X and Y, rotate, delete, select, text edit, format; keep aspect ratio |
| **Document...** | page width, height and colour |
| **Layers...** | the document's layers (see [below](#layers)) |
| **Styles...** | the document's styles (see [below](#styles)) |

<img src="{{ '/img/designer-dialog-line-en.png' | relative_url }}" alt="The Line dialog" width="321"> <img src="{{ '/img/designer-dialog-fill-en.png' | relative_url }}" alt="The Fill dialog" width="428">

<img src="{{ '/img/designer-dialog-text-en.png' | relative_url }}" alt="The Text dialog" width="443"> <img src="{{ '/img/designer-dialog-document-en.png' | relative_url }}" alt="The Document dialog" width="300">

### Behavior {#behavior}

![The Behavior dialog]({{ '/img/designer-dialog-behavior-en.png' | relative_url }}){: width="551"}

On the *Object* tab:

- **Object type** — 1-D (a line or connector, with a begin and an end) or 2-D
  (a shape with a box).
- **Selection** — whether to show the object handles and the alignment box;
  **Non-printing** keeps the shape off printed output.
- **Resize mode** — what happens to the shape when the group or page around
  it is resized: *Scale with group*, *Reposition only* or *Use shape
  formula*.
- **Group** (for groups) — whether text editing applies to the group, the
  selection order (group only, group first, members first) and the display.

On the *Action* tab — the **double-click action**: the default (inherited
from the style), editing the text, or a formula of your own.

## Styles {#styles}

A style is a named set of formatting. Assign it to the selected shapes with
the *Style* list on the *Format* bar. Styles cascade: a value set in the shape
itself wins over the style, and the style over its parent style.

## Layers {#layers}

*Format — Layers...* (also *View — Layers...* in the context menu) manages the
document's layers.

![The Layers dialog]({{ '/img/designer-dialog-layer-en.png' | relative_url }}){: width="600"}

| Column | Purpose |
|---|---|
| Name | the layer's name; this is also where it is renamed |
| Visible | hides the layer's shapes without deleting them |
| Print | whether the layer is printed |
| Active | which layer new shapes go to |
| Lock | shapes on a locked layer cannot be selected or moved |

Below the table, *Layer attributes* sets the selected layer's colour and
transparency. *Add* and *Remove* create and delete layers.

To put existing shapes on layers, select them and choose
*Format — Layer Membership...*.

## Document properties {#document}

*Format — Document...* opens *Document Properties*: the page width, height
and colour.

## Arranging {#arrange}

![The Arrange toolbar]({{ '/img/designer-toolbar-arrange-en.png' | relative_url }}){: width="147"}

The *Arrange* bar has three buttons with lists of the same commands as the
*Shape* menu:

| Button | Commands |
|---|---|
| Align | left, right, top or bottom edges, or centres horizontally and vertically — for two or more shapes; the others align to the first selected |
| Order and group | Bring to Front, Send to Back, Group, Ungroup, Regroup |
| Rotate and flip | 90° right and left, flip horizontal and vertical |
