@Echo off

if "%1"=="" Exit

set BatFile=%1
Shift

FOR /R %%F IN (%BatFile%) DO (

  Echo;
  Echo %%~dpF %1 %2 %3 %4 %5 %6 %7 %8 %9
  Echo;

  cd %%~dpF 

  call %%F %1 %2 %3 %4 %5 %6 %7 %8 %9

  cd ..

)
