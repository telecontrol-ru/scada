---
title: server.json parameters
nav_order: 9
parent: Server
permalink: /en/server/parameters/
---

# server.json parameters
{:.no_toc}

* TOC
{:toc}

System settings are stored in the process's parameter file (`server.json`
in this section). Its default location is given under
[`--param`]({{ '/en/server/' | relative_url }}#command-line-options).

**WARNING:** on Windows the parameter files are written by
[`scada-setup`]({{ '/en/server/setup/' | relative_url }}), and every `scada-setup apply` — every upgrade
included — writes them afresh from templates. **Do not edit `server.json`**:
put your own parameters in `server.override.json` in the same folder, which
`apply` lays over the template (see [Your own parameters]({{ '/en/server/setup/' | relative_url }}#server-override)).

These substitution variables can be used in the file:

| Variable | Description |
|---|---|
| `${DIR_PARAM}` | Directory containing the parameter file |
| `${DIR_EXE}` | Directory containing the Server executable |
| `${DIR_TEMP}` | Temporary directory |
| `$ENV{NAME}` | Value of the environment variable `NAME` (empty if it is not set) |

To see a complete, correct parameter file for a process, have one written
with `scada-setup generate --tiers <processes> --output <folder>` (on a
computer without `scada-config`, also with `--central <address>`): it only
writes the files into the given folder and installs nothing. Writing a
parameter file from scratch is not recommended — among other things it has to
contain the [`license`]({{ '/en/server/licensing/' | relative_url }}) block with the license file path,
[`security.rootPassword`]({{ '/en/server/security/' | relative_url }}#root-password) for `scada-config` and
`scada-filesystem`, and an enabled
[`opcua`]({{ '/en/server/opcua/' | relative_url }}#opcua) block, over which the processes exchange data.
