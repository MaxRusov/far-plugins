@Echo off

rem if not exist ..\..\Units\Noisy\GUI md ..\..\Units\Noisy\GUI

set BinFolder=Noisy
set UnitsFolder=Noisy\GUI

call ..\..\_dcc.bat WinNoisy %*
