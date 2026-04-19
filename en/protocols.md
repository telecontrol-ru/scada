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

## [](#modbus) MODBUS

MODBUS is a master-slave communication protocol. Telecontrol SCADA
supports MODBUS over RS-485, RS-422, RS-232, and Ethernet TCP/IP,
covering MODBUS RTU, ASCII, and TCP deployments.

The Server exchanges telemetry and control values through standard
MODBUS function codes and maps them to SCADA objects.

![]({{ '/img/MODBUS_func.png' | relative_url }})

See also the engineering reference for
[MODBUS devices]({{ '/en/dev/devices/' | relative_url }}).

## [](#iec-60870) IEC 60870-5

IEC 60870-5 directions define data channels such as a network endpoint
or serial port. One direction can serve multiple devices.

Supported application-layer ASDU types include:

| ASDU label | Type ID | Description |
|:---|:---:|:---|
| `M_SP_NA_1` | 1 | Single-point information |
| `M_SP_TA_1` | 2 | Single-point with timestamp |
| `M_DP_NA_1` | 3 | Double-point information |
| `M_BO_NA_1` | 7 | 32-bit bitstring |
| `M_ME_NA_1` | 9 | Normalized measured value |
| `M_ME_NB_1` | 11 | Scaled measured value |
| `M_ME_TB_1` | 12 | Scaled measured value with timestamp |
| `M_ME_NC_1` | 13 | Short floating-point measured value |
| `M_IT_NA_1` | 15 | Integrated total |
| `M_SP_TB_1` | 30 | Single-point with CP56Time2a |
| `M_DP_TB_1` | 31 | Double-point with CP56Time2a |
| `M_ME_TD_1` | 34 | Normalized value with CP56Time2a |
| `M_ME_TE_1` | 35 | Scaled value with CP56Time2a |
| `M_ME_TF_1` | 36 | Float value with CP56Time2a |
| `M_IT_TB_1` | 37 | Integrated total with CP56Time2a |
| `C_SC_NA_1` | 45 | Single command |
| `M_EI_NA_1` | 70 | End of initialization |
| `C_IC_NA_1` | 100 | General interrogation |
| `C_CI_NA_1` | 101 | Counter interrogation |
| `C_CS_NA_1` | 103 | Time synchronization |
| `C_RP_NA_1` | 105 | Reset process |
| `P_ME_NA_1` | 110 | Parameter write, normalized |
| `P_ME_NB_1` | 111 | Parameter write, scaled |
| `P_ME_NC_1` | 112 | Parameter write, float |

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

## [](#iec-61850) IEC 61850

IEC 61850 support provides transparent access to the device information
model. Data acquisition is performed through subscriptions to RCB/BRCB
report blocks transported over MMS.

Before data collection can begin, the required report blocks must exist
on the IEC 61850 device. After a connection is established, the Server
configures those report blocks for spontaneous event transmission.

Object binding uses MMS addresses in the format:

`LogicalDevice/LogicalNode$FC$DataObject`

Typical functional constraints are:

* `FC=ST` for discrete-state bindings
* `FC=MX` for measured-value bindings
* `FC=CO` for control commands

Two-stage control commands are supported.

Only UTC timestamps are supported. If the device uses a different time
zone, timestamp handling may become problematic.

The operator can also initiate a full interrogation of the device.

## Translation status

This English page is now a functional protocol reference. The Russian
page still contains fuller wording and a few extra implementation notes.
