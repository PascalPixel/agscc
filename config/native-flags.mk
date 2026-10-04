# Same native options as the admitted build.sh.
ROOT := $(abspath ../..)
CC = gcc
CFLAGS = -O2 -fno-pie -no-pie -Wno-narrowing -Wno-implicit-int -Wno-implicit-function-declaration -Wno-pointer-arith -Wno-int-conversion -Wno-format -Wno-error -std=gnu17 -Wno-incompatible-pointer-types -fcommon
LDFLAGS = -no-pie
