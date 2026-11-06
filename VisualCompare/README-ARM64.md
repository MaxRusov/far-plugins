# Building VisualCompare for Windows ARM64

Use a Free Pascal compiler with AArch64/Win64 support, its matching
`aarch64-win64` units, and an ARM64 Windows resource compiler such as the
`aarch64-w64-mingw32-windres` provided by LLVM-MinGW. Add the cross toolchain's
bin directory and the Free Pascal utilities (including `fpcres`) to `PATH`.
Run the script from a POSIX shell, for example WSL.

```sh
FPC=/path/to/ppcrossa64 \
FPC_ARM64_UNITS=/path/to/units/aarch64-win64 \
WINDRES=/path/to/aarch64-w64-mingw32-windres \
sh VisualCompare/build-arm64.sh
```

The script generates `VisualCompare/VisCompW.res` for Far 3 ARM64 and writes
`VisComp.dll` to `Bin3ARM64/VisComp`. An optional first argument selects a
different output directory. Relative output paths are resolved from
`VisualCompare`.

Copy `VisComp.dll` and the language and help files from `VisualCompare/Doc`
to a plugin directory under the ARM64 Far Manager installation.
