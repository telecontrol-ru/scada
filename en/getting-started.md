---
title: Getting started
nav_order: 2
permalink: /en/getting-started/
---

# Getting started
{:.no_toc}

* TOC
{:toc}

## System requirements

* Windows 10 or newer for the Server and graphical Client, or Linux for the Server only
* TCP/IP connectivity between clients and the server, using port 2000 by default
* A HASP or Guardant hardware key for production server operation
* The [ActiveXeme](http://swman.ru/content/blogcategory/21/49/) component for Modus schematic rendering in the graphical client, if that display mode is used

## Installation

The Windows distribution installs two main components: the Server and
the graphical Client. The Server is typically installed on the server
host, while the Client can be installed on one or more operator
workstations. Both components may also be installed on the same
computer for a demo or compact deployment.

On Windows, the Server runs as the `Telecontrol SCADA Server` service so
data acquisition can start before a user signs in.

Depending on the selected components, the installer also creates a
`Telecontrol SCADA` program group in the Start menu with shortcuts for
`Server (console)` and `Client`, and the same shortcuts are placed on
the desktop.

### Install ActiveXeme

The graphical Client uses the
[ActiveXeme](http://swman.ru/content/blogcategory/21/49/) component to
render electronic schematics. It can be downloaded from the Modus
vendor site.

ActiveXeme is optional because the Client also supports built-in
schematic rendering through the `Settings -> Built-in Modus rendering`
option.

### Connect the hardware key

Production Server operation requires a HASP or Guardant hardware key.
The HASP and Guardant drivers can be downloaded from the vendors'
support sites.

Without the key, the Server runs in demo mode and stops two hours after
startup. After connecting the key, restart the Server.

## Installation on Linux

Only the Server component is supported on Linux. Unpack the server
distribution archive and follow the included instructions.

Linux workstations should use the
[Web interface]({{ '/en/client/web/' | relative_url }}) for operator
access.

## Network preparation

If the server host is protected by Windows Firewall or another network
filtering product, allow incoming TCP connections on port `2000`.
Client workstations must be able to open outgoing TCP connections to the
Server.

The port can be changed in the Server
[configuration]({{ '/en/server/' | relative_url }}#parameters).

## Initial project setup

On first start, the Server creates a demo configuration with simulated objects so the system can be explored without connecting real field equipment.

For a real project:

* copy the server configuration to `%ProgramData%\Telecontrol\SCADA Server\Configuration`
* copy schematic files (`.sde`) to `%ProgramData%\Telecontrol\SCADA Client` on each workstation, or upload them to the [server-side file system]({{ '/en/server/' | relative_url }}#filesystem) if that feature is enabled

For project engineering details, see [Development]({{ '/en/development/' | relative_url }}).

## Start the Server

On Windows, the Server starts automatically together with the operating
system. A user sign-in is not required.

As an alternative, the Server can be started in
[console mode]({{ '/en/server/' | relative_url }}#console).

Additional settings can be configured in the Server
[parameter reference]({{ '/en/server/' | relative_url }}#parameters).

## Client login

Start the Client from the desktop shortcut or the Start menu. The login dialog asks for SCADA credentials and, optionally, the target server name or IP address.

![]({{ '/img/client-login.png' | relative_url }})

For the first login to a demo installation, use the `root` user with an empty password.

Enter the Server host name or IP address in the `Server` field only if
the Server is installed on a different computer. Otherwise, leave the
field empty.

If the `Automatic login` option is enabled, the Client reuses the saved credentials on the next startup. To bypass automatic login, hold `Ctrl` while launching the Client.

## First steps after login

After you sign in:

1. Open the object panel with `Further -> Objects`. The object tree
   shows the current values. Double-clicking an object opens its
   [Graph]({{ '/en/client/graph/' | relative_url }}).
1. Open available displays from the
   [Display]({{ '/en/client/display/' | relative_url }}) menu.
1. Check equipment status with `Further -> Equipment`.
1. Create user accounts with `Further -> Users` and assign a secure
   password to the `root` administrator account. See
   [User configuration]({{ '/en/dev/users/' | relative_url }}).

For the main operator interface, continue with
[Client]({{ '/en/client/' | relative_url }}).

## Upgrading

To upgrade Telecontrol SCADA, install the new version over the existing
one. Configuration, historical data, and schematic files are preserved.

Before upgrading, it is still recommended to back up
`%ProgramData%\Telecontrol\SCADA Server`.

## Troubleshooting

<dl>

<dt>Client cannot connect to the Server</dt>
<dd>Check that the <em>Telecontrol SCADA Server</em> service is running.
Also verify that port 2000 is allowed by the firewall and reachable over
the network.</dd>

<dt>The Server stops after two hours</dt>
<dd>The hardware key is missing or not recognized. Connect the key and
restart the Server service.</dd>

<dt>Schematics do not open</dt>
<dd>Install ActiveXeme or enable the built-in schematic renderer from
the settings menu.</dd>

<dt>Object values are shown in gray</dt>
<dd>The device is unavailable or the data is invalid. Check the device
state in the equipment panel.</dd>

</dl>

## Translation status

This English page is now a functional onboarding reference. The Russian
page still contains fuller wording and a bit more procedural detail.
