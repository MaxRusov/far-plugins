{$I Defines.inc}

unit FarDlg;

{******************************************************************************}
{* (c) 2008 Max Rusov                                                         *}
{*                                                                            *}
{* FAR Library                                                                *}
{* Объектная обертка для диалогов FAR                                         *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}
    FarColor,
    FarCtrl;


  type
    PPointers  = ^TPointers;
    TPointers  = array[0..MaxInt div SizeOf(Pointer)-1] of Pointer;

    TAlignment = (taLeftJustify, taRightJustify, taCenter);
    TLocationMode = (lmSimple, lmScroll, lmSafe, lmCenter);

    TFarCustomControl = class;

    TFarDialog = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      function Run :Integer;

      function SendMsg(AMsg, AParam1 :Integer; AParam2 :TIntPtr) :TIntPtr; overload;
      function SendMsg(AMsg, AParam1 :Integer; AParam2 :Pointer) :TIntPtr; overload;
      function GetDlgRect :TSmallrect;
      procedure SetDlgPos(ALeft, ATop, AWidth, AHeight :Integer);
      function GetScreenItemRect(AItemID :Integer) :TSmallRect;
      function GetChecked(AItemID :Integer) :Boolean;
      procedure SetChecked(AItemID :Integer; AChecked :Boolean);
      function GetRadioIndex(AItemID, ACount :Integer) :Integer;
      function GetTextApi(AItemID :Integer) :TFarStr;
      procedure SetTextApi(AItemID :Integer; const AStr :TFarStr);
      function GetText(AItemID :Integer) :TString;
      procedure SetText(AItemID :Integer; const AStr :TString);
      procedure SetListItems(AItemID :Integer; const AItems :array of TString);
      procedure SetListIndex(AItemID :Integer; AIndex :Integer; ATopPos :Integer = -1);
      procedure SetItemFlags(AItemID :Integer; AFlags :DWORD);
      procedure AddHistory(AItemID :Integer; const AStr :TString);

      procedure AddCustomControl(AControl :TFarCustomControl);

    protected
      procedure Prepare; virtual; abstract;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; virtual;
      procedure ErrorHandler(E :Exception); virtual;

      procedure InitDialog; virtual;
      function InitFialogInfo(var AInfo :TDialogInfo) :TIntPtr; virtual;
      function CloseDialog(ItemID :Integer) :Boolean; virtual;

    protected
      FDialog    :PFarDialogItemArray;
      FHandle    :THandle;
      FControls  :PPointers;
      FCtrlCount :Integer;
      FItemCount :Integer;
      FHelpTopic :TFarStr;
      FFlags     :DWORD;
      FGUID      :TGUID;
      FLeft      :Integer;
      FTop       :Integer;
      FWidth     :Integer;
      FHeight    :Integer;

      function DlgProc(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr;
      function CtrlPalette(const AColors :array of Integer) :Integer;
      procedure ChangePalette(AColors :PFarListColors);
    end;


    TFarCustomControl = class(TBasis)
    public
      constructor CreateEx(AOwner :TFarDialog; AControlID :Integer);

      procedure Redraw;

    protected
      procedure Paint(const AItem :TFarDialogItem); virtual;
      function KeyDown(AKey :Integer) :Boolean; virtual;
      function MouseEvent(var AMouse :TMouseEventRecord) :Boolean; virtual;
      function MouseClick(const AMouse :TMouseEventRecord) :Boolean; virtual;
      function EventHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :Integer; virtual;

    protected
      FOwner     :TFarDialog;
      FControlID :Integer;

    public
      property ControlID :Integer read FControlID;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;

    

 {-----------------------------------------------------------------------------}
 { TFarDialog                                                                  }
 {-----------------------------------------------------------------------------}

  constructor TFarDialog.Create; {override;}
  begin
    inherited Create;
    FLeft := -1;
    FTop := -1;
    Prepare;
  end;


  destructor TFarDialog.Destroy; {override;}
  begin
    MemFree(FControls);
    MemFree(FDialog);
    inherited Destroy;
  end;


//procedure TFarDialog.CreateDialog; {virtual;}
//begin
//end;


  function ApiDlgProc(hDlg :THandle; Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; stdcall;
  var
    vDialog :TFarDialog;
  begin
//  TraceF('ApiDlgProc: hDlg=%d, Msg=%d, Param1=%d, Param2=%d', [hDlg, Msg, Param1, Param2]);
    if Msg = DN_INITDIALOG then begin
      FARAPI.SendDlgMessage(hDlg, DM_SETDLGDATA, 0, Param2);
      TIntPtr(vDialog) := Param2;
      vDialog.FHandle := hDlg;
    end else
      TIntPtr(vDialog) := FARAPI.SendDlgMessage(hDlg, DM_GETDLGDATA, 0, 0);
    Assert(vDialog.FHandle = hDlg);
    Result := vDialog.DlgProc(Msg, Param1, Param2);
  end;


  function TFarDialog.DlgProc(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr;
  begin
    Result := 0; {???}
    try
      Result := DialogHandler(Msg, Param1, Param2);
    except
      on E :Exception do
        ErrorHandler(E);
    end;
  end;


  procedure TFarDialog.ErrorHandler(E :Exception); {virtual;}
  begin
    ShowMessage('Error', E.Message, FMSG_WARNING or FMSG_MB_OK);
  end;



  function TFarDialog.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {virtual;}
  var
    I :Integer;
    vCtrl :TFarCustomControl;
  begin
//  TraceF('TFarDialog.DialogHandler: %d, Param1=%d, Param2=%d', [Msg, Param1, Param2]);

    Result := 1;
    case Msg of
      DN_INITDIALOG:
        InitDialog;
      DN_GETDIALOGINFO:
        Result := InitFialogInfo(PDialogInfo(Param2)^);

      DN_CLOSE:
        Result := Byte(CloseDialog(Param1));

      DN_MOUSEEVENT:
        begin
          Result := 1;
          for I := 0 to FCtrlCount - 1 do begin
            vCtrl := FControls[I];
            if vCtrl <> nil then begin
              Result := vCtrl.EventHandler(Msg, Param1, Param2);
              if Result = 0 then
                Exit;
            end;
          end;
        end;

      DN_DRAWDLGITEM, DN_KEY, DN_MOUSECLICK, DN_KILLFOCUS, DN_GOTFOCUS:
        begin
          if (Param1 > 0) and (Param1 < FCtrlCount) and (FDialog[Param1].ItemType = DI_USERCONTROL) then begin
            vCtrl := FControls[Param1];
            if vCtrl <> nil then begin
              Result := vCtrl.EventHandler(Msg, Param1, Param2);
              Exit;
            end;
          end;
          Result := FARAPI.DefDlgProc(FHandle, Msg, Param1, Param2);
        end;

//    DN_ENTERIDLE:
//      begin
//      end;

    else
      Result := FARAPI.DefDlgProc(FHandle, Msg, Param1, Param2);
    end;
  end;


  procedure TFarDialog.AddCustomControl(AControl :TFarCustomControl);
  var
    vNewCount :Integer;
  begin
    if FCtrlCount <= AControl.ControlID then begin
      vNewCount := AControl.ControlID + 1;
      ReallocMem(FControls, vNewCount * SizeOf(Pointer));
      FillChar(FControls[FCtrlCount], (vNewCount - FCtrlCount) * SizeOf(Pointer), 0);
      FCtrlCount := vNewCount;
    end;
    FControls[AControl.ControlID] := AControl;
  end;


  procedure TFarDialog.InitDialog; {virtual;}
  begin
  end;


  function TFarDialog.InitFialogInfo(var AInfo :TDialogInfo) :TIntPtr; {virtual;}
  begin
    AInfo.Id := FGUID;
    Result := 1;
  end;


  function TFarDialog.CloseDialog(ItemID :Integer) :Boolean; {virtual;}
  begin
    Result := True;
  end;


  function TFarDialog.Run :Integer;
  begin
    Result := RunDialog(hModule, FLeft, FTop, FWidth, FHeight, PFarChar(FHelpTopic), FDialog, FItemCount, FFlags, ApiDlgProc, TIntPtr(Self));
  end;


  function TFarDialog.CtrlPalette(const AColors :array of Integer) :Integer;
  var
    I :Integer;
  begin
    Result := 0;
    for I := 0 to IntMin(High(AColors), 3) do
      PByteArray(@Result)[I] := Byte( FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(TIntPtr(AColors[i]))) );
  end;


  procedure TFarDialog.ChangePalette(AColors :PFarListColors);
  const
    cColors = 10;
    cMenuPalette :array[0..cColors - 1] of Integer =
      (COL_MENUBOX,COL_MENUBOX,COL_MENUTITLE,COL_MENUTEXT, COL_MENUHIGHLIGHT,COL_MENUBOX,COL_MENUSELECTEDTEXT, COL_MENUSELECTEDHIGHLIGHT,COL_MENUSCROLLBAR,COL_MENUDISABLEDTEXT);
  var
    I :Integer;
  begin
    for I := 0 to IntMin(cColors, AColors.ColorCount) - 1 do
      AColors.Colors[I] := AnsiChar( FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(TIntPtr(cMenuPalette[i]))) );
  end;


  function TFarDialog.SendMsg(AMsg, AParam1 :Integer; AParam2 :TIntPtr) :TIntPtr;
  begin
    Result := FARAPI.SendDlgMessage(FHandle, AMsg, AParam1, AParam2);
  end;


  function TFarDialog.SendMsg(AMsg, AParam1 :Integer; AParam2 :Pointer) :TIntPtr;
  begin
    Result := FARAPI.SendDlgMessage(FHandle, AMsg, AParam1, TIntPtr(AParam2));
  end;


  function TFarDialog.GetDlgRect :TSmallRect;
  begin
    SendMsg(DM_GETDLGRECT, 0, @Result);
  end;


  procedure TFarDialog.SetDlgPos(ALeft, ATop, AWidth, AHeight :Integer);
  var
    vCoord :TCoord;
  begin
    vCoord.X := AWidth;
    vCoord.Y := AHeight;
    SendMsg(DM_RESIZEDIALOG, 0, @vCoord);

    vCoord.X := ALeft;
    vCoord.Y := ATop;
    SendMsg(DM_MOVEDIALOG, 1, @vCoord);
  end;


  function TFarDialog.GetScreenItemRect(AItemID :Integer) :TSmallRect;
  begin
    SendMsg(DM_GETITEMPOSITION, AItemID, @Result);
    with GetDlgRect do
      SRectMove(Result, Left, Top);
  end;


  function TFarDialog.GetChecked(AItemID :Integer) :Boolean;
  begin
    Result := SendMsg(DM_GetCheck, AItemID, 0) = BSTATE_CHECKED;
  end;


  procedure TFarDialog.SetChecked(AItemID :Integer; AChecked :Boolean);
  begin
    SendMsg(DM_SetCheck, AItemID, IntIf(AChecked, BSTATE_CHECKED, BSTATE_UNCHECKED));
  end;


  function TFarDialog.GetRadioIndex(AItemID, ACount :Integer) :Integer;
  var
    I :Integer;
  begin
    for I := 0 to ACount - 1 do
      if GetChecked(AItemID + I) then begin
        Result := I;
        Exit;
      end;
    Result := -1;
  end;


  procedure TFarDialog.SetTextApi(AItemID :Integer; const AStr :TFarStr);
  var
    vData :TFarDialogItemData;
  begin
    vData.PtrLength := Length(AStr);
    vData.PtrData := PFarChar(AStr);
    SendMsg(DM_SETTEXT, AItemID, @vData);
  end;


  function TFarDialog.GetTextApi(AItemID :Integer) :TFarStr;
  var
    vLen :Integer;
    vData :TFarDialogItemData;
  begin
    Result := '';
    vLen := SendMsg(DM_GETTEXTLENGTH, AItemID, 0);
    if vLen > 0 then begin
      SetLength(Result, vLen);
      vData.PtrLength := vLen;
      vData.PtrData := PFarChar(Result);
      SendMsg(DM_GETTEXT, AItemID, @vData);
    end;
  end;


  procedure TFarDialog.SetText(AItemID :Integer; const AStr :TString);
  begin
   {$ifdef bUnicodeFar}
    SetTextApi( AItemID, AStr );
   {$else}
    SetTextApi( AItemID, StrAnsiToOem(AStr) );
   {$endif bUnicodeFar}
  end;


  function TFarDialog.GetText(AItemID :Integer) :TString;
  begin
   {$ifdef bUnicodeFar}
    Result := GetTextApi(AItemID);
   {$else}
    Result := StrOemToAnsi(GetTextApi(AItemID));
   {$endif bUnicodeFar}
  end;


  procedure TFarDialog.SetListItems(AItemID :Integer; const AItems :array of TFarStr);
  var
    I :Integer;
    vList :TFarList;
  begin
    vList.ItemsNumber := High(AItems) + 1;
    vList.Items := MemAllocZero(vList.ItemsNumber * SizeOf(TFarListItem));
    try
      for I := 0 to vList.ItemsNumber - 1 do
        vList.Items[I].TextPtr := PFarChar(AItems[I]);
      SendMsg(DM_LISTSET, AItemID, @vList);
    finally
      MemFree(vList.Items);
    end;
  end;


  procedure TFarDialog.SetListIndex(AItemID :Integer; AIndex :Integer; ATopPos :Integer = -1);
  var
    vPos :TFarListPos;
  begin
    vPos.SelectPos := AIndex;
    vPos.TopPos := ATopPos;
    SendMsg(DM_LISTSETCURPOS, AItemID, @vPos);
  end;



  procedure TFarDialog.SetItemFlags(AItemID :Integer; AFlags :DWORD);
  var
    vItem :TFarDialogItem;
  begin
    if SendMsg(DM_GETDLGITEMSHORT, AItemID, @vItem) <> 0 then begin
      vItem.Flags := AFlags;
      SendMsg(DM_SETDLGITEMSHORT, AItemID, @vItem);
    end;
  end;


  procedure TFarDialog.AddHistory(AItemID :Integer; const AStr :TString);
  var
    vFarStr :TFarStr;
  begin
   {$ifdef bUnicodeFar}
    vFarStr := AStr;
   {$else}
    vFarStr := StrAnsiToOem(AStr);
   {$endif bUnicodeFar}
    SendMsg(DM_ADDHISTORY, AItemID, PFarChar(vFarStr));
  end;


 {-----------------------------------------------------------------------------}
 { TFarCustomControl                                                           }
 {-----------------------------------------------------------------------------}

  constructor TFarCustomControl.CreateEx(AOwner :TFarDialog; AControlID :Integer);
  begin
    Create;
    FOwner := AOwner;
    FControlID := AControlID;
    AOwner.AddCustomControl(Self);
  end;


  procedure TFarCustomControl.Redraw;
(*  Так нельзя, остаются следы при закрытии диалога...
  var
    vItem :TFarDialogItem;
  begin
    FOwner.SendMsg(DM_GETDLGITEMSHORT, FControlID, @vItem);
    Paint(vItem);
*)
  begin
    FOwner.SendMsg(DM_REDRAW, 0, 0);
  end;


  procedure TFarCustomControl.Paint(const AItem :TFarDialogItem); {virtual;}
  begin
    {Abstract}
  end;


  function TFarCustomControl.KeyDown(AKey :Integer) :Boolean; {virtual;}
  begin
    Result := False;
  end;


  function TFarCustomControl.MouseEvent(var AMouse :TMouseEventRecord) :Boolean; {virtual;}
  begin
    Result := True;
  end;


  function TFarCustomControl.MouseClick(const AMouse :TMouseEventRecord) :Boolean; {virtual;}
  begin
    Result := False;
  end;


  function TFarCustomControl.EventHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :Integer; {virtual;}
  begin
    Result := 1;
    case Msg of
//    DN_GOTFOCUS:
//    DN_KILLFOCUS:

      DN_KEY:
        Result := Byte(KeyDown(Param2));

      DN_MOUSEEVENT:
        Result := Byte(MouseEvent(PMouseEventRecord(Param2)^));
      DN_MOUSECLICK:
        Result := Byte(MouseClick(PMouseEventRecord(Param2)^));
      DN_DRAWDLGITEM:
        Paint(PFarDialogItem(Param2)^);
    else
      Result := FARAPI.DefDlgProc(FOwner.FHandle, Msg, Param1, Param2);
    end;
  end;


end.

