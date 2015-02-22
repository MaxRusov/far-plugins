-- Вспомогательные процедуры для плагина MacroLib
-- Файл должен находиться в каталоге плагина 

MacroLib = {}

MacroLib.ID = "84884660-5B2F-4581-9282-96E00AE109A2"
                     
local PID = MacroLib.ID


MacroLib.Installed = function()
  return Plugin.Exist(PID)
end

MacroLib.Call = function(...)
  return Plugin.SyncCall(PID, ...)
end

MacroLib.Menu = function()
  return Plugin.Menu(PID)
end

MacroLib.AddLua = function(...)
  return Plugin.SyncCall(PID, "AddLua", ...)
end


MacroLib.Macros = {}


MacroLib.Check = function(Idx)
  if MacroLib.Macros[Idx].condition then
    return MacroLib.Macros[Idx].condition()
  else
    return true
  end
end


MacroLib.Run = function(Idx)
  MacroLib.Macros[Idx].action()
end


MacroLib.UpdateLuaMacros = function()
  MacroLib.Macros = {}
  MacroLib.AddLua(0) 
  for i = 1, math.huge do
    local m = mf.GetMacroCopy(i)
    if not m then break end
    if m.FileName and m.action then
      local vRow = debug.getinfo(m.action).linedefined
      if m.area then
        if not m.disabled then 
          local vIdx = MacroLib.AddLua(1, m.description, m.key, m.area, m.flags, m.FileName, vRow)
          MacroLib.Macros[vIdx] = m
        end
      else
        MacroLib.AddLua(2, "." .. m.group .. ": " .. (m.description or "") , "", "", m.FileName, vRow) 
      end
    end
  end
end


_G.MacroLib = MacroLib
