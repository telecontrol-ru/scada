---
title: Overview
nav_order: 1
permalink: /en/
---

# Overview

{: .note }
> **The version 2.6 Server is offered only as a service: Telecontrol hosts it
> in its cloud and maintains it** — installs, upgrades, backs up, monitors and
> licenses it. A Server to install on your own computers is not offered
> ([Server]({{ '/en/server/' | relative_url }})).
>
> * This manual describes version 2.6, published as releases
>   [2.6.0, 2.6.3, 2.6.4, 2.6.8 and 2.6.11]({{ '/en/changes/' | relative_url }}#v2-6); they carry the Client
>   packages ([Client installation]({{ '/en/getting-started/' | relative_url }}#client-install)).
> * Clients connect to the Server over encrypted OPC UA
>   ([Connecting Clients]({{ '/en/server/' | relative_url }}#client-connection)).
> * The site's devices are reached through a site gateway — a Server protocol
>   process the customer installs on a Linux computer next to the devices
>   ([Site gateway]({{ '/en/server/' | relative_url }}#gateway)).
> * The OPC DA client and the Vidicon integration need a Windows Server and are
>   not available with the hosted Server
>   ([Unavailable features]({{ '/en/server/' | relative_url }}#unavailable)).
> * The previous release, [2.5.7]({{ '/en/changes/' | relative_url }}#v2-5-7), is built
>   differently: its Server is a single Windows service with a HASP or Guardant
>   hardware key. Existing 2.5.7 installations keep working, and moving to the
>   hosted Server is arranged with Telecontrol
>   ([Server 2.5.7 and on-site installations]({{ '/en/server/' | relative_url }}#legacy)).
> * Before buying the service or moving to it, read the version 2.6
>   [Known limitations]({{ '/en/changes/' | relative_url }}#known-limitations) — in particular,
>   the Client packages do not yet include the display module (it is supplied
>   separately, and without it schematics are not shown), and an account
>   created in the Client can only view data until an administrator assigns it
>   roles with the *Roles…* command
>   ([Assigning roles]({{ '/en/dev/users/' | relative_url }}#assign-roles)).

Telecontrol SCADA is supervisory control and data acquisition software
for collecting field data, presenting it to operators, issuing control
commands, archiving telemetry, and displaying historical information.

The system uses a client-server architecture. In version 2.6 the Server is a
set of separate processes: protocol processes (MODBUS, IEC 60870-5-104 and
IEC 61850), the archive, the configuration, the file store, and a proxy that
Clients connect to. The Server runs in Telecontrol's cloud; the protocol
processes run there too or at the site, as the site gateway next to the
devices. What the service includes is agreed in the contract (see
[Getting the hosted Server]({{ '/en/getting-started/' | relative_url }}#buy-now) and
[Server processes]({{ '/en/architecture/' | relative_url }}#tiers)).
Any number of Clients can connect.

Clients connect to the Server over encrypted OPC UA. When the connection is
lost — including after the Server is restarted — the Client reconnects by
itself (see
[Connection to the Server]({{ '/en/client/' | relative_url }}#connection)).

The Client runs on Windows 10 or newer and on macOS 26 or newer on computers
with Apple silicon (see
[Client installation]({{ '/en/getting-started/' | relative_url }}#client-install)).
The site gateway needs an x86-64 Linux computer with systemd (see
[Site gateway]({{ '/en/server/' | relative_url }}#gateway)).
The Client displays Modus diagrams and Vidicon schematics with live values
with its own display module, without the ActiveXeme component; that module is
not in the release packages — Telecontrol supplies it separately, on terms
agreed with them (see
[Client installation]({{ '/en/getting-started/' | relative_url }}#client-install)). The
[Modus graphical editor](http://swman.ru/content/blogcategory/19/47/) is
used to edit diagrams.

## Where to start {#roles}

* **Evaluating and buying**: the version 2.6
  [Known limitations]({{ '/en/changes/' | relative_url }}#known-limitations), then
  [Server]({{ '/en/server/' | relative_url }}) — what Telecontrol does and what
  the customer does — and [Getting the hosted Server]({{ '/en/getting-started/' | relative_url }}#buy-now).
  The [2.6.11](https://github.com/alexsmn/scada-client/releases/tag/v2.6.11) Client is a
  free download. Terms and prices of the service: Telecontrol,
  mail@telecontrol.ru.
* **Administrator** on the customer's side, who manages users, Clients and the
  site gateway:
  [What the customer does]({{ '/en/server/' | relative_url }}#customer),
  [Client installation]({{ '/en/getting-started/' | relative_url }}#client-install),
  [Connecting Clients]({{ '/en/server/' | relative_url }}#client-connection),
  [Users]({{ '/en/dev/users/' | relative_url }}) and
  [Site gateway]({{ '/en/server/' | relative_url }}#gateway).
* **Project engineer**, who builds the project:
  [Architecture]({{ '/en/architecture/' | relative_url }}), then the
  [Development]({{ '/en/development/' | relative_url }}) section —
  [Equipment]({{ '/en/dev/devices/' | relative_url }}), [Data items]({{ '/en/dev/data-items/' | relative_url }}),
  [Displays]({{ '/en/dev/displays/' | relative_url }}), [Protocols]({{ '/en/protocols/' | relative_url }}),
  [Formulas]({{ '/en/formulas/' | relative_url }}) and [Users]({{ '/en/dev/users/' | relative_url }}).
* **Operator**: [Connection to the Server]({{ '/en/client/' | relative_url }}#connection),
  [Operator workbench]({{ '/en/client/workbench/' | relative_url }}),
  [Reading values and colours]({{ '/en/client/' | relative_url }}#quality-legend),
  [Alarm annunciation]({{ '/en/client/alarms/' | relative_url }}),
  [Event journal]({{ '/en/client/events/' | relative_url }}), [Control]({{ '/en/client/' | relative_url }}#control),
  [Manual input]({{ '/en/client/' | relative_url }}#manual-input), [Display]({{ '/en/client/display/' | relative_url }})
  and [Shift handover]({{ '/en/client/' | relative_url }}#shift-change).
* **Manager**, who only views data:
  [Reports and analysis]({{ '/en/client/reports/' | relative_url }}), [Summary]({{ '/en/client/summary/' | relative_url }}),
  [Graph]({{ '/en/client/graph/' | relative_url }}), [Table]({{ '/en/client/table/' | relative_url }}),
  [Printing]({{ '/en/client/print/' | relative_url }}) and
  [Export]({{ '/en/client/export/' | relative_url }}).

What changed between versions is described in the
[Change log]({{ '/en/changes/' | relative_url }}).

All schematics are stored as vector graphics, so even large process
diagrams remain compact and can be displayed at large scale on shared
operator panels without loss of image quality.

The platform supports one or more operator workstations depending on the
required user roles and access rights for the monitored automation
system.

How working with the hosted Server is arranged (details on the
[Server]({{ '/en/server/' | relative_url }}) page):

![Clients connect to the Server in Telecontrol's cloud, and the Server connects to the gateway at the customer's site, which polls the devices]({{ '/img/hosted-deployment-en.svg' | relative_url }})

## Key features

* Distributed multi-user [Architecture]({{ '/en/architecture/' | relative_url }}), with the Server as a service in Telecontrol's cloud and the Client on Windows and macOS
* Modus and Vidicon [displays]({{ '/en/client/display/' | relative_url }}) with live
  switch positions and values; for the limitations of version 2.6 see
  [Known limitations]({{ '/en/changes/' | relative_url }}#limits-upgrade).
  Before upgrading, check your site's schematics in a 2.6 Client: the
  instruments and controls the Modus graphics editor draws as pictures are
  drawn simplified, without a needle or lettering, the *Spectrum_UP*,
  *Spectrum_P*, *Server*, *отвертка* (screwdriver) and *XP4* elements are not
  drawn yet, and the bindings
  have not yet been tried on the schematics of working sites
* Interactive [tables]({{ '/en/client/table/' | relative_url }}),
  [graphs]({{ '/en/client/graph/' | relative_url }}), and
  [summaries]({{ '/en/client/summary/' | relative_url }}) with archive
  aggregation
* [User tables]({{ '/en/client/sheet/' | relative_url }}) with formulas
* Telemetry acquisition and control over
  [MODBUS]({{ '/en/protocols/' | relative_url }}#modbus),
  [IEC 60870-5]({{ '/en/protocols/' | relative_url }}#iec-60870), and
  [IEC 61850]({{ '/en/protocols/' | relative_url }}#iec-61850), and from
  external OPC servers over [OPC DA]({{ '/en/protocols/' | relative_url }}#opc)
  (not available with the hosted Server); for the limitations of version 2.6 see
  [Known limitations]({{ '/en/changes/' | relative_url }}#limits-protocols)
* [Retransmission]({{ '/en/dev/devices/' | relative_url }}#retransmission)
  of selected data to upper-level systems and an OPC UA server; for the
  limitations of version 2.6 see
  [Known limitations]({{ '/en/changes/' | relative_url }}#limits-protocols)
* [Vidicon integration]({{ '/en/protocols/' | relative_url }}#vidicon)
  for migrating existing projects (not available with the hosted Server)
* [Formulas]({{ '/en/formulas/' | relative_url }}),
  [manual input]({{ '/en/architecture/' | relative_url }}#manual-write),
  and [limit checks]({{ '/en/architecture/' | relative_url }}#limits)
* Object emulation for testing without field hardware
* [Historical archives]({{ '/en/dev/history/' | relative_url }})
  (the `scada-historian` process) with automatic removal of expired data
* [Event journal]({{ '/en/client/events/' | relative_url }}) with
  acknowledgement and importance-based highlighting
* [Redundancy]({{ '/en/architecture/' | relative_url }}#data-items) support for information objects
* Role-based access control through
  [user administration]({{ '/en/dev/users/' | relative_url }})
* Online engineering from any workstation, including
  [configuration export and import]({{ '/en/dev/excel/' | relative_url }})
* [Device watch]({{ '/en/client/device-watch/' | relative_url }}) and
  [device metrics]({{ '/en/client/device-metrics/' | relative_url }})
* [CSV]({{ '/en/client/export/' | relative_url }}) and
  [Excel]({{ '/en/client/export/' | relative_url }}#excel) export,
  [printing]({{ '/en/client/print/' | relative_url }}) of tables,
  summaries, the Data and Device watch windows and the event journal, and
  [graph printing and saving as an image]({{ '/en/client/graph/' | relative_url }}#print-export)
