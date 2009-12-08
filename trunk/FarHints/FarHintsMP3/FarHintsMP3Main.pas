{$I Defines.inc}

unit FarHintsMP3Main;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints sub-plugin                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    FarHintsAPI;


  function GetPluginInterface :IHintPlugin; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  type
    TStrMessage = (
      strName,
      strType,
      strModified,
      strSize,
      strTitle,
      strArtist,
      strAlbum,
      strYear,
      strComment,
      strGenre
    );

    
  type
    TID3v1Tag = packed record
      cID     :array[0..2] of Char;
      cTitle  :array[0..29] of Char;
      cArtist :array[0..29] of Char;
      cAlbum  :array[0..29] of Char;
      cYear   :array[0..3] of Char;
      case Byte of
        0: (
          cComment  :array[0..29] of Char;
          btGenre   :Byte;
        );
        1: (
          cComment2 :array[0..27] of Char;
          cZero     :Char;
          btTrack   :Byte;
//        btGenre   :Byte;
        );
    end;


  type
    TPluginObject = class(TInterfacedObject, IHintPlugin)
    public
      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;

    private
      FAPI :IFarHintsApi;

      function GetMsg(AIndex :TStrMessage) :WideString;
    end;


  procedure TPluginObject.InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); {stdcall;}
  begin
    FAPI := API;
  end;


  procedure TPluginObject.DonePlugin; {stdcall;}
  begin
  end;


  function TPluginObject.Process(const AItem :IFarItem) :Boolean; {stdcall;}

    function GetLen(AStr :PChar; ALen :Integer) :Integer;
    var
      vStr :PChar;
    begin
      vStr := AStr;
      while (vStr < AStr + ALen) and (vStr^ <> #0) do
        Inc(vStr);
      while (vStr > AStr) and ((vStr - 1)^ = ' ') do
        Dec(vStr);
      Result := vStr - AStr;
    end;

    procedure LocAdd(APrompt :TStrMessage; AStr :PChar; ALen :Integer);
    var
      vStr :TString;
    begin
      SetString(vStr, AStr, GetLen(AStr, ALen));
      if vStr <> '' then
        AItem.AddStringInfo(GetMsg(APrompt), vStr);
    end;

  var
    vName :TString;
    vFile :THandle;
    vTag  :TID3v1Tag;
    vRes  :DWORD;
  begin
    Result := False;
    vName := AItem.FullName;
    if FAPI.CompareStr( FAPI.ExtractFileExt(vName), 'mp3') = 0 then begin
      vFile := CreateFile(PTChar(vName), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
      if vFile <> INVALID_HANDLE_VALUE then begin
        try
          SetFilePointer(vFile, -SizeOf(vTag), nil, FILE_END);
          ReadFile(vFile, vTag, SizeOf(vTag), vRes, nil);
          if vTag.cID = 'TAG' then begin

            AItem.AddStringInfo(GetMsg(strName), AItem.Name);

            LocAdd(strTitle, vTag.cTitle, SizeOf(vTag.cTitle));
            LocAdd(strArtist, vTag.cArtist, SizeOf(vTag.cArtist));
            LocAdd(strAlbum, vTag.cAlbum, SizeOf(vTag.cAlbum));
            LocAdd(strYear, vTag.cYear, SizeOf(vTag.cYear));
            LocAdd(strComment, vTag.cComment, SizeOf(vTag.cComment));

            AItem.AddDateInfo(GetMsg(strModified), AItem.Modified);
            AItem.AddInt64Info(GetMsg(strSize), AItem.Size);

            Result := True;
          end;
        finally
          CloseHandle(vFile);
        end;
      end;
    end;
  end;


  procedure TPluginObject.PostProcess(const AItem :IFarItem); {stdcall;}
  begin
  end;


  procedure TPluginObject.DoneItem(const AItem :IFarItem); {stdcall;}
  begin
  end;

  
  function TPluginObject.GetMsg(AIndex :TStrMessage) :WideString;
  begin
    Result := FAPI.GetMsg(Self, Byte(AIndex));
  end;

 {-----------------------------------------------------------------------------}

  function GetPluginInterface :IHintPlugin; stdcall;
  begin
    Result := TPluginObject.Create;
  end;


end.


