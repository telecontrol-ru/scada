---
title: Equipment
nav_order: 2
parent: Development
permalink: /en/dev/devices/
---

# Equipment configuration
{:.no_toc}

* TOC
{:toc}

The equipment window can be opened from the main menu with
`More -> Equipment`.

![]({{ '/img/hardware-tree.png' | relative_url }})

## Create devices

Directions are created from the context menu of the Equipment window:
right-click an empty part of the window, with nothing selected, and choose
`Create`:

* `IEC 60870-104 Link` — an IEC 60870-5-104 direction (Russian UI:
  «Канал IEC 60870-104»);
* `IEC 60870-101 Link` — an IEC 60870-5-101 direction;
* `Modbus direction`;
* `IEC 61850 device`.

![]({{ '/img/devices-create.png' | relative_url }})

An IEC 60870-5 device is added from the direction's context menu with
`Create -> IEC 60870 device`, a Modbus device with
`Create -> Modbus device`.

A new IEC 60870-5 direction is named "IEC 60870-104 Link" or "IEC 60870-101
Link"; rename it in its properties. A -104 direction is created as a TCP
client to `localhost`, port 2404, a -101 direction on serial port COM1.
Set its Transport to match your site.

A device or direction works only while its Disabled property is No. The
model default for that property is Yes, so check it after creating. The
`Enable` and `Disable` context-menu commands switch it as well.

## Device properties

To edit an element's parameters, open the element context menu and
choose `Properties`.

### Fields with a list of values {#enum-lists}

**WARNING: in this version the fields with a list of values — a direction's
Protocol and Mode, a TIT object's Conversion, a simulation signal's Type —
may offer no choices.** Such a field then cannot be changed from the Client,
and the default stated on this page applies. An IEC 60870-5 direction's
protocol is set by the command that creates it (`IEC 60870-104 Link` or
`IEC 60870-101 Link`), so an empty list does not get in the way there. If
you need another value in such a field (for example the Modbus TCP protocol
or Modbus retransmission mode), contact Telecontrol (mail@telecontrol.ru).

### Address map

Besides the tabs carrying its own parameters, a device has an **Address map**
tab — the list of signals read from it, with the columns Signal, Type, IOA and
NodeId. The tab is read-only: an address is set in the data item's own
parameters, in its Channel field (see
[Data items]({{ '/en/dev/data-items/' | relative_url }})). The map answers the
reverse question — which object is behind an address that arrived from the
device — and it is the same map the
[frame decode]({{ '/en/client/device-watch/' | relative_url }}) uses in the
device watch window.

### Checking the setup {#commissioning}

After creating a direction and a device, make sure data is flowing:

1. Disabled is No on both the direction and the device.
2. The indicator left of the device in the Equipment window shows the
   channel as enabled, not "device not responding". The `Metrics` context
   command shows the channel's service data.
3. The [Watch]({{ '/en/client/device-watch/' | relative_url }}) window shows
   the exchange. For IEC 60870-5, once connected, a general interrogation
   runs: <code>C_IC_NA_1</code> with its activation confirmation, the data, and the
   activation termination.
4. The values of objects bound to the device arrive without the quality
   flags `C` (no communication), `H` (connection error) and `K`
   (configuration error) — see
   [Quality flags]({{ '/en/architecture/' | relative_url }}#quality-flags).
5. For a controllable object, send a test command and check in Watch that the
   device confirmed it.

## MODBUS devices {#mbDevice}

Supported MODBUS function codes are described in
[Protocols]({{ '/en/protocols/' | relative_url }}#modbus).

### MODBUS direction parameters

<dl>

<dt>Protocol</dt>
<dd>RTU, ASCII or TCP. Default: RTU. See the
<a href="#enum-lists">warning on list fields</a>.</dd>

<dt>Mode</dt>
<dd>Polling — the SCADA polls the devices (default); retransmission — the SCADA
answers another system's requests. See the
<a href="#enum-lists">warning on list fields</a>.</dd>

<dt>Transport</dt>
<dd>The communication channel: a serial port or a TCP/UDP network, set in the
Transport window opened by the button in the field.</dd>

<dt>Request delay, ms</dt>
<dd>An artificial delay between the response and the next request. This
is useful for serial devices that switch slowly between transmit and
receive modes. Default: 0.</dd>

<dt>Disabled</dt>
<dd>Yes — the direction does not run.</dd>

</dl>

### MODBUS device parameters

<dl>

<dt>Address</dt>
<dd>The device (slave) address in MODBUS requests. Default: 1.</dd>

<dt>Suspend duration, ms</dt>
<dd>If several devices are polled cyclically and one device stops
responding, polling of that device can be suspended for a while so the
other devices can still be queried on time. Default: 30000.</dd>

<dt>Transmission retry attempts</dt>
<dd>The maximum number of repeated requests when the device does not
respond; after that, communication loss is reported. Default: 3.</dd>

<dt>Response timeout, ms</dt>
<dd>The maximum wait for a device response, in milliseconds, before the
request is retried. Default: 1000.</dd>

<dt>Disabled</dt>
<dd>Yes — the device is not polled.</dd>

</dl>

## MODBUS register addressing

Each MODBUS register is 16 bits wide and is treated as a single word.
Each word contains two bytes, `Hi` and `Lo`, stored in direct order:
`[Hi][Lo]`.

Two MODBUS registers form a 32-bit double word. Four MODBUS registers
form a 64-bit value.

Examples:

* single word: `0x10DE`
* double word: `0x10DE34A8`

The protocol uses four logical register groups:

| Register number (dec) | Register address (hex) | Register type | Command | Access |
|:---:|:---:|:---|:---:|:---:|
| `1-9999` | `0x0000-0x270F` | Coils | `0x01/0x05(0x0F)` | Read/write |
| `10001-19999` | `0x0000-0x270F` | Discrete Inputs | `0x02` | Read |
| `30001-39999` | `0x0000-0x270F` | Input Registers | `0x04` | Read |
| `40001-49999` | `0x0000-0x270F` | Holding Registers | `0x03/0x06(0x10)` | Read/write |

The decimal register number is not the same as the hexadecimal address
carried in MODBUS frames. The difference between them is the group
offset.

Depending on the register type, MODBUS values can be interpreted as:

* `BOOL`
* `INT8` / `UINT8`
* `INT16` / `UINT16`
* `INT32` / `UINT32`
* `FLOAT`
* `DOUBLE`

### Full MODBUS channel-address format

The full format contains one required field and several optional ones:

```text
[type_data[count]:]NUMBER[:bit[+bitcount]][;swapbytes]
```

Fields:

* `type_data` is one of `BOOL`, `INT8`, `UINT8`, `INT16`, `UINT16`,
  `INT32`, `UINT32`, `FLOAT`, `DOUBLE`
* `count` explicitly sets the number of registers to read
* `NUMBER` is the decimal register number
* `bit` is the first bit to mask, numbered from 1 to 16
* `bitcount` reads several bits starting at `bit`
* `;swapbytes` swaps `Hi` and `Lo` bytes inside a 16-bit word
* `;swapwords` swaps the 16-bit words inside a 32-bit word

Typical examples include:

* `FLOAT:30001`
* `INT16:41105;swapbytes`
* `UINT32:41105;swapwords`
* `UINT16:30001:1+7`
* `UINT16:30001:9+7`
* `BOOL:40003:5`
* `1`
* `10001`
* `30001`
* `40001`
* `HOLDREG:FLOAT:10001`

### Short MODBUS channel-address format

The short format uses the absolute decimal MODBUS register address
instead of the logical register number:

```text
TYPE_REGISTER:TYPE_DATA:ADDR
```

Fields:

* `TYPE_REGISTER` is one of `COIL`, `DISCINPUT`, `INPUTREG`, `HOLDREG`
* `TYPE_DATA` is one of the supported data types
* `ADDR` is the absolute decimal register address

This format is used when the actual hexadecimal register address is
higher than `0x270F`.

Examples:

* `HOLDREG:FLOAT:10001`
* `INPUTREG:FLOAT:10001`
* `HOLDREG:INT32:10001`
* `INPUTREG:UINT32:10001` (read with function `0x04`)
* `HOLDREG:DOUBLE:10001`

The two parameter screenshots below show where these MODBUS channel
definitions are entered for discrete and measured objects:

![]({{ '/img/ts-channel.png' | relative_url }})

![]({{ '/img/ti-channel.png' | relative_url }})

## IEC 60870-5 devices {#iecDevice}

The supported IEC 60870-5 ASDU identifiers are described in the
[Protocols]({{ '/en/protocols/' | relative_url }}#iec-60870) page.

### IEC 60870-5 direction parameters

Defaults are given in brackets.

<dl>

<dt>Protocol</dt>
<dd>IEC 60870-5-104 or IEC 60870-5-101, set by the command that created the
direction (<code>IEC 60870-104 Link</code> or <code>IEC 60870-101 Link</code>).</dd>

<dt>Mode</dt>
<dd>Polling (default), retransmission or listening. In this version the
direction's behaviour is decided mainly by Data collection and Transport: the
SCADA polls the devices when data collection is on and answers another
system's requests when it is off. Listening applies to IEC 60870-5-101 only.
See the <a href="#enum-lists">warning on list fields</a>.</dd>

<dt>Data collection</dt>
<dd>Yes (default) — the SCADA is the controlling station: after connecting it
sends the devices general interrogation and clock synchronisation commands.
No — it sends neither and answers another system's requests; this is how
<a href="#retransmission">retransmission</a> is set up.</dd>

<dt>Transport</dt>
<dd>The communication channel. The button in the field opens the Transport
window: Type (TCP Client, TCP Server, UDP Client, UDP Server, Serial Port),
Host and Port for a network, or the serial-port settings.</dd>

![]({{ '/img/iec-60870-5-transport.png' | relative_url }})

<dt>Event archive</dt>
<dd>Selects the archive used to store network traffic for later analysis
and saving to a text log file.</dd>

<dt>Anonymous mode</dt>
<dd>No (default) — on connecting, the SCADA opens a session for every device
configured under the direction and polls each at its own address. Yes — a
configured device is brought into service only when its first frame arrives,
and right after connecting the SCADA sends one general interrogation to the
broadcast common address 0xFFFF. Frames from addresses with no configured
device are dropped with the warning "Unknown device address".</dd>

<dt>Send window (k)</dt>
<dd>Maximum number of unacknowledged transmitted ASDUs (12).</dd>

<dt>Receive window (w)</dt>
<dd>Number of received ASDUs after which an acknowledgement is sent (8).</dd>

<dt>Transmission retry attempts</dt>
<dd>For IEC 60870-5-104: how many times an unacknowledged frame is
retransmitted on t1 expiry before the connection is closed (0).</dd>

<dt>Connection timeout (t0), s</dt>
<dd>Time allowed to establish the connection (30).</dd>

<dt>Send timeout (t1), s</dt>
<dd>Time allowed for the acknowledgement of a sent ASDU (15). When it (and
the retries) run out, the connection is closed and re-established.</dd>

<dt>Receive timeout (t2), s</dt>
<dd>Time before a receive acknowledgement is sent when no further data
arrives (10). <code>t2</code> must be smaller than <code>t1</code>.</dd>

<dt>Idle timeout (t3), s</dt>
<dd>Idle time after which a test frame is sent (20).</dd>

<dt>Acknowledgement timeout, s</dt>
<dd>Time allowed for the confirmation of a control or setpoint command and of
clock synchronisation (5). An unconfirmed control command fails; an
unconfirmed clock synchronisation drops the connection.</dd>

<dt>Operation timeout, s</dt>
<dd>Time within which a general or group interrogation must finish (20). If
it does not, the connection is dropped and re-established. It does not apply
to control commands.</dd>

<dt>Device address size</dt>
<dd>Size of the common ASDU address in bytes (2).</dd>

<dt>Cause of transmission size</dt>
<dd>Size of the cause-of-transmission field in bytes (2).</dd>

<dt>Object address size</dt>
<dd>Size of the information object address in bytes (3).</dd>

<dt>CRC protection</dt>
<dd>Yes — the SCADA expects two extra checksum bytes at the end of every
received IEC 60870-5-104 frame. This is a non-standard extension; turn it on
only when the equipment requires it (No).</dd>

<dt>Disabled</dt>
<dd>Yes — the direction does not run.</dd>

</dl>

The default field sizes are those of IEC 60870-5-104 and are not changed
when an IEC 60870-5-101 direction is created. For -101, set them from the
device documentation; typical values:

| Field size, bytes | 104 | 101 |
|:---|:---:|:---:|
| Information-object address | 3 | 2 |
| Device address (common ASDU address) | 2 | 1 |
| Cause of transmission | 2 | 1 |

### IEC 60870-5 device parameters

Defaults are given in brackets.

<dl>

<dt>Address</dt>
<dd>The device's common ASDU address (1).</dd>

<dt>Switch address</dt>
<dd>The link-layer address of the device for IEC 60870-5-101 (1).</dd>

<dt>Event archive</dt>
<dd>Selects the archive used to store traffic for one specific
device.</dd>

<dt>UTC time</dt>
<dd>Timestamp format: Yes — UTC, No — local time (No).</dd>

<dt>General interrogation on startup</dt>
<dd>Whether <code>C_IC_NA_1</code> is sent after the connection is established
(Yes).</dd>

<dt>General interrogation period, s</dt>
<dd>How often the general interrogation is repeated (0). 0 means no periodic
interrogation; only the startup one runs, if enabled.</dd>

<dt>Group 1...16 poll period, s</dt>
<dd>Per-group interrogation periods (0 — the group is not
interrogated).</dd>

<dt>Clock synchronisation on startup</dt>
<dd>Whether <code>C_CS_NA_1</code> is sent after the connection is established
(No).</dd>

<dt>Clock synchronisation period, s</dt>
<dd>How often clock synchronisation is repeated (0 — no periodic
synchronisation).</dd>

<dt>Disabled</dt>
<dd>Yes — the device is not polled.</dd>

</dl>

Interrogation and clock synchronisation run only while the direction's Data
collection is on.

### Retransmission to a dispatch centre {#retransmission}

Example: a dispatch centre (DC) receives SCADA data over IEC 60870-5-104,
with the SCADA as the controlled station — the TCP server the DC connects
to.

1. In the Equipment window, right-click an empty part of the window with
   nothing selected and choose `Create -> IEC 60870-104 Link`.
2. In the new direction's properties set:
   * Name — for example "DC";
   * Transport — in the Transport window: Type = TCP Server, Port = 2404 (or
     the port agreed with the DC), Host = `0.0.0.0` to accept connections on
     every network interface, or the IP address of the network card facing
     the DC. With `localhost`, which a new direction gets, only this computer
     can connect;
   * Data collection = No — the SCADA will not send the DC interrogation or
     clock synchronisation commands;
   * Mode — retransmission, if the list offers choices. For
     IEC 60870-5-104 an empty list (see the [warning](#enum-lists)) does not
     get in the way;
   * k, w, t1–t3 and the field sizes — as agreed with the DC;
   * Disabled = No.
3. Under the direction, `Create -> IEC 60870 device`. Set its Address — the
   common ASDU address the DC uses for the SCADA — and Disabled = No.
4. Select the device and open the `Transmission Table`. Add rules: each links
   a SCADA object (Source object) to an information object address in the DC
   (Receiver object address). The table is described in
   [Transmission rules]({{ '/en/client/workbench/' | relative_url }}#transmission);
   `Multiple Create` makes many rules at once (see
   [Data items]({{ '/en/dev/data-items/' | relative_url }}#bulk-create)).
5. Open the port in the firewall of the computer running the Server's
   IEC 104 process.
6. Check: once the DC connects, the
   [Watch]({{ '/en/client/device-watch/' | relative_url }}) window shows the
   exchange, and the DC's general interrogation returns the object values.

Modbus retransmission needs Mode = retransmission on the Modbus direction; if
that list is empty, contact Telecontrol.

## IEC 61850 devices {#iec-61850}

A device is created with `Create -> IEC 61850 device` from the Equipment
window's context menu (right-click an empty part of the window). Its
properties are Host — the device's network address — and Port (default
102), plus Disabled = No. Under the device an `IEC 61850 RCB` (report control
block) can be created, with its Address set to the block's reference in the
device model. The device model appears in the Model subtree.

Any model node exposes its bindable address through the `Properties`
command in the context menu.

Server objects can also be created by dragging IEC 61850 model objects
into an object group. Dragging a full functional-constraint group
creates all objects from that group. Dragging a model object onto an
existing SCADA object updates the existing binding.
