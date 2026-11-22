---
title: Stencils
nav_order: 3
parent: Designer
grand_parent: Development
permalink: /en/dev/designer/stencils/
---

# Stencils
{:.no_toc}

* TOC
{:toc}

A master is a ready-made symbol (a breaker, a transformer, a disconnector...)
that you place on a schematic as many times as you like. Each schematic keeps
copies of the masters used on it; shared masters are collected in stencil
libraries — *vdc* files.

## The Stencils panel {#panel}

![The Stencils panel]({{ '/img/designer-stencils-en.png' | relative_url }}){: width="262"}

The *Document* tab shows the current schematic's masters, the other tabs the
open libraries. **Drag a symbol onto the schematic** to place it.

- The *Search* field keeps the symbols whose name contains what you type; the
  count beside it reads e.g. `3 of 214`, so an empty search result is not
  mistaken for an empty library.
- The `☰` button switches every tab from icons to a list that shows each name
  in full; the choice is remembered. Hover over a symbol to see its full
  name.

## Stencil libraries {#libraries}

- *File — Open Stencil...* (`Ctrl+Shift+O`) opens a *vdc* library as a new
  tab.
- *File — Open Default Stencils* (`F3`) opens every library in the folder set
  in *Tools — Options...* (*Stencils folder*).
- Saving a schematic records the list of open libraries in it; they reopen
  the next time the schematic is opened.

## Creating and editing masters {#masters}

- **From the selection**: select shapes and choose
  *Shape — Create Master from Selection*; the Designer asks for a name, and
  the new master appears on the *Document* tab.
- **By dragging**: drag a selected shape with `Ctrl` held onto the *Document*
  tab of the Stencils panel — the same thing.
- **Editing**: double-click a master (or *Edit Master* in its context menu) to
  open it in a tab of its own. Edit the shapes as on any schematic and close
  the tab — the changes go into the master, and every instance on the
  schematic updates. Reopening the same master switches to its open tab. With
  nothing selected in the master's tab, the Properties panel shows the
  master's own properties.
- **Properties...** in the context menu — the master's name, description
  (shown in its tooltip) and icon.
- **Rename...** and **Delete** — in the same menu. Instances of a deleted
  master on the schematic lose their link to it.

Creating, deleting, renaming, editing properties of and editing a
schematic's masters are undone like any other change to the schematic.

Masters from an open *vdc* library are edited the same way — by
double-click; closing the tab writes the changes into the library and **saves
the *vdc* file at once**. Such an edit is not in the schematic's undo history:
it changes the library, not the schematic.

Styles and fonts defined in a master's tab are not yet carried into the
schematic; edit shapes there — geometry, position, line, fill and text.

## Updating masters from a reference library {#synchronize}

A schematic keeps its own copies of masters, so a master corrected in its
library does not change in schematics already drawn with it.
*File — Synchronize Stencils...* updates them: pick the reference *vdc* (or
*vds*), and every master of the schematic that came from it gets the
reference's current artwork, properties, description and icon.

- **Instances keep their master** and show the new artwork at once; values
  set in the instances themselves are untouched.
- **Nothing is added or removed**: a reference master the schematic never
  used is not added (drag it in from an open library), and a master of your
  own that the reference lacks is left alone.
- **Masters already current are skipped**; the status bar says how many were
  checked and updated, and how many reference masters are not in the
  schematic. If nothing needed updating, the undo history is unchanged.
- **One undo step** restores every updated master.

A reference file that cannot be read is reported and the schematic is left
unchanged.

## Creating a *vdc* library {#vdc}

1. *File — New Stencil Document* opens a blank library sheet.
2. Draw or paste shapes and turn them into masters with
   *Shape — Create Master from Selection*.
3. *File — Save As...* — for a library sheet the *vdc* format is selected by
   default. The library can then be opened in any schematic with
   *File — Open Stencil...*.

To change an existing library, open it as a stencil and edit masters right
on its tab, or open the *vdc* file with *File — Open...* if you need to add,
rename or delete masters.
