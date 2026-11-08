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

| Protocol | Process | Collecting data from devices | Serving data to another system |
|:---|:---|:---|:---|
| [MODBUS RTU, ASCII, TCP](#modbus) | `scada-modbus` | master | slave — [MODBUS retransmission]({{ '/en/dev/devices/' | relative_url }}#modbus-retransmission) |
| [IEC 60870-5-101, -104](#iec-60870) | `scada-iec104` | master; for -101 also listening on a line | controlled station — [retransmission to a dispatch centre]({{ '/en/dev/devices/' | relative_url }}#retransmission) |
| [IEC 61850](#iec-61850) | `scada-iec61850` | client | no |
| [OPC DA](#opc) (Windows) | `scada-opc` | client of external OPC servers | no |
| [Vidicon](#vidicon) (Windows) | `scada-vidicon` | the objects of a Vidicon SCADA project, through its OPC server | no |
| OPC UA | `scada-proxy` | — | [OPC UA server for external systems]({{ '/en/server/' | relative_url }}#opcua), port 4840 |

## MODBUS {#modbus}

MODBUS is a master-slave communication protocol. Telecontrol SCADA
supports MODBUS over RS-485, RS-422, RS-232, and Ethernet TCP/IP,
covering all three variants: MODBUS RTU, MODBUS ASCII and MODBUS TCP.

The Server exchanges telemetry and control values through standard
MODBUS function codes and maps them to SCADA objects. The table below
(in Russian) lists the standard function codes:

![]({{ '/img/MODBUS_func.png' | relative_url }})

{: .note }
> The SCADA does not use every function in the table: it reads with 0x01,
> 0x02, 0x03 and 0x04, writes a single coil with 0x05, and writes holding
> registers with 0x10, even a single one. Functions 0x06 and 0x0F are not
> used when polling. In retransmission mode the SCADA accepts writes with
> 0x05, 0x06, 0x0F and 0x10, and answers a request carrying any other
> function with an ILLEGAL FUNCTION exception.

MODBUS objects cannot be controlled in two stages: the Server refuses the
select, so set [Two-stage control]({{ '/en/dev/data-items/' | relative_url }}#two-stage-control)
to No on them. The Client sets No on new MODBUS objects by itself.

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
| `M_BO_NA_1` | 7 | 32-bit bitstring — the TIT object receives an unsigned integer whose least significant bit is bit 1 of the string |
| `M_ME_NA_1` | 9 | Normalized measured value — scaled to the −1…+1 range, see the note below |
| `M_ME_NB_1` | 11 | Scaled measured value (signed 16-bit integer) |
| `M_ME_TB_1` | 12 | Scaled measured value (integer) with timestamp |
| `M_ME_NC_1` | 13 | Short floating-point measured value (float) |
| `M_IT_NA_1` | 15 | Integrated total (int32) |
| `M_SP_TB_1` | 30 | Single-point with CP56Time2a |
| `M_DP_TB_1` | 31 | Double-point with CP56Time2a |
| `M_BO_TB_1` | 33 | 32-bit bitstring with CP56Time2a — as `M_BO_NA_1` |
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
| `P_ME_NA_1` | 110 | Parameter write, normalized (−1…+1) |
| `P_ME_NB_1` | 111 | Parameter write, scaled (16-bit integer) |
| `P_ME_NC_1` | 112 | Parameter write, short floating point (float) |

Normalized values (`M_ME_NA_1`, `M_ME_TD_1`, `P_ME_NA_1`) are scaled to
the −1…+1 range: the signed 16-bit integer the device sends is divided by
32768, so the TIT object receives, for example, 0.5 rather than 16384. The
largest value is 32767/32768 ≈ 0.99997; exactly +1.0 cannot be carried by
this type. On retransmission the value is passed on without loss.

{: .note }
> Earlier versions delivered a normalized value as the raw integer (32767
> rather than 1.0). If the project rescaled it with a formula such as
> `{IEC_DEV.1!115} / 32768`, or with a linear conversion from
> −32768…32767, remove that rescaling after the upgrade — otherwise the value
> is divided twice.

Double-point information (`M_DP_NA_1`, `M_DP_TB_1`) gives the TS object the
value 1 only in position 2 (ON); in positions 0, 1 and 3 the object gets 0.
Positions 0 and 3 are additionally flagged with the bad-quality flag
(Russian UI: «Недост»), which tells them apart from OFF.

For control operations, Telecontrol SCADA uses:

* `C_SC_NA_1` for discrete control objects
* `P_ME_NC_1` for measured-value control objects

Only a single command, `C_SC_NA_1`, can be carried out in two stages. A
set-point command — `P_ME_NC_1` by default, or the type an `INT16:` or
`FLOAT:` override names (see below) — is refused by the Server already at
the select stage, with nothing sent to the device. So on objects controlled
with such a command (usually TIT objects), set
[Two-stage control]({{ '/en/dev/data-items/' | relative_url }}) to No.
The Client sets No by itself on new TIT objects, whether created one at a
time or with the [Multiple Create]({{ '/en/dev/data-items/' | relative_url }}#bulk-create)
wizard.

With [two-stage control]({{ '/en/dev/data-items/' | relative_url }}) of a TS
object, `C_SC_NA_1` is sent first with the select flag (S/E = 1) and then
with the execute flag. If the operator declines to execute, the Server
releases the selection: it repeats the same command with cause of
transmission 8 (deactivation) and waits for the device's confirmation with
cause 9. If the device refuses to release it, the selection stays in force
until the device's own select timeout, and the Client says so in the current
events panel.

In retransmission mode the Server receives the DC's commands itself. When the
DC releases a selection (a command with cause of transmission 8 after a
confirmed select), the Server releases the selection on the object's source
device the same way and confirms the deactivation to the DC with cause 9 only
once the source device has answered; if the device refuses, the confirmation
is negative. When the Server refuses the select of the source object (for example, an
object of a MODBUS device, or one whose command is not `C_SC_NA_1`), the DC
gets a negative confirmation already for its select and must control such an
object with a command without select; a release on such an object is
confirmed at once. Deactivating a command already
being executed only stops the reply to the DC: the execution on the device
cannot be undone.

The ASDU type can be overridden in the Control channel with the format
`type:address`, where `type` is one of:

* `BOOL` to use `C_SC_NA_1`
* `INT16` to use `P_ME_NB_1`
* `FLOAT` to use `P_ME_NC_1`

This override is useful when a measured object must be controlled with
`C_SC_NA_1` instead of the default measured-value command ASDU.

The Client chooses "Two-stage control" by the object's type, not by the
override: on a TS object controlled through an `INT16:` or `FLOAT:` override,
set it to No by hand, or a version 2.6 Server refuses the select (a 2.5.7
Server confirms it without sending anything to the device); a TIT object with
a `BOOL:` override gets No from the Client, although `C_SC_NA_1` can also be
executed in two stages — if a select-before-operate is needed, set Yes by
hand. See [Two-stage control]({{ '/en/dev/data-items/' | relative_url }}#two-stage-control).

When UDP server mode is used, multiple remote devices can share one
direction. Devices are identified by the remote IP address and port, so
separate listening ports are not required for each one. UDP mode also
supports devices that send datagrams built from multiple IEC messages.

See also the engineering reference for
[IEC 60870-5 devices]({{ '/en/dev/devices/' | relative_url }}).

## IEC 61850 {#iec-61850}

IEC 61850 support provides transparent access to the device information
model. See the description of
[IEC 61850 devices]({{ '/en/client/' | relative_url }}#iec-61850) in the
Client and the engineering reference for
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

Report control blocks can be created, changed and deleted at any time,
including on an enabled device: the Server resubscribes to the block
without restarting the process. A block's Address must carry the
functional constraint `RP` or `BR`; the Server does not subscribe a block
with any other functional constraint, and says so in the Device watch
window.

Object binding uses MMS addresses in the format
`LogicalDevice/LogicalNode$FC$DataObject`. TS objects bind to `FC=ST`
objects, TIT objects to `FC=MX` objects.

Values are read as follows:

* `FC=ST` status with a boolean `stVal` (classes SPS, SPC) as on/off;
* double-point positions (classes DPS and DPC, for example `Pos`, type
  Dbpos): the TS object shows "on" only in the ON position; the
  intermediate and bad positions show as "off", as for IEC 60870-5
  double-point information. The object can be bound either to the data
  object (`LD0/XCBR1$ST$Pos`) or to its `stVal` attribute
  (`LD0/XCBR1$ST$Pos$stVal`), whichever is a member of the block's dataset;
* integer status (for example classes INS, INC) as a number;
* `FC=MX` measurements with a floating-point value (`mag.f`, for example
  class MV) for TIT objects.

Remote control is sent to a controllable data object (classes SPC, DPC,
INC, APC, BSC). The object's control address may name the data object in the CO or
the ST functional constraint — `LD0/CSWI1$CO$Pos`, `LD0/CSWI1$ST$Pos` or
`LD0/CSWI1$ST$Pos$stVal`: in every case the command addresses the data
object `Pos`. The Server reads the control model (`ctlModel`) and the
command value type from the device:

* for a select-before-operate device (SBO, `sbo-with-normal-security` or
  `sbo-with-enhanced-security`), leave
  [Two-stage control]({{ '/en/dev/data-items/' | relative_url }}) enabled
  on the object (the default is Yes) — without the select stage the device
  rejects the command. If the operator declines to execute, the Server
  releases the selection with the control model's Cancel service;
* for direct control (`direct-with-normal-security`,
  `direct-with-enhanced-security`) only a one-stage command works: the
  Server refuses a select without sending anything to the device, so set
  Two-stage control to No on the object;
* an object whose model is `status-only` takes no commands; the Server
  rejects them.

The command value must fit the object's `ctlVal` type:

* 0 or 1 for a boolean (SPC, DPC);
* an integer for INC;
* a number for an analogue setpoint (APC). The Server reads from the
  device's model whether the setpoint is an integer (`i`) or a
  floating-point number (`f`); an integer setpoint does not take a
  fraction. A setpoint whose model carries both fields, `i` and `f`, is not
  sent: the integer field is scaled by the object's own settings (`sVC`);
* for step control (BSC, for example a transformer tap changer), the
  command number: 1 is a step down (lower), 2 a step up (higher), 0 stop.
  An on/off boolean does not fit such an object; use a control command
  with a value.

Any other value is rejected by the Server without being sent to the device.
Select and its release (Cancel) work for APC and BSC the same way as for
SPC and DPC.

If the device refuses the select or the execute (for example, because of its
own interlock or a control-model mismatch), the Client reports "IEC 61850
protocol error" («Ошибка протокола МЭК-61850»); the device's answer is
visible in the [Device watch]({{ '/en/client/device-watch/' | relative_url }})
window.

The Poll Device command requests a general interrogation (GI) through every
report control block of the device.

IEC 61850 timestamps are always UTC by the standard: the protocol has no
time-zone field, and the Server does not shift them. The device's clock must
therefore run on UTC, usually synchronised by SNTP. If the device's clock is
set to local time, value and event timestamps are off by the difference from
UTC; correct it in the device's settings. Timestamps from first-edition
devices (type BinaryTime) are supported too.

An IEC 61850 device cannot be a
[retransmission]({{ '/en/dev/devices/' | relative_url }}#retransmission)
destination: the IEC 61850 process only polls devices.

See the [IEC 61850 article](https://en.wikipedia.org/wiki/IEC_61850) for a
description of the protocol.

## OPC DA (Windows) {#opc}

The `scada-opc` process runs on Windows only and connects to external OPC
servers over OPC DA (Classic OPC): the external servers' tags appear in the
Server's address space and are bound to objects. The Server refuses the
select of two-stage control on an OPC object, so set
[Two-stage control]({{ '/en/dev/data-items/' | relative_url }}) to No on such
objects. The Client sets No on new OPC objects by itself; check objects
created by earlier Client versions. See [OPC client on Windows]({{ '/en/server/' | relative_url }}#opc-classic).

## Vidicon integration (Windows) {#vidicon}

The `scada-vidicon` process runs on Windows only and links the Server with
the Telecontrol Vidicon system for migrating existing projects: the Server
imports objects from the Vidicon configuration into its address space. See
[Vidicon integration]({{ '/en/server/' | relative_url }}#vidicon).
