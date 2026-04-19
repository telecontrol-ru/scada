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
`Further -> Equipment`.

![]({{ '/img/devices-off.png' | relative_url }})

## Create devices

IEC 60870-5 directions can be added from the IEC subsystem context menu,
for example with `Create -> IEC-101 direction` or
`Create -> IEC-104 direction`.

![]({{ '/img/devices-create.png' | relative_url }})

An IEC 60870-5 device can then be added from the direction's context
menu with `Create -> Device`.

## Device parameters

To edit an element's parameters, open the element context menu and
choose `Parameters`.

## MODBUS devices

Supported MODBUS function codes are described in
[Protocols]({{ '/en/protocols/' | relative_url }}#modbus).

### MODBUS direction parameter

<dl>

<dt>Request delay, ms</dt>
<dd>An artificial delay between the response and the next request. This
is useful for serial devices that switch slowly between transmit and
receive modes.</dd>

</dl>

### MODBUS device parameters

<dl>

<dt>Pause duration, ms</dt>
<dd>If several devices are polled cyclically and one device stops
responding, polling of that device can be suspended for a while so the
other devices can still be queried on time.</dd>

<dt>Retry count</dt>
<dd>The maximum number of repeated requests when the device does not
respond.</dd>

<dt>Response timeout</dt>
<dd>The maximum wait time for a device response before retrying the
request.</dd>

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
* `INPUTREG:UINT32:10001`
* `HOLDREG:DOUBLE:10001`

The two parameter screenshots below show where these MODBUS channel
definitions are entered for discrete and measured objects:

![]({{ '/img/ts-channel.png' | relative_url }})

![]({{ '/img/ti-channel.png' | relative_url }})

## [](#iecDevice) IEC 60870-5 devices

The supported IEC 60870-5 ASDU identifiers are described in the
[Protocols]({{ '/en/protocols/' | relative_url }}#iec-60870) page.

### IEC 60870-5 direction parameters

<dl>

<dt>Event archive</dt>
<dd>Selects the archive used to store network traffic for later analysis
and saving to a text log file.</dd>

<dt>Anonymous mode</dt>
<dd>Switches the system from balanced mode to unbalanced mode, where the
device establishes communication itself and explicit `STARTDT ACT`
commands are not required after the link is opened.</dd>

<dt>Send window (K)</dt>
<dd>Maximum number of transmitted ASDUs before acknowledgement is
required.</dd>

<dt>Receive window (W)</dt>
<dd>Number of received ASDUs after which an acknowledgement is sent.</dd>

<dt>Retry count</dt>
<dd>Maximum number of retries before communication loss is reported.</dd>

<dt>Standard IEC 60870-5 field sizes</dt>
<dd></dd>

| Field size, bytes | 104 | 101 |
|:---|:---:|:---:|
| Information-object address | 3 | 2 |
| Device address (common ASDU address) | 2 | 1 |
| Cause of transmission | 2 | 1 |

<dt>Operation timeout, s</dt>
<dd>Timeout for commands such as control operations and general
interrogation.</dd>

<dt>Transmission timeout (T1), s</dt>
<dd>Time allowed for a response or ASDU delivery acknowledgement.</dd>

<dt>Acknowledgement timeout, s</dt>
<dd>Time allowed for command completion acknowledgement such as
`ACTIVATION TERMINATION`.</dd>

<dt>Receive timeout (T2), s</dt>
<dd>Time before a receive acknowledgement is sent when no further data
arrives. `T2` must be smaller than `T1`.</dd>

<dt>Idle timeout (T3), s</dt>
<dd>Time before a test frame is sent on an idle connection.</dd>

<dt>Connection timeout (T0), s</dt>
<dd>Time allowed to establish the connection.</dd>

<dt>Transport</dt>
<dd>Physical-transport settings for the device channel:</dd>

![]({{ '/img/iec-60870-5-transport.png' | relative_url }})

</dl>

### IEC 60870-5 device parameters

<dl>

<dt>Event archive</dt>
<dd>Selects the archive used to store traffic for one specific
device.</dd>

<dt>Address</dt>
<dd>The device common address carried in the ASDU frame.</dd>

<dt>Link address</dt>
<dd>An additional link-layer address for the device.</dd>

<dt>UTC time</dt>
<dd>Selects UTC or local time for timestamps.</dd>

<dt>Group interrogation periods 1...16, s</dt>
<dd>Per-group interrogation periods using the standard general
interrogation grouping model.</dd>

<dt>General interrogation period, s</dt>
<dd>How often `C_IC_NA_1` is sent. A value of `0` means it is sent only
once after connection establishment.</dd>

<dt>Clock synchronization period, s</dt>
<dd>How often `C_CS_NA_1` is sent. A value of `0` means it is sent only
once after the connection is established.</dd>

<dt>General interrogation on startup</dt>
<dd>If disabled, no general interrogation is sent after the connection
is opened.</dd>

<dt>Clock synchronization on startup</dt>
<dd>If disabled, no clock synchronization is sent after the connection
is opened.</dd>

</dl>

## IEC 61850 devices

The IEC 61850 model can be browsed directly. Any model node can expose
its bindable address through the `Parameters` command in the context
menu.

Server objects can also be created by dragging IEC 61850 model objects
into an object group. Dragging a full functional-constraint group
creates all objects from that group. Dragging a model object onto an
existing SCADA object updates the existing binding.

## Translation status

This English page is now a substantially fuller engineering reference.
The Russian page still remains the fullest source for low-level device
details.
