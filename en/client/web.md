---
title: Web interface
nav_order: 15
parent: Client
permalink: /en/client/web/
---

# Web interface
{:.no_toc}

* TOC
{:toc}

Besides the graphical desktop Client, Telecontrol SCADA provides a web client —
the same operator workbench, opened in a browser and requiring no installation.
It is intended for remote access and for thin-client workstations.

The web client and the desktop Client are two implementations of one workbench.
They share the screen layout, the vocabulary and the meaning of every safety
signal; they differ in appearance and interaction idiom, because the desktop
Client follows the host operating system's look and the web client follows its
own design system. That difference is deliberate, not drift.

## Connecting

The web client is a set of static files (HTML and JavaScript) served by a web
server. The SCADA Server itself does not serve them: it serves only the OPC UA
WebSocket endpoint. How to connect the two is described under
[Deployment](#deployment).

The endpoint address defaults to the address of the page itself — `/ua` on the
same host over the matching scheme (`wss:` for a page served over HTTPS). There
is therefore no transport dialog of the kind the desktop Client has in
[device parameters]({{ '/en/dev/devices/' | relative_url }}).

The sign-in screen asks for:

<dl>

<dt>Server mode</dt>
<dd>"Cloud server" — the endpoint configured for this installation; "Custom
server" — an address typed into the "Server address" field
(<code>host:port</code> or <code>wss://host:port/ua</code>); "Demo emulator" —
a built-in set of demonstration data that contacts no server.</dd>

<dt>User name and password</dt>
<dd>The same accounts as the desktop Client. Anonymous sign-in is available
where the installation permits it.</dd>

</dl>

For diagnostics the endpoint can be overridden with the `scada-ws-host`,
`scada-ws-port`, `scada-ws-path` and `scada-ws-scheme` query parameters; the
override is remembered by the browser until it is changed again.

## Deployment {#deployment}

The web client needs three things:

1. **A WebSocket endpoint** on the Server process the Clients connect to
   (`scada-proxy` in a distributed installation) — see
   [WebSocket endpoint for the web client]({{ '/en/server/' | relative_url }}#opcua-websocket).
2. **The web client's files.** They are not part of the published
   [releases]({{ '/en/getting-started/' | relative_url }}#download); request them
   from Telecontrol (mail@telecontrol.ru).
3. **A web server** that serves the files and forwards `/ua` requests to the
   Server's endpoint. The page and the endpoint then share one address, and the
   web client finds the Server with no further setup.

The web server must provide:

* **HTTPS with a certificate the browser trusts.** A page opened over HTTPS can
  only connect over `wss:`.
* **Forwarding of `/ua` to the Server with WebSocket support**, path
  unchanged: the Server accepts connections on `/ua` only.
* **The files for every other path**, with `index.html` for an unknown path:
  the web client is a single-page application.
* **The page's address in the Server's `allowed_origins`** when that list is
  not empty — for example `https://scada.example.com`. The browser sends an
  `Origin` header even when the page and the endpoint share an address, and
  the comparison is exact.

An example for the [Caddy](https://caddyserver.com/) web server on the same
computer as the Server process, whose `opcua.url` includes
`opc.ws://127.0.0.1:4842`:

```
scada.example.com {
    handle /ua {
        reverse_proxy 127.0.0.1:4842
    }
    handle {
        root * /srv/scada-web
        try_files {path} /index.html
        file_server
    }
}
```

For a public host name Caddy obtains the HTTPS certificate automatically. If
the web server runs on a different computer, enable `opc.wss://` on the Server
instead of `opc.ws://` so the connection between them is encrypted, and make
the web server trust the Server's certificate.

The address for the "Cloud server" mode is set in `scada-config.js`, one of the
web client's files:

```js
window.__SCADA_CONFIG__ = { cloudServerUrl: 'wss://scada.example.com/ua' };
```

## Layout

The screen is the one described under
[Operator workbench]({{ '/en/client/workbench/' | relative_url }}):

* **Activity bar** on the left — the sidebar modes Data items, Devices, Files,
  Nodes and Administration, the profile's pages, and Settings and Users pinned
  at the foot. Nodes and Administration are hidden, not disabled, for an
  account without the configuration permission, exactly as in the desktop
  Client.
* **Context bar** on top — the page → view → selected object path, the
  search/command field (*Ctrl+K*) and the alarm severity tiles.
* **Workspace tabs** in the centre, the **inspector** on the right and the
  **status bar** at the bottom.

## Capabilities

The web client opens the same windows as the desktop Client:

* the graph (historical trend) with a range picker and per-series statistics
* [table]({{ '/en/client/table/' | relative_url }}), custom table and
  [summary]({{ '/en/client/summary/' | relative_url }})
* the value history of an object ([Data]({{ '/en/client/data/' | relative_url }}))
* current events and the
  [event journal]({{ '/en/client/events/' | relative_url }}), with
  acknowledgement
* [device watch]({{ '/en/client/device-watch/' | relative_url }}): the frame
  trace, the format and free-text filter, and the byte-level IEC 60870-5-104
  frame decode
* the equipment tree, the object tree,
  [portfolios]({{ '/en/client/portfolio/' | relative_url }}) and favourites
* server files and displays in the `.vds` and `.svg` formats
* node parameters,
  [transmission rules]({{ '/en/client/workbench/#transmission' | relative_url }})
  and bulk object creation
* control commands, manual entry and setpoints
* CSV export, configuration export and import
* administration: users with their roles and access rights, history databases,
  two-state signal formats, password change

## Limitations

The following are available only in the desktop Client:

* **Modus displays** — they are drawn by the ActiveXeme component, which does
  not exist in a browser; the web client renders displays in the `.vds` and
  `.svg` formats.
* **Multi-pane graphs** — adding and removing sub-graphs, the background
  colour and the horizontal scroll bar. Series colour is set from the
  inspector.
* **The Roles, Password policy, Audit log and Simulated signals
  administration windows** — a section with no web surface yet is simply not
  offered in the administration list.
* **Browsing the whole address space** — the web client's Nodes mode shows the
  objects folder rather than the root of the address space.
* **Excel export and configuration comparison** — the web client exports and
  imports the configuration file without diffing versions.
* **[Printing with preview]({{ '/en/client/print/' | relative_url }})** — a
  browser prints the page as it is.
* **The About dialog** and the embedded browser window.

## Appearance

The web client uses its own design system and supports light and dark themes.
Alarm severity, data quality and switchgear state colours do not follow the
theme and match the desktop Client: they are functional signalling
(ISA-101, ISA-18.2).
