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
* the profile is saved on this computer and, when the Client closes, also on
  the Server for your account, so the portfolios are available on another
  workstation after signing in with the same account;
* **with rights "0 — Executive / viewer" the profile is not saved on the
  Server**: the Server rejects the write, the Client reports on closing that
  the profile was kept on this computer only, and the portfolios stay on this
  computer. On another computer they have to be built again.

## Create a portfolio

To create a new portfolio, choose `Create Portfolio` on the command bar or
in the portfolio panel's context menu. The name is generated automatically
and opens for editing straight away.

## Rename

To rename a portfolio, choose `Rename` from the portfolio context menu.

## Add objects

Objects are added to the selected portfolio from the object panel (with the
check box next to the object) or with the `Add Items...` command in the
portfolio context menu.

## Summary and graphs for a portfolio {#open}

Select a portfolio and choose *Summary*, *Graph* or *Table* on the command
bar or in the context menu — the window opens with all of the portfolio's
objects. Select a single object in the portfolio to open windows for that
object only. How to build a report is described in
[Reports and analysis]({{ '/en/client/reports/' | relative_url }}).

## Delete

The context menu includes commands for removing individual objects from
a portfolio or deleting the portfolio completely. If an object is
deleted from the system, it is automatically removed from all
portfolios.
