---
title: Alarm annunciation
nav_order: 4
parent: Client
permalink: /en/client/alarms/
---

# Alarm annunciation
{:.no_toc}

* TOC
{:toc}

The client announces unacknowledged events in several ways: tiles in the
context strip, opening the event panel, flashing the window, a tone and a
spoken message. The tiles are always on; the rest are switched
on and off on the settings screen: **Settings → Settings... → Events & alarms**.

These preferences live in the user's profile, which is saved on this computer
and, when the client exits or on *More → Disconnect from Server*, on the
Server (see
[Shift handover]({{ '/en/client/' | relative_url }}#shift-change)). Since
Client 2.6.8 **Speech** is kept in the profile too; Clients 2.6.0–2.6.4 did not
save it, so it was on again at every sign-in.

## Which events raise the alarm {#escalation}

Not every unacknowledged event sounds. The annunciators fall into two groups.

**Unacknowledged events** are announced by the tiles in the context strip, the
event panel and the window flash.

**The tone and the spoken message** are on only while at least one of these
holds:

* at least one unacknowledged event is **critical** (severity 800 and above);
* **more than ten** events are unacknowledged (an "alarm flood"), whatever
  their severity.

> **Caution.** Warnings (severity 600 to 799) and routine events do not sound
> on their own: only the tiles, the event panel and the window flash announce
> them. A silent client does **not** mean nothing is unacknowledged — check the
> "Unacknowledged" tile in the context strip and the event panel.

The client's own messages ("Local Event") are events too: reports of a
successful command, of the connection to the Server being lost and restored,
of errors. They count according to their severity:

* **the client's warnings and errors** — the loss of the connection to the
  Server or a failed reconnection, for example — count just like the Server's
  events: in the severity tiles ("Critical N", "Warning N",
  "Unacknowledged N"), in the "Unacknowledged critical" and "Alarm flood"
  indicators, and towards both conditions above. An error message is critical
  and so sounds, while a single warning does not sound on its own;
* **a disconnection because the same credentials signed in at another
  workstation** ("Disconnected from server … These credentials are being used
  to log in from another workstation.") is reported as an error, so it is
  critical and sounds;
* **the client's information messages** — a successful command or the
  connection being restored, for example — are not in the tiles and sound
  neither the tone nor the spoken message.

The client's information messages are visible only in the event panel and the
journal until they are acknowledged. The tiles and the tone count the same
events, so the tone does not sound while the "Unacknowledged" tile reads zero. Acknowledge client
messages in the event panel just like the Server's events.

The event panel's [severity threshold](#threshold) does not affect the tiles
or annunciation: an event below it is hidden from the panel only.

## The event panel opens by itself

**Show Events on Arrival** (on by default).

When a new unacknowledged event arrives, the client opens the [event
panel]({{ '/en/client/' | relative_url }}#events-panel) without taking focus:
the operator keeps working in the current window while the list appears beside
it. An event that arrives already acknowledged does not open the panel.

With the option off, the panel opens only with **More → Events**. The
"Unacknowledged" tile in the context strip keeps counting either way, so nothing is
lost — the events simply stop asking for attention on their own.

## And closes by itself

**Hide Events on Acknowledge** (on by default).

The panel closes once the last event is acknowledged, even if acknowledged
alarms that still stand ("Active, acknowledged"; see
[Alarm states]({{ '/en/client/events/' | relative_url }}#alarm-states)) remain
in it. **All** events count, not
only those from the server: the client's own local messages — "Connection to
server established. Login successful.", for one — are unacknowledged until the
operator acknowledges them, and they hold the panel open.

With the option off, the panel stays on screen until the operator closes it.

## The alarm tone {#tone}

**Sound Alarm on Event** (on by default since Client 2.6.11).

The setting is kept in the user's profile. For an account whose profile has
never been saved, the tone is on. Once a profile is saved, the client takes
the setting from it: a tone switched off under that account stays off.

> **Caution.** Clients before 2.6.11 had the tone off by default, and a
> profile saved by such a client keeps it off even if nobody switched it off.
> So after upgrading the Client, check under each operator account that the
> tone is on: **Settings → Settings... → Events & alarms → Sound Alarm on
> Event**. Spoken announcements exist on Windows only, so on macOS this tone
> is the only audible alarm: while it is off, the client on macOS raises
> alarms silently.
>
> With a 2.5.7 Server the profile is kept on the computer, one per account,
> so check the tone under each account **on each computer** it has already
> been used on. This is needed once, not at every shift handover. An operator
> has no safe way to raise a critical event, so the engineer who configures
> the project raises a test alarm (see the check [below](#tone-check)).

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
> make sure *Sound Alarm on Event* is on, raise a critical event (severity 800 or
> above) and make sure the tone is heard. A convenient way is a test object
> not bound to equipment: the engineer sets its
> [Severity]({{ '/en/dev/data-items/' | relative_url }}) to 800 (a 2.5.7
> Server uses a 0–100 scale — set 80) and performs
> [Manual input]({{ '/en/client/' | relative_url }}#manual-input) on it with
> the "Lock:" box ticked; the manual-input event carries the object's
> severity. Afterwards acknowledge
> the event. To repeat the test, first remove manual input from the object
> with *Unlock* (available only when the input was made with the lock): another manual input on an object already in manual mode may
> raise no new event. Instead of manual input you can also change one of the
> object's limits so that its value crosses it. Keep a sound assigned to the Windows
> "Exclamation" event and the volume up on that computer, and test the tone
> again after changing the Windows sound scheme or the audio device.
{: #tone-check}

## Window flash

**Flash Main Window on Event** (off by default).

Whenever a new unacknowledged event arrives, the client asks the desktop for
attention: the taskbar button flashes on Windows, the Dock icon bounces on
macOS. This happens on every arrival, including while older events are still
unacknowledged.

The request takes effect only if the client's window is **not** the active one
at that moment, and the system withdraws it as soon as the window is brought to
the front. An event that arrives while the client's window is active does not
flash it; the next event to arrive after the operator has switched to another
program does.

The window flash is only an extra cue; the tiles in the context strip and the
event panel are what reliably show unacknowledged events.

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

Spoken announcements are switched on and off on the settings screen with
**Speech** in **Events & alarms**, next to the tone. The choice is kept in the
profile (in Clients 2.6.0–2.6.4 only until the next sign-in). On a computer without a
speech-synthesis voice the switch is shown disabled.

## What is always visible {#always-visible}

The alarm counts live only in the context strip at the top; since Client
2.6.11 the status bar at the bottom of the window does not repeat them. The
only alarm-related text in the status bar is "Panel filter: severity ≥ N"
(«Фильтр панели: важность ≥ N»), shown while the event panel has a
[severity threshold](#threshold) set.

![Severity tiles]({{ '/img/severity-tiles.png' | relative_url }})

*Severity tiles in the context strip*

The context strip at the top shows the "Critical N", "Warning N" and
"Unacknowledged N" tiles — for the Server's events and the client's own
warnings and errors. The tiles answer different questions:

* **"Critical N" and "Warning N"** — how many alarms of that severity
  **stand** right now: unacknowledged ones and acknowledged ones whose value is
  still outside the limit ("Active, acknowledged"). An alarm back to normal is
  not in them, even if nobody has acknowledged it yet;
* **"Unacknowledged N"** — how many events of any severity **nobody has
  acknowledged** yet, alarms already back to normal ("Returned to normal,
  unacknowledged") included.

So acknowledging an alarm that still stands lowers the "Unacknowledged" tile
but not the tile of its severity; see
[Alarm states]({{ '/en/client/events/' | relative_url }}#alarm-states). Beside
the tiles appear:

* **"Unacknowledged critical"** — a flashing indicator while at least one
  critical event (severity 800 and above) is unacknowledged, one already back
  to normal included. It stops flashing once every critical event is
  acknowledged;
* **"Alarm flood (N)"** — while more than ten events are unacknowledged.

The tiles stay in place either way.

## Severity threshold {#threshold}

The severity threshold of the "Current Events" panel hides events below it
from that panel. It acts **on the panel only**: the client still receives every
event, and an event below the threshold

* is in the context strip's tiles and indicators;
* sounds the tone and the spoken announcement and flashes the window under the
  usual rules;
* makes the object's dot in the object tree blink;
* is acknowledged by *More → Acknowledge All* in the main menu and by an
  object's *Acknowledge*;
* is shown in the [event journal]({{ '/en/client/events/' | relative_url }}),
  which has a severity filter of its own.

The panel's own *Acknowledge All* acknowledges only the events the panel shows,
so it leaves events below the threshold unacknowledged.

> **Caution.** The threshold is kept in the profile and stays in force until
> *All* is chosen. If the tiles show an event the panel does not, look at the
> status bar first: while a threshold is set, it shows "Panel filter:
> severity ≥ N", where N is the threshold. With no such text there is no
> threshold and the panel shows every event.

To change it, right-click in the "Current Events" panel, choose
**Severity → Custom...** and enter the minimum severity (0 or 1 means all
events, and the status-bar text goes away); **Severity → All** removes the
threshold.

## Acknowledging

Acknowledge an event with *Acknowledge* in the row's context menu or the
*Acknowledge* button on the event's card in the inspector; hold *Shift* or
*Ctrl* to select and acknowledge several rows at once. Since Client 2.6.11 a
double-click on a row acknowledges nothing: it brings the inspector forward
with that event. There is no keyboard shortcut for acknowledgement.

*Acknowledge All* in the event journal and the event panel acknowledges only
the events shown: events hidden by an area, severity or object filter stay
unacknowledged. When more than one such event is shown, it asks for
confirmation first, with "No" as the default button. *More → Acknowledge All* in the main menu works differently —
across the whole system and for every workstation, including events below the
panel's [severity threshold](#threshold); see
[Common commands]({{ '/en/client/' | relative_url }}#common-commands).

Client messages are acknowledged on this workstation only: they are not sent
to the Server and do not appear at other workstations.

See the event panel section of the
[client page]({{ '/en/client/' | relative_url }}#events-panel) and the
[event journal]({{ '/en/client/events/' | relative_url }}).
