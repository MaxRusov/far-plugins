
local VisComp  = "AF4DAB38-C00A-4653-900E-7A8230308010"

Macro
{
  area="Shell"; key="Ctrl-"; description="Visual Compare: Compare folders or 2 selected files";

  action=function()
    if APanel.SelCount == 1 then

      File1 = APanel.Path .."\\" .. panel.GetSelectedPanelItem(nil, 1, 1).FileName

      if PPanel.SelCount == 1 then
        File2 = PPanel.Path .."\\" .. panel.GetSelectedPanelItem(nil, 0, 1).FileName
      else
        File2 = PPanel.Path .."\\" .. panel.GetSelectedPanelItem(nil, 1, 1).FileName
      end

      if not APanel.Left then
        Tmp = File2
        File2 = File1
        File1 = Tmp
      end

      Plugin.Command(VisComp, '"'..File1..'" "'..File2..'"') 

    else
      if APanel.SelCount == 2 then

        File1 = APanel.Path .."\\" .. panel.GetSelectedPanelItem(nil, 1, 1).FileName
        File2 = APanel.Path .."\\" .. panel.GetSelectedPanelItem(nil, 1, 2).FileName

        Plugin.Command(VisComp, '"'..File1..'" "'..File2..'"') 

      else
        Plugin.Menu(VisComp) 
      end
    end;
  end;
}
