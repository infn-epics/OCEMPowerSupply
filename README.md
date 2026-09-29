# OCEM Power Supply IOC

EPICS IOC for OCEM magnet power supplies over **Modbus TCP**. It supports two
models:

| Model | Device db | UNIMAG db | Startup script | OPI |
|-------|-----------|-----------|----------------|-----|
| Single channel | `OCEMPowerSupply.db` | `unimag-ocem.db` | `OCEMPowersupply.cmd` | `opi/OCEM_modbus.bob` |
| Four channel (ways A..D) | `OCEMPowerSupply4chan.db` | `unimag-ocem4chan.db` | `OCEMPowersupply4chan.cmd` | `opi/OCEM_modbus4chan.bob` |

Each model has two layers:

- **Device layer** (`OCEMPowerSupply*.db`): raw Modbus registers, scaling to
  engineering units (A, V, mA), alarm words and control registers.
- **UNIMAG layer** (`unimag-ocem*.db`): the standard interface shared by the
  UNIMAG power-supply IOCs (`CURRENT_SP`, `CURRENT_RB`, `VOLTAGE_RB`,
  `STATE_SP`, `STATE_RB`), with state decoding and the setpoint and state
  watchdogs.

`OCEM4chanParent.db` gives a channel a `PARENT` PV that points to its crate.

---

## Build

Dependencies (see `configure/RELEASE`): EPICS Base 7, `asyn`, `modbus`.

```bash
make
```

The development container (`.devcontainer/devcontainer.json`) uses the
`infn-epics-ioc:devel` image, which already provides the dependencies.

## Run

```bash
cd iocBoot/iocOCEMPowersupply
../../bin/linux-x86_64/OCEMPowersupply OCEMPowersupply.cmd        # single channel
../../bin/linux-x86_64/OCEMPowersupply OCEMPowersupply4chan.cmd   # four channel
```

The startup scripts set up:

1. `drvAsynIPPortConfigure("MODBUS_IP", "<ip>:502", ...)`: the TCP connection
   to the device.
2. `command_port`: Modbus function 6 (write single register), for the
   control registers.
3. `readback_all`: Modbus function 4 (read input registers), polled every
   1000 ms, for all the readbacks.
4. `dbLoadRecords` of the device db and the UNIMAG db with the same `P`/`R`.

Change the IP address and the macros below to match the installation.

### Macros

| Macro | db | Description | Default |
|-------|----|-------------|---------|
| `P`, `R` | all | PV prefix, PVs are `$(P):$(R):<name>` | - |
| `READ_ALL`, `CMD_PORT` | device | asyn port names for readback and commands | - |
| `IMAX` | device | Full scale current (A) | - |
| `VMAX` | device | Full scale voltage (V) | - |
| `CORRECTION` | device | Current readback correction factor (single channel) | 1.8 (1ch), 1 (4ch) |
| `CORRECTION_A`..`CORRECTION_D` | 4ch device | Per-way current readback correction factor | 1 |
| `CORRECTIONSET` | device | Current setpoint correction factor | 1 |
| `MASKALARM` | device | Alarm mask (see [Alarm mask](#alarm-mask-maskalarm)) | 0 |
| `MASKALARM_A`..`MASKALARM_D` | 4ch device | Per-way alarm mask | 0 |
| `SET_TOLERANCE`, `ZERO_TOLERANCE`, `SET_TIMEOUT_S` | UNIMAG | Watchdog settings (see below) | 1.0, 0.5, 30 |
| `SWVER` | device | Value of the `SWVER` PV | 1.0.2 (1ch), 1.1 (4ch) |

---

## Device layer

### Single channel (`OCEMPowerSupply.db`)

| Register (fc 4) | PVs |
|-----------------|-----|
| 0 | Status bits: `GlobalOff`, `StandBy`, `PowerOn`, `Operational`, `PowerOff`, `LocRem`; `GlobalStateRaw` |
| 1 | `AlarmsSecond` |
| 2 | `AlarmsFirst` |
| 3 | `GroundCurrent` (mA, from `GroundCurrent_raw`, full scale `MaxGroundCurrent`) |
| 4 | `Current` (A, from `Current_raw`, full scale `MaxLoad`, times `CorrectionFactor`) |
| 5 | `Voltage` (V, from `Voltage_raw`, full scale `MaxVoltage`) |
| 6 | `MaxRampSpeed` |

| Register (fc 6) | PVs |
|-----------------|-----|
| 0 | `GlobalControl` (command word: 2 off, 4 on, 8 reset, 16 start ramp) |
| 1 | `Current_SP_raw`, set from `Current_SP` (A) through `MaxIset` and `CorrectionFactor_Set` |
| 2 | `RampSpeed_SP` |

`Fault` is 1 when an unmasked bit of `AlarmsFirst` or `AlarmsSecond` is set.

### Four channel (`OCEMPowerSupply4chan.db`)

| Register (fc 4) | PVs |
|-----------------|-----|
| 0 | `GlobalStateRaw`, `LocRem` |
| 1..4 | `WayA_State` .. `WayD_State` |
| 5 | `GlobalAlarms` (shared by all the ways) |
| 6..13 | `WayX_AlarmsFirst`, `WayX_AlarmsSecond` (X = A..D) |
| 14 | `GroundCurrent` (mA) |
| 15..22 | `WayX_Current` (A), `WayX_Voltage` (V), bipolar around 32767.5 |

| Register (fc 6) | PVs |
|-----------------|-----|
| 0 | `GlobalControl` |
| 1..4 | `WayX_StateControl` (1 on, 2 off, 8 reset / start ramp) |
| 5, 7, 9, 11 | `WayX_Iset_raw`, set from `WayX_Current_SP` (A, ±`IMAX`) |
| 6, 8, 10, 12 | `WayX_SetRamp_raw`, set from `WayX_SetRamp_SP` (A/s) |

`WayX_AlarmSummary` is 1 when an unmasked bit of `WayX_AlarmsFirst`,
`WayX_AlarmsSecond` or `GlobalAlarms` is set. The alarm bit descriptions are
in the `alarmFirstlabel0..15` and `alarmSecondlabel0..2` PVs.

---

## Alarm mask (`MASKALARM`)

`MASKALARM` is an integer bit field with one bit for each alarm bit of the
device. A bit at **0** leaves the alarm active (no mask). A bit at **1** masks
it, so it is ignored. The raw alarm words (`AlarmsFirst`, ...) still show every
bit. The mask only acts on the summary (`Fault` / `WayX_AlarmSummary`), so a
masked alarm does not drive `STATE_RB` to `FAULT` / `EXT_INTLK`.

| PV | Bits | Masks |
|----|------|-------|
| **Single channel** | | |
| `$(P):$(R):MASKALARM` | 0-15 | `AlarmsFirst` bits 0-15 |
| | 16-31 | `AlarmsSecond` bits 0-15 |
| **Four channel** | | |
| `$(P):$(R):MASKALARM` | 0-15 | `GlobalAlarms` bits 0-15 (all ways) |
| `$(P):$(R):WAYX:MASKALARM` | 0-15 | `WayX_AlarmsFirst` bits 0-15 |
| | 16-31 | `WayX_AlarmsSecond` bits 0-15 |

Default 0 (nothing masked). The value can be set with the macros or written at
runtime; it is not persisted across restarts. Example: ignore bit 9 of
`AlarmsFirst` and bit 2 of `AlarmsSecond`:

```bash
caput SPARC:OCEM:TEST:MASKALARM $(( (1<<9) | (1<<(16+2)) ))   # 262656
```

---

## UNIMAG interface

| PV (4 channel: `WAYX:` prefix, X = A..D) | Description |
|----|-------------|
| `CURRENT_SP` | Current setpoint (A). Switches the supply on, writes the setpoint, then starts the ramp |
| `CURRENT_RB` | Current readback (alias of `Current` / `WayX_Current`) |
| `VOLTAGE_RB` | Voltage readback (alias of `Voltage` / `WayX_Voltage`) |
| `STATE_SP` | State command: `OFF`, `ON`, `STANDBY`, `RESET` |
| `STATE_RB` | State readback (see below) |

### States

`STATE_RB` uses the state enumeration shared by the UNIMAG power-supply IOCs:

| Value | State | Alarm | Meaning |
|-------|-------|-------|---------|
| 0 | `OFF` | - | Power supply off |
| 1 | `ON` | - | Output on |
| 2 | `STANDBY` | - | Ready, output disabled |
| 3 | `FAULT` | MAJOR | Power supply fault |
| 4 | `EXT_INTLK` | MAJOR | External interlock |
| 5 | `CONN_FAULT` | MAJOR | Communication errors (the status read fails) |
| 6 | `SP_NOT_REACHED` | MINOR | Current setpoint not reached |
| 7 | `ST_NOT_REACHED` | MAJOR | State not reached (UNIMAG failure) |

Faults win over `ST_NOT_REACHED`, which wins over `SP_NOT_REACHED`. Values from
8 up are for additional, device specific states.

- Single channel (`unimag-ocem.db`): `FAULT` from `Fault` (unmasked
  `AlarmsFirst`/`AlarmsSecond`), `STANDBY` from the standby bit, `CONN_FAULT`
  when `Operational` cannot be read.
- Four channel (`unimag-ocem4chan.db`): each way has its own set of PVs,
  prefixed `$(P):$(R):WAYX:`. `EXT_INTLK` comes from the way alarm summary
  (unmasked alarms) or from way state 16. An unknown way state gives `FAULT`.
  `CONN_FAULT` is set when `WayX_State` cannot be read.

### Watchdogs

| Parameter | PV (4 channel: `WAYX:` prefix) | Description | Default | Units |
|-----------|----|-------------|---------|-------|
| `SET_TOLERANCE` | `SET_TOLERANCE` | Current setpoint tolerance (0 disables the setpoint check) | 1.0 | A |
| `ZERO_TOLERANCE` | `ZERO_TOLERANCE` | Zero current tolerance (a zero setpoint counts as reached within it) | 0.5 | A |
| `SET_TIMEOUT_S` | `SET_TIMEOUT_S` | Setpoint / state timeout | 30 | s |

These are db macros with the same names, and live PVs, so they can also be
changed at runtime. The timeout restarts when the readback gets closer to the
setpoint, on a new setpoint and on a new state command. The setpoint check only
runs while the supply is `ON`. The first `STATE_SP` command after boot arms the
state check, so a supply left running is not reported. `SP_NOT_REACHED`,
`ST_NOT_REACHED`, `SP_ERR`, `SP_WDOG` and `ST_WDOG` can be read as PVs.

---

## Layout

```
configure/                    EPICS build configuration (RELEASE: asyn, modbus)
OCEMPowersupplyApp/src/       IOC main and dbd
OCEMPowersupplyApp/Db/        device, UNIMAG and parent databases
iocBoot/iocOCEMPowersupply/   startup scripts
opi/                          Phoebus displays (.bob)
```

References: [EPICS Modbus documentation](https://epics-modbus.readthedocs.io/en/latest/).
