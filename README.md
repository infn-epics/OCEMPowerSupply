## Overview

This project is a generic EPICS template for controlling Modbus devices. It includes:
- **Database Templates:** Define EPICS records for various Modbus devices.
- **Substitution Files:** Provide device-specific configurations for the templates.
- **Source Code:** Implements the IOC logic and initialization.
- **Startup Scripts:** Configure and start the IOC.

For detailed Modbus documentation, refer to the [EPICS Modbus Documentation](https://epics-modbus.readthedocs.io/en/latest/).

---

## Features

- Support for Modbus TCP communication.
- Predefined templates for analog inputs/outputs, digital inputs/outputs, and relays.
- Easily customizable for any Modbus device.
- Includes example startup scripts and substitution files.

---

## Database Files

### Templates
- **`FwdRevPulse.template`**: Defines forward and reverse pulse logic.
- **`icpai.template`**: Analog input template for ICPDAS devices.
- **`icpao.template`**: Analog output template for ICPDAS devices.
- **`ICPDASAIO.template`**: Combined analog input/output template.
- **`ICPDASGV.template`**: General-purpose variables for ICPDAS devices.
- **`ICPDASRly.template`**: Relay control template.
- **`ICPDASRlyPulse.template`**: Relay pulse control template.
- **`icpdasVersion.template`**: Template for device version information.
- **`icpdi.template`**: Digital input template.
- **`icpdo.template`**: Digital output template.
- **`icprtd.template`**: RTD (Resistance Temperature Detector) template.
- **`icprtdsensor.template`**: RTD sensor template.

### Substitution Files
- **`icp7026.substitutions`**: Configuration for the ICPDAS 7026 module.
- **`icp7060.substitutions`**: Configuration for the ICPDAS 7060 module.
- **`icp7215.substitutions`**: Configuration for the ICPDAS 7215 module.
- **`icp7226.substitutions`**: Configuration for the ICPDAS 7226 module.
- **`icp7250.substitutions`**: Configuration for the ICPDAS 7250 module.
- **`icp7267.substitutions`**: Configuration for the ICPDAS 7267 module.

---

## Source Code

### `icpdasMain.cpp`
The main entry point for the IOC. It initializes the EPICS environment and registers the necessary components.

### `initTrace.c`
Implements tracing and debugging utilities for the IOC.

---

## Startup Script

### `ioc-icpdas7060.cmd`
This script configures and starts the IOC for the ICPDAS 7060 module. Key steps include:
1. Loading the environment variables from `envPaths`.
2. Registering the EPICS database and device drivers.
3. Configuring the Asyn IP port for Modbus communication.
4. Defining Modbus ports for reading and writing data.
5. Loading the EPICS records database (`icp7060.db`) with appropriate parameters.
6. Initializing the IOC.

#### Example Configuration:
- **IP Address:** `10.16.4.33`
- **Port:** `502` (Modbus default port)
- **Modbus Ports:**
  - `ICP_get_port`: Reads holding registers.
  - `ICP_set_port`: Writes to coils.
  - `ICP_DI`: Reads digital inputs.
  - `ICP_DICNT`: Reads digital input counters.
  - `ICP_info_port`: Reads device information.

---

## Prerequisites

1. **EPICS Base:** Ensure EPICS Base is installed and configured.
2. **AsynDriver:** Install the EPICS AsynDriver module.
3. **Modbus Support:** Install the EPICS Modbus support module.

---

## Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/modbus-template.git
   cd modbus-template

## UNIMAG states and watchdogs

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

Faults win over `ST_NOT_REACHED`, which wins over `SP_NOT_REACHED`. Values from 8 up are
additional, device specific states. `STATE_SP` accepts `OFF`, `ON`, `STANDBY` and `RESET`.

Single channel (`unimag-ocem.db`): `FAULT` from `AlarmsFirst`/`AlarmsSecond`, `STANDBY` from the
standby bit, `CONN_FAULT` when `Operational` cannot be read. Four channel (`unimag-ocem4chan.db`):
every way has its own set, prefixed `$(P):$(R):WAYx:` (`WAYA`..`WAYD`); `EXT_INTLK` from the way
alarm summary (or state 16), `FAULT` for an unknown way state, `CONN_FAULT` when `WayX_State`
cannot be read.

### UNIMAG configuration

| Parameter | PV (per way: `WAYx:` prefix on 4 channel) | Description | Default | Units |
|-----------|----|-------------|---------|-------|
| `SET_TOLERANCE` | `SET_TOLERANCE` | Current setpoint tolerance (0 disables the setpoint check) | 1.0 | Amperes |
| `ZERO_TOLERANCE` | `ZERO_TOLERANCE` | Zero current tolerance (a zero setpoint counts as reached within it) | 0.5 | Amperes |
| `SET_TIMEOUT_S` | `SET_TIMEOUT_S` | Setpoint / state timeout (restarts on progress) | 30 | Seconds |

They are db macros (same names) and live PVs, so they can also be changed at runtime. The
timeout restarts whenever the readback gets closer to the setpoint, on a new setpoint and on a
new state command. The setpoint check only runs while the supply is `ON`, and the state check
is armed by the first `STATE_SP` command after boot, so a supply left running is not reported.
`SP_NOT_REACHED` and `ST_NOT_REACHED` (and `SP_ERR`, `SP_WDOG`, `ST_WDOG`) are readable PVs.
