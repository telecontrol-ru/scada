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
until it is, the upgrade cannot be carried out.

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

**Check the plan before installing version 2.6.** The 2.6 installer
replaces the version 2.5 program, and what blocks the migration (see the
list below) can only be fixed in version 2.5. So check the plan first with
the `scada-setup` unpacked from the 2.6 package without installing it.

The steps, on the computer where the 2.5 Server ran, from an elevated
command prompt:

1. Obtain a version 2.6 license (a `license.json` file) from Telecontrol and
   put it at `%ProgramData%\Telecontrol\SCADA Server\license.json`. Version
   2.6 does not use the HASP or Guardant hardware key: Telecontrol exchanges
   it for a license — see [Exchanging the hardware key](#license-exchange).
2. Back up the whole `%ProgramData%\Telecontrol\SCADA Server` folder.
3. Unpack the version 2.6 package into a temporary folder — this **does not
   install it**, and the 2.5 Server keeps running — and find
   `scada-setup.exe` in it:

   ```bat
   msiexec /a telecontrol-scada-<version>.msi /qb TARGETDIR=C:\scada-2.6-setup
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
5. Install the version 2.6 package:

   ```bat
   msiexec /i telecontrol-scada-<version>.msi /qn /norestart /l*v install.log
   ```

   The installer replaces the version 2.5 program; the data stays where it
   is. The *Telecontrol SCADA Server* service may stay registered — the next
   step stops and removes it.
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
7. Install the version 2.6 Client on **every** workstation: the 2.6 Client
   displays schematics with its own display module (see
   [Displaying schematics]({{ '/en/getting-started/' | relative_url }}#displays)).
   Whether a version 2.5 Client works with a 2.6 Server has not been
   verified.
8. Connect a Client (port 2000, as before) as a user and check the objects,
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
version is installed** (the message `A later version of ОИК Телеконтроль is
already installed`), and the version 2.5 *Telecontrol SCADA
Server* service has already been removed by `migrate --execute`. On the same
computer, from an elevated command prompt:

1. Uninstall version 2.6: the *ОИК Телеконтроль* program (publisher
   ООО Телеконтроль) in *Control Panel — Programs and Features*, or
   `msiexec /x telecontrol-scada-<version>.msi /qn /norestart /l*v uninstall.log`.
   `msiexec /x` needs the file of the very package that is installed; if
   you do not have it, uninstall from the Control Panel. The installer
   itself stops and removes the version 2.6 services, and leaves the data in
   `%ProgramData%\Telecontrol\SCADA Server` (see
   [Uninstalling the Server](#uninstall)).
2. Install release 2.5.7 (`telecontrol-scada-2.5.7.msi` from the
   [releases page](https://github.com/alexsmn/scada-client/releases)) the
   way you installed version 2.5, and attach the HASP or Guardant hardware
   key.
3. On **every workstation** that got the version 2.6 package in the
   migration (step 7 above): uninstall the *ОИК Телеконтроль* program in
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
`A later version of ОИК Телеконтроль is already installed`), and restoring a
backup [on the same computer]({{ '/en/server/backup/' | relative_url }}#restore) only puts the data back under the
version that is installed now. **So back up every Server computer before every
upgrade**: without that backup there is no way back.

To go back to the previous version, on each Server computer the upgrade
reached, from an elevated command prompt:

1. Stop the processes:
   `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop`.
2. Uninstall the newer version: the *ОИК Телеконтроль* program in
   *Control Panel — Programs and Features*. The installer removes the
   services and the Server certificate from the
   `C:\Program Files\Telecontrol SCADA\data\Certificates` folder (see
   [Uninstalling the Server](#uninstall)); the data folder and the site
   certificate authority stay. `apply`
   creates the services again in step 5, and the certificate comes back from
   the backup in step 4.
3. Install the older version's package:

   ```bat
   msiexec /i telecontrol-scada-<older version>.msi /qn /norestart /l*v install.log
   ```

4. Put back, from the backup taken **before the upgrade**, the data folder
   (`%ProgramData%\Telecontrol\SCADA Server`, or the folder given as
   `--data-root`), replacing what is there, and the
   `C:\Program Files\Telecontrol SCADA\data\Certificates` folder. If the
   backup does not have it, `apply` creates a new certificate, and OPC UA
   clients that trusted the old one must be made to trust the new one. Do not keep the data the newer version worked with: whether a newer
   version changes the databases when it first starts has not been verified,
   so only the pre-upgrade backup is known to suit the older version.
5. Run `scada-setup apply` with the
   [computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options) and the same `svc` and
   `root` passwords.
6. Check the result: `scada-setup status`, then sign in from a Client.

Changes made to the configuration and values archived after the backup are
lost. If the workstations were upgraded too, uninstall the newer package on
them in the same way and install the older one (with no `scada-setup`
commands).

## Uninstalling the Server {#uninstall}

**The installer removes the services itself.** Before it deletes the
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
   installer deletes nothing from the folder.

   **If the computer leaves the site for good**, uninstall with the
   `SCADA_PURGE_CERTIFICATES=1` parameter: the whole `data\Certificates`
   folder is then deleted, on the central computer together with the site
   certificate authority (the `ca` subfolder with the `ca_key.pem` key). On
   the central computer do this only when the site is no longer needed:
   after a reinstall `apply` creates a new certificate authority, and every
   other computer of the site has to join again (see
   [A new certificate authority]({{ '/en/server/opcua/' | relative_url }}#opcua-renewal)).
2. Uninstall the program: the *ОИК Телеконтроль* program (publisher
   ООО Телеконтроль) in *Control Panel — Programs and Features*, or from an
   elevated command prompt:

   ```bat
   msiexec /x telecontrol-scada-<version>.msi /qn /norestart /l*v uninstall.log
   ```

   `msiexec /x` needs the file of the very package that is installed; if
   you do not have it, uninstall from the Control Panel. The computer's
   Client is uninstalled with the program.

   If the uninstall is cancelled with an error, look for the
   `ScadaSetupRemoveServices` action in `uninstall.log`, and check the
   services with
   `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" status`.
   If `scada-setup` itself does not start, remove the services with the
   Windows tools and uninstall with the `SCADA_KEEP_SERVICES=1` parameter,
   which skips that step:
   `msiexec /x telecontrol-scada-<version>.msi SCADA_KEEP_SERVICES=1 /l*v uninstall.log`.
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
