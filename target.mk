CCFLAGS =-Wall -Wextra
LDFLAGS =-lpthread -lrt
UNAME_S := $(shell uname -s)
UNAME_P := $(shell uname -p)

ifeq ($(OS),Windows_NT)
    CCFLAGS += -D WIN32
    ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
        CCFLAGS += -D AMD64
    else
        ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
            CCFLAGS += -D AMD64
        endif
        ifeq ($(PROCESSOR_ARCHITECTURE),x86)
            CCFLAGS += -D IA32
        endif
    endif


ifeq LINUX
	CCFLAGS += -D LINUX
	BUILD_DIR := linux
endif

# ifeq ($(UNAME_S),Darwin)
# CCFLAGS += -D OSX
# BUILD_DIR := mac
# endif

# ifeq ($(UNAME_P),x86_64)
# CCFLAGS += -D AMD64
# BUILD_DIR := $(addsuffix _amd64,$(BUILD_DIR))
# endif

# ifeq ($(UNAME_P),amd64)
# CCFLAGS += -D AMD64
# BUILD_DIR := $(addsuffix _amd64,$(BUILD_DIR))
# endif

# ifneq ($(filter %86,$(UNAME_P)),)
# CCFLAGS += -D IA32
# BUILD_DIR := $(addsuffix _ia32,$(BUILD_DIR))
# endif

# ifneq ($(filter arm%,$(UNAME_P)),)
# CCFLAGS += -D ARM
# BUILD_DIR := $(addsuffix _arm,$(BUILD_DIR))
# endif
