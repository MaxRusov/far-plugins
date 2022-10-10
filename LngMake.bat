@Echo off

echo Make .lng files: %1

if "%1" == "" (
  set /p S="Usage LnkMake Lang.templ {CopyDest}"
  exit
)

%~dp0LngGen -nc -ol Doc -oh . %1

if not %ERRORLEVEL%==0 (
  set /p S="Error code=%ERRORLEVEL%"
  exit
)

if "%2" == "" (
  goto End
)


if exist %2 (
  echo Copy to %2
  if exist Doc\*.lng xcopy /S /Y Doc\*.lng %2
) else (
  echo Not found: %2
)

if "%3" == "" goto Ok

if exist %3 (
  echo Copy to %3
  if exist Doc\*.lng xcopy /S /Y Doc\*.lng %3
) else (
   echo Not found: %3
)

:Ok
set /p S="Ok"

:End