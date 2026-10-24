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
account holding the Configure right (the `ConfigureAdmin` role).

![]({{ '/img/users.png' | relative_url }})

Double-clicking a user row starts editing its properties: the name, the
description and the permissions. In this version the Permissions
property grants nothing — see [Access rights](#access-rights).

To create a new user, choose `Create -> User` from the window's context menu.

To delete a user, choose `Delete` from the user context menu.

To change a password, choose `Set password` from the user context menu. Your
own account requires the current password; someone else's (an administrator
reset) does not. The server sets what a password must satisfy — see
[Password policy]({{ '/en/client/workbench/#password-policy' | relative_url }}).

**For the administrator:**

* **Never change or delete the `svc` user.** It is the service account the
  Server processes connect to each other with; changing it breaks the links
  between them (see [The svc account]({{ '/en/server/' | relative_url }}#svc)).
* **The `root` user in the list of a new installation is not the built-in
  `root` account.** It comes with the demo project and can never sign in:
  signing in as `root` always uses the built-in account. Changing or
  deleting this user does not affect the built-in account.
* **A `root` password set in this window does not last.** Each Server
  process writes the password given to `scada-setup apply` as
  `--root-password` again every time it starts. Change the root password
  with `scada-setup` instead (see
  [Root password]({{ '/en/getting-started/' | relative_url }}#root-password)).
* **The built-in `root` account allows one session at a time.** When `root`
  signs in a second time, from another workstation for example, the Client
  says the user name is already in use and offers to disconnect the open
  session; answering yes disconnects the first `root` session. Give each
  administrator a user of their own rather than sharing `root`.

## Access rights {#access-rights}

What an account may do after signing in is decided by the server from the
**OPC UA roles** it is a member of. Two roles carry the rights:

<dl>

<dt>Operator — the Control right</dt>
<dd>Issuing control and setpoint commands, manual value entry, editing
limits.</dd>

<dt>ConfigureAdmin — the Configure right</dt>
<dd>Creating, changing and deleting objects, devices and accounts. It does
not grant control commands, manual value entry or limit changes.</dd>

</dl>

Their combinations give the four familiar levels:

| Level | Account's roles | Control, manual input and limits | Configuration editing |
|:---|:---|:---:|:---:|
| 0 - Executive / viewer | none | No | No |
| 1 - SCADA engineer | `ConfigureAdmin` | No | Yes |
| 2 - Dispatcher | `Operator` | Yes | No |
| 3 - Administrator | `Operator` and `ConfigureAdmin` | Yes | Yes |

Control and setpoint commands, manual value entry and limit changes need the
Control right. The limits of a TIT object also appear in its properties (the
Limits group of the Properties window), but without the Control right they are
read-only there. When a user without that right pastes a copied TIT object,
the limits are not carried over: the object is created without them.

The configuration, conversely, is changed only with the Configure right. The
one exception is a device's Enable and Disable commands: taking a device out
of service and back needs only the Control right.

**WARNING: in this version an account's Permissions property (Russian UI:
«Права») grants nothing.** You can still enter a value (0–3), but at sign-in
the server grants rights from roles alone. A user created in the Client with
Permissions = 3 can only view data after signing in: the Roles column of the
Users window shows None («Нет»). This version has no way in the Client to make
a new account a member of `Operator` or `ConfigureAdmin` — the Roles window is
read-only, and the `scada-setup` installer assigns no roles. If a new user
needs control or configuration rights, contact Telecontrol
(mail@telecontrol.ru) in advance, before the site goes into service.

Accounts that existed before the upgrade to this version, including those
migrated from version 2.5, keep their rights: on its first start the server
converts their Permissions value, once, into membership of `Operator` and
`ConfigureAdmin`. The `root` account keeps full rights regardless of roles.

## Roles {#roles}

The roles the server grants a session:

* every authenticated account gets the `Observer` role — reading values,
  history and events
* `Operator` — writing values and calling methods, including control
  commands, manual value entry and limit changes; this role does not change
  the configuration, except to enable or disable a device
* `ConfigureAdmin` also gives the session `Engineer`, `Supervisor` and
  `SecurityAdmin` — changing the configuration, including adding and deleting
  nodes, but not writing object values or their limits and not issuing
  control commands: the server allows those to the `Operator` role alone
* an anonymous session gets the `Anonymous` role alone

An account may hold several roles at once, and their permissions combine. It is
the roles that the
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
