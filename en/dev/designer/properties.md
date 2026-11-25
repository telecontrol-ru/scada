---
title: Properties and formulas
nav_order: 4
parent: Designer
grand_parent: Development
permalink: /en/dev/designer/properties/
---

# Properties and formulas
{:.no_toc}

* TOC
{:toc}

Every shape is described by a table of cells: section — row — cell (for
example *Object — XForm — PinX* or *Object — Line — LineWeight*). A cell holds
a number, text, a colour or a formula, and a formula can refer to other cells
and to tags.

## The Properties panel {#property-panel}

![The Properties panel on its Sheet tab]({{ '/img/designer-properties-en.png' | relative_url }}){: width="360"}

At the top the panel names the selection: the shape's name (or its text, or
its master) and what it is — a shape, a group, an instance of a master; with
several shapes selected, how many; with nothing selected, the page. A shape
on a locked layer says so there too, which is why its values will not
change. The name of a single selected shape can be corrected right there,
and the list below it sets the style of the selected shapes.

Below are three tabs:

| Tab | What it holds |
|---|---|
| *Shape* | [position and size](#transform), [fill, line, text and behaviour](#shape-tab) |
| *Data* | [tags, bound cells, custom properties, hint, actions and events](#data-tab) |
| *Sheet* | every cell of the shape — described below |

A section on a tab folds when you click its heading. The tab you used last
opens next time.

### The Shape tab {#shape-tab}

Below [Position and size](#transform) come sections that show what the
shape is actually drawn with — including the values it takes from its master
or style:

| Section | Fields |
|---|---|
| Fill | Pattern, Colour, for a hatch a Second colour, Transparency |
| Line | Weight, Colour, Pattern, Begin and End arrow, Rounding, Transparency |
| Text | Font, Size, style (bold, italic, underline), Colour, horizontal and vertical alignment |
| Behaviour | Layers — a button for each layer of the page: pressed means every selected shape is on that layer, a `◐` mark that only some are; a click puts all the selected shapes on the layer or takes them all off. Non-printing. Double-click — Default, None, Edit text, Open sheet; a help topic or a formula of your own is set in the Behavior dialog, which *Help topic...* and *Custom formula...* open. Locks — buttons that lock width, height, horizontal and vertical move, rotation, deletion, text editing and formatting; for a group, Select and Display |

The Text section appears only when the shape has text; the text itself is
edited on the schematic with a double-click. The sections show when at least
one shape is selected.

Every field shows where its value comes from:

- **A plain name** — the shape sets the value itself.
- **A blue bar left of the name** — the shape sets the value over a
  different one from its master or style. Only on these fields does
  *Reset to Master* (or *to Style*) change what the schematic shows.
- **A dimmed name** — the value comes from the master, from the style, or
  is the default (the name's tooltip says which).
  Changing it gives the shape a value of its own.
- **An `ƒx` button** — a formula computes the value. The field cannot be
  edited here, so a binding cannot be erased by accident; the button opens
  the formula in the Formula bar.
- **A dash `—`** — the selected shapes have different values. A new value
  goes to all of them.

Every change is one undo step named after its section, e.g. *Undo Line*. A
field's context menu: *Reset to Master* (or *to Style*) — remove the shape's
own value; *Remove Formula* — replace the formula with its current value;
*Edit Formula*; *Show in Sheet*.

### Sheet {#sheet}

The tab shows the cells of the selected shape. With nothing selected it
shows the document's cells (page width, height and colour, layers and
others), and in a master's tab that master's cells. At the top, *Info* gives
the shape's ID, type, name, master and style.

- The *Filter* field keeps the rows whose name or value contains what you
  type; the count reads e.g. `12 of 82`.
- Cells with a formula show the computed value marked `ƒx`, e.g. `ƒx 100` for
  `Width*0.5`. Formulas that refer to tags or other shapes are shown as text.
- Colours are shown as a swatch and an `RGB(r,g,b)` value, Windows system
  colours by name, e.g. `System: Window`.
- Cells that hold a choice — line pattern, arrowheads, fill pattern, text
  alignment, resize mode — show the value's name, e.g. `Solid`, not the
  number the file stores; editing one opens a list.
- The *XForm* row starts folded: the same values are in *Position and size*
  on the *Shape* tab.
- Geometry rows are named `Row 1 - MoveTo`, `Row 2 - LineTo` and so on; the
  `Component` row holds flags such as `NoFill` and `NoShow`.
- A value can be edited right in the table (double-click it).

The `ƒx` button left of the filter (`Ctrl+``) shows **formulas** instead of
values; formulas can be edited in the table too, and `Ctrl+Space` in the cell
editor inserts a function.

![The Properties panel showing formulas]({{ '/img/designer-properties-formulas-en.png' | relative_url }}){: width="360"}

The table's context menu holds *Copy Value* for the selected row and *Copy
All Properties* of the shape as text (for a selected shape only), and the
formula toggle. Clicking a row opens its cell in the Formula bar.

### The Data tab {#data-tab}

![The Data tab]({{ '/img/designer-data-en.png' | relative_url }}){: width="360"}

This is where a shape is bound to the plant: which tags it reads and which of
its values depend on them.

**Tags** — the selected shape's tags. A row has a *Name* — the shape's
formulas read the tag as `Tag.<name>` (e.g. `IF(Tag.State,…)`) — a
*Reference* to the Server's object — its alias set on the Server, or its id
such as `TS.1379`, or, for an object of a namespace the SCADA model does not
know (another vendor's OPC UA server), an id in braces that names the
namespace by its URI, such as `{nsu=urn:plant;s=Plant.Temperature}`; a
Vidicon schematic keeps an address such as
`{OPC1\PS12.T1.State}` here — *Low* and
*High*, and an *In hint* mark. Every field is edited right in the table; *Add
tag* adds a row and *Remove* removes the selected one. Rows the shape takes
from its master are dimmed; editing one gives the shape a row of its own.
The easiest way to fill in a reference is not to type it but to drag the
object from the [Tags](#server-tags) panel — onto the shape or straight into
the table: onto a row to replace its reference, or below the rows to add one.
While the Designer is connected to the Server, the *Object* column shows
what the reference points at, e.g. `Substation / Breaker Q1`; if the Server
has no such alias or id, it reads *Not on the Server* — the Client will not
be able to show that tag.

**Bound cells**{: #bound-values} — every cell of the shape set by a formula,
with the formula: what on the shape is computed, and from what. Clicking an
entry opens the cell in the Formula bar. Geometry vertices are left out: the
drawing tools put a formula on each of them, and they would bury the bindings
you made yourself. Tag references are not repeated either — they are in Tags.
With nothing selected the section lists the page's formulas.

**[Custom properties](#custom-properties)** — see below.

**Hint** — the description, value format and time format of the shape's
runtime hint.

**Actions** and **Events** — the shape's context-menu commands and its event
handlers (mouse down, load and others), as the schematic stores them. They are
shown here, not edited; the sections appear when the shape has any.

Tags, the hint, actions and events belong to one shape: with several shapes
selected those sections are absent.

## The Formula bar {#formula-bar}

The Formula bar is a row of its own below the toolbars; it can be hidden from
the *View* menu.

| Control | Purpose |
|---|---|
| Cell list | every cell set on the selected shape; choose one to load its formula |
| ✕ or `Esc` | discard the edit and restore the cell's formula |
| ✓ or `Enter` | write the formula into the cell (undone with `Ctrl+Z`) |
| `f(x)` | the function list; the chosen one is inserted as `NAME(<arg>)` |
| Formula field | the formula text; `Ctrl+Space` opens the function list |

While editing a formula, `Shift`+click a cell in the Properties panel to
insert a reference to it, e.g. `Pump1!XForm.Width`.

### Operators {#operators}

| Operator | Meaning | Example |
|---|---|---|
| `+ - * /` | arithmetic | `Width * 0.5` |
| `%` or `MOD` | remainder | `10 % 3` → 1 |
| `^` | power (right-associative) | `2 ^ 10` → 1024 |
| `= == <> !=` | equality and inequality | `Width = 100` |
| `< <= > >=` | comparison | `Height > 50` |
| `& AND` | bitwise AND | `12 AND 10` → 8 |
| `\| OR` | bitwise OR | `12 OR 10` → 14 |
| `XOR` | bitwise exclusive OR | `12 XOR 10` → 6 |
| `~ NOT` | bitwise NOT | `NOT 0` → -1 |
| `SHL`, `SHR` | shift left, right | `1 SHL 4` → 16 |

Constants: `TRUE` (1), `FALSE` (0), `PI` (3.14159…).

### References {#references}

| Reference | Example |
|---|---|
| tag | `{Server\Pump.Speed}` |
| a tag's property or modifier | `{Server\Pump.Speed}.Quality` |
| another shape's cell | `Pump1!XForm.Width` |

The Designer parses and keeps such references; the Client supplies live tag
values when it shows the schematic. How to link a schematic element to a SCADA
object is described in
[Vidicon displays]({{ '/en/dev/displays/' | relative_url }}#vidicon): the
object's address goes into the element's tag (section *Tag*, cell *Raw*), and
the formulas read the tag's value.

### Functions {#functions}

**Core**: `If(cond, then, else)` — *then* if the condition is not 0,
otherwise *else*; `Guard(x)` — returns *x* unchanged (protects it from being
overwritten); `Min(a, b)`, `Max(a, b)`.

**Algebraic**: `Abs`, `Sgn` (−1, 0 or 1), `Sqr` (square), `Sqrt`,
`Power(base, exp)`, `Exp`, `Ln`, `Log2`, `Log10`, `Log(base, x)`,
`LnXP1(x)` = ln(1 + x), `Ceil`, `Floor`, `Round`, `Int` (drops the fraction),
`Frac` (the fraction), `PI()`.

**Trigonometric — in degrees**: `Sin`, `Cos`, `Tan`, `Cot`, `Sec`, `Csc`,
`Asin`, `Acos`, `Atan`, `ATan2(x, y)`, `Acot`, `Asec`, `Acsc`.

**Angle conversion**: `DegToRad`, `RadToDeg`, `DegToGrad`, `GradToDeg`,
`RadToGrad`, `GradToRad`.

**Hyperbolic**: `Sinh`, `Cosh`, `Tanh`, `Coth`, `Sech`, `Csch` and the inverse
`Asinh`, `Acosh`, `Atanh`, `Acoth`, `Asech`, `Acsch`.

**Colour**: `RGB(r, g, b)` — a colour from 0–255 components;
`GradC(ratio, c1, c2)` — a colour between *c1* and *c2* (ratio 0–1);
`GradCR(value, c1, c2, low, high)` — a colour by where the value falls in the
range.

**String**: `Concat(s1, s2, …)`, `Length(s)`, `SubStr(s, pos, len)` (position
from 1), `UpperCase(s)`, `LowerCase(s)`, `Pos(substr, s)` (from 1, 0 if not
found), `Replace(s, old, new)`, `IntToStr(n)`, `StrToInt(s)` and
`StrToFloat(s)` (0 on error), `Format(fmt, …)` in printf style (`%d`, `%f`,
`%e`, `%g`, `%s`).

## Server tags {#server-tags}

The *Tags* panel — the third tab beside *Stencils* and *Navigator* — shows
the Server's objects, so shapes can be bound to them without typing
references.

1. *Tools — Connect to Server...*: the Server's address (`opc.tcp://…`), user
   and password. The address and user are remembered, the password is not.
2. On the first connection the Designer shows the SHA-256 fingerprint of the
   Server's certificate. **Compare it with the fingerprint the Server's
   administrator publishes** before trusting the certificate. The password is
   not sent until the certificate is accepted. If the Server at the same
   address presents a different certificate, the Designer warns about it and
   by default refuses to connect: that is what an intercepted connection
   would look like.
3. In the *Tags* panel, open the folders and drag an object onto a shape. The
   shape gets a tag row (`Tag1`, `Tag2`, …) referring to the object — by its
   alias when one is set on the Server, otherwise by an id such as `TS.1379`,
   or by the `{nsu=…}` form above for a namespace the SCADA model does not
   know. An object whose id contains `}` cannot be dragged, since a reference
   cannot hold that character; its tooltip says so. It is one undo step; the row shows on the [Data](#data-tab) tab, where it
   can be renamed so formulas read a meaningful name.

The field above the tree filters the objects already opened. *Tools —
Disconnect from Server* closes the connection. The schematic does not change:
the bindings are stored in it, and the Server is needed only to pick objects.

## Position and size {#transform}

![The Shape tab's Position and size section]({{ '/img/designer-transform-en.png' | relative_url }}){: width="360"}

A section on the Properties panel's *Shape* tab. Sets the selected shape's geometry as numbers, when handles are not precise
enough.

| Field | What it sets |
|---|---|
| Pin X, Pin Y | where the shape's pin sits on the page: the shape is positioned by it and rotates around it |
| Width, Height | the shape's size |
| Angle | rotation around the pin, in degrees |
| Resize | what happens to the shape when the group or page is resized: *Scale*, *Reposition* (without changing size) or the shape's *Formula* |
| Loc Pin X, Loc Pin Y | where the pin sits within the shape; in the middle by default, which is what makes a shape rotate around its centre |

Type a value and press `Enter`. The fields behave as in the tab's other
sections: they show where a value comes from, change every selected shape at
once as one undo step, and show a dash where the shapes differ. A field set by
a formula is not edited here — a drawn shape's Loc Pin X is usually
`Width*0.5`. In a wide enough panel the fields sit in pairs (Pin X beside
Pin Y), otherwise in one column.

## Custom properties {#custom-properties}

A section on the Properties panel's *Data* tab. Shows the visible rows of the selected shape's *Prop* section:

| Column | Purpose |
|---|---|
| Prompt | text for the user, when set |
| Label | the property's name, by which formulas refer to it, e.g. `Prop.DeviceName` |
| Value | the current value or formula |

Invisible rows are hidden; the order follows the sort key. Editing a value
changes the shape at once and is undone in one step. With nothing selected or
several shapes selected the table is disabled.

*Define...* opens *Define Properties*: add and remove rows, rename the label,
set the prompt, value, type and format, make a row invisible. *OK* applies all
the changes in one undo step.

## The Navigator {#navigator}

![The Navigator panel]({{ '/img/designer-navigator-en.png' | relative_url }}){: width="262"}

Every shape of the schematic as a tree. A row is named after the shape's name
or, without one, its text, master or number (`Shape <number>`); the second
column names its master (or Group / Shape). Clicking a row selects the shape
on the schematic.
