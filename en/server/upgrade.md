---
title: Upgrade and removal
nav_order: 3
parent: Server
permalink: /en/server/upgrade/
---

# Upgrade and removal
{:.no_toc}

* TOC
{:toc}

## Upgrading from version 2.5 {#upgrade-2-5}

**WARNING:** the version 2.6 Server installer is not published yet
(see [Download]({{ '/en/getting-started/' | relative_url }}#download));
until it is, the upgrade cannot be carried out. The order below is how the
two version 2.6 packages are meant to be installed; it has not been run on
Windows yet. Before following it on a working site, check in the release
description or with Telecontrol (mail@telecontrol.ru) that it is confirmed.

Versions 2.5 and earlier installed a single process — the *Telecontrol SCADA
Server* service — and kept its data in the `Configuration`, `History` and
`FileSystem` folders inside `%ProgramData%\Telecontrol\SCADA Server`.
`scada-setup migrate` moves that data into the version 2.6 processes:

| Version 2.5 data | Copied to |
|---|---|
| Configuration `Configuration\configuration.sqlite3` | `config\Configuration` |
| User passwords `Configuration\password.dat` | The same folder, beside the configuration |
| History `History` | `historian\History` |
| Schematic files `FileSystem` | `filestore\FileSystem` |

All paths are relative to `%ProgramData%\Telecontrol\SCADA Server`; if the
version 2.5 `server.json` named other folders, the command takes them from
there. The configuration is copied to `scada-config` only: it hands it to
the protocol processes and to `scada-historian` (the historical databases
and object assignments), and `scada-proxy` reads Client user names and
passwords from it.

The configuration is not carried into `scada-filesystem`'s database
(`filestore\Configuration`): that process needs only the `svc` service
account, and `apply` keeps only that account in its database.

**The version 2.5 folders are only read**: the command changes and deletes
nothing in them. That matters, because on first start the 2.6 processes
convert their copies to the new format, which version 2.5 can no longer use.
Delete the old folders yourself once the upgraded system is known to work.

**Check the plan before installing version 2.6.** The migration removes the
version 2.5 service, and the version 2.6 Client package removes the 2.5
program itself, while what blocks the migration (see the list below) can only
be fixed in version 2.5. So check the plan first with the `scada-setup`
unpacked from the 2.6 Server package without installing it.

**Version 2.6 is installed with two packages, and their order matters.** The
Server package `scada-server-<version>.msi` (every Server process and
`scada-setup`) installs beside version 2.5 and removes nothing of it. The
Client package `telecontrol-scada-<version>.msi` (the Client and the
documentation) is an upgrade of the program release 2.5 installed: it
removes the version 2.5 program. So the Server package is installed and the
data migrated first (steps 5 and 6), and the Client package only after that
(step 7).

The steps, on the computer where the 2.5 Server ran, from an elevated
command prompt:

1. Obtain a version 2.6 license (a `license.json` file) from Telecontrol and
   put it at `%ProgramData%\Telecontrol\SCADA Server\license.json`. Version
   2.6 does not use the HASP or Guardant hardware key: Telecontrol exchanges
   it for a license — see [Exchanging the hardware key](#license-exchange).
2. Back up the whole `%ProgramData%\Telecontrol\SCADA Server` folder.
3. Unpack the version 2.6 Server package into a temporary folder — this **does not
   install it**, and the 2.5 Server keeps running — and find
   `scada-setup.exe` in it:

   ```bat
   msiexec /a scada-server-<version>.msi /qb TARGETDIR=C:\scada-2.6-setup
   dir /s /b C:\scada-2.6-setup\scada-setup.exe
   ```

4. See the migration plan with the unpacked program, giving the full path
   that `dir` printed and this computer's processes (the command changes
   nothing):

   ```bat
   "<path to the unpacked scada-setup.exe>" migrate --tiers config,historian,filesystem,iec104,proxy
   ```

   Besides `config`, `historian`, `filesystem` and `proxy`, give `--tiers`
   **a protocol process for every protocol** the version 2.5 devices use (in
   the example IEC 60870-5-104, `iec104`; `modbus` for MODBUS, `iec61850` for
   IEC 61850). When the version 2.5 configuration has enabled links or
   devices of a protocol whose process is not given, the plan warns with a
   line `WARNING: … will not run the '<process>' process`: the configuration
   is carried over, but no data is collected from those devices unless the
   process runs on another computer of the site.

   It lists what will be copied where, how much disk space that needs, which
   version 2.5 settings are not carried over and, under the heading
   `Cannot migrate`, anything that prevents the migration. Fix that in
   version 2.5 and run the command again until the list is empty. The
   `C:\scada-2.6-setup` folder can then be deleted.

   The check normally runs while the 2.5 Server is running. If the
   `Cannot migrate` list has the line `Can't read the 2.5 configuration
   database … stop the 2.5 service and run the migration again`, the running
   2.5 Server most likely kept the configuration database from being read:
   stop the *Telecontrol SCADA Server* service (Control Panel — Services), run
   the check again, then start the service again.
5. Stop the *Telecontrol SCADA Server* service (Control Panel — Services)
   and install the version 2.6 Server package:

   ```bat
   msiexec /i scada-server-<version>.msi /qn /norestart /l*v install.log
   ```

   The package installs into the same `C:\Program Files\Telecontrol SCADA`
   folder as version 2.5, which is why the version 2.5 service must be
   stopped meanwhile. The version 2.5 program and data stay where they are,
   and the service stays registered — the next step removes it.
6. Run the migration with the same `--tiers` as in step 4:

   ```bat
   "C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" migrate --execute --tiers config,historian,filesystem,iec104,proxy --svc-password <password> --root-password <root password>
   ```

   It checks the plan once more, stops and removes the *Telecontrol SCADA
   Server* service if it is still there, copies the data (the `Copied …`
   lines), and then runs `scada-setup apply`: it writes the parameter files,
   creates the [Server certificate]({{ '/en/server/opcua/' | relative_url }}#opcua-certificate) if there is none yet,
   and registers and starts the process services. User passwords are carried
   over, while the version 2.5 root password — whether set with
   `security.rootPassword` or changed from the Client — is replaced on the
   2.6 processes' first start by the [root password]({{ '/en/server/security/' | relative_url }}#root-password) given as
   `--root-password`.
7. **Only after step 6**, install the version 2.6 Client package on this
   same computer:

   ```bat
   msiexec /i telecontrol-scada-<version>.msi /qn /norestart /l*v install.log
   ```

   It removes the version 2.5 program (the version 2.5 *ОИК Телеконтроль*
   program disappears from *Programs and Features*) and installs the 2.6
   Client. If this computer does not need the Client, delete the *Клиент*
   (Client) shortcut from the desktop, but do install the package: otherwise
   the version 2.5 program stays installed. Then check the services:
   `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" status`. If a
   process does not start and its log says a file was not found, repair the
   Server package with `msiexec /fa scada-server-<version>.msi` and run
   `status` again.
8. Install the version 2.6 Client on **every** workstation: the 2.6 Client
   displays schematics with its own display module (see
   [Displaying schematics]({{ '/en/getting-started/' | relative_url }}#displays)).
   Whether a version 2.5 Client works with a 2.6 Server has not been
   verified.
9. Connect a Client (port 2000, as before) as a user and check the objects,
   the history and the schematics.

**If `migrate --execute` fails:**

* **after copying all the data** (the output has a `Copied` line for every
  line of the plan) — do not run `migrate` again: it would refuse, because
  the destination folders now exist. Fix the cause of the error and finish
  with `apply` with the same `--tiers` and passwords;
* **part-way through copying** — delete the `config`, `proxy`, `historian`
  and `filestore` folders it created in
  `%ProgramData%\Telecontrol\SCADA Server` (leave the version 2.5
  `Configuration`, `History` and `FileSystem` folders alone) and run
  `migrate --execute` again.

The migration does not start, and the command says why, when:

* the version 2.5 configuration is not stored in SQLite (for example, it is in
  PostgreSQL) — move it to SQLite with the version 2.5 administration utility
  (available from Telecontrol);
* a version 2.5 user has the id 100, which the `svc` service account takes.
  Create the same user in version 2.5 under another name, delete the old one,
  and check again;
* the version 2.5 configuration database cannot be read
  (`Can't read the 2.5 configuration database …`) — stop the version 2.5
  *Telecontrol SCADA Server* service and run the command again;
* `config` is not selected on this computer;
* the data has already been moved (the destination folders exist — the
  command never overwrites them);
* there is not enough disk space.

`--from <folder>` (the folder holding the version 2.5 `server.json`, when it
is not `%ProgramData%\Telecontrol\SCADA Server`) and `--from-exe-dir <folder>`
(the version 2.5 program folder — needed only when `server.json` named no data
folder and the data sat beside the program) are rarely needed.

If version 2.5 had the OPC client or the Vidicon integration enabled, in
version 2.6 these are the separate `scada-opc` and `scada-vidicon` processes,
and the license must include them. `migrate` says so in its list of settings
not carried over.

### Exchanging the hardware key {#license-exchange}

Version 2.6 does not read the Guardant or HASP key; Telecontrol exchanges it
for a signed license. The migration plan (step 4) needs no license, and its
notes end with a request line such as:

```text
TIERS=config,historian,filesystem,iec104,proxy
```

Send that line to Telecontrol together with the hardware key's serial number,
and you receive a long-dated `license.json` naming those processes. The line
lists everything the version 2.5 Server ran — `config`, `historian` and
`proxy`, `filesystem` if the file store was enabled, the process for every
protocol the version 2.5 devices use, and `opc` and `vidicon` if the OPC client
or the Vidicon integration was enabled — plus every process given to
`--tiers`. One license covers every computer of the site, so the line names
the site's processes, not only this computer's.

## Rolling back to version 2.5 {#rollback-2-5}

If the 2.6 Server does not work after the migration (for example, its
services do not start), version 2.5 can be brought back, but not by
installing over it: **the 2.5.7 installer refuses to install while a newer
version of the Client package is installed** (the message `A later version of ОИК Телеконтроль is
already installed`), and the version 2.5 *Telecontrol SCADA
Server* service has already been removed by `migrate --execute`. On the same
computer, from an elevated command prompt:

1. Uninstall both version 2.6 packages in *Control Panel — Programs and
   Features* (publisher of both: ООО Телеконтроль): first the *ОИК Телеконтроль — Сервер*
   program, then the version 2.6 *ОИК Телеконтроль* program. The
   same from the command line:

   ```bat
   msiexec /x scada-server-<version>.msi /qn /norestart /l*v uninstall-server.log
   msiexec /x telecontrol-scada-<version>.msi /qn /norestart /l*v uninstall-client.log
   ```

   `msiexec /x` needs the file of the very package that is installed; if
   you do not have it, uninstall from the Control Panel. The Server package
   itself stops and removes the version 2.6 services, and leaves the data in
   `%ProgramData%\Telecontrol\SCADA Server` (see
   [Uninstalling the Server](#uninstall)).

   If the migration stopped before step 7 and the version 2.5
   *ОИК Телеконтроль* program is still in the list, uninstall only the
   *ОИК Телеконтроль — Сервер* package, and before going further ask Telecontrol
   (mail@telecontrol.ru) for the rollback procedure: that rollback has not
   been verified.
2. Install release 2.5.7 (`telecontrol-scada-2.5.7.msi` from the
   [releases page](https://github.com/alexsmn/scada-client/releases)) the
   way you installed version 2.5, and attach the HASP or Guardant hardware
   key.
3. On **every workstation** that got the version 2.6 package in the
   migration (step 8 above): uninstall the *ОИК Телеконтроль* program in
   *Control Panel — Programs and Features* and install the release 2.5.7
   Client the way it was installed before. The 2.5.7 installer refuses to
   install over version 2.6 on a workstation too.
4. Check that the *Telecontrol SCADA Server* service is running, and connect
   with a version 2.5 Client.

`migrate` did not change the version 2.5 `Configuration`, `History` and
`FileSystem` folders, so the 2.5 Server resumes with the data as it was at
the migration: configuration changes and archives recorded by version 2.6 are
not carried back. If the version 2.5 folders have already been deleted,
restore them from the backup made before the migration. The 2.6 process
folders (`config`, `proxy`, `historian`, `filestore` and so on) and the 2.6
license file `license.json` are not needed by version 2.5; delete them once
you are sure you will not need them.

## Rolling back a failed upgrade {#rollback-upgrade}

The same applies to an upgrade within version 2.6 (to a newer 2.6.x): the
installer refuses to install an older version over a newer one (the message
`A later version of ОИК Телеконтроль — Сервер is already installed`), and restoring a
backup [on the same computer]({{ '/en/server/backup/' | relative_url }}#restore) only puts the data back under the
version that is installed now. **So back up every Server computer before every
upgrade**: without that backup there is no way back.

To go back to the previous version, on each Server computer the upgrade
reached, from an elevated command prompt:

1. Stop the processes:
   `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop`.
2. Uninstall the newer version of the Server package: the *ОИК Телеконтроль — Сервер*
   program (publisher ООО Телеконтроль) in *Control Panel — Programs and
   Features*. The Server package removes the
   services and the Server certificate from the
   `C:\Program Files\Telecontrol SCADA\data\Certificates` folder (see
   [Uninstalling the Server](#uninstall)); the data folder and the site
   certificate authority stay. `apply`
   creates the services again in step 5, and the certificate comes back from
   the backup in step 4.
3. Install the older version's Server package:

   ```bat
   msiexec /i scada-server-<older version>.msi /qn /norestart /l*v install.log
   ```

4. Put back, from the backup taken **before the upgrade**, the data folder
   (`%ProgramData%\Telecontrol\SCADA Server`, or the folder given as
   `--data-root`), replacing what is there, and the
   `C:\Program Files\Telecontrol SCADA\data\Certificates` folder. The
   restored key file takes the folder's permissions, so restrict access to it:

   ```bat
   icacls "C:\Program Files\Telecontrol SCADA\data\Certificates\ServerPrivateKey.pem" /inheritance:r /grant:r *S-1-5-18:F *S-1-5-32-544:F
   ```

   If the backup has no `Certificates` folder, `apply` creates a new certificate, and OPC UA
   clients that trusted the old one must be made to trust the new one. Do not keep the data the newer version worked with: whether a newer
   version changes the databases when it first starts has not been verified,
   so only the pre-upgrade backup is known to suit the older version.
5. Run `scada-setup apply` with the
   [computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options) and the same `svc` and
   `root` passwords.
6. Check the result: `scada-setup status`, then sign in from a Client.

**On Linux** the steps are the same, with the commands run through `sudo`.
There is no need to remove the newer version first: stop the processes
(`sudo /opt/telecontrol-scada/bin/scada-setup stop`) and install the older
package over the newer one:

```sh
sudo apt install --allow-downgrades ./telecontrol-scada-server_<older version>_amd64.deb
```

For an archive installation, unpack the older archive with the same
`tar -xzf … -C /opt` command. Then put back, from the backup, the data folder
(`/var/lib/scada`, or the folder given as `--data-root`) and the
`/opt/telecontrol-scada/data/Certificates` folder, and do steps 5 and 6; the
`icacls` step is not needed.

Changes made to the configuration and values archived after the backup are
lost. If the workstations, or the Client package on a Server computer, were
upgraded too, uninstall the newer Client package (*ОИК Телеконтроль*) there in
the same way and install the older one (with no `scada-setup` commands).

## Uninstalling the Server {#uninstall}

**The Server package removes the services itself.** Before it deletes the
program's files, it runs `scada-setup remove`: it stops and removes the
services of every process together with their registry settings. It then deletes
this computer's [Server certificate]({{ '/en/server/opcua/' | relative_url }}#opcua-certificate) and its private key
from the `C:\Program Files\Telecontrol SCADA\data\Certificates` folder —
the `ServerCertificate.pem` and `ServerPrivateKey.pem` files and the copies
`apply` set aside. **The site certificate authority** — the `ca` subfolder
on the central computer — **stays**: after a reinstall `apply` goes on using
it, and the other computers' certificates stay valid. `apply` creates the
central computer's own certificate anew, though, with a different
fingerprint. The other computers recognise it by the certificate authority,
so nothing needs changing on them; the new fingerprint is needed only to join
new computers (see
[The central computer's fingerprint changed]({{ '/en/server/opcua/' | relative_url }}#central-fingerprint-changed)).
The processes'
data in `%ProgramData%\Telecontrol\SCADA Server` (configuration, users,
archives, files, the license, the [password file]({{ '/en/server/setup/' | relative_url }}#stored-passwords)) stays. If `scada-setup remove` fails, the
uninstall is cancelled and the program stays installed: services are never
left without their programs.

On every Server computer:

1. [Back up]({{ '/en/server/backup/' | relative_url }}) if you may need the data or the certificate. For OPC UA
   clients to keep trusting the Server after a reinstall, save the
   `data\Certificates` folder and put it back before `apply`, or uninstall
   with the `SCADA_KEEP_CERTIFICATES=1` parameter (step 2), with which the
   Server package deletes nothing from the folder.

   **If the computer leaves the site for good**, uninstall with the
   `SCADA_PURGE_CERTIFICATES=1` parameter: the whole `data\Certificates`
   folder is then deleted, on the central computer together with the site
   certificate authority (the `ca` subfolder with the `ca_key.pem` key). On
   the central computer do this only when the site is no longer needed:
   after a reinstall `apply` creates a new certificate authority, and every
   other computer of the site has to join again (see
   [A new certificate authority]({{ '/en/server/opcua/' | relative_url }}#opcua-renewal)).
2. Uninstall the Server package: the *ОИК Телеконтроль — Сервер* program (publisher
   ООО Телеконтроль) in *Control Panel — Programs and Features*, or from an
   elevated command prompt:

   ```bat
   msiexec /x scada-server-<version>.msi /qn /norestart /l*v uninstall.log
   ```

   `msiexec /x` needs the file of the very package that is installed; if
   you do not have it, uninstall from the Control Panel. A Client installed
   on this computer with the `telecontrol-scada-<version>.msi` package stays;
   if it is no longer needed, uninstall it too — the *ОИК Телеконтроль*
   program.

   If the uninstall is cancelled with an error, look for the
   `ScadaSetupRemoveServices` action in `uninstall.log`, and check the
   services with
   `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" status`.
   If `scada-setup` itself does not start, remove the services with the
   Windows tools and uninstall with the `SCADA_KEEP_SERVICES=1` parameter,
   which skips that step:
   `msiexec /x scada-server-<version>.msi SCADA_KEEP_SERVICES=1 /l*v uninstall.log`.
3. If the data is no longer needed, delete the
   `%ProgramData%\Telecontrol\SCADA Server` folder — the processes' data, the
   license file and, if a migration from version 2.5 was done, the
   version 2.5 folders. The `C:\Program Files\Telecontrol SCADA` folder stays
   after the uninstall: it holds the `data\Certificates` folder with the site
   certificate authority (on the central computer) and the certificates the
   processes trust. Delete it as a whole only when the computer leaves the
   site for good (or uninstall with `SCADA_PURGE_CERTIFICATES=1`).
4. Delete the firewall rules created in
   [Network preparation]({{ '/en/getting-started/' | relative_url }}#network)
   (for a rule the computer does not have, `netsh` reports that no rules
   match, which is harmless):

   ```bat
   netsh advfirewall firewall delete rule name="Telecontrol SCADA Clients"
   netsh advfirewall firewall delete rule name="Telecontrol SCADA OPC UA"
   ```

   Delete in the same way any rule you created for links that accept
   connections (for example port 2404), by the name you gave it.

### On Linux {#uninstall-linux}

**On Linux**, `sudo apt remove telecontrol-scada-server` stops and
removes the process services and the computer's certificate; the data in
`/var/lib/scada` and the site certificate authority (on the central
computer, the `/opt/telecontrol-scada/data/Certificates/ca` folder) stay, as
on Windows, so after a reinstall the other computers need not join again.
`sudo apt purge telecontrol-scada-server` also deletes the whole
`data/Certificates` folder, the certificate authority included — uninstall
that way only when the computer leaves the site for good. For an archive
installation run `sudo /opt/telecontrol-scada/bin/scada-setup remove` first,
then delete the `/opt/telecontrol-scada` folder; on the central computer, if
the program will be installed again, first save the `data/Certificates/ca`
subfolder and put it back before `apply` (see
[A new certificate authority]({{ '/en/server/opcua/' | relative_url }}#opcua-renewal)).
The `scada` account stays after uninstalling, `apt purge` included; if it is
no longer needed, delete it with `sudo userdel scada`.

**Neither `apt remove` nor `apt purge` deletes the `/var/lib/scada` data
folder**: the configuration, history and license stay. `apt purge` deletes
only its `secrets` folder, with the file `service-secrets.env` that holds the
`svc` and `root` passwords unencrypted — also in a data folder chosen with
`--data-root`, which `scada-setup` records in `/etc/scada/data-root`. After
`apt remove` that file stays. Delete the `secrets` folder
(`<data folder>/secrets`) by hand if the program was installed from the
archive (`scada-setup remove` and deleting the installation folder), or if
the data folder is not `/var/lib/scada` and the processes' services had
already been removed before `apt purge`, which leaves no record of it. If
the data is no longer needed, delete the
folder with `sudo rm -rf /var/lib/scada`, and remove the firewall rules
created in [Network preparation]({{ '/en/getting-started/' | relative_url }}#network).
