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

Double-clicking a user row starts editing its properties: the name and the
description. A user's rights come from roles — see
[Access rights](#access-rights).

To create a new user, choose `Create -> User` from the window's context menu.

To delete a user, choose `Delete` from the user context menu.

To stop a user signing in without deleting the account, choose
`Disable Account` from the user context menu; `Enable Account` lets it sign
in again. The Status column shows which. A disabled user's session that is
already open is not closed.

To assign roles to a user, choose `Roles...` from the user context menu (see
[Assigning roles](#assign-roles)).

To change a password, choose `Set password` from the user context menu. Your
own account requires the current password; someone else's (an administrator
reset) does not. The server sets what a password must satisfy — see
[Password policy]({{ '/en/client/workbench/#password-policy' | relative_url }}).

**For the administrator:**

* **The `svc` user is the service account** the Server processes connect to
  each other with. The server does not let the Client change it: it cannot
  be deleted, renamed or disabled, nor its password or roles changed, and
  `Delete` is not offered for it. Its password is changed with
  `scada-setup set-password` on every Server computer (see
  [Changing the svc password]({{ '/en/server/' | relative_url }}#svc-rotate)).
* **The `root` user in the demo project's list is not the built-in `root`
  account.** It exists only in the
  [demo project]({{ '/en/getting-started/' | relative_url }}#demo) and can
  never sign in:
  signing in as `root` always uses the built-in account. Changing or
  deleting this user does not affect the built-in account.
* **The built-in `root` account's password is not changed in this
  window.** On a Server installed with `scada-setup` the root password is
  kept in the computer's encrypted
  [password file]({{ '/en/server/' | relative_url }}#stored-passwords), and
  each Server process writes it again every time it starts. So the Server
  refuses a root password change made from the Client, and the Client
  reports the refusal in the event journal, naming the command that changes
  it. Change the root password with
  `scada-setup set-password --root-password <new password>` on every Server
  computer (see
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

### Assigning roles {#assign-roles}

An administrator — an account with the Configure right — assigns an
account's roles. In the Users window, select the user and choose `Roles...`
from its context menu. The window that opens has the roles the user already
holds checked; check the ones needed (for example `Operator` and
`ConfigureAdmin` for level 3), clear the rest and press OK. The server
records every change in the [audit log]({{ '/en/client/workbench/#audit-log' | relative_url }}).

The change takes effect at the user's next sign-in: a session already open
keeps its previous rights.

Roles follow the account: when a user is renamed the server moves its roles
to the new name, and when a user is deleted it removes them — an account
created later with the same name receives none. The server does the same
with the user's profile (the pages and settings saved on the server).

A new account holds no roles and can only view data after signing in. The
Permissions property (Russian UI: «Права», 0–3), which set the level in
earlier versions, is no longer in the property window: only roles grant
rights.

Accounts that existed before the upgrade to this version, including those
migrated from version 2.5, keep their rights: on its first start the server
converts their former Permissions value, once, into membership of `Operator` and
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

The [Roles]({{ '/en/client/workbench/#roles' | relative_url }}) window shows
role membership; it is changed with `Roles...` on a user (see
[Assigning roles](#assign-roles)).

Sign-ins and every action on accounts, passwords and role membership —
successful or refused — are recorded in the
[audit log]({{ '/en/client/workbench/#audit-log' | relative_url }}).
