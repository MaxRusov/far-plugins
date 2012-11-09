@Echo off

if not exist ..\..\Units\Noisy\GUI md ..\..\Units\Noisy\GUI

call ..\..\_dcc.bat WinNoisy %*
