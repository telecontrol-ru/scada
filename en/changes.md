---
title: Change log
nav_order: 9
permalink: /en/changes/
---

# Change log
{:.no_toc}

* TOC
{:toc}

Distributions are published on the [GitHub releases page](https://github.com/alexsmn/scada-client/releases); releases 2.6.0 and 2.5.7 are available there today. Distributions of earlier versions are not published. The rest of this manual describes version 2.6; how it differs from 2.5.7 is described below.

## 2.6.0 {#v2-6}

Published on the releases page on 7 November 2026 with the Client packages for Windows and macOS. The Windows Server installer `telecontrol-scada-2.6.0.msi` and the Linux Server packages (`.deb` and `.tar.gz`) are not attached to it yet (see [Download]({{ '/en/getting-started/' | relative_url }}#download)).

The Client packages on the releases page were built on 2 November 2026, before some of the changes listed below: the readable message when the Server refuses two-stage control, the hatching of unreliable shapes on Vidicon schematics, and the improved drawing of Modus shapes. These changes arrive with the next build of the Client and the display module.

### Server

1. The Server is split into separate processes: `scada-config` (configuration), `scada-proxy` (Client connections), `scada-historian` (archive), `scada-filesystem` (files), the protocol processes `scada-modbus`, `scada-iec104` and `scada-iec61850`, and `scada-opc` and `scada-vidicon` (Windows only). Each process runs as its own Windows service (*Telecontrol SCADA Config*, *Telecontrol SCADA Proxy*, *Telecontrol SCADA Historian* and so on) instead of the single *Telecontrol SCADA Server* service. The processes are purchased separately. See [Server processes]({{ '/en/architecture/' | relative_url }}#tiers).

1. The `scada-setup` program: `apply` creates the parameter files, configuration databases and services of the processes and starts them; `status`, `start`, `stop` and `remove` manage the services; `migrate` moves the data of a version 2.5 Server. `scada-setup` runs on Windows (Windows services) and Linux (systemd services). See [Setting up with scada-setup]({{ '/en/server/' | relative_url }}#scada-setup).

1. The Windows Server installer, `telecontrol-scada-<version>.msi`, is meant as one package carrying every Server process, `scada-setup` and the Windows Client; it is not attached to release 2.6.0 yet. In addition, the releases page carries Client packages: an archive for Windows (`Telecontrol-SCADA-Client-<version>-windows-x64.zip`) and a disk image for macOS 26 or later on Apple silicon (`Telecontrol-SCADA-Client-<version>-macos-arm64.dmg`). See [Installing the Client]({{ '/en/getting-started/' | relative_url }}#client-install).

1. The license is a signed `license.json` file listing the purchased processes, instead of a HASP or Guardant hardware key. A process not named in the license does not run. The license is bound to no computer and needs no setting, except one issued for a Google Cloud virtual machine, which runs only there. `scada-setup status` shows the license id — whom the license was issued to. See [Licensing]({{ '/en/server/' | relative_url }}#licensing).

1. There is no longer an unlicensed demo mode: in version 2.5 a Server without a hardware key ran for two hours in demo mode, whereas in version 2.6 a process the license does not name — including when there is no license file — stops right after it starts. To evaluate the system, request a license from Telecontrol. See [Licensing]({{ '/en/server/' | relative_url }}#licensing).

1. Uninstalling the program removes the process services itself (with `scada-setup remove`) and the Server certificate; the processes' data and the site certificate authority stay. The `SCADA_PURGE_CERTIFICATES=1` parameter (on Linux, `apt purge`) deletes the whole certificate folder, the authority included. See [Uninstalling the Server]({{ '/en/server/' | relative_url }}#uninstall).

1. The same protocol process can be installed on several computers, splitting the devices of its protocol between them: a link's Computer property names the computer that serves it, and the computers that serve only the links assigned to them run `scada-setup apply` with `--assigned-links-only`. A link moves to another computer when that property changes, with no restart. See [Choose the Server processes]({{ '/en/getting-started/' | relative_url }}#choose).

1. Retransmission to a DC of objects whose values another Server process receives — computed and simulated objects, and objects of another protocol's devices: the retransmitting process reads them through `scada-proxy`, and passes the DC's commands on them (select, execute, write, release of selection) through it to the process that receives the object's value. See [Retransmission to a dispatch centre]({{ '/en/dev/devices/' | relative_url }}#retransmission).

1. Each object's value is held by one Server process: device objects by the protocol process serving the device, computed and simulated objects by `scada-config`.

1. The Server processes connect to each other encrypted (Basic256Sha256, Sign & Encrypt), each accepting only computers whose certificate the site's own certificate authority issued: `scada-setup apply` creates the authority on the central computer, and the other computers join with `--central-fingerprint`. `--insecure-links` keeps the earlier unencrypted connections. See [Site certificate authority]({{ '/en/server/' | relative_url }}#opcua-site-ca).

1. `scada-config` accepts a process registration only from a computer whose certificate the site certificate authority issued or which was moved into the trusted certificates folder. See [OPC UA server]({{ '/en/server/' | relative_url }}#opcua).

1. `scada-setup apply` does not join a computer to the site unencrypted: on a computer without `scada-config` that has no certificate from the site certificate authority yet, `apply` without `--central-fingerprint` and without `--insecure-links` fails and changes nothing. See [OPC UA server]({{ '/en/server/' | relative_url }}#opcua).

1. `scada-setup apply` creates the [OPC UA Server certificate]({{ '/en/server/' | relative_url }}#opcua-certificate) if there is none yet.

1. The password of the built-in `root` account is set with the `--root-password` option of `scada-setup apply`, and is required on a computer running `scada-config` or `scada-filesystem`. See [Root password]({{ '/en/server/' | relative_url }}#root-password).

1. `scada-setup start`, like `stop`, acts only on the services installed on this computer: processes named in `--tiers` or in the license that are not installed here are skipped with a message. See [The computer's parameters]({{ '/en/getting-started/' | relative_url }}#host-parameters).

1. The `svc` and `root` passwords are changed with the `scada-setup set-password` command, run on every Server computer starting with the central one. See [Changing the svc password]({{ '/en/server/' | relative_url }}#svc-rotate).

1. The `svc` and `root` passwords are stored in an encrypted file that only the Server's services and the computer's administrators can open, not in plain text in the registry; the first `apply` or `set-password` moves them out of the registry. See [Where the passwords are stored]({{ '/en/server/' | relative_url }}#stored-passwords).

1. The [Control condition]({{ '/en/dev/data-items/' | relative_url }}) is checked by the Server on every command, including one arriving over retransmission or from an OPC UA client, not only by the Client's Control window.

1. New data folders: each process has its own folder `%ProgramData%\Telecontrol\SCADA Server\<process>` with its `server.json` parameter file (the folder of `scada-filesystem` is `filestore`). The license is `%ProgramData%\Telecontrol\SCADA Server\license.json`.

1. The configuration is kept in one copy, by `scada-config`: `scada-proxy`, `scada-historian` and the protocol processes read it from `scada-config`, so a change made in the Client — objects, devices, users, their passwords and roles — takes effect in every process at once. See [Preparing the project]({{ '/en/getting-started/' | relative_url }}#project).

1. A process's own parameters go in a `server.override.json` file beside `server.json`: `scada-setup apply` never changes it and lays it over the template, so they survive re-running `apply` and upgrades. See [Your own parameters]({{ '/en/server/' | relative_url }}#server-override).

1. An error in the parameter file is written to the process log, not only printed to the screen; the lowest level of the log messages is set with the `log.severity` parameter (or `--log-severity`). See [Logging]({{ '/en/server/' | relative_url }}#logging).

1. Upgrading from version 2.5 is done with `scada-setup migrate`: it copies the configuration, users with their passwords, the archives and the display files, and leaves the version 2.5 folders unchanged. See [Upgrading from version 2.5]({{ '/en/server/' | relative_url }}#upgrade-2-5).

1. A new installation starts from an empty project — no objects, devices, links or users; sign in with the built-in `root` account. The demo project (objects with emulation, IEC 60870-5-104 links, users with no passwords, schematics) is installed on request: `scada-setup apply --demo`. See [Preparing the project]({{ '/en/getting-started/' | relative_url }}#project).

1. A Linux Server package — a `.deb` and a `.tar.gz` archive for x86-64 Linux with systemd (not attached to release 2.6.0 yet; installation tried in an Ubuntu 24.04 container, not yet on a working site): the same processes except `scada-opc` and `scada-vidicon`, and `scada-setup`, which creates a systemd service per process. See [Installation on Linux]({{ '/en/getting-started/' | relative_url }}#linux).

1. Fixed: a command that an IEC 60870-5-104 device rejects is reported as an error, not as successfully completed.

1. Fixed: MODBUS writes (control) for every data type — FLOAT, DOUBLE, INT16, INT32, negative values — in the same format and word order as reading, honouring `;swapbytes` and `;swapwords`. A write to register bits changes only the selected bits, and a value that does not fit the channel's type is refused. See [MODBUS register addressing]({{ '/en/dev/devices/' | relative_url }}#modbus-registers).

1. The MODBUS ASCII variant is implemented. See [MODBUS]({{ '/en/protocols/' | relative_url }}#modbus).

1. MODBUS: the `;reversewords` address parameter reverses the order of a value's registers, so a DOUBLE sent most significant word first — the usual order — is read and written correctly; with `;swapbytes` and `;swapwords` it reaches every word order. The default order is unchanged. See [MODBUS register addressing]({{ '/en/dev/devices/' | relative_url }}#modbus-registers).

1. MODBUS: a channel address with an unknown option — a misspelt `;swapword`, for example — is not accepted, and the device log records a warning; until now such an option was silently skipped and the value read in the default word order. See [MODBUS register addressing]({{ '/en/dev/devices/' | relative_url }}#modbus-registers).

1. MODBUS retransmission: a rule's Value format property sets the type and the byte and word order of the value sent, written as in a channel address (`FLOAT;swapwords`, `INT32`, `DOUBLE;reversewords`); FLOAT, INT32 and UINT32 take two registers, DOUBLE four. The default (UINT16) is rounded to the nearest whole number instead of dropping the fraction, and a value outside the type's range is sent as the nearest one it can hold instead of modulo. A device's first rule gets address 40001, a holding register, instead of coil 1. See [Retransmission over MODBUS]({{ '/en/dev/devices/' | relative_url }}#modbus-retransmission).

1. MODBUS retransmission: the Server answers one read request with up to 125 registers or 2000 bits, as the protocol allows, instead of up to 50 registers or 800 bits with the connection dropped on a larger request; a request it cannot carry out is answered with a MODBUS exception, and the connection stays open. A deleted, moved or re-formatted rule stops being sent at its old registers at once, with no process restart. A rule whose format is a register-table word alone (for example `HOLDREG`) is treated as wrong instead of sending the neighbouring register. Over MODBUS TCP the response carries the request's transaction number. See [Retransmission over MODBUS]({{ '/en/dev/devices/' | relative_url }}#modbus-retransmission).

1. Retransmission over IEC 60870-5-104: a release of selection received from the DC is passed on to the source device, and the deactivation is confirmed to the DC once the device has answered. See [Retransmission to a dispatch centre]({{ '/en/dev/devices/' | relative_url }}#retransmission).

1. MODBUS RTU: fixed waiting for a device's exception response — a command the device rejects is reported as an error at once, not after the response timeout. In retransmission mode, fixed receiving writes with 0x10 and added 0x06 and 0x0F.

1. IEC 60870-5: ASDU types 7 and 33 (32-bit bitstring) are accepted, and normalized values are scaled to −1…+1. If the project divided a normalized value by 32768 with a formula or a conversion, remove that rescaling. See [IEC 60870-5]({{ '/en/protocols/' | relative_url }}#iec-60870).

1. With two-stage control, an operator declining to execute releases the selection on an IEC 60870-5 or IEC 61850 device instead of leaving it until the device's timeout. See [Two-stage control]({{ '/en/dev/data-items/' | relative_url }}).

1. Fixed: an IEC 61850 device refusing a command is reported as "IEC 61850 protocol error", not as an IEC 60870 error.

1. IEC 61850: analogue setpoints (class APC) and step control (class BSC) are supported, including select-before-operate and releasing the selection. See [IEC 61850]({{ '/en/protocols/' | relative_url }}#iec-61850).

1. Fixed: timestamps from first-edition IEC 61850 devices (type BinaryTime) are read correctly rather than as dates around 1970. See [IEC 61850]({{ '/en/protocols/' | relative_url }}#iec-61850).

1. IEC 61850 devices are no longer offered as retransmission destinations: the Server never served them. Retransmission rules created for them earlier are deleted on upgrade. See [IEC 61850 devices]({{ '/en/dev/devices/' | relative_url }}#iec-61850).

1. Fixed: the fields with a list of values — a direction's *Protocol* and *Mode*, a TIT object's *Conversion*, a simulation signal's *Type* — offer their choices again. See [Fields with a list of values]({{ '/en/dev/devices/' | relative_url }}#enum-lists).

1. When no value of an object's Control condition has arrived yet (right after start-up, for example, or after an alias in the condition was renamed), the Server waits up to 2 seconds for one and decides on it rather than refusing the first command. See [Data items]({{ '/en/dev/data-items/' | relative_url }}).

### Client

1. `Roles...` on a user in the Users window assigns and removes an account's roles; only roles grant rights at sign-in. The Permissions property (0–3), which granted nothing, is no longer in the property window. `Enable Account` and `Disable Account` allow and stop sign-in, and the server does not let the Client delete, rename, disable or otherwise change the `svc` service account. See [Assigning roles]({{ '/en/dev/users/#assign-roles' | relative_url }}).

1. The main window is a workbench with the [section rail]({{ '/en/client/workbench/' | relative_url }}#activity-bar) on the left and the [Inspector]({{ '/en/client/workbench/' | relative_url }}#inspector) panel on the right, which shows the selected object or event. See [Operator workbench]({{ '/en/client/workbench/' | relative_url }}).

1. The user profile (pages, window layout, portfolios, settings) is saved on this computer; in addition, when the Client closes and on *Disconnect from Server* it also saves the profile on the Server, in the account's profile, at every access level, and at login it loads the profile from there — pages and portfolios follow the account to another computer (with the "Telecontrol" server type; with "OPC UA" the profile is kept on this computer only). See [Where portfolios are kept]({{ '/en/client/portfolio/' | relative_url }}#storage).

1. *Acknowledge All* in the [Event journal]({{ '/en/client/events/' | relative_url }}) acknowledges only the events shown: events hidden by a zone, severity or object filter stay unacknowledged.

1. The common *Acknowledge All* command, which acknowledges every event in the system, is now in the *More* menu and runs — from there and from the command palette — only after a confirmation stating how many events it acknowledges. See [Common commands]({{ '/en/client/' | relative_url }}#common-commands).

1. The sign-in window opened by *Disconnect from Server* and *Connect to Server...* always waits for input — automatic sign-in happens only when the Client starts. It can now be bypassed on macOS too (with the *Option* key), and with *Cancel* while the sign-in is in progress. See [Automatic sign-in]({{ '/en/client/' | relative_url }}#auto-login).

1. When the Server refuses an acknowledgement (for example, for lack of rights), the event panel shows an error message and the acknowledgement can be retried.

1. With the *Control Success Message* setting on, the Client reports a successful [control]({{ '/en/client/' | relative_url }}#control-result) or [manual input]({{ '/en/client/' | relative_url }}#manual-input) command.

1. In the [event panel]({{ '/en/client/' | relative_url }}#events-panel), *Severity — All* removes the threshold that was set, and the panel shows every event again. The threshold acts on the panel only: the count, the tiles and annunciation take every event into account. See [Severity threshold]({{ '/en/client/alarms/' | relative_url }}#threshold).

1. Fixed: reopening the *Period* dialog with the *Time* box cleared no longer moves the end of the period a day later. See [A report for last month]({{ '/en/client/reports/' | relative_url }}#last-month).

1. The [graph legend]({{ '/en/client/graph/' | relative_url }}#legend) shows each line's current value, minimum, maximum and average over the visible range, with the value at the cursor in its own `@ cursor` column.

1. The [Table]({{ '/en/client/table/' | relative_url }}) window has new `Quality`, `Trend` and `Source` columns; columns can be hidden from the header context menu.

1. The [CSV export]({{ '/en/client/export/' | relative_url }}) dialog has an *Expand grouped rows* option for the event journal.

1. Fixed: CSV export honours the chosen encoding. On Windows, *System* writes the file in the Windows code page and *Unicode (UTF-8)* writes UTF-8 with a byte-order mark, so Microsoft Excel opens the file by double-clicking it without garbling Russian text. See [Opening the file in Excel]({{ '/en/client/export/' | relative_url }}#open-in-excel).

1. Configuration export and import (*More — Export Configuration...* and *Import Configuration...*) use the OPC UA NodeSet (XML) format instead of version 2.5.7's CSV table. CSV files exported by version 2.5 cannot be imported: a version 2.5 Server's configuration is moved over by `scada-setup migrate`. See [Configuration export and import]({{ '/en/dev/excel/' | relative_url }}) and [Upgrading from version 2.5]({{ '/en/server/' | relative_url }}#upgrade-2-5).

1. Event severity is a number from 1 to 1000 instead of the former scale up to 100: *Critical* is 800 and above, *Warning* from 600. Severity set in object properties and the severity of archived events are recalculated once (multiplied by 10), as is the minimum severity saved in the profile. See [Severity]({{ '/en/client/events/' | relative_url }}#severity).

1. The [Event journal]({{ '/en/client/events/' | relative_url }}) has a filter bar above the journal (*Period*, *Min. severity*, *Unacknowledged only*) and an area list on the left with each area's count of unacknowledged events. See [Period]({{ '/en/client/events/' | relative_url }}#period) and [Filters]({{ '/en/client/events/' | relative_url }}#filters).

1. The *Audit log* window shows sign-ins and who did what to user accounts, passwords and roles; it is available to administrators only. See [Audit log]({{ '/en/client/workbench/' | relative_url }}#audit-log).

1. Modus displays are drawn by the Client's own display module, without the ActiveXeme component. Shapes bound with the `ключ_привязки` property show the present switch positions and measured values, and a click on such a shape selects its object; the **Display** menu lists a schematic by its title. Breakers are filled with the colours from the schematic's settings, a shape with unacknowledged events blinks a frame, and a double-click on a shape with no unacknowledged events follows its *гиперссылка* (hyperlink) property to another schematic. Bindings of other properties and limits are not shown — see [Live values on a Modus schematic]({{ '/en/client/display/' | relative_url }}#live-values).

1. Vidicon displays show live values on the schematic itself: breakers, disconnectors and value fields change with the objects whose addresses the shapes' tags name, and a shape with unacknowledged events blinks a frame. A shape whose value is unreliable or whose object is not connected is hatched in the bad-quality colour, and a shape whose value disappears returns to the look saved in the schematic. See [Live values on a Vidicon schematic]({{ '/en/client/display/' | relative_url }}#live-values-vidicon).

1. The [Device watch]({{ '/en/client/device-watch/' | relative_url }}) window has a `Frame trace` mode — protocol traffic only, with a decode pane for the selected frame — and a filter line above the table that works in both modes and also applies to `Save as`.

1. The `Multiple Create…` command opens a wizard that creates several data objects at once from one name and address pattern. See [Bulk create]({{ '/en/dev/data-items/' | relative_url }}#bulk-create).

1. Transmission rules are created in bulk: select the objects in a table, summary or portfolio and choose `Create -> Transmission Rules...` — the wizard creates a rule per object with consecutive addresses. See [Retransmission to a dispatch centre]({{ '/en/dev/devices/' | relative_url }}#retransmission).

1. A transmission rule created by ticking an object gets the device's next free address instead of address 1. Rules sharing an address are marked in the transmission table and in the bulk create wizard. See [Transmission rules]({{ '/en/client/workbench/' | relative_url }}#transmission).

1. Summary: *Maximum* over negative values is computed correctly (it used to show about 0); invalid values are no longer counted; a *Time Average* function is added, and *Sum* is replaced by *Time Integral*, which gives, for example, energy from power. Saved windows that used *Sum* show the integral. See [Aggregation function]({{ '/en/client/summary/' | relative_url }}#function).

1. A graph can be printed (to PDF as well) and saved as a PNG image. See [Printing and export of a graph]({{ '/en/client/graph/' | relative_url }}#print-export).

1. *Export to Excel* is offered on any Windows computer with Microsoft Excel installed; the `--excel` start-up option is no longer needed. See [Export to Excel]({{ '/en/client/export/' | relative_url }}#excel).

1. A printout of a table, a summary or another window opens with a header: the window title, the period (for a window that has one), for a summary the aggregation function and interval, and the print time. See [Printing]({{ '/en/client/print/' | relative_url }}).

1. A summary shows at most 10 000 intervals. When the period is longer, a notice above the summary reads "The summary is limited to 10000 rows and ends at …", and the printout header repeats it. See [Summary]({{ '/en/client/summary/' | relative_url }}).

1. A summary holds at most 1,000 columns; objects beyond that are not added, and a notice above the summary says "The summary is limited to 1000 columns; <number> items were not added." — also when a window saved with more columns is opened. Such columns used to disappear on reopen without warning. See [Summary size]({{ '/en/client/summary/' | relative_url }}#limits).

1. In a summary, *Time Average* and *Time Integral* take the value in force when the interval began — including one recorded before the period — and an interval in which the value did not change shows that value instead of an empty cell. See [Aggregation function]({{ '/en/client/summary/' | relative_url }}#function).

1. A graph's values are exported to CSV and Excel: every line over the visible time range, one column per line. See [Printing and export of a graph]({{ '/en/client/graph/' | relative_url }}#print-export).

1. CSV export proposes the column delimiter of the Windows regional settings on first use (a semicolon for Russian settings), so the file opens in Excel in columns. See [Export to CSV]({{ '/en/client/export/' | relative_url }}#open-in-excel).

1. A custom period whose start is not before its end is refused: *OK* stays unavailable until the period is corrected.

1. The Client interface is available in English, and the appearance is chosen from the *Colour scheme* list — see [Settings]({{ '/en/client/workbench/' | relative_url }}#settings) and [Appearance]({{ '/en/client/workbench/' | relative_url }}#appearance).

1. With two-stage control, a device refusing to release the selection is reported in the current events panel: the selection then stays in force until the device's select timeout. See [Two-stage control]({{ '/en/client/' | relative_url }}#two-stage).

1. Shift handover with *Disconnect from Server*: after a sign-in under another account the Client opens that account's profile — its pages, portfolios and settings — instead of keeping the previous operator's pages. See [Shift handover]({{ '/en/client/' | relative_url }}#shift-change).

1. The Control window finds a device-channel reference inside a Control condition expression, such as `{IEC_DEV.1!5} = 1`, the same way the Server does, so control from the window is no longer blocked by such a condition; the same applies to tables and user tables. See [Formulas]({{ '/en/formulas/' | relative_url }}).

1. With two-stage control, the selection on the device is also released when the Control window is closed during the select stage. See [Two-stage control]({{ '/en/client/' | relative_url }}#two-stage).

1. Two-stage control of an object whose device cannot select — an IEC 60870-5 command other than a single command (C_SC_NA_1), an IEC 61850 object with direct control, a MODBUS object, or an OPC object — is refused by the Server at the select stage, with nothing sent to the device, and the Client explains this in an error box. Such a select used to be confirmed without asking the device, and the Client said "The remote device is ready to execute the command." One-stage control of such an object works as before. See [Two-stage control]({{ '/en/client/' | relative_url }}#two-stage).

1. Deleting a portfolio, or an object from one, asks for confirmation first. See [Portfolios]({{ '/en/client/portfolio/' | relative_url }}).

1. In the bulk-create wizard the "NodeId template" field is empty by default, so the Server assigns the identifiers; the former default was one the Server refused. See [Data items]({{ '/en/dev/data-items/' | relative_url }}).

### Known limitations {#known-limitations}

Read this list before buying and before upgrading: each limitation is described in detail on the page it links to.

#### Before upgrading from 2.5.7 {#limits-upgrade}

1. Two-stage control is on by default, and version 2.6 does not carry out MODBUS or OPC objects, IEC 61850 objects with direct control, or IEC 60870-5 commands other than single commands (C_SC_NA_1) in two stages: the Server refuses the select. Before upgrading, set "Two-stage control" to No on such objects, or they cannot be controlled. See [Two-stage control]({{ '/en/client/' | relative_url }}#two-stage).

1. MODBUS: version 2.5.7 read a channel address with a misspelt option (`;swapword`, `;swapbyte`) by skipping the option; version 2.6 does not accept it, and such an object stops receiving values. Before upgrading, check the spelling of the options in your MODBUS channel addresses. See [MODBUS register addressing]({{ '/en/dev/devices/' | relative_url }}#modbus-registers).

1. On Modus displays the 2.6 Client shows switch positions and values bound through the *положение*, *текст* and *значение_базовое* properties but, unlike 2.5.7, does not show bindings of other shape properties or limits. If a site's displays rely on these, check the displays before upgrading. The bindings have not yet been tried on the schematics of working sites, so in any case open your site's schematics in a 2.6 Client before upgrading the workstations. See [Live values on a Modus schematic]({{ '/en/client/display/' | relative_url }}#live-values).

1. Bound shapes inside a Modus Graphic Editor group have not been tried in version 2.6. See [Binding objects]({{ '/en/dev/displays/' | relative_url }}#binding).

1. The 2.6 Client draws the common Modus element types as the Modus graphics editor does, except the instruments and controls that the editor draws as pictures (*прибор_настраиваемый*, *прибор_реальный*, *прибор_цифровой*, *РПН*, *панель_накладка*, *орган_управления*): the Client draws these simplified — by the picture's main outlines, without a needle or lettering, and at one size whatever scale the shape is given. An *отделитель* (separator) is drawn with the editor's symbol, but coloured by its position as a breaker square is (the editor always draws it black). The *Spectrum_UP*, *Spectrum_P* and *Server* elements are not drawn yet; some less common elements are drawn without the letters inside them, and the coloured parts of some (valves, for example) are drawn grey. Open your site's schematics in a 2.6 Client before upgrading. See [Live values on a Modus schematic]({{ '/en/client/display/' | relative_url }}#live-values).

1. Hyperlinks of Modus shapes have not been tried on working sites' schematics; a link opens only when the schematic is inside the workstation's schematics folder. See [Binding objects]({{ '/en/dev/displays/' | relative_url }}#binding).

1. The Client packages do not include the display module yet: its licence terms are not settled, and the module is supplied separately. Without it a display window shows "No display runtime is installed." See [When a schematic is not shown]({{ '/en/client/display/' | relative_url }}#not-shown).

1. An external OPC UA system that connected to a 2.5 Server unencrypted (policy None) or with anonymous sign-in will not connect to a 2.6 Server that way: `scada-proxy`'s port 4840 accepts only secured connections that sign in with a user name. Trust the system's certificate and create a user for it, or run `apply` on the computer with `scada-proxy` with `--allow-anonymous-opcua`. See [Connecting an external system]({{ '/en/server/' | relative_url }}#opcua-external).

1. A version 2.5 Client working with a 2.6 Server has not been tested: install the 2.6 Client on every workstation. A 2.6 Client working with a 2.5.7 Server has not been tested either: both use the same connection protocol version, so a 2.5.7 Server does not turn a 2.6 Client away when it connects, but capabilities that the Server provides in version 2.6 may not work with a 2.5.7 Server. See [Upgrading from version 2.5]({{ '/en/getting-started/' | relative_url }}#upgrade-2-5).

#### Protocols and retransmission {#limits-protocols}

1. IEC 61850: the device's clock must run on UTC — timestamps are not converted from local time. An APC setpoint whose device model carries both the `i` and `f` fields is not sent. See [IEC 61850]({{ '/en/protocols/' | relative_url }}#iec-61850).

1. Retransmission: objects whose values another Server process receives are sent to the DC, and the DC's commands on them carried out, only while `scada-proxy` is running. See [Retransmission to a dispatch centre]({{ '/en/dev/devices/' | relative_url }}#retransmission).

#### Archive and reports {#limits-archive}

1. *Export to Excel* is offered only on Windows, on a computer with Microsoft Excel installed. See [Export to Excel]({{ '/en/client/export/' | relative_url }}#excel).

#### Installation and security {#limits-setup}

1. The license is issued for a term; after it expires the Server processes refuse requests. See [Licensing]({{ '/en/server/' | relative_url }}#licensing).

1. Version 2.6 does not read the version 2.5 HASP or Guardant key: on upgrading, it is exchanged for a license using the `TIERS=…` line that the `scada-setup migrate` plan prints. See [Exchanging the hardware key]({{ '/en/server/' | relative_url }}#license-exchange).

1. `scada-setup` has not yet been tried on a site under Windows. If the result of any command differs from the description, report that to Telecontrol. See [Setting up with scada-setup]({{ '/en/server/' | relative_url }}#scada-setup).

1. Uninstalling the program, which removes the process services itself, has not yet been tried under Windows; if the uninstall is cancelled with an error, the program stays installed. See [Uninstalling the Server]({{ '/en/server/' | relative_url }}#uninstall).

1. On Linux the `svc` and `root` passwords are kept in an unencrypted file only `root` can read, and the process services run as `root`. See [Where the passwords are kept]({{ '/en/server/' | relative_url }}#stored-passwords).

1. The built-in `root` account's password is changed only with `scada-setup set-password` on every Server computer: the Server refuses such a change from the Client. See [Root password]({{ '/en/server/' | relative_url }}#root-password).

1. The site certificate authority is kept only on the central computer, in the `data\Certificates\ca` folder. An uninstall with `SCADA_PURGE_CERTIFICATES=1` (on Linux, `apt purge` or deleting `/opt/telecontrol-scada`), or a restore without that folder, makes the next `apply` create a new authority, and every other computer must then join again with `apply` and the new fingerprint in `--central-fingerprint`. A computer's certificate is valid for 5 years, the certificate authority's for 10. See [Lifetime and a new certificate authority]({{ '/en/server/' | relative_url }}#opcua-renewal).

1. The `svc` password may be at most 64 bytes long (a Cyrillic letter takes two): `scada-setup` refuses a longer one. See [scada-setup options]({{ '/en/server/' | relative_url }}#scada-setup-options).

1. The Client packages are not digitally signed: on first launch Windows SmartScreen warns about the program, and macOS refuses to open it until it is allowed in the system settings. See [Installing the Client]({{ '/en/getting-started/' | relative_url }}#client-install).

#### Working with the Client {#limits-client}

1. With "Sign in automatically next time" ticked, the Client logs in as the last account by itself at startup — do not tick it on a shared workstation; to sign in as yourself, hold *Ctrl* (on macOS, *Option*) while starting it. See [Automatic sign-in]({{ '/en/client/' | relative_url }}#auto-login).

1. The alarm tone is off for every new account — switch it on under each operator's account. See [The alarm tone]({{ '/en/client/alarms/' | relative_url }}#tone).

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
