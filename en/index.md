---
title: Overview
nav_order: 1
permalink: /en/
---

# Overview

{: .note }
> **Today only a 2.5.7 Server can be bought and installed; for version 2.6
> the Client is published, and the version 2.6 Server is not published yet**
> ([Buying now]({{ '/en/getting-started/' | relative_url }}#buy-now)).
>
> * This manual describes version 2.6, published as releases
>   [2.6.0, 2.6.3 and 2.6.4]({{ '/en/changes/' | relative_url }}#v2-6). Only Client packages
>   have been published for it so far: the Windows Server installer and the
>   Linux Server packages will be added later
>   ([Download]({{ '/en/getting-started/' | relative_url }}#download)).
> * So the 2.6 Client can today connect only to a 2.5.7 Server — from release
>   2.6.3 on, and without every version 2.6 capability; the 2.6 Client has not
>   yet been tried against a working 2.5.7 Server
>   ([Before upgrading from 2.5.7]({{ '/en/changes/' | relative_url }}#limits-upgrade)).
> * The previous release, [2.5.7]({{ '/en/changes/' | relative_url }}#v2-5-7), is built
>   differently: its Server is a single service with a HASP or Guardant
>   hardware key, not a set of separate processes.
> * The version 2.6 license is issued for a term: after it expires the Server
>   processes refuse requests ([Licensing]({{ '/en/server/licensing/' | relative_url }})).
> * Before buying or upgrading, read the version 2.6
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
set of separate processes: protocol processes (MODBUS, IEC 60870-5-104, IEC 61850
and others), the archive, the configuration, the file store, and a proxy
that Clients connect to. The processes are purchased separately and the
license lists the ones purchased; that is how the 2.6 Server will be sold once
its installer is published, while today a 2.5.7 Server is bought (see
[Buying now]({{ '/en/getting-started/' | relative_url }}#buy-now)). A protocol process on its own is not
enough, even on a small site: the smallest set is `scada-config`, one or more protocol
processes, `scada-filesystem` and `scada-proxy`, and the archive of values
and events — and so any report or summary over the archive — also needs
`scada-historian`. See
[Choose the Server processes]({{ '/en/getting-started/' | relative_url }}#choose)
and [Server processes]({{ '/en/architecture/' | relative_url }}#tiers).
Any number of Clients can connect over TCP/IP. When the connection is
lost — including after the Server is restarted or stopped — the Client
reconnects by itself (see
[Connection to the Server]({{ '/en/client/' | relative_url }}#connection)).

For operation, the system requires one computer for a single-machine
deployment or multiple computers for a distributed deployment. The Server
processes run on Windows 10 or newer and on x86-64 Linux (`.deb` and
`.tar.gz` packages, systemd services; see
[Installation on Linux]({{ '/en/getting-started/' | relative_url }}#linux));
the version 2.6 Server installer and packages are not published yet.
The Client runs on Windows 10 or newer and on macOS 26 or newer on computers with Apple
silicon (see
[Client installation]({{ '/en/getting-started/' | relative_url }}#client-install)).
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
  [Buying now]({{ '/en/getting-started/' | relative_url }}#buy-now). Terms and
  prices, keys and licences: Telecontrol, mail@telecontrol.ru.
* **Administrator**, who installs and maintains the Server: today, a 2.5.7
  Server ([Buying now]({{ '/en/getting-started/' | relative_url }}#buy-now)); for version 2.6,
  once its Server is published,
  [Download]({{ '/en/getting-started/' | relative_url }}#download) and
  [Choose the Server processes]({{ '/en/getting-started/' | relative_url }}#choose), then install
  following [Getting started]({{ '/en/getting-started/' | relative_url }}) (on Linux,
  [Installation on Linux]({{ '/en/getting-started/' | relative_url }}#linux));
  [Setting up with scada-setup]({{ '/en/server/setup/' | relative_url }}),
  [Licensing]({{ '/en/server/licensing/' | relative_url }}),
  [Root password]({{ '/en/server/security/' | relative_url }}#root-password),
  [Backup]({{ '/en/server/backup/' | relative_url }}),
  [Upgrading from version 2.5]({{ '/en/server/upgrade/' | relative_url }}#upgrade-2-5).
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

Example of a distributed deployment:

![]({{ '/img/structure-en.svg' | relative_url }})

## Key features

* Distributed multi-user [Architecture]({{ '/en/architecture/' | relative_url }}), with the Server on Windows and Linux (the version 2.6 Server is not published yet) and the Client on Windows and macOS
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
  (Windows); for the limitations of version 2.6 see
  [Known limitations]({{ '/en/changes/' | relative_url }}#limits-protocols)
* [Retransmission]({{ '/en/dev/devices/' | relative_url }}#retransmission)
  of selected data to upper-level systems and an OPC UA server; for the
  limitations of version 2.6 see
  [Known limitations]({{ '/en/changes/' | relative_url }}#limits-protocols)
* [Vidicon integration]({{ '/en/protocols/' | relative_url }}#vidicon)
  (Windows) for migrating existing projects
* [Formulas]({{ '/en/formulas/' | relative_url }}),
  [manual input]({{ '/en/architecture/' | relative_url }}#manual-write),
  and [limit checks]({{ '/en/architecture/' | relative_url }}#limits)
* Object emulation for testing without field hardware
* [Historical archives]({{ '/en/server/data/' | relative_url }}#history)
  (the `scada-historian` process) with automatic removal of expired data
  (set up as described under
  [Archiving]({{ '/en/dev/history/' | relative_url }}))
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
