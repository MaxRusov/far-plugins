@Echo off

if not exist ..\..\Units\Noisy\Player md ..\..\Units\Noisy\Player

call ..\..\_dcc.bat Noisy %*
