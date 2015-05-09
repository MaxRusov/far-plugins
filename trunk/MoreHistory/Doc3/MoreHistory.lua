
MoreHistory = {}

PID = "0AB780BC-36CA-4FDA-B321-70520D875CDE"

MoreHistory.OpenFolderHistory = function(Filter, Group, Order, Hidden)
  local M = mmode(3,1)
  Plugin.Call(PID, "OpenFolderHistory", Filter, Group, Order, Hidden)
--  mmode(3,M)
end

MoreHistory.OpenEditorHistory = function(Filter, Group, Order, Hidden)
  local M = mmode(3,1)
  Plugin.Call(PID, "OpenEditorHistory", Filter, Group, Order, Hidden)
--  mmode(3,M)
end

MoreHistory.OpenModifyHistory = function(Filter, Group, Order, Hidden)
  local M = mmode(3,1)
  Plugin.Call(PID, "OpenModifyHistory", Filter, Group, Order, Hidden)
--  mmode(3,M)
end

MoreHistory.OpenCommandHistory = function(Filter, Group, Order, Hidden)
  local M = mmode(3,1)
  Plugin.Call(PID, "OpenCommandHistory", Filter, Group, Order, Hidden)
--  mmode(3,M)
end
