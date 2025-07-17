#!../../bin/linux-x86_64/OCEMPowersupply
# https://epics-modbus.readthedocs.io/en/latest/overview.htm

< envPaths

## Register all support components
dbLoadDatabase "../../dbd/OCEMPowersupply.dbd"
OCEMPowersupply_registerRecordDeviceDriver(pdbbase)

# Configure Modbus TCP communication
 
drvAsynIPPortConfigure("MODBUS_IP", "192.168.0.158:502", 0, 0, 0)
modbusInterposeConfig("MODBUS_IP", 0, 0, 0)

# Define Modbus ports ASYN ports

drvModbusAsynConfigure("command_port", "MODBUS_IP", 1, 6, 0, 3, 0, 1000, "OCEM")

drvModbusAsynConfigure("readback_all", "MODBUS_IP", 1, 4, 20, 7, 0, 1000, "OCEM")

## define ASYN readback_port port to access Read Input Registers 
#drvModbusAsynConfigure("readback_port", "MODBUS_IP", 1, 4, 32, 10, 0, 1000, "GenericDevice")

## define ASYN MODBUS_AI2 port to access to read load values
#drvModbusAsynConfigure("readback_load", "MODBUS_IP", 1, 4, 52, 9, 0, 1000, "OCEM")




#asynSetTraceIOMask("readback_all", 0, 4)
#asynSetTraceMask("readback_all", 0,8)

#asynSetTraceIOMask("command_port", 0, 4)
#asynSetTraceMask("command_port", 0,9)






# Load database records ## ports name are already define in db
dbLoadRecords("$(TOP)/db/OCEMPowerSupply.db", "P=SPARC,R=OCEM:TEST,IMAX=500,VMAX=50")

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

