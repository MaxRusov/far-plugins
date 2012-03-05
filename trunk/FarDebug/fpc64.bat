@Echo off

if /i "%1" == "Far3" (
  echo Not supported
  goto :EOF
)

call ..\_fpc.bat FarDebug 64 %*
