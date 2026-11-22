---
title: Backup
nav_order: 8
parent: Server
permalink: /en/server/backup/
---

# Backup
{:.no_toc}

* TOC
{:toc}

On each computer running Server processes, copy:

* the whole `%ProgramData%\Telecontrol\SCADA Server` folder — each process
  has its own folder in it, holding its parameter file, databases and logs,
  and the license file `license.json` sits beside them;
* the `C:\Program Files\Telecontrol SCADA\data\Certificates` folder — the
  [Server certificate]({{ '/en/server/opcua/' | relative_url }}#opcua-certificate) and its private key, and on the
  central computer the `ca` subfolder as well — the
  [site certificate authority]({{ '/en/server/opcua/' | relative_url }}#opcua-site-ca) with its `ca_key.pem` key.
  Without it every other computer must join again after a restore (see
  [A new certificate authority]({{ '/en/server/opcua/' | relative_url }}#opcua-renewal)). Keep the copy of the keys
  as safe as the passwords.

A hot-standby Server is not supported in version 2.6, so the central computer
is a single point of failure of the site, and if it breaks down only a
restore from a backup brings the site back (see
[Redundancy]({{ '/en/architecture/' | relative_url }}#redundancy)).

**On Linux** copy the whole `/var/lib/scada` folder and the
`/opt/telecontrol-scada/data/Certificates` folder, with the processes
stopped by `sudo /opt/telecontrol-scada/bin/scada-setup stop`.
`/var/lib/scada` also holds the [password file]({{ '/en/server/setup/' | relative_url }}#stored-passwords)
`secrets/service-secrets.env`, which keeps the `svc` and `root` passwords
**in plain text**: keep the copy where only `root` can read it, or leave
that file out. The services do not start without it, and `start` does not
create it: if the copy has no `secrets` folder, keep the existing one when
restoring, or run `apply` with the passwords instead of `start` (see
[Restore](#restore)).

Copy only with **this computer's processes stopped**: a copy of the files of
running databases may be inconsistent. From an elevated command prompt:

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop
rem copy %ProgramData%\Telecontrol\SCADA Server
rem and C:\Program Files\Telecontrol SCADA\data\Certificates
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" start --tiers <this computer's processes>
```

A restore also needs the `svc` password, the `root` password, and the
[computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options) — the `--tiers`, `--central`,
`--advertise`, `--license`, the central computer's fingerprint and the other
options, if given, that `scada-setup apply` was run with on it. Some of them
are in the copied parameter files of the processes, and on Linux the copy
also holds `secrets/service-secrets.env` with the passwords, but the backup
does not give them in a form `apply` can reuse — keep the written record of
the options and passwords separately.

### Configuration backup

The configuration is an SQLite database in the `config\Configuration` folder
of `scada-config`; the other processes read it from there. The
`filestore\Configuration` folder holds only the `svc` service account.

For PostgreSQL, use the standard PostgreSQL backup tools such as
`pg_dump`.

### History backup

The historical databases are in `historian\History`, and the schematic files
in `filestore\FileSystem`.

Versions 2.5 and earlier kept this data in the `Configuration`, `History` and
`FileSystem` folders directly under `%ProgramData%\Telecontrol\SCADA Server`.
After [upgrading from version 2.5]({{ '/en/server/upgrade/' | relative_url }}#upgrade-2-5) those folders stay where they
are, but the 2.6 processes no longer use them.

### Restore {#restore}

Run the `scada-setup` commands by their full path from an elevated command
prompt.

On the same computer:

1. Stop the processes: `scada-setup stop`.
2. Put the `%ProgramData%\Telecontrol\SCADA Server` folder (and the
   `Certificates` folder, if it is gone, then restrict access to the key files
   with the `icacls` commands given below in step 3 for a new computer) back
   from the backup.
3. Start the processes: `scada-setup start` with the
   [computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options). The restored folder takes
   the permissions of `%ProgramData%`, which let any user of the computer read
   it; `start` closes it to other users again before it starts the services.
4. Check the result: `scada-setup status`.

On a new or rebuilt computer:

1. Install the package of **the same version** as the backup.
2. Put the `%ProgramData%\Telecontrol\SCADA Server` folder back from the
   backup.
3. **If the computer's name is the same**, put the
   `C:\Program Files\Telecontrol SCADA\data\Certificates` folder back too,
   then restrict access to the key files. A copied file takes the permissions
   of the `C:\Program Files` folder, which let any user of the computer read
   it, and neither `start` nor `apply` corrects the permissions of these
   files. The second command is needed only on the central computer, which
   has the `ca` subfolder:

   ```bat
   icacls "C:\Program Files\Telecontrol SCADA\data\Certificates\ServerPrivateKey.pem" /inheritance:r /grant:r *S-1-5-18:F *S-1-5-32-544:F
   icacls "C:\Program Files\Telecontrol SCADA\data\Certificates\ca\ca_key.pem" /inheritance:r /grant:r *S-1-5-18:F *S-1-5-32-544:F
   ```

   **If the computer's name is different**, do not put
   `ServerCertificate.pem` and `ServerPrivateKey.pem` back from the
   `Certificates` folder (or delete them): the old certificate names the
   former computer name, and `apply` creates a new pair only when neither of
   the two files exists. **Put the central computer's `ca` subfolder back in
   any case** — otherwise `apply` creates a new certificate authority and
   the other computers have to join again (see
   [A new certificate authority]({{ '/en/server/opcua/' | relative_url }}#opcua-renewal)) — and restrict access to
   its key with the second `icacls` command above. On a computer without
   `scada-config`, give `apply` in step 4 `--central-fingerprint` too, to get
   a new certificate from the certificate authority. Take the fingerprint
   from `scada-setup status` on the central computer now, not from the
   recorded parameters: it differs once the central computer's certificate
   has been renewed.
4. Run `scada-setup apply` with the same
   [computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options) as before, the `svc` password of
   the site's other computers, and the `root` password. You need not know the
   `svc` password stored in the restored databases: at start the processes
   write the one given to `apply` into the database. `apply` registers and starts the services, and keeps the
   restored databases and certificate. If the site's other computers name this
   one in `--central` by an address that has changed, run `apply` there with
   the new address. If this computer runs protocol
   processes, was set up with `--advertise` and its address changed, give
   `--advertise` the new address.
5. Create the inbound firewall rules again — the backup does not contain
   them (see
   [Network preparation]({{ '/en/getting-started/' | relative_url }}#network)).
   If the address of this computer changed, also correct the `remoteip`
   lists of the rules on the site's other Server computers.
6. If this is the central computer and its address or name changed, enter
   the new one in the `Server` field of the login dialog of each Client
   (see [Client login]({{ '/en/getting-started/' | relative_url }}#client-start)).
7. Check the result: `scada-setup status`.

With a new certificate, third-party OPC UA clients that trusted the old one
have to be set up again.

**On Linux** the folders are the ones in [Backup]({{ '/en/server/backup/' | relative_url }}) —
`/var/lib/scada` and `/opt/telecontrol-scada/data/Certificates` — and the
commands are `sudo /opt/telecontrol-scada/bin/scada-setup …`; the `icacls`
step is not needed. Files put back as `root` (with `cp -r`, say) belong to
`root`, but `scada-setup start` gives them back to the `scada` account and
closes the process folders to other users again before it starts the
services, so on the same computer step 3 (`start`) is enough
while the `secrets` folder is in place (otherwise run `apply` with the
passwords); on
a new computer run `apply` as in the steps above ("On a new or rebuilt
computer"). If `start` reports that the `scada` account does not exist, the
system was reinstalled — restore with the new-computer steps.
