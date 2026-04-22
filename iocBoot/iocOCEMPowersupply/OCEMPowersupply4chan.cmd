#!../../bin/linux-x86_64/OCEMPowersupply
# https://epics-modbus.readthedocs.io/en/latest/overview.htm

< envPaths

## Register all support components
dbLoadDatabase "../../dbd/OCEMPowersupply.dbd"
OCEMPowersupply_registerRecordDeviceDriver(pdbbase)

# Configure Modbus TCP communication
 
drvAsynIPPortConfigure("MODBUS_IP", "192.168.0.5:502", 0, 0, 0)
modbusInterposeConfig("MODBUS_IP", 0, 0, 0)

# Define Modbus ports ASYN ports

drvModbusAsynConfigure("command_port", "MODBUS_IP", 1, 6, 0, 13, 0, 1000, "OCEM")

drvModbusAsynConfigure("readback_all", "MODBUS_IP", 1, 4, 20, 23, 0, 1000, "OCEM")





#asynSetTraceIOMask("readback_all", 0, 4)
#asynSetTraceMask("readback_all", 0,8)

#asynSetTraceIOMask("command_port", 0, 4)
#asynSetTraceMask("command_port", 0,9)






# Load database records ## ports name are already define in db
dbLoadRecords("$(TOP)/db/OCEMPowerSupply4chan.db", "P=SPARC,R=OCEM:TEST,READ_ALL=readback_all,CMD_PORT=command_port,IMAX=30,VMAX=15")
dbLoadRecords("$(TOP)/db/unimag-ocem4chan.db", "P=SPARC,R=OCEM:TEST")

iocInit()

## Modbus Function Codes Documentation
# Access         Function Description           Function Code
# Bit access     Read Coils                     1
# Bit access     Read Discrete Inputs           2
# Bit access     Write Single Coil              5
# Bit access     Write Multiple Coils           15
# 16-bit word    Read Input Registers           4
# 16-bit word    Read Holding Registers         3
# 16-bit word    Write Single Register          6
# 16-bit word    Write Multiple Registers       16
# 16-bit word    Read/Write Multiple Registers  23

