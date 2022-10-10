{$I Defines.inc}

{-$Define bUseWinHTTP}

unit PlugRing;

{******************************************************************************}
{* (c) 2008-2012 Max Rusov                                                    *}
{*                                                                            *}
{* PlugMenu Far Plugin                                                        *}
{* Работа с Plugring                                                          *}
{******************************************************************************}

interface

  uses
    Windows,
    ActiveX,
    ShellAPI,
    WinINet,
//  WinHTTP,
    MSXML,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixWinUtils,
    MixCRC,
    Far_API,  //Plugin3.pas
    FarCtrl,

    PlugMenuCtrl;

  const
    cPluginURL    = 'http://plugring.farmanager.com/plugin.php?pid=';
//  cPlugringSrv  = 'https://plugring.farmanager.com';
    cPlugringSrv  = 'plugring.farmanager.com';
    cPlugringCmd  = 'command.php';
//  cPlugringAPI  = 'http://plugring.farmanager.com/command.php';
    cFindRequest1 = 'command=<plugring><command code="getinfo"/><uids><uid>%s</uid></uids></plugring>';


  function PlugringFindURL(const AID :TGUID) :TString;

(*
  var
    DownloadCallback :procedure(const AURL :TString; ASize :TIntPtr) of object = nil;

  procedure HTTPDownload(const AURL :TString; const AFileName :TString);
*)

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  function CreateComObject(const ClassID :TGUID) :IUnknown;
  begin
    OleCheck(CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IUnknown, Result));
  end;


  procedure XMLParseError(const AError :IXMLDOMParseError);
  var
    vStr :TString;
  begin
//  vStr := GetMsgStr(strXMLParseError);
    vStr := 'XML parse error';
    if AError <> nil then
      vStr := vStr + #10 + Trim(AError.reason) {+ ' (code: ' + HexStr(AError.errorCode, 8) + ')'} + #10 + AError.srcText;
    AppError(vStr);
  end;


  function XMLParseNode(const ADoc :IXMLDOMDocument; const ANode :TString; const AAttr :TString = '') :TString;
  var
    vNode, vNode1 :IXMLDOMNode;
    vAttrs :IXMLDOMNamedNodeMap;
  begin
    Result := '';
    vNode := ADoc.selectSingleNode(ANode);
    if vNode <> nil then
      if AAttr = '' then
        Result := vNode.text
      else begin
        vAttrs := vNode.attributes;
        if vAttrs <> nil then begin
          vNode1 := vAttrs.getNamedItem(AAttr);
          if vNode1 <> nil then
            Result := vNode1.Text;
        end;
      end;
  end;

(*
  function XMLParseArray(const ADoc :IXMLDOMDocument; const ANodes :TString; const ASubNodes :array of TString) :TStringArray2;
  var
    I, J :Integer;
    vNodes :IXMLDOMNodeList;
    vNode, vNode1 :IXMLDOMNode;
    vAttrs :IXMLDOMNamedNodeMap;
  begin
    Result := nil;
    vNodes := ADoc.selectNodes(ANodes);
    if vNodes <> nil then begin
      SetLength(Result, vNodes.length, High(ASubNodes) + 1);
      for I := 0 to vNodes.length - 1 do begin
        vNode := vNodes[I];
        for J := 0 to High(ASubNodes) do begin
          if ASubNodes[J] = '' then
            Result[I, J] := vNode.Text
          else
          if ASubNodes[J][1] = '%' then begin
            vAttrs := vNode.attributes;
            if vAttrs <> nil then begin
              vNode1 := vAttrs.getNamedItem(copy(ASubNodes[J], 2, MaxInt));
              if vNode1 <> nil then
                Result[I, J] := vNode1.Text;
            end;
          end else
          begin
            vNode1 := vNode.SelectSingleNode(ASubNodes[J]);
            if vNode1 <> nil then
              Result[I, J] := vNode1.Text;
          end;
        end;
      end;
    end;
  end;
*)

 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

 {$ifdef bUseWinHTTP}

  function HTTPGet(const ASrv, ACmd :TString; const AData :TAnsiStr; APost :Boolean = False) :TString;
  const
    cHTTPVer = 'HTTP/1.1';
    cRequestFlags = INTERNET_FLAG_SECURE
      or INTERNET_FLAG_IGNORE_CERT_DATE_INVALID or INTERNET_FLAG_IGNORE_CERT_CN_INVALID
      or INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTP or INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTPS
      or INTERNET_FLAG_KEEP_CONNECTION
      or INTERNET_FLAG_NO_CACHE_WRITE
      or INTERNET_FLAG_RELOAD
      or INTERNET_FLAG_PRAGMA_NOCACHE
    ;
  var
    vSession, vConnect, vRequest :HINTERNET;
    vHeader :TString;
  begin
    vConnect := nil; vRequest := nil;
    vSession := WinHttpOpen(cPluginName, WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, nil, nil, 0);
    Win32Check( vSession <> nil );
    try
//      vConnect := InternetConnect(vSession, PTChar(ASrv), INTERNET_DEFAULT_HTTPS_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 1);
//      Win32Check( vConnect <> nil );

      vConnect := WinHttpConnect(vSession, PTChar(ASrv), INTERNET_DEFAULT_HTTPS_PORT, 0);
      Win32Check( vConnect <> nil);


//      vRequest := HttpOpenRequest(vConnect, 'POST', PTChar(ACmd), cHTTPVer, nil{Referrer}, nil{AcceptTypes}, cRequestFlags, 1);
//      Win32Check( vRequest <> nil );

      vRequest := WinHttpOpenRequest(vConnect, 'POST', PTChar(ACmd), nil{Version}, nil{Referrer}, nil{AcceptTypes}, WINHTTP_FLAG_REFRESH or WINHTTP_FLAG_SECURE);
      Win32Check( vRequest <> nil);

(*
//    Win32Check( HttpSendRequest(vRequest, 'Content-Type: application/x-www-form-urlencoded', DWORD(-1), PAnsiChar(AData), length(AData) ));
//    Win32Check( HttpSendRequest(vRequest, nil, DWORD(-1), PAnsiChar(AData), length(AData) ));

      vHeader := 'Content-Type: application/x-www-form-urlencoded';
      Win32Check( HttpSendRequest(vRequest, PTChar(vHeader), length(vHeader), PAnsiChar(AData), length(AData) ));
*)

      vHeader := 'Content-Type: application/x-www-form-urlencoded';
      Win32Check(WinHttpSendRequest(vRequest, PTChar(vHeader), length(vHeader), Pointer(AData), length(AData), 0, 0 ));
//      Check(WinHttpReceiveResponse( vRequest, nil));




    finally
      if vRequest <> nil then
        WinHttpCloseHandle(vRequest);
      if vConnect <> nil then
        WinHttpCloseHandle(vConnect);
      WinHTTPCloseHandle(vSession);
    end;
  end;


 {$else} {---------------------------------------------------------------------}


  procedure HTTPError(ACode :Integer; const AResponse :TString);

//  function TryParseError(const AText :TString) :TString;
//  var
//    vXML :IXMLDOMDocument;
//  begin
//    Result := '';
//    vXML := CreateComObject(CLASS_DOMDocument) as IXMLDOMDocument;
//    if vXML.loadXML(AText) then
//      Result := ParseLastFMErrorDoc(vXML);
//  end;

  var
    vMess :TString;
  begin
    vMess := '';
//  if (ACode = 400) or (ACode = 403) or (ACode = 503) then
//    vMess := TryParseError(AResponse);

    if vMess = '' then begin
      case ACode of
        HTTP_STATUS_NOT_FOUND: vMess := 'Not found';
      end;

      if (vMess = '') and (AResponse <> '') then
        vMess := 'Response text:'#10#10 + AResponse;

      vMess := Format('HTTP error code %d.', [ACode]) + #10 + vMess;
    end;

    AppError(vMess);
  end;


(*
  function HTTPGet(const AURL, AData :TString;  APost :Boolean = False) :TString;
  var
    vRequest :IXMLHttpRequest;
  begin
    vRequest := CreateComObject(CLASS_XMLHTTPRequest) as IXMLHttpRequest;
   {$ifdef bDebug}
    Trace('URL=%s, Data=%s', [AURL, AData]);
   {$endif bDebug}
    if APost then begin
      vRequest.open('POST', AURL, False, '', '');
      vRequest.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    end else
      vRequest.open('GET', AURL, False, '', '');
    vRequest.send(AData);
    if vRequest.status <> 200 then
      HTTPError(vRequest.status, vRequest.responseText);
    Result := vRequest.responseText;
  end;
*)


  function HttpReadStr(ARequest :HINTERNET) :TAnsiStr;
  const
    cBufSize = 1024;
  var
    vBuffer :array[0..cBufSize] of AnsiChar;
    vCode, vRead, vDummy :DWORD;
  begin
    Result := '';

    vCode := 0; vDummy := 0;
    vRead := SizeOf(vCode);
    if not HttpQueryInfo(ARequest, HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER, @vCode, vRead, vDummy) then
      RaiseLastWin32Error;
(*  if vCode <> HTTP_STATUS_OK then
      HTTPError(vCode, '');  *)

    while True do begin
      if not InternetReadFile(ARequest, @vBuffer, cBufSize, vRead) then
        RaiseLastWin32Error;
      if (vRead <= 0) or (vRead > cBufSize) then
        Break;
      vBuffer[vRead] := #0;
      Result := Result + PAnsiChar(@vBuffer[0]);
    end;
  end;


  function HTTPGet(const ASrv, ACmd :TString; const AData :TAnsiStr; APost :Boolean = False) :TString;
  const
    cHTTPVer = 'HTTP/1.1';
    cRequestFlags = INTERNET_FLAG_SECURE
      or INTERNET_FLAG_IGNORE_CERT_DATE_INVALID or INTERNET_FLAG_IGNORE_CERT_CN_INVALID
      or INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTP or INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTPS
      or INTERNET_FLAG_KEEP_CONNECTION
      or INTERNET_FLAG_NO_CACHE_WRITE
      or INTERNET_FLAG_RELOAD
      or INTERNET_FLAG_PRAGMA_NOCACHE
    ;
  var
    vSession, vConnect, vRequest :HINTERNET;
    vHeader :TString;
  begin
    vConnect := nil; vRequest := nil;
    vSession := InternetOpen(cPluginName, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
    Win32Check( vSession <> nil );
    try
      vConnect := InternetConnect(vSession, PTChar(ASrv), INTERNET_DEFAULT_HTTPS_PORT, nil, nil, INTERNET_SERVICE_HTTP, 0, 1);
      Win32Check( vConnect <> nil );

      vRequest := HttpOpenRequest(vConnect, 'POST', PTChar(ACmd), cHTTPVer, nil{Referrer}, nil{AcceptTypes}, cRequestFlags, 1);
      Win32Check( vRequest <> nil );

      vHeader := 'Content-Type: application/x-www-form-urlencoded';
      Win32Check( HttpSendRequest(vRequest, PTChar(vHeader), length(vHeader), PAnsiChar(AData), length(AData) ));

//    Result := UTF8ToWide(HttpReadStr(vRequest));
      Result := TString(HttpReadStr(vRequest));

    finally
      if vRequest <> nil then
        InternetCloseHandle(vRequest);
      if vConnect <> nil then
        InternetCloseHandle(vConnect);
      InternetCloseHandle(vSession);
    end;
  end;
 {$endif bUseWinHTTP}


 {-----------------------------------------------------------------------------}

  function PlugringFindURL(const AID :TGUID) :TString;
  var
    vXML :IXMLDOMDocument;
    vRequest, vResponse, vPluginID :TString;
  begin
    Result := '';

    vRequest := Format(cFindRequest1, [StrDeleteChars(GUIDToString(AID), ['{','}'])]);

//  vResponse := HTTPGet(cPlugringAPI, vRequest, {Post=}True);
    vResponse := HTTPGet(cPlugringSrv, cPlugringCmd, TAnsiStr(vRequest), {Post=}True);
   {$ifdef bDebug}
    Trace(vResponse);
   {$endif bDebug}

    vXML := CreateComObject(CLASS_DOMDocument) as IXMLDOMDocument;
    if not vXML.loadXML(vResponse) then
      XMLParseError(vXML.parseError);

    vPluginID := XMLParseNode(vXML, 'plugring/plugins/plugin', 'id');
    if vPluginID <> '' then
      Result := cPluginURL + vPluginID;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

(*
  procedure HTTPDownload(const AURL :TString; const AFileName :TString);
  const
    cBufSize = 32 * 1024;
  var
    vSession, vHandle :HINTERNET;
    vBuffer :array[0..cBufSize - 1] of byte;
    vRead, vDummy :DWORD;
    vFile :THandle;
    vSize :TIntPtr;
    vCode :Integer;
    vStr :TString;
    vAStr :TAnsiStr;
  begin
    try
      vHandle := nil;
      vSession := InternetOpen(cPluginName, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
      Win32Check( vSession <> nil );
      try
        vHandle := InternetOpenUrl(vSession, PTChar(AURL), nil, 0, 0, 0);
        Win32Check( vHandle <> nil );

        vDummy := 0;
        vRead := SizeOf(vBuffer);
        if not HttpQueryInfo(vHandle, HTTP_QUERY_STATUS_CODE, @vBuffer, vRead, vDummy) then
          RaiseLastWin32Error;

        SetString(vStr, PTChar(@vBuffer), vRead div SizeOf(TChar));
        vCode := Str2IntDef(vStr, 0);

        if vCode <> 200 then begin
          if not InternetReadFile(vHandle, @vBuffer, SizeOf(vBuffer), vRead) then
            RaiseLastWin32Error;
          SetString(vAStr, PAnsiChar(@vBuffer), vRead);
          HTTPError(vCode, vAStr);
        end;

        vFile := FileCreate(AFileName);
        Win32Check(vFile <> INVALID_HANDLE_VALUE);
        try
          try
            vSize := 0;
            while True do begin
              if Assigned(DownloadCallback) then
                DownloadCallback(AURL, vSize);

              if not InternetReadFile(vHandle, @vBuffer, SizeOf(vBuffer), vRead) then
                RaiseLastWin32Error;
              if vRead = 0 then
                Break;

              if FileWrite(vFile, vBuffer, vRead) <> Integer(vRead) then
                RaiseLastWin32Error;

              Inc(vSize, vRead);
            end;

          finally
            FileClose(vFile);
          end;
        except
          DeleteFile(AFileName);
          raise;
        end;

      finally
        InternetCloseHandle(vHandle);
        InternetCloseHandle(vSession);
      end;

    except
      on E :ECtrlBreak do
        raise;
      on E :Exception do
        AppError('Download error'#10 + AURL + #10#10 + E.Message);
    end;
  end;


  procedure HTTPDownload1(const AURL :TString; const AFileName :TString);
 {$ifdef b64}
  begin
    Sorry;
 {$else}
  var
    vRequest :IXMLHttpRequest;
    vBytes :OleVariant;
    vLen :Integer;
    vData :Pointer;
    vFile :THandle;
  begin
    vRequest := CreateComObject(CLASS_XMLHTTPRequest) as IXMLHttpRequest;
   {$ifdef bDebug}
    TraceF('Download: %s...', [AURL]);
   {$endif bDebug}
    vRequest.open('GET', AURL, False, '', '');
    vRequest.send('');
    if vRequest.status <> 200 then
      HTTPError(vRequest.status, vRequest.responseText);
   {$ifdef bDebug}
    Trace('Done');
   {$endif bDebug}

    vBytes := vRequest.responseBody;
    if VarType(vBytes) = (varArray + varByte) then begin
      vLen := VarArrayHighBound(vBytes, 1) + 1;
      vData := VarArrayLock(vBytes);
      try
        vFile := FileCreate(AFileName);
        Win32Check(vFile <> INVALID_HANDLE_VALUE);
        try
          if FileWrite(vFile, vData^, vLen) <> vLen then
            RaiseLastWin32Error
        finally
          FileClose(vFile);
        end;
      finally
        VarArrayUnlock(vBytes);
      end;
    end else
      Wrong;
 {$endif b64}
  end;
*)


(* //
  procedure HTTPDownload(const AURL :TString; const AFileName :TString);
 {$ifdef b64}
  begin
    Sorry;
 {$else}
  var
    vRequest :IXMLHttpRequest;
    vBytes :OleVariant;
    vLen, vRes :Integer;
    vData :Pointer;
    vFile :THandle;
  begin
    vRequest := CreateComObject(CLASS_XMLHTTPRequest) as IXMLHttpRequest;
   {$ifdef bDebug}
    TraceF('Download: %s...', [AURL]);
   {$endif bDebug}
    vRequest.open('GET', AURL, True, '', '');
    vRequest.send('');

    vRes := 0;
    while True do begin
      vRes := vRequest.status;
      if vRes = 200 then
        Break;
      TraceF('Status: %d', [vRes]);
      Sleep(100);
    end;

    if vRes <> 200 then
      HTTPError(vRequest);
   {$ifdef bDebug}
    Trace('Done');
   {$endif bDebug}

    vBytes := vRequest.responseBody;
    if VarType(vBytes) = (varArray + varByte) then begin
      vLen := VarArrayHighBound(vBytes, 1) + 1;
      vData := VarArrayLock(vBytes);
      try
        vFile := FileCreate(AFileName);
        Win32Check(vFile <> INVALID_HANDLE_VALUE);
        try
          if FileWrite(vFile, vData^, vLen) <> vLen then
            RaiseLastWin32Error
        finally
          FileClose(vFile);
        end;
      finally
        VarArrayUnlock(vBytes);
      end;
    end else
      Wrong;
 {$endif b64}
  end;
*)


end.

