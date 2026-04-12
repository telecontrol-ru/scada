---
title: Реестр изображений
nav_exclude: true
---

# Image manifest

This manifest is the source of truth for how each image under
`scada-docs/img/` is produced. Every file gets exactly one tag:

| Tag | Meaning |
|---|---|
| `auto-view` | Main-window view type; rendered by `app/screenshot_generator.cpp` from a `WindowInfo` registered with the controller registry. |
| `auto-dialog` | Modal dialog; rendered by the generator via the `dialogs:` section of `screenshot_data.json`. |
| `auto-menu` | Right-click / popup menu; rendered by the generator from the command registries. |
| `auto-state` | Device / node runtime state capture (online, offline, traffic, …); needs fixture knobs. |
| `manual-diagram` | Hand-drawn architecture or protocol diagram, not a screenshot. |
| `manual-modus` | Modus schematic — depends on the Modus ActiveX runtime the fixture doesn't have. |
| `manual-os` | OS-level screenshot (Windows firewall, …) — lives outside the app. |
| `obsolete` | Still checked in, but not referenced from any `*.md`. Candidate for removal. |

When adding a new screenshot, append a row below and, if the tag starts
with `auto-`, add the matching entry to
`client/app/screenshot_data.json` in scada-client.

## Inventory

| File | Tag | Referenced from | Notes |
|---|---|---|---|
| `MODBUS_func.png` | `manual-diagram` | `protocols.md` | Modbus function-code table, hand-drawn. |
| `client-login.png` | `auto-dialog` | `getting-started.md` | `LoginDialog` modal shown at startup; rendered by the dialog pipeline. |
| `client-retransmission.png` | `auto-view` | `client.md` | `Transmission` window type. |
| `client-window.png` | `auto-view` | `client.md` | Full main window; already produced by `CaptureMainWindow`. |
| `control-confirm.jpg` | `obsolete` | — | Superseded by `t{s,i}-remote-control-confirm.png`. |
| `control-ti.jpg` | `obsolete` | — | Superseded by `ti-remote-control-enabled.png`. |
| `control-ts.jpg` | `obsolete` | — | Superseded by `ts-remote-control-enabled.png`. |
| `devices-create.png` | `auto-state` | `dev/devices.md` | `Struct` window, device freshly created. |
| `devices-off.png` | `auto-state` | `dev/devices.md` | `Struct` window, device offline. |
| `devices-on.png` | `auto-state` | `client.md` | `Struct` window, device online. |
| `devices-status.png` | `auto-state` | `client.md` | `Struct` window, status column visible. |
| `devices-traffic.png` | `auto-state` | `client/device-watch.md` | `Log` window showing live device traffic. |
| `display.png` | `manual-modus` | `client/display.md` | Modus schematic — out of scope until fake runtime lands. |
| `events-cur.jpg` | `obsolete` | — | Superseded by `menu-events-log.png`. |
| `firewall.jpg` | `manual-os` | — | Windows firewall dialog; OS-level. |
| `firewall.png` | `manual-os` | — | Windows firewall dialog; OS-level. |
| `graph-cursor.jpg` | `auto-view` | `client/graph.md` | `Graph` window with cursor; generator already emits `graph.png`. |
| `iec-60870-5-transport.png` | `manual-diagram` | `dev/devices.md` | IEC 60870-5 transport stack diagram. |
| `iec-61850-model.png` | `manual-diagram` | `client.md` | IEC 61850 object model diagram. |
| `limits-chart.png` | `auto-view` | `architecture.md` | Graph with limit lines drawn; blocked on the fixture exposing `AnalogItemType_LimitLo/Hi/LoLo/HiHi` on a graphed node. |
| `limits.png` | `auto-dialog` | `architecture.md`, `client.md` | `LimitDialog` modal. |
| `login.png` | `obsolete` | — | Superseded by `client-login.png`. |
| `menu-copy-object.png` | `auto-menu` | `dev/data-items.md` | Context menu: copy object. |
| `menu-create-object-service.png` | `auto-menu` | `dev/data-items.md` | Context menu: create service object. |
| `menu-create-object-ts-ti.png` | `auto-menu` | `dev/data-items.md` | Context menu: create TS/TI. |
| `menu-create-object.png` | `auto-menu` | `dev/data-items.md` | Context menu: create object (root). |
| `menu-delete-object.png` | `auto-menu` | `dev/data-items.md` | Context menu: delete object. |
| `menu-events-log.png` | `auto-menu` | `client/events.md` | Context menu on event journal row. |
| `menu-events.png` | `auto-menu` | `client.md` | Context menu on event row. |
| `menu-excel.png` | `auto-menu` | `dev/excel.md` | Context menu: export to Excel. |
| `menu-favorites.png` | `auto-menu` | `client.md` | Context menu: favourites. |
| `menu-files.png` | `auto-menu` | `client.md`, `dev/server-files.md` | Context menu on file view. |
| `menu-notepad.png` | `auto-menu` | `dev/excel.md` | Context menu: open in Notepad. |
| `menu-parameters-elements-copy.png` | `auto-menu` | `dev/displays.md` | Context menu: copy parameter element. |
| `menu-parameters-elements.png` | `auto-menu` | `dev/displays.md` | Context menu: parameter elements. |
| `menu-parameters.png` | `auto-menu` | `dev/data-items.md` | Context menu: parameters. |
| `menu-scheme.png` | `auto-menu` | `dev/displays.md` | Context menu on schematic. |
| `menu-summary.png` | `auto-menu` | `client/summary.md` | Context menu on summary row. |
| `modus-f11-breaker.png` | `manual-modus` | `dev/displays.md` | Modus schematic — breaker. |
| `modus-f11-bus.png` | `manual-modus` | `dev/displays.md` | Modus schematic — bus. |
| `modus-scheme.png` | `manual-modus` | `dev/displays.md` | Modus schematic — overview. |
| `structure.png` | `manual-diagram` | `index.md` | System architecture diagram. |
| `ti-channel.png` | `auto-dialog` | `dev/devices.md` | Node properties / Channels tab, TI side. |
| `ti-delete.png` | `auto-menu` | `development.md` | Context menu: delete TI. |
| `ti-element-parameters.png` | `auto-dialog` | `development.md` | Node properties / Element parameters tab. |
| `ti-formula.png` | `auto-dialog` | `formulas.md` | Node properties / Formula tab. |
| `ti-manual-control.png` | `auto-dialog` | `client.md` | Manual-control dialog, TI side. |
| `ti-parameters.png` | `auto-dialog` | `development.md`, `dev/data-items.md` | Node properties, TI root. |
| `ti-remote-control-confirm.png` | `auto-dialog` | `client.md` | Remote-control confirmation, TI. |
| `ti-remote-control-disabled.png` | `auto-dialog` | `client.md`, `dev/data-items.md` | Remote-control dialog disabled state, TI. |
| `ti-remote-control-enabled.png` | `auto-dialog` | `client.md`, `dev/data-items.md` | Remote-control dialog enabled state, TI. |
| `ts-channel.png` | `auto-dialog` | `dev/devices.md` | Node properties / Channels tab, TS side. |
| `ts-manual-control.png` | `auto-dialog` | `client.md` | Manual-control dialog, TS side. |
| `ts-remote-control-confirm.png` | `auto-dialog` | `client.md` | Remote-control confirmation, TS. |
| `ts-remote-control-disabled.png` | `auto-dialog` | `client.md` | Remote-control dialog disabled state, TS. |
| `ts-remote-control-enabled.png` | `auto-dialog` | `client.md` | Remote-control dialog enabled state, TS. |
| `users.jpg` | `obsolete` | — | Superseded by `users.png`. |
| `users.png` | `auto-view` | `dev/users.md` | `Users` window. |

## Counts

| Tag | Count |
|---|---|
| `auto-view` | 5 |
| `auto-dialog` | 15 |
| `auto-menu` | 15 |
| `auto-state` | 5 |
| `manual-diagram` | 4 |
| `manual-modus` | 4 |
| `manual-os` | 2 |
| `obsolete` | 5 |

Everything tagged `manual-*` stays hand-maintained. Everything tagged
`obsolete` is a removal candidate — leave the file in place until the
replacement is committed.
