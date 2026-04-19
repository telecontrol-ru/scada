---
title: Server files
nav_order: 6
parent: Development
permalink: /en/dev/server-files/
---

# Server files

In a distributed client-server SCADA deployment with a central Server,
the Server provides schematic files to all connected Clients
automatically.

The server-files window can be opened with the `Files` command from the
Client's `Further` menu:

![]({{ '/img/menu-files.png' | relative_url }})

In the `Files` window, server-side schematic files can be organized into
multiple nested folders. Double-clicking a selected schematic file opens
it in the Client.

All schematic files should be stored on the Server in the main folder:

`%ProgramData%\Telecontrol\SCADA Server\FileSystem`

This is the Server-side file system described in
[Server]({{ '/en/server/' | relative_url }}#filesystem).

With this arrangement, changing a schematic file once on the Server is
enough for the updated version to become available to all Clients
connected to that Server.

## Translation status

This English page is a direct translation of the current Russian page.
