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
    FarHintsAPI,
    FarHintsTags;


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

    procedure LocAdd(APrompt :TStrMessage; const AStr :TString);
    begin
      if AStr <> '' then
        AItem.AddStringInfo(GetMsg(APrompt), AStr);
    end;

  var
    vName :TString;
    vFile :THandle;
    vTags :TID3Tags;
  begin
    Result := False;
    vName := AItem.FullName;
    if FAPI.CompareStr( FAPI.ExtractFileExt(vName), 'mp3') = 0 then begin
      vFile := CreateFile(PTChar(vName), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
      if vFile <> INVALID_HANDLE_VALUE then begin
        try
          if ReadID3v2(vFile, vTags) or ReadID3v1(vFile, vTags) then begin

            AItem.AddStringInfo(GetMsg(strName), AItem.Name);

            LocAdd(strTitle, vTags.FTitle);
            LocAdd(strArtist, vTags.FArtist);
            LocAdd(strAlbum, vTags.FAlbum);
            LocAdd(strYear, vTags.FYear);
            LocAdd(strComment, vTags.FComment);

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


