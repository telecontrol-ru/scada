---
title: Server
nav_order: 6
permalink: /en/server/
---

# Server
{:.no_toc}

* TOC
{:toc}

The Server is the central runtime component of Telecontrol SCADA. It acquires data from equipment, processes live values, archives history, records events, and maintains client sessions. It runs on Windows and, on request, on Linux (see [Linux deployment](#linux)).

The Server is a set of separate processes: `scada-config`, `scada-proxy`, `scada-historian`, `scada-filesystem`, the protocol processes, and others. What each one does and the typical installations are described in [Server processes]({{ '/en/architecture/' | relative_url }}#tiers). Every process is started and configured the same way, so below "the Server" means any of them, and `server.json` means that process's parameter file.

## Runtime modes

On Windows, each Server process is installed as its own service — `Telecontrol SCADA Config`, `Telecontrol SCADA Proxy`, `Telecontrol SCADA Historian`, `Telecontrol SCADA IEC 104`, and so on (the full list is in [Server processes]({{ '/en/architecture/' | relative_url }}#tiers)) — and starts automatically during system boot.

It can also be started in console mode for diagnostics.

### Windows services {#services}

The services are registered by [`scada-setup`](#scada-setup); they run as the
SYSTEM account and start automatically with Windows. `scada-setup stop` and
`scada-setup start` stop and start all of a computer's services in the right
order (`start` only with the [computer's parameters](#scada-setup-options)); a single service can be controlled through the standard Windows
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

**WARNING:** after a protocol process's service restarts, automatically
included, its objects' values stop being archived. Restart the
*Telecontrol SCADA Historian* service afterwards (see
[Monitoring](#monitoring)).

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

**This version of `scada-setup` has not yet been tried on a site under
Windows.** If the result of any command differs from what this page
describes, report that to Telecontrol (mail@telecontrol.ru).

**Run `scada-setup` from an elevated command prompt, and always by its full
path:**

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" <command> <options>
```

The installer does not add the program's folder to `PATH`, and `scada-setup`
looks for its templates relative to the path it was invoked by; typed
without a path, it may not find them. If for some reason you cannot invoke it
by its full path, name the installation folder explicitly:
`--install-root "C:\Program Files\Telecontrol SCADA"`.

| Command | Does | Needs admin |
|---|---|:-:|
| `apply` | Write parameter files and databases, create the [Server certificate](#opcua-certificate) if there is none, register and start the processes' services | yes |
| `status` | License summary and each process's service state | yes |
| `start` / `stop` | Start / stop this computer's services in order | yes |
| `remove [--purge-data]` | Stop and unregister the services (with `--purge-data`, delete the processes' data too — see the [warning](#remove)) | yes |
| `generate --output <dir>` | Write the parameter files only, for inspection | no |
| `migrate [--execute]` | Move a version 2.5 Server's data over — see [Upgrading from version 2.5](#upgrade-2-5) | with `--execute` |

In its messages `scada-setup` calls the Server processes *tiers*: for
example, `status` prints the line `Entitled tiers: config filesystem historian …` — the
processes the license allows, in alphabetical order — and errors read
`--tiers must name at least one tier` or
`the license does not entitle tier(s) …`. The names in these messages are the
same as in the `--tiers` option.

**A new installation starts with a demo project.** The configuration
databases `apply` creates are copies of the demo configuration shipped with
the installer: objects with emulation, two enabled IEC 60870-5-104 links (one
of them accepts connections on port 2404 of this computer — the
`scada-iec104` process takes that port, if it is installed), two archives,
and the users «Клиент 1» … «Клиент 10» and `guest` with no passwords. Before
going live, delete the demo devices, objects and users, or replace the
configuration with the project's (see
[Preparing the project]({{ '/en/getting-started/' | relative_url }}#project)).

#### Options {#scada-setup-options}

* `--tiers <list>` — this computer's processes, comma-separated. When it is
  absent, `apply`, `start` and `migrate` take **every process in the
  license**, while `stop`, `status` and `remove` take every Server service
  the computer has.
* `--central <address>` — the central computer's address; required by
  `apply`, `start` and `migrate` on a computer without `scada-config`.
* `--advertise <address>` — this computer's address for the others, when its
  name does not resolve on the network.
* `--license <path>` — the license file; default `license.json` in the data
  folder (`%ProgramData%\Telecontrol\SCADA Server\license.json`). `apply`,
  `start`, `migrate` and `status` check it: if the license file is
  elsewhere, give `--license` to `status` too, or it prints
  `License: not available`.
* `--svc-password <password>` (or the `SCADA_SETUP_SVC_PASSWORD` environment
  variable) — the password of the [svc account](#svc), required by `apply`
  and `migrate --execute`.
* `--root-password <password>` (or the `SCADA_SETUP_ROOT_PASSWORD`
  environment variable) — the [root password](#root-password), required by
  `apply` and `migrate --execute` on a computer running `scada-config`,
  `scada-proxy`, `scada-historian` or `scada-filesystem`.
* `--data-root`, `--install-root` — the data folder and the installation
  folder, when they are not the standard ones.

**`scada-setup` does not remember its options.** Write down each computer's
`--tiers`, `--central`, `--advertise`, `--license` and, if you gave them,
`--data-root` and `--install-root` at installation, and
give them to every `apply` and `start` on it, upgrades and restores
included:

* `start` without `--tiers` tries to start every process in the license and
  stops with an error at the first process whose service the computer does
  not have; it does not start the processes after it;
* `apply` without `--tiers` installs every process in the license on the
  computer. `remove --tiers <the extra processes>` removes the extra services
  (without `--purge-data` their data stays);
* `apply` without `--license` writes the default path into the parameter
  files.

`apply` can be run again: it rewrites the parameter files and re-registers
the services with the new settings, without touching data.

#### Re-running apply on running processes {#reapply}

**`apply` does not restart services that are already running:** it leaves a
running service as it is, and the service keeps working with its old
settings. A new `root` password (`--root-password`), another license file
(`--license`), a different `--central` or `--advertise`, and rewritten
parameter files take effect only after the process restarts. So, when you
change anything on a running installation, stop the processes first and then
run `apply`, which starts them again:

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" apply --tiers <this computer's processes> [--central <address>] [--advertise <address>] [--license <path>] --svc-password <password> --root-password <root password>
```

Do the same when changing the `root` password, when adding a process to the
computer, and when restoring the `svc` password after a mismatch.

#### Removing services and data {#remove}

`remove` stops and unregisters the services; the processes' data stays.

**WARNING: `remove --purge-data` without `--tiers` irreversibly deletes the
data of all nine processes**, without asking for confirmation: the `config`,
`proxy`, `historian`, `filestore`, `modbus`, `iec104`, `iec61850`, `opc` and
`vidicon` folders in `%ProgramData%\Telecontrol\SCADA Server` — the
configuration, user passwords, archives, display files and logs. Make a
[backup](#backup) before using `--purge-data`, and always give `--tiers`
with exactly the processes whose data must be deleted.

**WARNING:** `apply` writes every `server.json` afresh from a template, and
**all** hand edits to it are lost — on every `apply`, every upgrade included.
If you changed parameters by hand (for example the [log sizes](#logging)),
keep a copy of the edited file, and after each `apply` make the changes again
and restart the process.

#### Passwords are stored in plain text {#stored-passwords}

**WARNING: the passwords given to `apply` are stored in plain text** — in the
Windows service settings, in the `Environment` values of the registry keys
`HKLM\SYSTEM\CurrentControlSet\Services\TelecontrolScada<Process>`. Assume
that anyone who signs in to Windows on that computer can read them: keep
untrusted users from signing in to the Server computers, and do not combine a
Server computer with an operator workstation. The Server installer puts the
Client on the computer too, with a desktop shortcut — do not let operators
work with it on a Server computer (see
[Installing the Client]({{ '/en/getting-started/' | relative_url }}#client-install)).

### Upgrading from version 2.5 {#upgrade-2-5}

Versions 2.5 and earlier installed a single process — the *Telecontrol SCADA
Server* service — and kept its data in the `Configuration`, `History` and
`FileSystem` folders inside `%ProgramData%\Telecontrol\SCADA Server`.
`scada-setup migrate` moves that data into the version 2.6 processes:

| Version 2.5 data | Copied to |
|---|---|
| Configuration `Configuration\configuration.sqlite3` | The `Configuration` folder of `config`, `proxy` and `historian` |
| User passwords `Configuration\password.dat` | The same folders, beside each copy of the configuration |
| History `History` | `historian\History` |
| Schematic files `FileSystem` | `filestore\FileSystem` |

All paths are relative to `%ProgramData%\Telecontrol\SCADA Server`; if the
version 2.5 `server.json` named other folders, the command takes them from
there. The configuration is copied to three processes because each works from
its own copy: `scada-config` hands it to the protocol processes, `scada-proxy`
checks Client user names and passwords against it, and `scada-historian`
reads its historical databases and object assignments from it.

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
   2.6 does not use the HASP or Guardant hardware key.
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
   IEC 61850). The command does not warn when one is missing: the
   configuration is carried over, but no data is collected from that
   protocol's devices.

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
  with `stop` and `apply` with the same `--tiers` and passwords;
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
* none of `config`, `proxy` and `historian` is selected on this computer;
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

### Rolling back to version 2.5 {#rollback-2-5}

If the 2.6 Server does not work after the migration (for example, its
services do not start), version 2.5 can be brought back, but not by
installing over it: **the 2.5.7 installer refuses to install while a newer
version is installed** (the message `A later version of ОИК Телеконтроль is
already installed`), and the version 2.5 *Telecontrol SCADA
Server* service has already been removed by `migrate --execute`. On the same
computer, from an elevated command prompt:

1. Stop and remove the version 2.6 services — with the same `--tiers` as in
   the migration, and **without** `--purge-data`:

   ```bat
   "C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" remove --tiers config,historian,filesystem,iec104,proxy
   ```

2. Uninstall version 2.6: the *ОИК Телеконтроль* program (publisher
   ООО Телеконтроль) in *Control Panel — Programs and Features*, or
   `msiexec /x telecontrol-scada-<version>.msi /qn /norestart /l*v uninstall.log`.
   `msiexec /x` needs the file of the very package that is installed; if
   you do not have it, uninstall from the Control Panel.
3. Install release 2.5.7 (`telecontrol-scada-2.5.7.msi` from the
   [releases page]({{ '/en/getting-started/' | relative_url }}#download)) the
   way you installed version 2.5, and attach the HASP or Guardant hardware
   key.
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

### Uninstalling the Server {#uninstall}

**Remove the services first, then the program.** The installer removes only
what it installed: the services registered by `scada-setup` and their
registry settings — with the `svc` and `root` passwords in plain text —
remain, as do the data folders and the Server certificate's private key. From
an elevated command prompt, on every Server computer:

1. Remove the services:

   ```bat
   "C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" remove --tiers <this computer's processes>
   ```

2. Uninstall the program: the *ОИК Телеконтроль* program (publisher
   ООО Телеконтроль) in *Control Panel — Programs and Features*, or
   `msiexec /x telecontrol-scada-<version>.msi /qn /norestart /l*v uninstall.log`.
   `msiexec /x` needs the file of the very package that is installed; if
   you do not have it, uninstall from the Control Panel. The computer's
   Client is uninstalled with the program.
3. [Back up](#backup) the data if you may need it, and delete the folders:
   * `%ProgramData%\Telecontrol\SCADA Server` — the processes' data, the
     license file and, if a migration from version 2.5 was done, the
     version 2.5 folders;
   * `C:\Program Files\Telecontrol SCADA\data\Certificates` — the
     [Server certificate](#opcua-certificate) and its private key (if the
     `C:\Program Files\Telecontrol SCADA` folder is still there after the
     uninstall, delete it as a whole).

### Console mode {#console}

For diagnostics, a Server process can run in a console window: it works as
the service does and prints its log to the screen. The installer creates no
shortcut for this.

This is the only way to see an **error in the `server.json` parameter
file**: the process reports it before it starts writing its log files, so a
service with such an error stops (and is restarted by Windows) without
leaving an entry in the [log](#logging).

1. Stop the process's service (for example *Telecontrol SCADA IEC 104*): the
   process and its service cannot run at the same time — they use the same
   ports and files.
2. Open an elevated command prompt: without administrator rights the process
   cannot read the [Server certificate](#opcua-certificate)'s private key and
   does not start.
3. Set the passwords the service gets from `scada-setup`, and start the
   process with its parameter file:

   ```bat
   set SCADA_SVC_PASSWORD=<svc password>
   set SCADA_ROOT_PASSWORD=<root password>
   "C:\Program Files\Telecontrol SCADA\bin\scada-iec104.exe" --param "%ProgramData%\Telecontrol\SCADA Server\iec104\server.json"
   ```

   The executable is `scada-<process>.exe`; the parameter file's folder is
   `config`, `proxy`, `historian`, `filestore` (for `scada-filesystem`),
   `modbus`, `iec104`, `iec61850`, `opc` or `vidicon`.
4. To finish, close the window or press *Ctrl+C*, then start the process's
   service again (the Windows Services UI), or all of the computer's processes
   with `scada-setup start` and the
   [computer's parameters](#scada-setup-options).

**WARNING:** started without the `SCADA_ROOT_PASSWORD` variable,
`scada-config`, `scada-proxy`, `scada-historian` or `scada-filesystem`
**sets the `root` account's password to empty** — their parameter files
contain `"rootPassword": "$ENV{SCADA_ROOT_PASSWORD}"`, and a configured
password is written on every start (see [Root password](#root-password)).
Give `SCADA_ROOT_PASSWORD` the same password as `apply`. Without
`SCADA_SVC_PASSWORD` the process cannot connect to the other processes.
Protocol processes do not need `SCADA_ROOT_PASSWORD`.

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

Processes installed by `scada-setup` are started with a `--param` naming
`%ProgramData%\Telecontrol\SCADA Server\<process folder>\server.json`.

### Linux deployment {#linux}

The Server processes run on Linux, but this version publishes no Linux
package, and on Linux `scada-setup` only writes parameter files (the
`generate` command): it does not create the `svc` service account in the
configuration databases, creates the [Server certificate](#opcua-certificate)
only with the `--create-certificate` switch, and does not pass the `svc` and
`root` passwords to the processes. **Installing the Server on Linux is
available on request** — contact Telecontrol (mail@telecontrol.ru). The
information below is for reference, for such an installation. The graphical
Client is not supported on Linux.

#### Run from an archive

Unpack the server distribution archive and start the executables of the
processes you need (`scada-config`, `scada-iec104`, and so on). Each
process reads its own parameter file `data/<name>.json`, where `data` is
resolved from the executable's directory as `<program dir>/../data`, or
the file passed with `--param`.

Environment variables can be substituted into the parameter file
(`$ENV{NAME}`, see the [parameter reference](#parameters)), for example to
keep the [root password](#root-password) out of the file. Installation in
Docker containers is also available on request.

## Licensing

Each Server process needs a signed license file. The license states an
expiry date and the processes purchased; a process the license does not name
will not run. No hardware key is used.

The settings live in the `license` block of the parameter file:

```json
"license": {
    "file": "C:\\ProgramData\\Telecontrol\\license.json",
    "require_gcp_binding": false
}
```

| Parameter | Default | Description |
|---|---|---|
| `file` | `license.json` | Path to the license file. A relative path resolves against the process's working directory, so an absolute path is safer. When the parameter is absent, the `SCADA_SERVER_LICENSE_FILE` environment variable is used |
| `require_gcp_binding` | `true` | Check that the license is bound to this Google Cloud virtual machine. **Outside Google Cloud, set it to `false`**, or the license cannot be verified. When the parameter is absent, the `SCADA_SERVER_LICENSE_REQUIRE_GCP_BINDING` environment variable is used |

Parameter files written by [`scada-setup`](#scada-setup) already carry the path `%ProgramData%\Telecontrol\SCADA Server\license.json` (or the one given with `--license`) and `"require_gcp_binding": false`.

The license is checked at startup and then every 5 seconds:

* **No valid license**, or one that does not include this process — the
  process stops. The reason is written to the log. The process does the same
  when the file is missing or only partly written at the moment it is
  checked. The service then exits normally and Windows does **not** restart
  it — once the file is fixed, start the processes with `scada-setup start`
  and the [computer's parameters](#scada-setup-options). A license whose
  validity period has not started yet counts as not valid too.
* **The license could not be verified** (for example, the Google Cloud
  metadata server did not answer) — the process keeps running but serves no
  requests until verification succeeds.
* **The license has expired** — the process keeps running but refuses
  requests. Once the license file is replaced, service resumes without a
  restart.

**WARNING:** with an expired license, `scada-setup` treats all nine processes
as licensed (and warns that the license is outside its validity window):
`apply` without `--tiers` installs every one of them on the computer.
`scada-setup apply` does not accept a license whose validity period has not
started yet.

`scada-setup status` shows when the license expires. During the last 30
days the Server also raises a daily system event about the expiry, but it is
visible only in the Client.

Replace the license file in one step: copy the new file into the same folder
under a temporary name and rename it to `license.json` over the old one
(`move /y`) — see [License]({{ '/en/getting-started/' | relative_url }}#license).

Versions 2.5 and earlier used a HASP or Guardant hardware key, and ran for two
hours in demo mode without one.

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

GigaBASE support was removed starting with version 2.1. Older
configurations must be exported with the version 2.0 administration
utility and imported into SQLite before the current Server is used. The
utility is not published on the releases page; request it from
Telecontrol (mail@telecontrol.ru).

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
| `log.console_severity` | — | Lowest level of the messages printed **to the screen** in [console mode](#console): `Trace`, `Debug`, `Info`, `Warning`, `Error` or `Critical`. Does not affect the log files |

A new file is started when the current one reaches its maximum size, and
every day at midnight. Old files are deleted automatically when the total
size or file count limit is exceeded. The level of the messages written to
the files is not configurable.

Errors in the parameter file itself (and in its `log` block) are found before
the process starts writing its log, and are printed to the screen only: to
see them, start the process in [console mode](#console).

## Monitoring {#monitoring}

* **Service and license state** — `scada-setup status` on each computer
  (from an elevated command prompt): the license expiry, the processes it
  entitles, and the state of each process's service. It prints, for
  example:

  ```text
  License: C:\ProgramData\Telecontrol\SCADA Server\license.json (expires 2027-01-31T00:00:00Z)
  Entitled tiers: config filesystem historian iec104 proxy
  config       SERVICE_RUNNING
  historian    SERVICE_RUNNING
  ```

  The processes on the `Entitled tiers` line are listed in alphabetical
  order. A running service shows `SERVICE_RUNNING`, a stopped one
  `SERVICE_STOPPED`, and one the computer does not have `not installed`.
* **Process logs** — see [Logging](#logging). Why a process stopped (license,
  certificate) is written to its log; an error in the parameter file is not —
  only [console mode](#console) shows it.
* **Links between processes** — if a protocol process's log shows
  `Bad_UserAccessDenied`, its computer was given a different `svc` password
  (see [The svc account](#svc)).
* **Archive writing** — the Client's `More -> Databases` window shows, for
  each archive, how many values were written and the write queue (see
  [Databases]({{ '/en/client/workbench/' | relative_url }}#historical-db)).
  If the written-values count stops growing while object values change,
  restart the *Telecontrol SCADA Historian* service: after a protocol
  process's service restarts, automatically after a failure included, its
  objects' values are not archived until *Telecontrol SCADA Historian* is
  restarted.

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
replaces any password stored earlier, including one changed from the
Client. To keep the password out of the file in plain text, pass it
through an environment variable as in the example above.

**On Windows, `scada-setup` sets it**: the parameter files it writes for
`scada-config`, `scada-proxy`, `scada-historian` and `scada-filesystem`
contain `"rootPassword": "$ENV{SCADA_ROOT_PASSWORD}"`, and `scada-setup apply`
takes the variable's value from `--root-password` (or the
`SCADA_SETUP_ROOT_PASSWORD` environment variable) and stores it in those
processes' Windows service settings — in plain text, in the registry (see
the [warning](#stored-passwords) in the `scada-setup` description). On a computer running one of those
processes, `apply` refuses to run without it. To change the root password,
stop the processes (`scada-setup stop`) and run `apply` with the new value:
`apply` does not restart running processes, which would keep accepting the
old password (see [Re-running apply](#reapply)). Do not edit the generated parameter files,
which the next `apply` rewrites.

Set the parameter on **every** process that keeps the configuration in
its own database; each of them has its own `root` account: `scada-config`,
`scada-proxy`, `scada-historian` and `scada-filesystem`. The protocol
processes receive their configuration from `scada-config` and do not use
this parameter (they log a message saying so).

**WARNING:** a process gets the `SCADA_ROOT_PASSWORD` variable from its
service. Started outside the service (for example in
[console mode](#console)) without that variable, it gives `root` an empty
password.

## The svc account {#svc}

The Server processes connect to each other as the `svc` service account
(id 100). `scada-setup apply` creates it in the configuration databases and
hands its password, from `--svc-password`, to the processes through the
Windows service settings (the `SCADA_SVC_PASSWORD` variable, in plain text in
the registry).

* **The password is written to the databases once only** — on the processes'
  first start. Later `apply` runs do not change it: an `apply` with a
  different `--svc-password` hands the processes the new password while the
  databases keep the old one, and the processes stop connecting to each
  other. **This version has no way to change the `svc` password.** Give every
  `apply`, on every computer, the original password.
* **Do not change or delete the `svc` account** in the Client's *Users*
  window: that breaks the links between the processes too.
* When the passwords differ, the protocol process keeps running but gets no
  configuration, and its [log](#logging) shows `Bad_UserAccessDenied`. Stop
  the processes on that computer (`scada-setup stop`) and run `apply` with
  the original `svc` password (see [Re-running apply](#reapply)).

## OPC UA server {#opcua}

The Server can expose data to external systems through
[OPC UA](https://opcfoundation.org/about/opc-technologies/opc-ua/).
When enabled, external clients can browse the Server address space,
including objects, devices, and current or historical data.

In an installation made by `scada-setup`, OPC UA is enabled on every process
(ports 4840–4848, see
[Network preparation]({{ '/en/getting-started/' | relative_url }}#network)):
the processes exchange data with each other over it.

**WARNING: in this version the OPC UA ports are protected by the firewall
alone.** The processes connect to each other unencrypted (policy None) as the
[`svc`](#svc) account, register with `scada-proxy` and `scada-config`
without authentication, and anonymous sign-in is always offered. So:

* open the OPC UA ports to the site's computers only (see
  [Network preparation]({{ '/en/getting-started/' | relative_url }}#network));
* if an external system must connect to the Server, allow it port 4840
  (`scada-proxy`) in the firewall from its address only;
* **in an installation made by `scada-setup`, do not set
  `"allow_none": false` or `"require_encryption_for_password": true`** (see
  [below](#opcua-certificate)): the other processes cannot connect to a
  process with those settings — and every process has at least one other
  process connecting to it — so the Server stops working.

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

* a 2048-bit RSA key without a passphrase and a self-signed SHA-256
  certificate valid for 5 years;
* the certificate lists the identifiers (ApplicationUri) of every process
  `apply` enables on this computer, the computer's name, `localhost`,
  `127.0.0.1`, and the `--advertise` address when one is given;
* only the SYSTEM account the services run as, and administrators, can read
  the key file.

One pair serves every process on the computer. `apply` never replaces existing
files. When a process that the certificate does not list is enabled after the
pair was created, `apply` prints a warning naming its identifier: third-party
OPC UA clients that check the certificate may refuse to connect to that
process. When only one of the two files exists, `apply` stops and names the
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
   installation: a missing pair is created again, and the processes start.

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
certificate to carry the application's identifier, and third-party OPC UA
clients check it. Copy both files to the folder the parameters name, and
restrict access to the key file to the SYSTEM account and administrators
(the groups are given by identifier, so the command works on Windows in any
language):

```bat
icacls "C:\Program Files\Telecontrol SCADA\data\Certificates\ServerPrivateKey.pem" /inheritance:r /grant:r *S-1-5-18:F *S-1-5-32-544:F
```

**Client** certificates are not checked by default: the Server accepts any
client certificate. This check applies to secured connections only; it does
not forbid an unsecured connection (policy None), which the Server processes
use themselves, and so **it does not protect against a stranger's computer on
the network** — in this version the protection is the firewall alone (see
[OPC UA server](#opcua)). To accept only trusted certificates on secured
connections, set these folders in the `opcua` block of the parameter file:

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
from starting without a trusted-certificate folder. Anonymous sign-in is
always offered. The desktop Client does not verify the Server's certificate.

**WARNING:** the Server processes connect to each other unsecured and send
the `svc` password unencrypted, so **`"allow_none": false` and
`"require_encryption_for_password": true` break the links between the
processes** — do not set them in an installation made by `scada-setup`.
Besides, `scada-setup` sets none of these parameters, and every
`scada-setup apply` (upgrades included) writes the parameter files afresh,
losing parameters added by hand.

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
  [Server certificate](#opcua-certificate) and its private key. Keep the
  copy of the key as safe as the passwords.

Copy only with **this computer's processes stopped**: a copy of the files of
running databases may be inconsistent. From an elevated command prompt:

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop
rem copy %ProgramData%\Telecontrol\SCADA Server
rem and C:\Program Files\Telecontrol SCADA\data\Certificates
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" start --tiers <this computer's processes> [--central <address>] [--license <path>]
```

A restore also needs the `svc` password, the `root` password, and the
[computer's parameters](#scada-setup-options) — the `--tiers`, `--central`,
`--advertise` and `--license` (and `--data-root` and `--install-root`, if
given) that `scada-setup apply` was run with on it;
none of them is in the backup.

### Configuration backup

The SQLite configuration databases are in the `Configuration` folders of
`config`, `proxy`, `historian` and `filestore`. The main configuration is
`scada-config`'s (`config\Configuration`); Client user names and passwords
are checked against `scada-proxy`'s copy (`proxy\Configuration`).

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

   **If the computer's name is different**, do not put the `Certificates`
   folder back (or delete both files from it): the old certificate names the
   former computer name, and `apply` creates a new pair only when neither of
   the two files exists.
4. Run `scada-setup apply` with the same
   [computer's parameters](#scada-setup-options) as before, **the same `svc`
   password**, and the `root` password. The `svc` password is stored in the
   restored databases, and with a different one the processes cannot connect
   to each other. `apply` registers and starts the services, and keeps the
   restored databases and certificate. If the site's other computers name this
   one in `--central` by an address that has changed, run `stop` there and
   then `apply` with the new address.
5. Check the result: `scada-setup status`.

With a new certificate, third-party OPC UA clients that trusted the old one
have to be set up again.

## `server.json` parameter reference {#parameters}

System settings are stored in the process's parameter file (`server.json`
in this section). Its default location is given under
[`--param`](#command-line-options).

**WARNING:** on Windows the parameter files are written by
[`scada-setup`](#scada-setup), and every `scada-setup apply` — every upgrade
included — writes them afresh from templates. **Any parameter changed in
`server.json` by hand is lost.** If you change parameters by hand, keep a
copy of the edited file, and after each `apply` make the changes again and
restart the process.

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
contain the [`license`](#licensing) block with
`"require_gcp_binding": false` (outside Google Cloud),
[`security.rootPassword`](#root-password) for `scada-config`, `scada-proxy`,
`scada-historian` and `scada-filesystem`, and an enabled
[`opcua`](#opcua) block, over which the processes exchange data.
