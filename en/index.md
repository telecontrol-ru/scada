---
title: Overview
nav_order: 1
permalink: /en/
---

# Overview

Telecontrol SCADA is supervisory control and data acquisition software
for collecting field data, presenting it to operators, issuing control
commands, archiving telemetry, and displaying historical information.

The system uses a client-server architecture with a central Server. Any
number of Clients can connect over TCP/IP, and client sessions remain
resilient while the Server stays online.

For operation, the system requires one computer for a single-machine
deployment or multiple computers for a distributed deployment, with
Windows 10 or newer on operator workstations. For real-time diagram
display and binding to telemetry data, the
[ActiveXeme](http://swman.ru/content/blogcategory/21/49/) component is
required. The
[Modus graphical editor](http://swman.ru/content/blogcategory/19/47/) is
used to edit diagrams.

All schematics are stored as vector graphics, so even large process
diagrams remain compact and can be displayed at large scale on shared
operator panels without loss of image quality.

The platform supports one or more operator workstations depending on the
required user roles and access rights for the monitored automation
system.

Example of a distributed deployment:

![]({{ '/img/structure.png' | relative_url }})

## Key features

* Distributed multi-user [Architecture]({{ '/en/architecture/' | relative_url }}) with Windows and Linux server support
* Data display on [electronic schematics]({{ '/en/client/display/' | relative_url }}) through ActiveXeme
* Interactive [tables]({{ '/en/client/table/' | relative_url }}),
  [graphs]({{ '/en/client/graph/' | relative_url }}), and
  [summaries]({{ '/en/client/summary/' | relative_url }}) with archive
  aggregation
* [User tables]({{ '/en/client/sheet/' | relative_url }}) with formulas
  and conditional formatting
* Telemetry acquisition and control over
  [MODBUS]({{ '/en/protocols/' | relative_url }}#modbus),
  [IEC 60870-5]({{ '/en/protocols/' | relative_url }}#iec-60870), and
  [IEC 61850]({{ '/en/protocols/' | relative_url }}#iec-61850)
* Retransmission of selected data to upper-level systems and an OPC UA
  server
* [Formulas]({{ '/en/formulas/' | relative_url }}),
  [manual input]({{ '/en/architecture/' | relative_url }}#manual-input),
  and [limit checks]({{ '/en/architecture/' | relative_url }}#limit-checks)
* Object emulation for testing without field hardware
* [Historical archives]({{ '/en/server/' | relative_url }}#history)
  with automatic database maintenance
* [Event journal]({{ '/en/client/events/' | relative_url }}) with
  acknowledgement and importance-based highlighting
* Redundancy support for information objects
* Role-based access control through
  [user administration]({{ '/en/dev/users/' | relative_url }})
* Online engineering from any workstation, including
  [Excel-based configuration editing]({{ '/en/dev/excel/' | relative_url }})
* [Device watch]({{ '/en/client/device-watch/' | relative_url }}) and
  [device metrics]({{ '/en/client/device-metrics/' | relative_url }})
* [CSV export]({{ '/en/client/export/' | relative_url }}) and
  [printing]({{ '/en/client/print/' | relative_url }}) of tables and
  graphs
* [Web access]({{ '/en/client/web/' | relative_url }}) through a browser
