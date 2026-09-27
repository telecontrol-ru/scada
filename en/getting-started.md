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

One installer carries every Server process and the `scada-setup` tool. Which
processes run is decided by the license.

1. Install the package:

   ```bat
   msiexec /i telecontrol-scada-<version>.msi /qn
   ```

2. Put the license file at
   `%ProgramData%\Telecontrol\SCADA Server\license.json`.

3. From an elevated command prompt, run:

   ```bat
   "C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" apply --svc-password <password>
   ```

   `<password>` is the password of the `svc` service account the processes
   use to connect to each other. It must be the same on every computer of the
   site.

`apply` enables every process the license entitles (narrow it with
`--tiers`), writes each one's parameter file
`%ProgramData%\Telecontrol\SCADA Server\<process>\server.json` (the
folder of `scada-filesystem` is named `filestore`), creates the
configuration databases (never overwriting an existing one), registers one
Windows service per process, and starts them in the right order. To check the
result:

```bat
scada-setup status
```

**Several computers.** Set up the central computer first, then the computers
running protocol processes, giving them the central computer's address:

```bat
rem Central computer:
scada-setup apply --tiers config,historian,filesystem,proxy --svc-password <password>
rem Computer near the equipment:
scada-setup apply --tiers modbus,iec104 --central 10.0.0.10 --svc-password <password>
```

The remaining links between processes are set up automatically. All
`scada-setup` commands are described in the
[Server]({{ '/en/server/' | relative_url }}#scada-setup) section.

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

The Server processes run on Linux, but `scada-setup` registers no services
there: start the executables of the processes you need, each with its own
parameter file (see [Linux deployment]({{ '/en/server/' | relative_url }}#linux)).
Container deployments use a single Docker image.

The graphical Client is not supported on Linux.

## License

The license is a signed `license.json` file listing the processes purchased.
The same file goes on every computer of the site. A process the license does
not name stops right after it starts. To add a process, replace the file with
the new license on every computer — running processes pick it up without a
restart — and run `scada-setup apply`.

Parameter files written by `scada-setup` already contain
`"license": {"require_gcp_binding": false}`. **If you write a parameter file by
hand and the Server does not run on Google Cloud, set it yourself** —
otherwise the process cannot verify its license and serves no requests. See
[Licensing]({{ '/en/server/' | relative_url }}#licensing).

## Root password

The built-in `root` account has all rights. While no password is set for it,
a process accepts `root` with an empty password.

**WARNING: `scada-setup` does not set a root password.** Each process that
keeps the configuration in its own database — `scada-config`, `scada-proxy`,
`scada-historian` and `scada-filesystem` — has its own `root` account, and
after `apply` all of them accept an empty password. Right after installation,
add to the parameter file of each of those processes
(`%ProgramData%\Telecontrol\SCADA Server\<process>\server.json`, where
`<process>` is `config`, `proxy`, `historian` and `filestore`):

```json
"security": {
    "rootPassword": "<password>"
}
```

and restart the processes (`scada-setup stop`, then `scada-setup start`).
**Repeat this after every `scada-setup apply`**, which rewrites the parameter
files from the templates. Restrict access to these files: the password is
stored in them as plain text. See
[Root password]({{ '/en/server/' | relative_url }}#root-password).

## Network preparation

Clients connect to the `scada-proxy` process: open inbound TCP port 2000 on
its computer (and 4840 for external OPC UA clients). In a distributed
installation the process ports must also be open between the site's
computers:

| Process | OPC UA | Clients |
|---|:-:|:-:|
| `scada-proxy` | 4840 | 2000 |
| `scada-config` | 4841 | 2001 |
| `scada-historian` | 4842 | 2002 |
| `scada-modbus` | 4843 | 2003 |
| `scada-iec104` | 4844 | 2004 |
| `scada-iec61850` | 4845 | 2005 |
| `scada-filesystem` | 4846 | 2006 |
| `scada-opc` | 4847 | 2007 |
| `scada-vidicon` | 4848 | 2008 |

`scada-setup` does not create firewall rules — open the ports by hand. Open
the OPC UA ports to the site's computers only.

## Initial project setup

For a real project:

* put the `scada-config` configuration database in
  `%ProgramData%\Telecontrol\SCADA Server\config\Configuration` (or, for a
  hand-written setup, the directory named by `configuration.dir`)
* copy schematic files (`.sde`) to `%ProgramData%\Telecontrol\SCADA Client` on each workstation, or upload them to the [server-side file system]({{ '/en/server/' | relative_url }}#filesystem) if that feature is enabled

To explore the system without field equipment, give objects
[emulation]({{ '/en/architecture/' | relative_url }}#emulation).

For project engineering details, see [Development]({{ '/en/development/' | relative_url }}).

## Start the Server

The process services start automatically with Windows; a user sign-in is not
required. `scada-setup start` and `scada-setup stop` start or stop all of the
computer's processes in the right order.

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

These steps upgrade version 2.6 and later. A version 2.5 or earlier Server
was a single process with a single service, and its data has to be moved into
the version 2.6 processes — see [below](#upgrade-2-5).

Before upgrading, back up the configuration and historical databases — see
[Backup]({{ '/en/server/' | relative_url }}#backup). Then, on each computer:

```bat
scada-setup stop
msiexec /i telecontrol-scada-<new version>.msi /qn
scada-setup apply --svc-password <password>
```

The installer replaces only the executables; `apply` rewrites the parameter
files and leaves the data alone. After `apply`, set the
[root password](#root-password) again.

### Upgrading from version 2.5 {#upgrade-2-5}

A version 2.5 Server ran as a single *Telecontrol SCADA Server* service and
used a hardware key. To move to version 2.6, on the computer where it ran:

1. Obtain a version 2.6 license and put it at
   `%ProgramData%\Telecontrol\SCADA Server\license.json`.
2. Back up the `%ProgramData%\Telecontrol\SCADA Server` folder.
3. Install the version 2.6 package
   (`msiexec /i telecontrol-scada-<version>.msi /qn`).
4. Run `scada-setup migrate` and read the plan: what will be copied where,
   and anything that prevents the migration. The command changes nothing.
5. From an elevated command prompt, run
   `scada-setup migrate --execute --svc-password <password>`. It removes the
   old service, copies the configuration, the users with their passwords, the
   history and the schematic files into the version 2.6 process folders, and
   starts the processes as `apply` does.
6. Set the [root password](#root-password) and check the result from the
   Client.

The old `Configuration`, `History` and `FileSystem` folders are neither
changed nor deleted. See
[Upgrading from version 2.5]({{ '/en/server/' | relative_url }}#upgrade-2-5)
for the details.

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
