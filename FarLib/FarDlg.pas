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
    Far_API,
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
      procedure Close;

      function SendMsg(AMsg, AParam1 :Integer; AParam2 :TIntPtr) :TIntPtr; overload;
      function SendMsg(AMsg, AParam1 :Integer; AParam2 :Pointer) :TIntPtr; overload;
      function GetDlgRect :TSmallrect;
      procedure SetDlgPos(ALeft, ATop, AWidth, AHeight :Integer);
      function GetScreenItemRect(AItemID :Integer) :TSmallRect;
      procedure SetVisible(AItemID :Integer; AVisible :Boolean);
      procedure SetEnabled(AItemID :Integer; AEnabled :Boolean);
      function GetChecked(AItemID :Integer) :Boolean;
      procedure SetChecked(AItemID :Integer; AChecked :Boolean);
      function GetRadioIndex(AItemID, ACount :Integer) :Integer;
      function GetText(AItemID :Integer) :TString;
      procedure SetText(AItemID :Integer; const AStr :TString);
      procedure SetListItems(AItemID :Integer; const AItems :array of TString);
      procedure SetListIndex(AItemID :Integer; AIndex :Integer; ATopPos :Integer = -1);
      procedure SetItemFlags(AItemID :Integer; AFlags :DWORD);
      procedure AddHistory(AItemID :Integer; const AStr :TString);

      procedure AddCustomControl(AControl :TFarCustomControl);

    protected
      procedure Prepare; virtual; abstract;
      function KeyDown(AID :Integer; AKey :Integer) :Boolean; virtual;
      function MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; virtual;
     {$ifdef Far3}
      function KeyDownEx(AID :Integer; const AEvent :TKeyEventRecord) :Boolean; virtual;
     {$endif Far3}
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


     {$ifdef Far3}
      procedure CtrlPalette(const AColors :array of TFarColor; var Colors :TFarDialogItemColors); overload;
      procedure CtrlPalette1(const AColors :array of TPaletteColors; var Colors :TFarDialogItemColors); overload;
     {$else}
      function CtrlPalette(const AColors :array of TFarColor) :Integer; overload;
      function CtrlPalette1(const AColors :array of TPaletteColors) :Integer; overload;
     {$endif Far3}
(*
     {$ifdef Far3}
      procedure ChangePalette(AColors :PFarDialogItemColors);
     {$else}
      procedure ChangePalette(AColors :PFarListColors);
     {$endif Far3}
*)
    public
      property Handle :THandle read FHandle;
    end;


    TFarCustomControl = class(TBasis)
    public
      constructor CreateEx(AOwner :TFarDialog; AControlID :Integer);

      procedure Redraw;

    protected
      procedure Paint(const AItem :TFarDialogItem); virtual;
      function KeyDown(AKey :Integer) :Boolean; virtual;
      function MouseEvent(const AMouse :TMouseEventRecord) :Boolean; virtual;
      function MouseClick(const AMouse :TMouseEventRecord) :Boolean; virtual;
     {$ifdef Far3}
      function KeyDownEx(const AEvent :TKeyEventRecord) :Boolean; virtual;
      function MouseEventEx(const AEvent :TMouseEventRecord) :Boolean; virtual;
     {$endif Far3}
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


 {$ifdef Far3}
  function ApiDlgProc(hDlg :THandle; Msg :TIntPtr; Param1 :TIntPtr; Param2 :TIntPtr) :TIntPtr; stdcall;
 {$else}
  function ApiDlgProc(hDlg :THandle; Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; stdcall;
 {$endif Far3}
  var
    vDialog :TFarDialog;
  begin
//  TraceF('ApiDlgProc: hDlg=%d, Msg=%d, Param1=%d, Param2=%d', [hDlg, Msg, Param1, Param2]);
    if Msg = DN_INITDIALOG then begin
      FarSendDlgMessage(hDlg, DM_SETDLGDATA, 0, Param2);
      TIntPtr(vDialog) := Param2;
      vDialog.FHandle := hDlg;
    end else
      TIntPtr(vDialog) := FarSendDlgMessage(hDlg, DM_GETDLGDATA, 0, 0);
    Assert(vDialog.FHandle = hDlg);
    Result := vDialog.DlgProc(Msg, Param1, TIntPtr(Param2));
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


  function TFarDialog.KeyDown(AID :Integer; AKey :Integer) :Boolean; {virtual;}
  begin
    Result := False; { Не обработано, продолжить стандартную обработку }
  end;


  function TFarDialog.MouseEvent(AID :Integer; const AMouse :TMouseEventRecord) :Boolean; {virtual;}
  begin
    Result := False; { Не обработано, продолжить стандартную обработку }
  end;


 {$ifdef Far3}
  function TFarDialog.KeyDownEx(AID :Integer; const AEvent :TKeyEventRecord) :Boolean; {virtual;}
  begin
    Result := KeyDown(AID, KeyEventToFarKeyDlg(AEvent));
  end;
 {$endif Far3}



  function TFarDialog.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {virtual;}

    function LocControlHandle(var AResult :TIntPtr) :Boolean;
    var
      vCtrl :TFarCustomControl;
    begin
      Result := False;
      if (Param1 > 0) and (Param1 < FCtrlCount) and (FDialog[Param1].ItemType = DI_USERCONTROL) then begin
        vCtrl := FControls[Param1];
        if vCtrl <> nil then begin
          AResult := vCtrl.EventHandler(Msg, Param1, Param2);
          Result := True;
        end;
      end;
    end;

  var
    I :Integer;
    vCtrl :TFarCustomControl;
  begin
   {$ifdef bTrace}
//  if Msg <> DN_ENTERIDLE then
//  if Msg = DN_KEY then
//    TraceF('TFarDialog.DialogHandler: %d, Param1=%x, Param2=%x', [Msg, Param1, Param2]);
   {$endif bTrace}

    Result := 1;
    case Msg of
      DN_INITDIALOG:
        InitDialog;

     {$ifdef Far3}
     {$else}
      DN_GETDIALOGINFO:
        Result := InitFialogInfo(PDialogInfo(Param2)^);
     {$endif Far3}

      DN_CLOSE:
        Result := Byte(CloseDialog(Param1));

     {$ifdef Far3}
      DN_INPUT:
     {$else}
      DN_MOUSEEVENT:
     {$endif Far3}
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

     {$ifdef Far3}
      DN_CONTROLINPUT:
        begin
          with INPUT_RECORD(Pointer(Param2)^) do
            if EventType = KEY_EVENT then begin
              if KeyDownEx(Param1, Event.KeyEvent) then
                Exit;
            end else
            if EventType = _MOUSE_EVENT then begin
              if MouseEvent(Param1, Event.MouseEvent) then
                Exit;
            end;
          if not LocControlHandle(Result) then
            Result := FARAPI.DefDlgProc(FHandle, Msg, Param1, Param2);
        end;

     {$else}
      DN_KEY:
        if not KeyDown(Param1, Param2) then
          if not LocControlHandle(Result) then
            Result := FARAPI.DefDlgProc(FHandle, Msg, Param1, Param2);

      DN_MOUSECLICK:
        if not MouseEvent(Param1, PMouseEventRecord(Param2)^) then
          if not LocControlHandle(Result) then
            Result := FARAPI.DefDlgProc(FHandle, Msg, Param1, Param2);
     {$endif Far3}

      DN_DRAWDLGITEM, DN_KILLFOCUS, DN_GOTFOCUS {$ifdef Far3}, DN_GETVALUE{$endif Far3}:
        if not LocControlHandle(Result) then
          Result := FARAPI.DefDlgProc(FHandle, Msg, Param1, Param2);

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
    Result := RunDialog(FLeft, FTop, FWidth, FHeight, PFarChar(FHelpTopic), FDialog, FItemCount, FFlags,
      ApiDlgProc, {$ifdef Far3}FGUID,{$endif Far3} TIntPtr(Self));
  end;


  procedure TFarDialog.Close;
  begin
    SendMsg(DM_CLOSE, -1, 0)
  end;


 {$ifdef Far3}

  procedure TFarDialog.CtrlPalette(const AColors :array of TFarColor; var Colors :TFarDialogItemColors);
  var
    I :Integer;
  begin
    for I := 0 to IntMin(High(AColors), Colors.ColorsCount - 1) do
      Colors.Colors[I] := AColors[i];
  end;

  procedure TFarDialog.CtrlPalette1(const AColors :array of TPaletteColors; var Colors :TFarDialogItemColors);
  var
    I :Integer;
  begin
    for I := 0 to IntMin(High(AColors), Colors.ColorsCount - 1) do
      Colors.Colors[I] := FarGetColor(AColors[i]);
  end;

 {$else}

  function TFarDialog.CtrlPalette(const AColors :array of TFarColor) :Integer;
  var
    I :Integer;
  begin
    Result := 0;
    for I := 0 to IntMin(High(AColors), 3) do
      PByteArray(@Result)[I] := AColors[i];
  end;

  function TFarDialog.CtrlPalette1(const AColors :array of TPaletteColors) :Integer;
  var
    I :Integer;
  begin
    Result := 0;
    for I := 0 to IntMin(High(AColors), 3) do
      PByteArray(@Result)[I] := FarGetColor(AColors[i]);
  end;

 {$endif Far3}


(*
 {$ifdef Far3}
  procedure TFarDialog.ChangePalette(AColors :PFarDialogItemColors);
  begin
    Sorry;
 {$else}
  procedure TFarDialog.ChangePalette(AColors :PFarListColors);
  const
    cColors = 10;
    cMenuPalette :array[0..cColors - 1] of TPaletteColors =
      (COL_MENUBOX,COL_MENUBOX,COL_MENUTITLE,COL_MENUTEXT, COL_MENUHIGHLIGHT,COL_MENUBOX,COL_MENUSELECTEDTEXT, COL_MENUSELECTEDHIGHLIGHT,COL_MENUSCROLLBAR,COL_MENUDISABLEDTEXT);
  var
    I :Integer;
  begin
    for I := 0 to IntMin(cColors, AColors.ColorCount) - 1 do
      AColors.Colors[I] := AnsiChar( FARAPI.AdvControl(hModule, ACTL_GETCOLOR, Pointer(TIntPtr(cMenuPalette[i]))) );
 {$endif Far3}
  end;
*)


  function TFarDialog.SendMsg(AMsg, AParam1 :Integer; AParam2 :TIntPtr) :TIntPtr;
  begin
    Result := FarSendDlgMessage(FHandle, AMsg, AParam1, AParam2);
  end;


  function TFarDialog.SendMsg(AMsg, AParam1 :Integer; AParam2 :Pointer) :TIntPtr;
  begin
    Result := FarSendDlgMessage(FHandle, AMsg, AParam1, AParam2);
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
      RectMove(Result, Left, Top);
  end;


  procedure TFarDialog.SetVisible(AItemID :Integer; AVisible :Boolean);
  begin
    SendMsg(DM_SHOWITEM, AItemID, byte(AVisible));
  end;


  procedure TFarDialog.SetEnabled(AItemID :Integer; AEnabled :Boolean);
  begin
    SendMsg(DM_ENABLE, AItemID, byte(AEnabled));
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


  procedure TFarDialog.SetText(AItemID :Integer; const AStr :TString);
  var
    vData :TFarDialogItemData;
  begin
   {$ifdef Far3}
    vData.StructSize := SizeOf(vData);
   {$endif Far3}
    vData.PtrLength := Length(AStr);
    vData.PtrData := PFarChar(AStr);
    SendMsg(DM_SETTEXT, AItemID, @vData);
  end;


  function TFarDialog.GetText(AItemID :Integer) :TString;
 {$ifdef Far3}
  var
    vLen :Integer;
    vData :TFarDialogItemData;
  begin
    Result := '';
    vLen := SendMsg(DM_GETTEXT, AItemID, 0);
    if vLen > 0 then begin
      SetLength(Result, vLen);
      vData.StructSize := SizeOf(vData);
      vData.PtrLength := vLen;
      vData.PtrData := PFarChar(Result);
      SendMsg(DM_GETTEXT, AItemID, @vData);
    end;
 {$else}
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
 {$endif Far3}
  end;

  
  procedure TFarDialog.SetListItems(AItemID :Integer; const AItems :array of TFarStr);
  var
    I :Integer;
    vList :TFarList;
  begin
   {$ifdef Far3}
    vList.StructSize := SizeOf(vList);
   {$endif Far3}
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
   {$ifdef Far3}
    vPos.StructSize := SizeOf(vPos);
   {$endif Far3}
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
  begin
    SendMsg(DM_ADDHISTORY, AItemID, PTChar(AStr));
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


  function TFarCustomControl.MouseEvent(const AMouse :TMouseEventRecord) :Boolean; {virtual;}
  begin
    Result := True;
  end;


  function TFarCustomControl.MouseClick(const AMouse :TMouseEventRecord) :Boolean; {virtual;}
  begin
    Result := False;
  end;


 {$ifdef Far3}
  function TFarCustomControl.KeyDownEx(const AEvent :TKeyEventRecord) :Boolean; {virtual;}
  begin
    Result := KeyDown(KeyEventToFarKeyDlg(AEvent));
  end;


  function TFarCustomControl.MouseEventEx(const AEvent :TMouseEventRecord) :Boolean; {virtual;}
  var
    vKey :Integer;
  begin
    Result := False;
    if (AEvent.dwEventFlags and MOUSE_WHEELED <> 0) or (AEvent.dwEventFlags and MOUSE_HWHEELED <> 0) then begin
      vKey := MouseEventToFarKey(AEvent);
      if vKey <> 0 then
        Result := KeyDown(vKey);
    end else
      Result := MouseClick(AEvent);
  end;
 {$endif Far3}


  function TFarCustomControl.EventHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :Integer; {virtual;}
  begin
    Result := 1;
    case Msg of
//    DN_GOTFOCUS:
//    DN_KILLFOCUS:

     {$ifdef Far3}
      DN_CONTROLINPUT:
        with INPUT_RECORD(Pointer(Param2)^) do
          if EventType = KEY_EVENT then
            Result := Byte(KeyDownEx(Event.KeyEvent))
          else
          if EventType = _MOUSE_EVENT then
            Result := Byte(MouseEventEx(Event.MouseEvent));
      DN_INPUT:
        with INPUT_RECORD(Pointer(Param2)^) do
          if EventType = _MOUSE_EVENT then
            Result := Byte(MouseEvent(Event.MouseEvent));
     {$else}
      DN_KEY:
        Result := Byte(KeyDown(Param2));
      DN_MOUSECLICK:
        Result := Byte(MouseClick(PMouseEventRecord(Param2)^));
      DN_MOUSEEVENT:
        Result := Byte(MouseEvent(PMouseEventRecord(Param2)^));
     {$endif Far3}

      DN_DRAWDLGITEM:
        Paint(PFarDialogItem(Param2)^);
    else
      Result := FARAPI.DefDlgProc(FOwner.FHandle, Msg, Param1, Param2);
    end;
  end;


(*
  function TFarCustomControl.EventHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :Integer; {virtual;}
  begin
    Result := 1;
    case Msg of
//    DN_GOTFOCUS:
//    DN_KILLFOCUS:

     {$ifdef Far3}
      DN_CONTROLINPUT:
        with INPUT_RECORD(Pointer(Param2)^) do
          if EventType = KEY_EVENT then
            Result := Byte(KeyDownEx(Event.KeyEvent))
          else
          if EventType = _MOUSE_EVENT then
            Result := Byte(MouseClick(Event.MouseEvent));
      DN_INPUT:
        with INPUT_RECORD(Pointer(Param2)^) do
          if EventType = _MOUSE_EVENT then
            Result := Byte(MouseEventEx(Event.MouseEvent));
     {$else}
      DN_KEY:
        Result := Byte(KeyDown(Param2));
      DN_MOUSECLICK:
        Result := Byte(MouseClick(PMouseEventRecord(Param2)^));
      DN_MOUSEEVENT:
        Result := Byte(MouseEvent(PMouseEventRecord(Param2)^));
     {$endif Far3}

      DN_DRAWDLGITEM:
        Paint(PFarDialogItem(Param2)^);
    else
      Result := FARAPI.DefDlgProc(FOwner.FHandle, Msg, Param1, Param2);
    end;
  end;
*)

end.



