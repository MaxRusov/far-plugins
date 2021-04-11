
Review = require "Review"

local ffi = require "ffi"
ffi.cdef "short GetKeyState(int Key);"

Macro 
{ 
  description="Review: Goto Next Dir"; area="Dialog"; key="ShiftPgDn"; condition=Review.IsView; 

  action=function()
    if Review.Goto(0, 1) then
      ShowHint("")
    elseif not APanel.Plugin then
      local vPath, vFile, vPath1

      Far.DisableHistory(-1)
      while true do
        vPath = APanel.Path
        vFile = mf.fsplit(vPath, 12)
        vPath1 = mf.fsplit(vPath, 3)
        if vFile == "" then
          ShowHint('Last Dir')
          break
        end

        panel.SetPanelDirectory(nil, 1, vPath1)
        Panel.SetPos(0, vFile)

        if APanel.CurPos < APanel.ItemCount then
          Panel.SetPosIdx(0, APanel.CurPos + 1)

          if APanel.Folder then

            while APanel.Folder and APanel.Current ~= ".." do
              panel.SetPanelDirectory(nil, 1, APanel.Path .. "\\" .. APanel.Current )
              Panel.SetPosIdx(0, 2)
              ShowHint(APanel.Path)
            end
            
            Panel.SetPosIdx(0, 1)
            if Review.Goto(0, 1) then
              break
            end
          else
            ShowHint( APanel.Path )
            Panel.SetPosIdx(0, APanel.CurPos - 1)
            if Review.Goto(0, 1) then
              break
            end
          end
        end

        ShowHint(APanel.Path)
        if ffi.C.GetKeyState(27) < 0 then
          ShowHint('Cancel')
          break
        end
      end
    else
      mf.beep(0)
    end
  end;
}


Macro 
{ 
  description="Review: Goto Prev Dir"; area="Dialog"; key="ShiftPgUp"; condition=Review.IsView; 

  action=function()
    if Review.Goto(0, 0) then
      ShowHint("")
    elseif not APanel.Plugin then
      local vPath, vFile, vPath1
      Far.DisableHistory(-1)
      while true do
        vFile = "" 
        for i = 1, APanel.CurPos do
          if band(Panel.Item(0,i,2), 16) == 0 then
            break
          end
          vFile = Panel.Item(0,i,0)
        end

        if vFile ~= "" and vFile ~= ".." then
          panel.SetPanelDirectory(nil, 1, APanel.Path .. "\\" .. vFile )
          ShowHint(APanel.Path)
          if Review.Goto(2) then
            break
          end
          Panel.SetPosIdx(0, -1)
        else
          vPath = APanel.Path
          vFile = mf.fsplit(vPath, 12)
          vPath1 = mf.fsplit(vPath, 3)
        
          panel.SetPanelDirectory(nil, 1, vPath1)
          Panel.SetPos(0, vFile)

          if APanel.CurPos > 1 then
            Panel.SetPosIdx(0, APanel.CurPos - 1)
            if APanel.Folder and APanel.Current ~= ".." then
              panel.SetPanelDirectory(nil, 1, APanel.Path .. "\\" .. APanel.Current )
              ShowHint(APanel.Path)
              if Review.Goto(2) then
                break
              end;
              Panel.SetPosIdx(0, -1)
            end
          else
            if vPath1:sub(-2) == ":\\" then
              ShowHint('First Dir')
              break
            end
          end
        end

        ShowHint(APanel.Path)
        if ffi.C.GetKeyState(27) < 0 then
          ShowHint('Cancel')
          break
        end
      end
    else
      mf.beep(0)
    end
  end;
}
