
-- Макросы для управлением музыкальным проигрывателем Noisy

local NoisyID = "298208DF-2031-4DD8-A461-E3DD80C72F46"

local ID = NoisyID;

local Noisy = {}

function Noisy.Installed()
  return Plugin.Exist(ID)
end;

function Noisy.Call(...)
  return Plugin.Call(ID, ...)
end;


Macro { description="Noisy: Add files"; area="Common"; key="CtrlAltA";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("//Add")
  end;
}

Macro { description="Noisy: Open files"; area="Common"; key="CtrlAltO";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("//Open")
  end;
}

Macro { description="Noisy: Play/Pause"; area="Common"; key="CtrlAltP";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/Playpause")
  end;
}

Macro { description="Noisy: Stop"; area="Common"; key="CtrlAltS";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/Stop")
  end;
}


Macro { description="Noisy: Information"; area="Common"; key="CtrlAltI";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("//Info")
  end;
}


Macro { description="Noisy: Information"; area="Common"; key="CtrlAltI";  
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("//Info");
  end;
}


Macro { description="Noisy: Goto track"; area="Common"; key="CtrlAltG";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("//Playlist")
  end;
}

Macro { description="Noisy: Exit"; area="Common"; key="CtrlAltX";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/Quit")
  end;
}

Macro { description="Noisy: Volume Up"; area="Common"; key="CtrlAltAdd";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/Volume=+5")
  end;
}

Macro { description="Noisy: Volume Down"; area="Common"; key="CtrlAltSubtract";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/Volume=-5")
  end;
}

Macro { description="Noisy: Mute"; area="Common"; key="CtrlAltMultiply";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/Mute=1")
  end;
}

Macro { description="Noisy: Next track"; area="Common"; key="CtrlAltPgDn";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/Next")
  end;
}

Macro { description="Noisy: Prev track"; area="Common"; key="CtrlAltPgUp";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/Prev")
  end;
}

Macro { description="Noisy: First track"; area="Common"; key="CtrlAltHome";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/First")
  end;
}

Macro { description="Noisy: Last track"; area="Common"; key="CtrlAltEnd";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/Last")
  end;
}

Macro { description="Noisy: Seek forward"; area="Common"; key="CtrlAltRight";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/Seek=+5")
  end;
}

Macro { description="Noisy: Seek backward"; area="Common"; key="CtrlAltLeft";
  condition=Noisy.Installed;
  action=function()
    Noisy.Call("/Seek=-5")
  end;
}
