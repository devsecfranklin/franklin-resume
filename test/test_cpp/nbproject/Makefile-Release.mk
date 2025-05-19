#
# Gererated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Environment
MKDIR=mkdir
CP=cp
CCADMIN=CCadmin
RANLIB=ranlib
CC=cc
CCC=CC
CXX=CC
FC=f95

# Include project Makefile
include Makefile

# Object Directory
OBJECTDIR=build/Release/SunStudio_12-Linux-x86

# Object Files
OBJECTFILES= \
	${OBJECTDIR}/SunBox.o \
	${OBJECTDIR}/main.o \
	${OBJECTDIR}/device.o

# C Compiler Flags
CFLAGS=

# CC Compiler Flags
CCFLAGS=
CXXFLAGS=

# Fortran Compiler Flags
FFLAGS=

# Link Libraries and Options
LDLIBSOPTIONS=

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS} dist/Release/SunStudio_12-Linux-x86/cpp_test

dist/Release/SunStudio_12-Linux-x86/cpp_test: ${OBJECTFILES}
	${MKDIR} -p dist/Release/SunStudio_12-Linux-x86
	${LINK.cc} -o dist/Release/SunStudio_12-Linux-x86/cpp_test ${OBJECTFILES} ${LDLIBSOPTIONS} 

${OBJECTDIR}/SunBox.o: SunBox.cpp 
	${MKDIR} -p ${OBJECTDIR}
	$(COMPILE.cc) -xO3 -o ${OBJECTDIR}/SunBox.o SunBox.cpp

${OBJECTDIR}/main.o: main.cpp 
	${MKDIR} -p ${OBJECTDIR}
	$(COMPILE.cc) -xO3 -o ${OBJECTDIR}/main.o main.cpp

${OBJECTDIR}/device.o: device.cpp 
	${MKDIR} -p ${OBJECTDIR}
	$(COMPILE.cc) -xO3 -o ${OBJECTDIR}/device.o device.cpp

# Subprojects
.build-subprojects:

# Clean Targets
.clean-conf:
	${RM} -r build/Release
	${RM} dist/Release/SunStudio_12-Linux-x86/cpp_test
	${CCADMIN} -clean

# Subprojects
.clean-subprojects:
