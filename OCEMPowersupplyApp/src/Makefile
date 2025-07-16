TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS BELOW HERE

# Use typed rset structure (see 3.16.1 release notes)
USR_CPPFLAGS += -DUSE_TYPED_RSET

# Build an IOC support library
# LIBRARY_IOC += OCEMPowersupplySupport

# Link locally-provided code into the support library,
# rather than directly into the IOC application, that
# causes problems on Windows DLL builds
#OCEMPowersupplySupport_SRCS += dbSubExample.c
#OCEMPowersupplySupport_SRCS += devOCEMPowersupplyVersion.c
#OCEMPowersupplySupport_SRCS += OCEMPowersupplyHello.c
#OCEMPowersupplySupport_SRCS += initTrace.c

OCEMPowersupplySupport_LIBS += $(EPICS_BASE_IOC_LIBS)

# Auto-generate a header file containing a version string.
# Version comes from the VCS if available, else date+time.
GENVERSION = OCEMPowersupplyVersion.h
# Macro name
GENVERSIONMACRO = OCEMPowersupplyVERSION

# Build the IOC application
PROD_IOC = OCEMPowersupply

# OCEMPowersupply.dbd will be created and installed
DBD += OCEMPowersupply.dbd

# OCEMPowersupply.dbd will include these files:
OCEMPowersupply_DBD += base.dbd
OCEMPowersupply_DBD += modbusSupport.dbd
OCEMPowersupply_DBD += asyn.dbd
OCEMPowersupply_DBD += drvAsynIPPort.dbd


OCEMPowersupply_SRCS += OCEMPowersupply_registerRecordDeviceDriver.cpp

# Build the main IOC entry point where needed
OCEMPowersupply_SRCS_DEFAULT += OCEMPowersupplyMain.cpp
OCEMPowersupply_SRCS_vxWorks += -nil-

# Link in the code from our support library
OCEMPowersupply_LIBS += asyn
OCEMPowersupply_LIBS += modbus
# To build SNL programs, SNCSEQ must be defined
# in the <top>/configure/RELEASE file

# Link QSRV (pvAccess Server) if available
ifdef EPICS_QSRV_MAJOR_VERSION
    OCEMPowersupply_LIBS += qsrv
    OCEMPowersupply_LIBS += $(EPICS_BASE_PVA_CORE_LIBS)
    OCEMPowersupply_DBD += PVAServerRegister.dbd
    OCEMPowersupply_DBD += qsrv.dbd
endif

# Finally link IOC to the EPICS Base libraries
OCEMPowersupply_LIBS += $(EPICS_BASE_IOC_LIBS)

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD EXTRA GNUMAKE RULES BELOW HERE

# Explicit dependency needed for generated header file
devOCEMPowersupplyVersion$(DEP): $(COMMON_DIR)/$(GENVERSION)
