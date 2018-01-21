
local FarHints = 'CDF48DA0-0334-4169-8453-69048DD3B51C'


Macro { 
  description="Far Hints: Close hint or toggle panels"; area="Shell"; key="Esc";

  action = function()
    if not Plugin.Call(FarHints, "Hide") then
      if CmdLine.Empty then
        Keys("CtrlO")
      else
        Keys("Esc")
      end
    end
  end;
}
 

Macro {
  description="Far Hints: Keyboard change hint size"; area="Shell Tree Dialog"; key="Add Subtract";

  priority=99;

  condition= function()
--  return win.GetEnv("FarHint") == "1"
    return Plugin.SyncCall(FarHints, "Visible")
  end;

  action = function()
    local n = akey(2) == "Add" and 1 or -1
    Plugin.Call(FarHints, "Size", n)
  end;
}


Macro 
{ 
  description="Far Hints: Mouse change hint size"; area="Shell Tree Dialog"; key="MsWheelUp MsWheelDown";

  priority=99;

  condition= function()
--  return win.GetEnv("FarHint") == "1"
    return Plugin.SyncCall(FarHints, "Visible")
  end;

  action=function()
    local n = akey(2) == "MsWheelUp" and 1 or -1
    Plugin.Call(FarHints, "Size", n)
  end;
}
