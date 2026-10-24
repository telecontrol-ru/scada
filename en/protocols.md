---
title: Protocols
nav_order: 5
permalink: /en/protocols/
---

# Supported protocols
{:.no_toc}

* TOC
{:toc}

For all supported field protocols, device communication can be examined
through the
[Device watch]({{ '/en/client/device-watch/' | relative_url }}) and
[Debugger]({{ '/en/client/debugger/' | relative_url }}) tools in the
Client.

## MODBUS {#modbus}

MODBUS is a master-slave communication protocol. Telecontrol SCADA
supports MODBUS over RS-485, RS-422, RS-232, and Ethernet TCP/IP,
covering MODBUS RTU and TCP deployments. The MODBUS ASCII variant is not
implemented in this version.

The Server exchanges telemetry and control values through standard
MODBUS function codes and maps them to SCADA objects. The table below
(in Russian) lists the standard function codes:

![]({{ '/img/MODBUS_func.png' | relative_url }})

{: .note }
> The SCADA does not use every function in the table: it reads with 0x01,
> 0x02, 0x03 and 0x04, writes a single coil with 0x05, and writes holding
> registers with 0x10, even a single one. Functions 0x06 and 0x0F are not
> used; in retransmission mode the SCADA answers a request carrying one of
> them with an ILLEGAL FUNCTION exception.

See also the engineering reference for
[MODBUS devices]({{ '/en/dev/devices/' | relative_url }}).

## IEC 60870-5 {#iec-60870}

IEC 60870-5 directions define data channels such as a network endpoint
or serial port. One direction can serve multiple devices.

Supported application-layer ASDU types include:

| ASDU label | Type ID | Description |
|:---|:---:|:---|
| `M_SP_NA_1` | 1 | Single-point information (0 – OFF, 1 – ON) |
| `M_SP_TA_1` | 2 | Single-point with timestamp |
| `M_DP_NA_1` | 3 | Double-point information (0 – indeterminate or intermediate, 1 – OFF, 2 – ON, 3 – indeterminate); see the note below |
| `M_BO_NA_1` | 7 | 32-bit bitstring — **not supported in this version**: values from these ASDUs do not reach objects |
| `M_ME_NA_1` | 9 | Normalized measured value — arrives as a signed 16-bit integer, see the note below |
| `M_ME_NB_1` | 11 | Scaled measured value (signed 16-bit integer) |
| `M_ME_TB_1` | 12 | Scaled measured value (integer) with timestamp |
| `M_ME_NC_1` | 13 | Short floating-point measured value (float) |
| `M_IT_NA_1` | 15 | Integrated total (int32) |
| `M_SP_TB_1` | 30 | Single-point with CP56Time2a |
| `M_DP_TB_1` | 31 | Double-point with CP56Time2a |
| `M_ME_TD_1` | 34 | Normalized value with CP56Time2a — as `M_ME_NA_1` |
| `M_ME_TE_1` | 35 | Scaled value (integer) with CP56Time2a |
| `M_ME_TF_1` | 36 | Float value with CP56Time2a |
| `M_IT_TB_1` | 37 | Integrated total with CP56Time2a |
| `C_SC_NA_1` | 45 | Single command (0 – OFF, 1 – ON) |
| `M_EI_NA_1` | 70 | End of initialization |
| `C_IC_NA_1` | 100 | General interrogation |
| `C_CI_NA_1` | 101 | Counter interrogation |
| `C_CS_NA_1` | 103 | Time synchronization |
| `C_RP_NA_1` | 105 | Reset process |
| `P_ME_NA_1` | 110 | Parameter write, normalized (16-bit integer) |
| `P_ME_NB_1` | 111 | Parameter write, scaled (16-bit integer) |
| `P_ME_NC_1` | 112 | Parameter write, short floating point (float) |

**WARNING:** in this version normalized values (`M_ME_NA_1`, `M_ME_TD_1`)
are not converted to the −1…+1 range: the TIT object receives the signed
16-bit integer exactly as transmitted (1.0 arrives as 32767, −1.0 as
−32768). To get the normalized value, create a TIT object without a device
and enter a [formula]({{ '/en/formulas/' | relative_url }}) in its Channel
field, for example `{IEC_DEV.1!115} / 32768`, where `IEC_DEV.1` is the
device identifier and 115 the information object address.

Double-point information (`M_DP_NA_1`, `M_DP_TB_1`) gives the TS object the
value 1 only in position 2 (ON); in positions 0, 1 and 3 the object gets 0.
Positions 0 and 3 are additionally flagged with the bad-quality flag
(Russian UI: «Недост»), which tells them apart from OFF.

For control operations, Telecontrol SCADA uses:

* `C_SC_NA_1` for discrete control objects
* `P_ME_NC_1` for measured-value control objects

The ASDU type can be overridden in the output field with the format
`type:address`, where `type` is one of:

* `BOOL` to use `C_SC_NA_1`
* `INT16` to use `P_ME_NB_1`
* `FLOAT` to use `P_ME_NC_1`

This override is useful when a measured object must be controlled with
`C_SC_NA_1` instead of the default measured-value command ASDU.

When UDP server mode is used, multiple remote devices can share one
direction. Devices are identified by the remote IP address and port, so
separate listening ports are not required for each one. UDP mode also
supports devices that send datagrams built from multiple IEC messages.

See also the engineering reference for
[IEC 60870-5 devices]({{ '/en/dev/devices/' | relative_url }}).

## IEC 61850 {#iec-61850}

IEC 61850 support provides transparent access to the device information
model. See also the engineering reference for
[IEC 61850 devices]({{ '/en/dev/devices/' | relative_url }}#iec-61850).

Data is acquired only through subscriptions to report control blocks
(RCB — unbuffered, BRCB — buffered) over MMS. The Server never reads values
directly: an object whose data is not in any subscribed report receives no
value. To enable data acquisition:

1. Under the IEC 61850 device in the Equipment window, create a report
   control block with *Create — IEC 61850 RCB* (Russian UI: «Создать — RCB
   МЭК-61850») and enter in its Address field the block's MMS address in the
   device model: the logical device, the logical node (usually `LLN0`), the
   functional constraint `RP` (unbuffered) or `BR` (buffered) and the block
   name, for example `LD0/LLN0$RP$urcbA01` or `LD0/LLN0$BR$brcbA01`. The
   block name and the contents of its dataset are set by the device's own
   configuration.
2. Bind TS and TIT objects to members of that block's dataset. The address
   in the object's Channel field must match a dataset member **exactly**,
   including letter case and nesting level: the member `LD0/GGIO1$ST$Ind1`
   and the address `LD0/GGIO1$ST$Ind1$stVal` are different addresses, and no
   value arrives for the second. Dragging an object from the Model subtree
   writes the address in the right form; just check that the object is a
   member of the block's dataset.

When the connection is established, the Server reads the block's
parameters and its dataset from the device, enables reporting and requests
a general interrogation (GI) through the block: a device that supports GI
immediately sends the current values of every dataset member, followed by
spontaneous reports of changes. Messages about the block subscription and
its dataset are shown in the
[Device watch]({{ '/en/client/device-watch/' | relative_url }}) window.

Object binding uses MMS addresses in the format
`LogicalDevice/LogicalNode$FC$DataObject`. TS objects bind to `FC=ST`
objects, TIT objects to `FC=MX` objects.

**WARNING:** in this version only the following are read correctly:

* single-point status (class SPS, boolean `stVal`) for TS objects;
* `FC=MX` measurements with a floating-point value (`mag.f`, for example
  class MV) for TIT objects.

Double-point positions (classes DPS and DPC, for example `Pos`, type
Dbpos) are read wrongly: the TS object always shows "on" when bound to the
data object, or gets no value when bound to `stVal`. Do not use such
objects to show switchgear positions; if you need this, contact
Telecontrol LLC (mail@telecontrol.ru).

**WARNING:** in this version remote control (`FC=CO`) and the Poll Device
command do not work for IEC 61850 devices: the Server rejects them with an
error. Switchgear cannot be controlled through an IEC 61850 device in this
version.

**WARNING:** only UTC timestamps are supported. If the device uses a
different time zone, value updates will be affected.

See the [IEC 61850 article](https://en.wikipedia.org/wiki/IEC_61850) for a
description of the protocol.
