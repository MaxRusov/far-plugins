--
-- Console Control
-- (c) Max Rusov
-- http://code.google.com/p/far-plugins
--
-- Интерфейсный модуль
-- Поместите файл в %FARPROFILE%\Macros\Modules
--

ConsoleControl = {}

ConsoleControl.ID = "94624B7B-FFDB-435F-B955-F99DBBC3BFE0"
                     
local PID = ConsoleControl.ID

ConsoleControl.Installed = function()
  return Plugin.Exist(PID)
end

ConsoleControl.Call = function(...)
  return Plugin.Call(PID, ...)
end

ConsoleControl.Menu = function()
  return Plugin.Menu(PID)
end

ConsoleControl.WindowSize = function(X, Y)
  return Plugin.Call(PID, "WindowSize", X, Y)
end

ConsoleControl.WindowSizeDelta = function(DX, DY)
  local X, Y = ConsoleControl.WindowSize()
  return ConsoleControl.WindowSize(X+DX, Y+DY)
end

ConsoleControl.BufferSize = function(X, Y)
  return Plugin.Call(PID, "BufferSize", X, Y)
end

ConsoleControl.BufferSizeDelta = function(DX, DY)
  local X, Y = ConsoleControl.BufferSize()
  return ConsoleControl.BufferSize(X+DX, Y+DY)
end

ConsoleControl.FontSize = function(Size)
  return Plugin.Call(PID, "FontSize", Size)
end

ConsoleControl.FontSizeDelta = function(D)
  return Plugin.Call(PID, "FontSizeDelta", D)
end

ConsoleControl.FontName = function(Name, Size)
  return Plugin.Call(PID, "FontName", Name, Size)
end

ConsoleControl.Maximize = function(On)
  return Plugin.Call(PID, "Maximize", On)
end                       

ConsoleControl.Topmost = function(On)
  return Plugin.Call(PID, "Topmost", On)
end                       

ConsoleControl.Transparency = function(Value)
  return Plugin.Call(PID, "Transparency", Value)
end                       
