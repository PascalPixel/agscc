#!/bin/sh
# Compatibility entry point for the explicit admitted native build.
exec make -C "$(dirname "$0")" -j"${AGSCC_JOBS:-8}"
