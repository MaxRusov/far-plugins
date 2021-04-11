--
-- Review Macro
-- –азмещаетс€ в каталоге Macro\scripts
--

require "Review"

Macro 
{ 
  description="Review: QuickView Helper"; area="Shell"; 
    key="CtrlO CtrlU CtrlF1 CtrlF2 Esc CtrlUp CtrlDown CtrlLeft CtrlRight";

  condition=function()
    if Review.IsQuickView() then
      Review.Update(0)
    end
    return false;
  end;

  action=function()
  end;
}


Macro 
{ 
  description="Review: Scale QuickView with mouse"; area="Shell";
    key="MsWheelUp MsWheelDown";

  condition=function()
    return (Review.Loaded() and Review.IsQuickView()) and 999 or False
  end;

  action=function()
    Review.Scale(3, akey(1):sub(-2) == "Up" and 5 or -5)
  end;
}


Macro 
{ 
  description="Review: Scale 0.N%"; area="Dialog"; key="/\\d/"; condition=Review.IsView;

  action=function()
    n = tonumber("0." .. mf.akey(2))
    n = n > 0 and n or 1
    Review.Scale(1, n)
  end;
}


Macro 
{ 
  description="Review: Goto Next Image"; area="Dialog"; key="PgDn Num3 CtrlMsWheelDown"; condition=Review.IsView; priority=99; EnableOutput=true;

  action=function()
    if Review.Goto(0, 1) then
      ShowHint("")
    else
      mf.beep(0)
      ShowHint("Last image")
    end
  end;
}

Macro 
{ 
  description="Review: Goto Prev Image"; area="Dialog"; key="PgUp Num9 CtrlMsWheelUp"; condition=Review.IsView; priority=99; EnableOutput=true;

  action=function()
    if Review.Goto(0, 0) then
      ShowHint("")
    else
      mf.beep(0)
      ShowHint("First image")
    end;
  end;
}


local LastFile

Macro 
{ 
  description="Review: Goto First Image"; area="Dialog"; key="Home"; condition=Review.IsView; EnableOutput=true;

  action=function()
    local File = APanel.Current
    if Review.Goto(1) then
      LastFile = File
      ShowHint("")
    else
      mf.beep(0)
      ShowHint("First image")
    end
  end;
}

Macro 
{ 
  description="Review: Goto Last Image"; area="Dialog"; key="End"; condition=Review.IsView; EnableOutput=true;

  action=function()
    local File = APanel.Current
    if Review.Goto(2) then
      LastFile = File
      ShowHint("")
    else
      mf.beep(0)
      ShowHint("Last image")
    end
  end;
}


Macro 
{ 
  description="Review: Goto back Image"; area="Dialog"; key="BS"; condition=Review.IsView; EnableOutput=true;

  action=function()
    if LastFile then
      if Review.Goto(3, LastFile) then
        LastFile = nil
      else
        mf.beep(0)
      end
    end
  end;
}



Macro 
{ 
  description="Review: Goto Next Page"; area="Dialog Shell"; key="CtrlPgDn CtrlMsWheelDown"; condition=Review.IsActive;

  action=function()
    Review.Page(Review.Page() + 1)
  end;
}

Macro 
{ 
  description="Review: Goto Prev Page"; area="Dialog Shell"; key="CtrlPgUp CtrlMsWheelUp"; condition=Review.IsActive;

  action=function()
    Review.Page(Review.Page() - 1)
  end;
}

Macro 
{ 
  description="Review: Goto First Page"; area="Dialog Shell"; key="CtrlHome"; condition=Review.IsActive;

  action=function()
    Review.Page(1)
  end;
}

Macro 
{ 
  description="Review: Goto Last Page"; area="Dialog Shell"; key="CtrlEnd"; condition=Review.IsActive;

  action=function()
    local Page, Pages = Review.Page()
    Review.Page(Pages)
  end;
}


Macro 
{ 
  description="Review: Next Decoder"; area="Dialog Shell"; key="AltPgDn"; condition=Review.IsActive;

  action=function()
    Review.Decoder(2)
  end;
}

Macro 
{ 
  description="Review: Prev Decoder"; area="Dialog Shell"; key="AltPgUp"; condition=Review.IsActive;

  action=function()
    Review.Decoder(3)
  end;
}

Macro 
{ 
  description="Review: Default Decoder"; area="Dialog Shell"; key="AltHome"; condition=Review.IsActive;

  action=function()
    Review.Decoder(1)
  end;
}


Macro 
{ 
  description="Review: Fullscreen mode On/Off"; area="Dialog"; key="F CtrlF"; condition=Review.IsView;

  action=function()
    Review.Fullscreen(not Review.Fullscreen())
  end;
}


Macro 
{ 
  description="Review: Rotate +90"; area="Dialog"; key=". ] AltMsWheelDown"; condition=Review.IsView;

  action=function()
    Review.Rotate(0, 1);
  end;
}

Macro 
{ 
  description="Review: Rotate -90"; area="Dialog"; key=", [ AltMsWheelUp"; condition=Review.IsView;

  action=function()
    Review.Rotate(0, 2);
  end;
}

Macro 
{ 
  description="Review: Swap horz"; area="Dialog"; key="Ctrl]"; condition=Review.IsView;

  action=function()
    Review.Rotate(0, 3);
  end;
}

Macro 
{ 
  description="Review: Swap vert"; area="Dialog"; key="Ctrl["; condition=Review.IsView;

  action=function()
    Review.Rotate(0, 4);
  end;
}

--Macro 
--{ 
--  description="Review: Save picture"; area="Dialog"; key="F2"; condition=Review.IsView;
--
--  action=function()
--    if Review.Save(1+2+8) then
----    ShowHint("Saved")
--    end
--  end;
--}


------------------------------------------------------------------------------
-- Media-файлы


Macro 
{ 
  description="Review: Volume"; area="Dialog"; key="Up Down"; condition=Review.IsMedia;

  action=function()
    local Delta = akey(1):sub(-2) == "Up" and 10 or -10
    local Volume = Review.Volume( Review.Volume() + Delta )
    ShowHint("Volume: " .. Volume)
  end;
}


Macro 
{ 
  description="Review: Seek"; area="Dialog"; key="Left Right ShiftLeft ShiftRight"; condition=Review.IsMedia;

  action=function()
    local Delta = akey(1):sub(-4) == "Left" and -1 or 1
    Delta = akey(1):sub(1,5) == "Shift" and Delta or Delta * 10
    local Pos, Len = Review.Seek( 1, Delta * 1000 )
    ShowHint("Seek: " .. StrTime(Pos) .. " / " .. StrTime(Len))
  end;
}

function StrTime(aMS)
  return os.date("!%X",aMS/1000)
end;


Macro 
{ 
  description="Review: Next audio stream"; area="Dialog"; key="A CtrlA"; condition=Review.IsMedia;

  action=function()
    local Idx, Count = Review.Audio( 1, 1 )
    ShowHint("Audio: " .. (Idx+1) .. " / " .. Count)
  end;
}

Macro 
{ 
  description="Review: Prev audio stream"; area="Dialog"; key="CtrlShiftA"; condition=Review.IsMedia;

  action=function()
    local Idx, Count = Review.Audio( 1, -1 )
    ShowHint("Audio: " .. (Idx+1) .. " / " .. Count)
  end;
}

------------------------------------------------------------------------------
-- Ёскизы


Macro 
{ 
  description="Review: Scale Thumbs"; area="Dialog"; 
    key="CtrlMsWheelUp CtrlMsWheelDown ShiftMsWheelUp ShiftMsWheelDown"; 
    condition=Review.IsThumbView; priority=99;

  action=function()
    local Delta = akey(1):sub(-2) == "Up" and 1 or -1
    if akey(1):sub(1,4) == "Ctrl" then
      Delta = Delta * 16
    end
    Review.Size( Review.Size() + Delta )
  end;
}


Macro 
{ 
  description="Review: Thumbs Size"; area="Dialog"; key="/\\d/"; condition=Review.IsThumbView;

  action=function()
    n = tonumber(mf.akey(2))
    Review.Size(96 + n * 32)
  end;
}

