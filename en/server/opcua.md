---
title: OPC UA and integration
nav_order: 5
parent: Server
permalink: /en/server/opcua/
---

# OPC UA and integration
{:.no_toc}

* TOC
{:toc}

## OPC UA server {#opcua}

The Server can expose data to external systems through
[OPC UA](https://opcfoundation.org/about/opc-technologies/opc-ua/).
When enabled, external clients can browse the Server address space,
including objects, devices, and current or historical data.

In an installation made by `scada-setup`, OPC UA is enabled on every process
(ports 4840–4848, see
[Network preparation]({{ '/en/getting-started/' | relative_url }}#network)):
the processes exchange data with each other over it.

The processes connect to each other encrypted (the Basic256Sha256 policy,
Sign & Encrypt mode) as the [`svc`]({{ '/en/server/security/' | relative_url }}#svc) account. Each process other than
`scada-config` accepts only computers whose certificate was issued by the
[site's certificate authority](#opcua-site-ca) or moved into the `trusted`
folder. `scada-config` (port 4841) accepts a secure connection with any
certificate, because a computer joining the site reaches it before it has a
certificate of its own. But it gives nothing without a sign-in, and it issues
a site certificate to the `svc` account only: no user — not `root`, not an
administrator, not a user with the Configure right — can obtain one, and the
Client cannot give that right to anyone. So joining a computer to the site
takes the `svc` password; keep it as you keep the `root` password.

A Server process may register with `scada-proxy` and `scada-config` — and
`scada-proxy` then treats it as one of the site's processes — only when it
connects with a certificate the [site's certificate authority](#opcua-site-ca)
issued, and only under a name that certificate carries. A certificate moved
into the `trusted` folder lets a system connect, never register. No process accepts unsecured connections (policy None) or
anonymous sign-in, `scada-proxy`'s port 4840 included, which is where
external systems connect — unless `apply` on the computer with `scada-proxy`
was run with `--allow-anonymous-opcua` (see
[Connecting an external system](#opcua-external)). No process accepts a
password sent unencrypted. So, still:

* open the OPC UA ports to the site's computers only (see
  [Network preparation]({{ '/en/getting-started/' | relative_url }}#network));
* if an external system must connect to the Server, allow it port 4840
  (`scada-proxy`) in the firewall from its address only.

**WARNING:** a computer without `scada-config` set up without
`--central-fingerprint` gets a self-signed certificate, and on a site with a
certificate authority its processes **cannot connect** to the others at all:
those refuse unsecured connections and passwords sent unencrypted, and do not
trust its certificate. So `apply` with `--central` but with neither
`--central-fingerprint` nor `--insecure-links`, on a computer that has no
certificate from the certificate authority yet, fails and changes nothing. Only a site whose computers
are all set up with [`--insecure-links`]({{ '/en/server/setup/' | relative_url }}#scada-setup-options) runs
unencrypted, sending the `svc` password in clear text; on such a site the
firewall is the only protection.

```json
"opcua": {
    "enabled": true,
    "url": "opc.tcp://localhost:4840",
    "server_private_key": "${DIR_PARAM}/Certificates/ServerPrivateKey.pem",
    "server_certificate": "${DIR_PARAM}/Certificates/ServerCertificate.pem",
    "trace": "none"
}
```

| Parameter | Description |
|---|---|
| `enabled` | Enable the OPC UA server |
| `url` | OPC UA endpoint address |
| `server_private_key` | Path to the private key in PEM format |
| `server_certificate` | Path to the certificate in PEM format |
| `trace` | Diagnostic level: `none`, `error`, `warning`, `info`, `debug`, `all` |

### Connecting an external system {#opcua-external}

An external OPC UA system — a higher-level system, another vendor's SCADA —
connects to `scada-proxy`'s port 4840. On a site with encryption (set up
without `--insecure-links`) that port accepts only secured connections
(Sign & Encrypt mode) that sign in with a user name and password:

1. Create a user with the rights it needs for the system in the Client's
   [Users]({{ '/en/client/workbench/' | relative_url }}#users) window.
2. Connect the system to `opc.tcp://<computer with scada-proxy>:4840` in
   Sign & Encrypt mode as that user. The first connection is refused:
   `scada-proxy` does not trust the system's certificate and writes it into
   the `data\Certificates\rejected` folder of the installation folder.
3. Move that file into the `data\Certificates\trusted` folder beside it and
   restart the *Telecontrol SCADA Proxy* service (Control Panel — Services;
   on Linux, `systemctl restart scada-proxy`): the process reads its trusted
   certificates when it starts. The restart briefly cuts the Clients off the
   Server.

**WARNING:** every process of the computer trusts the `trusted` folder, so a
system with a certificate there can open a secure connection to any of them,
not only to port 4840 — what it may then do is decided by the user it signs in
as. It cannot register with `scada-proxy` or `scada-config` as a Server
process: they accept that only from a certificate the site's certificate
authority issued. Move into `trusted` only the certificates of systems you
mean to let in; in the firewall, open only port 4840 to such a system, from
its address only; remove its certificate from `trusted` once the system no
longer connects.

If the system can do neither encryption nor sign-in with a user name — as
many systems that connected to a 2.5 Server cannot — run `apply` on the
computer with `scada-proxy` with
[`--allow-anonymous-opcua`]({{ '/en/server/setup/' | relative_url }}#scada-setup-options), together with the
computer's other parameters. Port 4840 then also accepts unsecured
connections (policy None) and anonymous sign-in: **anyone who reaches the
port can browse and read the Server's address space** — the objects and
their values — but not change it or send commands. The port still never
accepts a password sent unencrypted. Allow port 4840 in the firewall from
that system's address only. The other processes refuse anonymous sign-in
even with this option. On a site set up with `--insecure-links`, port 4840
accepts unsecured connections and anonymous sign-in without it.

### Server certificate {#opcua-certificate}

Secured connections (the Basic256Sha256 policy, Sign & Encrypt mode) need a
private key and a certificate in PEM format, named by `server_private_key` and
`server_certificate`:

* an RSA key (2048 bits recommended) **without a passphrase**;
* when the parameters are absent, the process offers unsecured connections
  only (policy None);
* **when the parameters are set but a file is missing or unreadable, the
  process does not start** — the log shows `Can't open file` or
  `Failed to parse OPC UA server certificate PEM`.

Parameter files written by [`scada-setup`]({{ '/en/server/setup/' | relative_url }}) point at
`C:\Program Files\Telecontrol SCADA\data\Certificates\ServerCertificate.pem`
and `ServerPrivateKey.pem`. The installer does not contain these files —
**`scada-setup apply` creates them when they are not there yet**:

* a 2048-bit RSA key without a passphrase and a SHA-256 certificate valid
  for 5 years, issued by the [site's certificate authority](#opcua-site-ca)
  (self-signed with `--insecure-links`, or on a computer that joined without
  `--central-fingerprint`);
* the certificate lists the identifiers (ApplicationUri) of every process
  `apply` enables on this computer, the computer's name, `localhost`,
  `127.0.0.1`, and the `--advertise` address when one is given;
* only the SYSTEM account the services run as, and administrators, can read
  the key file.

One pair serves every process on the computer. `apply` replaces existing
files only to get off a self-signed pair once the site's certificate
authority can issue one: it keeps the old files beside the new ones, as
`ServerCertificate.pem.self-signed` and `ServerPrivateKey.pem.self-signed`.
When a process that the certificate does not list is enabled after the pair
was created, `apply` gets a new certificate from the site's certificate
authority that lists it, and keeps the old files beside the new ones as
`ServerCertificate.pem.previous-uris` and `ServerPrivateKey.pem.previous-uris`:
`scada-proxy` and `scada-config` accept a process's registration only under an
identifier its certificate lists. Where no certificate authority can issue
one (a site set up with `--insecure-links`), `apply` instead prints a warning
naming the identifier: that process cannot register, and third-party OPC UA
clients that check the certificate may refuse to connect to it. When only one of the two files exists, `apply` stops and names the
missing one.

**To replace the certificate** — to issue a new one, include processes added
since, or use a certificate from your own certificate authority:

1. Stop the processes:
   `"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" stop`.
2. Delete both files from `C:\Program Files\Telecontrol SCADA\data\Certificates`,
   or put your own pair in their place (the key in PEM format, without a
   passphrase; restrict access to it as described below).
3. Run `scada-setup apply` with the same
   [computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options) and passwords as at
   installation, including `--central-fingerprint` on a computer without
   `scada-config`: a missing pair is created again, and the processes start.

You can also create a self-signed pair of your own with
[OpenSSL](https://www.openssl.org/) (not part of Windows; it comes, for
example, with Git for Windows). Save this as `cert.cnf`:

```ini
[req]
distinguished_name = dn
x509_extensions = v3
prompt = no

[dn]
O = Telecontrol
CN = Telecontrol SCADA Server

[v3]
basicConstraints = critical, CA:TRUE
keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyCertSign
extendedKeyUsage = serverAuth, clientAuth
subjectKeyIdentifier = hash
subjectAltName = @san

[san]
URI.1 = urn:telecontrol:scada:server
URI.2 = urn:SCADA-HOST:scada:historian
DNS.1 = SCADA-HOST
DNS.2 = localhost
IP.1 = 127.0.0.1
```

and run:

```bat
openssl req -x509 -nodes -newkey rsa:2048 -sha256 -days 1826 ^
    -keyout ServerPrivateKey.pem -out ServerCertificate.pem -config cert.cnf
```

In `[san]`, replace `SCADA-HOST` with the computer's name and list the
identifiers (ApplicationUri) of every process running on it:
`urn:telecontrol:scada:server` for `scada-config` and `scada-proxy`, and
`urn:<computer name>:scada:<process>` for the others (for example
`urn:SCADA-HOST:scada:iec104`). The OPC UA specification requires the
certificate to carry the application's identifier, and the Server's processes
check it, as third-party OPC UA clients do. **The other processes refuse a
self-signed pair**: a pair of your own must be issued by the site's
certificate authority, or by one whose certificate you put in the `issuer`
folder on every computer of the site. Copy both files to the folder the parameters name, and
restrict access to the key file to the SYSTEM account and administrators
(the groups are given by identifier, so the command works on Windows in any
language):

```bat
icacls "C:\Program Files\Telecontrol SCADA\data\Certificates\ServerPrivateKey.pem" /inheritance:r /grant:r *S-1-5-18:F *S-1-5-32-544:F
```

**Client certificates.** In an installation made by `scada-setup`, every
process except `scada-config` accepts on secured connections only the
certificates the site's certificate authority issued or that were moved into
the `trusted` folder: its `opcua` block names the `issuer`, `trusted` and
`rejected` folders under `data\Certificates`. `scada-config` accepts any
client certificate, because a computer joining the site connects to it
before it has a certificate of its own; everything `scada-config` serves
requires a sign-in, and it issues a site certificate only to the `svc`
account. `scada-config` and `scada-proxy` accept a process's registration
only over a connection whose certificate the site's certificate authority
issued — the `opcua.register_trust` block names the `issuer` folder and not
`trusted` — and only under an identifier (ApplicationUri) that certificate
lists. The folders are:

| Parameter | Description |
|---|---|
| `trusted_certificates_dir` | Trusted client certificates (PEM or DER); a client is accepted when its certificate is in this folder |
| `issuer_certificates_dir` | Certificate authority certificates; a client whose certificate they signed is accepted |
| `crl_dir` | Revocation lists for those authorities |
| `rejected_certificates_dir` | Rejected client certificates are written here, to be moved to the trusted folder if wanted |

Further restrictions go in the `opcua.security` block:
`"allow_none": false` forbids unsecured connections,
`"require_encryption_for_password": true` forbids sending a password
unencrypted, and `"require_trusted_client_cert": true` keeps the process
from starting without a trusted-certificate folder, and
`"allow_anonymous": false` forbids anonymous sign-in (allowed by default).
The desktop Client checks no Server certificate when it signs
in with the "Telecontrol" type (TCP port 2000); when it signs in with the
"OPC UA" type in the "Most secure available" or "Sign and encrypt" mode it checks the certificate, and asks
you to confirm trust in it on the first connection (see
[Checking the Server's certificate]({{ '/en/getting-started/' | relative_url }}#server-certificate-check)).

`scada-setup` sets these itself: `"allow_none": false`,
`"allow_anonymous": false` and `"require_encryption_for_password": true` on
every process; with `--allow-anonymous-opcua`, `"allow_none": true` and
`"allow_anonymous": true` on `scada-proxy`.

**WARNING: the Client's connection with the "Telecontrol" sign-in type (TCP
port 2000) is not encrypted.** Everything sent over it, including the user
name and password at sign-in, crosses the network in clear text, and anyone
who can see that traffic can read it. The Server neither limits the number
of failed sign-in attempts nor delays its answer to them, so a password can
be guessed unhindered; each failed attempt is only written to the process
log as an `Authorization error` warning with the user name. Therefore:

* open port 2000 only to the operators' workstation subnet or to a VPN —
  the firewall rule can be limited to their addresses with the `remoteip`
  parameter (on Linux, `from` in the ufw rule; see [Network preparation]({{ '/en/getting-started/' | relative_url }}#network));
* **never make port 2000 reachable from outside the site network** (from
  the internet or from the company's general network); connect remote
  workstations through a VPN only.

**WARNING:** in an installation made with `--insecure-links`, the processes
connect to each other unsecured and send the `svc` password unencrypted, so
there **`"allow_none": false` and `"require_encryption_for_password": true`
break the links between the processes**.

### Site certificate authority {#opcua-site-ca}

The processes trust each other because one certificate authority issued all
their certificates: the site's own, kept on the central computer.

* **The central computer** (the one running `scada-config`): the first
  `apply` creates the certificate authority in
  `C:\Program Files\Telecontrol SCADA\data\Certificates\ca` and issues
  the computer's own certificate from it. It then prints the line the other
  computers need:

  ```
  Links are encrypted (SignAndEncrypt). Join the other computers of the site with
    --central-fingerprint 30:CE:C4:DB:...:66:6F
  ('scada-setup status' prints it again)
  ```

  **The `ca_key.pem` file is the key that issues every certificate of the
  site.** On Windows `apply` creates it so that only the SYSTEM account and
  administrators can read it. A file copied into this folder (from a backup,
  for example) takes the permissions of the `C:\Program Files` folder,
  which let any user of the computer read it, and `apply` does not correct
  them — after copying, restrict access to it with `icacls` (see
  [Restore]({{ '/en/server/backup/' | relative_url }}#restore)). On Linux it belongs to `root` and the `scada` group (mode 0640): any
  Server process on the central computer can read it, so run nothing but the
  Server services as the `scada` account. Back it
  up with the configuration, and never copy it to another computer.
* **Every other computer**: give `apply` that fingerprint with
  `--central-fingerprint`. `apply` then:
  1. checks that the central computer's certificate has that fingerprint,
     and stops, changing nothing, when it does not, so the `svc` password
     goes to no other computer;
  2. signs in to `scada-config` as `svc`;
  3. creates this computer's key, which never leaves it, and gets a
     certificate for it from the certificate authority;
  4. writes parameter files in which every connection is encrypted.

  The colons and letter case of the fingerprint do not matter. Every
  `apply` on the central computer prints it again, and
  [`scada-setup status`]({{ '/en/server/monitoring/' | relative_url }}#monitoring) on the central computer shows it at any
  time (the `Other computers join the site with --central-fingerprint …`
  line); [OpenSSL](https://www.openssl.org/) shows it too:
  `openssl x509 -in ServerCertificate.pem -noout -fingerprint -sha256`.

  The fingerprint is needed only to join. A computer that has joined keeps
  the certificate authority's certificate, and later `apply` runs check the
  central computer's certificate against it rather than against the
  fingerprint.

When `apply` on another computer reports:

* `presented a certificate with fingerprint …, not the … given` — the
  fingerprint is mistyped, `--central` names another computer, or the
  central computer has had a new certificate authority since and the
  fingerprint given is the old one. `scada-setup status` on the central
  computer prints the current fingerprint. Replacing only the central
  computer's certificate does not cause this error (see
  [The central computer's fingerprint changed](#central-fingerprint-changed)).
* `presents a certificate (fingerprint …) that the site CA this computer holds
  did not issue` — this computer has joined, and the central computer has
  since got a new certificate authority (or `--central` names another
  computer). Run `apply` with `--central-fingerprint` and the fingerprint
  that `scada-setup status` prints on the central computer.
* `cannot sign in to scada-config … as svc` — the `svc` password differs
  from the central computer's. **After five failed sign-ins, `scada-config`
  refuses that computer for 15 minutes**, even with the right password.
* `the central computer's certificate does not name the address` — the
  other computers reach the central one by an address its certificate does
  not list. Give `--central` the central computer's name, or, on the central
  computer, delete `ServerCertificate.pem` and `ServerPrivateKey.pem` and run
  `apply` again with `--advertise` and that address.

**Sites installed before this version** switch over by themselves:

1. Run `apply` on the central computer. It creates the certificate authority
   and replaces the self-signed pair.
2. Run `apply` with `--central-fingerprint` on every other computer.

Until a computer is switched over, its connections to the switched computers
fail, so switch all of them in one session.

#### Lifetime and a new certificate authority {#opcua-renewal}

A computer's certificate is valid for 5 years, the site certificate
authority's for 10 years from its creation. When a computer's certificate
expires, the other processes stop accepting its connections and its devices
disappear from the Client; when the certificate authority's expires, the
same happens to every computer of the site.
[`scada-setup status`]({{ '/en/server/monitoring/' | relative_url }}#monitoring) shows the start and expiry dates: the
`Valid from … to …` line under `OPC UA certificate` for the computer's
certificate, and the one under `Site CA` on the central computer for the
authority. [OpenSSL](https://www.openssl.org/) shows them too:
`openssl x509 -in ServerCertificate.pem -noout -enddate` (for the authority,
`ca\ca.pem` on the central computer). Replace certificates in good time.

`apply` does not replace a valid certificate issued by a certificate
authority this computer trusts, even when it is about to expire. So:

* **to renew a computer's certificate**, stop its processes
  (`scada-setup stop`), delete `ServerCertificate.pem` and
  `ServerPrivateKey.pem` from the `data\Certificates` folder of the
  installation (`C:\Program Files\Telecontrol SCADA\data\Certificates`, on
  Linux `/opt/telecontrol-scada/data/Certificates`) and run `apply` with the
  [computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options) — on a joined computer
  without `scada-config`, together with `--svc-password`: it gets the new
  certificate from `scada-config`, and needs no fingerprint for that.
  Renewing the central computer's own certificate changes its fingerprint,
  but the other computers recognise it by the certificate authority, and
  nothing needs changing on them (see
  [The central computer's fingerprint changed](#central-fingerprint-changed));
* **a new certificate authority** appears when the `ca` subfolder on the
  central computer is deleted (to replace an expiring authority) or lost —
  for example by uninstalling with `SCADA_PURGE_CERTIFICATES=1` or by a
  restore without that folder. Every computer's certificate was then issued
  by the old authority, and **every other computer must join again**. On the
  central computer itself, `apply` then replaces its own pair as well: the old
  one is set aside with the `.previous-ca` extension, and the central
  computer's fingerprint changes — the same `apply` and `scada-setup status`
  print the new one. This is the one case in which the other computers need
  the new fingerprint: on every one of them, run `apply` with the
  [computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options) and the new fingerprint in
  `--central-fingerprint`. `apply` notices by itself that this computer's
  certificate was not issued by the current authority, sets the old pair
  aside with the `.previous-ca` extension and gets a new one; there is no
  need to delete the certificate files by hand. Until a computer has joined
  again its connections fail, so join all of them in one session.

#### The central computer's fingerprint changed {#central-fingerprint-changed}

The central computer's fingerprint changes with its certificate:

* after the central computer's [certificate is renewed](#opcua-renewal);
* after the program is reinstalled on the central computer (the installer
  removes its certificate), or the computer is restored under another name;
* after its pair is made again for `--advertise`;
* after the site certificate authority is replaced;
* after `apply` adds a process to the central computer: the computer gets a
  new certificate that names that process too.

**While the certificate authority is the same, nothing needs changing on the
other computers.** A computer that has joined checks the central computer's
certificate against the certificate authority rather than the fingerprint,
so its `apply` (upgrades and restores included) works with the old
fingerprint in `--central-fingerprint` and without one alike, and it need not
join again. The new fingerprint is needed only to join new computers;
`apply` and `scada-setup status` on the central computer print it.

**When the certificate authority is new**, the other computers must join
again with the new fingerprint (see
[Lifetime and a new certificate authority](#opcua-renewal)). Until they do,
`apply` on them stops with `presented a certificate with fingerprint …, not
the … given` (with the old fingerprint) or `… that the site CA this computer
holds did not issue` (without one) and changes nothing.

To notice a new certificate authority, `apply` on a joined computer contacts
`scada-config` on the central computer. When that is unreachable, `apply`
warns `could not check the central computer's site CA`, keeps this
computer's certificate and carries on. If the certificate authority may have
been replaced, run `apply` again once the central computer is up.

## OPC client on Windows {#opc-classic}

On Windows, the Server can connect to external Classic OPC (OPC DA)
servers. Their tags then appear in the Telecontrol SCADA Server address
space and can be bound to data objects.

```json
"opc": {
    "client": {
        "enabled": true
    }
}
```

## Vidicon integration {#vidicon}

The Server supports integration with the Telecontrol Vidicon system to
help migrate existing projects. When enabled, it imports Vidicon objects
into its own address space.

```json
"vidicon": {
    "enabled": true
}
```

This feature is available only on Windows.
