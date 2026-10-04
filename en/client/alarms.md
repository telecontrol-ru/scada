---
title: Alarm annunciation
nav_order: 7
parent: Client
permalink: /en/client/alarms/
---

# Alarm annunciation
{:.no_toc}

* TOC
{:toc}

The client announces unacknowledged events in several ways: a count and
severity tiles, opening the event panel, flashing the window, a tone and a
spoken message. The count and the tiles are always on; the rest are switched
on and off on the settings screen: **Settings → Settings… → Events & alarms**.

These preferences live in the user profile on the server, so a choice made at
one workstation follows the account to the next.

## Which events raise the alarm {#escalation}

Not every unacknowledged event sounds. The annunciators fall into two groups.

**Every unacknowledged event** is announced by the status-bar count, the
severity tiles in the context strip, the event panel and the window flash.

**The tone and the spoken message** are on only while at least one of these
holds:

* at least one unacknowledged event is **critical** (severity 800 and above);
* **more than ten** events are unacknowledged (an "alarm flood"), whatever
  their severity.

> **Caution.** Warnings (severity 600 to 799) and routine events do not sound
> on their own: only the count, the tiles, the event panel and the window flash
> announce them. A silent client does **not** mean nothing is unacknowledged —
> check the count in the status bar.

The client's own messages ("Local Event") count too: an error message is
critical and so sounds, while a warning — such as the loss of the connection
to the Server — does not.

## The event panel opens by itself

**Show Events on Arrival** (on by default).

When a new unacknowledged event arrives, the client opens the [event
panel]({{ '/en/client/' | relative_url }}#events-panel) without taking focus:
the operator keeps working in the current window while the list appears beside
it. An event that arrives already acknowledged does not open the panel.

With the option off, the panel opens only with **More → Events**. The
unacknowledged count in the status bar keeps counting either way, so nothing is
lost — the events simply stop asking for attention on their own.

## And closes by itself

**Hide Events on Acknowledge** (on by default).

The panel closes once the last event is acknowledged. **All** events count, not
only those from the server: the client's own local messages — "Connection to
server established. Login successful.", for one — are unacknowledged until the
operator acknowledges them, and they hold the panel open.

With the option off, the panel stays on screen until the operator closes it.

## The alarm tone

**Sound Alarm on Event** (off by default).

The tone sounds only under the conditions listed [above](#escalation).

On Windows it repeats for as long as the condition holds and stops as soon as
it no longer does — for example when the last critical event is acknowledged,
even if warnings are still unacknowledged.

On every other platform the tone **sounds once**, when the condition starts to
hold, and does not repeat.

## Window flash

**Flash Main Window on Event** (off by default).

While at least one event of any severity stands unacknowledged, the client asks
the desktop for attention: the taskbar button flashes on Windows, the Dock icon
bounces on macOS.

The request is only made while the client's window is **not** the active one —
an operator already looking at the client is not interrupted — and the system
withdraws it as soon as the window is brought to the front. So the flash ends
when the operator turns to the client, not when the events are acknowledged;
the status-bar count is what stays until the last event is acknowledged.

## Spoken announcement {#speech}

The spoken announcement is on by default and available in the **Windows build
only** — it uses the platform's own speech synthesis.

When one of the conditions listed [above](#escalation) starts to hold, the
client says **"Unacknowledged alarm"** once. It does not repeat while the
condition holds, and says nothing on acknowledgement. If the condition starts
to hold again — a new critical event after the previous one was acknowledged,
say — it speaks again.

> **Caution.** In the current version the settings screen has no switch for
> spoken announcements, so they cannot be turned off from the client.

## What is always visible

The status bar shows the number of unacknowledged events, the current severity
threshold ("Severity: N") and the highest severity among the unacknowledged
events. The context strip at the top shows the "Critical N", "Warning N" and
"Unacknowledged N" tiles, or a single "Alarm flood" indicator during a flood.

The severity threshold filters current events: an event below it never reaches
the current-events panel and so never opens it. If an expected event did not
appear, check the threshold first.

To change it, right-click in the "Current Events" panel, choose
**Severity → Custom...** and enter the minimum severity (0 means all events);
**Severity → All** removes the threshold. The threshold is kept in the profile.

## Acknowledging

Acknowledge an event by double-clicking its row or with *Acknowledge* in the
row's context menu; hold *Shift* or *Ctrl* to select and acknowledge several
rows at once. There is no keyboard shortcut for acknowledgement.

> **Caution.** *Acknowledge All* acknowledges **every** unacknowledged event in
> the system — including events the current window hides because of an area,
> severity or object filter. To acknowledge only what you can see, select those
> rows (*Shift*, *Ctrl*) and choose *Acknowledge*.

See the event panel section of the
[client page]({{ '/en/client/' | relative_url }}#events-panel) and the
[event journal]({{ '/en/client/events/' | relative_url }}).
