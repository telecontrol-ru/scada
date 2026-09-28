---
title: Archiving
nav_order: 7
parent: Development
permalink: /en/dev/history/
---

# Archiving
{:.no_toc}

* TOC
{:toc}

The history of object values and events is kept in **archives** — the
Server's historical databases. For an object's values to be archived, create
an archive with a suitable retention depth and assign it to the object.
Graphs, summaries, the Data table and the event journal build their past
periods from these archives.

Everything on this page needs the *Configure* right.

**WARNING: in version 2.6, archiving cannot yet be set up from the Client.**
In version 2.6 the archives are kept by a separate process, `scada-historian`
(see [Server processes]({{ '/en/architecture/' | relative_url }}#tiers)), and on
an installation made with `scada-setup`:

* creating an archive and assigning one to an object from the Client are
  refused by the Server;
* objects that already have an archive assigned (for example, ones moved
  from version 2.5 with
  [`scada-setup migrate`]({{ '/en/server/' | relative_url }}#upgrade-2-5)) are
  archived, and the archives are listed in the *Databases* window;
* after the service of a protocol process (for example,
  *Telecontrol SCADA IEC 104*) restarts, its objects' values stop being
  archived. Restart the *Telecontrol SCADA Historian* service after it.

To assign archives to new objects on a version 2.6 site, contact Telecontrol
(mail@telecontrol.ru). The Client procedure below is how it works on a Server
running as a single process.

## The Server's archives

Archives are listed in the `More -> Databases` window (or the *Databases*
section of the *Administration* mode). Each shows its retention depth and its
write state — see [Databases]({{ '/en/client/workbench/' | relative_url }}#historical-db).

There is always a system archive, shown as «Системная база данных»: it keeps
every Server event for 30 days, and cannot be changed or deleted.

## Creating an archive

1. Open the *Databases* window.
2. In its context menu, choose `Create -> Database`. The archive is created at
   once, named "Database", and its properties window opens.
3. Set its name (for example "Measurements, 1 year") and its **retention
   depth** — the *Depth, days* property. A new archive starts with a depth of
   **1 day**, so set it straight away.

An archive is renamed with *Rename* or the *Name* field in its properties.

Once a minute the Server deletes data older than the archive's depth; reducing
the depth deletes the excess at once. The formula under
[Historical databases]({{ '/en/server/' | relative_url }}#history) helps
estimate the disk space needed.

## Assigning an archive to objects

In the properties of a [data object]({{ '/en/dev/data-items/' | relative_url }}),
under *Archiving*, choose the archive in the *Value archive* field. The list
holds every archive and *<None>* — do not archive.

A device's events are stored in the archive chosen in its *Event archive*
property ([Devices]({{ '/en/dev/devices/' | relative_url }})).

A common practice is several archives with different depths — say, one for
fast-changing measurements and one for rare events — each assigned to the
objects it suits.

## What happens to the data

* **Changing an object's archive** — its history is deleted from the previous
  archive, and new values go to the new one.
* **Deleting an object** — its history is deleted from the archive.
* **Clearing a device's event archive** — events already written stay in the
  previous archive until its depth expires.
* **Deleting an archive** — all of its data is deleted.

## Checking

After assigning an archive, open the object's
[Graph]({{ '/en/client/graph/' | relative_url }}) or
[Data]({{ '/en/client/data/' | relative_url }}) for a past period: values
written since the assignment should show. In the *Databases* window, an
archive's *Measurement count* shows how many objects write to it.
