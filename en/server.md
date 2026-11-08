---
title: Server
nav_order: 6
permalink: /en/server/
---

# Server
{:.no_toc}

* TOC
{:toc}

The Server is the central runtime component of Telecontrol SCADA. It acquires data from equipment, processes live values, archives history, records events, and maintains client sessions. It runs on Windows and Linux, as system services or in console mode (see [Linux deployment](#linux)).

The Server is a set of separate processes: `scada-config`, `scada-proxy`, `scada-historian`, `scada-filesystem`, the protocol processes, and others. What each one does and the typical installations are described in [Server processes]({{ '/en/architecture/' | relative_url }}#tiers). Every process is started and configured the same way, so below "the Server" means any of them, and `server.json` means that process's parameter file.

## Runtime modes

On Windows, each Server process is installed as its own service — `Telecontrol SCADA Config`, `Telecontrol SCADA Proxy`, `Telecontrol SCADA Historian`, `Telecontrol SCADA IEC 104`, and so on (the full list is in [Server processes]({{ '/en/architecture/' | relative_url }}#tiers)) — and starts automatically during system boot.

It can also be started in console mode for diagnostics.

### Windows services {#services}

The services are registered by [`scada-setup`](#scada-setup); they run as the
SYSTEM account and start automatically with Windows. `scada-setup stop` and
`scada-setup start` stop and start all of a computer's services in the right
order (`start` with the [computer's parameters](#scada-setup-options): it skips the processes whose services the computer does not have, and fails only when the computer has none of the requested services); a single service can be controlled through the standard Windows
Services UI.

When a computer runs *Telecontrol SCADA Config*, its other services depend on
it, and *Telecontrol SCADA Proxy* also depends on *Telecontrol SCADA
Filesystem*: Windows starts the dependent services after them, and the
Services UI offers to stop a service whose dependents are running only
together with them.

**Recovery after a failure.** `scada-setup` sets every service to restart
after a failure: 5 seconds after the first failure, 10 seconds after the
second, and 60 seconds after later ones; the failure count resets after one
day. A process exiting with a non-zero code counts as a failure too. A
process that stopped because it has no license exits normally and is not
restarted — start it with `scada-setup start` and the
[computer's parameters](#scada-setup-options).

#### After a protocol process restarts {#edge-restart}

When the service of a protocol process restarts while `scada-proxy` keeps
running — automatically after a failure included, or when the processes are
stopped and started on a computer without `scada-proxy` — **nothing needs
restarting**. While the process is unavailable, its objects in open Client
windows are marked bad and no new values are archived. Usually within a
minute of the process starting, `scada-proxy` connects to it again: the values in Client
windows update again and archiving resumes by itself. Neither the
*Telecontrol SCADA Historian* service nor the Client needs to be restarted
for this.

When the process starts, its objects take their latest values from history:
until the devices report new values, an object shows the value, quality and
time of its last archived sample. This applies to objects whose values are
archived. If `scada-historian` is unavailable at that moment, the process
waits for it for at most 10 seconds and starts without those values; the
objects then stay bad until the devices report new values.

When `scada-proxy` and `scada-historian` restarted with it (for example,
`scada-setup stop` and `start` on a single-computer installation), the
Historian starts afresh and the Clients reconnect by themselves (see
[Connection to the Server]({{ '/en/client/' | relative_url }}#connection)). See also [Monitoring](#monitoring).

### Setting up with scada-setup {#scada-setup}

On Windows, the Server processes are installed and configured with the
`scada-setup` tool that comes with the installer. It writes the parameter
files `%ProgramData%\Telecontrol\SCADA Server\<process>\server.json` from
templates, creates the configuration databases and the
[Server certificate](#opcua-certificate), and registers the Windows services. A process's folder has the name the process has in `--tiers`
(`config`, `proxy`, `historian`, `iec104`…), except `scada-filesystem`, whose
folder is `filestore`. The executables' `--install` / `--uninstall` options
are needed only for a hand-built setup without `scada-setup`; do not use them
to change or remove services `scada-setup` created — `scada-setup apply` and
`scada-setup remove` do that. The step-by-step installation is in
[Getting started]({{ '/en/getting-started/' | relative_url }}).
On Linux `scada-setup` does the same with systemd services — see
[Linux deployment](#linux).

**This version of `scada-setup` has not yet been tried on a site under
Windows.** If the result of any command differs from what this page
describes, report that to Telecontrol (mail@telecontrol.ru).

**Run `scada-setup` from an elevated command prompt** (except `status`,
`generate` and `migrate` without `--execute`):

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" <command> <options>
```

The installer does not add the program's folder to `PATH`, so outside that
folder call the program by its full path. `scada-setup` finds its templates
in the installation folder, the one above the folder holding
`scada-setup.exe`, wherever it is invoked from.

| Command | Does | Needs admin |
|---|---|:-:|
| `apply` | Write parameter files and databases, create the [Server certificate](#opcua-certificate) if there is none, register and start the processes' services | yes |
| `status` | License summary, this computer's certificate and each process's service state | no |
| `start` / `stop` | Start / stop this computer's services in order | yes |
| `remove [--purge-data]` | Stop and unregister the services (with `--purge-data`, delete the data of the processes named in `--tiers` too — see [Removing services and data](#remove)) | yes |
| `generate --tiers <list> --output <dir>` | Write the parameter files only, for inspection | no |
| `migrate [--execute]` | Move a version 2.5 Server's data over — see [Upgrading from version 2.5](#upgrade-2-5) | with `--execute` |
| `set-password` | Change the `svc` and/or `root` password on this computer and restart its services — see [Changing the svc password](#svc-rotate) | yes |

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

#### Options {#scada-setup-options}

* `--tiers <list>` — this computer's processes, comma-separated. When it is
  absent, `apply`, `start` and `migrate` take **every process in the
  license**, while `stop`, `status`, `remove` and `set-password` take every
  Server service the computer has. `generate` requires it.
* `--central <address>` — the central computer's address; required by
  `apply`, `migrate` and `generate` on a computer without `scada-config`.
* `--advertise <address>` — this computer's address for the others. Without
  it, a computer set up with `--central` reports its computer name, and
  `scada-proxy` connects to it by that name: give the IP address unless the
  central computer resolves the name. Decide before the first `apply`: the
  [Server certificate](#opcua-certificate) records the address only when it
  is created. On the central computer, give the address the other computers
  use to reach it: they check it against the central computer's
  certificate, and refuse to connect when it is not there.
* `--license <path>` — the license file; default `license.json` in the data
  folder (`%ProgramData%\Telecontrol\SCADA Server\license.json`; on Linux
  `/var/lib/scada/license.json`). `apply`, `start`, `migrate` and `status`
  check it: if the license file is elsewhere, give `--license` to `status`
  too, or it prints `License: not available`. Give a full path (on Windows,
  beginning with the drive letter): the processes receive the path as
  written. On Linux the file must be readable by the `scada` account and must
  not be under `/home`, `/root` or `/run/user`, which the services cannot
  see.
* `--svc-password <password>` (or the `SCADA_SETUP_SVC_PASSWORD` environment
  variable) — the password of the [svc account](#svc), required by `apply`
  and `migrate --execute`; for `set-password`, the new password. It may be
  at most 64 bytes long, or `scada-setup` refuses to run: a Latin letter or
  digit takes one byte and a Cyrillic letter two, so a password of Cyrillic
  letters only may be at most 32 characters.
* `--root-password <password>` (or the `SCADA_SETUP_ROOT_PASSWORD`
  environment variable) — the [root password](#root-password), required by
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
  [site's certificate authority](#opcua-site-ca), and its processes connect
  to the others encrypted. Requires `--svc-password`. The fingerprint is
  needed only to join for the first time, and after the central computer has
  got a new certificate authority (for example, it was reinstalled with its
  authority deleted): `apply` with the new fingerprint then replaces this
  computer's certificate by itself. A computer that has joined recognises the
  central one by the certificate authority, so replacing the central
  computer's certificate does not affect the fingerprint in its parameters
  (see [The central computer's fingerprint changed](#central-fingerprint-changed)).
* `--insecure-links` — the processes connect to each other unencrypted, as
  in earlier versions: no certificate authority is created, and each
  computer gets a self-signed certificate. The firewall is then the only
  protection (see [OPC UA server](#opcua)).
* `--allow-anonymous-opcua` — on the computer with `scada-proxy`: port 4840
  also accepts unsecured connections (policy None) and anonymous sign-in,
  for external OPC UA systems that can do neither of the secure ones (see
  [Connecting an external system](#opcua-external)). Without it, on a site
  with encryption, port 4840 accepts only secured connections that sign in
  with a user name.
* `--data-root` — the data folder, when it is not the standard one
  (`%ProgramData%\Telecontrol\SCADA Server` by default, `/var/lib/scada`
  on Linux).
* `--install-root` — the installation folder. There is no need to give it:
  it defaults to the folder above the one holding `scada-setup.exe`.

* `--host-name <name>` — this computer's name in place of the Windows
  computer name: `scada-setup` writes it into the parameter files and the
  certificate, and it is the name a link's Computer property gives (see
  [Choose the Server processes]({{ '/en/getting-started/' | relative_url }}#choose)).

**`scada-setup` does not remember its options.** Write down each computer's
`--tiers`, `--central`, `--advertise`, `--license`, the central computer's
fingerprint (`--central-fingerprint`) and, if you gave them, `--host-name`,
`--assigned-links-only`, `--insecure-links`, `--allow-anonymous-opcua` and
`--data-root` at installation, and give them to every `apply` on it (and `--tiers` and
`--license` to every `start`; `start` does not need `--central`), upgrades
and restores included:

* `start` without `--tiers` takes every process in the license, starts those
  whose services the computer has, and prints
  `Skipped <process>: not installed on this host` for the rest;
* `apply` without `--tiers` installs every process in the license on the
  computer. `remove --tiers <the extra processes>` removes the extra services
  (without `--purge-data` their data stays);
* `apply` without `--license` writes the default path into the parameter
  files only, not into the services;
* `apply` without `--assigned-links-only` on a computer where it was given
  makes that computer serve the links without a computer — and two computers
  open the same links;
* `apply` without `--host-name` on a computer where it was given writes the
  Windows computer name into the parameter files, and the computer stops
  serving the links assigned to the old name;
* on a site set up with `--insecure-links`, `apply` without that option on
  the central computer creates the site certificate authority and switches
  the central computer's links to encryption — the other computers lose
  contact with it until they are joined with `--central-fingerprint` (see
  [Site certificate authority](#opcua-site-ca));
* `apply` without `--allow-anonymous-opcua` on the computer with
  `scada-proxy`, where it was given, closes port 4840 to unsecured
  connections and anonymous sign-in, and the external systems that connected
  that way stop connecting.

`apply` can be run again: it rewrites the parameter files and re-registers
the services with the new settings, without touching data.

#### Re-running apply on running processes {#reapply}

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
(see [Changing the svc password](#svc-rotate)). A restart interrupts the
service for a moment: while `scada-proxy` restarts, Clients lose their
connection to the Server. If this computer has no `scada-proxy` (protocol processes only), Clients keep their connection: those processes' objects are marked bad during the restart and then update and archive again by themselves — see [After a protocol process restarts](#edge-restart).

A running process does not let its configuration database be changed.
Normally a repeated `apply` has nothing to change in it, but if the `svc`
service account was altered, `apply` prints `can't update the configuration
DB of <process>: database is locked` and stops before starting the services: stop the services
with `scada-setup stop` and run `apply` again.

#### Removing services and data {#remove}

`remove` stops and unregisters the services; the processes' data stays.

With `--purge-data` the command also irreversibly deletes, without asking
for confirmation, the data folders of the processes named in `--tiers`
(`config`, `proxy`, `historian`, `filestore` and so on in
`%ProgramData%\Telecontrol\SCADA Server`) — the configuration, user
passwords, archives, display files and logs. Without `--tiers`,
`remove --purge-data` does nothing and reports an error. Make a
[backup](#backup) before using `--purge-data`.

#### Your own parameters: server.override.json {#server-override}

**WARNING:** `apply` writes every `server.json` afresh from a template — on
every `apply`, every upgrade included — so **do not edit `server.json`**. Put
your own parameters (for example the [log sizes](#logging)) in a
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

#### Where the passwords are stored {#stored-passwords}

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
  (see [Root password](#root-password) and [The svc account](#svc)).
* **A Server installed by a pre-release build of version 2.6 may keep the
  passwords in plain text** — in the `Environment` values of the registry keys
  `HKLM\SYSTEM\CurrentControlSet\Services\TelecontrolScada<Process>`, where
  anyone who signs in to Windows on that computer can read them. The first
  `apply` or `set-password` after the update moves them into the file and
  removes them from the registry.
* **After moving the data to another computer** (for example when
  [restoring](#backup)), run `apply` there with the same passwords: the copied
  password file does not decrypt there.

**On Linux** the passwords are kept in
`/var/lib/scada/secrets/service-secrets.env`: it is **not encrypted**, but
only `root` can open the `secrets` folder and read the file. systemd reads it
when it starts each service and passes the passwords to the process in
environment variables; the parameter files and service files carry no
password. Do not give outsiders `root` rights on Server computers, and do not
copy this file into backups others can read.

Do not combine a Server computer with an operator workstation. The Server installer puts the
Client on the computer too, with a desktop shortcut — do not let operators
work with it on a Server computer (see
[Installing the Client]({{ '/en/getting-started/' | relative_url }}#client-install)).

### Upgrading from version 2.5 {#upgrade-2-5}

**WARNING:** the version 2.6 Server installer is not published yet
(see [Download]({{ '/en/getting-started/' | relative_url }}#download));
until it is, the upgrade cannot be carried out.

Versions 2.5 and earlier installed a single process — the *Telecontrol SCADA
Server* service — and kept its data in the `Configuration`, `History` and
`FileSystem` folders inside `%ProgramData%\Telecontrol\SCADA Server`.
`scada-setup migrate` moves that data into the version 2.6 processes:

| Version 2.5 data | Copied to |
|---|---|
| Configuration `Configuration\configuration.sqlite3` | `config\Configuration` |
| User passwords `Configuration\password.dat` | The same folder, beside the configuration |
| History `History` | `historian\History` |
| Schematic files `FileSystem` | `filestore\FileSystem` |

All paths are relative to `%ProgramData%\Telecontrol\SCADA Server`; if the
version 2.5 `server.json` named other folders, the command takes them from
there. The configuration is copied to `scada-config` only: it hands it to
the protocol processes and to `scada-historian` (the historical databases
and object assignments), and `scada-proxy` reads Client user names and
passwords from it.

The configuration is not carried into `scada-filesystem`'s database
(`filestore\Configuration`): that process needs only the `svc` service
account, and `apply` keeps only that account in its database.

**The version 2.5 folders are only read**: the command changes and deletes
nothing in them. That matters, because on first start the 2.6 processes
convert their copies to the new format, which version 2.5 can no longer use.
Delete the old folders yourself once the upgraded system is known to work.

**Check the plan before installing version 2.6.** The 2.6 installer
replaces the version 2.5 program, and what blocks the migration (see the
list below) can only be fixed in version 2.5. So check the plan first with
the `scada-setup` unpacked from the 2.6 package without installing it.

The steps, on the computer where the 2.5 Server ran, from an elevated
command prompt:

1. Obtain a version 2.6 license (a `license.json` file) from Telecontrol and
   put it at `%ProgramData%\Telecontrol\SCADA Server\license.json`. Version
   2.6 does not use the HASP or Guardant hardware key: Telecontrol exchanges
   it for a license — see [Exchanging the hardware key](#license-exchange).
2. Back up the whole `%ProgramData%\Telecontrol\SCADA Server` folder.
3. Unpack the version 2.6 package into a temporary folder — this **does not
   install it**, and the 2.5 Server keeps running — and find
   `scada-setup.exe` in it:

   ```bat
   msiexec /a telecontrol-scada-<version>.msi /qb TARGETDIR=C:\scada-2.6-setup
   dir /s /b C:\scada-2.6-setup\scada-setup.exe
   ```

4. See the migration plan with the unpacked program, giving the full path
   that `dir` printed and this computer's processes (the command changes
   nothing):

   ```bat
   "<path to the unpacked scada-setup.exe>" migrate --tiers config,historian,filesystem,iec104,proxy
   ```

   Besides `config`, `historian`, `filesystem` and `proxy`, give `--tiers`
   **a protocol process for every protocol** the version 2.5 devices use (in
   the example IEC 60870-5-104, `iec104`; `modbus` for MODBUS, `iec61850` for
   IEC 61850). When the version 2.5 configuration has enabled links or
   devices of a protocol whose process is not given, the plan warns with a
   line `WARNING: … will not run the '<process>' process`: the configuration
   is carried over, but no data is collected from those devices unless the
   process runs on another computer of the site.

   It lists what will be copied where, how much disk space that needs, which
   version 2.5 settings are not carried over and, under the heading
   `Cannot migrate`, anything that prevents the migration. Fix that in
   version 2.5 and run the command again until the list is empty. The
   `C:\scada-2.6-setup` folder can then be deleted.

   The check normally runs while the 2.5 Server is running. If the
   `Cannot migrate` list has the line `Can't read the 2.5 configuration
   database … stop the 2.5 service and run the migration again`, the running
   2.5 Server most likely kept the configuration database from being read:
   stop the *Telecontrol SCADA Server* service (Control Panel — Services), run
   the check again, then start the service again.
5. Install the version 2.6 package:

   ```bat
   msiexec /i telecontrol-scada-<version>.msi /qn /norestart /l*v install.log
   ```

   The installer replaces the version 2.5 program; the data stays where it
   is. The *Telecontrol SCADA Server* service may stay registered — the next
   step stops and removes it.
6. Run the migration with the same `--tiers` as in step 4:

   ```bat
   "C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" migrate --execute --tiers config,historian,filesystem,iec104,proxy --svc-password <password> --root-password <root password>
   ```

   It checks the plan once more, stops and removes the *Telecontrol SCADA
   Server* service if it is still there, copies the data (the `Copied …`
   lines), and then runs `scada-setup apply`: it writes the parameter files,
   creates the [Server certificate](#opcua-certificate) if there is none yet,
   and registers and starts the process services. User passwords are carried
   over, while the version 2.5 root password — whether set with
   `security.rootPassword` or changed from the Client — is replaced on the
   2.6 processes' first start by the [root password](#root-password) given as
   `--root-password`.
7. Install the version 2.6 Client on **every** workstation: the 2.6 Client
   displays schematics with its own display module (see
   [Displaying schematics]({{ '/en/getting-started/' | relative_url }}#displays)).
   Whether a version 2.5 Client works with a 2.6 Server has not been
   verified.
8. Connect a Client (port 2000, as before) as a user and check the objects,
   the history and the schematics.

**If `migrate --execute` fails:**

* **after copying all the data** (the output has a `Copied` line for every
  line of the plan) — do not run `migrate` again: it would refuse, because
  the destination folders now exist. Fix the cause of the error and finish
  with `apply` with the same `--tiers` and passwords;
* **part-way through copying** — delete the `config`, `proxy`, `historian`
  and `filestore` folders it created in
  `%ProgramData%\Telecontrol\SCADA Server` (leave the version 2.5
  `Configuration`, `History` and `FileSystem` folders alone) and run
  `migrate --execute` again.

The migration does not start, and the command says why, when:

* the version 2.5 configuration is not stored in SQLite (for example, it is in
  PostgreSQL) — move it to SQLite with the version 2.5 administration utility
  (available from Telecontrol);
* a version 2.5 user has the id 100, which the `svc` service account takes.
  Create the same user in version 2.5 under another name, delete the old one,
  and check again;
* the version 2.5 configuration database cannot be read
  (`Can't read the 2.5 configuration database …`) — stop the version 2.5
  *Telecontrol SCADA Server* service and run the command again;
* `config` is not selected on this computer;
* the data has already been moved (the destination folders exist — the
  command never overwrites them);
* there is not enough disk space.

`--from <folder>` (the folder holding the version 2.5 `server.json`, when it
is not `%ProgramData%\Telecontrol\SCADA Server`) and `--from-exe-dir <folder>`
(the version 2.5 program folder — needed only when `server.json` named no data
folder and the data sat beside the program) are rarely needed.

If version 2.5 had the OPC client or the Vidicon integration enabled, in
version 2.6 these are the separate `scada-opc` and `scada-vidicon` processes,
and the license must include them. `migrate` says so in its list of settings
not carried over.

#### Exchanging the hardware key {#license-exchange}

Version 2.6 does not read the Guardant or HASP key; Telecontrol exchanges it
for a signed license. The migration plan (step 4) needs no license, and its
notes end with a request line such as:

```text
TIERS=config,historian,filesystem,iec104,proxy
```

Send that line to Telecontrol together with the hardware key's serial number,
and you receive a long-dated `license.json` naming those processes. The line
lists everything the version 2.5 Server ran — `config`, `historian` and
`proxy`, `filesystem` if the file store was enabled, the process for every
protocol the version 2.5 devices use, and `opc` and `vidicon` if the OPC client
or the Vidicon integration was enabled — plus every process given to
`--tiers`. One license covers every computer of the site, so the line names
the site's processes, not only this computer's.

### Rolling back to version 2.5 {#rollback-2-5}

If the 2.6 Server does not work after the migration (for example, its
services do not start), version 2.5 can be brought back, but not by
installing over it: **the 2.5.7 installer refuses to install while a newer
version is installed** (the message `A later version of ОИК Телеконтроль is
already installed`), and the version 2.5 *Telecontrol SCADA
Server* service has already been removed by `migrate --execute`. On the same
computer, from an elevated command prompt:

1. Uninstall version 2.6: the *ОИК Телеконтроль* program (publisher
   ООО Телеконтроль) in *Control Panel — Programs and Features*, or
   `msiexec /x telecontrol-scada-<version>.msi /qn /norestart /l*v uninstall.log`.
   `msiexec /x` needs the file of the very package that is installed; if
   you do not have it, uninstall from the Control Panel. The installer
   itself stops and removes the version 2.6 services, and leaves the data in
   `%ProgramData%\Telecontrol\SCADA Server` (see
   [Uninstalling the Server](#uninstall)).
2. Install release 2.5.7 (`telecontrol-scada-2.5.7.msi` from the
   [releases page](https://github.com/alexsmn/scada-client/releases)) the
   way you installed version 2.5, and attach the HASP or Guardant hardware
   key.
3. On **every workstation** that got the version 2.6 package in the
   migration (step 7 above): uninstall the *ОИК Телеконтроль* program in
   *Control Panel — Programs and Features* and install the release 2.5.7
   Client the way it was installed before. The 2.5.7 installer refuses to
   install over version 2.6 on a workstation too.
4. Check that the *Telecontrol SCADA Server* service is running, and connect
   with a version 2.5 Client.

`migrate` did not change the version 2.5 `Configuration`, `History` and
`FileSystem` folders, so the 2.5 Server resumes with the data as it was at
the migration: configuration changes and archives recorded by version 2.6 are
not carried back. If the version 2.5 folders have already been deleted,
restore them from the backup made before the migration. The 2.6 process
folders (`config`, `proxy`, `historian`, `filestore` and so on) and the 2.6
license file `license.json` are not needed by version 2.5; delete them once
you are sure you will not need them.

### Rolling back a failed upgrade {#rollback-upgrade}

The same applies to an upgrade within version 2.6 (to a newer 2.6.x): the
installer refuses to install an older version over a newer one (the message
`A later version of ОИК Телеконтроль is already installed`), and restoring a
backup [on the same computer](#restore) only puts the data back under the
version that is installed now. **So back up every Server computer before every
upgrade**: without that backup there is no way back.

To go back to the previous version, on each Server computer the upgrade
reached, from an elevated command prompt:

1. Stop the processes:
   `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop`.
2. Uninstall the newer version: the *ОИК Телеконтроль* program in
   *Control Panel — Programs and Features*. The installer removes the
   services and the Server certificate from the
   `C:\Program Files\Telecontrol SCADA\data\Certificates` folder (see
   [Uninstalling the Server](#uninstall)); the data folder and the site
   certificate authority stay. `apply`
   creates the services again in step 5, and the certificate comes back from
   the backup in step 4.
3. Install the older version's package:

   ```bat
   msiexec /i telecontrol-scada-<older version>.msi /qn /norestart /l*v install.log
   ```

4. Put back, from the backup taken **before the upgrade**, the data folder
   (`%ProgramData%\Telecontrol\SCADA Server`, or the folder given as
   `--data-root`), replacing what is there, and the
   `C:\Program Files\Telecontrol SCADA\data\Certificates` folder. If the
   backup does not have it, `apply` creates a new certificate, and OPC UA
   clients that trusted the old one must be made to trust the new one. Do not keep the data the newer version worked with: whether a newer
   version changes the databases when it first starts has not been verified,
   so only the pre-upgrade backup is known to suit the older version.
5. Run `scada-setup apply` with the
   [computer's parameters](#scada-setup-options) and the same `svc` and
   `root` passwords.
6. Check the result: `scada-setup status`, then sign in from a Client.

Changes made to the configuration and values archived after the backup are
lost. If the workstations were upgraded too, uninstall the newer package on
them in the same way and install the older one (with no `scada-setup`
commands).

### Uninstalling the Server {#uninstall}

**The installer removes the services itself.** Before it deletes the
program's files, it runs `scada-setup remove`: it stops and removes the
services of every process together with their registry settings. It then deletes
this computer's [Server certificate](#opcua-certificate) and its private key
from the `C:\Program Files\Telecontrol SCADA\data\Certificates` folder —
the `ServerCertificate.pem` and `ServerPrivateKey.pem` files and the copies
`apply` set aside. **The site certificate authority** — the `ca` subfolder
on the central computer — **stays**: after a reinstall `apply` goes on using
it, and the other computers' certificates stay valid. `apply` creates the
central computer's own certificate anew, though, with a different
fingerprint. The other computers recognise it by the certificate authority,
so nothing needs changing on them; the new fingerprint is needed only to join
new computers (see
[The central computer's fingerprint changed](#central-fingerprint-changed)).
The processes'
data in `%ProgramData%\Telecontrol\SCADA Server` (configuration, users,
archives, files, the license, the [password file](#stored-passwords)) stays. If `scada-setup remove` fails, the
uninstall is cancelled and the program stays installed: services are never
left without their programs.

On every Server computer:

1. [Back up](#backup) if you may need the data or the certificate. For OPC UA
   clients to keep trusting the Server after a reinstall, save the
   `data\Certificates` folder and put it back before `apply`, or uninstall
   with the `SCADA_KEEP_CERTIFICATES=1` parameter (step 2), with which the
   installer deletes nothing from the folder.

   **If the computer leaves the site for good**, uninstall with the
   `SCADA_PURGE_CERTIFICATES=1` parameter: the whole `data\Certificates`
   folder is then deleted, on the central computer together with the site
   certificate authority (the `ca` subfolder with the `ca_key.pem` key). On
   the central computer do this only when the site is no longer needed:
   after a reinstall `apply` creates a new certificate authority, and every
   other computer of the site has to join again (see
   [A new certificate authority](#opcua-renewal)).
2. Uninstall the program: the *ОИК Телеконтроль* program (publisher
   ООО Телеконтроль) in *Control Panel — Programs and Features*, or from an
   elevated command prompt:

   ```bat
   msiexec /x telecontrol-scada-<version>.msi /qn /norestart /l*v uninstall.log
   ```

   `msiexec /x` needs the file of the very package that is installed; if
   you do not have it, uninstall from the Control Panel. The computer's
   Client is uninstalled with the program.

   If the uninstall is cancelled with an error, look for the
   `ScadaSetupRemoveServices` action in `uninstall.log`, and check the
   services with
   `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" status`.
   If `scada-setup` itself does not start, remove the services with the
   Windows tools and uninstall with the `SCADA_KEEP_SERVICES=1` parameter,
   which skips that step:
   `msiexec /x telecontrol-scada-<version>.msi SCADA_KEEP_SERVICES=1 /l*v uninstall.log`.
3. If the data is no longer needed, delete the
   `%ProgramData%\Telecontrol\SCADA Server` folder — the processes' data, the
   license file and, if a migration from version 2.5 was done, the
   version 2.5 folders. The `C:\Program Files\Telecontrol SCADA` folder stays
   after the uninstall: it holds the `data\Certificates` folder with the site
   certificate authority (on the central computer) and the certificates the
   processes trust. Delete it as a whole only when the computer leaves the
   site for good (or uninstall with `SCADA_PURGE_CERTIFICATES=1`).
4. Delete the firewall rules created in
   [Network preparation]({{ '/en/getting-started/' | relative_url }}#network)
   (for a rule the computer does not have, `netsh` reports that no rules
   match, which is harmless):

   ```bat
   netsh advfirewall firewall delete rule name="Telecontrol SCADA Clients"
   netsh advfirewall firewall delete rule name="Telecontrol SCADA OPC UA"
   ```

   Delete in the same way any rule you created for links that accept
   connections (for example port 2404), by the name you gave it.

### Console mode {#console}

For diagnostics, a Server process can run in a console window: it works as
the service does and prints its log to the screen. The installer creates no
shortcut for this.

1. Stop the process's service (for example *Telecontrol SCADA IEC 104*): the
   process and its service cannot run at the same time — they use the same
   ports and files.
2. Open an elevated command prompt: without administrator rights the process
   cannot read the [Server certificate](#opcua-certificate)'s private key and
   does not start.
3. Set the `svc` password the service gets from `scada-setup`, and start the
   process with its parameter file:

   ```bat
   set SCADA_SVC_PASSWORD=<svc password>
   "C:\Program Files\Telecontrol SCADA\bin\scada-iec104.exe" --param "%ProgramData%\Telecontrol\SCADA Server\iec104\server.json"
   ```

   The executable is `scada-<process>.exe`; the parameter file's folder is
   `config`, `proxy`, `historian`, `filestore` (for `scada-filesystem`),
   `modbus`, `iec104`, `iec61850`, `opc` or `vidicon`.
4. To finish, close the window or press *Ctrl+C*, then start the process's
   service again (the Windows Services UI), or all of the computer's processes
   with `scada-setup start` and the
   [computer's parameters](#scada-setup-options).

Without `SCADA_SVC_PASSWORD` the process cannot connect to the other
processes. Console mode does not need `SCADA_ROOT_PASSWORD`: without it the
process leaves the `root` password the service stored unchanged (see
[Root password](#root-password)).

## Command-line options

The most important server startup options are:

| Option | Purpose |
|---|---|
| `--install` | Install the Server as a Windows service (hand-built setups without `scada-setup` only) |
| `--uninstall` | Remove the Windows service (hand-built setups without `scada-setup` only) |
| `--service` | Run in service mode (used by Windows) |
| `--param <path>` | Use a specific parameter file. The default on Windows is `%ProgramData%\Telecontrol\SCADA <process>\<name>.json` (for example `%ProgramData%\Telecontrol\SCADA IEC 104\scada-iec104.json`); on Linux it is `<name>.json` in the `data` directory beside the executable's directory |
| `--name <name>` | Override the Windows service name, so several services of one process can coexist on a machine |
| `--display-name <name>` | Override the service display name and the console window title |
| `--log-severity <level>` | Lowest level of the log messages, as the [`log.severity`](#logging) parameter; takes priority over it |

Processes installed by `scada-setup` are started with a `--param` naming
`%ProgramData%\Telecontrol\SCADA Server\<process folder>\server.json`.

### Linux deployment {#linux}

On Linux the Server is installed from a `.deb` package or a `.tar.gz`
archive into `/opt/telecontrol-scada` and set up with the same `scada-setup`
program (run it with `sudo`): `apply` creates the parameter files in
`/var/lib/scada/<process>/server.json`, the configuration databases, the
[Server certificate](#opcua-certificate) in
`/opt/telecontrol-scada/data/Certificates`, and one systemd service per
process — `/etc/systemd/system/scada-<process>.service` — then enables them
and starts them in the right order; `status`, `start`, `stop`, `remove` and
`set-password` manage those services. The step-by-step installation is in
[Installation on Linux]({{ '/en/getting-started/' | relative_url }}#linux).

* The services run as the system account `scada`, start at boot and are
  restarted 10 seconds after a failure. As on Windows, on a computer with `scada-config` the other
  services depend on `scada-config.service`, and `scada-proxy.service` also
  on `scada-filesystem.service`: stopping a service stops the ones that
  depend on it.
* `apply` rewrites the service file on every run: put your own changes not
  in it but in the `server.override.json` parameter file (see
  [Your own parameters](#server-override)) or in a systemd drop-in
  (`systemctl edit scada-<process>`).
* A service's state is `systemctl status scada-<process>`; the process's
  messages are `journalctl -u scada-<process>` and the log in the
  `/var/lib/scada/<process>/Logs` folder.
* `migrate --execute` is not available on Linux: the version 2.5 Server ran
  on Windows only.

#### Running without scada-setup

The process executables can also be started by hand, for example in a
Docker container. Each process reads its own parameter file
`data/<name>.json`, where `data` is resolved from the executable's directory
as `<program dir>/../data`, or the file passed with `--param`.

Environment variables can be substituted into the parameter file
(`$ENV{NAME}`, see the [parameter reference](#parameters)), for example to
keep the [root password](#root-password) out of the file. Installation in
Docker containers is available on request.

## Licensing

Each Server process needs a signed license file. The license states an
expiry date and the processes purchased; a process the license does not name
will not run. No hardware key is used.

The settings live in the `license` block of the parameter file:

```json
"license": {
    "file": "C:\\ProgramData\\Telecontrol\\SCADA Server\\license.json"
}
```

| Parameter | Default | Description |
|---|---|---|
| `file` | `license.json` | Path to the license file. A relative path resolves against the process's working directory, so an absolute path is safer. When the parameter is absent, the `SCADA_SERVER_LICENSE_FILE` environment variable is used |

Parameter files written by [`scada-setup`](#scada-setup) already carry the path `%ProgramData%\Telecontrol\SCADA Server\license.json` (on Linux `/var/lib/scada/license.json`; or the one given with `--license`).

A license issued for a Google Cloud virtual machine verifies only on that machine. Any other license is bound to no computer and needs no setting. The `require_gcp_binding` parameter and the `SCADA_SERVER_LICENSE_REQUIRE_GCP_BINDING` environment variable no longer have any effect: if an older parameter file still has them, the process logs a warning and ignores them. Remove them.

The license is checked at startup and then every 5 seconds:

* **No valid license**, or one that does not include this process — the
  process stops. The reason is written to the log. The process does the same
  when the file is missing, only partly written or, on Linux, not readable
  by the `scada` account at the moment it is checked. The service then exits
  normally and neither Windows nor systemd restarts it — once the file is fixed, start the processes with `scada-setup start`
  and the [computer's parameters](#scada-setup-options). A license whose
  validity period has not started yet counts as not valid too.
* **The license could not be verified** (for example, the Google Cloud
  metadata server did not answer) — the process keeps running but serves no
  requests until verification succeeds.
* **The license has expired** — the process keeps running but refuses
  requests. Once the license file is replaced, service resumes without a
  restart.

With an expired license `scada-setup` warns that it has expired but still
goes by the processes the license names: `apply` without `--tiers` installs
exactly those. `scada-setup apply` does not accept a license whose validity
period has not started yet.

`scada-setup status` shows the license id and when the license expires. The
id names whom the license was issued to; quote it when asking Telecontrol
about the license. During the last 30
days the Server also raises a daily system event about the expiry, but it is
visible only in the Client.

Replace the license file in one step: copy the new file into the same folder
under a temporary name and rename it to `license.json` over the old one
(`move /y`; on Linux `mv -f`) — see [License]({{ '/en/getting-started/' | relative_url }}#license).

Versions 2.5 and earlier used a HASP or Guardant hardware key, and ran for two
hours in demo mode without one. **Version 2.6 has no demo mode**: without a
license the Server processes do not run. To evaluate the system or to order a
license, contact Telecontrol (mail@telecontrol.ru) and name the processes the
site needs (see
[Choose the Server processes]({{ '/en/getting-started/' | relative_url }}#choose)).

## Configuration storage

The configuration database is stored in the directory named by
`configuration.dir` in the process's parameter file; `${DIR_PARAM}/Configuration`,
beside the parameter file, is a convenient choice. Without the parameter, the
database is created in the executable's directory. SQLite is
supported out of the box, and PostgreSQL can be used when a separate
database server is required.

### SQLite

SQLite is the default embedded configuration database:

```json
"configuration": {
    "driver": "SQLite",
    "dir": "${DIR_PARAM}/Configuration"
}
```

### PostgreSQL

For distributed installations or stricter reliability requirements,
PostgreSQL is also supported:

```json
"configuration": {
    "driver": "PostgreSQL",
    "connection-string": "postgresql://user:password@localhost:5432/scada"
}
```

### Migration from GigaBASE {#migration}

GigaBASE support was removed starting with version 2.1, and
`scada-setup migrate` moves an SQLite configuration only. If a site's
configuration is still kept in GigaBASE, first convert it to SQLite and run a
version 2.5 Server on it, and only then run `scada-setup migrate` (see
[Upgrading from version 2.5](#upgrade-2-5)). The conversion needs the
version 2.0 administration utility; it is not published on the releases page
— request it from Telecontrol (mail@telecontrol.ru).

## Historical databases {#history}

Historical databases are stored in
[SQLite](https://www.sqlite.org/index.html) format.

The system historical database stores audit events and the latest object
values. User historical databases store value changes and events for
configured objects. Multiple user historical databases can exist at the
same time, and the Server manages the required files automatically.

Historical databases are kept by the `scada-historian` process, in the
folder named by `history.dir` in its parameter file; `scada-setup` sets
`%ProgramData%\Telecontrol\SCADA Server\historian\History`. (A version 2.5
Server kept them in `%ProgramData%\Telecontrol\SCADA Server\History`;
[upgrading from version 2.5](#upgrade-2-5) copies them to the new folder.)
Each database has its own subfolder named by its numeric id, except the
system database, whose folder is `System`.

Each object can be assigned to one historical database. If an object is
deleted or moved to a different database, its associated historical data
in the previous database is removed.

Each database has a configured retention depth, and the Server cleans up
old records automatically.

### Disk-space estimate

New databases are created with SQLite's standard page size of 4 KB;
databases carried over from earlier versions keep theirs. For the permitted
sizes, see the [SQLite limits](https://sqlite.org/limits.html).

One [object]({{ '/en/architecture/' | relative_url }}#data-items) record
takes less than 100 bytes. So the expected database size in MB is:

`size = freq * depth / 10000`

where:

* `size` is the expected database size in MB
* `freq` is the number of value changes per day
* `depth` is the retention depth in days

Or, with a known amount of free disk space, the maximum retention depth in
days is `depth = size * 10000 / freq`.

### Working with SQLite directly

For administration and diagnostics, a history database can be opened with
the `sqlite3` command-line tool. Version 2.6 does not install it (versions 2.5
and earlier did); download it from the
[SQLite download page](https://sqlite.org/download.html). The database file is
named `history` and sits in the database's folder: change to that folder and
run `sqlite3 history`. Open a database for writing only while its process is
stopped (`scada-setup stop`).

The Server maintains its databases automatically, so this is optional. A
convenient graphical tool is the free
[SQLiteStudio](https://sqlitestudio.pl/). `sqlite3` runs SQL queries and a
number of special commands; see the [SQLite documentation](https://sqlite.org/cli.html).

#### Examples

The database page size:

```SQL
sqlite> pragma page_size;
4096
```

The tables: parameter values (`timed_data`), the latest object values
(`items_info`), and one table per event type:

```SQL
sqlite> .tables
AuditActivateSessionEventType  OperatorActionAuditEventType
AuditUpdateMethodEventType     SystemEventType
DeviceWatchEventType           items_info
ItemAlarmEventType             timed_data
```

A database carried over from an earlier version may also have an
`events_v1_backup` table — the original old-format event table, whose data
has already been moved to `SystemEventType`.

The schema of the system events table:

```SQL
sqlite> .schema SystemEventType
CREATE TABLE SystemEventType(EventID INTEGER PRIMARY KEY NOT NULL, Time INTEGER NOT NULL, ReceiveTime INTEGER NOT NULL, ChangeMask INTEGER, Severity INTEGER, NodeNS INTEGER NOT NULL, NodeID INTEGER NOT NULL, UserID INTEGER, Value FLOAT, Qualifier INTEGER, Message TEXT, Acked BOOLEAN NOT NULL, AckTime INTEGER, AckUserID INTEGER, SourceName TEXT, MessageLocale TEXT, SourceNameLocale TEXT);
CREATE INDEX SystemEventType_TimeIndex ON SystemEventType(Time);
CREATE INDEX SystemEventType_NodeIndex ON SystemEventType(NodeNS, NodeID);
```

The number of system events in the archive:

```SQL
sqlite> select count(*) from SystemEventType;
86
```

## Server-side file system {#filesystem}

The server-side file system stores schematic files on the Server so they
can be provided to all Clients without manual synchronization.

The file system is kept by the `scada-filesystem` process, and the parameter
file `scada-setup` writes already enables it. In a hand-built setup, enable it
in the process's `server.json`:

```json
"filesystem": {
    "enabled": true,
    "dir": "${DIR_PARAM}/FileSystem"
}
```

The files are stored in the folder named by `dir`; `scada-setup` sets
`%ProgramData%\Telecontrol\SCADA Server\filestore\FileSystem`. (A version
2.5 Server kept them in `%ProgramData%\Telecontrol\SCADA Server\FileSystem`;
[upgrading from version 2.5](#upgrade-2-5) copies them to the new folder.)

Files are managed from the Client
[Files]({{ '/en/dev/server-files/' | relative_url }}) window.

## Logging {#logging}

Each process writes text log files named
`scada-<process>_<date>_<time>-<number>.log` (for example
`scada-iec104_2026-10-04_08-00-00-0.log`). For processes installed by
`scada-setup`, the logs are in the `Logs` folder of the process folder:
`%ProgramData%\Telecontrol\SCADA Server\<process folder>\Logs`. Settings:

| Parameter | Default | Description |
|---|---|---|
| `log.dir` | `%ProgramData%\Telecontrol\SCADA Server\logs` (on Linux, `Telecontrol/SCADA Server/logs` under the process's working directory) | Log-directory path |
| `log.max_file_size` | `10` | Maximum size of one log file in MB |
| `log.max_total_size` | `100` | Maximum total log size in MB |
| `log.max_count` | `1000` | Maximum number of log files |
| `log.severity` | — | Lowest level of the messages written to the log files (and anywhere else): `Trace`, `Debug`, `Info`, `Warning`, `Error` or `Critical`. Not set — messages of every level are written to the files |
| `log.console_severity` | — | Lowest level of the messages printed **to the screen** in [console mode](#console), from the same values. Does not affect the log files |

A new file is started when the current one reaches its maximum size, and
every day at midnight. Old files are deleted automatically when the total
size or file count limit is exceeded.

If the parameter file cannot be read (for example after a mistake while
editing it), the process writes the reason to a log in the `Logs` folder
beside the parameter file — for processes installed by `scada-setup` that is
their usual log folder — and does not start. An error in the `log` block (for
example an unknown level) is written to a log with the default settings in the
`log.dir` folder.

## Monitoring {#monitoring}

* **Service, license and certificate state** — `scada-setup status` on each
  computer (it needs no administrator rights): the license expiry, the
  processes it entitles, this computer's [Server certificate](#opcua-certificate)
  and the state of each process's service. It prints, for
  example:

  ```text
  License: C:\ProgramData\Telecontrol\SCADA Server\license.json (onprem-example-20260131, expires 2027-01-31T00:00:00Z)
  Entitled tiers: config filesystem historian iec104 proxy
  OPC UA certificate: C:\Program Files\Telecontrol SCADA\data\Certificates\ServerCertificate.pem
    SHA-256 fingerprint: 30:CE:C4:DB:...:66:6F
    Valid from 2026-11-07 to 2031-11-06 (UTC)
    Issued by the site CA: links are encrypted
  Site CA: C:\Program Files\Telecontrol SCADA\data\Certificates\ca\ca.pem (this is the central computer)
    Valid from 2026-11-07 to 2036-11-05 (UTC)
    Other computers join the site with --central-fingerprint 30:CE:C4:DB:...:66:6F
  config       SERVICE_RUNNING
  historian    SERVICE_RUNNING
  filesystem   SERVICE_RUNNING
  modbus       not installed
  iec104       SERVICE_RUNNING
  iec61850     not installed
  opc          not installed
  vidicon      not installed
  proxy        SERVICE_RUNNING
  ```

  The processes on the `Entitled tiers` line are listed in alphabetical
  order. Under `OPC UA certificate` come the SHA-256 fingerprint of this
  computer's certificate, the dates it is valid from and to, and whether the
  [site certificate authority](#opcua-site-ca) issued it (if not, its
  connections are unencrypted). The `Site CA` lines appear on the central
  computer only: the certificate authority's dates, and the fingerprint the
  other computers join the site with (`--central-fingerprint`). Below that, without `--tiers`, come all nine processes in their start
  order: a running service shows `SERVICE_RUNNING`, a stopped one
  `SERVICE_STOPPED`, and one the computer does not have `not installed`.
* **Process logs** — see [Logging](#logging). Why a process stopped (license,
  certificate, an error in the parameter file) is written to its log.
* **Links between processes** — if a protocol process's log shows
  `Bad_UserAccessDenied`, its computer was given a different `svc` password
  (see [The svc account](#svc)).
* **Archive writing** — the Client's `More -> Databases` window shows, for
  each archive, how many values were written and the write queue (see
  [Databases]({{ '/en/client/workbench/' | relative_url }}#historical-db)).
  After a protocol process's service restarts, automatically after a failure
  included, archiving of its objects' values resumes by itself, usually
  within a minute (see [After a protocol process restarts](#edge-restart)).
  If the written-values count stays flat for longer while object values
  change in the Client, contact Telecontrol (mail@telecontrol.ru).

## Client connections {#sessions}

The `sessions` parameter defines the addresses and ports used for client
connections. By default, the Server listens on all network interfaces
(`0.0.0.0`) on port `2000`.

```json
"sessions": [
    "tcp;passive;host=0.0.0.0;port=2000"
]
```

Multiple connection endpoints can be configured if different interfaces
or ports are required.

## Root password {#root-password}

The built-in `root` account has all rights and always exists, whatever
the configuration contains. Its password is set with
`security.rootPassword`:

```json
"security": {
    "rootPassword": "$ENV{SCADA_ROOT_PASSWORD}"
}
```

**WARNING:** without this parameter, `root` is given an empty password
on first start and the Server accepts `root` with no password (a warning
is written to the log). Set a password before the Server is reachable
over the network.

A configured value is authoritative: it is written on every start and
replaces any password stored earlier. So while the parameter is set, the
process refuses a root password change made from the Client or an OPC UA
client (status `Bad_NotWritable`), and the Client reports the refusal in
the event journal, naming the `scada-setup set-password` command. The
other accounts' passwords change as usual. Without the parameter, a root
password changed from the Client is kept. To keep the password out of the
file in plain text, pass it through an environment variable as in the
example above.

**`scada-setup` sets it** (on Windows and on Linux): the parameter files it writes for
`scada-config` and `scada-filesystem`
contain `"rootPassword": "$ENV{SCADA_ROOT_PASSWORD}"`, and `scada-setup apply`
takes the variable's value from `--root-password` (or the
`SCADA_SETUP_ROOT_PASSWORD` environment variable) and stores it in the
computer's [password file](#stored-passwords). On a computer running one of those
processes, `apply` refuses to run without it. To change the root password,
run `scada-setup set-password --root-password <new password>`: the command
stores the password and restarts the computer's services (see
[Changing the svc password](#svc-rotate)). Do not edit the generated parameter files,
which the next `apply` rewrites.

Set the parameter on **every** process that keeps the configuration in
its own database; each of them has its own `root` account: `scada-config`
and `scada-filesystem`. The protocol processes, `scada-historian` and
`scada-proxy` receive their configuration from `scada-config` and do not
use this parameter (they log a message saying so); a `root` sign-in through
`scada-proxy` is checked against `scada-config`'s `root` password.

A process takes the `SCADA_ROOT_PASSWORD` value from the computer's
[password file](#stored-passwords), which it finds through the
`SCADA_SECRETS_FILE` variable in its service settings; when there is no such
file or no password in it, from the environment variable of the same name.
Started without either (for example in [console mode](#console)), it leaves
the stored `root` password unchanged and writes a warning to its log.

## The svc account {#svc}

The Server processes connect to each other as the `svc` service account
(id 100). `scada-setup apply` creates it in the configuration databases and
stores its password, from `--svc-password`, in the computer's
[password file](#stored-passwords), where the processes read it.
`scada-config` and `scada-filesystem` write
that password into their databases on every start, so **every computer of the
site must be given the same `svc` password**.

* **The `svc` account cannot be changed in the Client's *Users* window**:
  the server refuses to delete, rename or disable it, or to change its
  password or roles, because that would break the links between the
  processes. If it is missing anyway (for example from a database copied
  from another site), `apply` restores it: on the central computer, stop the
  processes (`scada-setup stop`) and run `apply` with the same `svc` password
  (see [Re-running apply](#reapply)).
* When the passwords differ, the protocol process keeps running but gets no
  configuration, and its [log](#logging) shows `Bad_UserAccessDenied`. Run
  `set-password` on that computer with the central computer's `svc` password
  (see [Changing the svc password](#svc-rotate)).

### Changing the svc password {#svc-rotate}

The `set-password` command stores the new password in the
[password file](#stored-passwords), restarts this computer's process services
and starts every installed process service, **stopped ones included**. Do not
run it while any process of this computer runs in [console mode](#console):
that process's service would be started alongside it. From an elevated
command prompt:

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" set-password --svc-password <new password>
```

**Run it on every Server computer, in this order:**

1. on the central computer (the one with `scada-config`) — its processes
   write the new password into their databases and connect to each other
   with it straight away;
2. then on each computer of protocol processes. Their objects are marked bad
   during the restart and then update again by themselves (see
   [After a protocol process restarts](#edge-restart)).

Until the command has run on a computer, its processes present the old
password: they keep running but get no configuration, and the log shows
`Bad_UserAccessDenied`. So change it on all computers in one go, in a
maintenance window.

With `--root-password <new password>` the command changes this computer's
[root password](#root-password) the same way; both can be given together.
If the Server was installed by a pre-release build of version 2.6 and the
computer has no password file yet, the command requires both passwords — on a
computer running `scada-config` or
`scada-filesystem` — and changes nothing until it has them: otherwise the
`root` password would be lost when it leaves the registry.

## OPC UA server {#opcua}

The Server can expose data to external systems through
[OPC UA](https://opcfoundation.org/about/opc-technologies/opc-ua/).
When enabled, external clients can browse the Server address space,
including objects, devices, and current or historical data.

In an installation made by `scada-setup`, OPC UA is enabled on every process
(ports 4840–4848, see
[Network preparation]({{ '/en/getting-started/' | relative_url }}#network)):
the processes exchange data with each other over it.

The processes connect to each other encrypted (the Basic256Sha256 policy,
Sign & Encrypt mode) as the [`svc`](#svc) account. Each process other than
`scada-config` accepts only computers whose certificate was issued by the
[site's certificate authority](#opcua-site-ca) or moved into the `trusted`
folder. `scada-config` (port 4841) accepts a secure connection with any
certificate, because a computer joining the site reaches it before it has a
certificate of its own. But it gives nothing without a sign-in, and it issues
a site certificate to the `svc` account only: no user — not `root`, not an
administrator, not a user with the Configure right — can obtain one, and the
Client cannot give that right to anyone. So joining a computer to the site
takes the `svc` password; keep it as you keep the `root` password.

A Server process may register with `scada-proxy` and `scada-config` — and
`scada-proxy` then treats it as one of the site's processes — only when it
connects with a certificate the [site's certificate authority](#opcua-site-ca)
issued, and only under a name that certificate carries. A certificate moved
into the `trusted` folder lets a system connect, never register. No process accepts unsecured connections (policy None) or
anonymous sign-in, `scada-proxy`'s port 4840 included, which is where
external systems connect — unless `apply` on the computer with `scada-proxy`
was run with `--allow-anonymous-opcua` (see
[Connecting an external system](#opcua-external)). No process accepts a
password sent unencrypted. So, still:

* open the OPC UA ports to the site's computers only (see
  [Network preparation]({{ '/en/getting-started/' | relative_url }}#network));
* if an external system must connect to the Server, allow it port 4840
  (`scada-proxy`) in the firewall from its address only.

**WARNING:** a computer without `scada-config` set up without
`--central-fingerprint` gets a self-signed certificate, and on a site with a
certificate authority its processes **cannot connect** to the others at all:
those refuse unsecured connections and passwords sent unencrypted, and do not
trust its certificate. So `apply` with `--central` but with neither
`--central-fingerprint` nor `--insecure-links`, on a computer that has no
certificate from the certificate authority yet, fails and changes nothing. Only a site whose computers
are all set up with [`--insecure-links`](#scada-setup-options) runs
unencrypted, sending the `svc` password in clear text; on such a site the
firewall is the only protection.

```json
"opcua": {
    "enabled": true,
    "url": "opc.tcp://localhost:4840",
    "server_private_key": "${DIR_PARAM}/Certificates/ServerPrivateKey.pem",
    "server_certificate": "${DIR_PARAM}/Certificates/ServerCertificate.pem",
    "trace": "none"
}
```

| Parameter | Description |
|---|---|
| `enabled` | Enable the OPC UA server |
| `url` | OPC UA endpoint address |
| `server_private_key` | Path to the private key in PEM format |
| `server_certificate` | Path to the certificate in PEM format |
| `trace` | Diagnostic level: `none`, `error`, `warning`, `info`, `debug`, `all` |

### Connecting an external system {#opcua-external}

An external OPC UA system — a higher-level system, another vendor's SCADA —
connects to `scada-proxy`'s port 4840. On a site with encryption (set up
without `--insecure-links`) that port accepts only secured connections
(Sign & Encrypt mode) that sign in with a user name and password:

1. Create a user with the rights it needs for the system in the Client's
   [Users]({{ '/en/client/workbench/' | relative_url }}#users) window.
2. Connect the system to `opc.tcp://<computer with scada-proxy>:4840` in
   Sign & Encrypt mode as that user. The first connection is refused:
   `scada-proxy` does not trust the system's certificate and writes it into
   the `data\Certificates\rejected` folder of the installation folder.
3. Move that file into the `data\Certificates\trusted` folder beside it and
   restart the *Telecontrol SCADA Proxy* service (Control Panel — Services;
   on Linux, `systemctl restart scada-proxy`): the process reads its trusted
   certificates when it starts. The restart briefly cuts the Clients off the
   Server.

**WARNING:** every process of the computer trusts the `trusted` folder, so a
system with a certificate there can open a secure connection to any of them,
not only to port 4840 — what it may then do is decided by the user it signs in
as. It cannot register with `scada-proxy` or `scada-config` as a Server
process: they accept that only from a certificate the site's certificate
authority issued. Move into `trusted` only the certificates of systems you
mean to let in; in the firewall, open only port 4840 to such a system, from
its address only; remove its certificate from `trusted` once the system no
longer connects.

If the system can do neither encryption nor sign-in with a user name — as
many systems that connected to a 2.5 Server cannot — run `apply` on the
computer with `scada-proxy` with
[`--allow-anonymous-opcua`](#scada-setup-options), together with the
computer's other parameters. Port 4840 then also accepts unsecured
connections (policy None) and anonymous sign-in: **anyone who reaches the
port can browse and read the Server's address space** — the objects and
their values — but not change it or send commands. The port still never
accepts a password sent unencrypted. Allow port 4840 in the firewall from
that system's address only. The other processes refuse anonymous sign-in
even with this option. On a site set up with `--insecure-links`, port 4840
accepts unsecured connections and anonymous sign-in without it.

### Server certificate {#opcua-certificate}

Secured connections (the Basic256Sha256 policy, Sign & Encrypt mode) need a
private key and a certificate in PEM format, named by `server_private_key` and
`server_certificate`:

* an RSA key (2048 bits recommended) **without a passphrase**;
* when the parameters are absent, the process offers unsecured connections
  only (policy None);
* **when the parameters are set but a file is missing or unreadable, the
  process does not start** — the log shows `Can't open file` or
  `Failed to parse OPC UA server certificate PEM`.

Parameter files written by [`scada-setup`](#scada-setup) point at
`C:\Program Files\Telecontrol SCADA\data\Certificates\ServerCertificate.pem`
and `ServerPrivateKey.pem`. The installer does not contain these files —
**`scada-setup apply` creates them when they are not there yet**:

* a 2048-bit RSA key without a passphrase and a SHA-256 certificate valid
  for 5 years, issued by the [site's certificate authority](#opcua-site-ca)
  (self-signed with `--insecure-links`, or on a computer that joined without
  `--central-fingerprint`);
* the certificate lists the identifiers (ApplicationUri) of every process
  `apply` enables on this computer, the computer's name, `localhost`,
  `127.0.0.1`, and the `--advertise` address when one is given;
* only the SYSTEM account the services run as, and administrators, can read
  the key file.

One pair serves every process on the computer. `apply` replaces existing
files only to get off a self-signed pair once the site's certificate
authority can issue one: it keeps the old files beside the new ones, as
`ServerCertificate.pem.self-signed` and `ServerPrivateKey.pem.self-signed`.
When a process that the certificate does not list is enabled after the pair
was created, `apply` gets a new certificate from the site's certificate
authority that lists it, and keeps the old files beside the new ones as
`ServerCertificate.pem.previous-uris` and `ServerPrivateKey.pem.previous-uris`:
`scada-proxy` and `scada-config` accept a process's registration only under an
identifier its certificate lists. Where no certificate authority can issue
one (a site set up with `--insecure-links`), `apply` instead prints a warning
naming the identifier: that process cannot register, and third-party OPC UA
clients that check the certificate may refuse to connect to it. When only one of the two files exists, `apply` stops and names the
missing one.

**To replace the certificate** — to issue a new one, include processes added
since, or use a certificate from your own certificate authority:

1. Stop the processes:
   `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop`.
2. Delete both files from `C:\Program Files\Telecontrol SCADA\data\Certificates`,
   or put your own pair in their place (the key in PEM format, without a
   passphrase; restrict access to it as described below).
3. Run `scada-setup apply` with the same
   [computer's parameters](#scada-setup-options) and passwords as at
   installation, including `--central-fingerprint` on a computer without
   `scada-config`: a missing pair is created again, and the processes start.

You can also create a self-signed pair of your own with
[OpenSSL](https://www.openssl.org/) (not part of Windows; it comes, for
example, with Git for Windows). Save this as `cert.cnf`:

```ini
[req]
distinguished_name = dn
x509_extensions = v3
prompt = no

[dn]
O = Telecontrol
CN = Telecontrol SCADA Server

[v3]
basicConstraints = critical, CA:TRUE
keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyCertSign
extendedKeyUsage = serverAuth, clientAuth
subjectKeyIdentifier = hash
subjectAltName = @san

[san]
URI.1 = urn:telecontrol:scada:server
URI.2 = urn:SCADA-HOST:scada:historian
DNS.1 = SCADA-HOST
DNS.2 = localhost
IP.1 = 127.0.0.1
```

and run:

```bat
openssl req -x509 -nodes -newkey rsa:2048 -sha256 -days 1826 ^
    -keyout ServerPrivateKey.pem -out ServerCertificate.pem -config cert.cnf
```

In `[san]`, replace `SCADA-HOST` with the computer's name and list the
identifiers (ApplicationUri) of every process running on it:
`urn:telecontrol:scada:server` for `scada-config` and `scada-proxy`, and
`urn:<computer name>:scada:<process>` for the others (for example
`urn:SCADA-HOST:scada:iec104`). The OPC UA specification requires the
certificate to carry the application's identifier, and the Server's processes
check it, as third-party OPC UA clients do. **The other processes refuse a
self-signed pair**: a pair of your own must be issued by the site's
certificate authority, or by one whose certificate you put in the `issuer`
folder on every computer of the site. Copy both files to the folder the parameters name, and
restrict access to the key file to the SYSTEM account and administrators
(the groups are given by identifier, so the command works on Windows in any
language):

```bat
icacls "C:\Program Files\Telecontrol SCADA\data\Certificates\ServerPrivateKey.pem" /inheritance:r /grant:r *S-1-5-18:F *S-1-5-32-544:F
```

**Client certificates.** In an installation made by `scada-setup`, every
process except `scada-config` accepts on secured connections only the
certificates the site's certificate authority issued or that were moved into
the `trusted` folder: its `opcua` block names the `issuer`, `trusted` and
`rejected` folders under `data\Certificates`. `scada-config` accepts any
client certificate, because a computer joining the site connects to it
before it has a certificate of its own; everything `scada-config` serves
requires a sign-in, and it issues a site certificate only to the `svc`
account. `scada-config` and `scada-proxy` accept a process's registration
only over a connection whose certificate the site's certificate authority
issued — the `opcua.register_trust` block names the `issuer` folder and not
`trusted` — and only under an identifier (ApplicationUri) that certificate
lists. The folders are:

| Parameter | Description |
|---|---|
| `trusted_certificates_dir` | Trusted client certificates (PEM or DER); a client is accepted when its certificate is in this folder |
| `issuer_certificates_dir` | Certificate authority certificates; a client whose certificate they signed is accepted |
| `crl_dir` | Revocation lists for those authorities |
| `rejected_certificates_dir` | Rejected client certificates are written here, to be moved to the trusted folder if wanted |

Further restrictions go in the `opcua.security` block:
`"allow_none": false` forbids unsecured connections,
`"require_encryption_for_password": true` forbids sending a password
unencrypted, and `"require_trusted_client_cert": true` keeps the process
from starting without a trusted-certificate folder, and
`"allow_anonymous": false` forbids anonymous sign-in (allowed by default).
The desktop Client checks no Server certificate when it signs
in with the "Telecontrol" type (TCP port 2000); when it signs in with the
"OPC UA" type in the "Most secure available" or "Sign and encrypt" mode it checks the certificate, and asks
you to confirm trust in it on the first connection (see
[Checking the Server's certificate]({{ '/en/getting-started/' | relative_url }}#server-certificate-check)).

`scada-setup` sets these itself: `"allow_none": false`,
`"allow_anonymous": false` and `"require_encryption_for_password": true` on
every process; with `--allow-anonymous-opcua`, `"allow_none": true` and
`"allow_anonymous": true` on `scada-proxy`.

**WARNING:** in an installation made with `--insecure-links`, the processes
connect to each other unsecured and send the `svc` password unencrypted, so
there **`"allow_none": false` and `"require_encryption_for_password": true`
break the links between the processes**.

### Site certificate authority {#opcua-site-ca}

The processes trust each other because one certificate authority issued all
their certificates: the site's own, kept on the central computer.

* **The central computer** (the one running `scada-config`): the first
  `apply` creates the certificate authority in
  `C:\Program Files\Telecontrol SCADA\data\Certificates\ca` and issues
  the computer's own certificate from it. It then prints the line the other
  computers need:

  ```
  Links are encrypted (SignAndEncrypt). Join the other computers of the site with
    --central-fingerprint 30:CE:C4:DB:...:66:6F
  ('scada-setup status' prints it again)
  ```

  **The `ca_key.pem` file is the key that issues every certificate of the
  site.** On Windows only the SYSTEM account and administrators can read
  it. On Linux it belongs to `root` and the `scada` group (mode 0640): any
  Server process on the central computer can read it, so run nothing but the
  Server services as the `scada` account. Back it
  up with the configuration, and never copy it to another computer.
* **Every other computer**: give `apply` that fingerprint with
  `--central-fingerprint`. `apply` then:
  1. checks that the central computer's certificate has that fingerprint,
     and stops, changing nothing, when it does not, so the `svc` password
     goes to no other computer;
  2. signs in to `scada-config` as `svc`;
  3. creates this computer's key, which never leaves it, and gets a
     certificate for it from the certificate authority;
  4. writes parameter files in which every connection is encrypted.

  The colons and letter case of the fingerprint do not matter. Every
  `apply` on the central computer prints it again, and
  [`scada-setup status`](#monitoring) on the central computer shows it at any
  time (the `Other computers join the site with --central-fingerprint …`
  line); [OpenSSL](https://www.openssl.org/) shows it too:
  `openssl x509 -in ServerCertificate.pem -noout -fingerprint -sha256`.

  The fingerprint is needed only to join. A computer that has joined keeps
  the certificate authority's certificate, and later `apply` runs check the
  central computer's certificate against it rather than against the
  fingerprint.

When `apply` on another computer reports:

* `presented a certificate with fingerprint …, not the … given` — the
  fingerprint is mistyped, `--central` names another computer, or the
  central computer has had a new certificate authority since and the
  fingerprint given is the old one. `scada-setup status` on the central
  computer prints the current fingerprint. Replacing only the central
  computer's certificate does not cause this error (see
  [The central computer's fingerprint changed](#central-fingerprint-changed)).
* `presents a certificate (fingerprint …) that the site CA this computer holds
  did not issue` — this computer has joined, and the central computer has
  since got a new certificate authority (or `--central` names another
  computer). Run `apply` with `--central-fingerprint` and the fingerprint
  that `scada-setup status` prints on the central computer.
* `cannot sign in to scada-config … as svc` — the `svc` password differs
  from the central computer's. **After five failed sign-ins, `scada-config`
  refuses that computer for 15 minutes**, even with the right password.
* `the central computer's certificate does not name the address` — the
  other computers reach the central one by an address its certificate does
  not list. Give `--central` the central computer's name, or, on the central
  computer, delete `ServerCertificate.pem` and `ServerPrivateKey.pem` and run
  `apply` again with `--advertise` and that address.

**Sites installed before this version** switch over by themselves:

1. Run `apply` on the central computer. It creates the certificate authority
   and replaces the self-signed pair.
2. Run `apply` with `--central-fingerprint` on every other computer.

Until a computer is switched over, its connections to the switched computers
fail, so switch all of them in one session.

#### Lifetime and a new certificate authority {#opcua-renewal}

A computer's certificate is valid for 5 years, the site certificate
authority's for 10 years from its creation. When a computer's certificate
expires, the other processes stop accepting its connections and its devices
disappear from the Client; when the certificate authority's expires, the
same happens to every computer of the site.
[`scada-setup status`](#monitoring) shows the start and expiry dates: the
`Valid from … to …` line under `OPC UA certificate` for the computer's
certificate, and the one under `Site CA` on the central computer for the
authority. [OpenSSL](https://www.openssl.org/) shows them too:
`openssl x509 -in ServerCertificate.pem -noout -enddate` (for the authority,
`ca\ca.pem` on the central computer). Replace certificates in good time.

`apply` does not replace a valid certificate issued by a certificate
authority this computer trusts, even when it is about to expire. So:

* **to renew a computer's certificate**, stop its processes
  (`scada-setup stop`), delete `ServerCertificate.pem` and
  `ServerPrivateKey.pem` from the `data\Certificates` folder of the
  installation (`C:\Program Files\Telecontrol SCADA\data\Certificates`, on
  Linux `/opt/telecontrol-scada/data/Certificates`) and run `apply` with the
  [computer's parameters](#scada-setup-options) — on a joined computer
  without `scada-config`, together with `--svc-password`: it gets the new
  certificate from `scada-config`, and needs no fingerprint for that.
  Renewing the central computer's own certificate changes its fingerprint,
  but the other computers recognise it by the certificate authority, and
  nothing needs changing on them (see
  [The central computer's fingerprint changed](#central-fingerprint-changed));
* **a new certificate authority** appears when the `ca` subfolder on the
  central computer is deleted (to replace an expiring authority) or lost —
  for example by uninstalling with `SCADA_PURGE_CERTIFICATES=1` or by a
  restore without that folder. Every computer's certificate was then issued
  by the old authority, and **every other computer must join again**. On the
  central computer itself, `apply` then replaces its own pair as well: the old
  one is set aside with the `.previous-ca` extension, and the central
  computer's fingerprint changes — the same `apply` and `scada-setup status`
  print the new one. This is the one case in which the other computers need
  the new fingerprint: on every one of them, run `apply` with the
  [computer's parameters](#scada-setup-options) and the new fingerprint in
  `--central-fingerprint`. `apply` notices by itself that this computer's
  certificate was not issued by the current authority, sets the old pair
  aside with the `.previous-ca` extension and gets a new one; there is no
  need to delete the certificate files by hand. Until a computer has joined
  again its connections fail, so join all of them in one session.

#### The central computer's fingerprint changed {#central-fingerprint-changed}

The central computer's fingerprint changes with its certificate:

* after the central computer's [certificate is renewed](#opcua-renewal);
* after the program is reinstalled on the central computer (the installer
  removes its certificate), or the computer is restored under another name;
* after its pair is made again for `--advertise`;
* after the site certificate authority is replaced;
* after `apply` adds a process to the central computer: the computer gets a
  new certificate that names that process too.

**While the certificate authority is the same, nothing needs changing on the
other computers.** A computer that has joined checks the central computer's
certificate against the certificate authority rather than the fingerprint,
so its `apply` (upgrades and restores included) works with the old
fingerprint in `--central-fingerprint` and without one alike, and it need not
join again. The new fingerprint is needed only to join new computers;
`apply` and `scada-setup status` on the central computer print it.

**When the certificate authority is new**, the other computers must join
again with the new fingerprint (see
[Lifetime and a new certificate authority](#opcua-renewal)). Until they do,
`apply` on them stops with `presented a certificate with fingerprint …, not
the … given` (with the old fingerprint) or `… that the site CA this computer
holds did not issue` (without one) and changes nothing.

To notice a new certificate authority, `apply` on a joined computer contacts
`scada-config` on the central computer. When that is unreachable, `apply`
warns `could not check the central computer's site CA`, keeps this
computer's certificate and carries on. If the certificate authority may have
been replaced, run `apply` again once the central computer is up.

## OPC client on Windows {#opc-classic}

On Windows, the Server can connect to external Classic OPC (OPC DA)
servers. Their tags then appear in the Telecontrol SCADA Server address
space and can be bound to data objects.

```json
"opc": {
    "client": {
        "enabled": true
    }
}
```

## Vidicon integration {#vidicon}

The Server supports integration with the Telecontrol Vidicon system to
help migrate existing projects. When enabled, it imports Vidicon objects
into its own address space.

```json
"vidicon": {
    "enabled": true
}
```

This feature is available only on Windows.

## Backup {#backup}

On each computer running Server processes, copy:

* the whole `%ProgramData%\Telecontrol\SCADA Server` folder — each process
  has its own folder in it, holding its parameter file, databases and logs,
  and the license file `license.json` sits beside them;
* the `C:\Program Files\Telecontrol SCADA\data\Certificates` folder — the
  [Server certificate](#opcua-certificate) and its private key, and on the
  central computer the `ca` subfolder as well — the
  [site certificate authority](#opcua-site-ca) with its `ca_key.pem` key.
  Without it every other computer must join again after a restore (see
  [A new certificate authority](#opcua-renewal)). Keep the copy of the keys
  as safe as the passwords.

**On Linux** copy the whole `/var/lib/scada` folder and the
`/opt/telecontrol-scada/data/Certificates` folder, with the processes
stopped by `sudo /opt/telecontrol-scada/bin/scada-setup stop`.
`/var/lib/scada` also holds the [password file](#stored-passwords)
`secrets/service-secrets.env`, which keeps the `svc` and `root` passwords
**in plain text**: keep the copy where only `root` can read it, or leave
that file out — on a restore `apply` takes the passwords again anyway.

Copy only with **this computer's processes stopped**: a copy of the files of
running databases may be inconsistent. From an elevated command prompt:

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop
rem copy %ProgramData%\Telecontrol\SCADA Server
rem and C:\Program Files\Telecontrol SCADA\data\Certificates
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" start --tiers <this computer's processes> [--license <path>]
```

A restore also needs the `svc` password, the `root` password, and the
[computer's parameters](#scada-setup-options) — the `--tiers`, `--central`,
`--advertise`, `--license`, the central computer's fingerprint and the other
options, if given, that `scada-setup apply` was run with on it;
none of them is in the backup.

### Configuration backup

The configuration is an SQLite database in the `config\Configuration` folder
of `scada-config`; the other processes read it from there. The
`filestore\Configuration` folder holds only the `svc` service account.

For PostgreSQL, use the standard PostgreSQL backup tools such as
`pg_dump`.

### History backup

The historical databases are in `historian\History`, and the schematic files
in `filestore\FileSystem`.

Versions 2.5 and earlier kept this data in the `Configuration`, `History` and
`FileSystem` folders directly under `%ProgramData%\Telecontrol\SCADA Server`.
After [upgrading from version 2.5](#upgrade-2-5) those folders stay where they
are, but the 2.6 processes no longer use them.

### Restore {#restore}

Run the `scada-setup` commands by their full path from an elevated command
prompt.

On the same computer:

1. Stop the processes: `scada-setup stop`.
2. Put the `%ProgramData%\Telecontrol\SCADA Server` folder (and the
   `Certificates` folder, if it is gone) back from the backup.
3. Start the processes: `scada-setup start` with the
   [computer's parameters](#scada-setup-options).
4. Check the result: `scada-setup status`.

On a new or rebuilt computer:

1. Install the package of **the same version** as the backup.
2. Put the `%ProgramData%\Telecontrol\SCADA Server` folder back from the
   backup.
3. **If the computer's name is the same**, put the
   `C:\Program Files\Telecontrol SCADA\data\Certificates` folder back too,
   then restrict access to the key file (a copied file takes the folder's
   permissions):

   ```bat
   icacls "C:\Program Files\Telecontrol SCADA\data\Certificates\ServerPrivateKey.pem" /inheritance:r /grant:r *S-1-5-18:F *S-1-5-32-544:F
   ```

   **If the computer's name is different**, do not put
   `ServerCertificate.pem` and `ServerPrivateKey.pem` back from the
   `Certificates` folder (or delete them): the old certificate names the
   former computer name, and `apply` creates a new pair only when neither of
   the two files exists. **Put the central computer's `ca` subfolder back in
   any case** — otherwise `apply` creates a new certificate authority and
   the other computers have to join again (see
   [A new certificate authority](#opcua-renewal)). On a computer without
   `scada-config`, give `apply` in step 4 `--central-fingerprint` too, to get
   a new certificate from the certificate authority. Take the fingerprint
   from `scada-setup status` on the central computer now, not from the
   recorded parameters: it differs once the central computer's certificate
   has been renewed.
4. Run `scada-setup apply` with the same
   [computer's parameters](#scada-setup-options) as before, **the same `svc`
   password**, and the `root` password. The `svc` password is stored in the
   restored databases, and with a different one the processes cannot connect
   to each other. `apply` registers and starts the services, and keeps the
   restored databases and certificate. If the site's other computers name this
   one in `--central` by an address that has changed, run `apply` there with
   the new address. If this computer runs protocol
   processes, was set up with `--advertise` and its address changed, give
   `--advertise` the new address.
5. Create the inbound firewall rules again — the backup does not contain
   them (see
   [Network preparation]({{ '/en/getting-started/' | relative_url }}#network)).
   If the address of this computer changed, also correct the `remoteip`
   lists of the rules on the site's other Server computers.
6. If this is the central computer and its address or name changed, enter
   the new one in the `Server` field of the login dialog of each Client
   (see [Client login]({{ '/en/getting-started/' | relative_url }}#client-start)).
7. Check the result: `scada-setup status`.

With a new certificate, third-party OPC UA clients that trusted the old one
have to be set up again.

**On Linux** the folders are the ones in [Backup](#backup) —
`/var/lib/scada` and `/opt/telecontrol-scada/data/Certificates` — and the
commands are `sudo /opt/telecontrol-scada/bin/scada-setup …`; the `icacls`
step is not needed. Files put back as `root` (with `cp -r`, say) belong to
`root`, and the services, which run as `scada`, cannot write to them. So on
the same computer too, run `apply` with the same
[computer's parameters](#scada-setup-options) and passwords instead of
`start` in step 3: `apply` hands the process folders and the certificate keys
to the `scada` account.

## `server.json` parameter reference {#parameters}

System settings are stored in the process's parameter file (`server.json`
in this section). Its default location is given under
[`--param`](#command-line-options).

**WARNING:** on Windows the parameter files are written by
[`scada-setup`](#scada-setup), and every `scada-setup apply` — every upgrade
included — writes them afresh from templates. **Do not edit `server.json`**:
put your own parameters in `server.override.json` in the same folder, which
`apply` lays over the template (see [Your own parameters](#server-override)).

These substitution variables can be used in the file:

| Variable | Description |
|---|---|
| `${DIR_PARAM}` | Directory containing the parameter file |
| `${DIR_EXE}` | Directory containing the Server executable |
| `${DIR_TEMP}` | Temporary directory |
| `$ENV{NAME}` | Value of the environment variable `NAME` (empty if it is not set) |

To see a complete, correct parameter file for a process, have one written
with `scada-setup generate --tiers <processes> --output <folder>` (on a
computer without `scada-config`, also with `--central <address>`): it only
writes the files into the given folder and installs nothing. Writing a
parameter file from scratch is not recommended — among other things it has to
contain the [`license`](#licensing) block with the license file path,
[`security.rootPassword`](#root-password) for `scada-config` and
`scada-filesystem`, and an enabled
[`opcua`](#opcua) block, over which the processes exchange data.
