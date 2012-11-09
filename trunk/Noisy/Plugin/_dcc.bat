@Echo off

if not exist ..\..\Units\Noisy\Plugin md ..\..\Units\Noisy\Plugin

call ..\..\_dcc.bat NoisyFar %*
