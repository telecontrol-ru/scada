---
title: Server
nav_order: 6
has_children: true
permalink: /en/server/
---

# Server
{:.no_toc}

* TOC
{:toc}

The Server is the central runtime component of Telecontrol SCADA. It acquires data from equipment, processes live values, archives history, records events, and maintains client sessions. It runs on Windows and Linux, as system services or in console mode (see [Linux deployment](#linux)).

{: .warning }
> The version 2.6 Server packages (the Windows installer and the Linux
> packages) are not published yet; until they are, only a 2.5.7 Server can be
> installed (see [Download]({{ '/en/getting-started/' | relative_url }}#download)).

The Server is a set of separate processes: `scada-config`, `scada-proxy`, `scada-historian`, `scada-filesystem`, the protocol processes, and others. What each one does and the typical installations are described in [Server processes]({{ '/en/architecture/' | relative_url }}#tiers). Every process is started and configured the same way, so below "the Server" means any of them, and `server.json` means that process's parameter file.

A hot-standby Server is not supported in version 2.6, so the central computer is a single point of failure of the site (see [Redundancy]({{ '/en/architecture/' | relative_url }}#redundancy)).


Sections:

* [Setting up with scada-setup]({{ '/en/server/setup/' | relative_url }})
* [Licensing]({{ '/en/server/licensing/' | relative_url }})
* [Upgrade and removal]({{ '/en/server/upgrade/' | relative_url }})
* [Passwords and accounts]({{ '/en/server/security/' | relative_url }})
* [OPC UA and integration]({{ '/en/server/opcua/' | relative_url }})
* [Databases and files]({{ '/en/server/data/' | relative_url }})
* [Logs and monitoring]({{ '/en/server/monitoring/' | relative_url }})
* [Backup]({{ '/en/server/backup/' | relative_url }})
* [server.json parameters]({{ '/en/server/parameters/' | relative_url }})

## Runtime modes

On Windows, each Server process is installed as its own service — `Telecontrol SCADA Config`, `Telecontrol SCADA Proxy`, `Telecontrol SCADA Historian`, `Telecontrol SCADA IEC 104`, and so on (the full list is in [Server processes]({{ '/en/architecture/' | relative_url }}#tiers)) — and starts automatically during system boot.

It can also be started in console mode for diagnostics.

### Windows services {#services}

The services are registered by [`scada-setup`]({{ '/en/server/setup/' | relative_url }}); they run as the
SYSTEM account and start automatically with Windows. `scada-setup stop` and
`scada-setup start` stop and start all of a computer's services in the right
order (`start` with the [computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options): it skips the processes whose services the computer does not have, and fails only when the computer has none of the requested services); a single service can be controlled through the standard Windows
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
[computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options).

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
[Connection to the Server]({{ '/en/client/' | relative_url }}#connection)). See also [Monitoring]({{ '/en/server/monitoring/' | relative_url }}#monitoring).

### Console mode {#console}

For diagnostics, a Server process can run in a console window: it works as
the service does and prints its log to the screen. The installer creates no
shortcut for this.

1. Stop the process's service (for example *Telecontrol SCADA IEC 104*): the
   process and its service cannot run at the same time — they use the same
   ports and files.
2. Open an elevated command prompt: without administrator rights the process
   cannot read the [Server certificate]({{ '/en/server/opcua/' | relative_url }}#opcua-certificate)'s private key and
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
   [computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options).

Without `SCADA_SVC_PASSWORD` the process cannot connect to the other
processes. Console mode does not need `SCADA_ROOT_PASSWORD`: without it the
process leaves the `root` password the service stored unchanged (see
[Root password]({{ '/en/server/security/' | relative_url }}#root-password)).

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
| `--log-severity <level>` | Lowest level of the log messages, as the [`log.severity`]({{ '/en/server/monitoring/' | relative_url }}#logging) parameter; takes priority over it |

Processes installed by `scada-setup` are started with a `--param` naming
`%ProgramData%\Telecontrol\SCADA Server\<process folder>\server.json`.

### Linux deployment {#linux}

On Linux the Server is installed from a `.deb` package or a `.tar.gz`
archive into `/opt/telecontrol-scada` and set up with the same `scada-setup`
program (run it with `sudo`): `apply` creates the parameter files in
`/var/lib/scada/<process>/server.json`, the configuration databases, the
[Server certificate]({{ '/en/server/opcua/' | relative_url }}#opcua-certificate) in
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
* The package (or, after the archive, `apply`) creates the `scada` account
  and adds it to the `dialout` group, which owns the serial ports, also when
  the account already existed. When `apply` reports that it added the account
  to `dialout`, restart the services (`stop`, then `start` with the
  [computer's parameters]({{ '/en/getting-started/' | relative_url }}#host-parameters)): a process
  already running gets the ports only after a restart. If an RS-485 adapter
  belongs to another group, add `scada` to it
  (`sudo usermod -aG <group> scada`) and restart the services. The protocol
  processes may listen on ports below 1024 (for example port 502 for
  MODBUS TCP retransmission).
* The `svc` and `root` passwords are kept in the file
  `/var/lib/scada/secrets/service-secrets.env`, which only `root` can read
  (see [Where the passwords are stored]({{ '/en/server/setup/' | relative_url }}#stored-passwords)).
* `scada-setup status` prints each service's state as systemd names it:
  `active` — running, `inactive` — stopped, `failed` — stopped on an error.
* `apply` rewrites the service file on every run: put your own changes not
  in it but in the `server.override.json` parameter file (see
  [Your own parameters]({{ '/en/server/setup/' | relative_url }}#server-override)) or in a systemd drop-in
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
(`$ENV{NAME}`, see the [parameter reference]({{ '/en/server/parameters/' | relative_url }})), for example to
keep the [root password]({{ '/en/server/security/' | relative_url }}#root-password) out of the file. Installation in
Docker containers is available on request.
