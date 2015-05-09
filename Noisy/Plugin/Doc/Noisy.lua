
-- Макросы для управлением музыкальным проигрывателем Noisy

local Shortcuts = 
{
  {"CtrlAltA",        "Add files",     "//Add"},
  {"CtrlAltO",        "Open files",    "//Open"},
  {"CtrlAltI",        "Information",   "//Info"},
  {"CtrlAltG",        "Goto track",    "//Playlist"},
  {"CtrlAltP",        "Play/Pause",    "/Playpause"},
  {"CtrlAltS",        "Stop",          "/Stop"},
  {"CtrlAltX",        "Exit",          "/Quit"},
  {"CtrlAltAdd",      "Volume Up",     "/Volume=+5"},
  {"CtrlAltSubtract", "Volume Down",   "/Volume=-5"},
  {"CtrlAltMultiply", "Mute",          "/Mute=1"},
  {"CtrlAltPgDn",     "Next track",    "/Next"},
  {"CtrlAltPgUp",     "Prev track",    "/Prev"},
  {"CtrlAltHome",     "First track",   "/First"},
  {"CtrlAltEnd",      "Last track",    "/Last"},
  {"CtrlAltRight",    "Seek forward",  "/Seek=+5"},
  {"CtrlAltLeft",     "Seek backward", "/Seek=-5"}
}


local NoisyID = "298208DF-2031-4DD8-A461-E3DD80C72F46"

local Noisy = {}

function Noisy.Installed()
  return Plugin.Exist(NoisyID)
end;

function Noisy.Call(...)
  return Plugin.Call(NoisyID, ...)
end;


for i,Cmd in ipairs(Shortcuts) do
  Macro { description="Noisy: "..Cmd[2]; key=Cmd[1]; area="Common";
    condition = Noisy.Installed;
    action = function()
      Noisy.Call(Cmd[3])
    end
  }
end
