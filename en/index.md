---
title: Overview
nav_order: 1
permalink: /en/
---

# Overview

{: .note }
> **Version 2.6.** This manual describes version 2.6, which is being prepared
> for release. The published release is
> [2.5.7]({{ '/en/changes/' | relative_url }}#v2-5-7), and it is built
> differently: its Server is a single service with a HASP or Guardant
> hardware key, not a set of separate processes. The version 2.6 license is
> issued for a term: after it expires the Server processes refuse requests
> ([Licensing]({{ '/en/server/' | relative_url }}#licensing)). Before buying
> or upgrading, read the version 2.6
> [Known limitations]({{ '/en/changes/' | relative_url }}#known-limitations)
> — in particular, the display module may not be included in the Client
> installation, and on a new
> installation archives cannot be assigned to objects from the Client.

Telecontrol SCADA is supervisory control and data acquisition software
for collecting field data, presenting it to operators, issuing control
commands, archiving telemetry, and displaying historical information.

The system uses a client-server architecture. The Server is a set of
separate processes: protocol processes (MODBUS, IEC 60870-5-104, IEC 61850
and others), the archive, the configuration, the file store, and a proxy
that Clients connect to. The processes are purchased separately and the
license lists the ones purchased. A protocol process on its own is not
enough, even on a small site: the smallest set is `scada-config`, one or more protocol
processes, `scada-filesystem` and `scada-proxy`, and the archive of values
and events — and so any report or summary over the archive — also needs
`scada-historian`. See
[Choose the Server processes]({{ '/en/getting-started/' | relative_url }}#choose)
and [Server processes]({{ '/en/architecture/' | relative_url }}#tiers).
Any number of Clients can connect over TCP/IP, and client sessions remain
resilient while the Server stays online.

For operation, the system requires one computer for a single-machine
deployment or multiple computers for a distributed deployment. The Server
processes run on Windows 10 or newer; installing the Server on Linux is
available on request (see
[Installation on Linux]({{ '/en/getting-started/' | relative_url }}#linux)).
The Client runs on Windows 10 or newer. The Client displays Modus diagrams with
its own display module, without the ActiveXeme component. The
[Modus graphical editor](http://swman.ru/content/blogcategory/19/47/) is
used to edit diagrams.

Installation is described in
[Getting started]({{ '/en/getting-started/' | relative_url }}), and what
changed between versions in the
[Change log]({{ '/en/changes/' | relative_url }}).

All schematics are stored as vector graphics, so even large process
diagrams remain compact and can be displayed at large scale on shared
operator panels without loss of image quality.

The platform supports one or more operator workstations depending on the
required user roles and access rights for the monitored automation
system.

Example of a distributed deployment:

![]({{ '/img/structure.png' | relative_url }})

## Key features

* Distributed multi-user [Architecture]({{ '/en/architecture/' | relative_url }}), with the Server on Windows (on Linux on request)
* Modus [displays]({{ '/en/client/display/' | relative_url }}) with live
  switch positions and values; for the limitations of version 2.6 see
  [Known limitations]({{ '/en/changes/' | relative_url }}#limits-upgrade)
* Interactive [tables]({{ '/en/client/table/' | relative_url }}),
  [graphs]({{ '/en/client/graph/' | relative_url }}), and
  [summaries]({{ '/en/client/summary/' | relative_url }}) with archive
  aggregation
* [User tables]({{ '/en/client/sheet/' | relative_url }}) with formulas
* Telemetry acquisition and control over
  [MODBUS]({{ '/en/protocols/' | relative_url }}#modbus),
  [IEC 60870-5]({{ '/en/protocols/' | relative_url }}#iec-60870), and
  [IEC 61850]({{ '/en/protocols/' | relative_url }}#iec-61850); for the
  limitations of version 2.6 see
  [Known limitations]({{ '/en/changes/' | relative_url }}#limits-protocols)
* [Retransmission]({{ '/en/dev/devices/' | relative_url }}#retransmission)
  of selected data to upper-level systems and an OPC UA server; for the
  limitations of version 2.6 see
  [Known limitations]({{ '/en/changes/' | relative_url }}#limits-protocols)
* [Formulas]({{ '/en/formulas/' | relative_url }}),
  [manual input]({{ '/en/architecture/' | relative_url }}#manual-write),
  and [limit checks]({{ '/en/architecture/' | relative_url }}#limits)
* Object emulation for testing without field hardware
* [Historical archives]({{ '/en/server/' | relative_url }}#history)
  (the `scada-historian` process) with automatic removal of expired data;
  the limitations of version 2.6 are described under
  [Archiving]({{ '/en/dev/history/' | relative_url }})
* [Event journal]({{ '/en/client/events/' | relative_url }}) with
  acknowledgement and importance-based highlighting
* Redundancy support for information objects
* Role-based access control through
  [user administration]({{ '/en/dev/users/' | relative_url }})
* Online engineering from any workstation, including
  [configuration export and import]({{ '/en/dev/excel/' | relative_url }})
* [Device watch]({{ '/en/client/device-watch/' | relative_url }}) and
  [device metrics]({{ '/en/client/device-metrics/' | relative_url }})
* [CSV export]({{ '/en/client/export/' | relative_url }}) and
  [printing]({{ '/en/client/print/' | relative_url }}) of tables,
  summaries, the Data window and the event journal
