
local EdtFind      = "E4ABD267-C2F9-4158-818F-B0E040A2AB9F"  

local FindDlgID    = 'A0562FC4-25FA-48DC-BA5E-48EFA639865F'
local ReplaceDlgID = '070544C7-E2F6-4E7B-B348-7583685B5647'
local GrepDlgID    = '39BE672E-9303-4F06-A38A-ECC35ABD98B6'
local FindFileID   = '8C9EAD29-910F-4B24-A669-EDAFBA6ED964'

local Find          = 1
local FindWord      = 2
local Replace       = 3
local ReplaceWord   = 4
local Repeat        = 5
local RepeatBack    = 6
local PickWord      = 7
local RemoveHilight = 8

local optRegExp     = 1
local optCaseSens   = 2
local optWholeWords = 4
local optPrompt     = 8


Macro { description="Edt Find: Find"; area="Editor"; key = "CtrlS";
  action=function()
    Plugin.Call(EdtFind, Find)
  end;
}

Macro { description="Edt Find: Find word"; area="Editor"; key="AltS";
  action=function()
    Plugin.Call(EdtFind, FindWord)
  end;
}

Macro { description="Edt Find: Replace"; area="Editor"; key="CtrlR";
  action=function()
    Plugin.Call(EdtFind, Replace)
  end;
}

Macro { description="Edt Find: Replace word"; area="Editor"; key="AltR";
  action=function()
    Plugin.Call(EdtFind, ReplaceWord)
  end; 
}

Macro { description="Edt Find: find next"; area="Editor"; key="CtrlL"; 
  action=function()
    Plugin.Call(EdtFind, Repeat)
  end; 
}

Macro { description="Edt Find: find prev"; area="Editor"; key="CtrlShiftL"; 
  action=function()
    Plugin.Call(EdtFind, RepeatBack)
  end; 
}

Macro { description="Edt Find: Pick word"; area="Editor"; key="CtrlP";
  action=function()
--  history.disable(8); -- Чтобы текущее слово не попало в историю...
    Plugin.Call(EdtFind, PickWord)
  end; 
}

Macro { description="Edt Find: Remove Highlight"; area="Editor"; key="AltP";
  action=function()
    Plugin.Call(EdtFind, RemoveHilight)
  end; 
}

--Macro { description="Edt Find: Remove Highlight or close edfitor"; area="Editor"; key="Esc";
--  condition= function()
--    return Plugin.SyncCall(EdtFind, "mark")
--  end;
--  action=function()
--    Plugin.Call(EdtFind, RemoveHilight)
--  end; 
--}

-------------------------------------------------------------------------------

function EdtFindMarkWord()
  if Editor.Sel(0, 4) == 0 then 
    Keys("SelWord")
  end

  if Editor.Sel(0, 4) ~= 0 then 
    if _G.EditFindMark then 
      _G.EditFindMark = _G.EditFindMark .. "|";
    else
      _G.EditFindMark = ""
    end
    _G.EditFindMark = _G.EditFindMark .. "\\b" .. Editor.SelValue .. "\\b"

    Editor.Sel(4)

----  msgbox("", _G.EditFindMark)
    Plugin.Call(EdtFind, "RegExp:1 Mark " .. _G.EditFindMark)
  end 
end



Macro { description="Edt Find: Pick new word"; area="Editor"; key="CtrlQ:Release";
  condition= function()
    return Plugin.Exist(EdtFind)
  end;
  action=function()
    _G.EditFindMark = nil
    EdtFindMarkWord()
  end; 
}


Macro { description="Edt Find: Pick add word"; area="Editor"; key="CtrlQ:Hold";
  action=function()
    EdtFindMarkWord()
  end; 
}


--Macro { description="Edt Find: Pick word"; area="Editor"; key="RAlt:Down";
--  action=function()
--    Plugin.Call(EdtFind, PickWord)
--  end; 
--}

--Macro { description="Edt Find: Pick word"; area="Editor"; key="RAlt:Up";
--  action=function()
--    Plugin.Call(EdtFind, RemoveHilight)
--  end; 
--}


-------------------------------------------------------------------------------
-- Сервисы для диалогов

Macro { description="Edt Find: Insert word"; area="Dialog"; key="CtrlS CtrlR";
  condition= function()
    return (Dlg.Id == FindDlgID) or (Dlg.Id == ReplaceDlgID)
  end;
  action=function()
    Keys("CtrlP")
  end; 
}


Macro { description="Edt Find: Editor scroll for grep"; area="Dialog"; key="CtrlUp CtrlDown";
  condition= function()
    return Dlg.Id == GrepDlgID
  end;
  action=function()
    local Info = editor.GetInfo()
    editor.SetPosition(nil, nil, nil, nil, Info.TopScreenLine + (mf.akey(1):sub(5) == "Down" and 1 or -1))
    editor.Redraw()
  end; 
}


Macro { description="Edt Find: Синхронизация с диалогом поиска"; area="Dialog"; key="Enter CtrlEnter";
  condition= function()
    return Dlg.Id == FindFileID
  end;
  action=function()
    local Str = Dlg.GetValue(6, 0)
    local CaseSens = Dlg.GetValue(11, 0) == 1
    local WholeWords = Dlg.GetValue(12, 0) == 1
    if Str ~= "" then 
      Plugin.Call(EdtFind, "Set", Str, (CaseSens and optCaseSens or 0) + (WholeWords and optWholeWords or 0))
    end
    Keys("AKey")
  end; 
}


--[=[

--Macro { description="Edt Find: Find word forward"; area="Editor"; key="CtrlAltDown"
--  action=function()
----history.disable(8); -- Чтобы текущее слово не попало в историю...
--
--  Plugin.Call(#%EdtFind, #%PickWord)
--  Plugin.Call(#%EdtFind, #%Repeat)
--end; }
--
--Macro { description="Edt Find: Find word up"; area="Editor"; key="CtrlAltUp"
--  action=function()
----history.disable(8); -- Чтобы текущее слово не попало в историю...
--
--  Plugin.Call(#%EdtFind, #%PickWord)
--  Plugin.Call(#%EdtFind, #%RepeatBack)
--end; }


Macro { description="Edt Find: Find Files"; area="Shell"; key="CtrlS"
  action=function()
--  Plugin.Call(#%EdtFind)
  Plugin.Call(#%EdtFind, #%Find)
end; }

]=]