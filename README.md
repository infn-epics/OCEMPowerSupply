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