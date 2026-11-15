---
title: Licensing
nav_order: 2
parent: Server
permalink: /en/server/licensing/
---

# Licensing
{:.no_toc}

* TOC
{:toc}

Each Server process needs a signed license file. The license states an
expiry date and the processes purchased; a process the license does not name
will not run. No hardware key is used. The license limits nothing else: not
the number of objects or devices, nor the number of computers, Clients or
copies of one process. License types and terms, renewal and its cost, and
the terms of exchanging a hardware key are agreed with Telecontrol.

The settings live in the `license` block of the parameter file:

```json
"license": {
    "file": "C:\\ProgramData\\Telecontrol\\SCADA Server\\license.json"
}
```

| Parameter | Default | Description |
|---|---|---|
| `file` | `license.json` | Path to the license file. A relative path resolves against the process's working directory, so an absolute path is safer. When the parameter is absent, the `SCADA_SERVER_LICENSE_FILE` environment variable is used |

Parameter files written by [`scada-setup`]({{ '/en/server/setup/' | relative_url }}) already carry the path `%ProgramData%\Telecontrol\SCADA Server\license.json` (on Linux `/var/lib/scada/license.json`; or the one given with `--license`).

A license issued for a Google Cloud virtual machine verifies only on that machine. Any other license is bound to no computer and needs no setting. The `require_gcp_binding` parameter and the `SCADA_SERVER_LICENSE_REQUIRE_GCP_BINDING` environment variable no longer have any effect: if an older parameter file still has them, the process logs a warning and ignores them. Remove them.

The license is checked at startup and then every 5 seconds:

* **No valid license**, or one that does not include this process — the
  process stops. The reason is written to the log. The process does the same
  when the file is missing, only partly written or, on Linux, not readable
  by the `scada` account at the moment it is checked. The service then exits
  normally and neither Windows nor systemd restarts it — once the file is fixed, start the processes with `scada-setup start`
  and the [computer's parameters]({{ '/en/server/setup/' | relative_url }}#scada-setup-options). A license whose
  validity period has not started yet counts as not valid too.
* **The license could not be verified** (for example, the Google Cloud
  metadata server did not answer) — the process keeps running. If the license
  has not yet been verified since the process started, it serves no requests
  until verification succeeds; if it has, it goes on serving as before.
* **The license has expired** — the process keeps running but refuses every
  request from Clients and from the site's other processes: reading and
  subscribing to live values, control, writes, and browsing the
  configuration and history. Open subscriptions are stopped and the values in
  the Client turn bad. There is no grace period: requests are refused from
  the moment the license expires. Once the license file is replaced, service
  resumes without a restart.

With an expired license `scada-setup` warns that it has expired but still
goes by the processes the license names: `apply` without `--tiers` installs
exactly those. `scada-setup apply` does not accept a license whose validity
period has not started yet.

`scada-setup status` shows the license id and when the license expires. The
id names whom the license was issued to; quote it when asking Telecontrol
about the license. During the last 30
days the Server also raises a daily system event about the expiry (every 15
minutes in the final day), but it is
visible only in the Client; there is no other warning, so watch the date with
`scada-setup status`.

Versions 2.5 and earlier used a HASP or Guardant hardware key, and ran for two
hours in demo mode without one. **Version 2.6 has no demo mode**: without a
license the Server processes do not run. Once the 2.6 Server packages are
published, to evaluate the system or to order a license, contact Telecontrol
(mail@telecontrol.ru) and name the processes the site needs (see
[Choose the Server processes]({{ '/en/getting-started/' | relative_url }}#choose)).
Until then see [Buying now]({{ '/en/getting-started/' | relative_url }}#buy-now).

## Replacing the license file {#license-replace}

Running processes re-read the file every 5
seconds and pick up a new license without a restart. So replace the file in
one step: copy the new license into the same folder under a temporary name,
then rename it to `license.json` over the old file:

```bat
copy new-license.json "%ProgramData%\Telecontrol\SCADA Server\license.new"
move /y "%ProgramData%\Telecontrol\SCADA Server\license.new" "%ProgramData%\Telecontrol\SCADA Server\license.json"
```

On Linux the new file must be readable by the `scada` account:

```sh
sudo install -m 0644 new-license.json /var/lib/scada/license.new
sudo mv -f /var/lib/scada/license.new /var/lib/scada/license.json
```

**WARNING:** if the file is missing or only partly written when a process
checks it (for example while it is being copied over the old one), or on
Linux is not readable by the `scada` account, the process concludes there is
no license and stops. Neither Windows nor systemd on Linux restarts such a
service: once the file is in place, start the processes with `start` and the
[computer's parameters]({{ '/en/getting-started/' | relative_url }}#host-parameters):

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" start --tiers <this computer's processes>
```

```sh
sudo /opt/telecontrol-scada/bin/scada-setup start --tiers <this computer's processes>
```

If the license was given with `--license` elsewhere at installation,
replace the file at that path: `start` and `status` check the file named in
the processes' parameter files, so `--license` need not be given again.

If this computer has no `scada-proxy` (protocol processes only), nothing else needs restarting: its processes' objects update and archive again by themselves — see [After a protocol process restarts]({{ '/en/server/' | relative_url }}#edge-restart).

## Adding a process {#license-add}

Replace the file with the new license on every
computer. On the computer that will run the new process, run
`scada-setup apply` with that computer's full process list in `--tiers`, the
new one included, and the same other options as at installation (see
[Re-running apply]({{ '/en/server/setup/' | relative_url }}#reapply)). Write the
new list down. If this computer has no `scada-proxy` (protocol processes only), nothing else needs restarting: its processes' objects update and archive again by themselves — see [After a protocol process restarts]({{ '/en/server/' | relative_url }}#edge-restart).
