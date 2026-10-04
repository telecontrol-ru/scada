---
title: Server
nav_order: 6
permalink: /en/server/
---

# Server
{:.no_toc}

* TOC
{:toc}

The Server is the central runtime component of Telecontrol SCADA. It acquires data from equipment, processes live values, archives history, records events, and maintains client sessions. It runs on Windows and Linux.

The Server is a set of separate processes: `scada-config`, `scada-proxy`, `scada-historian`, `scada-filesystem`, the protocol processes, and others. What each one does and the typical installations are described in [Server processes]({{ '/en/architecture/' | relative_url }}#tiers). Every process is started and configured the same way, so below "the Server" means any of them, and `server.json` means that process's parameter file.

## Runtime modes

On Windows, each Server process is installed as its own service — `Telecontrol SCADA Config`, `Telecontrol SCADA Proxy`, `Telecontrol SCADA Historian`, `Telecontrol SCADA IEC 104`, and so on (the full list is in [Server processes]({{ '/en/architecture/' | relative_url }}#tiers)) — and starts automatically during system boot.

It can also be started in console mode for diagnostics. In Linux deployments, the Server can run directly from an
unpacked distribution or inside a containerized environment.

### Windows services {#services}

The services are registered by [`scada-setup`](#scada-setup); they run as the
SYSTEM account and start automatically with Windows. `scada-setup stop` and
`scada-setup start` stop and start all of a computer's services in the right
order; a single service can be controlled through the standard Windows
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
restarted — start it with `scada-setup start`.

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

| Command | Does | Needs admin |
|---|---|:-:|
| `scada-setup apply` | Write parameter files and databases, create the [Server certificate](#opcua-certificate) if there is none, register and start the services of the licensed processes | yes |
| `scada-setup status` | License summary and each process's service state | no |
| `scada-setup start` / `stop` | Start / stop this computer's services in order | yes |
| `scada-setup remove [--purge-data]` | Stop and unregister the services (with `--purge-data`, delete the processes' data too) | yes |
| `scada-setup generate --output <dir>` | Write the parameter files only, for inspection | no |
| `scada-setup migrate [--execute]` | Move a version 2.5 Server's data over — see [Upgrading from version 2.5](#upgrade-2-5) | with `--execute` |

Common options: `--tiers <list>` (default: the licensed processes),
`--central <address>` (required on a computer without `scada-config`),
`--advertise <address>` (this computer's address for the others, when its
name does not resolve on the network), `--license <path>` (default
`%ProgramData%\Telecontrol\SCADA Server\license.json`),
`--svc-password <password>` (or the `SCADA_SETUP_SVC_PASSWORD` environment
variable), `--root-password <password>` (or the `SCADA_SETUP_ROOT_PASSWORD`
environment variable; the [root password](#root-password), required by
`apply` and `migrate --execute` on a computer running `scada-config`,
`scada-proxy`, `scada-historian` or `scada-filesystem`), `--data-root`,
`--install-root`.

`apply` can be run again: it rewrites the parameter files and brings the
services to the required state without touching data. Repeat the same
`--tiers`, `--central` and `--advertise` as at installation: without
`--tiers` the command enables every process in the license.

**WARNING:** `apply` writes every `server.json` afresh from a template, and
**all** hand edits to it are lost — on every `apply`, every upgrade included.
If you changed parameters by hand (for example
[OPC UA client certificate checks](#opcua-certificate)), keep a copy of the
edited file, and after each `apply` make the changes again and restart the
process.

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

The steps, on the computer where the 2.5 Server ran:

1. Obtain a version 2.6 license (a `license.json` file) from Telecontrol and
   put it at `%ProgramData%\Telecontrol\SCADA Server\license.json`. Version
   2.6 does not use the HASP or Guardant hardware key.
2. Back up the whole `%ProgramData%\Telecontrol\SCADA Server` folder.
3. Install the version 2.6 package:

   ```bat
   msiexec /i telecontrol-scada-<version>.msi /qn
   ```

   The installer replaces the version 2.5 program and normally removes its
   service itself; the data stays where it is.
4. See what will be done (the command changes nothing):

   ```bat
   scada-setup migrate
   ```

   It lists what will be copied where, how much disk space that needs, which
   version 2.5 settings are not carried over, and anything that prevents the
   migration.
5. From an elevated command prompt, run the migration:

   ```bat
   scada-setup migrate --execute --svc-password <password> --root-password <root password>
   ```

   It stops and removes the *Telecontrol SCADA Server* service if it is still
   there, copies the data, and then runs `scada-setup apply`: it writes the
   parameter files, creates the [Server certificate](#opcua-certificate) if
   there is none yet, and registers and starts the process services. User
   passwords are carried over, while the version 2.5 root password — whether
   set with `security.rootPassword` or changed from the Client — is replaced
   on the 2.6 processes' first start by the [root password](#root-password)
   given as `--root-password`.
6. Connect a Client (port 2000, as before) as a user and check the objects,
   the history and the schematics.

The migration does not start, and the command says why, when:

* the version 2.5 configuration is not stored in SQLite (for example, it is in
  PostgreSQL);
* a version 2.5 user has the id 100, which the `svc` service account takes.
  Create the same user in version 2.5 under another name, delete the old one,
  and migrate again;
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
4. To finish, close the window or press *Ctrl+C*, then start the service
   again: `scada-setup start`.

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

The Server supports Linux. The graphical Client does not.

#### Run from an archive

Unpack the server distribution archive and start the executables of the
processes you need (`scada-config`, `scada-iec104`, and so on). Each
process reads its own parameter file `data/<name>.json`, where `data` is
resolved from the executable's directory as `<program dir>/../data`, or
the file passed with `--param`.

#### Docker deployment

All processes share one Docker image. The environment variable `ROLE`
selects which process a container runs (`config`, `proxy`, `historian`,
`filesystem`, `modbus`, `iec104`, `iec61850`), and that process's
parameter file is mounted as `/etc/scada/<ROLE>.json`. Client
connections are accepted by the `proxy` container on port `2000`.

The parameter file supports environment-variable substitution in the
`$ENV{VARIABLE_NAME}` form, which is useful for values such as a
PostgreSQL connection string or the [root password](#root-password). An
undefined variable is replaced with an empty string.

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
  it — once the file is fixed, start the processes with `scada-setup start`.
* **The license could not be verified** (for example, the Google Cloud
  metadata server did not answer) — the process keeps running but serves no
  requests until verification succeeds.
* **The license has expired** — the process keeps running but refuses
  requests. Once the license file is replaced, service resumes without a
  restart.

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

The Russian source page includes a sizing rule of thumb:

`size = freq * depth / 10000`

where:

* `size` is the expected database size in MB
* `freq` is the number of value changes per day
* `depth` is the retention depth in days

The inverse formula can be used to estimate the maximum retention depth
from the available disk space.

### Working with SQLite directly

For administration and diagnostics, a history database can be opened with
the `sqlite3` command-line tool. Version 2.6 does not install it (versions 2.5
and earlier did); download it from the
[SQLite download page](https://sqlite.org/download.html). The database file is
named `history` and sits in the database's folder: change to that folder and
run `sqlite3 history`. Open a database for writing only while its process is
stopped (`scada-setup stop`). The Russian page also includes example commands
such as `pragma page_size`, `.tables`, `.schema`, and simple SQL queries for
event counts.

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
| `log.console_severity` | — | Lowest level of the messages printed **to the screen** in [console mode](#console) or to a container's output: `Trace`, `Debug`, `Info`, `Warning`, `Error` or `Critical`. Does not affect the log files |

A new file is started when the current one reaches its maximum size, and
every day at midnight. Old files are deleted automatically when the total
size or file count limit is exceeded. The level of the messages written to
the files is not configurable.

## Monitoring {#monitoring}

* **Service and license state** — `scada-setup status` on each computer:
  the license expiry, the processes it entitles, and the state of each
  process's service.
* **Process logs** — see [Logging](#logging). Why a process stopped (license,
  certificate, parameter file) is written to its log.
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
processes' Windows service settings. On a computer running one of those
processes, `apply` refuses to run without it. To change the root password,
run `apply` with the new value; do not edit the generated parameter files,
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

## OPC UA server {#opcua}

The Server can expose data to external systems through
[OPC UA](https://opcfoundation.org/about/opc-technologies/opc-ua/).
When enabled, external clients can browse the Server address space,
including objects, devices, and current or historical data.

In an installation made by `scada-setup`, OPC UA is enabled on every process
(ports 4840–4848, see
[Network preparation]({{ '/en/getting-started/' | relative_url }}#network)):
the processes exchange data with each other over it.

**WARNING:** open the OPC UA ports to the site's computers only. Processes
register with `scada-proxy` and `scada-config` without authentication,
anonymous sign-in is always offered, and client certificates are not checked
by default. If an external system must connect to the Server, allow port
4840 in the firewall from its address only, and turn on
[client certificate checks](#opcua-certificate).

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

1. Stop the processes: `scada-setup stop`.
2. Delete both files from `C:\Program Files\Telecontrol SCADA\data\Certificates`,
   or put your own pair in their place (the key in PEM format, without a
   passphrase).
3. Run `scada-setup apply` with the same options as at installation: a
   missing pair is created again, and the processes start.

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
restrict access to the key file.

**Client** certificates are not checked by default: the Server accepts any
client certificate. To accept only trusted ones, set these folders in the
`opcua` block of the parameter file:

| Parameter | Description |
|---|---|
| `trusted_certificates_dir` | Trusted client certificates (PEM or DER); a client is accepted when its certificate is in this folder |
| `issuer_certificates_dir` | Certificate authority certificates; a client whose certificate they signed is accepted |
| `crl_dir` | Revocation lists for those authorities |
| `rejected_certificates_dir` | Rejected client certificates are written here, to be moved to the trusted folder if wanted |

Further restrictions go in the `opcua.security` block:
`"allow_none": false` forbids unsecured connections,
`"require_encryption_for_password": true` forbids sending a password
unencrypted, and `"require_trusted_client_cert": true` requires a trusted
client certificate. Anonymous sign-in is always offered. The desktop Client
does not verify the Server's certificate.

**WARNING:** `scada-setup` sets none of these parameters, and every
`scada-setup apply` (upgrades included) writes the parameter files afresh,
losing parameters added by hand. Keep a copy of the edited files, and after
each `apply` make the changes again and restart the processes.

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
running databases may be inconsistent.

```bat
scada-setup stop
rem copy %ProgramData%\Telecontrol\SCADA Server
rem and C:\Program Files\Telecontrol SCADA\data\Certificates
scada-setup start
```

A restore also needs the `svc` password, the `root` password, and the
`--tiers`, `--central` and `--advertise` that `scada-setup apply` was run
with on this computer; none of them is in the backup.

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

On the same computer:

1. Stop the processes: `scada-setup stop`.
2. Put the `%ProgramData%\Telecontrol\SCADA Server` folder (and the
   `Certificates` folder, if it is gone) back from the backup.
3. Start the processes: `scada-setup start`.
4. Check the result: `scada-setup status`.

On a new or rebuilt computer:

1. Install the package of **the same version** as the backup.
2. Put the `%ProgramData%\Telecontrol\SCADA Server` folder and the
   `C:\Program Files\Telecontrol SCADA\data\Certificates` folder back from
   the backup. Restrict access to `ServerPrivateKey.pem` to the SYSTEM
   account and administrators: a copied file takes the folder's permissions.
3. From an elevated command prompt, run `scada-setup apply` with the same
   `--tiers`, `--central` and `--advertise` as before, **the same `svc`
   password**, and the `root` password. The `svc` password is stored in the
   restored databases, and with a different one the processes cannot connect
   to each other. `apply` registers and starts the services, and keeps the
   restored databases and certificate.
4. Check the result: `scada-setup status`.

Without the `Certificates` folder, `apply` creates a new certificate, and
third-party OPC UA clients that trusted the old one have to be set up again.

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
