{$I Defines.inc} { см. также DefApp.inc }

{$ImageBase $01000000}
{-$APPTYPE CONSOLE}

program Noisy;

uses
  MixTypes,
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  Windows,
  MixUtils,
  PlayerMain;

 {$R NoisyW.res}

begin
  try
    Run;
  except
    on E :Exception do 
      MessageBox(0, PTChar(E.Message), 'Error', MB_OK or MB_ICONERROR);
  end;
end.
