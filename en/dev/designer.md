---
title: Designer
nav_order: 6.5
parent: Development
has_children: true
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

The pages of this section cover the work in detail:

- [Drawing and editing]({{ '/en/dev/designer/drawing/' | relative_url }}) —
  tools, selection, moving, rotation, grouping, order;
- [Formatting]({{ '/en/dev/designer/formatting/' | relative_url }}) — the
  Format bar, the Line, Fill, Text and Behavior dialogs, styles, layers,
  document properties;
- [Stencils]({{ '/en/dev/designer/stencils/' | relative_url }}) — symbols,
  creating and editing masters, *vdc* libraries;
- [Properties and formulas]({{ '/en/dev/designer/properties/' | relative_url }})
  — the Properties panel with its Shape, Data and Sheet tabs, the Formula bar
  and the function reference;
- [Rulers, grid and view]({{ '/en/dev/designer/view/' | relative_url }}) —
  zoom, scrolling, rulers, guides, grid and snapping.

## Installation {#install}

The Designer is part of the Windows Client package
`telecontrol-scada-<version>.msi`, which creates *Дизайнер* (Designer)
shortcuts on the desktop and in the *Start — ОИК Телеконтроль* menu.
**That package is not yet published for version 2.6** — see
[Installing the Client]({{ '/en/getting-started/' | relative_url }}#client-install).

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
  shape (see [Properties and formulas]({{ '/en/dev/designer/properties/' | relative_url }}#formula-bar)).

![The Standard toolbar]({{ '/img/designer-toolbar-standard-en.png' | relative_url }}){: width="407"}

On the left are the vertical *Tools* bar with the drawing tools, and the
*Stencils* and *Navigator* panels. On the right is the *Properties* panel
with its *Shape*, *Data* and *Sheet* tabs. Panels stacked as tabs switch
by the tabs above them; any panel, the Formula bar or a toolbar can be closed
or reopened from the *View* menu. Panels and toolbars can be dragged to
another edge of the window; where you put them is remembered.

At the bottom is the **status bar**:

- the pointer's coordinates over the schematic, e.g. `X = 123.4    Y = 567.8`;
- the selection: for one shape its name, width, height, angle and position,
  for a line its length, angle and offsets, for several shapes their count,
  and with nothing selected the page size, e.g. `Page 2760 × 1960`;
- the *Grid* and *Snap* toggles and the zoom: zoom out, the zoom field (pick
  or type, e.g. `150%`), zoom in, zoom to fit.

### Language, style and renderer {#settings}

- *View — Language* — the interface language: Russian, English or the
  system's. Takes effect after a restart.
- *View — Style* — the widget style; *Fusion* by default.
- *View — Renderer* — how the schematic is drawn: *Scene* or *QPainter*, and
  *GDI+* on Windows. The same submenu holds the *Anti-aliasing* toggle: off
  gives crisper thin lines, on gives smoother curves.

The choices are remembered per Windows user.

## Files {#files}

| Command | Shortcut |
|---|---|
| *File — New* | `Ctrl+N` |
| *File — New Stencil Document* | — |
| *File — Open...* (*vds*, *vdc*, *sde*, *xsde*) | `Ctrl+O` |
| *File — Save* | `Ctrl+S` |
| *File — Save As...* | — |
| *File — Recent Files* | — |
| *File — Print...* | `Ctrl+P` |
| *File — Print Preview...* | — |
| *File — Export...* | — |

A schematic is stored in the binary *vds* format. The print preview lets you
change the page orientation, zoom and printer before printing.

*Export...* saves the schematic's page as a picture for documentation or
mail: *PNG* is a bitmap the size of the page (the schematic at 100%), *PDF* a
document whose lines and text stay vector and stay sharp when enlarged. The
schematic is exported the way it prints: shapes on non-printing layers are
left out.

**Modus schematics** (*sde*, *xsde*) open too, to convert them to the Vidicon
format: such a schematic is saved with *Save As...* and only as *vds*; the
original Modus file is left unchanged. Modus meters, switches and buttons are
drawn with Modus's own pictures from the *Modus* stencil: the *Modus.vdc*
library, holding the pictures of the Modus 6.30 element library, which is
installed with the Designer in its stencil folder. If the file is not there,
those elements are drawn in simplified form. To take the pictures from a
different Modus stencil, set the `SCADA_MODUS_STENCIL` environment variable to
the full path of its *vdc* file.

The *Modus* stencil opens with the other default stencils
(*File — Open Default Stencils*, `F3`) or through *File — Open Stencil...*;
its pictures can be placed on schematics like any stencil. Check the schematic
after converting it: elements with no Vidicon counterpart may look different.

## Tabs, unsaved changes and the Window menu {#tabs}

Every open schematic — and every master opened for editing — is a tab of its
own. The tab strip appears when a second schematic is opened; with one, its
name is in the window title.

![Two schematics open]({{ '/img/designer-tabs-en.png' | relative_url }})

A schematic with unsaved changes is marked with an asterisk `*` on its tab
and in the window title. **If you close such a schematic** — its tab, the
Designer window or the whole program — the Designer asks whether to save the
changes:

![Asking to save changes]({{ '/img/designer-save-prompt-en.png' | relative_url }}){: width="413"}

*Save* writes the file (asking for a name for a new schematic), *Don't Save*
closes without writing, *Cancel* keeps the schematic open. Opening a file
while an empty new *Untitled* schematic that you have not changed is in front
replaces it.

**Autosave.** Every two minutes the Designer copies modified schematics to a
folder in the user's profile; a copy is deleted when its schematic is saved or
closed. If the Designer closed abnormally (the program failed, the computer
went down), the next start offers to recover the unsaved schematics.
*Recover* opens them with their changes unsaved — check them and save; a
schematic opened from a file is saved back to that file. *Discard* deletes the
copies. Autosave does not replace saving: the schematic's file changes only
when you *Save*.

The *Window* menu:

| Command | Shortcut | Action |
|---|---|---|
| Next | `Ctrl+F6` | next tab |
| Previous | `Ctrl+Shift+F6` | previous tab |
| Close | `Ctrl+F4` | close the current tab |
| Close All | — | close every tab |

Below them the menu lists the open schematics (the current one checked); the
first nine are reached with `Alt+1` … `Alt+9`.

## Keyboard shortcuts {#keys}

*Help — Keyboard Shortcuts* lists every menu command that has a shortcut. On
macOS, press `⌘` wherever this manual says `Ctrl`. The main ones:

| Keys | Action |
|---|---|
| `Ctrl+N` / `Ctrl+O` / `Ctrl+S` | New / open / save |
| `Ctrl+Z` / `Ctrl+Y` | Undo / redo |
| `Ctrl+X` / `Ctrl+C` / `Ctrl+V` | Cut / copy / paste |
| `Ctrl+A` / `Ctrl+D` / `Delete` | Select all / duplicate / delete |
| `Ctrl+G` / `Ctrl+Shift+G` | Group / ungroup |
| `Ctrl+Shift+]` / `Ctrl+Shift+[` | Bring to front / send to back |
| `Ctrl+R` / `Ctrl+L` | Rotate 90° right / left |
| `Alt+Enter` | Properties panel |
| `Ctrl++` / `Ctrl+-` / `Ctrl+0` | Zoom in / out / to fit |
| `Alt+C` | Center the selection |
| `Ctrl+2` | Zoom to the selection |
| Mouse wheel / `Ctrl` + wheel (`⌘` + scroll on macOS) | Scroll / zoom around the pointer |
| Space + drag | Pan the schematic |
| Arrows (`Ctrl`, `Alt`) | Move the selection by a ruler division (grid step, pixel) |
| `Ctrl` + drag | Copy the selection |
| `Ctrl+Shift+O` / `F3` | Open Stencil / Open Default Stencils |
| `Ctrl+F6` / `Ctrl+Shift+F6` / `Ctrl+F4` | Next / previous / close tab |
| `Esc` | Cancel the current action, leave text editing |
