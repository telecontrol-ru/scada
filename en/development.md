---
title: Development
nav_order: 8
has_children: true
permalink: /en/development/
---

# Development
{:.no_toc}

* TOC
{:toc}

Project engineering is performed from the graphical Client while signed in with administrator rights. In that mode, the Client exposes additional commands for editing parameters, devices, data items, displays, users, and server-side files.

## Administrative commands

When the user signs in with administrator rights, the Client adds
administrative commands to its menus and context actions.

### Parameters

The `Parameters` command opens the property window for the selected data
item or object.

![]({{ '/img/ti-parameters.png' | relative_url }})

### Element parameters

The `Element parameters` command opens a table that lists parameters for
all display elements inside the selected group or direction.

![]({{ '/img/ti-element-parameters.png' | relative_url }})

### Delete

The `Delete` command removes the selected object, multiple selected
objects, or a device from the project.

![]({{ '/img/ti-delete.png' | relative_url }})

## Main engineering areas

The engineering workflow covers:

* [user administration]({{ '/en/dev/users/' | relative_url }})
* [equipment and communication setup]({{ '/en/dev/devices/' | relative_url }})
* [data-item configuration]({{ '/en/dev/data-items/' | relative_url }})
* [electronic schematics and element parameters]({{ '/en/dev/displays/' | relative_url }})
* [configuration export and import through Excel]({{ '/en/dev/excel/' | relative_url }})
* [server-side file management]({{ '/en/dev/server-files/' | relative_url }})
