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

The client announces unacknowledged events three ways: it opens the event
panel, it sounds a tone, and it counts them in the status bar. The first two are
switched on and off from the *Settings* menu; the third is always on.

All of these preferences live in the user profile on the server, so a choice
made at one workstation follows the account to the next.

## The event panel opens by itself

**Settings → Show Events on Arrival** (on by default).

When a new unacknowledged event arrives, the client opens the [event
panel]({{ '/en/client/' | relative_url }}#events-panel) without taking focus:
the operator keeps working in the current window while the list appears beside
it. An event that arrives already acknowledged does not open the panel.

With the option off, the panel opens only when the operator opens it from the
*Window* menu. The unacknowledged count in the status bar keeps counting either
way, so nothing is lost — the events simply stop asking for attention on their
own.

## And closes by itself

**Settings → Hide Events on Acknowledge** (on by default).

The panel closes once the last event is acknowledged. **All** events count, not
only those from the server: the client's own local messages — the control
success message, for one — are unacknowledged until the operator acknowledges
them, and they hold the panel open.

With the option off, the panel stays on screen until the operator closes it.

## The alarm tone

**Settings → Sound Alarm on Event** (off by default).

On Windows, while at least one event stands unacknowledged, the client repeats
a system tone. It stops as soon as the last event is acknowledged rather than
after a fixed time, so a client that has gone quiet is a client with nothing
outstanding.

On every other platform the tone **sounds once** when the alarm arrives, rather
than repeating: the client has no looping system sound to offer there. The
option is live on both — what differs is only whether the tone repeats — and
the annunciation that lasts until the last event is acknowledged is the
unacknowledged count in the status bar.

## Window flash

**Settings → Flash Main Window on Event** (off by default).

While at least one event stands unacknowledged, the client asks the desktop for
attention: the taskbar button flashes on Windows, the Dock icon bounces on
macOS.

The request is only made while the client's window is **not** the active one —
an operator already looking at the client is not interrupted — and the system
withdraws it as soon as the window is brought to the front. So the flash ends
when the operator turns to the client, not when the events are acknowledged;
the tone and the status-bar count are what stay until the last event is
acknowledged.

## Spoken announcement

**Settings → Speech** (on by default, where it is available at all).

When an event arrives and nothing was standing unacknowledged before it, the
client says **"Unacknowledged alarm"** once. It does not repeat while the alarm
stands, and it says nothing when the last event is acknowledged: the
announcement marks the arrival, and repeating it would talk over the operator.

Spoken announcements are available in the **Windows build only** — they use the
platform's own speech synthesis. Elsewhere the checkbox is drawn disabled
rather than hidden, so the option reads as unavailable on this platform rather
than as not existing.

## What is always visible

The status bar shows the number of unacknowledged events and the current
severity threshold. The threshold is the panel's filter: an event below it never
reaches the current-events panel and so never opens it. If an expected event did
not appear, check the threshold first.

## Acknowledging

Acknowledge an event by double-clicking its row, from the row's context menu, or
with *Acknowledge All* on the toolbar; hold *Shift* to select and acknowledge
several rows at once. See the event panel section of the
[client page]({{ '/en/client/' | relative_url }}#events-panel) and the
[event journal]({{ '/en/client/events/' | relative_url }}).
