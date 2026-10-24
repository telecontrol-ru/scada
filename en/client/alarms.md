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

These preferences live in the user's profile on the Server.

## Which events raise the alarm {#escalation}

Not every unacknowledged event sounds. The annunciators fall into two groups.

**Unacknowledged events** are announced by the status-bar count, the severity
tiles in the context strip, the event panel and the window flash.

**The tone and the spoken message** are on only while at least one of these
holds:

* at least one unacknowledged event is **critical** (severity 800 and above);
* **more than ten** events are unacknowledged (an "alarm flood"), whatever
  their severity.

> **Caution.** Warnings (severity 600 to 799) and routine events do not sound
> on their own: only the count, the tiles, the event panel and the window flash
> announce them. A silent client does **not** mean nothing is unacknowledged —
> check the count in the status bar and the event panel.

The client's own messages ("Local Event") are events too: reports of a
successful command, of the connection to the Server being lost and restored,
of errors. An error message is critical and so sounds, while a warning — such
as the loss of the connection to the Server — does not sound on its own.

Client messages are counted **differently from the Server's events**:

* they are in the status bar's "Events: N" count and count towards both
  conditions above — including "more than ten";
* they are **not** in the severity tiles ("Critical N", "Warning N",
  "Unacknowledged N"), in the "Unacknowledged critical" and "Alarm flood"
  indicators, or in the status bar's highest severity.

So the tone can sound while the tiles read zero, or fewer than ten: after a few
control commands with success messages and a few reconnections to the Server,
for example. Acknowledge client messages in the event panel just like the
Server's events.

> **Caution.** Events below the [severity threshold](#threshold) are not
> received by the client at all: they are not in the count, the tiles or the
> event panel, and they raise no annunciation of any kind. "Check the count"
> does not help for them. Keep the threshold at *All* on an operator
> workstation.

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

> **Caution.** The tone is off for **every new** account: the setting is kept
> in the user's profile, so it has to be turned on under each operator account
> — **Settings → Settings… → Events & alarms → Sound Alarm on Event**. Spoken
> announcements exist on Windows only, so on macOS this tone is the only
> audible alarm: while it is off, the client on macOS raises alarms silently.

The tone sounds only under the conditions listed [above](#escalation).

On Windows it repeats for as long as the condition holds and stops as soon as
it no longer does — for example when the last critical event is acknowledged,
even if warnings are still unacknowledged.

On every other platform the tone **sounds once**, when the condition starts to
hold, and does not repeat.

The client has no sound file of its own: on Windows the tone is the Windows
system sound "Exclamation", played in a loop; on macOS it is the system alert
sound. If that sound is set to "(None)" in the Windows sound settings, the
volume is muted or the wrong output device is selected, the client stays
silent on an alarm without saying so.

> **Caution.** When commissioning an operator workstation, test the tone:
> turn on *Sound Alarm on Event*, raise a critical event (severity 800 or
> above) and make sure the tone is heard. Keep a sound assigned to the Windows
> "Exclamation" event and the volume up on that computer, and test the tone
> again after changing the Windows sound scheme or the audio device.

## Window flash

**Flash Main Window on Event** (off by default).

When unacknowledged events appear (after there were none), the client asks the
desktop for attention **once**: the taskbar button flashes on Windows, the Dock
icon bounces on macOS.

The request takes effect only if the client's window is **not** the active one
at that moment, and the system withdraws it as soon as the window is brought to
the front. The client makes a new request only after every event has been
acknowledged and a new one arrives. So:

* while events remain unacknowledged, new events do **not** flash the window —
  even if the operator has switched to another program;
* if the first event arrived while the client's window was active, there is no
  flash at all until everything is acknowledged.

The window flash is only an extra cue; the status-bar count and the event panel
are what reliably show unacknowledged events.

## Spoken announcement {#speech}

The spoken announcement is on by default and available in the **Windows build
only** — it uses the platform's own speech synthesis.

The client speaks with the Windows default voice. For the Russian-language
client the phrase is Russian («Неквитированное событие»), so a Russian
speech-synthesis voice must be installed in Windows and selected as the
default voice; check this when commissioning the workstation.

When one of the conditions listed [above](#escalation) starts to hold, the
client says **"Unacknowledged alarm"** once. It does not repeat while the
condition holds, and says nothing on acknowledgement. If the condition starts
to hold again — a new critical event after the previous one was acknowledged,
say — it speaks again.

> **Caution.** In the current version there is no switch for spoken
> announcements on the settings screen or in the command palette (*Ctrl+K*), so
> they cannot be turned off from the client.

## What is always visible

The status bar shows the number of unacknowledged events ("Events: N",
client messages included), the current severity threshold ("Severity: N") and
the highest severity among the Server's unacknowledged events.

The context strip at the top shows the "Critical N", "Warning N" and
"Unacknowledged N" tiles — for the Server's events. Beside the tiles appear:

* **"Unacknowledged critical"** — a flashing indicator while at least one of
  the Server's critical events (severity 800 and above) is unacknowledged. It
  stops flashing once every critical event is acknowledged;
* **"Alarm flood (N)"** — while more than ten of the Server's events are
  unacknowledged.

The tiles stay in place either way.

## Severity threshold {#threshold}

The severity threshold sets which events the client receives from the Server as
current events. For this workstation, an event below the threshold might as
well not have happened:

* it is not in the "Current Events" panel or in a journal showing current
  events, and it does not open the panel;
* it is not in the "Events: N" count or in the context strip's tiles and
  indicators;
* it does not sound the tone or the spoken announcement, and does not flash the
  window;
* the object's dot in the object tree does not blink for it;
* *Acknowledge All* and an object's *Acknowledge* do not acknowledge it.

Such events are still recorded on the Server and can be seen in the
[event journal]({{ '/en/client/events/' | relative_url }}) for a period once it
loads — when the journal window opens or the period changes.

> **Caution.** The threshold is kept in the profile and stays in force until
> *All* is chosen. Do not raise it on an operator workstation: the operator
> will neither see nor hear events below it. If an expected event did not
> appear, check "Severity: N" in the status bar first.

To change it, right-click in the "Current Events" panel, choose
**Severity → Custom...** and enter the minimum severity (0 means all events);
**Severity → All** removes the threshold.

## Acknowledging

Acknowledge an event by double-clicking its row or with *Acknowledge* in the
row's context menu; hold *Shift* or *Ctrl* to select and acknowledge several
rows at once. There is no keyboard shortcut for acknowledgement.

*Acknowledge All* in the event journal and the event panel acknowledges only
the events shown: events hidden by an area, severity or object filter stay
unacknowledged. Run from any other window, it acknowledges every
unacknowledged event the client receives and every client message — but not
events below the [severity threshold](#threshold).

> **Caution.** *Acknowledge All* is in the context menu of every window.
> Outside the event panel and the event journal it acknowledges **every**
> Server event the client has received, across the whole system — at once,
> with **no confirmation**, and for every workstation: acknowledgement is
> recorded on the Server. Acknowledge from the event panel or the journal. See
> [Common commands]({{ '/en/client/' | relative_url }}#common-commands).

Client messages are acknowledged on this workstation only: they are not sent
to the Server and do not appear at other workstations.

See the event panel section of the
[client page]({{ '/en/client/' | relative_url }}#events-panel) and the
[event journal]({{ '/en/client/events/' | relative_url }}).
