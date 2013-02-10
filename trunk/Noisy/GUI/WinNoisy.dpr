{$I Defines.inc}

{$ImageBase $01000000}

program Noisy;

{$I Defines1.inc}

uses
  Windows,
  MixTypes,
  MixErrors,
 {$ifdef bTrace}
  MixCheck,
 {$endif bTrace}
  MixFormat,
  MixUtils,
  WinNoisyMain;

 {$R WinNoisyW.res}

begin
  try
    Run;
  except
    on E :Exception do begin
//    S := E.Message;
//    Writeln(S);
      MessageBox(0, PTChar(E.Message), 'Error', MB_OK or MB_ICONERROR);
    end;
  end;
end.
