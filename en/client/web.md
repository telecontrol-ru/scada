---
title: Web interface
nav_order: 14
parent: Client
permalink: /en/client/web/
---

# Web interface
{:.no_toc}

* TOC
{:toc}

In addition to the graphical desktop Client, Telecontrol SCADA provides
a web interface for browser-based access. The web interface is intended
for remote access and thin-client scenarios.

## Capabilities

The web interface provides the main day-to-day system functions:

* user authorization and authentication
* browsing the object and equipment trees
* viewing data in [tables]({{ '/en/client/table/' | relative_url }}) and
  [summaries]({{ '/en/client/summary/' | relative_url }})
* control commands and manual value entry
* acknowledging and reviewing
  [events]({{ '/en/client/events/' | relative_url }})
* editing setpoints
* exporting data to CSV
* working with favorites and
  [portfolios]({{ '/en/client/portfolio/' | relative_url }})
* configuring objects and devices

## Limitations

The following functions are available only in the graphical desktop
Client:

* **Graphs and trends** for chart-based visualization
* **[Displays]({{ '/en/client/display/' | relative_url }})** rendered
  through ActiveXeme
* **Vidicon integration**
* **[Full print workflow]({{ '/en/client/print/' | relative_url }})**
  with preview

## Startup

The web server runs as a separate application, `webserver`. Its address
and port are configured through command-line arguments.

After startup, the web interface is available through a browser at the
server address.

## UI structure

The web interface uses a Bootstrap-based style and includes:

* a main menu with the same high-level sections as the desktop Client
* a toolbar with command buttons
* a work area with tabs and panels
* docked panels attached to the window edges
* a status bar

Window and worksheet layout is persisted similarly to the graphical
Client.

## Translation status

This English page is a direct translation of the current scope of the
Russian page.
