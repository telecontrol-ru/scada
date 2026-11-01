---
title: Portfolios
nav_order: 12
parent: Client
permalink: /en/client/portfolio/
---

# Portfolios
{:.no_toc}

* TOC
{:toc}

A portfolio is a named collection of data objects grouped by the user
for convenient monitoring and analysis. Portfolios are shown as a tree:
root nodes are portfolios, and child nodes are the objects included in
them.

The portfolio panel is in the *Objects* mode of the
[section rail]({{ '/en/client/workbench/' | relative_url }}#activity-bar),
below the object tree; the `More -> Portfolio` command opens it as well.

## Where portfolios are kept {#storage}

Portfolios are kept in your **user profile**, like the window layout and
settings, not in the Server's configuration:

* portfolios are **personal**: other users do not see them, and a portfolio
  cannot be handed to a colleague — they have to build their own;
* the profile is saved on this computer; in addition, when the Client closes
  it also saves the profile on the Server, in your account's profile, and at
  login it loads the profile from there — so your portfolios are available on
  any computer where you log in under your account. This holds for any
  [access rights]({{ '/en/dev/users/' | relative_url }}#access-rights), an
  account with no roles included, and for the
  "Telecontrol" server type; with the "OPC UA" type the profile, and the
  portfolios with it, is kept on this computer only.

## Create a portfolio

To create a new portfolio, choose `Create Portfolio` in the portfolio
panel's context menu. The name is generated automatically
and opens for editing straight away.

## Rename

To rename a portfolio, choose `Rename` from the portfolio context menu.

## Add objects

Objects are added to the selected portfolio from the object panel (with the
check box next to the object) or with the `Add Items...` command in the
portfolio context menu.

A portfolio is a set, not an ordered list: each object is in it once, and the
objects are shown in an order the Client chooses itself — not the order in
which they were added. That order cannot be changed.

## Summary and graphs for a portfolio {#open}

Select a portfolio and choose *Summary*, *Graph* or *Table* in the
context menu — the window opens with all of the portfolio's
objects. Select a single object in the portfolio to open windows for that
object only. How to build a report is described in
[Reports and analysis]({{ '/en/client/reports/' | relative_url }}).

## Delete

The `Delete` command in the context menu removes the selected object from
its portfolio or, when the portfolio itself is selected, deletes the whole
portfolio. If an object is deleted from the system, it is automatically
removed from all portfolios.

**WARNING:** a portfolio is deleted at once, **without confirmation**, and
this cannot be undone — the only way back is to build it again.
