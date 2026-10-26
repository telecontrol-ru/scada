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

1. The `scada-setup` program: `apply` creates the parameter files, configuration databases and services of the processes and starts them; `status`, `start`, `stop` and `remove` manage the services; `migrate` moves the data of a version 2.5 Server. `scada-setup` runs on Windows; installing the Server on Linux is available on request in this version. See [Setting up with scada-setup]({{ '/en/server/' | relative_url }}#scada-setup).

1. One package, `telecontrol-scada-<version>.msi`, carries every Server process, `scada-setup` and the Client; the operator workstations get the same package, without `scada-setup`. See [Installing the Client]({{ '/en/getting-started/' | relative_url }}#client-install).

1. The license is a signed `license.json` file listing the purchased processes, instead of a HASP or Guardant hardware key. A process not named in the license does not run. See [Licensing]({{ '/en/server/' | relative_url }}#licensing).

1. `scada-setup apply` creates the [OPC UA Server certificate]({{ '/en/server/' | relative_url }}#opcua-certificate) if there is none yet.

1. The password of the built-in `root` account is set with the `--root-password` option of `scada-setup apply`, and is required on a computer running `scada-config`, `scada-proxy`, `scada-historian` or `scada-filesystem`. See [Root password]({{ '/en/server/' | relative_url }}#root-password).

1. New data folders: each process has its own folder `%ProgramData%\Telecontrol\SCADA Server\<process>` with its `server.json` parameter file (the folder of `scada-filesystem` is `filestore`). The license is `%ProgramData%\Telecontrol\SCADA Server\license.json`.

1. Upgrading from version 2.5 is done with `scada-setup migrate`: it copies the configuration, users with their passwords, the archives and the display files, and leaves the version 2.5 folders unchanged. See [Upgrading from version 2.5]({{ '/en/server/' | relative_url }}#upgrade-2-5).

1. The configuration of a new installation is a demo project (objects with emulation, IEC 60870-5-104 links, archives, the users «Клиент 1» … «Клиент 10» and `guest`). Before going live, replace it with the project's configuration or delete the demo data. See [Preparing the project]({{ '/en/getting-started/' | relative_url }}#project).

### Client

1. The main window is a workbench with the [section rail]({{ '/en/client/workbench/' | relative_url }}#activity-bar) on the left and the [Inspector]({{ '/en/client/workbench/' | relative_url }}#inspector) panel on the right, which shows the selected object or event. See [Operator workbench]({{ '/en/client/workbench/' | relative_url }}).

1. The user profile (pages, window layout, portfolios, settings) is saved on this computer; in addition, when the Client closes it also saves the profile on the Server, in the account's profile, at every access level. Do not count on pages and portfolios appearing by themselves in the Client on another computer. See [Where portfolios are kept]({{ '/en/client/portfolio/' | relative_url }}#storage).

1. *Acknowledge All* in the [Event journal]({{ '/en/client/events/' | relative_url }}) acknowledges only the events shown: events hidden by a zone, severity or object filter stay unacknowledged.

1. The common *Acknowledge All* command, which acknowledges every event in the system, is now in the *More* menu and runs — from there and from the command palette — only after a confirmation stating how many events it acknowledges. See [Common commands]({{ '/en/client/' | relative_url }}#common-commands).

1. The sign-in window opened by *Disconnect from Server* and *Connect to Server...* always waits for input — automatic sign-in happens only when the Client starts. It can now be bypassed on macOS too (with the *Option* key), and with *Cancel* while the sign-in is in progress. See [Automatic sign-in]({{ '/en/client/' | relative_url }}#auto-login).

1. When the Server refuses an acknowledgement (for example, for lack of rights), the event panel shows an error message and the acknowledgement can be retried.

1. With the *Control Success Message* setting on, the Client reports a successful [control]({{ '/en/client/' | relative_url }}#control-result) or [manual input]({{ '/en/client/' | relative_url }}#manual-input) command.

1. In the [event panel]({{ '/en/client/' | relative_url }}#events-panel), *Severity — All* removes the threshold that was set, and the panel loads every event again.

1. Fixed: reopening the *Period* dialog with the *Time* box cleared no longer moves the end of the period a day later. See [A report for last month]({{ '/en/client/reports/' | relative_url }}#last-month).

1. The [graph legend]({{ '/en/client/graph/' | relative_url }}#legend) shows each line's current value, minimum, maximum and average over the visible range, with the value at the cursor in its own `@ cursor` column.

1. The [Table]({{ '/en/client/table/' | relative_url }}) window has new `Quality`, `Trend` and `Source` columns; columns can be hidden from the header context menu.

1. The [CSV export]({{ '/en/client/export/' | relative_url }}) dialog has an *Expand grouped rows* option for the event journal.

1. Fixed: CSV export honours the chosen encoding. On Windows, *System* writes the file in the Windows code page and *Unicode (UTF-8)* writes UTF-8 with a byte-order mark, so Microsoft Excel opens the file by double-clicking it without garbling Russian text. See [Export to CSV]({{ '/en/client/export/' | relative_url }}).

1. Configuration export and import (*More — Export Configuration...* and *Import Configuration...*) use the OPC UA NodeSet (XML) format instead of version 2.5.7's CSV table. CSV files exported by version 2.5 cannot be imported: a version 2.5 Server's configuration is moved over by `scada-setup migrate`. See [Configuration export and import]({{ '/en/dev/excel/' | relative_url }}) and [Upgrading from version 2.5]({{ '/en/server/' | relative_url }}#upgrade-2-5).

1. Event severity is a number from 1 to 1000 instead of the former scale up to 100: *Critical* is 800 and above, *Warning* from 600. Severity set in object properties and the severity of archived events are recalculated once (multiplied by 10), as is the minimum severity saved in the profile. See [Severity]({{ '/en/client/events/' | relative_url }}#severity).

1. The [Event journal]({{ '/en/client/events/' | relative_url }}) has a filter bar above the journal (*Period*, *Min. severity*, *Unacknowledged only*) and an area list on the left with each area's count of unacknowledged events. See [Period]({{ '/en/client/events/' | relative_url }}#period) and [Filters]({{ '/en/client/events/' | relative_url }}#filters).

1. The *Audit log* window shows who did what to user accounts, passwords and roles; it is available to administrators only. See [Audit log]({{ '/en/client/workbench/' | relative_url }}#audit-log).

1. Modus displays are drawn by the Client's own display module, without the ActiveXeme component. Shapes bound with the `ключ_привязки` property show the present switch positions and measured values, and a click on such a shape selects its object; the **Display** menu lists a schematic by its title. Bindings of other properties, limits and blinking on an alarm are not shown — see [Live values on a Modus schematic]({{ '/en/client/display/' | relative_url }}#live-values).

1. The [Device watch]({{ '/en/client/device-watch/' | relative_url }}) window has a `Frame trace` mode — protocol traffic only, with a decode pane for the selected frame — and a filter line above the table that works in both modes and also applies to `Save as`.

1. The `Multiple Create…` command opens a wizard that creates several data objects at once from one name and address pattern. See [Bulk create]({{ '/en/dev/data-items/' | relative_url }}#bulk-create).

1. The Client interface is available in English, and the appearance is chosen from the *Colour scheme* list — see [Settings]({{ '/en/client/workbench/' | relative_url }}#settings) and [Appearance]({{ '/en/client/workbench/' | relative_url }}#appearance).

### Known limitations {#known-limitations}

Read this list before buying and before upgrading: each limitation is described in detail on the page it links to.

#### Before upgrading from 2.5.7 {#limits-upgrade}

1. On Modus displays the 2.6 Client shows switch positions and values bound through the *положение*, *текст* and *значение_базовое* properties but, unlike 2.5.7, does not show bindings of other shape properties, limits, or a shape blinking on an alarm. If a site's displays rely on these, check the displays before upgrading. See [Live values on a Modus schematic]({{ '/en/client/display/' | relative_url }}#live-values).

1. The display module is a separate library that may not be included in the Client installation; without it a display window shows "No display runtime is installed." See [When a schematic is not shown]({{ '/en/client/display/' | relative_url }}#not-shown).

1. A version 2.5 Client working with a 2.6 Server has not been tested: install the 2.6 Client on every workstation. See [Upgrading from version 2.5]({{ '/en/getting-started/' | relative_url }}#upgrade-2-5).

#### Protocols and retransmission {#limits-protocols}

1. IEC 61850: analogue setpoints (class APC) and step control (class BSC) are not supported. See [IEC 61850]({{ '/en/protocols/' | relative_url }}#iec-61850).

1. MODBUS: writing is reliable only for coils and for whole unsigned 16-bit registers. See [MODBUS register addressing]({{ '/en/dev/devices/' | relative_url }}#modbus-registers).

1. MODBUS: by default the first of two registers is taken as the low word, and DOUBLE values in the standard word order cannot be read. See [MODBUS register addressing]({{ '/en/dev/devices/' | relative_url }}#modbus-registers).

1. MODBUS ASCII is not implemented. See [MODBUS]({{ '/en/protocols/' | relative_url }}#modbus).

1. IEC 60870-5: ASDU type 7 (32-bit string) is not supported, and normalized values are not scaled to −1…+1. See [IEC 60870-5]({{ '/en/protocols/' | relative_url }}#iec-60870).

1. The *Protocol* and *Mode* lists of a link (and other fields with a list of values) can be empty — the default value then applies. See [Fields with a list of values]({{ '/en/dev/devices/' | relative_url }}#enum-lists).

1. Retransmission: every new rule gets address 1, retransmitting objects of another Server process is not confirmed, and MODBUS retransmission needs a mode the list may not offer. See [Retransmission to a dispatch centre]({{ '/en/dev/devices/' | relative_url }}#retransmission).

#### Archive and reports {#limits-archive}

1. On a new installation archiving cannot be set up from the Client: creating an archive and assigning one to an object are rejected by the Server. Objects that already have an archive assigned (for example, ones migrated from version 2.5) are archived. See [Archiving]({{ '/en/dev/history/' | relative_url }}).

1. After the service of a protocol process is restarted, archiving of its objects' values stops until the *Telecontrol SCADA Historian* service is restarted. See [Where the data comes from]({{ '/en/client/reports/' | relative_url }}#archive).

1. In a summary, *Maximum* over negative values shows about 0, and *Sum* and *Average* are computed over recorded changes, not over time — a summary gives neither energy nor a time-weighted average. See [Aggregation function]({{ '/en/client/summary/' | relative_url }}#function).

1. Graphs cannot be printed or exported. See [Printing and export of a graph]({{ '/en/client/graph/' | relative_url }}#print-export).

1. *Export to Excel* works only on Windows with Microsoft Excel, and only when the Client was started with `--excel`. See [Export to Excel]({{ '/en/client/export/' | relative_url }}#excel).

#### Installation and security {#limits-setup}

1. The license is issued for a term; after it expires the Server processes refuse requests. See [Licensing]({{ '/en/server/' | relative_url }}#licensing).

1. `scada-setup` has not yet been tried on a site under Windows. If the result of any command differs from the description, report that to Telecontrol. See [Setting up with scada-setup]({{ '/en/server/' | relative_url }}#scada-setup).

1. Installing the Server on Linux is available on request: there is no Linux package. See [Installation on Linux]({{ '/en/getting-started/' | relative_url }}#linux).

1. Each protocol process can run on one computer of the site only, and serves every device of its protocol. See [Choose the Server processes]({{ '/en/getting-started/' | relative_url }}#choose).

1. The configuration of a new installation is a demo project with password-less users and enabled IEC 60870-5-104 links; replace it before going live. See [Preparing the project]({{ '/en/getting-started/' | relative_url }}#project).

1. The OPC UA ports 4840–4848, over which the processes exchange data, are protected only by the firewall. See [OPC UA server]({{ '/en/server/' | relative_url }}#opcua).

1. The password of the `svc` service account cannot be changed after installation. See [The svc account]({{ '/en/server/' | relative_url }}#svc).

1. The `svc` and `root` passwords given to `scada-setup apply` are stored in plain text in the Windows service settings in the registry. See [Passwords are stored in plain text]({{ '/en/server/' | relative_url }}#stored-passwords).

1. `scada-setup apply` does not restart services that are running: a new `root` password and other options take effect only after a restart. See [Re-running apply]({{ '/en/server/' | relative_url }}#reapply).

#### Working with the Client {#limits-client}

1. After *Disconnect from Server* and logging in as another account, the previous operator's pages and settings remain — restart the Client at shift handover. See [Shift handover]({{ '/en/client/' | relative_url }}#shift-change).

1. With "Sign in automatically next time" ticked, the Client logs in as the last account by itself at startup — do not tick it on a shared workstation; to sign in as yourself, hold *Ctrl* (on macOS, *Option*) while starting it. See [Automatic sign-in]({{ '/en/client/' | relative_url }}#auto-login).

## 2.5.7 {#v2-5-7}

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

1. Server: IEC 60870 — fixed execution of telecontrol commands.

## 2.0.53

### New features

1. Server: support for the SQLite format of the configuration database. New configuration databases are created in the SQLite format.

## 2.0.52

### New features

1. Client: [Summary]({{ '/en/client/summary/' | relative_url }}) — the aggregation interval is saved.

### Fixes

1. Client: fixed filling [user table]({{ '/en/client/sheet/' | relative_url }}) cells from the object tree.

1. Client: fixed editing user table cells from the formula bar.

1. Client: fixed setting the cell color in the user table.

1. Client: editing a user table is now available to administrators only.

1. Server: fixed the `Alias!SourceTimeStamp` and `Alias!ServerTimeStamp` fields.
