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

It can also be started in console mode for diagnostics or manual
operation. In Linux deployments, the Server can run directly from an
unpacked distribution or inside a containerized environment.

### Windows service

Each service can be controlled through the standard Windows Services UI
or from the command line of that process's executable:

| Command | Purpose |
|---|---|
| `--install` | Install the Server as a Windows service |
| `--uninstall` | Remove the Windows service |

### Setting up with scada-setup {#scada-setup}

On Windows, the Server processes are installed and configured with the
`scada-setup` tool that comes with the installer. It writes the parameter
files `%ProgramData%\Telecontrol\SCADA Server\<process>\server.json` from
templates, creates the configuration databases, and registers the Windows
services. A process's folder has the name the process has in `--tiers`
(`config`, `proxy`, `historian`, `iec104`…), except `scada-filesystem`, whose
folder is `filestore`. The executables' `--install` / `--uninstall` options
are needed only for a hand-built setup. The step-by-step installation is in
[Getting started]({{ '/en/getting-started/' | relative_url }}).

| Command | Does | Needs admin |
|---|---|:-:|
| `scada-setup apply` | Write parameter files and databases, register and start the services of the licensed processes | yes |
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
variable), `--data-root`, `--install-root`.

`apply` can be run again: it rewrites the parameter files and brings the
services to the required state without touching data. Hand edits to the
parameter files are lost when it does.

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
4. Create the [Server certificate](#opcua-certificate) in
   `C:\Program Files\Telecontrol SCADA\data\Certificates` — the version 2.6
   processes do not start without it.
5. See what will be done (the command changes nothing):

   ```bat
   scada-setup migrate
   ```

   It lists what will be copied where, how much disk space that needs, which
   version 2.5 settings are not carried over, and anything that prevents the
   migration.
6. From an elevated command prompt, run the migration:

   ```bat
   scada-setup migrate --execute --svc-password <password>
   ```

   It stops and removes the *Telecontrol SCADA Server* service if it is still
   there, copies the data, and then runs `scada-setup apply`: it writes the
   parameter files and registers and starts the process services.
7. Set the [root password](#root-password) in the parameter files of
   `config`, `proxy`, `historian` and `filestore`, and restart the processes
   (`scada-setup stop`, then `scada-setup start`).
8. Connect a Client (port 2000, as before) as a user and check the objects,
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

To start a Server process in console mode, stop its service and run the desktop shortcut or the
Start-menu entry for the console variant.

If the current Windows user does not have administrative rights, server
operation in this mode may be limited or disrupted.

## Command-line options

The most important server startup options are:

| Option | Purpose |
|---|---|
| `--install` | Install the Server as a Windows service |
| `--uninstall` | Remove the Windows service |
| `--service` | Run in service mode |
| `--param <path>` | Use a specific parameter file. The default on Windows is `%ProgramData%\Telecontrol\SCADA <process>\<name>.json` (for example `%ProgramData%\Telecontrol\SCADA IEC 104\scada-iec104.json`); on Linux it is `<name>.json` in the `data` directory beside the executable's directory |
| `--name <name>` | Override the Windows service name, so several services of one process can coexist on a machine |
| `--display-name <name>` | Override the service display name and the console window title |
| `--log-severity <level>` | Set the logging level |

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

The license is checked at startup and then every few seconds:

* **No valid license**, or one that does not include this process — the
  process stops. The reason is written to the log.
* **The license could not be verified** (for example, the Google Cloud
  metadata server did not answer) — the process keeps running but serves no
  requests until verification succeeds.
* **The license has expired** — the process keeps running but refuses
  requests. Once the license file is replaced, service resumes without a
  restart.

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

The Server writes text log files. Key settings include:

| Parameter | Default | Description |
|---|---|---|
| `log.dir` | `${DIR_PARAM}/Logs` | Log-directory path |
| `log.max_file_size` | `10` | Maximum size of one log file in MB |
| `log.max_total_size` | `100` | Maximum total log size in MB |
| `log.max_count` | `1000` | Maximum number of log files |

When a log file reaches its maximum size, the Server rotates to a new
file. Old files are deleted automatically when the total size or file
count limit is exceeded.

The startup option `--log-severity` sets the logging level.

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

**`scada-setup` does not set this parameter**, and it rewrites the
parameter files it generates on every `apply` — the procedure is in
[Getting started]({{ '/en/getting-started/' | relative_url }}#root-password).

Set the parameter on **every** process that keeps the configuration in
its own database; each of them has its own `root` account. In a minimal
installation that is the single process. In the typical distributed
installation it is `scada-config`, `scada-proxy`, `scada-historian` and
`scada-filesystem`; the protocol processes receive their configuration
from `scada-config` and do not use this parameter (they log a message
saying so).

## OPC UA server {#opcua}

The Server can expose data to external systems through
[OPC UA](https://opcfoundation.org/about/opc-technologies/opc-ua/).
When enabled, external clients can browse the Server address space,
including objects, devices, and current or historical data.

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

**Parameter files written by [`scada-setup`](#scada-setup) point at
`C:\Program Files\Telecontrol SCADA\data\Certificates\ServerCertificate.pem`
and `ServerPrivateKey.pem`, and the installer does not create them.** Create
them before `scada-setup apply`, or the processes will not start.

A self-signed pair can be created with [OpenSSL](https://www.openssl.org/)
(not part of Windows; it comes, for example, with Git for Windows). Save this
as `cert.cnf`:

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
client certificate. To accept only trusted ones, set these folders:

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

All the data of the processes `scada-setup` installs is in
`%ProgramData%\Telecontrol\SCADA Server`: each process has its own folder
holding its parameter file and its data. The simplest backup copies that
whole folder, with the processes stopped so the copy is consistent:

```bat
scada-setup stop
rem copy %ProgramData%\Telecontrol\SCADA Server
scada-setup start
```

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

## `server.json` parameter reference {#parameters}

System settings are stored in the process's parameter file (`server.json`
in this section). Its default location is given under
[`--param`](#command-line-options).

These substitution variables can be used in the file:

| Variable | Description |
|---|---|
| `${DIR_PARAM}` | Directory containing the parameter file |
| `${DIR_EXE}` | Directory containing the Server executable |
| `${DIR_TEMP}` | Temporary directory |
| `$ENV{NAME}` | Value of the environment variable `NAME` (empty if it is not set) |
