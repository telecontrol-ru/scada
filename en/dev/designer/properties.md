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

![The Properties panel]({{ '/img/designer-properties-en.png' | relative_url }}){: width="360"}

The panel shows the cells of the selected shape. With nothing selected it
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
- The *XForm* row starts folded: the same values are on the Transform panel
  above.
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

### Bound values {#bound-values}

The *Bound values* section above the table lists every cell of the shape set
by a formula, with the formula: it shows what on the shape is computed and
from what, without hunting for `ƒx` marks in a long table. Clicking an entry
opens the cell in the Formula bar. Geometry vertices are left out: the drawing
tools put a formula on each of them, and they would bury the bindings you
made yourself. The section is absent when nothing is bound.

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

## The Transform panel {#transform}

![The Transform panel]({{ '/img/designer-transform-en.png' | relative_url }}){: width="360"}

Sets the selected shape's geometry as numbers, when handles are not precise
enough.

| Field | What it sets |
|---|---|
| Pin X, Pin Y | where the shape's pin sits on the page: the shape is positioned by it and rotates around it |
| Width, Height | the shape's size |
| Angle | rotation around the pin, in degrees |
| Resize | what happens to the shape when the group or page is resized: *Scale*, *Reposition* (without changing size) or the shape's *Formula* |
| Loc Pin X, Loc Pin Y | where the pin sits within the shape; in the middle by default, which is what makes a shape rotate around its centre |

Type a value and press `Enter`, or use the field's arrows. Every change is one
undo step. The fields are enabled only when exactly one shape is selected;
otherwise they are blank. The panel sits above the Properties panel; the
divider between them can be dragged, and in a narrow panel the fields fall
into one column. The same values in the property table (*Object — XForm*) can
be set by formulas.

## The Custom Properties panel {#custom-properties}

Shows the visible rows of the selected shape's *Prop* section:

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
