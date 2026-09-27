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
services; the executables' `--install` / `--uninstall` options are needed only
for a hand-built setup. The step-by-step installation is in
[Getting started]({{ '/en/getting-started/' | relative_url }}).

| Command | Does | Needs admin |
|---|---|:-:|
| `scada-setup apply` | Write parameter files and databases, register and start the services of the licensed processes | yes |
| `scada-setup status` | License summary and each process's service state | no |
| `scada-setup start` / `stop` | Start / stop this computer's services in order | yes |
| `scada-setup remove [--purge-data]` | Stop and unregister the services (with `--purge-data`, delete the processes' data too) | yes |
| `scada-setup generate --output <dir>` | Write the parameter files only, for inspection | no |

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

By default, history is stored under
`%ProgramData%\Telecontrol\SCADA Server\History`.

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

For administration and diagnostics, the history database can be opened
with `sqlite3.exe`, which is installed with the Server. The Russian page
also includes example commands such as `pragma page_size`, `.tables`,
`.schema`, and simple SQL queries for event counts.

## Server-side file system {#filesystem}

The server-side file system stores schematic files on the Server so they
can be provided to all Clients without manual synchronization.

On new installations this feature is enabled automatically. On existing
installations it can be enabled through `server.json`:

```json
"filesystem": {
    "enabled": true,
    "dir": "${DIR_PARAM}/FileSystem"
}
```

By default the files are stored under
`%ProgramData%\Telecontrol\SCADA Server\FileSystem`.

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

The connection is protected with PEM-formatted certificates. A key and
certificate pair must be generated during initial setup.

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

### Configuration backup

For an SQLite configuration database, it is sufficient to copy
`%ProgramData%\Telecontrol\SCADA Server\Configuration`.

For PostgreSQL, use the standard PostgreSQL backup tools such as
`pg_dump`.

To migrate configuration data between formats, use `scada-admin`.

### History backup

History databases are stored under
`%ProgramData%\Telecontrol\SCADA Server\History`. Stop the Server before
copying them to ensure data consistency.

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
