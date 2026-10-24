---
title: Debugger
nav_order: 10
parent: Client
permalink: /en/client/debugger/
---

# Debugger
{:.no_toc}

* TOC
{:toc}

The debugger shows the requests the Client exchanges with the Server and is
meant for diagnosing that exchange — for example, at the request of support.
The Server's exchange with devices is not shown here; use the
[Device watch]({{ '/en/client/device-watch/' | relative_url }}) window for
that.

## Opening it {#open}

The debugger exists only in a Client started with the command-line option
`--debug` (for example, added after the program path in the Client
shortcut's properties). In a normal start its menu items are absent.

In a Client started with `--debug`, the **Help** menu gains two items:

<dl>

<dt>Debugger</dt>
<dd>Opens a separate "Debugger" window with a "Requests" tab.</dd>

<dt>Debug Information</dt>
<dd>Copies diagnostic details about the selected object to the clipboard
and reports "Debug information copied to clipboard.". It is available when
an object with data is selected.</dd>

</dl>

## The Debugger window

Above the request table are the buttons "Pause" ("Resume" while paused) and
"Clear", the "Filter title or id" field, and the "Save trace" button, which
writes the shown requests to a text file.

The table has these columns:

| Column | Description |
|---|---|
| ID | Request identifier |
| Phase | Request state |
| Start Time | Time when the request was sent |
| Duration | Execution time in milliseconds (`ms`) |
| Title | Request description |

When a request row is selected, the full contents of the request and
response are shown on the right.

The table keeps at most the 1,000 most recent requests; older ones are
dropped. While paused, new requests are not recorded.
