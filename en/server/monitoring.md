---
title: Logs and monitoring
nav_order: 7
parent: Server
permalink: /en/server/monitoring/
---

# Logs and monitoring
{:.no_toc}

* TOC
{:toc}

## Logging {#logging}

Each process writes text log files named
`scada-<process>_<date>_<time>-<number>.log` (for example
`scada-iec104_2026-10-04_08-00-00-0.log`). For processes installed by
`scada-setup`, the logs are in the `Logs` folder of the process folder:
`%ProgramData%\Telecontrol\SCADA Server\<process folder>\Logs`. Settings:

| Parameter | Default | Description |
|---|---|---|
| `log.dir` | `%ProgramData%\Telecontrol\SCADA Server\logs` (on Linux, `Telecontrol/SCADA Server/logs` under the process's working directory) | Log-directory path |
| `log.max_file_size` | `10` | Maximum size of one log file in MB |
| `log.max_total_size` | `100` | Maximum total log size in MB |
| `log.max_count` | `1000` | Maximum number of log files |
| `log.severity` | — | Lowest level of the messages written to the log files (and anywhere else): `Trace`, `Debug`, `Info`, `Warning`, `Error` or `Critical`. Not set — messages of every level are written to the files |
| `log.console_severity` | — | Lowest level of the messages printed **to the screen** in [console mode]({{ '/en/server/' | relative_url }}#console), from the same values. Does not affect the log files |

A new file is started when the current one reaches its maximum size, and
every day at midnight. Old files are deleted automatically when the total
size or file count limit is exceeded.

If the parameter file cannot be read (for example after a mistake while
editing it), the process writes the reason to a log in the `Logs` folder
beside the parameter file — for processes installed by `scada-setup` that is
their usual log folder — and does not start. An error in the `log` block (for
example an unknown level) is written to a log with the default settings in the
`log.dir` folder.

## Monitoring {#monitoring}

* **Service, license and certificate state** — `scada-setup status` on each
  computer (it needs no administrator rights): the license expiry, the
  processes it entitles, this computer's [Server certificate]({{ '/en/server/opcua/' | relative_url }}#opcua-certificate)
  and the state of each process's service. It prints, for
  example:

  ```text
  License: C:\ProgramData\Telecontrol\SCADA Server\license.json (onprem-example-20260131, expires 2027-01-31T00:00:00Z)
  Entitled tiers: config filesystem historian iec104 proxy
  OPC UA certificate: C:\Program Files\Telecontrol SCADA\data\Certificates\ServerCertificate.pem
    SHA-256 fingerprint: 30:CE:C4:DB:...:66:6F
    Valid from 2026-11-07 to 2031-11-06 (UTC)
    Issued by the site CA: links are encrypted
  Site CA: C:\Program Files\Telecontrol SCADA\data\Certificates\ca\ca.pem (this is the central computer)
    Valid from 2026-11-07 to 2036-11-05 (UTC)
    Other computers join the site with --central-fingerprint 30:CE:C4:DB:...:66:6F
  config       SERVICE_RUNNING
  historian    SERVICE_RUNNING
  filesystem   SERVICE_RUNNING
  modbus       not installed
  iec104       SERVICE_RUNNING
  iec61850     not installed
  opc          not installed
  vidicon      not installed
  proxy        SERVICE_RUNNING
  ```

  The processes on the `Entitled tiers` line are listed in alphabetical
  order. Under `OPC UA certificate` come the SHA-256 fingerprint of this
  computer's certificate, the dates it is valid from and to, and whether the
  [site certificate authority]({{ '/en/server/opcua/' | relative_url }}#opcua-site-ca) issued it (if not, its
  connections are unencrypted). The `Site CA` lines appear on the central
  computer only: the certificate authority's dates, and the fingerprint the
  other computers join the site with (`--central-fingerprint`). Below that, without `--tiers`, come all nine processes in their start
  order: a running service shows `SERVICE_RUNNING`, a stopped one
  `SERVICE_STOPPED`, and one the computer does not have `not installed`.
* **Process logs** — see [Logging](#logging). Why a process stopped (license,
  certificate, an error in the parameter file) is written to its log.
* **Links between processes** — if a protocol process's log shows
  `Bad_UserAccessDenied`, its computer was given a different `svc` password
  (see [The svc account]({{ '/en/server/security/' | relative_url }}#svc)).
* **Archive writing** — the Client's `More -> Databases` window shows, for
  each archive, how many values were written and the write queue (see
  [Databases]({{ '/en/client/workbench/' | relative_url }}#historical-db)).
  After a protocol process's service restarts, automatically after a failure
  included, archiving of its objects' values resumes by itself, usually
  within a minute (see [After a protocol process restarts]({{ '/en/server/' | relative_url }}#edge-restart)).
  If the written-values count stays flat for longer while object values
  change in the Client, contact Telecontrol (mail@telecontrol.ru).

## Client connections {#sessions}

The `sessions` parameter defines the addresses and ports used for client
connections. By default, the Server listens on all network interfaces
(`0.0.0.0`) on port `2000`.

```json
"sessions": [
    "tcp;passive;host=0.0.0.0;port=2000"
]
```

Multiple connection endpoints can be configured if different interfaces
or ports are required.
