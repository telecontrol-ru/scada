---
title: Users
nav_order: 1
parent: Development
permalink: /en/dev/users/
---

# User configuration
{:.no_toc}

* TOC
{:toc}

The users window is opened from the main menu with `More -> Users`, or from the
Users button at the foot of the section rail. It is available only to an
account holding the configure right.

![]({{ '/img/users.png' | relative_url }})

Double-clicking a user row starts editing its properties: the name, the
description and the access rights.

To create a new user, choose `Create -> User` from the window's context menu.

To delete a user, choose `Delete` from the user context menu.

To change a password, choose `Set password` from the user context menu. Your
own account requires the current password; someone else's (an administrator
reset) does not. The server sets what a password must satisfy — see
[Password policy]({{ '/en/client/workbench/#password-policy' | relative_url }}).

## Access rights

An account's Rights property is two independent permissions:

<dl>

<dt>Control</dt>
<dd>Issuing control and setpoint commands, manual value entry, editing
limits.</dd>

<dt>Configure</dt>
<dd>Creating, changing and deleting objects, devices and accounts.</dd>

</dl>

Their combinations give the four familiar values:

| Rights | Control functions and setpoints | Configuration editing |
|:---|:---:|:---:|
| 0 - Executive / viewer | No | No |
| 1 - SCADA engineer | No | Yes |
| 2 - Dispatcher | Yes | No |
| 3 - Administrator | Yes | Yes |

## Roles

The server does not check requests against those two bits directly. It checks
**OPC UA roles**, derived from them:

* every authenticated account gets the `Observer` role — reading values,
  history and events
* the Control right adds `Operator` — writing values and calling methods
* the Configure right adds `Engineer`, `Supervisor`, `ConfigureAdmin` and
  `SecurityAdmin` — the full set, including adding and deleting nodes
* an anonymous session gets the `Anonymous` role alone

An account may hold several roles at once, and their permissions combine. It is
the roles, not the pair of bits, that the
[Users]({{ '/en/client/workbench/#users' | relative_url }}) window and the
workbench's Access rights panel show; the panel derives from them what the
account may view, control and configure.

Role membership can be inspected in the
[Roles]({{ '/en/client/workbench/#roles' | relative_url }}) window. It is
read-only: changing a role's membership is a privileged operation performed on
the server.

Every action on accounts, passwords and role membership — successful or refused
— is recorded in the
[audit log]({{ '/en/client/workbench/#audit-log' | relative_url }}).

## Translation status

This English page is a direct translation of the current Russian page.
