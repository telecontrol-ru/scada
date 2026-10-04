---
title: Change log
nav_order: 9
permalink: /en/changes/
---

# Change log
{:.no_toc}

* TOC
{:toc}

Distributions are published on the [GitHub releases page](https://github.com/alexsmn/scada-client/releases); release 2.5.7 is available there today. Distributions of earlier versions are not published. The rest of this manual describes version 2.6, which is being prepared for release; how it differs from 2.5.7 is described below.

## 2.6 (being prepared for release) {#v2-6}

This version is not yet published on the releases page.

### Server

1. The Server is split into separate processes: `scada-config` (configuration), `scada-proxy` (Client connections), `scada-historian` (archive), `scada-filesystem` (files), the protocol processes `scada-modbus`, `scada-iec104` and `scada-iec61850`, and `scada-opc` and `scada-vidicon` (Windows only). Each process runs as its own Windows service (*Telecontrol SCADA Config*, *Telecontrol SCADA Proxy*, *Telecontrol SCADA Historian* and so on) instead of the single *Telecontrol SCADA Server* service. The processes are purchased separately. See [Server processes]({{ '/en/architecture/' | relative_url }}#tiers).

1. The `scada-setup` program: `apply` creates the parameter files, configuration databases and services of the processes and starts them; `status`, `start`, `stop` and `remove` manage the services; `migrate` moves the data of a version 2.5 Server. See [Setting up with scada-setup]({{ '/en/server/' | relative_url }}#scada-setup).

1. The license is a signed `license.json` file listing the purchased processes, instead of a HASP or Guardant hardware key. A process not named in the license does not run. See [Licensing]({{ '/en/server/' | relative_url }}#licensing).

1. `scada-setup apply` creates the [OPC UA Server certificate]({{ '/en/server/' | relative_url }}#opcua-certificate) if there is none yet.

1. The password of the built-in `root` account is set with the `--root-password` option of `scada-setup apply`, and is required on a computer running `scada-config`, `scada-proxy`, `scada-historian` or `scada-filesystem`. See [root password]({{ '/en/server/' | relative_url }}#root-password).

1. New data folders: each process has its own folder `%ProgramData%\Telecontrol\SCADA Server\<process>` with its `server.json` parameter file (the folder of `scada-filesystem` is `filestore`). The license is `%ProgramData%\Telecontrol\SCADA Server\license.json`.

1. Upgrading from version 2.5 is done with `scada-setup migrate`: it copies the configuration, users with their passwords, the archives and the display files, and leaves the version 2.5 folders unchanged. See [Upgrading from version 2.5]({{ '/en/server/' | relative_url }}#upgrade-2-5).

### Client

1. The user profile (pages, window layout, portfolios, settings) is saved on the Server for the account when the Client closes, and is available on another workstation. With rights "0" the profile is not saved on the Server — see [Portfolios]({{ '/en/client/portfolio/' | relative_url }}#storage).

### Known limitations

1. Archiving cannot be set up from the Client: creating an archive and assigning one to an object are rejected by the Server. Objects that already have an archive assigned (for example, ones migrated from version 2.5) are archived. See [Archiving]({{ '/en/dev/history/' | relative_url }}).

1. After the service of a protocol process is restarted, archiving of its objects' values stops until the *Telecontrol SCADA Historian* service is restarted.

## 2.5.7

Published on the releases page on 9 February 2026 (installer `telecontrol-scada-2.5.7.msi`). In this release the Server is a single *Telecontrol SCADA Server* service with a HASP or Guardant hardware key, as in version 2.5. No list of changes since 2.5.6 accompanies the release.

## 2.5.6

### Fixes

1. Server: fixed MODBUS reconnection after protocol errors.
1. Server: fixed IEC 60870-5-104 reconnection after protocol errors.

## 2.5.0

### New features

1. Client: reworked the main window.
1. Client: faster startup by initializing services before authorization.

### Fixes

1. Client: fixed controller registration for Favorites and Portfolios.
1. Client: fixed report generation during configuration export.

## 2.4.8

### New features

1. Client: added arbitrary time ranges in the Data window.
1. Client: improved configuration export and import with object reordering and report generation.

### Fixes

1. Client: fixed event-count updates in the status bar.
1. Client: fixed toolbar and status-bar visibility.
1. Client: fixed the response-time panel in the status bar.

## 2.4.4

### New features

1. Client: added arbitrary time ranges in the [Device watch]({{ '/en/client/device-watch/' | relative_url }}) window.
1. Client: added topology support for Modus displays.
1. Client: added the protocol-exchange [Debugger]({{ '/en/client/debugger/' | relative_url }}).

### Fixes

1. Client: fixed locale detection for interface translation.
1. Client: fixed configuration import.

## 2.4.0

### New features

1. Server: added optional archiving of device logs. Logs visible in the [Device watch]({{ '/en/client/device-watch/' | relative_url }}) window can now be stored in the historical database when the device `Event archive` parameter is enabled.

## 2.3.0

### New features

1. Client: integrated Telecontrol Vidicon displays, including click handling, context menus, tooltips, and navigation.
1. Client: added the Vidicon manual-value entry dialog.
1. Client: added the protocol-session [Debugger]({{ '/en/client/debugger/' | relative_url }}).
1. Client: added support for writing to arbitrary variables.

### Fixes

1. Client: fixed subscriptions in the [Device watch]({{ '/en/client/device-watch/' | relative_url }}) window.

## 2.2.0

### New features

1. Server: added the [server-side file system]({{ '/en/server/' | relative_url }}#filesystem). It is enabled automatically on new installations and can be enabled on existing installations with `filesystem.enabled=true` in `server.json`. *This applies to versions 2.2–2.5, where the Server ran as one service; in version 2.6 the file system is served by the separate `scada-filesystem` process — see [Server processes]({{ '/en/architecture/' | relative_url }}#tiers).*
1. Client: added the server file-system panel under `Further -> Files`. *That was the menu in version 2.2; in the current Client files open with the "Files" mode on the [section rail]({{ '/en/client/workbench/' | relative_url }}#activity-bar).*
1. Client: added drag-and-drop in the configuration tree.
1. Client: added retransmission support for all device types.
1. Client: added the [Device metrics]({{ '/en/client/device-metrics/' | relative_url }}) panel for all device types, including MODBUS.
1. Client: added navigation from a selected data range to the [Summary]({{ '/en/client/summary/' | relative_url }}) view.
1. Server: added file-system support for file creation, deletion, and rename operations.
1. Server: added OPC UA MethodService support.

### Fixes

1. Client: fixed cursor-legend values in the [Graph]({{ '/en/client/graph/' | relative_url }}).
1. Client: fixed time fitting in the graph.
1. Client: fixed copy and paste of objects.
1. Client: fixed Russian characters in Modus bindings.
1. Client: fixed equipment-tree icons after reopening.
1. Server: fixed writing of zero values for limit properties.
1. Server: fixed SQLite configuration-database updates.

## 2.1.8

### Fixes

1. Server: fixed the message `x minutes remaining until server shutdown` when the USB key is removed.
1. Client: fixed duplicate devices in [Device metrics]({{ '/en/client/device-metrics/' | relative_url }}).
1. Client: fixed colors in [User tables]({{ '/en/client/sheet/' | relative_url }}).

## 2.1.7

### Fixes

1. Server: fixed creation of root objects such as device directions.
1. Server: fixed startup of MODBUS device polling.
1. Client: restored panel sizes after client restart.
1. Client: fixed context-navigation commands in [Summary]({{ '/en/client/summary/' | relative_url }}).
1. Client: restored the aggregation function in the Summary window after client restart.
1. Client: fixed encoding in the [Data]({{ '/en/client/data/' | relative_url }}) window title.

## 2.1.3

### Fixes

1. Server: fixed aliases in discrete and measured object expressions.
1. Client: fixed an error when creating an object after deleting another object of the same type.
1. Client: fixed event-panel errors during object copy.
1. Client: fixed inability to change the MODBUS device address.

## 2.1.1

### New features

1. Server: added the ability to override the ASDU type for IEC 60870 control commands. See the [Protocols]({{ '/en/protocols/' | relative_url }}#iec-60870) reference.
1. Server: added support for extended IEC 60870-5-104 functions for receiving and writing schedule corrections for Telecontrol SE7 devices.

### Fixes

1. Server: fixed metrics for historical archives.
1. Server: improved safe shutdown behavior after the demo period expires without a license.

### Removed features

1. Removed support for WebSocket connections.

## 2.1.0

This release removed obsolete functionality.

### New features

1. Added the ability to bind a device to object groups and show its communication state next to the group in the object tree.
1. Improved bulk acknowledgement of many events at once.
1. Server: added periodic system events when the license is missing.
1. Server: added detection of IEC 60870-5-104 protocol errors while preserving the connection when possible.
1. Client: added color highlighting of important events and errors in the [Device watch]({{ '/en/client/device-watch/' | relative_url }}) window.

### Removed features

1. Removed support for the GigaBASE (`configuration.gb`) configuration database format. See the [migration]({{ '/en/server/' | relative_url }}#migration) instructions.
1. Removed GigaBASE support for historical databases. SQLite has been used for history for the last five years.

## 2.0.60

### New features

1. Server: for IEC 60870-5-104, recoverable protocol errors are now handled without dropping the connection.

## 2.0.59

### Fixes

1. Server: for IEC 60870-5-104 in UDP server mode, fixed support for devices that send datagrams composed of multiple IEC messages.

## 2.0.58

### New features

1. Server: added UDP support for [IEC 60870-5]({{ '/en/protocols/' | relative_url }}#iec-60870) directions. One UDP server direction can work with multiple remote devices identified by IP address and port.

### Fixes

1. Client: fixed channel editing in the element table.
1. Client: bound the `Ctrl+C`, `Ctrl+V`, `F2`, and `Delete` shortcuts.

## 2.0.57

### New features

1. Server: added a Linux build of the Server.

## 2.0.55

### Fixes

1. Client: fixed configuration [export and import]({{ '/en/client/export/' | relative_url }}) issues.

## Translation status

This English page is now a functional release-history page. The Russian
page still remains the fuller canonical record.
