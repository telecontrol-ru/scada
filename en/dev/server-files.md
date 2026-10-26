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
Client's `More` menu:

![]({{ '/img/files.png' | relative_url }})

In the `Files` window, server-side schematic files can be organized into
multiple nested folders (see below for creating one). Double-clicking a
selected schematic file opens
it in the Client.

## Uploading a display to the Server

1. Open the `Files` window (`More -> Files`).
2. Choose `Create -> File` from the window's context menu. Pick the
   display file (`sde` or `xsde`) on your computer — it is sent to the
   Server.

`Create -> Folder` creates a folder named "New Folder" («Новая папка») in the
selected folder; rename it afterwards. Folders that already exist on the
Server (for example, ones moved from version 2.5) are shown in the window as
usual.

Uploading needs the Configure right.

## Where the Server keeps the files

A version 2.6 Server keeps the files in the folder of the
`scada-filesystem` process. On an installation made with `scada-setup` that
is

`%ProgramData%\Telecontrol\SCADA Server\filestore\FileSystem`

A version 2.5 Server kept them in
`%ProgramData%\Telecontrol\SCADA Server\FileSystem`; moving to 2.6 copies
them to the new folder. See
[Server-side file system]({{ '/en/server/' | relative_url }}#filesystem).

With this arrangement, changing a schematic file once on the Server is
enough for the updated version to become available to all Clients
connected to that Server.
