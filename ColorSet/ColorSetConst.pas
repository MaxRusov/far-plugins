{$I Defines.inc}

unit ColorSetConst;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,

    Far_API,
    FarCtrl,
    FarConfig,
    FarColorDlg;


  const
   {$ifdef Far3}
    cPluginID :TGUID = '{D2FCCE3F-9280-43F2-A72E-64FD97269E8A}';
    cMenuID   :TGUID = '{50F3A567-A5D2-4C12-8F9E-D12D574E62E3}';
   {$endif Far3}

    cPluginName = 'ColorSet';
    cPluginDescr = 'Color Setup Far plugin';
    cPluginAuthor = 'Max Rusov';

    cColorDefs  = 'Colors.ini';

  const
    cPrefix     = 'pal';

    { Команды, доступные через префикс pal: }
    cSaveCmd    = 'Save';
    cLoadCmd    = 'Load';

    cPalFileExt = 'farpal';


  type
    TMessages = (
      sTitle,
      strUnknownCommand,

      strColorDialog,
      str_CD_Foreground,
      str_CD_Background,
      str_CD_Sample,
      str_CD_Set,
      str_CD_Cancel
    );


  var
    optDefaultPalette :TString;
    optFoundColor     :TFarColor;



  function GetMsg(MsgId :TMessages) :PFarChar;
  function GetMsgStr(MsgId :TMessages) :TSTring;

  procedure AppErrorId(AMess :TMessages);
  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);

  procedure RestoreDefColor;
  procedure PluginConfig(AStore :Boolean);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  function GetMsg(MsgId :TMessages) :PFarChar;
  begin
    Result := FarCtrl.GetMsg(Integer(MsgId));
  end;

  function GetMsgStr(MsgId :TMessages) :TSTring;
  begin
    Result := FarCtrl.GetMsgStr(Integer(MsgId));
  end;


  procedure AppErrorId(AMess :TMessages);
  begin
    FarCtrl.AppErrorID(Integer(AMess));
  end;

  procedure AppErrorIdFmt(AMess :TMessages; const Args: array of const);
  begin
    FarCtrl.AppErrorIdFmt(Integer(AMess), Args);
  end;


  procedure RestoreDefColor;
  begin
    optFoundColor := MakeColor(clLime, 0);
  end;


  procedure PluginConfig(AStore :Boolean);
  var
    vConfig :TFarConfig;
  begin
    vConfig := TFarConfig.CreateEx(AStore, cPluginName);
    try
      with vConfig do begin
        if not Exists then
          Exit;

        StrValue('DefaultPalette', optDefaultPalette);
      end;
    finally
      vConfig.Destroy;
    end;
  end;



initialization
  ColorDlgResBase := Byte(strColorDialog);
end.
