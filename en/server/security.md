---
title: Passwords and accounts
nav_order: 4
parent: Server
permalink: /en/server/security/
---

# Passwords and accounts
{:.no_toc}

* TOC
{:toc}

## Root password {#root-password}

The built-in `root` account has all rights and always exists, whatever
the configuration contains. Its password is set with
`security.rootPassword`:

```json
"security": {
    "rootPassword": "$ENV{SCADA_ROOT_PASSWORD}"
}
```

**WARNING:** without this parameter, `root` is given an empty password
on first start and the Server accepts `root` with no password (a warning
is written to the log). Set a password before the Server is reachable
over the network.

A configured value is authoritative: it is written on every start and
replaces any password stored earlier. So while the parameter is set, the
process refuses a root password change made from the Client or an OPC UA
client (status `Bad_NotWritable`), and the Client reports the refusal in
the event journal, naming the `scada-setup set-password` command. The
other accounts' passwords change as usual. Without the parameter, a root
password changed from the Client is kept. To keep the password out of the
file in plain text, pass it through an environment variable as in the
example above.

**`scada-setup` sets it** (on Windows and on Linux): the parameter files it writes for
`scada-config` and `scada-filesystem`
contain `"rootPassword": "$ENV{SCADA_ROOT_PASSWORD}"`, and `scada-setup apply`
takes the variable's value from `--root-password` (or the
`SCADA_SETUP_ROOT_PASSWORD` environment variable) and stores it in the
computer's [password file]({{ '/en/server/setup/' | relative_url }}#stored-passwords). On a computer running one of those
processes, `apply` refuses to run without it. To change the root password,
run `scada-setup set-password --root-password <new password>`: the command
stores the password and restarts the computer's services (see
[Changing the svc password](#svc-rotate)). Do not edit the generated parameter files,
which the next `apply` rewrites.

Set the parameter on **every** process that keeps the configuration in
its own database; each of them has its own `root` account: `scada-config`
and `scada-filesystem`. The protocol processes, `scada-historian` and
`scada-proxy` receive their configuration from `scada-config` and do not
use this parameter (they log a message saying so); a `root` sign-in through
`scada-proxy` is checked against `scada-config`'s `root` password.

A process takes the `SCADA_ROOT_PASSWORD` value from the computer's
[password file]({{ '/en/server/setup/' | relative_url }}#stored-passwords), which it finds through the
`SCADA_SECRETS_FILE` variable in its service settings; when there is no such
file or no password in it, from the environment variable of the same name.
Started without either (for example in [console mode]({{ '/en/server/' | relative_url }}#console)), it leaves
the stored `root` password unchanged and writes a warning to its log.

## The svc account {#svc}

The Server processes connect to each other as the `svc` service account
(id 100). `scada-setup apply` creates it in the configuration databases and
stores its password, from `--svc-password`, in the computer's
[password file]({{ '/en/server/setup/' | relative_url }}#stored-passwords), where the processes read it.
`scada-config` and `scada-filesystem` write
that password into their databases on every start, so **every computer of the
site must be given the same `svc` password**.

* **The `svc` account cannot be changed in the Client's *Users* window**:
  the server refuses to delete, rename or disable it, or to change its
  password or roles, because that would break the links between the
  processes. If it is missing anyway (for example from a database copied
  from another site), `apply` restores it: on the central computer, stop the
  processes (`scada-setup stop`) and run `apply` with the same `svc` password
  (see [Re-running apply]({{ '/en/server/setup/' | relative_url }}#reapply)).
* When the passwords differ, the protocol process keeps running but gets no
  configuration, and its [log]({{ '/en/server/monitoring/' | relative_url }}#logging) shows `Bad_UserAccessDenied`. Run
  `set-password` on that computer with the central computer's `svc` password
  (see [Changing the svc password](#svc-rotate)).

### Changing the svc password {#svc-rotate}

The `set-password` command stores the new password in the
[password file]({{ '/en/server/setup/' | relative_url }}#stored-passwords), restarts this computer's process services
and starts every installed process service, **stopped ones included**. Do not
run it while any process of this computer runs in [console mode]({{ '/en/server/' | relative_url }}#console):
that process's service would be started alongside it. From an elevated
command prompt:

```bat
"C:\Program Files\Telecontrol SCADA\bin\scada-setup.exe" set-password --svc-password <new password>
```

On Linux:

```shell
sudo /opt/telecontrol-scada/bin/scada-setup set-password --svc-password <new password>
```

The command finds the data folder from the installed services, so
`--data-root` is not needed.

**Run it on every Server computer, in this order:**

1. on the central computer (the one with `scada-config`) — its processes
   write the new password into their databases and connect to each other
   with it straight away;
2. then on each computer of protocol processes. Their objects are marked bad
   during the restart and then update again by themselves (see
   [After a protocol process restarts]({{ '/en/server/' | relative_url }}#edge-restart)).

Until the command has run on a computer, its processes present the old
password: they keep running but get no configuration, and the log shows
`Bad_UserAccessDenied`. So change it on all computers in one go, in a
maintenance window.

With `--root-password <new password>` the command changes this computer's
[root password](#root-password) the same way; both can be given together.
If the Server was installed by a pre-release build of version 2.6 and the
computer has no password file yet, the command requires both passwords — on a
computer running `scada-config` or
`scada-filesystem` — and changes nothing until it has them: otherwise the
`root` password would be lost when it leaves the registry.
