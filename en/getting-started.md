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

* Windows 10 or newer (Server and Client), or x86-64 Linux with systemd and
  glibc 2.38 or newer, such as Ubuntu 24.04 (Server; see
  [Installation on Linux](#linux))
* Windows administrator rights (`root` on Linux) to install and set up the
  Server
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

Different protocol processes may go on different computers (for example
`scada-modbus` on one and `scada-iec104` on another). **The same protocol
process may also be installed on several computers**, splitting the devices
of its protocol between them — for example, with an `scada-iec104` next to
each group of devices:

* a link's Computer property says which computer serves it (an IEC 61850
  device, which has no link, has the property itself). It holds the computer
  name `scada-setup` writes into that computer's configuration files — the
  Windows computer name or the `--host-name` value; letter case does not
  matter;
* the devices of a link are served by the same computer as the link;
* the links whose Computer is empty are served by the computer where
  `scada-setup apply` ran **without** the `--assigned-links-only` option.
  On every other computer running that process, run `apply` with
  `--assigned-links-only`: such a computer serves only the links assigned to
  it by name;
* to move a link to another computer, change its Computer property in the
  Client: the old computer closes the connection and the new one opens it,
  with no process restart.

Clients, the archive and retransmission work with the devices of every
computer through `scada-proxy`, as with one Server.

**WARNING:** among the computers running one protocol process,
`--assigned-links-only` must be given on all but one. If neither of two
computers has it, both open every link without a computer; if all have it,
nobody serves those links.

## Installation on Windows

One installer carries every Server process and the `scada-setup` tool. You
choose which processes run on a computer with the `--tiers` option; the
license decides which of them are allowed.

**Run `scada-setup` from an elevated command prompt** (`status` does not
need one). The installer does not add the program's folder to `PATH`, so the
examples call it by its full path,
`"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe"`; from that
folder, typing `scada-setup` is enough.

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
   other. It must be the same on every computer of the site; to change it
   later, run `scada-setup set-password` on every computer (see
   [The svc account]({{ '/en/server/' | relative_url }}#svc)).
   `<root password>` is the password of the built-in `root` account; see
   [Root password](#root-password).

`apply` writes each process's parameter file
`%ProgramData%\Telecontrol\SCADA Server\<process>\server.json` (the
folder of `scada-filesystem` is named `filestore`), creates the
[Server certificate]({{ '/en/server/' | relative_url }}#opcua-certificate) in
`C:\Program Files\Telecontrol SCADA\data\Certificates` unless one is already
there, creates the configuration databases with an empty project (with `--demo`,
with the demo project, see [Preparing the project](#project); it never
overwrites an existing one; `scada-filesystem`'s keeps only the `svc`
service account), registers one Windows service per process, and starts them in the
right order. To check the result:

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" status
```

In `scada-setup`'s messages the processes are called *tiers*: the line
`Entitled tiers: …` lists the processes the license allows, and below it the
state of each process's service is printed (`SERVICE_RUNNING` means it is
running).

**WARNING: an administrator of this computer can read the `svc` and `root`
passwords.** `apply` stores them in an encrypted file that only the Server's
services and administrators can open (see
[Where the passwords are stored]({{ '/en/server/' | relative_url }}#stored-passwords)).
Do not give untrusted people administrator rights on the Server computers,
and do not make a Server computer an operator workstation. The Server installer puts
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
* `--data-root` — if you gave a non-standard data folder;
* the `svc` password and the `root` password.

**Give these options to every `apply` and `start` on that computer** (and
the passwords to `apply`), upgrades and restores included:

* without `--tiers` both commands take **every** process in the license:
  `apply` installs processes that do not belong on the computer, and `start`
  starts only those whose services the computer has, printing
  `Skipped <process>: not installed on this host` for the rest; if the
  computer has none of those services, `start` ends with an error;
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

**WARNING:** if Telecontrol has given you a separate Client or Server
package, do not install it on a computer that already has the
`telecontrol-scada-<version>.msi` package, nor the other way round, without
checking the procedure with Telecontrol (mail@telecontrol.ru). Each version
2.6 package has its own Windows Installer upgrade code, so installing one does
not remove another, but they all install into the same
`C:\Program Files\Telecontrol SCADA` folder, and installing them together has
not been verified.

### Displaying schematics {#displays}

The version 2.6 Client renders Modus schematics (`.sde` and `.xsde` files)
itself, through a display module that has to be in the Client's folder,
beside its executable. The ActiveXeme component is not used by the version
2.6 Client. Without the module, a display window shows the message "No
display runtime is installed." with the reason. Editing schematics still
needs the Modus graphics editor.

## Installation on Linux {#linux}

The Server ships for Linux as a package in two forms —
`telecontrol-scada-server_<version>_amd64.deb` (Ubuntu, Debian) and the
archive `telecontrol-scada-server-<version>-linux-amd64.tar.gz`. It holds the
same processes as the Windows installer, except `scada-opc` and
`scada-vidicon`, and the same `scada-setup` program. The package installs
into `/opt/telecontrol-scada`; it needs x86-64 Linux with systemd and glibc
2.38 or newer (verified on Ubuntu 24.04). The graphical Client is not
supported on Linux: Windows Clients connect to a Linux Server just as they do
to a Windows one.

Run every command as `root` (with `sudo`; `status` does not need it).

1. Install the package:

   ```sh
   sudo apt install ./telecontrol-scada-server_<version>_amd64.deb
   ```

   or unpack the archive:

   ```sh
   sudo tar -xzf telecontrol-scada-server-<version>-linux-amd64.tar.gz -C /opt
   ```

2. Put the license file at `/var/lib/scada/license.json`.

3. Decide which processes run on this computer, and
   [write down the computer's parameters](#host-parameters).

4. Run:

   ```sh
   sudo /opt/telecontrol-scada/bin/scada-setup apply --tiers config,historian,filesystem,iec104,proxy --svc-password <password> --root-password <root password>
   ```

The options of `apply` and the other commands are the same as on Windows
(see [Installation on Windows](#installation-on-windows) and
[Setting up with scada-setup]({{ '/en/server/' | relative_url }}#scada-setup));
only the locations differ:

* the data folder is `/var/lib/scada`: it holds the process folders
  (`/var/lib/scada/<process>/server.json`; `filestore` for
  `scada-filesystem`) and the license;
* every process runs as a systemd service `scada-<process>.service` (for
  example `scada-config.service`) that `apply` creates; the services start
  at boot, are restarted after a failure, and run as `root`;
* the `svc` and `root` passwords are kept in the file
  `/var/lib/scada/secrets/service-secrets.env`, which only `root` can read
  (see [Where the passwords are stored]({{ '/en/server/' | relative_url }}#stored-passwords));
* `scada-setup status` prints each service's state as systemd names it:
  `active` — running, `inactive` — stopped, `failed` — stopped on an error.
  Service details are `systemctl status scada-config`, the process's
  messages `journalctl -u scada-config` and the log in the
  `/var/lib/scada/<process>/Logs` folder;
* `migrate --execute` is not available on Linux: the version 2.5 Server ran
  on Windows only.

Removing the package (`sudo apt remove telecontrol-scada-server`) stops and
removes the process services; the data in `/var/lib/scada` stays. For an
archive installation run `sudo /opt/telecontrol-scada/bin/scada-setup remove`
first, then delete the `/opt/telecontrol-scada` folder. Upgrading the package
(`apt install` of a newer `.deb`) restarts the running services with the new
executables.

## License {#license}

The license is a signed `license.json` file listing the processes purchased
and its validity period. The same file goes on every computer of the site. A
process the license does not name stops right after it starts. A license
whose validity period has not started yet is accepted neither by the
processes nor by `scada-setup`.

**Expiry.** `scada-setup status` shows when the license ends (the line
`License: … (<license id>, expires …)`; an expired one shows `EXPIRED` and the
date). The license id names whom the license was issued to; quote it when
asking Telecontrol about the license.
Check it yourself: the Server warns of the coming expiry only as system events
in the Client, during the last 30 days. Once the license has expired, the
processes keep running but refuse Client requests until the license is
replaced.

With an expired license `scada-setup` warns but still goes by the processes
the license names: `apply` without `--tiers` installs exactly those.

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

If this computer has no `scada-proxy` (protocol processes only), nothing else needs restarting: its processes' objects update and archive again by themselves — see [After a protocol process restarts]({{ '/en/server/' | relative_url }}#edge-restart).

**Adding a process.** Replace the file with the new license on every
computer. On the computer that will run the new process, run
`scada-setup apply` with that computer's full process list in `--tiers`, the
new one included, and the same other options as at installation (see
[Re-running apply]({{ '/en/server/' | relative_url }}#reapply)). Write the
new list down. If this computer has no `scada-proxy` (protocol processes only), nothing else needs restarting: its processes' objects update and archive again by themselves — see [After a protocol process restarts]({{ '/en/server/' | relative_url }}#edge-restart).

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

`scada-setup` stores the password in the computer's encrypted
[password file]({{ '/en/server/' | relative_url }}#stored-passwords) rather
than in the parameter files, and the processes write it again on every start.
So:

* **to change the root password, run from an elevated command prompt**

  ```bat
  "C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" set-password --root-password <new password>
  ```

  on every computer running one of those processes. The command stores the
  new password and restarts this computer's process services;
* **the root password is not changed from the Client**: the Server refuses
  such a change and the Client reports it in the event journal, rather than
  accepting a password that the next start of the process would replace;
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

## Preparing the project {#project}

**A new installation starts from an empty project.** The configuration
databases `apply` creates hold no objects, devices, links or users: only the
`svc` service account the processes use to connect to each other. Sign in to
the Client with the built-in `root` account and the password given as
`--root-password`. The protocol processes connect to nothing and take no
device ports until you create links. Build the project's configuration in
the Client (see [Development]({{ '/en/development/' | relative_url }})) or
put a ready project database in place (below).

The configuration is kept in one copy, in the `config/Configuration` folder
of `scada-config`. The other processes read it from `scada-config`: the
protocol processes their devices and objects, `scada-historian` the archive
list and the archive assigned to each object, and `scada-proxy` the names,
passwords and roles of Client users. So a configuration change made in the
Client — creating, renaming and deleting objects, devices and users, and
assigning roles — takes effect in every process at once. `scada-filesystem`
has a database of its own, in `filestore/Configuration`, but it holds only
the `svc` service account: `apply` removes everything else from it, and it
needs no replacing.

### Demo project {#demo}

To explore the system without field equipment, install the demo project:
add `--demo` to the first `apply` on the central computer. The configuration
databases are then created from the demo configuration shipped with the
installer: 41 analog and 52 discrete objects, emulation signals, two enabled
IEC 60870-5-104 links (one of them accepts connections on port 2404 of this
computer, which the `scada-iec104` process takes if installed), two
archives, and the users «Клиент 1» … «Клиент 10» and `guest`, which **have
no passwords set**. The demo schematics are copied into the file store of
`scada-filesystem`.

**Do not install the demo project on a Server reachable from the site
network**: anyone can sign in as its users, with no password. The demo
project's user list also has a `root` user. It is not the built-in `root`
account: signing in as `root` always uses the built-in account, with the
password given as `--root-password`, and this user can never sign in. Do
not change or delete it thinking it is the real `root`.

`--demo` acts only on configuration databases that do not exist yet: on a
computer already set up, `apply --demo` replaces nothing and prints
`Kept the existing configuration DB of …`. To go from the demo project to an
empty one, stop the processes, delete the `configuration.sqlite3` file from
the `config/Configuration` folder of the data folder, and run `apply`
without `--demo` with the same [computer's parameters](#host-parameters) and
passwords. Delete the demo schematics from the `filestore/FileSystem`
folder. You can also delete the demo devices, objects and users in the
Client: the change reaches every process. Either way, check afterwards that
nothing listens on port 2404 any more (`netstat -ano | findstr :2404` on the
computer of `scada-iec104` prints nothing) and that «Клиент 1» can no longer
sign in.

### A ready project database {#project-db}

To put a ready project configuration database (a version 2.6
`configuration.sqlite3`) in place, on the central computer:

1. Stop the processes:
   `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop`.
2. Copy the file into the `config\Configuration` folder under
   `%ProgramData%\Telecontrol\SCADA Server`, replacing the database `apply`
   created. The other processes keep no configuration database of their
   own. A `proxy\Configuration` folder left by an earlier 2.6 build is no
   longer used.
3. Run `scada-setup apply` with the same
   [computer's parameters](#host-parameters) and passwords as at
   installation. It keeps the copied database and adds the `svc` service
   account (id 100) to it, without which the processes cannot connect to
   each other. **A project user with id 100 is replaced by the `svc`
   account.** A database taken from another version 2.6 site keeps that
   site's `svc` password: this site then needs the same `svc` password, or
   the processes cannot connect to each other.

On Linux the commands are the same — `sudo /opt/telecontrol-scada/bin/scada-setup stop`
and `apply` — and the `config/Configuration` folder is under
`/var/lib/scada` (see [Installation on Linux](#linux)).

Move a version 2.5 Server's configuration with `scada-setup migrate` instead:
it also carries over the user passwords version 2.5 kept in a separate file
(see [Upgrading from version 2.5](#upgrade-2-5)).

On each workstation, copy the schematic files (`.sde`) to
`%ProgramData%\Telecontrol\SCADA Client`, or upload them to the
[server-side file system]({{ '/en/server/' | relative_url }}#filesystem)
if that feature is used.

To explore the system without field equipment, install the
[demo project](#demo) or give your project's objects
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

> **Caution.** The "OPC UA" type connects the Client over OPC UA. After the
> connection is lost the Client reconnects by itself, as with the
> "Telecontrol" type (see
> [Connection to the Server]({{ '/en/client/' | relative_url }}#connection)).
> Use the "Telecontrol" type to work with the SCADA Server.

On the right, enter the host name or IP address of the computer running
`scada-proxy` only if it is a different computer. Otherwise, leave the field
empty.

The "Security and certificates" disclosure (the security mode, the client
certificate and private key) appears only for the "OPC UA" type; with the
"Telecontrol" type there is nothing to fill in.

In the "Most secure available" and "Sign and encrypt" modes the Client checks
the Server's identity by its certificate:
{: #server-certificate-check}

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

**In a new installation the project is empty:** the objects and equipment
panels show nothing until you build the configuration or put a ready project
database in place (see [Preparing the project](#project)). If the Server was
set up with `--demo`, you see the [demo project](#demo).

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
   creating a user and setting a password, check that you can sign in as
   that user.

   An account's rights come only from its **roles**: a new account can only
   view data until it is given roles. Assign them with `Roles...` from the
   user's context menu: `Operator` for control, `ConfigureAdmin` for
   configuration (see
   [Access rights]({{ '/en/dev/users/' | relative_url }}#access-rights)).

   The user list contains the `svc` service account: the Server processes
   connect to each other through it, and the server does not let the Client
   change it. Only `scada-setup set-password` changes its password (see [The svc account]({{ '/en/server/' | relative_url }}#svc)).

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
installation, and the current `svc` password. The installer replaces only the
executables; `apply` rewrites the parameter files (keep your own parameters
in [`server.override.json`]({{ '/en/server/' | relative_url }}#server-override),
which is preserved) and leaves the data alone. On computers running only protocol
processes, `--root-password` may be omitted.

On a site with several computers, while the computers running protocol
processes are being upgraded, their processes' objects are marked bad; once
upgraded, they update and archive again by themselves
(see [After a protocol process restarts]({{ '/en/server/' | relative_url }}#edge-restart)).

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
   `iec61850` for IEC 61850). When one is missing, the migration plan warns
   with a line `WARNING: … will not run the '<process>' process`: no data is
   then collected from that protocol's devices, unless the process runs on
   another computer.

   It removes the old service, copies the configuration, the users with their
   passwords, the history and the schematic files into the version 2.6
   process folders, and starts the processes as `apply` does (creating the
   Server certificate included). The version 2.5 root password is replaced by
   the one given as `--root-password` (see [Root password](#root-password)).
   **If the command fails after copying, do not run `migrate` again** —
   finish with `apply` with the same `--tiers` and passwords (see
   [Upgrading from version 2.5]({{ '/en/server/' | relative_url }}#upgrade-2-5)).
6. Install the version 2.6 Client on **every** workstation (see
   [Installing the Client](#client-install)): whether a version 2.5 Client works
   with a 2.6 Server has not been verified.
7. Check the result from the Client.

The old `Configuration`, `History` and `FileSystem` folders are neither
changed nor deleted.

## Uninstalling {#uninstall}

Uninstall the *ОИК Телеконтроль* program (publisher ООО Телеконтроль) in
*Control Panel — Programs and Features*. The installer itself stops and
removes the process services together with their registry settings, and the
folder holding the Server certificate and its private key. It leaves the
`%ProgramData%\Telecontrol\SCADA Server` data folder (which also holds the
`svc` and `root` password file) and the firewall rules created in
[Network preparation](#network) — delete those by hand. The steps, including
how to keep the certificate for a reinstall, are in
[Uninstalling the Server]({{ '/en/server/' | relative_url }}#uninstall).

## Troubleshooting

Run the `scada-setup` commands below, other than `status`, from an elevated
command prompt.

<dl>

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

<dt>A service stops or keeps restarting after a parameter change</dt>
<dd>Most likely the <code>server.json</code> parameter file has an error (for
example after a hand edit): the
<a href="{{ '/en/server/' | relative_url }}#logging">process log</a> — in the
<code>Logs</code> folder beside the parameter file — has a
<code>Can't load parameters file</code> or <code>Invalid log configuration</code>
line describing it. Put your own parameters not in <code>server.json</code> but
in <a href="{{ '/en/server/' | relative_url }}#server-override"><code>server.override.json</code></a>,
and run <code>scada-setup apply</code>.</dd>

<dt>Protocol processes get no configuration</dt>
<dd>If a protocol process's log shows <code>Bad_UserAccessDenied</code>, the
<code>svc</code> password on that computer differs from the central
computer's. Run <code>scada-setup set-password --svc-password &lt;the central
computer's current svc password&gt;</code> there (see
<a href="{{ '/en/server/' | relative_url }}#svc-rotate">Changing the svc password</a>). If this computer has no <code>scada-proxy</code>, nothing else needs restarting: its processes' objects update and archive again by themselves (see <a href="{{ '/en/server/' | relative_url }}#edge-restart">After a protocol process restarts</a>).</dd>

<dt>The devices of a protocol computer never appear</dt>
<dd>The Client does not show the devices served by a computer running
protocol processes, although <code>scada-setup status</code> there shows them
running. <code>scada-proxy</code> connects to that computer by the name it
reported; if the central computer cannot resolve that name (check with
<code>ping &lt;computer name&gt;</code> on the central computer), run
<code>scada-setup apply</code> on the protocol computer
with its <a href="#host-parameters">computer's parameters</a> plus
<code>--advertise &lt;its IP address&gt;</code>, and write the option down. For
the new address to be in the
<a href="{{ '/en/server/' | relative_url }}#opcua-certificate">Server certificate</a>
too, delete both certificate files before that <code>apply</code>.
Also check that its firewall lets the central computer reach the OPC UA ports
of its processes (see <a href="#network">Network preparation</a>).
Once the address is fixed, the <em>Telecontrol SCADA Historian</em> service
needs no restart: the archive starts receiving those objects' values by
itself. If Client windows showing this computer's objects were open before
the fix, have the operators restart the Client as a precaution.</dd>

<dt>Every process stopped after the license file was replaced</dt>
<dd>The file was missing or only partly written when it was checked. Put a
valid file in place (see <a href="#license">Replacing the license file</a>)
and run <code>scada-setup start</code> with the
<a href="#host-parameters">computer's parameters</a>. If this computer has no <code>scada-proxy</code>, nothing else needs restarting: its processes' objects update and archive again by themselves (see <a href="{{ '/en/server/' | relative_url }}#edge-restart">After a protocol process restarts</a>).</dd>

<dt><code>scada-setup start</code> stops with an error</dt>
<dd>It was run without <code>--tiers</code> (or without
<code>--central</code>) and is trying to start a process whose service the
computer does not have. Run it again with the
<a href="#host-parameters">computer's parameters</a>.</dd>

<dt>A process runs but refuses requests</dt>
<dd>The license is not verified or has expired (the expiry is in the
<code>scada-setup status</code> output). If the process's parameter file was
written by hand, check that it sets
<code>"license": {"require_gcp_binding": false}</code> (<code>scada-setup</code>
sets it itself); for an
expired license, replace the file — no restart is needed.</dd>

<dt>Values are no longer archived</dt>
<dd>While a protocol process's service (for example
<em>Telecontrol SCADA IEC 104</em>) is stopped or restarting, automatic
restarts after a failure included, its objects' values are not archived.
Once the process starts, archiving resumes by itself, usually within a
minute; neither <em>Telecontrol SCADA Historian</em> nor the Client needs a
restart (see <a href="{{ '/en/server/' | relative_url }}#edge-restart">After a
protocol process restarts</a>). If archiving has not resumed, check
<code>scada-setup status</code> on that process's computer and contact
Telecontrol.</dd>

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
