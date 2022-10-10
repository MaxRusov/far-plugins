
local EdtFind      = "E4ABD267-C2F9-4158-818F-B0E040A2AB9F"  

local Find          = 1
local FindWord      = 2
local Replace       = 3
local ReplaceWord   = 4
local Repeat        = 5
local RepeatBack    = 6
local PickWord      = 7
local RemoveHilight = 8

-------------------------------------------------------------------------------
-- Стандартные команды: F7, CtrlF7, ShiftF7, AltF7

Macro { description="Edt Find: Find"; area="Editor"; key = "F7";
  action=function()
    Plugin.Call(EdtFind, Find)
--  Plugin.Call(EdtFind, FindWord)
  end;
}

Macro { description="Edt Find: Replace"; area="Editor"; key="CtrlF7";
  action=function()
    Plugin.Call(EdtFind, Replace)
--  Plugin.Call(EdtFind, ReplaceWord)
  end;
}

Macro { description="Edt Find: find next"; area="Editor"; key="ShiftF7"; 
  action=function()
    Plugin.Call(EdtFind, Repeat)
  end; 
}

Macro { description="Edt Find: find prev"; area="Editor"; key="AltF7"; 
  action=function()
    Plugin.Call(EdtFind, RepeatBack)
  end; 
}

-------------------------------------------------------------------------------
