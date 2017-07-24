{$I Defines.inc}

unit ApiDemoMain;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixDebug,
    Far_API,
    FarCtrl,
    FarPlug,
    FarMenu,
    FarDlg,
    FarGrid,
    FarColorDlg,
    FarListDlg;


  const
   {$ifdef Far3}
    cPluginID :TGUID = '{31D2E844-2961-4317-A5D5-54CDAC80C8D2}';
    cMenuID   :TGUID = '{2F68739D-B453-4B6C-BA60-F4D7DB4EAE30}';
   {$endif Far3}

    PLUGIN_NAME = 'API Demo';
    PLUGIN_DESC = 'FAR API demo plugin';
    PLUGIN_AUTHOR = 'Max Rusov';

  type
    TDemoPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure GetInfo; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
    end;


implementation


  type
    TMessages = (
      sTitle,
      sMsgBox,
      sInputBox,
      sDialog,
      sOptions,
      sFarVersion,
      sText,
      sCheckBox1,
      sCheckBox2,
      sOkBut,
      sCancelBut,

      strColorDialog,
      str_CD_Foreground,
      str_CD_Background,
      str_CD_Sample,
      str_CD_Set,
      str_CD_Cancel
    );


  function GetMsg(MsgId :TMessages) :PFarChar;
  begin
    Result := FarCtrl.GetMsg(Integer(MsgId));
  end;

  function GetMsgStr(MsgId :TMessages) :TSTring;
  begin
    Result := FarCtrl.GetMsgStr(Integer(MsgId));
  end;

  procedure HandleError(AError :Exception);
  begin
    ShowMessage(PLUGIN_NAME, AError.Message, FMSG_WARNING or FMSG_MB_OK);
  end;


  var
    GlobStr   :TString;
    GlobColor :TFarColor;


 {-----------------------------------------------------------------------------}
 { Диалог                                                                      }
 {-----------------------------------------------------------------------------}

  const
    IdFrame        = 0;
    IdInputEdt     = 2;
    IdChk1         = 4;
    IdChk2         = 5;
    IdOk           = 7;

  type
    TInputDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FInitStr  :TString;
    end;


  procedure TInputDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 11;
  begin
    FWidth := DX;
    FHeight := DY;
    FDialog := CreateDialog(
      [
        NewItemApi(DI_DoubleBox, 3,  1,   DX-6, DY-2, 0, GetMsg(sTitle)),

        NewItemApi(DI_Text,     5,  2, -1,    -1, 0, GetMsg(sText) ),
        NewItemApi(DI_Edit,     5,  3, DX-10, -1, DIF_HISTORY, '', 'ApiDemo.Text' ),

        NewItemApi(DI_Text,     0,  4, -1, -1,    DIF_SEPARATOR),

        NewItemApi(DI_CHECKBOX, 5,  5, DX-10, -1, 0, GetMsg(sCheckBox1)),
        NewItemApi(DI_CHECKBOX, 5,  6, DX-10, -1, 0, GetMsg(sCheckBox2)),

        NewItemApi(DI_Text,     0, DY-4, -1, -1,  DIF_SEPARATOR),

        NewItemApi(DI_DefButton,0, DY-3, -1, -1,  DIF_CENTERGROUP, GetMsg(sOkBut) ),
        NewItemApi(DI_Button,   0, DY-3, -1, -1,  DIF_CENTERGROUP, GetMsg(sCancelBut) )
      ],
      @FItemCount
    );
  end;


  procedure TInputDlg.InitDialog; {override;}
  begin
    if FInitStr <> '' then
      SetText(IdInputEdt, FInitStr);
  end;


  function TInputDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if ItemID = IdOk then
      FInitStr := GetText(IdInputEdt);
    Result := True;
  end;


  function TInputDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}
  begin
//  Result := 1;
    case Msg of
      DN_BTNCLICK:
        Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { Grid-based диалог                                                           }
 {-----------------------------------------------------------------------------}

  type
    TListDlg = class(TFilteredListDlg)
    protected
      procedure ReinitGrid; override;
      function GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; override;
    end;


  procedure TListDlg.ReinitGrid; {override;}
  begin
    SetText(IdFrame, GetMsg(sTitle));

    FGrid.Options := FGrid.Options - [goRowSelect];

//  FGrid.Column[0].Options := [coColMargin];
    FGrid.Columns.Clear;
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 15, taLeftJustify, [coColMargin], 1) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 15, taLeftJustify, [coColMargin], 2) );
    FGrid.Columns.Add( TColumnFormat.CreateEx('', '', 15, taLeftJustify, [coColMargin], 3) );

    FGrid.RowCount := 100;

    FMenuMaxWidth := 47;
    ResizeDialog;
  end;


  function TListDlg.GridGetDlgText(ASender :TFarGrid; ACol, ARow :Integer) :TString; {override;}
  begin
    Result := 'Item ' + IntToStr(ARow);
  end;



 {-----------------------------------------------------------------------------}
 { Главное меню плагина                                                        }
 {-----------------------------------------------------------------------------}

(*
  function Get8087CW: Word;
  asm
    PUSH    0
    FNSTCW  [ESP].Word
    POP     EAX
  end;
*)


  procedure MainMenu;

    procedure LocShowMessage;
    begin
      ShowMessage(
        GetMsgStr(sTitle),
        GetMsgStr(sFarVersion) + #10 +
        GetMsgStr(sOkBut),
        FMSG_WARNING + FMSG_LEFTALIGN, 1);
    end;

    procedure LocInputBox;
    var
      vStr :TString;
    begin
      vStr := GlobStr;
      if FarInputBox(GetMsg(sTitle), GetMsg(sText), vStr, FIB_BUTTONS or FIB_NOAMPERSAND{ or FIB_PASSWORD}, 'ApiDemo.Text') then begin
        GlobStr := vStr;
       {$ifdef bTrace}
        TraceF('Input: %s', [vStr]);
       {$endif bTrace}
        ShowMessage(GetMsgStr(sTitle), vStr, FMSG_MB_OK)
      end;
    end;

    procedure LocDialog;
    var
      vDlg :TInputDlg;
    begin
      vDlg := TInputDlg.Create;
      try
        vDlg.FInitStr := GlobStr;
        if vDlg.Run = IdOk then begin
          GlobStr := vDlg.FInitStr;
        end;
      finally
        FreeObj(vDlg);
      end;
    end;

    procedure LocColorDialog;
    begin
      ColorDlg('Color', GlobColor);
    end;

    procedure LocGrid;
    var
      vDlg :TListDlg;
    begin
//    FarPostMacro('far.Message("Hello, world!")');
      vDlg := TListDlg.Create;
      try
        if vDlg.Run = IdOk then begin
        end;
      finally
        FreeObj(vDlg);
      end;
    end;

  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(sTitle),
    [
      GetMsg(sMsgBox),
      GetMsg(sInputBox),
      GetMsg(sDialog),
      '&Grid based Dialog',
      '&Colors Dialog',
      '',
      GetMsg(sOptions)
    ]);
    try
      vMenu.SetSelected(vMenu.ResIdx);

      if not vMenu.Run then
        Exit;

      case vMenu.ResIdx of
        0: LocShowMessage;
        1: LocInputBox;
        2: LocDialog;
        3: LocGrid;
        4: LocColorDialog;
      else
        Sorry;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;



 {-----------------------------------------------------------------------------}
 { TDemoPlug                                                                   }
 {-----------------------------------------------------------------------------}

  procedure TDemoPlug.Init; {override;}
  begin
    inherited Init;

//  TraceF('Size=%d', [SizeOf(TPluginInfo)]);

    FName := PLUGIN_NAME;
    FDescr := PLUGIN_DESC;
    FAuthor := PLUGIN_AUTHOR;

   {$ifdef Far3}
    FGUID := cPluginID;
   {$else}
   {$endif Far3}

    GlobColor := MakeColor(clWhite, clBlack);
  end;


  procedure TDemoPlug.GetInfo; {override;}
  begin
    FMenuStr := GetMsg(sTitle);
   {$ifdef Far3}
    FMenuID  := cMenuID;
   {$endif Far3}
  end;


type
  TA = Class (TObject)
  public
    procedure my;virtual;abstract;
  End;

type
  TB = Class (TA)
  public
    procedure my;override;
  End;

type
  TC = Class (TB)
  protected
    procedure my;override;
  End;

type
  TD = Class (TC)
  public
    procedure my;override;
  End;


  procedure TB.my;
  begin
  end;

  procedure TC.my;
  begin
    inherited My;
  end;

  procedure TD.my;
  begin
    inherited My;
  end;



  procedure Test;
//var
//  E :Extended;
//  I :Integer;
//  P :Pointer;
  begin
    with TD.Create do
      try
        My;
      finally
        Destroy;
      end;


//    Set8087CW(Default8087CW);
//  TraceF('Default8087CW: %x', [Default8087CW]);
//  TraceF('8087CW: %x', [Get8087CW]);

//    Sorry;

//  P := nil;
//  Integer(P^) := 1;

(*
    E := 0;
    E := 1 / E;

//  E := 0;
//  E := 1 / E;

    Set8087CW(Default8087CW);
    E := 1.2;
    I := Trunc(E);
*)
  end;


  function TDemoPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Test;
    MainMenu;
    Result := INVALID_HANDLE_VALUE;
  end;


initialization
  ColorDlgResBase := Byte(strColorDialog);
end.
