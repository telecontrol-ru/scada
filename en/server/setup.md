---
title: Setting up with scada-setup
nav_order: 1
parent: Server
permalink: /en/server/setup/
---

# Setting up with scada-setup
{:.no_toc}

* TOC
{:toc}

On Windows, the Server processes are installed and configured with the
`scada-setup` tool that comes with the installer. It writes the parameter
files `%ProgramData%\Telecontrol\SCADA Server\<process>\server.json` from
templates, creates the configuration databases and the
[Server certificate]({{ '/en/server/opcua/' | relative_url }}#opcua-certificate), and registers the Windows services. A process's folder has the name the process has in `--tiers`
(`config`, `proxy`, `historian`, `iec104`…), except `scada-filesystem`, whose
folder is `filestore`. The executables' `--install` / `--uninstall` options
are needed only for a hand-built setup without `scada-setup`; do not use them
to change or remove services `scada-setup` created — `scada-setup apply` and
`scada-setup remove` do that. The step-by-step installation is in
[Getting started]({{ '/en/getting-started/' | relative_url }}).
On Linux `scada-setup` does the same with systemd services — see
[Linux deployment]({{ '/en/server/' | relative_url }}#linux).

**This version of `scada-setup` has not yet been tried on a site under
Windows.** If the result of any command differs from what this page
describes, report that to Telecontrol (mail@telecontrol.ru).

**Run `scada-setup` from an elevated command prompt** (except `status`,
`generate` and `migrate` without `--execute`):

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" <command> <options>
```

The data folder is closed to other users, so without one `status` shows the
certificate and the services' state, and in place of the license summary,
when the license is in the data folder, prints
`License: <path> can be read by administrators only; to see it, run scada-setup status from an elevated prompt`.

The installer does not add the program's folder to `PATH`, so outside that
folder call the program by its full path. `scada-setup` finds its templates
in the installation folder, the one above the folder holding
`scada-setup.exe`, wherever it is invoked from.

| Command | Does | Needs admin |
|---|---|:-:|
| `apply` | Write parameter files and databases, create the [Server certificate]({{ '/en/server/opcua/' | relative_url }}#opcua-certificate) if there is none, register and start the processes' services | yes |
| `status` | License summary, this computer's certificate and each process's service state | no (yes for the summary of a license in the data folder) |
| `start` / `stop` | Start / stop this computer's services in order | yes |
| `remove [--purge-data]` | Stop and unregister the services (with `--purge-data`, delete the data of the processes named in `--tiers` too — see [Removing services and data](#remove)) | yes |
| `generate --tiers <list> --output <dir>` | Write the parameter files only, for inspection | no |
| `migrate [--execute]` | Move a version 2.5 Server's data over — see [Upgrading from version 2.5]({{ '/en/server/upgrade/' | relative_url }}#upgrade-2-5) | with `--execute` |
| `set-password` | Change the `svc` and/or `root` password on this computer and restart its services — see [Changing the svc password]({{ '/en/server/security/' | relative_url }}#svc-rotate) | yes |

In its messages `scada-setup` calls the Server processes *tiers*: for
example, `status` prints the line `Entitled tiers: config filesystem historian …` — the
processes the license allows, in alphabetical order — and errors read
`--tiers must name at least one tier` or
`the license does not entitle tier(s) …`. The names in these messages are the
same as in the `--tiers` option.

**A new installation starts from an empty project.** The configuration
databases `apply` creates hold no objects, devices, links or users — only the
`svc` service account; sign in with the built-in `root` account. With
`--demo`, the first `apply` creates them from the demo configuration shipped
with the installer (objects with emulation, IEC 60870-5-104 links, users
with no passwords) and copies the demo schematics — for exploring only, see
[Preparing the project]({{ '/en/getting-started/' | relative_url }}#project).
`apply` replaces no existing database, with `--demo` or without. The
configuration is kept in one copy, by `scada-config`; the other processes,
`scada-proxy` included, read it from `scada-config`, so changes made in the
Client take effect in every process.

### Options {#scada-setup-options}

* `--tiers <list>` — this computer's processes, comma-separated. When it is
  absent, `apply`, `start` and `migrate` take **every process in the
  license**, while `stop`, `status`, `remove` and `set-password` take every
  Server service the computer has. `generate` requires it.
  On Linux the default set leaves out `scada-opc` and `scada-vidicon`, which
  run on Windows only. Named in the `--tiers` of `apply`, `start` or `migrate` (a dry run
  included), either
  is refused with `… runs on Windows only, and this computer is not Windows;
  nothing was changed`; `stop`, `status`, `remove` and `generate` accept
  them.
* `--central <address>` — the central computer's address; required by
  `apply`, `migrate` and `generate` on a computer without `scada-config`.
* `--advertise <address>` — this computer's address for the others. Without
  it, a computer set up with `--central` reports its computer name, and
  `scada-proxy` connects to it by that name: give the IP address unless the
  central computer resolves the name. Decide before the first `apply`: the
  [Server certificate]({{ '/en/server/opcua/' | relative_url }}#opcua-certificate) records the address only when it
  is created. On the central computer, give the address the other computers
  use to reach it: they check it against the central computer's
  certificate, and refuse to connect when it is not there.
* `--license <path>` — the license file; default `license.json` in the data
  folder (`%ProgramData%\Telecontrol\SCADA Server\license.json`; on Linux
  `/var/lib/scada/license.json`). `apply`, `start`, `migrate` and `status`
  check it. Without `--license`, `start` and `status` check the file whose
  path `apply` wrote into the processes' parameter files, so `--license` is
  needed only by `apply` and `migrate`. Give a full path (on Windows,
  beginning with the drive letter): the processes receive the path as
  written. On Linux the file must be readable by the `scada` account and must
  not be under `/home`, `/root` or `/run/user`: the services cannot see
  those folders, and `apply` and `start` refuse such a path.
* `--svc-password <password>` (or the `SCADA_SETUP_SVC_PASSWORD` environment
  variable) — the password of the [svc account]({{ '/en/server/security/' | relative_url }}#svc), required by `apply`
  and `migrate --execute`; for `set-password`, the new password. It may be
  at most 64 bytes long, or `scada-setup` refuses to run: a Latin letter or
  digit takes one byte and a Cyrillic letter two (passwords are stored in
  UTF-8 on Windows and Linux alike; on Windows `scada-setup` has not yet
  been tried on a site), so a password of Cyrillic letters only
  may be at most 32 characters.
* `--root-password <password>` (or the `SCADA_SETUP_ROOT_PASSWORD`
  environment variable) — the [root password]({{ '/en/server/security/' | relative_url }}#root-password), required by
  `apply` and `migrate --execute` on a computer running `scada-config` or
  `scada-filesystem`.
* `--demo` — `apply` only: create the configuration databases that do not
  exist yet from the demo project rather than empty (see
  [Demo project]({{ '/en/getting-started/' | relative_url }}#demo)).
* `--assigned-links-only` — this computer's protocol processes serve only
  the links whose Computer property names this computer, and leave the links
  without a computer to the computer where `apply` ran without this option
  (see [Choose the Server processes]({{ '/en/getting-started/' | relative_url }}#choose)).
* `--central-fingerprint <fingerprint>` — on a computer without
  `scada-config`: the fingerprint of the central computer's certificate, as
  `apply` and `scada-setup status` print it there. With it, the computer
  joins the site: it gets its certificate from the
  [site's certificate authority]({{ '/en/server/opcua/' | relative_url }}#opcua-site-ca), and its processes connect
  to the others encrypted. Requires `--svc-password`. The fingerprint is
  needed only to join for the first time, and after the central computer has
  got a new certificate authority (for example, it was reinstalled with its
  authority deleted): `apply` with the new fingerprint then replaces this
  computer's certificate by itself. A computer that has joined recognises the
  central one by the certificate authority, so replacing the central
  computer's certificate does not affect the fingerprint in its parameters
  (see [The central computer's fingerprint changed]({{ '/en/server/opcua/' | relative_url }}#central-fingerprint-changed)).
* `--insecure-links` — the processes connect to each other unencrypted, as
  in earlier versions: no certificate authority is created, and each
  computer gets a self-signed certificate. The firewall is then the only
  protection (see [OPC UA server]({{ '/en/server/opcua/' | relative_url }}#opcua)).
* `--allow-anonymous-opcua` — on the computer with `scada-proxy`: port 4840
  also accepts unsecured connections (policy None) and anonymous sign-in,
  for external OPC UA systems that can do neither of the secure ones (see
  [Connecting an external system]({{ '/en/server/opcua/' | relative_url }}#opcua-external)). Without it, on a site
  with encryption, port 4840 accepts only secured connections that sign in
  with a user name.
* `--data-root` — the data folder, when it is not the standard one
  (`%ProgramData%\Telecontrol\SCADA Server` by default, `/var/lib/scada`
  on Linux).
* `--install-root` — the installation folder. There is no need to give it:
  it defaults to the folder above the one holding `scada-setup.exe`. On
  Linux neither the data folder nor the installation folder may be under
  `/home`, `/root` or `/run/user`: the services cannot see those folders,
  and `apply` and `start` refuse to run. So do not unpack the `.tar.gz`
  archive into a home folder.

* `--host-name <name>` — this computer's name in place of its system
  computer name: `scada-setup` writes it into the parameter files and the
  certificate, and it is the name a link's Computer property gives (see
  [Choose the Server processes]({{ '/en/getting-started/' | relative_url }}#choose)).

**`scada-setup` remembers only the license path and the data folder.** It does not remember the other options. Write down each computer's
`--tiers`, `--central`, `--advertise`, `--license`, the central computer's
fingerprint (`--central-fingerprint`) and, if you gave them, `--host-name`,
`--assigned-links-only`, `--insecure-links`, `--allow-anonymous-opcua` and
`--data-root` at installation, and give them to every `apply` on it (and
`--tiers` to every `start`; `start` does not need `--central`), upgrades and
restores included (`start`, `status`, `stop`, `remove` and
`set-password` without `--data-root` take the data folder from the installed
services):

* `start` without `--tiers` takes every process in the license, starts those
  whose services the computer has, and prints
  `Skipped <process>: not installed on this host` for the rest; if the
  computer has none of those services, `start` fails with
  `none of the requested tier services is installed on this host`;
* `apply` without `--tiers` installs every process in the license on the
  computer. `remove --tiers <the extra processes>` removes the extra services
  (without `--purge-data` their data stays);
* `apply` without `--license` writes the default path into the parameter
  files only, not into the services;
* `apply` without `--assigned-links-only` on a computer where it was given
  makes that computer serve the links without a computer — and two computers
  open the same links;
* `apply` without `--host-name` on a computer where it was given writes the
  computer name into the parameter files, and the computer stops
  serving the links assigned to the old name;
* on a site set up with `--insecure-links`, `apply` without that option on
  the central computer creates the site certificate authority and switches
  the central computer's links to encryption — the other computers lose
  contact with it until they are joined with `--central-fingerprint` (see
  [Site certificate authority]({{ '/en/server/opcua/' | relative_url }}#opcua-site-ca));
* `apply` without `--allow-anonymous-opcua` on the computer with
  `scada-proxy`, where it was given, closes port 4840 to unsecured
  connections and anonymous sign-in, and the external systems that connected
  that way stop connecting.

`apply` can be run again: it rewrites the parameter files and re-registers
the services with the new settings, without touching data.

### Re-running apply on running processes {#reapply}

A process reads its parameter file, the `svc` and `root` passwords and the
license path only when it starts. So **`apply` restarts a running service
when any of them changed** — after a new `--root-password`, another `--license`, a different
`--central` or `--advertise`, for example — together with this computer's
services that depend on it (all the others depend on *Telecontrol SCADA
Config*). Services with nothing changed keep running. There is no need to
stop the processes before `apply`:

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" apply --tiers <this computer's processes> [--central <address>] [--advertise <address>] [--license <path>] --svc-password <password> --root-password <root password>
```

Add the rest of the recorded
[computer parameters](#scada-setup-options) too — `--central-fingerprint`,
`--host-name`, `--assigned-links-only`, `--insecure-links`,
`--allow-anonymous-opcua`, `--data-root` — if they were given at
installation.

This is how to add a process to the computer. The `svc` and `root` passwords
are changed by the `set-password` command, which restarts the services itself
(see [Changing the svc password]({{ '/en/server/security/' | relative_url }}#svc-rotate)). A restart interrupts the
service for a moment: while `scada-proxy` restarts, Clients lose their
connection to the Server. If this computer has no `scada-proxy` (protocol processes only), Clients keep their connection: those processes' objects are marked bad during the restart and then update and archive again by themselves — see [After a protocol process restarts]({{ '/en/server/' | relative_url }}#edge-restart).

A running process does not let its configuration database be changed.
Normally a repeated `apply` has nothing to change in it, but if the `svc`
service account was altered, `apply` prints `can't update the configuration
DB of <process>: database is locked` and stops before starting the services: stop the services
with `scada-setup stop` and run `apply` again.

### Removing services and data {#remove}

`remove` stops and unregisters the services; the processes' data stays.

With `--purge-data` the command also irreversibly deletes, without asking
for confirmation, the data folders of the processes named in `--tiers`
(`config`, `proxy`, `historian`, `filestore` and so on in
`%ProgramData%\Telecontrol\SCADA Server`) — the configuration, user
passwords, archives, display files and logs. Without `--tiers`,
`remove --purge-data` does nothing and reports an error. Make a
[backup]({{ '/en/server/backup/' | relative_url }}) before using `--purge-data`.

### Your own parameters: server.override.json {#server-override}

**WARNING:** `apply` writes every `server.json` afresh from a template — on
every `apply`, every upgrade included — so **do not edit `server.json`**. Put
your own parameters (for example the [log sizes]({{ '/en/server/monitoring/' | relative_url }}#logging)) in a
`server.override.json` file in the same process folder: `apply` never changes
it, and lays it over the template every time it writes `server.json`. Blocks
(JSON objects) are merged key by key, any other value (a string, a number, a
list) replaces the template's value whole, and a `null` value removes the
parameter. For example, to make the log files larger this file is enough:

```json
{ "log": { "max_file_size": 50 } }
```

An error in `server.override.json` stops `apply` with a message naming the
file. If the existing `server.json` differs from the one being written (for
example because it was edited by hand), `apply` keeps the old file as
`server.json.bak` — move your changes from it into `server.override.json`.
After changing `server.override.json`, run `apply`: when that changes the
process's parameter file, `apply` restarts its service (see
[Re-running apply](#reapply)).

### Where the passwords are stored {#stored-passwords}

The `svc` and `root` passwords given to `apply` or `set-password` are stored
in the file `%ProgramData%\Telecontrol\SCADA Server\secrets\service-secrets.dat`.
The file is encrypted by Windows (DPAPI) and bound to the computer: it does
not decrypt on another one. Only the system account the services run as and
the computer's administrators can open the `secrets` folder. The services find
the file through the `SCADA_SECRETS_FILE` variable in their settings, and the
registry no longer holds the passwords.

* **An administrator of the computer can read these passwords.** Do not give
  untrusted people administrator rights on the Server computers.
* **Only `scada-setup set-password` changes the passwords in this file.** A
  `root` or `svc` password change from the Client is refused by the Server
  (see [Root password]({{ '/en/server/security/' | relative_url }}#root-password) and [The svc account]({{ '/en/server/security/' | relative_url }}#svc)).
* **A Server installed by a pre-release build of version 2.6 may keep the
  passwords in plain text** — in the `Environment` values of the registry keys
  `HKLM\SYSTEM\CurrentControlSet\Services\TelecontrolScada<Process>`, where
  anyone who signs in to Windows on that computer can read them. The first
  `apply` or `set-password` after the update moves them into the file and
  removes them from the registry.
* **After moving the data to another computer** (for example when
  [restoring]({{ '/en/server/backup/' | relative_url }})), run `apply` there with the same passwords: the copied
  password file does not decrypt there.

**On Linux** the passwords are kept in
`/var/lib/scada/secrets/service-secrets.env`: it is **not encrypted**, but
only `root` can open the `secrets` folder and read the file. systemd reads it
when it starts each service and passes the passwords to the process in
environment variables; the parameter files and service files carry no
password. Do not give outsiders `root` rights on Server computers, and do not
copy this file into backups others can read.

**The data folder is closed to other users of the computer.** `apply`
leaves the configuration database (including the Client users' password
records), the archive and the process logs to the Server alone. On Windows
the data folder gets access for administrators and the system account
(SYSTEM), which the services run as, and nobody else — open it from a
command prompt run as administrator: when Explorer offers to give your own
account access instead, accepting adds that account to the folder for good.
On Linux each process folder inside it belongs to `scada` and is closed to
other users (`0750`), and so is everything the processes create later.
`/var/lib/scada` itself stays `root`'s and open for reading: the processes,
which run as `scada`, reach their folders and the license through it, so do
not close it.

If you restricted the folder yourself before, `apply` keeps what you set:
on Windows a folder whose inherited permissions you turned off and which
lets no ordinary users in is left as it is, extra entries included; on
Linux no folder is opened wider than you left it. What stays your job: keep
backups and copies of the data folder just as closed, and do not put the
data folder at the root of a drive (`D:\`) — `apply` leaves the permissions
of a whole drive alone and says so.

Do not combine a Server computer with an operator workstation. If the Client
package (with its desktop shortcut) is installed on a Server computer too, do
not let operators work with it (see
[Installing the Client]({{ '/en/getting-started/' | relative_url }}#client-install)).
