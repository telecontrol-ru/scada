---
title: Getting started
nav_order: 2
permalink: /en/getting-started/
---

# Getting started
{:.no_toc}

* TOC
{:toc}

This page describes version 2.6, in which the Server is a set of separate
processes (see [Server processes]({{ '/en/architecture/' | relative_url }}#tiers)).

## System requirements

* Windows 10 or newer for the Server and graphical Client, or Linux for the Server only
* TCP/IP connectivity between clients and the server, using port 2000 by default
* A license file issued for the Server processes you need (see [Licensing]({{ '/en/server/' | relative_url }}#licensing))
* The [ActiveXeme](http://swman.ru/content/blogcategory/21/49/) component for Modus schematic rendering in the graphical client, if that display mode is used

## Download {#download}

Distributions are published on the
[Telecontrol SCADA releases page on GitHub](https://github.com/alexsmn/scada-client/releases/latest).

**WARNING:** the release published today, 2.5.7, predates version 2.6: it
installs the Server as a single `Telecontrol SCADA Server` service and does
not contain the separate 2.6 processes. The earlier rules apply to it: the
`Telecontrol SCADA Server` service, a HASP or Guardant hardware key, and the
configuration in `%ProgramData%\Telecontrol\SCADA Server\Configuration`.

## Choose the Server processes

Decide which Server processes the site needs:

* **A minimal installation** is one protocol process, for example
  `scada-iec104`. It keeps the configuration in its own database and accepts
  Client connections itself. It has no archive.
* **A distributed installation** is `scada-config`, the protocol processes
  you need, `scada-historian` for the archive, optionally `scada-filesystem`,
  and `scada-proxy`, which the Clients connect to.

What each process does, and the start order, are described in
[Server processes]({{ '/en/architecture/' | relative_url }}#tiers).

## Installation on Windows

Each Server process is installed as its own Windows service with the
`--install` option of its executable, for example:

```
scada-iec104.exe --install
```

The service is named after the process — `Telecontrol SCADA IEC 104`,
`Telecontrol SCADA Config`, and so on — and starts automatically at boot,
before any user signs in. The process reads the parameter file
`%ProgramData%\Telecontrol\SCADA <process>\<name>.json`, for example
`%ProgramData%\Telecontrol\SCADA IEC 104\scada-iec104.json`. See the
[Server]({{ '/en/server/' | relative_url }}) section for details.

The graphical Client is installed on one or more operator workstations; the
Server and the Client may also share one computer.

### Install ActiveXeme

The graphical Client uses the
[ActiveXeme](http://swman.ru/content/blogcategory/21/49/) component to
render electronic schematics. It can be downloaded from the Modus
vendor site.

ActiveXeme is optional because the Client also supports built-in
schematic rendering through the `Settings -> Built-in Modus rendering`
option.

## Installation on Linux

The Server processes run on Linux: start the executables of the processes
you need, and each reads its own parameter file `data/<name>.json` (see
[Linux deployment]({{ '/en/server/' | relative_url }}#linux)). Container
deployments use a single Docker image.

The graphical Client is not supported on Linux. Linux workstations should use
the [Web interface]({{ '/en/client/web/' | relative_url }}).

## License

Each process needs a license file, `license.json`, listing the processes
purchased. Without a valid license a process stops right after it starts.
**If the Server does not run on Google Cloud, set
`"license": {"require_gcp_binding": false}` in the parameter file** —
otherwise the process cannot verify its license and serves no requests. See
[Licensing]({{ '/en/server/' | relative_url }}#licensing).

## Root password

The built-in `root` account has all rights. While no password is set for it,
the Server accepts `root` with an empty password, so **set one before the
first start**, with `security.rootPassword` in the parameter file of every
process that keeps the configuration in its own database:

```json
"security": {
    "rootPassword": "$ENV{SCADA_ROOT_PASSWORD}"
}
```

A value set this way is written on every start and replaces a password
changed from the Client. See
[Root password]({{ '/en/server/' | relative_url }}#root-password).

## Network preparation

If the server host is protected by Windows Firewall or another network
filtering product, allow incoming TCP connections on port `2000` of the
process the Clients connect to (`scada-proxy` in a distributed installation).
Client workstations must be able to open outgoing TCP connections to the
Server.

In a distributed installation the processes talk to each other over OPC UA,
so their OPC UA ports (the `opcua.url` parameter) must be open between them.

The Client port can be changed with the
[`sessions`]({{ '/en/server/' | relative_url }}#sessions) parameter.

## Initial project setup

For a real project:

* put the configuration database in the directory named by `configuration.dir`
  in the parameter file of the process that keeps the configuration
  (`scada-config` in a distributed installation)
* copy schematic files (`.sde`) to `%ProgramData%\Telecontrol\SCADA Client` on each workstation, or upload them to the [server-side file system]({{ '/en/server/' | relative_url }}#filesystem) if that feature is enabled

To explore the system without field equipment, give objects
[emulation]({{ '/en/architecture/' | relative_url }}#emulation).

For project engineering details, see [Development]({{ '/en/development/' | relative_url }}).

## Start the Server

On Windows, the process services start automatically with the operating
system; a user sign-in is not required. In a distributed installation keep
the order: `scada-config`; then `scada-historian`, `scada-filesystem` and the
protocol processes; then `scada-proxy`.

As an alternative, a process can be started in
[console mode]({{ '/en/server/' | relative_url }}#console).

## Client login

Start the Client from the desktop shortcut or the Start menu. The login dialog asks for SCADA credentials and, optionally, the target server name or IP address.

![]({{ '/img/client-login.png' | relative_url }})

For the first login, use `root` with the password set by
`security.rootPassword`.

Enter the host name or IP address of the process that accepts Client
connections (`scada-proxy` in a distributed installation) in the `Server`
field only if it runs on a different computer. Otherwise, leave the field
empty.

If the `Sign in automatically next time` box is ticked, the Client reuses the saved credentials on the next startup. To bypass automatic login, hold `Ctrl` while launching the Client.

## First steps after login

After you sign in:

1. Open the object panel with `More -> Objects`. The object tree
   shows the current values. Double-clicking an object opens its
   [Graph]({{ '/en/client/graph/' | relative_url }}).
1. Open available displays from the
   [Display]({{ '/en/client/display/' | relative_url }}) menu.
1. Check equipment status with `More -> Equipment`.
1. Create user accounts with `More -> Users`, and work under them rather
   than as `root`. See
   [User configuration]({{ '/en/dev/users/' | relative_url }}).

For the main operator interface, continue with
[Client]({{ '/en/client/' | relative_url }}).

## Upgrading

Before upgrading, back up the configuration and historical databases — see
[Backup]({{ '/en/server/' | relative_url }}#backup).

## Troubleshooting

<dl>

<dt>Client cannot connect to the Server</dt>
<dd>Check that the service of the process accepting Client connections
(<em>Telecontrol SCADA Proxy</em> in a distributed installation) is running.
Also verify that port 2000 is allowed by the firewall and reachable over
the network.</dd>

<dt>A Server process stops right after starting</dt>
<dd>There is no valid license file, or the license does not include this
process. The reason is written to the process log. See
<a href="{{ '/en/server/' | relative_url }}#licensing">Licensing</a>.</dd>

<dt>A process runs but refuses requests</dt>
<dd>The license is not verified or has expired. Outside Google Cloud, check
that <code>"license": {"require_gcp_binding": false}</code> is set; for an
expired license, replace the file — no restart is needed.</dd>

<dt>Schematics do not open</dt>
<dd>Install ActiveXeme or enable the built-in schematic renderer from
the settings menu.</dd>

<dt>Object values are shown in gray</dt>
<dd>The device is unavailable or the data is invalid. Check the device
state in the equipment panel.</dd>

</dl>
