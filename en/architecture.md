---
title: Architecture
nav_order: 3
permalink: /en/architecture/
---

# Architecture
{:.no_toc}

* TOC
{:toc}

## Overview

Telecontrol SCADA uses a client-server architecture. The [Server]({{ '/en/server/' | relative_url }}) collects data from field devices, processes it in real time, stores history, and serves client sessions. The Server is a set of separate processes, each owning one part of that work; see [Server processes](#tiers). The Server runs in Telecontrol's cloud. [Clients]({{ '/en/client/' | relative_url }}) connect to it over encrypted OPC UA and give the operator visualization and control. The number of Clients is not limited.

The main data flow is:

1. Devices send telemetry to the Server using industrial protocols such as MODBUS, IEC 60870-5, and IEC 61850.
1. The scanner layer (the protocol processes) receives and distributes updates into internal channels.
1. The real-time subsystem applies reservation, transformations, limit checks, and calculated values.
1. The historian (`scada-historian`) archives value changes and system events.
1. Clients display live and historical information and send control commands back to the Server.

The Server can also provide data to external systems over [OPC UA](#opc-ua-server).

## Server processes {#tiers}

The SCADA Server is not a single program but a set of processes. The Server runs in Telecontrol's cloud: Telecontrol installs, upgrades, backs up and monitors the processes there, and which processes the service includes is agreed in the contract (see [Server]({{ '/en/server/' | relative_url }}#service)). The protocol processes run either in the cloud or at the site — as the **site gateway**, on a Linux computer next to the devices, which the customer installs (see [Site gateway]({{ '/en/server/' | relative_url }}#gateway)).

| Process | Where it runs | Role |
|:---|:---|:---|
| `scada-config` | cloud | Holds the configuration (objects, equipment, users) and serves it to the other processes |
| `scada-proxy` | cloud | Accepts Client connections and combines the other processes into one address space |
| `scada-historian` | cloud | [Archiving](#archiving) of values and events; serves history |
| `scada-filesystem` | cloud | [Server-side file system]({{ '/en/dev/server-files/' | relative_url }}) (displays and other files) |
| `scada-modbus` | cloud or site gateway | Data acquisition over MODBUS RTU/ASCII/TCP |
| `scada-iec104` | cloud or site gateway | Data acquisition over IEC 60870-5-101/104 |
| `scada-iec61850` | cloud or site gateway | Data acquisition over IEC 61850 |

The `scada-opc` ([OPC client](#opc-client-on-windows)) and `scada-vidicon` ([Vidicon integration]({{ '/en/protocols/' | relative_url }}#vidicon)) processes run only on Windows and are not available with the hosted Server (see [Unavailable features]({{ '/en/server/' | relative_url }}#unavailable)).

Retransmission to a dispatch centre is carried out by the protocol process of the protocol the DC receives data over: `scada-iec104` for IEC 60870-5-101/104, or `scada-modbus` for MODBUS. So retransmission needs that process in the service, even when the objects sent to the DC are received by another process (see [Retransmission to a dispatch centre]({{ '/en/dev/devices/' | relative_url }}#retransmission)).

The processes exchange data with each other over OPC UA; the links between them are encrypted.

The protocol processes receive their configuration from `scada-config` and keep none of their own, so they run only together with it; the site gateway works the same way. The gateway connects to the cloud itself over encrypted OPC UA, and the cloud works with the gateway over that connection, so no inbound port has to be opened on the gateway computer (see [Gateway port]({{ '/en/server/' | relative_url }}#gateway-port)). Only `scada-historian` stores the history of values and events, so without it there is no archive and no report or summary over the archive.

The devices of one protocol may be served by different computers — for example, the cloud and a site gateway, or several gateways. A link's Computer property says which computer serves it (see [Equipment]({{ '/en/dev/devices/' | relative_url }})).

## Client-server interaction

Clients connect to the Server's `scada-proxy` process over OPC UA with
signing and encryption, under a named account; the Client verifies the
Server certificate by its SHA-256 fingerprint, which Telecontrol gives (see
[Connecting Clients]({{ '/en/server/' | relative_url }}#client-connection)).
Client sessions tolerate short network interruptions and reconnect
automatically. Through a single session, the Client can subscribe to
live value updates, request historical data, execute control commands,
and edit configuration when the user role allows it.

## Roles and permissions

An account holds two independent rights, *Control* and *Configure*, through membership of OPC UA roles: Control comes with the `Operator` role, Configure with the `ConfigureAdmin` role. Their combinations give four familiar profiles:

| Rights | Control, manual input and limits | Configuration editing |
|:---|:---:|:---:|
| Executive / viewer | No | No |
| SCADA engineer | No | Yes |
| Dispatcher | Yes | No |
| Administrator | Yes | Yes |

Control commands, manual value entry and limit changes need the Control right, including limits in the object's properties (the Limits group). The Configure right does not grant them. The configuration, conversely, is changed only with the Configure right; the Control right can only enable and disable devices.

Users authenticate with a name and password. The Server grants the session rights from the roles the account is a member of and checks each request against them; the roles determine access to control operations, manual value entry, engineering tools, and user administration.

An administrator assigns an account's roles in the Client, with `Roles...` on the user; a new account with no roles can only view data. Accounts that existed before the upgrade keep their rights. See [Access rights]({{ '/en/dev/users/' | relative_url }}#access-rights).

For user setup details, see
[User configuration]({{ '/en/dev/users/' | relative_url }}).

## Data objects {#data-items}

The main information objects are discrete signals, measured values, and control channels. Objects can be identified by number and, optionally, by a text alias: a user-defined name unique within the system (no spaces; for the allowed characters, see [Binding objects]({{ '/en/dev/displays/' | relative_url }}#binding)). The identification is needed to bind objects to elements of graphic schematics and to use them in calculated-value expressions. Their values can also be archived: the object is assigned an archive, and the retention depth in days is set on the archive, not on the object (see [Archiving]({{ '/en/dev/history/' | relative_url }})).

**WARNING: deleting an object deletes all of its history.**

Objects may be grouped into hierarchical structures that reflect the monitored process layout, for example by plant, substation, or device group.

### Object groups

Objects can be organized into object groups, and groups can be nested
inside other groups. This allows the system to represent hierarchical
structures such as:

```text
Substation
    Feeder
        Metering node
            ...
```

### Redundancy

Each object can use up to two data sources to implement hot standby. If
the primary source loses validity, the system switches automatically to
the backup source and switches back when the primary source recovers.

An object can also define one control channel. That control channel may
even be the same exchange channel that provides the object's source
data.

Incoming values can be:

* inverted (for discrete objects)
* scaled linearly (for measured values)
* calculated from a [formula]({{ '/en/formulas/' | relative_url }})

This describes redundancy of an object's data sources. **Redundancy of the
Server itself (a second, hot-standby Server) is not a supported
configuration in version 2.6**. So the `scada-config`, `scada-proxy`,
`scada-historian` and `scada-filesystem` processes in the cloud are a single
point of failure: while they are down, the Clients get no data. Ask
Telecontrol about redundancy and the availability of the service.

## Devices and protocols

The SCADA configuration distinguishes between directions and devices.
Directions describe the physical communication channel, such as a serial
port or IP endpoint. Devices belong to directions and are identified by
the address they use on that channel.

Supported exchange protocols include:

* IEC 60870-5-101
* IEC 60870-5-104
* IEC 61850
* MODBUS RTU
* MODBUS ASCII
* MODBUS TCP

See the full protocol overview in
[Protocols]({{ '/en/protocols/' | relative_url }}).

### Information channels

In many cases an information channel is just a single address value, as
in IEC protocols. In other cases, especially with MODBUS, the channel
specification depends on the protocol and device type.

Examples:

* IEC channels: `1`, `23`, `1403`
* MODBUS channels: `BOOL:3`, `UINT16:30020`

Information channels also carry a quality state that reflects link
status or validity information reported by the device.

### Retransmission

Retransmission allows Telecontrol SCADA objects to be forwarded to
higher-level systems through supported protocols. This is implemented
with a virtual server-side device and a retransmission table that maps
SCADA objects to the remote system's channel addresses.

Retransmission works in both directions: values are sent outward, and
incoming control commands can be relayed back to the field equipment.

The setup — the direction, the receiving device and the retransmission
table — is described in
[Retransmission to a dispatch centre]({{ '/en/dev/devices/' | relative_url }}#retransmission);
working with the table itself is described in
[Transmission rules]({{ '/en/client/workbench/' | relative_url }}#transmission).

## Data acquisition

The scanner subsystem collects data from field equipment according to
the configured directions, devices, and protocols. It also executes
control commands, time synchronization, forced polling, and
retransmission functions.

If a user edits the configuration of a direction or device, or adds or
removes one, the scanner re-establishes or closes the communication
channel automatically. Once communication with a device is established,
the scanner runs the initialization commands (full poll, time
synchronization) according to the device's configuration.

The scanner passes control commands, and other commands received from
users, on to the devices.

When communication is lost or restored, the scanner logs system events.
For operator-side communication monitoring, see
[Device watch]({{ '/en/client/device-watch/' | relative_url }}).

## Real-time processing

The real-time subsystem receives raw equipment data from the scanner and
distributes it to system objects. It calculates quality, handles source
redundancy, computes formulas and emulated values, and notifies clients
about object updates. In the reverse direction, it routes user commands
back to the scanner for execution.

The real-time subsystem distributes the values of the devices' information
channels between system objects according to the configuration. When an
object has two data sources (primary and backup), it switches to the backup
source and back automatically, depending on the quality of the primary one.

The value of a discrete object can be inverted, according to its
configuration. A measured object can define a linear transformation that
converts the physical scale into the logical one.

After a protocol process restarts, its archived objects take their latest
values from history — with the quality and time they were archived with —
and show them until the devices report new values.

It also supports out-of-order values: data that belongs to an earlier
timestamp than already received data is still processed and archived
correctly.

### Quality flags

Object values carry quality flags that are commonly displayed next to
the current value. The Client shows them with their Russian letters in every
interface language:

| Flag | Meaning |
|:-:|---|
| `К` | Not configured, configuration error, or an invalid calculation formula |
| `С` | No communication |
| `Н` | Connection error |
| `Р` | Manual input |
| `2` | Backup channel (set by Server 2.6; a 2.5.7 Server never sets it) |
| `Б` | Blocked channel |
| `У` | Stale value |
| `В` | Limit violation |

### Manual input and blocking {#manual-write}

An operator with control privileges can manually set the value of any
discrete or measured object with the `Manual input` command.

At the same time, the operator can block the object. When blocked,
incoming telemetry from field devices is ignored and the manually
entered value takes priority. When the block is removed, the next device
update overwrites the manual value again.

A blocked object carries the quality flag `Б`. The block is removed with the
`Unlock` command (Russian UI: «Разблокировать») from the object's context
menu.

### Limit checks {#limits}

Measured objects can define limit monitoring with alarm and pre-alarm
threshold pairs. Each pair has an upper and lower boundary.

Both pairs may be set, or only one of them. The upper and lower limits of a
pair need not be set together: one bound may be set alone.

Pre-alarm limits, if set, must lie inside the alarm limits.

![]({{ '/img/limits.png' | relative_url }})

When a discrete object changes state, the real-time subsystem logs a
system event. For measured objects, entering or leaving a limit range
also generates events:

| Limit | Event when the value enters the band |
|-------|--------------------------------------|
|       | Alarm: Value > x                     |
| Upper alarm |                                |
|       | Value > x                            |
| Upper pre-alarm |                            |
|       | Value is normal                      |
| Lower pre-alarm |                            |
|       | Value < x                            |
| Lower alarm |                                |
|       | Alarm: Value < x                     |

**WARNING: a limit event gets the object's severity** (the Severity
field in its properties, 10 by default), not a severity of its own for
pre-alarm and alarm limits. At the default severity these events are not
highlighted in the event journal or the current events panel. For an
operator to notice a limit violation, set the measured object's Severity to
600 or higher (yellow background, Warning) or 800 or higher (red
background, Critical). The pre-alarm and alarm events of one object are
coloured the same. See the Severity field under
[Object properties]({{ '/en/dev/data-items/' | relative_url }}#object-properties).

When a measured object with configured limits is displayed in a
[Graph]({{ '/en/client/graph/' | relative_url }}), the limits are shown
as dashed lines:

![]({{ '/img/limits-chart.png' | relative_url }})

## Calculations and filtering

### Formulas

Any SCADA object can use a mathematical expression, also called a
formula or calculated value, as its data source. Expressions can include
arithmetic operators, references to other objects by alias, and
built-in functions.

See the full syntax in [Formulas]({{ '/en/formulas/' | relative_url }}).

### Emulation

For project preparation and testing, objects can use emulated signals
instead of real equipment. The data is generated by one of the
predefined functions configured as simulated signals, with a given period,
phase and update interval (the *Period, ms*, *Phase, ms* and *Update, ms*
parameters).

### Aperture

For measured objects, aperture filtering suppresses small value changes.
The aperture is set in absolute units, the same as the object's value.
Any deviation from the current value smaller than the aperture is ignored.

### Deadband

The deadband suppresses small measured values around zero. Values whose
absolute magnitude is smaller than the configured deadband are forced to
zero.

### Stale detection

An object can define a stale-data interval. If the value is not updated
within that interval, the real-time subsystem marks it with the stale
flag.

## System events

A SCADA system event is a record whose main fields are event time and
message. Newly registered events remain unacknowledged until a user
acknowledges them, and acknowledgement is system-wide.

If an event belongs to an object, the event also references that object.
Typical object-related events include:

* discrete state changes
* measured-value limit transitions
* manual input and blocking
* block removal
* steps in a control-command workflow

Some events are associated with devices instead, for example:

* communication loss and restoration
* device restart, reconfiguration, or removal

Events are reviewed in the
[Event journal]({{ '/en/client/events/' | relative_url }}).

## Archiving

The archive subsystem (`scada-historian`) stores historical object values and system events
in one or more
[SQLite](https://www.sqlite.org/index.html) databases. This database
engine is built into the process, so no third-party database system is
required.

Archived history can then be queried and displayed in the
[Graph]({{ '/en/client/graph/' | relative_url }}),
[Data]({{ '/en/client/data/' | relative_url }}), and
[Summary]({{ '/en/client/summary/' | relative_url }}) views.

Creating archives and assigning them to objects is described under
[Archiving]({{ '/en/dev/history/' | relative_url }}).

## External integration

### OPC UA server

The SCADA Server processes exchange data with each other over
[OPC UA](https://opcfoundation.org/about/opc-technologies/opc-ua/) with
encryption (security policy Basic256Sha256, mode Sign and Encrypt).
External systems can connect to the `scada-proxy` process and access
current values, historical data, and subscriptions.

The Server accepts only secured connections that sign in with a user name.
Arrange connecting an external system to the hosted Server with Telecontrol
(see [Server]({{ '/en/server/' | relative_url }}#service)).

### OPC client on Windows

The `scada-opc` process connects outward to Classic OPC (OPC DA) servers.
It runs only on Windows, so it is not available with the hosted Server (see
[Unavailable features]({{ '/en/server/' | relative_url }}#unavailable)).

## Configuration

The configuration stored on disk contains all SCADA objects, equipment
structure, and users. It lives in a database owned by
`scada-config` (`scada-proxy`, `scada-historian` and the protocol
processes, the site gateway included, receive their configuration from
`scada-config`). It is updated immediately when edited so that
changes are reflected across the running system without waiting for a
manual save step.

The customer creates and changes the project — objects, equipment,
displays, users and roles — in the Client (see
[What the customer does]({{ '/en/server/' | relative_url }}#customer)).

Configuration is edited with the built-in engineering tools, and
requires the *Configure* right.

The built-in `root` account has every user right and always exists,
whatever the configuration contains. On the hosted Server its password is
set and kept by Telecontrol; the customer works in the Client under named
accounts (see [Users]({{ '/en/dev/users/' | relative_url }})).

For more details, see [Development]({{ '/en/development/' | relative_url }})
and [Configuration export and import]({{ '/en/dev/excel/' | relative_url }}).
