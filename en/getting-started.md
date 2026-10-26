---
title: Getting started
nav_order: 2
permalink: /en/getting-started/
---

# Getting started
{:.no_toc}

* TOC
{:toc}

This page describes version 2.6, in which the Server is a set of separate
processes (see [Server processes]({{ '/en/architecture/' | relative_url }}#tiers)).

## System requirements

* Windows 10 or newer (Server and Client). Installing the Server on Linux
  is available on request (see [Installation on Linux](#linux))
* Windows administrator rights to install and set up the Server
* A TCP/IP network between the site's computers; Clients connect to the
  `scada-proxy` process on port 2000 (see [Network preparation](#network))
* A license file issued for the Server processes you need (see [License](#license))

## Download {#download}

Distributions are published on the
[Telecontrol SCADA releases page on GitHub](https://github.com/alexsmn/scada-client/releases/latest).

**WARNING:** the release published today, 2.5.7, predates version 2.6: it
installs the Server as a single *Telecontrol SCADA Server* service and does
not contain the separate 2.6 processes. The earlier rules apply to it: the
*Telecontrol SCADA Server* service, a HASP or Guardant hardware key, and the
configuration in `%ProgramData%\Telecontrol\SCADA Server\Configuration`.

## Choose the Server processes {#choose}

A version 2.6 Server is always installed as several processes: the protocol
processes receive their configuration from `scada-config` and keep none of
their own, so a protocol process cannot run without `scada-config`.

The smallest set `scada-setup` builds is:

* `scada-config`, which holds the configuration;
* one or more protocol processes (`scada-modbus`, `scada-iec104`,
  `scada-iec61850`, and on Windows also `scada-opc` and `scada-vidicon`);
* `scada-filesystem` — without it `scada-setup apply` prints a warning and
  the [server-side file system]({{ '/en/server/' | relative_url }}#filesystem)
  (displays stored on the Server) is unavailable;
* `scada-proxy`, which the Clients connect to.

Add `scada-historian` to archive values and events; without it there is no
archive.

**The license must name every one of these processes**, `config`,
`filesystem` and `proxy` included, not only the protocol processes: a process
the license does not name stops right after it starts, and
`scada-setup apply` refuses to install it.

All the processes may run on one computer or be spread over several.
**`scada-config`, `scada-proxy`, `scada-historian` and `scada-filesystem`
always go on one and the same computer — the central one**; the protocol
processes go on it too or on other computers of the site. What each process
does, and the start order, are described in
[Server processes]({{ '/en/architecture/' | relative_url }}#tiers).

**Each protocol process is installed on one computer of the site only, and
serves every device of its protocol.** It receives the whole configuration
from `scada-config`: in this version the devices of one protocol cannot be
split between computers. Different protocol processes may go on different
computers (for example `scada-modbus` on one and `scada-iec104` on another).

**WARNING:** do not install the same protocol process (for example
`scada-iec104`) on two computers: both processes would connect to every
device of that protocol. Choose one computer for each process, one from
which every device of its protocol can be reached.

## Installation on Windows

One installer carries every Server process and the `scada-setup` tool. You
choose which processes run on a computer with the `--tiers` option; the
license decides which of them are allowed.

**Run `scada-setup` from an elevated command prompt, and always by its full
path** — `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe"`. The
installer does not add that folder to `PATH`, and the tool finds its
templates relative to the path it was invoked by: typed as a bare
`scada-setup`, even from the `bin` folder, it may not find them.

1. Install the package:

   ```bat
   msiexec /i telecontrol-scada-<version>.msi /qn /norestart /l*v install.log
   ```

   `/qn` installs the package without any windows, `/norestart` keeps
   Windows Installer from restarting the computer by itself, and
   `/l*v install.log` writes a detailed installation log to `install.log`,
   which is what an installation error is diagnosed from (these are general
   Windows Installer options).

2. Put the license file at
   `%ProgramData%\Telecontrol\SCADA Server\license.json`.

3. Decide which processes run on this computer, and
   [write down the computer's parameters](#host-parameters).

4. Run:

   ```bat
   "C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" apply --tiers config,historian,filesystem,iec104,proxy --svc-password <password> --root-password <root password>
   ```

   In `--tiers`, list this computer's processes (the example has every
   process on one computer, with IEC 60870-5-104). `<password>` is the
   password of the `svc` service account the processes use to connect to each
   other. It must be the same on every computer of the site, and **it cannot
   be changed later** (see
   [The svc account]({{ '/en/server/' | relative_url }}#svc)).
   `<root password>` is the password of the built-in `root` account; see
   [Root password](#root-password).

`apply` writes each process's parameter file
`%ProgramData%\Telecontrol\SCADA Server\<process>\server.json` (the
folder of `scada-filesystem` is named `filestore`), creates the
[Server certificate]({{ '/en/server/' | relative_url }}#opcua-certificate) in
`C:\Program Files\Telecontrol SCADA\data\Certificates` unless one is already
there, creates the configuration databases (never overwriting an existing
one), registers one Windows service per process, and starts them in the
right order. To check the result:

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" status
```

In `scada-setup`'s messages the processes are called *tiers*: the line
`Entitled tiers: …` lists the processes the license allows, and below it the
state of each process's service is printed (`SERVICE_RUNNING` means it is
running).

**WARNING: the `svc` and `root` passwords are stored in plain text.**
`apply` writes them into the Windows service settings — the registry, in the
`Environment` values of the
`HKLM\SYSTEM\CurrentControlSet\Services\TelecontrolScada<Process>` keys.
Assume that anyone who signs in to Windows on that computer can read them:
keep untrusted users from signing in to the Server computers, and do not
make a Server computer an operator workstation. The Server installer puts
the Client on the computer too (see [Installing the Client](#client-install)).

**Several computers.** Set up the central computer first, then the computers
running protocol processes, giving them the central computer's address:

```bat
rem Central computer:
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" apply --tiers config,historian,filesystem,proxy --svc-password <password> --root-password <root password>
rem Computer running protocol processes:
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" apply --tiers modbus,iec104 --central 10.0.0.10 --advertise 10.0.0.11 --svc-password <password>
```

The protocol processes need no root password: `scada-config` keeps their
accounts. `--central` is required on a computer without `scada-config`.

**Decide `--advertise` before the first `apply` on each protocol computer.**
A computer set up with `--central` reports its *computer name* to
`scada-proxy`, and `scada-proxy` connects to that computer's processes by
that name. Unless the central computer resolves the name of every protocol
computer (check with `ping <computer name>` on the central computer), give
each protocol computer its own IP address as `--advertise`, as in the example
(10.0.0.11 is the protocol computer's own address). Otherwise the devices of
that computer never appear in the Client. The
[Server certificate]({{ '/en/server/' | relative_url }}#opcua-certificate)
records the computer's addresses only when it is created: if you add
`--advertise` later, also replace the certificate so that it carries the new
address.

The remaining links between processes are set up automatically. All
`scada-setup` commands are described in the
[Server]({{ '/en/server/' | relative_url }}#scada-setup) section.

How to install the Client on the operator workstations is described below,
in [Installing the Client](#client-install).

### The computer's parameters {#host-parameters}

`scada-setup` does not remember the options it was run with. **Write down,
for each computer,** and keep with the passwords:

* `--tiers` — this computer's processes;
* `--central` — the central computer's address (on a computer without
  `scada-config`);
* `--advertise` — if you gave one;
* `--license` — if the license file is not at
  `%ProgramData%\Telecontrol\SCADA Server\license.json`;
* `--data-root` and `--install-root` — if you gave a non-standard data
  folder or installation folder;
* the `svc` password and the `root` password.

**Give these options to every `apply` and `start` on that computer** (and
the passwords to `apply`), upgrades and restores included:

* without `--tiers` both commands take **every** process in the license:
  `apply` installs processes that do not belong on the computer, and `start`
  stops with an error at the first process whose service the computer does
  not have, leaving the processes after it unstarted;
* without `--central`, on a computer without `scada-config`, both commands
  refuse to run;
* without `--license` both commands look for the license at
  `%ProgramData%\Telecontrol\SCADA Server\license.json`, and `apply` writes
  that path into the parameter files (but not into the services);
* give `--license` as a full path, beginning with the drive letter:
  `scada-setup` hands the path to the processes as written, and a relative
  path does not lead them to the same file.

`stop`, `status` and `remove` without `--tiers` act on every Server service
the computer has, so they need no `--tiers` or `--central`. `status`,
however, checks the license at `<data folder>\license.json` (by default
`%ProgramData%\Telecontrol\SCADA Server\license.json`): if the license file
is elsewhere, give it `--license` (and `--data-root` if the data folder is
not the standard one), or it prints `License: not available` instead of the
license details.

**If `apply` was run without `--tiers`** and installed processes that do not
belong, remove their services (the processes' data stays):

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" remove --tiers <the extra processes, comma-separated>
```

### Installing the Client {#client-install}

The [releases page](#download) has no separate Client installer: the Client
is part of the same `telecontrol-scada-<version>.msi` package as the Server.
The installer puts the Client on every computer the package is installed on,
and creates a *Клиент* (Client) shortcut on the desktop and in the
*Start — ОИК Телеконтроль* menu.

* **On an operator workstation**, install the same package with the same
  command,
  `msiexec /i telecontrol-scada-<version>.msi /qn /norestart /l*v install.log`,
  and **do not run `scada-setup`**: only `scada-setup` creates the Server
  process services, so without it no Server process runs on that computer.
  A workstation needs no license file.
* **On a Server computer** the Client is installed as well. Do not use it as
  an operator workstation (see the password warning above). If the
  administrator does not need the Client on that computer, delete the
  *Клиент* shortcut from the desktop.

**WARNING:** if Telecontrol has given you a separate Client package, do not
install it on a Server computer, nor the Server package on a computer with
such a Client, without checking the procedure with Telecontrol
(mail@telecontrol.ru): the packages share one Windows Installer upgrade code,
so installing one of them may remove the other. This behaviour has not been
verified.

### Displaying schematics {#displays}

The version 2.6 Client renders Modus schematics (`.sde` and `.xsde` files)
itself, through a display module that has to be in the Client's folder,
beside its executable. The ActiveXeme component is not used by the version
2.6 Client. Without the module, a display window shows the message "No
display runtime is installed." with the reason. Editing schematics still
needs the Modus graphics editor.

## Installation on Linux {#linux}

The Server processes run on Linux, but this version has neither a Linux
package nor a tool that prepares a working installation: on Linux
`scada-setup` only writes parameter files — it does not create the `svc`
service account or the certificate, and does not set the passwords.
**Installing the Server on Linux is available on request** — contact
Telecontrol (mail@telecontrol.ru).

The graphical Client is not supported on Linux.

## License {#license}

The license is a signed `license.json` file listing the processes purchased
and its validity period. The same file goes on every computer of the site. A
process the license does not name stops right after it starts. A license
whose validity period has not started yet is accepted neither by the
processes nor by `scada-setup`.

**Expiry.** `scada-setup status` shows when the license ends (the line
`License: … (expires …)`; an expired one shows `OUTSIDE VALIDITY WINDOW`).
Check it yourself: the Server warns of the coming expiry only as system events
in the Client, during the last 30 days. Once the license has expired, the
processes keep running but refuse Client requests until the license is
replaced.

**WARNING:** with an expired license, `scada-setup` treats all nine
processes as licensed: `apply` without `--tiers` installs every one of them
on the computer. Always give `--tiers`.

**Replacing the license file.** Running processes re-read the file every 5
seconds and pick up a new license without a restart. So replace the file in
one step: copy the new license into the same folder under a temporary name,
then rename it to `license.json` over the old file:

```bat
copy new-license.json "%ProgramData%\Telecontrol\SCADA Server\license.new"
move /y "%ProgramData%\Telecontrol\SCADA Server\license.new" "%ProgramData%\Telecontrol\SCADA Server\license.json"
```

**WARNING:** if the file is missing or only partly written when a process
checks it (for example while it is being copied over the old one), the
process concludes there is no license and stops. Windows does not restart
such a service: once the file is in place, start the processes with `start`
and the [computer's parameters](#host-parameters):

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" start --tiers <this computer's processes> [--central <address>] [--license <path>]
```

**Adding a process.** Replace the file with the new license on every
computer. On the computer that will run the new process, stop the processes
(`scada-setup stop`) and run `scada-setup apply` with that computer's full
process list in `--tiers`, the new one included, and the same other options
as at installation: `apply` does not restart running services (see
[Re-running apply]({{ '/en/server/' | relative_url }}#reapply)). Write the
new list down.

Parameter files written by `scada-setup` already contain
`"license": {"require_gcp_binding": false}`. **If you write a parameter file by
hand and the Server does not run on Google Cloud, set it yourself** —
otherwise the process cannot verify its license and serves no requests. See
[Licensing]({{ '/en/server/' | relative_url }}#licensing).

## Root password

The built-in `root` account has all rights. Its password is set by the
`--root-password` option of `scada-setup apply` (or the
`SCADA_SETUP_ROOT_PASSWORD` environment variable). On a computer running at
least one of `scada-config`, `scada-proxy`, `scada-historian` and
`scada-filesystem`, `apply` refuses to run without it: each of those processes
has its own `root` account, which would otherwise accept an empty password.

`scada-setup` stores the password in the Windows service settings of those
processes rather than in the parameter files, and the processes write it again
on every start. So:

* **to change the root password, stop the processes (`scada-setup stop`)
  and run `scada-setup apply` with the new `--root-password`** — `apply` does
  not restart running processes, and without `stop` they would keep accepting
  the old password. A password changed from the Client is replaced by the one
  given to `apply` the next time the process starts;
* give the current root password on every later `apply`, upgrades included.

See [Root password]({{ '/en/server/' | relative_url }}#root-password).

## Network preparation {#network}

`scada-setup` does not create firewall rules — open the inbound ports by
hand:

* **for the Client workstations** — TCP port 2000 on the central computer
  (the one running `scada-proxy`);
* **when the processes run on several computers:**
  * on the central computer — ports 4840 (`scada-proxy`) and 4841
    (`scada-config`) for the computers running protocol processes;
  * on each computer running protocol processes — the OPC UA port of each of
    its processes (from the table below) for the central computer:
    `scada-proxy` connects to them.

When every process runs on one computer, only port 2000 needs opening.

The rules can be created from an elevated command prompt (replace the
addresses in the example with your computers'; `remoteip` takes them
comma-separated):

```bat
rem Central computer: Clients (may be limited to the workstations' addresses with remoteip=...)
netsh advfirewall firewall add rule name="Telecontrol SCADA Clients" dir=in action=allow protocol=TCP localport=2000
rem Central computer, when there are other Server computers (here 10.0.0.11 and 10.0.0.12):
netsh advfirewall firewall add rule name="Telecontrol SCADA OPC UA" dir=in action=allow protocol=TCP localport=4840,4841 remoteip=10.0.0.11,10.0.0.12
rem Computer running scada-modbus and scada-iec104 (the central computer is 10.0.0.10):
netsh advfirewall firewall add rule name="Telecontrol SCADA OPC UA" dir=in action=allow protocol=TCP localport=4843,4844 remoteip=10.0.0.10
```

**Links that accept connections.** When a link works passively — its
Transport is of type TCP Server and the SCADA waits to be connected to (for
example [retransmission to a dispatch centre]({{ '/en/dev/devices/' | relative_url }}#retransmission)
over IEC 60870-5-104, usually port 2404) — open its port on the computer of
its protocol process, for the addresses that must connect only.

| Process | OPC UA | Clients |
|---|:-:|:-:|
| `scada-proxy` | 4840 | 2000 |
| `scada-config` | 4841 | 2001 |
| `scada-historian` | 4842 | 2002 |
| `scada-modbus` | 4843 | 2003 |
| `scada-iec104` | 4844 | 2004 |
| `scada-iec61850` | 4845 | 2005 |
| `scada-filesystem` | 4846 | 2006 |
| `scada-opc` | 4847 | 2007 |
| `scada-vidicon` | 4848 | 2008 |

**WARNING: OPC UA ports 4840–4848 must be reachable from the site's computers
only — in this version the firewall is their only protection.** The processes
connect to each other unencrypted, register with `scada-proxy` and
`scada-config` without authentication, and anonymous OPC UA sign-in is always
offered. A computer that reaches these ports can connect to the Server
processes or pose as one of them. If an external OPC UA system must connect
to the Server, allow it port 4840 from its address only (see
[OPC UA server]({{ '/en/server/' | relative_url }}#opcua)).

Ports 2001–2008 of the other processes accept user sign-ins too, but Clients
do not need them: keep them closed.

**WARNING: never open port 2006 (`scada-filesystem`).** `scada-filesystem`
keeps its own copy of the configuration, and on a new installation — and
after a [migration from version 2.5](#upgrade-2-5), which does not replace
it — that copy is the demo database, whose users «Клиент 1» … «Клиент 10»
and `guest` have no passwords. On a new installation, replace it along with
the other copies as described in [Preparing the project](#project).

## Preparing the project {#project}

**The configuration of a new installation is a demo project.** The
databases `apply` creates are copies of the demo configuration shipped with
the installer: 41 analog and 52 discrete objects, emulation signals, two
enabled IEC 60870-5-104 links (one of them accepts connections on port 2404
of this computer), two archives, and the users «Клиент 1» … «Клиент 10» and
`guest`, which have no passwords set. The demo project's user list also has
a `root` user. It is not the built-in `root` account: signing in as `root`
always uses the built-in account, with the password given as
`--root-password`, and this user can never sign in. **Do not change or
delete it thinking it is the real `root`**: neither the password nor the
rights of the built-in account depend on it. Until the configuration is
replaced,
the `scada-iec104` process, if installed, takes port 2404 and works with the
demo devices. **Before going live, replace the configuration with the
project's** (below).

The configuration is kept in four copies, one per process, each in its
process's `Configuration` folder: `scada-config` serves the configuration to
the protocol processes, `scada-proxy` checks Client user names and passwords
against it, `scada-historian` reads the archive list and the archive assigned
to each object from it, and `scada-filesystem` checks the sign-ins on its
port 2006 against it. Every copy starts as the demo project, so **replace all
four**.

**WARNING:** deleting the demo devices, objects and users in the Client is
not a dependable way to remove them in this version: it has not been
verified that a change made in the Client reaches every copy. If you go that
way anyway, check afterwards that nothing listens on port 2404 any more
(`netstat -ano | findstr :2404` on the computer of `scada-iec104` prints
nothing) and that «Клиент 1» can no longer sign in; if either check fails,
replace the configuration as below.

To put a ready project configuration database (a version 2.6
`configuration.sqlite3`) in place, on the central computer:

1. Stop the processes:
   `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop`.
2. Copy the file into the `config\Configuration`, `proxy\Configuration`,
   `historian\Configuration` and `filestore\Configuration` folders under
   `%ProgramData%\Telecontrol\SCADA Server` (`filestore` is the folder of
   `scada-filesystem`), replacing the databases `apply` created.
3. Run `scada-setup apply` with the same
   [computer's parameters](#host-parameters) and passwords as at
   installation. It keeps the copied databases and adds the `svc` service
   account (id 100) to them, without which the processes cannot connect to
   each other. **A project user with id 100 is replaced by the `svc`
   account.** A database taken from another version 2.6 site keeps that
   site's `svc` password: this site then needs the same `svc` password, or
   the processes cannot connect to each other.

Move a version 2.5 Server's configuration with `scada-setup migrate` instead:
it also carries over the user passwords version 2.5 kept in a separate file
(see [Upgrading from version 2.5](#upgrade-2-5)).

On each workstation, copy the schematic files (`.sde`) to
`%ProgramData%\Telecontrol\SCADA Client`, or upload them to the
[server-side file system]({{ '/en/server/' | relative_url }}#filesystem)
if that feature is used.

To explore the system without field equipment, give objects
[emulation]({{ '/en/architecture/' | relative_url }}#emulation).

For project engineering details, see [Development]({{ '/en/development/' | relative_url }}).

## Start the Server

The process services start automatically with Windows; a user sign-in is not
required. When a process fails, Windows restarts its service (see
[Windows services]({{ '/en/server/' | relative_url }}#services)).
`start` and `stop` start or stop all of the computer's processes in the right
order; `start` only with the [computer's parameters](#host-parameters):

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" start --tiers <this computer's processes> [--central <address>] [--license <path>]
```

For diagnostics, a process can be started in
[console mode]({{ '/en/server/' | relative_url }}#console).

## Client login {#client-start}

Start the Client from the desktop shortcut or the Start menu. The login dialog asks for SCADA credentials and, optionally, the target server name or IP address.

![]({{ '/img/client-login.png' | relative_url }})

For the first login, use `root` with the password given as
`--root-password` during installation.

The `Server` row has two fields. On the left is the list of server types
(shown only when the Client supports more than one type): choose
**"Telecontrol"**.

> **Caution.** The "OPC UA" type connects the Client over OPC UA. In the
> current version a Client connected with this type **does not reconnect by
> itself** after the connection is lost: restart the Client to restore it. Use
> the "Telecontrol" type to work with the SCADA Server.

On the right, enter the host name or IP address of the computer running
`scada-proxy` only if it is a different computer. Otherwise, leave the field
empty.

The "Security and certificates" disclosure (the security mode, the client
certificate and private key) appears only for the "OPC UA" type; with the
"Telecontrol" type there is nothing to fill in.

In the "Most secure available" and "Sign and encrypt" modes the Client checks
the Server's identity by its certificate:

* The Client's own certificate and private key are optional: if the fields are
  empty, the Client creates its own certificate on the first connection.
* The first time it meets a Server's certificate, the Client asks: "The server
  presented a certificate this computer has not trusted before", and shows its
  subject and SHA-256 fingerprint. Compare the fingerprint with the one the
  Server's administrator publishes, and answer *Yes* to trust the certificate
  and connect.
* If the server at the same address presents a *different* certificate, the
  Client warns: "WARNING: the server at this address presented a DIFFERENT
  certificate…". That is what an intercepted connection would look like: trust
  the new certificate only if the Server's administrator confirms it was
  replaced.

The certificates are kept in the `pki` folder of the Client's user data:
`%APPDATA%\Telecontrol\SCADA Client\pki` on Windows and
`~/Library/Application Support/Telecontrol/SCADA Client/pki` on macOS. To stop
trusting a Server, delete its certificate from the `trusted` subfolder.

If the `Sign in automatically next time` box is ticked, the Client stores the
name and password on this computer and does not wait for input in the
sign-in window at each start: it signs the last account straight in. The
sign-in window opened by *Disconnect from Server* and *Connect to Server...*
always waits for input.

> **Caution.** Do not tick this box on a shared operator workstation: at start
> the Client would sign in under the outgoing operator's account. To sign in
> under your own and clear the box, hold `Ctrl` (on macOS, `Option`) while
> starting the Client — the sign-in window opens with the box cleared — and
> sign in. You can also press *Cancel* while automatic sign-in is in progress
> (see [Automatic sign-in]({{ '/en/client/' | relative_url }}#auto-login)).

## First steps after login

**Until the configuration is replaced, what you see is the demo project**
(see [Preparing the project](#project)): its objects, devices and the users
«Клиент 1» … «Клиент 10» and `guest` are demo data. Replace the
configuration as described there before the system goes live.

After you sign in:

1. Open the object panel with `More -> Objects`. The object tree
   shows the current values. Double-clicking an object opens its
   [Graph]({{ '/en/client/graph/' | relative_url }}).
1. Open available displays from the
   [Display]({{ '/en/client/display/' | relative_url }}) menu.
1. Check equipment status with `More -> Equipment`. The icons to the left of
   the devices show the connection state.
1. Create user accounts with `More -> Users`, and work under them rather
   than as `root`. See
   [User configuration]({{ '/en/dev/users/' | relative_url }}). After
   creating a user, check straight away that you can sign in as that user;
   if you cannot, contact Telecontrol.

   **WARNING:** the user list contains the `svc` service account. Do not
   change or delete it: the Server processes connect to each other through
   it (see [The svc account]({{ '/en/server/' | relative_url }}#svc)).

For the main operator interface, continue with
[Client]({{ '/en/client/' | relative_url }}).

## Upgrading

These steps upgrade version 2.6 and later. A version 2.5 or earlier Server
was a single process with a single service, and its data has to be moved into
the version 2.6 processes — see [below](#upgrade-2-5).

**Before every upgrade, back up every Server computer** — see
[Backup]({{ '/en/server/' | relative_url }}#backup). That backup is the only
way back: the installer refuses to install an older version over a newer
one, so a failed upgrade is undone by reinstalling the older version and
restoring the backup (see
[Rolling back a failed upgrade]({{ '/en/server/' | relative_url }}#rollback-upgrade)).

**On the Server computers** — the central computer first, then each
computer running protocol processes — from an elevated command prompt:

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop
msiexec /i telecontrol-scada-<new version>.msi /qn /norestart /l*v install.log
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" apply --tiers <this computer's processes> [--central <address>] [--advertise <address>] [--license <path>] --svc-password <password> --root-password <root password>
```

Give `apply` the same [computer's parameters](#host-parameters) as at
installation, and the same `svc` password. The installer replaces only the
executables; `apply` rewrites the parameter files (hand edits to them are
lost) and leaves the data alone. On computers running only protocol
processes, `--root-password` may be omitted.

**On the operator workstations** install the new package only, with no
`scada-setup` commands (see [Installing the Client](#client-install)):

```bat
msiexec /i telecontrol-scada-<new version>.msi /qn /norestart /l*v install.log
```

### Upgrading from version 2.5 {#upgrade-2-5}

A version 2.5 Server ran as a single *Telecontrol SCADA Server* service and
used a hardware key. The version 2.6 installer replaces the version 2.5
program, so **check the migration plan before installing 2.6**: what blocks
the migration can only be fixed in version 2.5.

How to go back to version 2.5 is described in
[Rolling back to version 2.5]({{ '/en/server/' | relative_url }}#rollback-2-5).

On the computer where the 2.5 Server ran:

1. Obtain a version 2.6 license and put it at
   `%ProgramData%\Telecontrol\SCADA Server\license.json`.
2. Back up the `%ProgramData%\Telecontrol\SCADA Server` folder.
3. Unpack the 2.6 package into a temporary folder without installing it, and
   run `scada-setup migrate` from there — it changes nothing and prints the
   plan. Fix in version 2.5 whatever blocks the migration, and check again.
   The steps are in
   [Upgrading from version 2.5]({{ '/en/server/' | relative_url }}#upgrade-2-5).
4. Install the version 2.6 package
   (`msiexec /i telecontrol-scada-<version>.msi /qn /norestart /l*v install.log`).
5. From an elevated command prompt, run:

   ```bat
   "C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" migrate --execute --tiers config,historian,filesystem,iec104,proxy --svc-password <password> --root-password <root password>
   ```

   In `--tiers`, list this computer's processes: `config`, `historian`,
   `filesystem`, `proxy` and **a protocol process for every protocol** the
   version 2.5 devices use (in the example `iec104`; `modbus` for MODBUS,
   `iec61850` for IEC 61850). The command does not warn when one is missing,
   and no data is then collected from that protocol's devices.

   It removes the old service, copies the configuration, the users with their
   passwords, the history and the schematic files into the version 2.6
   process folders, and starts the processes as `apply` does (creating the
   Server certificate included). The version 2.5 root password is replaced by
   the one given as `--root-password` (see [Root password](#root-password)).
   **If the command fails after copying, do not run `migrate` again** —
   finish with `stop` and `apply` with the same `--tiers` and passwords (see
   [Upgrading from version 2.5]({{ '/en/server/' | relative_url }}#upgrade-2-5)).
6. Install the version 2.6 Client on **every** workstation (see
   [Displaying schematics](#displays)): whether a version 2.5 Client works
   with a 2.6 Server has not been verified.
7. Check the result from the Client.

The old `Configuration`, `History` and `FileSystem` folders are neither
changed nor deleted.

The migration does not carry the configuration into `scada-filesystem`'s
copy (`filestore\Configuration`): it stays the demo database, with the
password-less demo users. Never open its port 2006 (see
[Network preparation](#network)).

## Uninstalling {#uninstall}

Before uninstalling the program, remove the services with
`scada-setup remove --tiers <this computer's processes>`: the installer
removes neither the services, nor their registry settings with the `svc` and
`root` passwords, nor the data folders and the certificate's private key, nor
the firewall rules created in [Network preparation](#network).
Then uninstall the *ОИК Телеконтроль* program (publisher ООО Телеконтроль)
in *Control Panel — Programs and Features*. The steps are in
[Uninstalling the Server]({{ '/en/server/' | relative_url }}#uninstall).

## Troubleshooting

Run the `scada-setup` commands below by their full path from an elevated
command prompt — `status` included.

<dl>

<dt>A new <code>root</code> password or other <code>apply</code> options have no effect</dt>
<dd><code>apply</code> does not restart running services. Run
<code>scada-setup stop</code>, then <code>apply</code> (see
<a href="{{ '/en/server/' | relative_url }}#reapply">Re-running apply</a>).</dd>

<dt>Client cannot connect to the Server</dt>
<dd>Check that the <em>Telecontrol SCADA Proxy</em> service is running
(<code>scada-setup status</code> on its computer). Also verify that port 2000
is allowed by the firewall and reachable over the network.</dd>

<dt>A Server process stops right after starting</dt>
<dd>There is no valid license file, or the license does not include this
process, or one of the <a href="{{ '/en/server/' | relative_url }}#opcua-certificate">Server certificate</a>
files was deleted (the log shows <code>Can't open file</code>;
<code>scada-setup apply</code> then says which file is missing). The reason is
written to the <a href="{{ '/en/server/' | relative_url }}#logging">process
log</a>. See
<a href="{{ '/en/server/' | relative_url }}#licensing">Licensing</a>.</dd>

<dt>A service stops or keeps restarting, and the log shows nothing</dt>
<dd>Most likely the <code>server.json</code> parameter file has an error (for
example after a hand edit). The process reports it before it starts writing
its log — on the screen only. Start the process in
<a href="{{ '/en/server/' | relative_url }}#console">console mode</a> and
read the message.</dd>

<dt>Protocol processes get no configuration</dt>
<dd>If a protocol process's log shows <code>Bad_UserAccessDenied</code>, the
<code>svc</code> password on that computer differs from the central
computer's. Run <code>scada-setup stop</code> there, then <code>apply</code>
with the original <code>svc</code> password (see <a href="{{ '/en/server/' | relative_url }}#svc">The svc
account</a>).</dd>

<dt>The devices of a protocol computer never appear</dt>
<dd>The Client does not show the devices served by a computer running
protocol processes, although <code>scada-setup status</code> there shows them
running. <code>scada-proxy</code> connects to that computer by the name it
reported; if the central computer cannot resolve that name (check with
<code>ping &lt;computer name&gt;</code> on the central computer), run
<code>scada-setup stop</code> on the protocol computer, then <code>apply</code>
with its <a href="#host-parameters">computer's parameters</a> plus
<code>--advertise &lt;its IP address&gt;</code>, and write the option down. For
the new address to be in the
<a href="{{ '/en/server/' | relative_url }}#opcua-certificate">Server certificate</a>
too, delete both certificate files before that <code>apply</code>.
Also check that its firewall lets the central computer reach the OPC UA ports
of its processes (see <a href="#network">Network preparation</a>).</dd>

<dt>Every process stopped after the license file was replaced</dt>
<dd>The file was missing or only partly written when it was checked. Put a
valid file in place (see <a href="#license">Replacing the license file</a>)
and run <code>scada-setup start</code> with the
<a href="#host-parameters">computer's parameters</a>.</dd>

<dt><code>scada-setup start</code> stops with an error</dt>
<dd>It was run without <code>--tiers</code> (or without
<code>--central</code>) and is trying to start a process whose service the
computer does not have. Run it again with the
<a href="#host-parameters">computer's parameters</a>.</dd>

<dt>A process runs but refuses requests</dt>
<dd>The license is not verified or has expired (the expiry is in the
<code>scada-setup status</code> output). Outside Google Cloud, check that
<code>"license": {"require_gcp_binding": false}</code> is set; for an
expired license, replace the file — no restart is needed.</dd>

<dt>Values are no longer archived</dt>
<dd>After a protocol process's service restarts (for example
<em>Telecontrol SCADA IEC 104</em>), automatic restarts after a failure
included, its objects' values stop being archived. Restart the
<em>Telecontrol SCADA Historian</em> service. See
<a href="{{ '/en/server/' | relative_url }}#monitoring">Monitoring</a>.</dd>

<dt>Schematics do not open</dt>
<dd>If the display window says "No display runtime is installed.", the
display module is missing from the Client's folder — contact Telecontrol.
Otherwise, check that the schematic file is in
<em>%ProgramData%\Telecontrol\SCADA Client</em> or in the
<a href="{{ '/en/server/' | relative_url }}#filesystem">server-side file system</a>.</dd>

<dt>Object values are shown in gray</dt>
<dd>Gray value text means the value is not valid, for example because the
device is unreachable. Check the device state in the equipment panel
(<code>More -> Equipment</code>). A blinking yellow row background means
something else — the object has an unacknowledged event.</dd>

</dl>
