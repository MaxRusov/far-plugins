@Echo off

if /i NOT "%1" == "Far3" (
  echo Not supported
  goto :EOF
)

set BinFolder=VerCol
call ..\..\_fpc.bat VersionColumn 64 %*
