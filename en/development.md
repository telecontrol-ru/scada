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

Project engineering is performed from the graphical Client while signed in with an account holding the Configure right (see [Users]({{ '/en/dev/users/' | relative_url }})). The Client then exposes additional commands for editing parameters, devices, data items, displays, users, and server-side files.

## General configuration editing commands

The commands below are available only with the Configure right.

<dl>

<dt>Properties</dt>
<dd>Opens the property window for the selected SCADA object. Its properties are grouped on tabs in Russian alphabetical order: Архивирование (Archiving), Атрибуты (Attributes), Каналы (Channels), Отображение (Display), Преобразование (Conversion), Прочее (Misc), Уставки (Limits), Фильтрация (Filtering), Эмуляция (Simulation); an object shows only the tabs that hold its properties. The Архивирование tab is where the archive is chosen: Архив значений (Value archive) for a data item, Архив событий (Event archive) for a device or direction (see <a href="{{ '/en/dev/history/' | relative_url }}">Archiving</a>). So on data items, devices and directions the first tab is Архивирование, and on other elements it is Атрибуты. Edited values are not written at once: a dot by the title marks unsaved changes, Apply writes them and Revert discards them. Since Client 2.6.8, when changes are left unapplied the Client asks: "“…” has changes that were not applied. Apply them before closing?" — Apply, Don't apply or Cancel. It asks when the window or the main window is closed, when you switch to another page, create, duplicate or delete a page, and when you sign out; Cancel leaves everything as it was. <b>In Clients 2.6.0–2.6.4 all of these discarded the changes without asking.</b> On the Каналы (Channels) tab an object's device and channel are set in the Основной ввод (Primary input), Резервный ввод (Backup input) and Вывод (Output) sections; they can also be set in the Element Properties table (below).</dd>

![]({{ '/img/ti-parameters.png' | relative_url }})

<dt>Element Properties</dt>
<dd>Opens a table of the parameters of all elements inside the selected group or direction.</dd>

![]({{ '/img/ti-element-parameters.png' | relative_url }})

<dt>Delete</dt>
<dd>Removes the selected object, several selected objects, or a device from the system.</dd>

![]({{ '/img/ti-delete.png' | relative_url }})

</dl>

## User configuration

See [Users]({{ '/en/dev/users/' | relative_url }}).

## Equipment configuration

See [Equipment]({{ '/en/dev/devices/' | relative_url }}).

## Data item configuration

See [Data items]({{ '/en/dev/data-items/' | relative_url }}).

## Electronic schematics and element parameters

See [Displays]({{ '/en/dev/displays/' | relative_url }}).

## Archiving

See [Archiving]({{ '/en/dev/history/' | relative_url }}).

## Configuration export and import {#excel-cfg}

See [Configuration export and import]({{ '/en/dev/excel/' | relative_url }}).

## Server files

See [Server files]({{ '/en/dev/server-files/' | relative_url }}).

## Protocols

See [Supported protocols]({{ '/en/protocols/' | relative_url }}).

## Formulas

See [Formulas]({{ '/en/formulas/' | relative_url }}).
