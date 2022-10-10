@Echo off

set BinFolder=Review\PVD
call ..\..\_bld.bat SVG %*
set BinFolder=
