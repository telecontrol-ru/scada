---
title: Databases and files
nav_order: 6
parent: Server
permalink: /en/server/data/
---

# Databases and files
{:.no_toc}

* TOC
{:toc}

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
[Upgrading from version 2.5]({{ '/en/server/upgrade/' | relative_url }}#upgrade-2-5)). The conversion needs the
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
[upgrading from version 2.5]({{ '/en/server/upgrade/' | relative_url }}#upgrade-2-5) copies them to the new folder.)
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
[upgrading from version 2.5]({{ '/en/server/upgrade/' | relative_url }}#upgrade-2-5) copies them to the new folder.)

Files are managed from the Client
[Files]({{ '/en/dev/server-files/' | relative_url }}) window.
