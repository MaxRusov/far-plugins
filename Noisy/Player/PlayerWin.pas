{$I Defines.inc}

unit PlayerWin;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* Window specific procedures                                                 *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,
    ShellAPI,
    CommCtrl,
    CommDlg,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses;


  const
    NOTIFYICONDATA_V1_SIZE = 152;  // 88;
    NOTIFYICONDATA_V2_SIZE = 936;  // 488;
//  NOTIFYICONDATA_V3_SIZE =

    NIM_SETVERSION = 4;

    NOTIFYICON_VERSION   = 3;
    NOTIFYICON_VERSION_4 = 4;

    NIF_INFO     = $00000010;
    NIF_REALTIME = $00000040;
    NIF_SHOWTIP  = $00000080;

    NIIF_INFO    = $00000001;
    NIIF_NOSOUND = $00000010;

    NIN_BALLOONSHOW      = WM_USER + 2;
    NIN_BALLOONHIDE      = WM_USER + 3;
    NIN_BALLOONTIMEOUT   = WM_USER + 4;
    NIN_BALLOONUSERCLICK = WM_USER + 5;
    NIN_POPUPOPEN        = WM_USER + 6;
    NIN_POPUPCLOSE       = WM_USER + 7;


  const
    WM_MySysTrayNotify   = WM_USER + 1;

  var
    LastFolder :TString;
    DialogRect :TRect;


  procedure AddMenuItem(AMenu :HMenu; const aCaption :TString; aType, aState, aSubMenu :UINT; aTag :Integer);

  procedure SysTrayUpdate(Add :Boolean; AWindow :THandle; AIcon :THandle; const ATitle :TString);
  procedure SysTrayDelete(AWindow :THandle);

  procedure WinShowTooltip(AWindow :THandle; const ATitle, AStr :TString);
  procedure WinHideTooltip(AWindow :THandle);

  function OpenFilesDlg(AWnd :THandle; const AMasks :TString; AFiles :TStrList) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  procedure AddMenuItem(AMenu :HMenu; const aCaption :TString; aType, aState, aSubMenu :UINT; aTag :Integer);
  var
    vItem :TMenuItemInfo;
  begin
    vItem.cbSize := 44; // Required for Windows 95
    vItem.fMask := MIIM_DATA or MIIM_ID or MIIM_STATE or MIIM_TYPE or MIIM_SUBMENU;
    vItem.fType := aType;
    vItem.fState := aState;
    vItem.wID := aTag;
    vItem.hSubMenu := aSubMenu;
    vItem.hbmpChecked := 0;
    vItem.hbmpUnchecked := 0;
    vItem.dwItemData := aTag;
    vItem.dwTypeData := PTChar(aCaption);
    vItem.cch := 0;

    Win32Check(InsertMenuItem(AMenu, DWORD(-1), True, vItem));
  end;


 {-----------------------------------------------------------------------------}
 { Tooltip support                                                             }
 {-----------------------------------------------------------------------------}

{
typedef struct _NOTIFYICONDATAA{
    DWORD cbSize;
    HWND hWnd;
    UINT uID;
    UINT uFlags;
    UINT uCallbackMessage;
    HICON hIcon;
#if (NTDDI_VERSION < NTDDI_WIN2K)
    TCHAR szTip[64];
#endif
#if (NTDDI_VERSION >= NTDDI_WIN2K)
    TCHAR szTip[128];
    DWORD dwState;
    DWORD dwStateMask;
    TCHAR szInfo[256];
    union(
        UINT  uTimeout;
        UINT  uVersion;  // Used with Shell_NotifyIcon flag NIM_SETVERSION.
    ) DUMMYUNIONNAME;
    TCHAR szInfoTitle[64];
    DWORD dwInfoFlags;
#endif
#if (NTDDI_VERSION >= NTDDI_WINXP)
    GUID guidItem;
#endif
#if (NTDDI_VERSION >= NTDDI_VISTA)
    HICON hBalloonIcon;
#endif
}

  type
    TNotifyIconDataEx = packed record
      cbSize: DWORD;
      Wnd: HWND;
      uID: UINT;
      uFlags: UINT;
      uCallbackMessage: UINT;
      hIcon: HICON;
      szTip: array [0..128-1] of WideChar;
      dwState :DWORD;
      dwStateMask :DWORD;
      szInfo : array [0..256-1] of WideChar;
      uTimeout :UINT;  {он же uVersion}
      szInfoTitle : array [0..64-1] of WideChar;
      dwInfoFlags :DWORD;
//    guidItem :tGUID;
//    hBalloonIcon :HICON;
    end;


 {-----------------------------------------------------------------------------}

  procedure SysTrayUpdate(Add :Boolean; AWindow :THandle; AIcon :THandle; const ATitle :TString);
  var
    vData :TNotifyIconDataEx;
  begin
    FillChar(vData, SizeOf(vData), 0);
    vData.cbSize := SizeOf(vData);
    vData.uID := 1;
    vData.Wnd := AWindow;

    vData.uFlags := NIF_Icon or NIF_Message or NIF_Tip;
    vData.hIcon := AIcon;
    vData.uCallbackMessage := WM_MySysTrayNotify;

    StrPLCopy(vData.szTip, PTChar(ATitle), High(vData.szTip));

    Shell_NotifyIcon(IntIf(Add, NIM_ADD, NIM_MODIFY), Pointer(@vData));

//  if Add then begin
//    FillChar(vData, SizeOf(vData), 0);
//    vData.cbSize := SizeOf(vData);
//    vData.uID := 1;
//    vData.Wnd := AWindow;
//    vData.uTimeout := NOTIFYICON_VERSION_4;
//    ApiVerify( Shell_NotifyIcon(NIM_SETVERSION, Pointer(@vData)) );
//  end;
  end;


  procedure SysTrayDelete(AWindow :THandle);
  var
    vData :TNotifyIconDataEx;
  begin
    FillChar(vData, SizeOf(vData), 0);
    vData.cbSize := SizeOf(vData);
    vData.uID := 1;
    vData.Wnd := AWindow;

    Shell_NotifyIcon(NIM_Delete, Pointer(@vData));
  end;


 {-----------------------------------------------------------------------------}

  procedure WinShowTooltip(AWindow :THandle; const ATitle, AStr :TString);
  var
    vData :TNotifyIconDataEx;
  begin
    FillChar(vData, SizeOf(vData), 0);
    vData.cbSize := SizeOf(vData);

    vData.uID := 1;
    vData.Wnd := AWindow;
    vData.uFlags := NIF_INFO;
    vData.uTimeout := 1;
    vData.dwInfoFlags := {NIIF_INFO or} NIIF_NOSOUND;
    StrPLCopy(vData.szInfo, PTChar(AStr), High(vData.szInfo));
    if ATitle <> '' then
      StrPLCopy(vData.szInfoTitle, ATitle, High(vData.szInfoTitle));

    Shell_NotifyIcon(NIM_MODIFY, Pointer(@vData));
  end;


  procedure WinHideTooltip(AWindow :THandle);
  var
    vData :TNotifyIconDataEx;
  begin
    FillChar(vData, SizeOf(vData), 0);
    vData.cbSize := SizeOf(vData);

    vData.uID := 1;
    vData.Wnd := AWindow;
    vData.uFlags := NIF_INFO;

    Shell_NotifyIcon(NIM_MODIFY, Pointer(@vData));
  end;


 {-----------------------------------------------------------------------------}
 { File dialog                                                                 }
 {-----------------------------------------------------------------------------}

  const
    cMaxLength = $FFFF;

    FolderControlID = 1121;
    EditControlId   = 1152;


  var
    FDefDlgProc  :Pointer;


  function DialogHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
  var
    vEdt :THandle;
  begin
//  TraceF('DialogHook: %s', [WindowMessage2Str(Msg)]);

    case Msg of
      WM_SHOWWINDOW: begin
        with DialogRect do
          SetWindowPos(Wnd, 0, Left, Top, Right - Left, Bottom - Top, SWP_NOACTIVATE or SWP_NOZORDER );
      end;

      WM_COMMAND:
//      TraceF('Command: NC=%d, ID=%d', [HiWord(WParam), LOWORD(WParam)]);
        if WParam = IDOK then begin
          vEdt := GetDlgItem(Wnd, EditControlId);
          SetFocus(vEdt);
//        EndDialog(Wnd, idOk);
//        Result := 0;
//        Exit;
        end;

//    WM_NOTIFY:
//      TraceF('Notify: %d', [POFNotify(LParam).Hdr.Code]);
    end;

    Result := CallWindowProc(FDefDlgProc, Wnd, Msg, wParam, lParam);
  end;


  function ExplorerHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
  var
    vDlg, vCtrl, vEdt :THandle;
    vCount, vIndex :Integer;
    vStr, vNames :TString;
    vName :array[0..Max_Path] of TChar;
  begin
    Result := 0;
//  TraceF('Msg: %s', [WindowMessage2Str(Msg)]);
    vDlg := GetParent(Wnd);

    case Msg of
      WM_DESTROY:
        GetWindowRect(vDlg, DialogRect);

//    WM_INITDIALOG:
//       with DialogRect do
//         SetWindowPos(vDlg, 0, Left, Top, Right - Left, Bottom - Top, SWP_NOACTIVATE or SWP_NOZORDER);

      WM_NOTIFY: begin
//      TraceF('  Notify: %d', [POFNotify(LParam).Hdr.Code]);

        case POFNotify(LParam).Hdr.Code of
          CDN_INITDONE:
            begin
//            Trace('Init done');
//            with DialogRect do
//              SetWindowPos(vDlg, 0, Left, Top, Right - Left, Bottom - Top, SWP_NOACTIVATE or SWP_NOZORDER or SWP_NOSIZE);

              FDefDlgProc := Pointer(GetWindowLong(vDlg, GWL_WNDPROC));
              SetWindowLong(vDlg, GWL_WNDPROC, Integer(@DialogHook));
            end;

          CDN_FOLDERCHANGE:
            begin
              SendMessage(vDlg, CDM_GETFOLDERPATH, Max_Path, Integer(@vName));
              LastFolder := vName;
  //          TraceF('CurFolder=%s', [LastFolder]);
            end;

          CDN_SELCHANGE:
            begin
              vEdt := GetDlgItem(vDlg, EditControlId);
              vCtrl := GetDlgItem(vDlg, FolderControlID);
              if (vCtrl <> 0) and (vEdt <> 0) then begin
                vCtrl := GetWindow(vCtrl, GW_CHILD);
                if vCtrl <> 0 then begin
                  vNames := '';
                  vCount := ListView_GetSelectedCount(vCtrl);
//                TraceF('Selected: %d', [vCount]);
                  if vCount > 0 then begin
                    vIndex := ListView_GetNextItem(vCtrl, -1, LVNI_ALL or LVNI_SELECTED);
                    while vIndex <> -1 do begin
                      ListView_GetItemText(vCtrl, vIndex, 0, vName, Max_Path);
                      vStr := vName;
                      if vCount > 1 then
                        vStr := '"' + vStr + '"';
                      vNames := AppendStrCh(vNames, vStr, ' ');
                      vIndex := ListView_GetNextItem(vCtrl, vIndex, LVNI_ALL or LVNI_SELECTED);
                    end;
                  end;
                  SetDlgItemText(vDlg, EditControlId, PTChar(vNames));
                end;
              end;
            end;
        end;

      end;
    end;
  end;


  function OpenFilesDlg(AWnd :THandle; const AMasks :TString; AFiles :TStrList) :Boolean;
  var
    vRec :TOpenFileName;
    vFiles, vStr :PTChar;
    vFolder, vName :TString;
  begin
    vFiles := MemAllocZero(cMaxLength * SizeOf(TChar));
    try
      FillChar(vRec, SizeOf(vRec), 0);
      vRec.lStructSize := SizeOf(vRec);
      vRec.hWndOwner := AWnd;
      vRec.lpstrFilter := PTChar(AMasks);
      vRec.lpstrFile := PTChar(vFiles);
      vRec.lpstrInitialDir := PTChar(LastFolder);
      vRec.nMaxFile := cMaxLength;
      vRec.Flags :=
        OFN_EXPLORER or
        OFN_ENABLESIZING or
        OFN_ALLOWMULTISELECT or
        OFN_NOVALIDATE or
        OFN_NOTESTFILECREATE or
        OFN_HIDEREADONLY or
        OFN_NOCHANGEDIR or
        OFN_ENABLEHOOK or
        0;
      vRec.lpfnHook := ExplorerHook;
      Result := GetOpenFileName(vRec);
      if Result then begin

        vStr := vFiles;
        vFolder := vStr;
        Inc(vStr, Length(vFolder) + 1);
        if vStr^ = #0 then
          AFiles.Add(vFolder)
        else  begin
          while vStr^ <> #0 do begin
            vName := vStr;
            AFiles.Add(AddFileName(vFolder, vName));
            Inc(vStr, Length(vName) + 1);
          end;
        end;

      end;
    finally
      MemFree(vFiles);
    end;
  end;


end.
