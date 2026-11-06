#!/bin/sh
set -eu

# Use an FPC compiler and unit tree built for aarch64-win64.
: "${FPC_ARM64_UNITS:?Set FPC_ARM64_UNITS to the absolute aarch64-win64 units directory}"
compiler=${FPC:-ppcrossa64}
windres=${WINDRES:-aarch64-w64-mingw32-windres}
out=${1:-../Bin3ARM64/VisComp}

cd "$(dirname "$0")"
mkdir -p "$out/units"
"$windres" -D Far3 -D arm64 -i VisCompW.rc -O res -o VisCompW.res
"$compiler" -n -Twin64 -Sd -Sx \
    -Fi../MixLib -Fu../FarHints -Fu../FarAPI -Fu../FarLib \
    -Fu../MixLib -Fu../MixLib/Win -Fu../MixLib/FPC \
    "-Fu$FPC_ARM64_UNITS/*" "-FU$out/units" "-FE$out" VisComp.dpr
