---
title: Client
nav_order: 7
has_children: true
permalink: /en/client/
---

# Client
{:.no_toc}

* TOC
{:toc}

The graphical client is the main operator application. It provides access to diagrams, tables, graphs, event windows, configuration tools, and data export functions.

Main client window:

![]({{ '/img/client-window.png' | relative_url }})

## Main areas

The main window contains the title bar, the main menu, a command
toolbar, and a status bar. Operators work with multiple views inside
worksheets and can switch between open windows without leaving the
application.

## Menus

The menu bar provides these main groups of commands:

* **Display**: open available diagrams
* **Table**: create tables, user tables, data tables, and group tables
* **Graph**: create new graph windows
* **Object**: execute commands that apply to the selected object
* **Further**: open event windows, engineering panels, and
  configuration import or export tools
* **Sheet**: create, rename, delete, and switch worksheets
* **Window**: rename, close, restore, and favorite open windows
* **Settings**: configure the client look and behavior
* **Help**: open online documentation or show client version

The `Settings` menu controls toolbar and status-bar visibility,
operation confirmation, event popups, event blinking and sound,
built-in Modus rendering, and the application style.

## Status bar

The status bar shows:

* the number of unacknowledged events
* the current importance threshold for the live-event panel
* the active user name
* connection state to the Server
* Server response time in milliseconds

## Sheets and windows

The central workspace is divided into sheets. A client session can have
multiple sheets, but only one is visible at a time. Sheets can be
created, renamed, deleted, and switched from the `Sheet` menu.

Windows and panels can be arranged freely inside a sheet. They can be
docked side by side, stacked as tabs, or restored from the `Window`
menu after accidental closure. The recycle list keeps the 10 most
recently closed windows.

The `Window -> Favorite` command stores a window together with its
content under a user-defined name and folder. Favorited graphs and
tables also appear at the bottom of the corresponding `Graph` and
`Table` menus for quick reopening.

## Command toolbar

The command toolbar below the main menu gives fast access to commands
for the selected object or device.

### Object commands

For the selected object, the toolbar can open related views or perform
actions such as:

* [Graph]({{ '/en/client/graph/' | relative_url }})
* [Table]({{ '/en/client/table/' | relative_url }})
* [Display]({{ '/en/client/display/' | relative_url }})
* [Data]({{ '/en/client/data/' | relative_url }})
* [Summary]({{ '/en/client/summary/' | relative_url }})
* [Event journal]({{ '/en/client/events/' | relative_url }})
* group table
* acknowledge all events
* remove blocking
* control command
* manual input

If a matching window is already open for the same object, the client
switches to it instead of opening a duplicate.

### Device commands

For the selected device, the toolbar can open:

* [Device watch]({{ '/en/client/device-watch/' | relative_url }})
* [Device metrics]({{ '/en/client/device-metrics/' | relative_url }})

It can also:

* enable communication with the device
* disable communication with the device
* force a full poll
* synchronize the device clock with the Server clock

For retransmission projects, the client can create a virtual server
device and a retransmission table for the selected objects.

### Common commands

Common toolbar commands include printing the active window, opening the
event window, and acknowledging all events.

## Control and manual input

The client supports both control commands and manual value entry.

When control confirmation is enabled in `Settings`, each telecontrol or
teleadjustment action must be confirmed before execution. The client
also indicates when control is blocked.

Manual input is intended for cases where a data item must temporarily
override telemetry from field devices. If blocking is enabled for the
object, incoming telemetry is ignored and the manual value takes
priority. If blocking is removed, device telemetry becomes authoritative
again.

Limit values can also be edited from the client. Warning limits must
stay within the configured alarm-limit range.

## Object panel

The object panel is used to browse the object hierarchy, open related
views, and execute object operations. It is available from
`Further -> Objects`.

The panel shows objects grouped by hierarchy. Values and quality flags
appear to the right of object names. Invalid values are shown in gray.
If an object has unacknowledged system events, its value flashes yellow.

Groups show the communication state of the device assigned to that
group. In administration mode, objects can also be dragged between
groups.

The toggle at the left side of each object or group controls whether the
object is included in the current view. Double-clicking an object opens
its graph. Double-clicking a group opens a table for all objects in that
group.

## Equipment panel

The equipment panel is available from `Further -> Equipment`.

It shows the device hierarchy and communication-state indicators for
each device, including disabled channels, enabled channels, and
non-responding devices.

The equipment panel is also the entry point to:

* [Device watch]({{ '/en/client/device-watch/' | relative_url }}) for
  protocol traffic
* [Device metrics]({{ '/en/client/device-metrics/' | relative_url }})
  for service information
* the IEC 61850 data model view for connected IEC 61850 devices

When communication with an IEC 61850 device is established, its data
model appears as a `Model` subtree under the device node. See
[Protocols]({{ '/en/protocols/' | relative_url }}#iec-61850) and
[Development]({{ '/en/development/' | relative_url }}) for the
engineering details behind this view.

## Event panel

The live event panel shows the current list of unacknowledged events.
Operators can acknowledge an event by double-clicking it or by using the
context menu. Multiple events can be acknowledged together with
`Shift`-selection.

If the `Show events on arrival` option is enabled, the live event panel
opens automatically when new events arrive.

The event-row context menu exposes commands for the event itself and, if
the event is linked to an object or device, the corresponding object or
device commands as well.

## Files panel

The files panel provides access to Modus schematic files stored on the
Server:

![]({{ '/img/menu-files.png' | relative_url }})

Files can be organized into folders. The context menu supports creating
folders, uploading files, deleting entries, and renaming files or
folders through the `Properties` command.

## Main views

The main operator-facing views now documented in English are:

* [Graph]({{ '/en/client/graph/' | relative_url }})
* [Table]({{ '/en/client/table/' | relative_url }})
* [Summary]({{ '/en/client/summary/' | relative_url }})
* [Data]({{ '/en/client/data/' | relative_url }})
* [Event journal]({{ '/en/client/events/' | relative_url }})
* [Display]({{ '/en/client/display/' | relative_url }})
* [User table]({{ '/en/client/sheet/' | relative_url }})
* [Device watch]({{ '/en/client/device-watch/' | relative_url }})
* [Device metrics]({{ '/en/client/device-metrics/' | relative_url }})
* [Debugger]({{ '/en/client/debugger/' | relative_url }})
* [Portfolios]({{ '/en/client/portfolio/' | relative_url }})
* [Export and import]({{ '/en/client/export/' | relative_url }})
* [Printing]({{ '/en/client/print/' | relative_url }})
* [Web interface]({{ '/en/client/web/' | relative_url }})

## Related views

See the dedicated pages for:

* [Summary]({{ '/en/client/summary/' | relative_url }})
* [Data]({{ '/en/client/data/' | relative_url }})
* [Device metrics]({{ '/en/client/device-metrics/' | relative_url }})
* [Event journal]({{ '/en/client/events/' | relative_url }})
* [Device watch]({{ '/en/client/device-watch/' | relative_url }})
* [Debugger]({{ '/en/client/debugger/' | relative_url }})
