{$I Defines.inc}

unit GitShellCommitDlg;


interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,

    Far_API,
    FarCtrl,
    FarDlg,

    GitLibAPI,
    GitShellCtrl,
    GitShellClasses;


  type
    TCommitDlg = class(TFarDialog)
    protected
      procedure Prepare; override;
      procedure InitDialog; override;
      function CloseDialog(ItemID :Integer) :Boolean; override;

      function KeyDown(AID :Integer; AKey :Integer) :Boolean; override;
      function DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; override;

    private
      FRepo     :TGitRepository;

      FAuthor   :TString;
      FEmail    :TString;
      FMessage  :TString;
      FAmend    :Boolean;

      procedure EnableControls;
      procedure ReinitAuthor;
      procedure SetAuthor(const aUserName, aEmail :TString);
      function GetMessages :TString;
      procedure SetMessages(const aMessages :TString);
    end;


  function CommitDlg(aRepo :TGitRepository; var aMessage, aAuthor, aEMail :TString; var aAmend :Boolean) :Boolean;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


  const
    cDescrEdtCount = 10;

  const
    IdFrame        = 0;
    IdAuthorEdt    = 2;
    IdEMailEdt     = 4;
    IdMessageEdt   = 6;
    IdDescrEdt1    = 8;
    IdAmendChk     = 18;
    IdOk           = 20;
    IdCancel       = 21;


 {-----------------------------------------------------------------------------}
 { TCommitDlg                                                                }
 {-----------------------------------------------------------------------------}

  procedure TCommitDlg.Prepare; {override;}
  const
    DX = 76;
    DY = 22;
  var
    X2, WA :Integer;
  begin
    FGUID := cCommitDlgID;
    FHelpTopic := 'CommitDlg';

    FWidth := DX;
    FHeight := DY;

    WA := DX-10;
    X2 := WA div 2;

    FDialog := CreateDialog(
      [
        NewItem(DI_DoubleBox, 3,  1,  DX-6, DY-2, 0, GetMsg(strCommitTitle)),
        DlgSetMargin(5, 2),

        NewTextX(0, 0, GetMsg(strCommitAuthor)),
        NewEditX(0, 1, X2 - 1,  DIF_HISTORY or DIF_USELASTHISTORY, cUserNameHistory ),

        NewTextX(X2, -1, GetMsg(strCommitAuthorEmail)),
        NewEditX(X2, 1, WA - X2, DIF_HISTORY or DIF_USELASTHISTORY, cEMailHistory ),

        NewTextX(0, 1, GetMsg(strCommitMessage)),
        NewEditX(0, 1, WA, DIF_HISTORY, cCommitMessageHistory ),

        NewTextX(0, 1, GetMsg(strCommitDescription)),
        NewEditX(0, 1, WA, DIF_EDITOR),
        NewEditX(0, 1, WA, DIF_EDITOR),
        NewEditX(0, 1, WA, DIF_EDITOR),
        NewEditX(0, 1, WA, DIF_EDITOR),
        NewEditX(0, 1, WA, DIF_EDITOR),
        NewEditX(0, 1, WA, DIF_EDITOR),
        NewEditX(0, 1, WA, DIF_EDITOR),
        NewEditX(0, 1, WA, DIF_EDITOR),
        NewEditX(0, 1, WA, DIF_EDITOR),
        NewEditX(0, 1, WA, DIF_EDITOR),

        NewCheckX(0, 1, GetMsg(strAmendLastCommit)),

        DlgSetMargin(0, DY-4),
        NewTextX(0, 0, '', DIF_SEPARATOR),

        NewButtonX(0, 1, GetMsg(strOk), DIF_CENTERGROUP or DIF_DEFAULTBUTTON ),
        NewButtonX(0, 0, GetMsg(strCancel), DIF_CENTERGROUP )
      ],
      @FItemCount
    );
  end;


  procedure TCommitDlg.InitDialog; {override;}
  begin
    ReinitAuthor;
    SendMsg(DM_SetFocus, IdMessageEdt, 0);
    EnableControls;
  end;


  function TCommitDlg.CloseDialog(ItemID :Integer) :Boolean; {override;}
  begin
    if ItemID = IdOk then begin
      FAuthor  := Trim(GetText(IdAuthorEdt));
      FEmail   := Trim(GetText(IdEMailEdt));
      if (FAuthor = '') or (FEmail = '') then
        AppErrorId(strNoAuthorOrEMail);

      FMessage := Trim(GetText(IdMessageEdt));
      if FMessage = '' then
        AppErrorId(strNoCommitMessage);

      FMessage := GetMessages;
      FAmend := GetChecked(IdAmendChk);
    end;
    Result := True;
  end;


 {-----------------------------------------------------------------------------}

  procedure TCommitDlg.ReinitAuthor;
  var
    vSign :PGitSignature;
  begin
    if git_signature_default(vSign, FRepo.Repo) = 0 then begin
      try
        SetAuthor(UTF8ToWide(vSign.name), UTF8ToWide(vSign.email));
      finally
        git_signature_free(vSign);
      end;
    end;
  end;


  procedure TCommitDlg.SetAuthor(const aUserName, aEmail :TString);
  begin
    SetText(IdAuthorEdt, aUserName);
    SetText(IdEMailEdt, aEmail);
  end;


  function TCommitDlg.GetMessages :TString;
  var
    i :Integer;
    vStr :TString;
  begin
    Result := Trim(GetText(IdMessageEdt));

    vStr := '';
    for i := 0 to cDescrEdtCount - 1 do
      vStr := vStr + GetText(IdDescrEdt1 + i) + #10;
    vStr := Trim(vStr);

    if vStr <> '' then
      Result := Result + #10#10 + vStr;
  end;


  procedure TCommitDlg.SetMessages(const aMessages :TString);
  var
    i :Integer;
    vPtr :PTChar;
    vStr :TString;
  begin
    vPtr := PTChar(aMessages);

    vStr := ExtractNextValue(vPtr, [#13, #10]);
    SetText(IdMessageEdt, vStr);

    if CharInSet(vPtr^, [#13, #10]) then
      Inc(vPtr);

    for i := 0 to cDescrEdtCount - 1 do begin
      vStr := ExtractNextValue(vPtr, [#13, #10]);
      SetText(IdDescrEdt1 + i, vStr);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure TCommitDlg.EnableControls;
  begin
    {}
  end;


  function TCommitDlg.KeyDown(AID :Integer; AKey :Integer) :Boolean; {override;}
  begin
    Result := True;
    case AKey of
      KEY_F9:
        {OptionsMenu};
    else
      Result := inherited KeyDown(AID, AKey);
    end;
  end;


  function TCommitDlg.DialogHandler(Msg :Integer; Param1 :Integer; Param2 :TIntPtr) :TIntPtr; {override;}

    procedure LocAmendClick;
    var
      vCommit :PGitCommit;
      vCommitID :TGitOID;
      vAuthor :PGitSignature;
    begin
      if GetChecked(IdAmendChk) then begin
        FMessage := GetMessages;

        GitCheck(git_reference_name_to_id(vCommitID, FRepo.Repo, cHead));
        GitCheck(git_commit_lookup(vCommit, FRepo.Repo, @vCommitID));
        try
          vAuthor := git_commit_author(vCommit);
          SetAuthor(UTF8ToWide(vAuthor.name), UTF8ToWide(vAuthor.email));
          SetMessages(Trim(UTF8ToWide(git_commit_message(vCommit))));
        finally
          git_commit_free(vCommit);
        end;
      end else
      begin
        ReinitAuthor;
        SetMessages(FMessage);
      end;
    end;

  begin
    Result := 1;
    case Msg of
      DN_BTNCLICK:
        if Param1 = IdAmendChk then
          LocAmendClick
        else
          Result := inherited DialogHandler(Msg, Param1, Param2);
    else
      Result := inherited DialogHandler(Msg, Param1, Param2);
    end;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  function CommitDlg(aRepo :TGitRepository; var aMessage, aAuthor, aEMail :TString; var aAmend :Boolean) :Boolean;
  var
    vDlg :TCommitDlg;
  begin
    vDlg := TCommitDlg.Create;
    try
      vDlg.FRepo := aRepo;

      Result := vDlg.Run = IdOk;

      if Result then begin
        aAuthor := vDlg.FAuthor;
        aEMail := vDlg.FEmail;
        aMessage := vDlg.FMessage;
        aAmend := vDlg.FAmend;
      end;

    finally
      FreeObj(vDlg);
    end;
  end;


end.

