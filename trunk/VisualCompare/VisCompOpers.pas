{$I Defines.inc}

unit VisCompOpers;

{******************************************************************************}
{* (c) 2009 Max Rusov                                                         *}
{*                                                                            *}
{* Visual Compare Far plugin                                                  *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixFormat,
    MixClasses,
    MixWinUtils,
   {$ifdef bUseCRC}
    MixCRC,
   {$endif bUseCRC}

   {$ifdef bUnicodeFar}
    PluginW,
   {$else}
    Plugin,
   {$endif bUnicodeFar}

    FarCtrl,
    FarMatch,
    VisCompCtrl,
    VisCompFiles;



  function PromptDeleteFile(AVer :Integer; AList :TStringList) :Boolean;
  procedure DeleteFiles(AVer :Integer; AList :TStringList);


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function PromptDeleteFile(AVer :Integer; AList :TStringList) :Boolean;
  var
    vItem :TCmpFileItem;
    vPrompt, vStr :TString;
  begin
    Result := False;
    if AList.Count = 1 then begin
      vItem := AList.Objects[0] as TCmpFileItem;

      if not vItem.IsFolder then
        vPrompt := GetMsgStr(strDeleteFile)
      else
        vPrompt := GetMsgStr(strDeleteFolder);

      vStr := '';
      if (AVer = 0) or ((AVer = -1) and (faPresent and vItem.Attr[0] <> 0)) then
        vStr := ExtractFilePath(vItem.GetFullFileName(0));
      if (AVer = 1) or ((AVer = -1) and (faPresent and vItem.Attr[1] <> 0)) then
        vStr := AppendStrCh(vStr, ExtractFilePath(vItem.GetFullFileName(1)), #10);

      vPrompt := Format(vPrompt, [RemoveBackSlash(vItem.Name), vStr]);

    end else
    begin
      vPrompt := GetMsgStr(strDeleteNItems);

      if AVer = -1 then
        vStr := GetMsgStr(strBothSides)
      else
      if AVer = 0 then
        vStr := GetMsgStr(strLeftSide)
      else
      if AVer = 1 then
        vStr := GetMsgStr(strRightSide);

      vPrompt := Format(vPrompt, [AList.Count, vStr]);
    end;

    if ShowMessage(GetMsgStr(strDelete), vPrompt + #10#10 + GetMsgStr(strDeleteBut) + #10 + GetMsgStr(strCancel), 0, 2) <> 0 then
      Exit;

    Result := True;
  end;


  function PromptDlg(AMsg :TMessages; const AName :TString) :Integer;
  begin
    Result := ShowMessage(GetMsgStr(strWarning), Format(GetMsgStr(AMsg), [AName]) + #10#10 +
      GetMsgStr(strDelete1But) + #10 + GetMsgStr(strAllBut) + #10 + GetMsgStr(strSkipBut) + #10 + GetMsgStr(strSkipAllBut) + #10 + GetMsgStr(strCancel),
      FMSG_WARNING, 5);
  end;



(*
  procedure DeleteFiles(AVer :Integer; AList :TStringList);
  var
    vContinue :Boolean;
    vAllReadOnly :Integer;
    vAllNotEmpty :Integer;


    function LocDeleteFile(const AName :TString) :Boolean;
    var
      vAttr :Integer;
      vDelReadOnly, vRes :Integer;
    begin
//    TraceF('Delete File: %s', [AName]);
      Result := False;

      if WinFileExists(AName) then begin

        vAttr := FileGetAttr(AName);
        if (vAttr <> -1) and (faReadOnly and vAttr <> 0) then begin

          vDelReadOnly := vAllReadOnly;
          if vDelReadOnly = 0 then begin
            vRes := PromptDlg(strDeleteReadOnlyFile, AName);
            case vRes of
              0: vDelReadOnly := 1;
              1: vAllReadOnly := 1;
              2: vDelReadOnly := 2;
              3: vAllReadOnly := 2;
            else
              vContinue := False;
              Exit;
            end;
            if vAllReadOnly <> 0 then
             vDelReadOnly := vAllReadOnly;
          end;

          if vDelReadOnly = 2 then
            { Попустить файл }
            Exit;

          FileSetAttr(AName, vAttr and not faReadOnly);
        end;

        if not DeleteFile(AName) then
          RaiseLastWin32Error;

        {!!!}

      end;
      Result := True;
    end;


    function LocDeleteFolder(const AName :TString) :Boolean;
    begin
      if not RemoveDir(AName) then
        RaiseLastWin32Error;
      Result := True;
    end;


    function LocClearFolder(const AName :TString) :Boolean;

      function LocDeleteItem(const aPath :TString; const aSRec :TWin32FindData) :Boolean;
      var
        vName :TString;
      begin
        vName := AddFileName(APath, ASRec.cFileName);
        if faDirectory and ASRec.dwFileAttributes = 0 then
          LocDeleteFile(vName)
        else
          LocDeleteFolder(vName);
        if not vContinue then
          Abort;
      end;

    begin
      try
        WinEnumFilesEx(AName, '*.*', faEnumFiles, [efoRecursive, efoIncludeDir, efoFilesFirst], LocalAddr(@LocDeleteItem));
      except
        on E :EAbort do
          Result := False;
        else
          raise
      end;
    end;


    function LocDeleteNotEmptyFolder(const AName :TString) :Boolean;
    var
      vDelNotEmpty, vRes :Integer;
    begin
//    TraceF('Delete Folder: %s', [AName]);
      Result := False;
      if WinFolderExists(AName) then begin

        if WinFolderNotEmpty(AName) then begin
          vDelNotEmpty := vAllNotEmpty;
          if vDelNotEmpty = 0 then begin
            vRes := PromptDlg(strDeleteNotEmptyFolder, AName);
            case vRes of
              0: vDelNotEmpty := 1;
              1: vAllNotEmpty := 1;
              2: vDelNotEmpty := 2;
              3: vAllNotEmpty := 2;
            else
              vContinue := False;
              Exit;
            end;
            if vAllNotEmpty <> 0 then
             vDelNotEmpty := vAllNotEmpty;
          end;

          if vDelNotEmpty = 2 then
            { Попустить папку }
            Exit;

          if not LocClearFolder(AName) then
            Exit;
        end;

        if not LocDeleteFolder(AName) then
          Exit;

      end;
      Result := True;
    end;


    function LocDeleteItem(AItemVer :Integer; AItem :TCmpFileItem) :Boolean;
    var
      vName :TString;
    begin
      Result := True;
      if faPresent and AItem.Attr[AItemVer] = 0 then
        Exit;
      vName := AItem.GetFullFileName(AItemVer);
      if faDirectory and AItem.Attr[AItemVer] <> 0 then
        Result := LocDeleteNotEmptyFolder(RemoveBackSlash(vName))
      else
        Result := LocDeleteFile(vName);
      if Result then begin
        AItem.Attr[AItemVer] := 0;
      end;
    end;

  var
    I :Integer;
    vItem :TCmpFileItem;
  begin
    vAllReadOnly := 0; vAllNotEmpty := 0;
    vContinue := True;
    for I := 0 to AList.Count - 1 do begin
      vItem := AList.Objects[I] as TCmpFileItem;

      if (AVer = 0) or (AVer = -1) then
        LocDeleteItem(0, vItem);
      if not vContinue then
        Break;

      if (AVer = 1) or (AVer = -1) then
        LocDeleteItem(1, vItem);
      if not vContinue then
        Break;
    end;
  end;
*)

(*
  procedure DeleteFiles(AVer :Integer; AList :TStringList);
  var
    vContinue :Boolean;
    vAllReadOnly :Integer;
    vAllNotEmpty :Integer;


    function LocDeleteFile(const AName :TString) :Boolean;
    var
      vAttr :Integer;
      vDelReadOnly, vRes :Integer;
    begin
//    TraceF('Delete File: %s', [AName]);
      Result := False;

      if WinFileExists(AName) then begin

        vAttr := FileGetAttr(AName);
        if (vAttr <> -1) and (faReadOnly and vAttr <> 0) then begin

          vDelReadOnly := vAllReadOnly;
          if vDelReadOnly = 0 then begin
            vRes := PromptDlg(strDeleteReadOnlyFile, AName);
            case vRes of
              0: vDelReadOnly := 1;
              1: vAllReadOnly := 1;
              2: vDelReadOnly := 2;
              3: vAllReadOnly := 2;
            else
              vContinue := False;
              Exit;
            end;
            if vAllReadOnly <> 0 then
             vDelReadOnly := vAllReadOnly;
          end;

          if vDelReadOnly = 2 then
            { Попустить файл }
            Exit;

          FileSetAttr(AName, vAttr and not faReadOnly);
        end;

        if not DeleteFile(AName) then
          RaiseLastWin32Error;

        {!!!}

      end;
      Result := True;
    end;


    function LocDeleteFolder(const AName :TString) :Boolean;
    begin
      if not RemoveDir(AName) then
        RaiseLastWin32Error;
      Result := True;
    end;


    function LocClearFolder(const AName :TString) :Boolean;

      function LocDeleteItem(const aPath :TString; const aSRec :TWin32FindData) :Boolean;
      var
        vName :TString;
      begin
        vName := AddFileName(APath, ASRec.cFileName);
        if faDirectory and ASRec.dwFileAttributes = 0 then
          LocDeleteFile(vName)
        else
          LocDeleteFolder(vName);
        if not vContinue then
          Abort;
      end;

    begin
      try
        WinEnumFilesEx(AName, '*.*', faEnumFiles, [efoRecursive, efoIncludeDir, efoFilesFirst], LocalAddr(@LocDeleteItem));
      except
        on E :EAbort do
          Result := False;
        else
          raise
      end;
    end;


    function LocDeleteItem(AItemVer :Integer; AItem :TCmpFileItem) :Boolean;
    var
      vName :TString;
      I, vDelNotEmpty, vRes :Integer;
    begin
      Result := True;
      if faPresent and AItem.Attr[AItemVer] = 0 then
        Exit;

      vName := AItem.GetFullFileName(AItemVer);
      if faDirectory and AItem.Attr[AItemVer] <> 0 then begin
        vName := RemoveBackSlash(vName);

        if WinFolderExists(vName) then begin

          if WinFolderNotEmpty(vName) then begin
            vDelNotEmpty := vAllNotEmpty;
            if vDelNotEmpty = 0 then begin
              vRes := PromptDlg(strDeleteNotEmptyFolder, vName);
              case vRes of
                0: vDelNotEmpty := 1;
                1: vAllNotEmpty := 1;
                2: vDelNotEmpty := 2;
                3: vAllNotEmpty := 2;
              else
                vContinue := False;
                Exit;
              end;
              if vAllNotEmpty <> 0 then
               vDelNotEmpty := vAllNotEmpty;
            end;

            if vDelNotEmpty = 2 then
              { Попустить папку }
              Exit;

            if AItem.Subs <> nil then begin

              for I := 0 to AItem.Subs.Count - 1 do begin

              end;

            end;

          end;

          Result := LocDeleteFolder(vName);
        end;
      end else
        Result := LocDeleteFile(vName);

      if Result then begin
        AItem.Attr[AItemVer] := 0;
      end;
    end;

  var
    I :Integer;
    vItem :TCmpFileItem;
  begin
    vAllReadOnly := 0; vAllNotEmpty := 0;
    vContinue := True;
    for I := 0 to AList.Count - 1 do begin
      vItem := AList.Objects[I] as TCmpFileItem;

      if (AVer = 0) or (AVer = -1) then
        LocDeleteItem(0, vItem);
      if not vContinue then
        Break;

      if (AVer = 1) or (AVer = -1) then
        LocDeleteItem(1, vItem);
      if not vContinue then
        Break;
    end;
  end;
*)



  procedure DeleteFiles(AVer :Integer; AList :TStringList);
  var
    vContinue :Boolean;
    vAllReadOnly :Integer;
    vAllNotEmpty :Integer;
    vCurFolder :TCmpFolder;


    procedure LocUpdateCmpItem(const AName :TString);
    begin
    end;


    function LocDeleteFile(const AName :TString) :Boolean;
    var
      vAttr :Integer;
      vDelReadOnly, vRes :Integer;
    begin
//    TraceF('Delete File: %s', [AName]);
      Result := False;

      if WinFileExists(AName) then begin

        vAttr := FileGetAttr(AName);
        if (vAttr <> -1) and (faReadOnly and vAttr <> 0) then begin

          vDelReadOnly := vAllReadOnly;
          if vDelReadOnly = 0 then begin
            vRes := PromptDlg(strDeleteReadOnlyFile, AName);
            case vRes of
              0: vDelReadOnly := 1;
              1: vAllReadOnly := 1;
              2: vDelReadOnly := 2;
              3: vAllReadOnly := 2;
            else
              vContinue := False;
              Exit;
            end;
            if vAllReadOnly <> 0 then
             vDelReadOnly := vAllReadOnly;
          end;

          if vDelReadOnly = 2 then
            { Попустить файл }
            Exit;

          FileSetAttr(AName, vAttr and not faReadOnly);
        end;

        if not DeleteFile(AName) then
          RaiseLastWin32Error;

        if vCurFolder <> nil then
          LocUpdateCmpItem(AName);
      end;
      Result := True;
    end;


    function LocDeleteFolder(const AName :TString) :Boolean;
    begin
      if not RemoveDir(AName) then
        RaiseLastWin32Error;

      if vCurFolder <> nil then
        LocUpdateCmpItem(AName);

      Result := True;
    end;


    function LocClearFolder(const AName :TString) :Boolean;

      procedure LocDeleteItem(const aPath :TString; const aSRec :TWin32FindData);
      var
        vName :TString;
      begin
        vName := AddFileName(APath, ASRec.cFileName);
        if faDirectory and ASRec.dwFileAttributes = 0 then
          LocDeleteFile(vName)
        else
          LocDeleteFolder(vName);
        if not vContinue then
          Abort;
      end;

    begin
      try
        WinEnumFilesEx(AName, '*.*', faEnumFiles, [efoRecursive, efoIncludeDir, efoFilesFirst], LocalAddr(@LocDeleteItem));
        Result := True;
      except
        on E :EAbort do
          Result := False;
        else
          raise
      end;
    end;


    function LocDeleteNotEmptyFolder(const AName :TString) :Boolean;
    var
      vDelNotEmpty, vRes :Integer;
    begin
//    TraceF('Delete Folder: %s', [AName]);
      Result := False;
      if WinFolderExists(AName) then begin

        if WinFolderNotEmpty(AName) then begin
          vDelNotEmpty := vAllNotEmpty;
          if vDelNotEmpty = 0 then begin
            vRes := PromptDlg(strDeleteNotEmptyFolder, AName);
            case vRes of
              0: vDelNotEmpty := 1;
              1: vAllNotEmpty := 1;
              2: vDelNotEmpty := 2;
              3: vAllNotEmpty := 2;
            else
              vContinue := False;
              Exit;
            end;
            if vAllNotEmpty <> 0 then
             vDelNotEmpty := vAllNotEmpty;
          end;

          if vDelNotEmpty = 2 then
            { Попустить папку }
            Exit;

          if not LocClearFolder(AName) then
            Exit;
        end;

        if not LocDeleteFolder(AName) then
          Exit;

      end;
      Result := True;
    end;


    function LocDeleteItem(AItemVer :Integer; AItem :TCmpFileItem) :Boolean;
    var
      vName :TString;
    begin
      Result := True;
      if faPresent and AItem.Attr[AItemVer] = 0 then
        Exit;
      vName := AItem.GetFullFileName(AItemVer);
      vCurFolder := AItem.Subs;
      if faDirectory and AItem.Attr[AItemVer] <> 0 then begin
        vName := RemoveBackSlash(vName);
        Result := LocDeleteNotEmptyFolder(vName);
      end else
        Result := LocDeleteFile(vName);
      if Result then begin
        AItem.Attr[AItemVer] := 0;
      end;
    end;

  var
    I :Integer;
    vItem :TCmpFileItem;
  begin
    vAllReadOnly := 0; vAllNotEmpty := 0;
    vContinue := True;
    for I := 0 to AList.Count - 1 do begin
      vItem := AList.Objects[I] as TCmpFileItem;

      if (AVer = 0) or (AVer = -1) then
        LocDeleteItem(0, vItem);
      if not vContinue then
        Break;

      if (AVer = 1) or (AVer = -1) then
        LocDeleteItem(1, vItem);
      if not vContinue then
        Break;
    end;
  end;



end.

