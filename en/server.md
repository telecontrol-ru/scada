---
title: Server
nav_order: 6
permalink: /en/server/
---

# Server
{:.no_toc}

* TOC
{:toc}

The SCADA Server acquires data from equipment, processes live values, keeps
the history archive and the event journal, and serves Client connections.
**The Server is offered only as a service:** Telecontrol LLC runs and
maintains it on Linux in its cloud. A Server for installation on the
customer's computers is no longer offered (see
[Server 2.5.7 and on-site installations](#legacy)).

Clients connect to the Server over encrypted OPC UA (see
[Connecting Clients](#client-connection)), and the site's devices are reached
through a gateway that the customer installs on site (see
[Site gateway](#gateway)). How to get the service is described in
[Getting the hosted Server]({{ '/en/getting-started/' | relative_url }}#buy-now).

![Clients connect to the Server in Telecontrol's cloud; the gateway at the customer's site connects to the Server itself and polls the devices]({{ '/img/hosted-deployment-en.svg' | relative_url }})

## What we do {#service}

* We install the Server in the cloud, update it, back it up and monitor it.
* We license the Server and the site gateway.
* We give the customer what is needed to connect: the Server address for
  Clients, the SHA-256 fingerprint of its certificate, an account for the
  first login, and for the gateway its package, licence file and parameters
  (see [Site gateway](#gateway)).

The hosting region, terms and price of the service are agreed in the
contract.

## What the customer does {#customer}

* Creates users and assigns their roles in the Client (see
  [Users]({{ '/en/dev/users/' | relative_url }})).
* Builds the project — objects, devices, displays — in the Client (see
  [Development]({{ '/en/development/' | relative_url }})).
* Installs the Clients on the workstations (see
  [Getting started]({{ '/en/getting-started/' | relative_url }})).
* Installs the site gateway (see [Site gateway](#gateway)). No inbound port
  has to be opened for it: the gateway connects to our cloud itself.

## Connecting Clients {#client-connection}

* **Server type "OPC UA"**, with the address we give you. The "Telecontrol"
  type (TCP port 2000) is not used with the hosted Server.
* **Security mode "Sign and encrypt"** (or "Most secure available").
* **Log in with a named account**, one per user.
* **Server check.** On the first connection the Client shows the SHA-256
  fingerprint of the Server certificate. Compare it with the fingerprint we
  gave you, and only then confirm trust. If the Client warns that the Server
  presented a *different* certificate, do not connect until we confirm the
  replacement.

A limitation of Client 2.6.8 with the "OPC UA" type: the user profile —
pages, settings (see
[Operator workbench]({{ '/en/client/workbench/' | relative_url }})) and
portfolios (see [Portfolio]({{ '/en/client/portfolio/' | relative_url }})) —
is kept on this computer only and does not follow the account to another
computer. The next Client release fixes this.

The login steps are in
[Client login]({{ '/en/getting-started/' | relative_url }}#client-start), and
what happens when the connection is lost is in
[Connection to the Server]({{ '/en/client/' | relative_url }}#connection).

## Site gateway {#gateway}

The site's devices are polled by the gateway: a Server protocol process on a
Linux computer next to the devices — `scada-iec104` (IEC 60870-5-104),
`scada-modbus` (MODBUS) and/or `scada-iec61850` (IEC 61850). The gateway
connects to our cloud itself over encrypted OPC UA, and the cloud works with
the gateway over that connection, so not a single inbound port has to be
opened on the gateway computer. The gateway package is not
published for download; we supply it with the service.

**Computer requirements:** Linux x86-64 with systemd, glibc 2.38 or later,
libstdc++ 13 or later (for example Ubuntu 24.04, where installation was
tested); network access to the devices, or a serial port for them.

**What we supply:** the gateway package, the licence file and the computer
parameters — the gateway's processes (`--tiers`), the address of our central
computer (`--central`), the fingerprint of its certificate
(`--central-fingerprint`) and the password of the `svc` service account. Keep
the `svc` password secret: with it a computer connects to the Server as one of
its processes. You do not need to tell us the gateway's external address.

### Gateway port {#gateway-port}

The gateway only connects out; it waits for no connection from the cloud.
Allow the gateway computer **outbound** TCP connections to the cloud address
we give you, on these ports:

| Port | Why |
|:-:|---|
| 4849 | the cloud works with the gateway over a connection the gateway opens itself and keeps open |
| 4841 | on start the gateway gets its certificate and configuration |
| 4842 | the last values of the gateway's objects from the archive |
| 4840 | the gateway announces itself to the Server and gets values to retransmit |

The connection is encrypted and checked on both sides: the gateway connects
only to the address given at installation and accepts the cloud only if its
certificate was issued by our central computer, and the cloud accepts the
gateway only if it presents the certificate issued to it at installation.

**Keep inbound ports closed.** The gateway processes accept connections on
their OPC UA ports — `scada-modbus` 4843, `scada-iec104` 4844,
`scada-iec61850` 4845 — and on ports 2003–2005 (user logins), but nobody
needs to reach them from outside.

If a gateway link accepts connections itself (its "Transport" is of type
"TCP Server", for example
[retransmission to a dispatch centre]({{ '/en/dev/devices/' | relative_url }}#retransmission)
over IEC 60870-5-104, usually port 2404), open its port too, only to the
addresses that must connect.

### Installation {#gateway-install}

Run every command with `sudo`.

1. Install the package we supplied. It installs into
   `/opt/telecontrol-scada`:

   ```sh
   sudo apt install ./<package file>.deb
   ```

2. Put the licence file at `/var/lib/scada/license.json`, readable by
   everyone — the processes read it as the `scada` account:

   ```sh
   sudo mkdir -p /var/lib/scada
   sudo install -m 0644 license.json /var/lib/scada/license.json
   ```

3. **Before the next step** enable the firewall so that it refuses inbound
   connections (except SSH, if you manage the computer over the network) and
   lets outbound ones through. An example for Ubuntu:

   ```sh
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow OpenSSH
   sudo ufw enable
   sudo ufw status
   ```

   On Ubuntu ufw is off by default, and while it is off the process ports are
   open to the whole network. If you are connected over SSH, the `OpenSSH`
   rule must come before `ufw enable`, or you lose access to the computer.

4. Start the gateway with the parameters we supplied. Type the `svc` password
   without echo, so that it stays out of the shell history:

   ```sh
   read -rs SCADA_SETUP_SVC_PASSWORD; export SCADA_SETUP_SVC_PASSWORD
   sudo --preserve-env=SCADA_SETUP_SVC_PASSWORD \
     /opt/telecontrol-scada/bin/scada-setup apply --tiers iec104 \
     --central <address> --central-fingerprint <fingerprint> \
     --reverse-connect
   unset SCADA_SETUP_SVC_PASSWORD
   ```

   `apply` first checks that our central computer's certificate has the
   fingerprint you gave and, if not, stops without changing anything, so the
   `svc` password never reaches a stranger's computer. It then obtains a
   certificate for the gateway, creates a systemd service for each process —
   `scada-iec104.service`, `scada-modbus.service`, `scada-iec61850.service` —
   and starts it. The `--reverse-connect` parameter makes the gateway
   processes connect to the cloud themselves, on port 4849. The services run
   as the `scada` account, start at boot and
   restart 10 seconds after a failure.

5. Check that the services run: `scada-setup status` shows them `active`.
   Process messages are in `journalctl -u scada-iec104` and in the log folder
   `/var/lib/scada/iec104/Logs`.

If `apply` reports:

* `presented a certificate with fingerprint …, not the … given` — the
  fingerprint or the address is mistyped; check them against what we gave you.
* `cannot sign in to scada-config … as svc` — the `svc` password is wrong.
  **After five failed logins the Server refuses this computer for 15
  minutes**, even with the right password.

If the services run (`active`) but the gateway's objects stay without a
connection in the Client, look in the process log for:

* `OPC UA reverse connect: cannot reach client` — the gateway computer cannot
  connect to the cloud address on port 4849; check the company firewall and
  allow outbound connections on the ports in [Gateway port](#gateway-port).
* `OPC UA reverse connect: refused by client` — the cloud did not recognise
  the gateway; tell us, giving the gateway computer's name.

**Serial ports.** The package adds the `scada` account to the `dialout` group,
which owns the serial ports. If `apply` says it added it to `dialout`, restart
the services (`scada-setup stop`, then `scada-setup start --tiers iec104`). If
the RS-485 adapter belongs to another group, add `scada` to it
(`sudo usermod -aG <group> scada`) and restart the services.

**Restarting the gateway** needs nothing restarted in the cloud. While the
gateway is unreachable, its objects are marked invalid in the Client and no new
values are archived. Usually within a minute of the gateway starting, the
gateway connects to the Server again, and value updates and archiving resume
by themselves.

### Gateway licence {#gateway-license}

The gateway's licence is valid for a limited period. While the service is
paid for, we send a new licence file in advance. Replace the old one with it
using the same command as at installation:

```sh
sudo install -m 0644 license.json /var/lib/scada/license.json
```

The gateway processes pick up the new file within a few seconds; the services
do not need restarting. `scada-setup status` shows the licence's expiry and
number.

If less than two weeks remain before expiry and you have not received a new
file, tell us. **After
expiry the gateway processes keep running but stop serving the cloud**: the
gateway's objects become invalid in the Client, and `License
expired` appears in the process log. The values come back by themselves a few
seconds after the new file is installed.

## Unavailable features {#unavailable}

Features that need a Windows Server are not available with the hosted Server:

* the OPC DA (Classic OPC) client — connecting to external OPC servers;
* the Vidicon SCADA integration.

A site that needs them stays on Server 2.5.7 (see [Server 2.5.7](#legacy)).

## Server 2.5.7 and on-site installations {#legacy}

* A Server for installation on the customer's computers is no longer offered,
  for Windows or for Linux.
* Existing Server 2.5.7 installations keep working.
* Moving a site from Server 2.5.7 to the hosted Server is arranged with us
  (see [Getting the hosted Server]({{ '/en/getting-started/' | relative_url }}#buy-now)).

The release history is in the
[Change log]({{ '/en/changes/' | relative_url }}).
