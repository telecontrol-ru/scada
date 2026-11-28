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

Creating, changing and deleting users, assigning roles and setting another
user's password are open to an account holding the `ConfigureAdmin` role.
Telecontrol supplies the first such account with the service (see
[What we do]({{ '/en/server/' | relative_url }}#service)); create the other
users and assign their roles under it.

![]({{ '/img/users.png' | relative_url }})

Double-clicking a user row starts editing its properties: the name and the
description. A user's rights come from roles — see
[Access rights](#access-rights).

To create a new user, choose `Create -> User` from the window's context menu.

To delete a user, choose `Delete` from the user context menu.

To stop a user signing in without deleting the account, choose
`Disable Account` from the user context menu; `Enable Account` lets it sign
in again. The Status column shows which. A disabled user's session that is
already open is not closed. A disabled user who tries to sign in gets the
same refusal as for a wrong password — "Wrong user name or password" — so it
does not show that the account is disabled.

### Cutting a user off at once {#cut-off}

Neither disabling an account nor removing its roles closes a session that is
already open: disabling only refuses the next sign-in, and a role change takes
effect at the next sign-in. To stop a user working at once:

* **delete the user** — the server closes all of their sessions at once; the
  account's roles and profile go with it, so a user created again with the
  same name starts with no roles;
* or disable the account and **ask Telecontrol to restart the Server's
  `scada-proxy` process**: the restart closes every user's session, and the
  disabled user cannot sign in again.

To assign roles to a user, choose `Roles...` from the user context menu (see
[Assigning roles](#assign-roles)).

Any user signed in with their own account (not anonymously) changes their
own password with *Change Password...* (*Сменить пароль…*) in the *Settings*
menu or in the command palette (*Ctrl+K*), whatever their rights; the window
asks for the current password (see
[Changing a password]({{ '/en/client/workbench/#set-password' | relative_url }})).

![The Change Password window: the current password, the server's password-policy rules, one rule not met]({{ '/img/change-password.png' | relative_url }})

*Changing your own password: the current password, the new password and its repeat. The upper-case rule is not met, so OK is unavailable. When an administrator resets another user's password, the Current field is not shown.*

To set another user's password, choose `Set Password...` (*Задать пароль…*)
from the user context menu. The command is available only with the Configure right and
only when a user is selected; the Users window, too, opens only with that
right. Your own account requires the current password; someone else's (an
administrator reset) does not. The server sets what a password must satisfy —
see [Password policy]({{ '/en/client/workbench/#password-policy' | relative_url }}).

![Password policy window]({{ '/img/password-policy.png' | relative_url }})

*The Password policy window: this installation allows 8 to 64 characters, requires an upper-case letter, a lower-case letter and a digit, and adds its own rule in words.*

A user without the Configure right — a Dispatcher (level 2) or a Manager
(level 0), for example — changes their own password with *Change Password...*.
If they have forgotten the current password, they ask the administrator, who
sets a new one with `Set Password...`.

**For the administrator:**

* **The `svc` user is the service account** the Server processes connect to
  each other with. The server does not let the Client change it: it cannot
  be deleted, renamed or disabled, nor its password or roles changed, and
  `Delete` is not offered for it. Telecontrol changes its password; the
  `svc` password for the site gateway comes with the gateway's parameters
  (see [Site gateway]({{ '/en/server/' | relative_url }}#gateway)).
* **The `root` user in the demo project's list is not the built-in `root`
  account.** It exists only in the
  [demo project]({{ '/en/getting-started/' | relative_url }}#demo) and can
  never sign in:
  signing in as `root` always uses the built-in account. Changing or
  deleting this user does not affect the built-in account.
* **The built-in `root` account's password is not changed in this
  window.** The Server refuses a root password change made from the Client,
  and the Client reports the refusal in the event journal. On the hosted
  Server the root password is set and kept by Telecontrol.
* **Every account created in version 2.6, and the built-in `root`, allows
  one session at a time.** Several sessions at once are allowed only to
  accounts migrated from version 2.5 with that permission; a user's
  «Множество сессий» (Multiple sessions) property has no effect in version
  2.6. When the same name signs in a second time, from another workstation
  for example, the Client says the user name is already in use and offers to
  disconnect the open session; answering yes disconnects the first session.
  «Нет» (No) is the default button in that question, so *Enter* leaves the
  open session alone and does not sign in. Give each dispatcher and each administrator a user of their own rather than
  having several people sign in under one name, `root` included.

## Access rights {#access-rights}

What an account may do after signing in is decided by the server from the
**OPC UA roles** it is a member of. Two roles carry the rights:

<dl>

<dt>Operator — the Control right</dt>
<dd>Issuing control and setpoint commands, manual value entry, editing
limits.</dd>

<dt>ConfigureAdmin — the Configure right</dt>
<dd>Creating, changing and deleting objects and devices. It does not grant
control commands, manual value entry or limit changes. It grants user
management.</dd>

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

An administrator — an account holding the `ConfigureAdmin` role — assigns an
account's roles. In the Users window, select the user and choose `Roles...`
from its context menu. The window that opens has the roles the user already
holds checked; check the ones needed (for example `Operator` and
`ConfigureAdmin` for level 3), clear the rest and press OK. The server
records every change in the [audit log]({{ '/en/client/workbench/#audit-log' | relative_url }}).

![Account roles window]({{ '/img/account-roles.png' | relative_url }})

*The window opened by `Roles...`: both roles are checked for the user «Администратор» (Administrator).*

The change takes effect at the user's next sign-in: a session already open
keeps its previous rights (to end it at once, see [above](#cut-off)).

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
  control commands: the server allows those to the `Operator` role alone;
  it also grants user management
* an anonymous session gets the `Anonymous` role alone

An account may hold several roles at once, and their permissions combine. It is
the roles that the
[Users]({{ '/en/client/workbench/#users' | relative_url }}) window and the
Inspector's Access rights section show; the section derives from them what the
account may view, control and configure.

![Access rights panel]({{ '/img/users-rbac.png' | relative_url }})

*The Access rights panel for the user «Администратор» (Administrator): the roles held and the permissions derived from them.*

The [Roles]({{ '/en/client/workbench/#roles' | relative_url }}) window shows
role membership; it is changed with `Roles...` on a user (see
[Assigning roles](#assign-roles)).

![Roles window]({{ '/img/roles.png' | relative_url }})

*The Roles window: the members of each role.*

Sign-ins and every action on accounts, passwords and role membership —
successful or refused — are recorded in the
[audit log]({{ '/en/client/workbench/#audit-log' | relative_url }}).

![Audit log window]({{ '/img/audit-log.png' | relative_url }})

*The Audit log window: sign-ins and account actions; a refused action is marked in the "Result" column.*
