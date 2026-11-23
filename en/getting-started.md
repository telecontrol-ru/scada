---
title: Getting started
nav_order: 2
permalink: /en/getting-started/
---

# Getting started
{:.no_toc}

* TOC
{:toc}

This page describes the version 2.6 Client and how to start working with the
SCADA Server.

{: .note }
> **The Server is provided only as a hosted service** run by Telecontrol: a
> Server to install on your own computers is no longer offered. What
> Telecontrol does and what you do is described on the
> [Server]({{ '/en/server/' | relative_url }}) page; existing Server 2.5.7
> installations are covered under
> [Server 2.5.7]({{ '/en/server/' | relative_url }}#legacy).

You install the Clients on the workstations (see
[Installing the Client](#client-install)) and, to reach the field devices,
the site gateway next to them (see
[Site gateway]({{ '/en/server/' | relative_url }}#gateway)). You set up the
project — objects, devices, schematics, users and roles — in the Client.

## System requirements

* Client: Windows 10 or newer (x64), or macOS on a computer with Apple
  silicon, macOS 26 or later (the release notes name the exact minimum; see [Installing the Client](#client-install)); there is no Linux
  Client
* Network access from the Client workstations to the Server address that
  Telecontrol gives you
* The site gateway has requirements of its own, see
  [Site gateway]({{ '/en/server/' | relative_url }}#gateway)

## Download {#download}

The Client packages are published on the
[Telecontrol SCADA releases page on GitHub](https://github.com/alexsmn/scada-client/releases). The version 2.6
Client packages are in release [2.6.8](https://github.com/alexsmn/scada-client/releases/tag/v2.6.8), which replaces releases 2.6.0, 2.6.3 and 2.6.4. The page marks
release 2.5.7 as the latest, because it is the last release that carries a
Server installer; that Server is no longer offered (see
[Server 2.5.7]({{ '/en/server/' | relative_url }}#legacy)).

Releases 2.6.0, 2.6.3, 2.6.4 and 2.6.8 carry only the Client packages (see
[Installing the Client](#client-install)). The Windows Client package
`telecontrol-scada-<version>.msi` (the Client, the Designer and the
documentation) will be added later. The display module is not part of the
releases and is supplied separately (see
[Displaying schematics](#displays)). There are no Server or site gateway
packages to download: Telecontrol supplies the gateway package with the
service.

**Do not use the 2.6.0 Client** — it also stores the remembered
automatic-login password unencrypted; use the 2.6.8 Client. At sites still
running a 2.5.7 Server, the 2.6.8 Client can be installed for evaluation;
what works in that combination and what does not is listed under
[Before upgrading from 2.5.7]({{ '/en/changes/' | relative_url }}#limits-upgrade).

### Getting the hosted Server {#buy-now}

To get the Server, contact Telecontrol (mail@telecontrol.ru). The service
terms, the region the Server is hosted in and the price are agreed in the
contract. Telecontrol installs, updates and licenses the Server, backs it up
and monitors it (see [Server]({{ '/en/server/' | relative_url }}#service)).

When you are connected, Telecontrol gives you:

* the Server address the Clients connect to;
* the SHA-256 fingerprint of the Server certificate, by which the Client
  checks the Server's identity (see [Checking the Server certificate](#server-certificate-check));
* the name and password of a named account, under which you sign in to the
  Client and set up users, roles and the project;
* to reach the field devices, the site gateway package with its parameter
  file, and the address the Server connects to the gateway from (see
  [Site gateway]({{ '/en/server/' | relative_url }}#gateway)).

What you do is listed under
[What the customer does]({{ '/en/server/' | relative_url }}#customer).
The display module is supplied separately; agree the terms of its supply
with Telecontrol.

Server features that need a Windows Server (the OPC DA client and the
Vidicon integration) are not available with the hosted Server (see
[Unavailable features]({{ '/en/server/' | relative_url }}#unavailable)).

## Installing the Client {#client-install}

The [releases page](#download) carries two Client packages of the same
version with every version 2.6 release:

* **`Telecontrol-SCADA-Client-<version>-windows-x64.zip`** — for Windows 10
  or newer. Unzip it into any folder and run `client.exe`. The program is not
  code-signed, so Windows SmartScreen may warn about it on first launch:
  choose *More info* → *Run anyway*.
* **`Telecontrol-SCADA-Client-<version>-macos-arm64.dmg`** — for macOS on a
  computer with Apple silicon, macOS 26 or later (the release notes name the
  exact minimum). Open the disk image and
  drag *Telecontrol SCADA Client* to *Applications*. The release notes say
  whether the app is signed and notarised by Apple; the release 2.6.8
  package is neither. If it is not notarised, macOS refuses to open it the first time: after the
  refusal, open *System Settings → Privacy & Security* and click *Open
  Anyway*. To avoid doing that on every computer, run
  `xattr -dr com.apple.quarantine "/Applications/Telecontrol SCADA Client.app"`
  once in Terminal after copying the app.

**These packages do not include the display module yet** (see
[Displaying schematics](#displays)). A workstation needs no license file.

On Windows the Client can also be installed with the
`telecontrol-scada-<version>.msi` package, which carries the Windows Client,
the [Designer]({{ '/en/dev/designer/' | relative_url }}) (an editor for Vidicon schematics) and the documentation. The package creates *Клиент* (Client) and
*Дизайнер* (Designer) shortcuts on the desktop and in the
*Start — ОИК Телеконтроль* menu, and appears in *Control Panel — Programs and
Features* as *ОИК Телеконтроль*. It is not published for version 2.6 yet (see
[Download](#download)), so for now the Client is installed from the archive or
the disk image. Once the package is published, install it with:

```bat
msiexec /i telecontrol-scada-<version>.msi /qn /norestart /l*v install.log
```

**WARNING:** on a computer with a 2.5.7 Server installed, the version 2.6
Client package removes the version 2.5 program together with the Server
service. Do not install it on such a computer until the move to the hosted
Server has been arranged with Telecontrol (see
[Server 2.5.7]({{ '/en/server/' | relative_url }}#legacy)). If Telecontrol
has given you some other separate package, check with Telecontrol
(mail@telecontrol.ru) how to install it next to
`telecontrol-scada-<version>.msi`: they all install into the same
`C:\Program Files\Telecontrol SCADA` folder, and installing them together
that way has not been verified.

### Displaying schematics {#displays}

The version 2.6 Client renders Modus schematics (`.sde` and `.xsde` files)
and Vidicon schematics (`.vds` files) with live values itself, through a
display module that has to be in the Client's folder, beside its executable.
The ActiveXeme component is not used by the version 2.6 Client.

**The Client packages do not include the display module yet**: its licence
terms are not settled, and the module is supplied separately — contact
Telecontrol. Until it is there, a display window shows the message "No
display runtime is installed." with the reason; the Client's other windows
work. Editing Modus schematics still needs the Modus graphics editor.

## Preparing the project {#project}

**Unless agreed otherwise, the Server starts with an empty project:** no
objects, devices or links. Sign in to the Client with the account
Telecontrol gave you (see [Client login](#client-start)) and build the
project's configuration in the Client (see
[Development]({{ '/en/development/' | relative_url }})).

The configuration is kept on the Server in one copy. A configuration change
made in the Client — creating, renaming and deleting objects, devices and
users, and assigning roles — takes effect across the Server at once and is
seen by every Client. The Server reaches the site's devices through the site
gateway (see [Site gateway]({{ '/en/server/' | relative_url }}#gateway)):
until the gateway is installed and connected, the devices stay without a
connection in the Client.

On each workstation, copy the schematic files (`.sde`) to
`%ProgramData%\Telecontrol\SCADA Client`, or upload them to the Server in
the *Files* window (see [Server files]({{ '/en/dev/server-files/' | relative_url }})).

To explore the system without field equipment, give your project's objects
[emulation]({{ '/en/architecture/' | relative_url }}#emulation), or arrange
the [demo project](#demo) with Telecontrol.

For project engineering details, see [Development]({{ '/en/development/' | relative_url }}).

### Demo project {#demo}

A Server with the demo project instead of an empty one is started by
arrangement with Telecontrol. The demo project has 41 analog and 52 discrete
objects, emulated signals, two archives, demo schematics in the server files,
and the users "Клиент 1" … "Клиент 10" and `guest`, **with no passwords
set**.

**WARNING:** the hosted Server is reachable over the network, and anyone who
knows its address can sign in as a demo user without a password. Right after
the first sign-in, set passwords for those users or delete them (see
[User configuration]({{ '/en/dev/users/' | relative_url }})). The `root` user
in the demo project's user list can never sign in; do not change or delete
it.

To move from the demo project to your own, delete the demo devices, objects,
schematics and users in the Client (the change takes effect on the Server at
once), or arrange with Telecontrol to replace the configuration with an
empty one. Then check that "Клиент 1" can no longer sign in.

### A ready project database {#project-db}

A ready project configuration database (a version 2.6
`configuration.sqlite3`), for example one prepared at another site, is put
on the Server by Telecontrol: arrange it with Telecontrol. Note that **the
project user with ID 100 is replaced by the `svc` service account**, through
which the Server processes connect to each other.

Moving a 2.5.7 Server's configuration to the hosted Server is also arranged
with Telecontrol (see [Server 2.5.7]({{ '/en/server/' | relative_url }}#legacy)).

## Client login {#client-start}

Run `client.exe` from the folder the Client archive was unpacked into, or on
macOS *Telecontrol SCADA Client* from *Applications*. The desktop and Start
menu shortcuts are created only by the Client package
`telecontrol-scada-<version>.msi`, which is not published for version 2.6 yet. The login dialog asks for SCADA credentials to connect to the Server:

![]({{ '/img/client-login.png' | relative_url }})

The `Server` row has two fields. On the left is the list of server types
(shown only when the Client supports more than one type; otherwise a
"Connecting to: …" line under the fields names that type): choose
**"OPC UA"**. On the right, enter the Server address exactly as Telecontrol
gave it to you.

Expand the "Security and certificates" section and choose the
**"Sign and encrypt"** security mode (or "Most secure available"). In these
modes the connection is encrypted and the Client checks the Server's
identity (below).

Sign in with the named account whose name and password Telecontrol gave you.
You create the accounts for everyone else yourself (see
[First steps after login](#first-steps)).

With the "OPC UA" server type the user profile — pages, portfolios and
workstation settings — is kept only on this computer and does not follow the
account to another computer (see
[Shift change]({{ '/en/client/' | relative_url }}#shift-change)). After the
connection is lost the Client reconnects by itself (see
[Connection to the Server]({{ '/en/client/' | relative_url }}#connection)).

In the "Most secure available" and "Sign and encrypt" modes the Client checks
the Server's identity by its certificate:
{: #server-certificate-check}

* The Client's own certificate and private key are optional: if the fields are
  empty, the Client creates its own certificate on the first connection.
* The first time it meets a Server's certificate, the Client asks: "The server
  presented a certificate this computer has not trusted before", and shows its
  subject and SHA-256 fingerprint. Compare the fingerprint with the one
  Telecontrol gave you, and answer *Yes* only if they match: the Client then
  trusts the certificate and connects.
* If the server at the same address presents a *different* certificate, the
  Client warns: "WARNING: the server at this address presented a DIFFERENT
  certificate…". That is what an intercepted connection would look like: trust
  the new certificate only if Telecontrol confirms it was replaced and gives
  you the new fingerprint.

The certificates are kept in the `pki` folder of the Client's user data:
`%APPDATA%\Telecontrol\SCADA Client\pki` on Windows and
`~/Library/Application Support/Telecontrol/SCADA Client/pki` on macOS. To stop
trusting a Server, delete its certificate from the `trusted` subfolder.

If the `Sign in automatically next time` box is ticked, the Client stores the
name and password on this computer and does not wait for input in the
sign-in window at each start: it signs the last account straight in. The
sign-in window opened by *Disconnect from Server* and *Connect to Server...*
always waits for input.

> **Caution.** Do not tick this box on a shared operator workstation: at start
> the Client would sign in under the outgoing operator's account. To sign in
> under your own and clear the box, hold `Ctrl` (on macOS, `Option`) while
> starting the Client — the sign-in window opens with the box cleared — and
> sign in. You can also press *Cancel* while automatic sign-in is in progress
> (see [Automatic sign-in]({{ '/en/client/' | relative_url }}#auto-login)).

## First steps after login {#first-steps}

**A new project is empty:** the objects and equipment panels show nothing
until you build the configuration (see [Preparing the project](#project)).
If the Server was started with the demo project, you see the
[demo project](#demo).

After you sign in:

1. Open the object panel with `More -> Items`. The object tree
   shows the current values. Double-clicking an object opens its
   [Graph]({{ '/en/client/graph/' | relative_url }}).
1. Open available displays from the
   [Display]({{ '/en/client/display/' | relative_url }}) menu.
1. Check equipment status with `More -> Hardware`. The icons to the left of
   the devices show the connection state.
1. Create user accounts with `More -> Users`, and work under them, keeping
   the account Telecontrol gave you for administration. See
   [User configuration]({{ '/en/dev/users/' | relative_url }}). After
   creating a user and setting a password, check that you can sign in as
   that user.

   An account's rights come only from its **roles**: a new account can only
   view data until it is given roles. Assign them with `Roles...` from the
   user's context menu: `Operator` for control, `ConfigureAdmin` for
   configuration (see
   [Access rights]({{ '/en/dev/users/' | relative_url }}#access-rights)).

   The user list contains the `svc` service account: the Server processes
   connect to each other through it, and the server does not let the Client
   change it. Telecontrol manages it.

For the main operator interface, continue with
[Client]({{ '/en/client/' | relative_url }}).

## Upgrading the Client {#client-upgrade}

Telecontrol upgrades the Server. **On the operator workstations** install
the new Client version the same
way as the old one (see [Installing the Client](#client-install)): unpack
the new archive or disk image in place of the old one, or install the new
package. The display module is not part of the
Client packages, and replacing the program deletes it with the old
folder: **before** replacing it, copy the module somewhere safe
(`display_runtime.dll` beside `client.exe`; on macOS
`libdisplay_runtime.dylib` in the app's *Contents/Frameworks* folder), and
afterwards put it in the same place in the new Client. Otherwise the
schematic windows show "No display runtime is installed".

A workstation whose Client was installed with the
`telecontrol-scada-<version>.msi` package (not yet published for version 2.6)
is upgraded with:

```bat
msiexec /i telecontrol-scada-<new version>.msi /qn /norestart /l*v install.log
```

## Uninstalling the Client {#uninstall}

A Client unpacked from the archive or disk image is removed by deleting its
folder (on macOS, the app in *Applications*). A Client installed with the
`telecontrol-scada-<version>.msi` package is removed in *Control Panel —
Programs and Features* as the program *ОИК Телеконтроль*. The Client keeps
its settings and data elsewhere, and those stay behind:

* on Windows — the login settings in the registry key
  `HKEY_CURRENT_USER\Software\Telecontrol\Workplace`, the profile, the `pki`
  certificate folder and other per-user data in
  `%APPDATA%\Telecontrol\SCADA Client`, shared data in
  `%ProgramData%\Telecontrol\SCADA Client`, and logs in
  `%LOCALAPPDATA%\Telecontrol\SCADA Client\logs`;
* on macOS — the login settings in
  `~/Library/Application Support/Telecontrol/SCADA Client/settings.json`, data
  in the same folder, and logs in `~/Library/Logs/Telecontrol/SCADA Client`.

When automatic login was on, the user's password is kept encrypted in the
same registry key on Windows, and on macOS in the user's keychain, as the
item "Telecontrol SCADA Client", which deleting the folders does not touch.
A Client older than 2.6.3 kept it unencrypted — on Windows in the `Password`
value of the same registry key, on macOS in the `settings.json` file — and on
a workstation where the new Client has never started it is still there in
clear.
When a workstation is decommissioned, delete that registry key and those
folders — and on macOS that item in Keychain Access — for every user of the
computer.

## Troubleshooting

<dl>

<dt>Client cannot connect to the Server</dt>
<dd>Check that the "OPC UA" server type is chosen, the address is entered
exactly as Telecontrol gave it, and the security mode is "Sign and encrypt"
or "Most secure available". Check that the workstation's network (the
company firewall included) lets connections through to that address. If the
Client warns that the server presented a <em>different</em> certificate, do
not connect until Telecontrol confirms the replacement (see
<a href="#server-certificate-check">Checking the Server certificate</a>). If
nothing helps, contact Telecontrol (mail@telecontrol.ru).</dd>

<dt>Devices stay without a connection</dt>
<dd>The Server reaches the devices through the site gateway. Check that the
gateway is installed and running, that the gateway computer can connect to
the cloud address Telecontrol gave you, and that the devices are reachable
from the gateway computer (see
<a href="{{ '/en/server/' | relative_url }}#gateway">Site gateway</a>).</dd>

<dt>Schematics do not open</dt>
<dd>If the display window says "No display runtime is installed.", the
display module is missing from the Client's folder: the Client packages do
not include it yet — contact Telecontrol (see
<a href="#displays">Displaying schematics</a>).
Otherwise, check that the schematic file is in
<em>%ProgramData%\Telecontrol\SCADA Client</em> or in the
<a href="{{ '/en/dev/server-files/' | relative_url }}">server files</a>.</dd>

<dt>Object values are shown in gray</dt>
<dd>Gray value text means the value is not valid, for example because the
device is unreachable. Check the device state in the equipment panel
(<code>More -> Hardware</code>) and that the site gateway is running. A
blinking yellow row background means something else — the object has an
unacknowledged event.</dd>

</dl>
