@Echo off

FOR /R %%F IN (bld.*) DO (

  Echo;
  Echo %%~dpF %1 %2 %3 %4 %5 %6 %7 %8 %9
  Echo;

  cd %%~dpF 
  call %%F %1 %2 %3 %4 %5 %6 %7 %8 %9
  cd ..
)
