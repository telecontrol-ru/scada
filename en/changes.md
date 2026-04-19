---
title: Change log
nav_order: 9
permalink: /en/changes/
---

# Change log
{:.no_toc}

* TOC
{:toc}

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

[Windows installer](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-2.4.0.msi)

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

[Windows installer](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-2.2.0.msi)

### New features

1. Server: added the [server-side file system]({{ '/en/server/' | relative_url }}#filesystem). It is enabled automatically on new installations and can be enabled on existing installations with `filesystem.enabled=true` in `server.json`.
1. Client: added the server file-system panel under `Further -> Files`.
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

[Windows installer](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-2.1.8.msi)

### Fixes

1. Server: fixed the message `x minutes remaining until server shutdown` when the USB key is removed.
1. Client: fixed duplicate devices in [Device metrics]({{ '/en/client/device-metrics/' | relative_url }}).
1. Client: fixed colors in [User tables]({{ '/en/client/sheet/' | relative_url }}).

## 2.1.7

[Windows installer](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-2.1.7.msi)

### Fixes

1. Server: fixed creation of root objects such as device directions.
1. Server: fixed startup of MODBUS device polling.
1. Client: restored panel sizes after client restart.
1. Client: fixed context-navigation commands in [Summary]({{ '/en/client/summary/' | relative_url }}).
1. Client: restored the aggregation function in the Summary window after client restart.
1. Client: fixed encoding in the [Data]({{ '/en/client/data/' | relative_url }}) window title.

## 2.1.3

[Windows installer](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-2.1.3.msi)

### Fixes

1. Server: fixed aliases in discrete and measured object expressions.
1. Client: fixed an error when creating an object after deleting another object of the same type.
1. Client: fixed event-panel errors during object copy.
1. Client: fixed inability to change the MODBUS device address.

## 2.1.1

[Windows installer](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-2.1.1.msi)

### New features

1. Server: added the ability to override the ASDU type for IEC 60870 control commands. See the [Protocols]({{ '/en/protocols/' | relative_url }}#iec-60870) reference.
1. Server: added support for extended IEC 60870-5-104 functions for receiving and writing schedule corrections for Telecontrol SE7 devices.

### Fixes

1. Server: fixed metrics for historical archives.
1. Server: improved safe shutdown behavior after the demo period expires without a license.

### Removed features

1. Removed support for WebSocket connections.

## 2.1.0

[Windows installer](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-2.1.0.msi)

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

[Windows installer](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-2.0.59.msi)

### Fixes

1. Server: for IEC 60870-5-104 in UDP server mode, fixed support for devices that send datagrams composed of multiple IEC messages.

## 2.0.58

[Windows installer](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-2.0.58.msi)

### New features

1. Server: added UDP support for [IEC 60870-5]({{ '/en/protocols/' | relative_url }}#iec-60870) directions. One UDP server direction can work with multiple remote devices identified by IP address and port.

### Fixes

1. Client: fixed channel editing in the element table.
1. Client: bound the `Ctrl+C`, `Ctrl+V`, `F2`, and `Delete` shortcuts.

## 2.0.57

[Windows installer](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-2.0.57.msi)

[Linux installer](https://telecontrol-public.s3-us-west-2.amazonaws.com/telecontrol-scada/telecontrol-scada-2.0.57.tar.gz)

### New features

1. Server: added a Linux build of the Server.

## 2.0.55

### Fixes

1. Client: fixed configuration [export and import]({{ '/en/client/export/' | relative_url }}) issues.

## Translation status

This English page is now a functional release-history page. The Russian
page still remains the fuller canonical record.
