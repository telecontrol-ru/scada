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

Telecontrol SCADA uses a client-server architecture. The [Server]({{ '/en/server/' | relative_url }}) collects data from field devices, processes it in real time, stores history, and serves client sessions. The Server is a set of separate processes, each owning one part of that work; see [Server processes](#tiers). The graphical [Client]({{ '/en/client/' | relative_url }}) and web-based access tools connect over TCP/IP and present data to operators.

The main data flow is:

1. Devices send telemetry to the Server using industrial protocols such as MODBUS, IEC 60870-5, and IEC 61850.
1. The scanner layer (the protocol processes) receives and distributes updates into internal channels.
1. The real-time subsystem applies reservation, transformations, limit checks, and calculated values.
1. The historian (`scada-historian`) archives value changes and system events.
1. Clients display live and historical information and send control commands back to the Server.

## Server processes {#tiers}

The SCADA Server is not a single program but a set of processes. Each one is installed as its own Windows service (or run as its own process on Linux), reads its own parameter file, and is licensed separately, so an installation carries only the processes it needs.

| Process | Windows service | Role |
|:---|:---|:---|
| `scada-config` | Telecontrol SCADA Config | Holds the configuration (objects, equipment, users) and serves it to the other processes |
| `scada-proxy` | Telecontrol SCADA Proxy | Accepts Client connections and combines the other processes into one address space |
| `scada-historian` | Telecontrol SCADA Historian | [Archiving](#archiving) of values and events; serves history |
| `scada-filesystem` | Telecontrol SCADA Filesystem | [Server-side file system]({{ '/en/server/' | relative_url }}#filesystem) (displays and other files) |
| `scada-modbus` | Telecontrol SCADA Modbus | Data acquisition over MODBUS RTU/TCP |
| `scada-iec104` | Telecontrol SCADA IEC 104 | Data acquisition over IEC 60870-5-101/104 |
| `scada-iec61850` | Telecontrol SCADA IEC 61850 | Data acquisition over IEC 61850 |
| `scada-opc` | Telecontrol SCADA OPC | [OPC client](#opc-client-on-windows) (Windows only) |
| `scada-vidicon` | Telecontrol SCADA Vidicon | [Vidicon integration]({{ '/en/server/' | relative_url }}#vidicon) (Windows only) |

The processes exchange data with each other over OPC UA.

The protocol processes receive their configuration from `scada-config` and keep none of their own, so they run only together with it. **The smallest installation** the `scada-setup` tool builds is `scada-config`, one or more protocol processes, `scada-filesystem`, and `scada-proxy`, which the Clients connect to. Without `scada-filesystem` the server-side file system is unavailable (`scada-setup` warns about it). Add `scada-historian` for a value and event archive: only it stores history. The license must name every installed process — see [Choose the Server processes]({{ '/en/getting-started/' | relative_url }}#choose).

The processes may run on one computer or be spread over several: usually `scada-config`, `scada-historian`, `scada-filesystem` and `scada-proxy` run on a central computer, and the protocol processes on it or on computers near the equipment. Start them in this order: `scada-config`; then `scada-historian`, `scada-filesystem` and the protocol processes; then `scada-proxy`. `scada-setup start` keeps this order on each computer.

Running the processes — startup, Windows services, parameter files — is described in the [Server]({{ '/en/server/' | relative_url }}) section.

## Client-server interaction

Clients connect to the Server over TCP/IP on port `2000` by default —
to `scada-proxy`.
Client sessions tolerate short network interruptions and reconnect
automatically. Through a single session, the Client can subscribe to
live value updates, request historical data, execute control commands,
and edit configuration when the user role allows it.

Address and port configuration is described in the Server section on
[client connections]({{ '/en/server/' | relative_url }}#sessions).

## Roles and permissions

Each user account is given two independent rights, *Control* and *Configure*. Their combinations give four familiar profiles:

| Rights | Control, manual input and limits | Configuration editing |
|:---|:---:|:---:|
| Executive / viewer | No | No |
| SCADA engineer | Yes (see the warning) | Yes |
| Dispatcher | Yes | No |
| Administrator | Yes | Yes |

**WARNING: in this version the Configure right also lets an account issue control commands, enter values manually and change limits, even without the Control right.** Limits are, besides, edited in the object's properties (the Limits group) by anyone allowed to change the configuration. Give the Configure right only to people who may operate the plant.

Users authenticate with a name and password. The Server checks each request against OPC UA roles derived from these rights, which determine access to control operations, manual value entry, engineering tools, and user administration.

For user setup details, see
[User configuration]({{ '/en/dev/users/' | relative_url }}).

## Data objects {#data-items}

The main information objects are discrete signals, measured values, and control channels. Objects can be identified by number and, optionally, by a unique alias. They can also be archived with a defined history depth.

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

* inverted for discrete objects
* scaled linearly for measured values
* calculated from a [formula]({{ '/en/formulas/' | relative_url }})

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
channel automatically.

When communication is lost or restored, the scanner logs system events.
For operator-side communication monitoring, see
[Device watch]({{ '/en/client/device-watch/' | relative_url }}).

## Real-time processing

The real-time subsystem receives raw equipment data from the scanner and
distributes it to system objects. It calculates quality, handles source
redundancy, computes formulas and emulated values, and notifies clients
about object updates. In the reverse direction, it routes user commands
back to the scanner for execution.

When the Server restarts, the real-time subsystem restores the latest
object values from history.

It also supports out-of-order values: data that belongs to an earlier
timestamp than already received data is still processed and archived
correctly.

### Quality flags

Object values carry quality flags that are commonly displayed next to
the current value:

| Flag | Meaning |
|:-:|---|
| `K` | Not configured or configuration error |
| `C` | No communication |
| `H` | Connection error or invalid expression |
| `P` | Manual input |
| `2` | Backup channel |
| `B` | Blocked channel |
| `U` | Stale value |
| `V` | Limit violation |

### Manual input and blocking {#manual-write}

An operator with control privileges can manually set the value of any
discrete or measured object with the `Manual input` command.

At the same time, the operator can block the object. When blocked,
incoming telemetry from field devices is ignored and the manually
entered value takes priority. When the block is removed, the next device
update overwrites the manual value again.

### Limit checks {#limits}

Measured objects can define limit monitoring with alarm and pre-alarm
threshold pairs. Each pair has an upper and lower boundary.

![]({{ '/img/limits.png' | relative_url }})

When a discrete object changes state, the real-time subsystem logs a
system event. For measured objects, entering or leaving a limit range
also generates events.

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
predefined functions configured as simulated signals.

### Aperture

For measured objects, aperture filtering suppresses small value changes.
Any deviation smaller than the configured aperture is ignored.

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
[Archiving]({{ '/en/dev/history/' | relative_url }}); storage on the Server,
under [historical databases]({{ '/en/server/' | relative_url }}#history).

## External integration

### OPC UA server

Every SCADA Server process can act as an
[OPC UA](https://opcfoundation.org/about/opc-technologies/opc-ua/)
server and expose its address space to external systems. External OPC
UA clients can access current values, historical data, and
subscriptions.

Configuration is described in the Server section on
[OPC UA]({{ '/en/server/' | relative_url }}#opcua). **Note:** open the
processes' OPC UA ports only to the site's computers and trusted external
systems — see the same section.

### OPC client on Windows

On Windows, the `scada-opc` process can connect outward to Classic OPC (OPC DA)
servers. Their tags then appear in the Telecontrol SCADA address space
and can be bound to SCADA objects.

Configuration is described in the Server section on
[OPC client]({{ '/en/server/' | relative_url }}#opc-classic).

## Configuration

The configuration stored on disk contains all SCADA objects, equipment
structure, and users. It lives in a local database owned by
`scada-config` (`scada-proxy`, `scada-historian` and `scada-filesystem` also
keep configuration databases of their own). It is updated immediately when edited so that
changes are reflected across the running system without waiting for a
manual save step.

Configuration is edited with the built-in engineering tools, and
requires the *Configure* right.

The built-in `root` account has all rights and always exists,
whatever the configuration contains.

**WARNING:** while no root password is configured, the Server accepts
`root` with an empty password. On Windows, `scada-setup apply` sets it
(the `--root-password` option); in a hand-built setup, set it with
[`security.rootPassword`]({{ '/en/server/' | relative_url }}#root-password)
before the Server is reachable over the network.

For more details, see [Development]({{ '/en/development/' | relative_url }})
and [Configuration export and import]({{ '/en/dev/excel/' | relative_url }}).
