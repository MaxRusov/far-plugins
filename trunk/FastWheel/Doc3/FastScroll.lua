
local FastWheel = '4DF17F5F-E79B-46B1-A70C-04B573CECAA4' 

Macro 
{ 
  description="Fast Wheel: Mouse scroll accelerator"; area="Editor Viewer Shell"; key="MsWheelUp MsWheelDown";

  action=function()
    local n = akey(2) == "MsWheelUp" and 1 or 2;
    if not Plugin.Call(FastWheel, n) then
      Keys("AKey")
    end
  end;
}
