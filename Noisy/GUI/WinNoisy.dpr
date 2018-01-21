program Noisy;

{$I Defines.inc}

{$ImageBase $01000000}

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
