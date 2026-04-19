---
title: Formulas
nav_order: 4
permalink: /en/formulas/
---

# Formulas
{:.no_toc}

* TOC
{:toc}

Any Telecontrol SCADA data item can use a mathematical expression as
its data source. These expressions are also used in
[data-item configuration]({{ '/en/architecture/' | relative_url }}#data-items),
[tables]({{ '/en/client/table/' | relative_url }}),
[user tables]({{ '/en/client/sheet/' | relative_url }}), and control
conditions.

## Object references

Formulas can refer to values of other objects by alias:

* `TIT.1`: reference an object by alias
* `{object name}`: object names containing special characters must be
  wrapped in braces
* `{IEC_DEV.1\Channel1}`: reference a device channel

An initial `=` is allowed but not required.

## Arithmetic operators

The formula engine supports addition (`+`), subtraction (`-`),
multiplication (`*`), and division (`/`). Parentheses can be used for
grouping.

Example: `TIT.1 + TIT.2 * TIT.3`

## Functions

| Function | Description |
|:--:|---|
| `sin(x)` | sine |
| `cos(x)` | cosine |
| `tan(x)` | tangent |
| `asin(x)` | arcsine |
| `acos(x)` | arccosine |
| `atan(x)` | arctangent |
| `atan2(y, x)` | arctangent of `y/x` |
| `abs(x)` | absolute value |
| `not(x)` | logical negation |
| `sqrt(x)` | square root |
| `sign(x)` | sign of a number |
| `min(x1, x2, ...)` | minimum |
| `max(x1, x2, ...)` | maximum |
| `and(x1, x2, ...)` | logical AND |
| `or(x1, x2, ...)` | logical OR |
| `if(x, a, b)` | ternary conditional operator |

Angles for trigonometric functions are specified in radians.
`...` means an arbitrary number of parameters.

## Examples

* `TIT1 + TIT2 * TIT3`
* `sin({IEC_DEV.1\Channel1})`
* `if(or(rec1_current>3, rec2_current>3), rec3_current, 0)`
* `and(!TS.1379, !TS.1380, !TS.1382)`
* `or(TS.1, TS.2)`

![]({{ '/img/ti-formula.png' | relative_url }})

`TIT.637`, `TIT.638`, and `TIT.639` are non-editable TIT object numbers
assigned automatically by the Server when the objects are created in the
database.

## Errors

If a formula is invalid, the client displays an error message. The data
item quality flags show `[H]`, which means a connection error or an
invalid expression.
