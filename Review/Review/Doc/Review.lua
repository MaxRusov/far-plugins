--
-- Review Macro API
-- ����������� � �������� Macro\modules
--

local FarHints = "CDF48DA0-0334-4169-8453-69048DD3B51C" 
local ReviewID = "0364224C-A21A-42ED-95FD-34189BA4B204"
local ViewDlgID = "FAD3BD72-2641-4D00-8F98-5467EEBCE827"
local ThumbDlgID = "ABDFD3DF-FE59-4714-8068-9F944022EA50"


function ShowHint(Mess)
  if Mess ~= "" then
    Plugin.Call(FarHints, "Info", Mess)
  else
    Plugin.Call(FarHints, "Hide")
  end
end


local ID = ReviewID;

local Review = {}

function Review.Installed()
  return Plugin.Exist(ID)
end;

function Review.Loaded()
  return far.IsPluginLoaded(ID)
end;

function Review.IsView()
  return Area.Dialog and Dlg.Id == ViewDlgID
end;

function Review.IsThumbView()
  return Area.Dialog and Dlg.Id == ThumbDlgID
end;

function Review.IsMedia()
  return Review.IsView() and Plugin.SyncCall(ID, "IsMedia")
end;

function Review.IsQuickView()
  return Review.Loaded() and Plugin.SyncCall(ID, "IsQuickView")
end;

function Review.IsActive()
  return Review.IsView() or Review.IsQuickView()
end;

function Review.Update(Delay)
  return Plugin.SyncCall(ID, "Update", Delay)
end;


-- ������� � ���������� ����������� � ������ ������
-- Orig=0, Next=1 - � ����������
-- Orig=0, Next=0 - � �����������
-- Orig=1         - � �������
-- Orig=2         - � ����������
-- ����������: ������� ���������� ��������

function Review.Goto(Orig, Next)
  return Plugin.Call(ID, "Goto", Orig, Next)
end;

-- ��������� �������� �����������
-- Mode=0  - �������������� �������
--   Val=1 - �� ������������� �������
--   Val=2 - �� ������
--   Val=3 - �� ������
-- Mode=1  - ��������� ��������� ��������
--   Val   - ���������� ����������� (������������ �����), 1 - 100%
-- Mode=2  - ��������� ���������������� ��������
--   Val   - ��� ���������. ��� 100% �������� 1 ������������� 1%
-- Mode=3  - ��-��, ��� Mode=2, ������������ ������� ����
-- ����������: �����, �����������

function Review.Scale(Mode, Val)
  return Plugin.Call(ID, "Scale", Mode, Val)
end;

-- ��������� ������� �������� ��� ���������������� �����������
-- ����������: ������� ��������, ���������� �������

function Review.Page(Number)
  return Plugin.Call(ID, "Page", Number)
end;


-- ��������� ������������� ����������� � ������� ������������� ��������
-- Mode=0 - ��-�� �������
-- Mode=1 - ������� �� ���������
-- Mode=2 - ��������� �������
-- Mode=3 - ���������� �������
-- ���������� ��� ������ ��������

function Review.Decoder(Mode)
  return Plugin.Call(ID, "Decoder", Mode)
end;


-- �������/��������� �����������
-- Mode=0  - ������������� �������
--   Val=1 - ������� +90
--   Val=2 - ������� -90
--   Val=3 - ��������� �� �����������
--   Val=4 - ��������� �� ���������

function Review.Rotate(Mode, Val)
  return Plugin.Call(ID, "Rotate", Mode, Val)
end;


-- ���������� ����������� �����������
-- Flags&1 - ������� ����� ��������� EXIF ��������� (���� ��������)
-- Flags&2 - ������� ����� �������������
-- Flags&4 - ��������� ������������� � ������� ��������
-- ���������� ������� ���������� ����������

function Review.Save(Flags)
  return Plugin.Call(ID, "Save", Flags)
end;


-- ��������/��������� ����� �������������� �����������
-- ���� ������� �������� ������ - ���������� ������� ���������

function Review.Fullscreen(On)
  return Plugin.Call(ID, "Fullscreen", On)
end;


-- ������������� ��������� ���������������
-- ���� ������� �������� ������ - ���������� ������� ���������

function Review.Volume(Val)
  return Plugin.Call(ID, "Volume", Val)
end;


-- ������������� ������� ������� ����� ����� (Val - � ms)
-- Orig=0 - Val - ������� �� ������ �����
-- Orig=1 - Val - �������� �� ������� ������� 
-- Orig=2 - Val - ������� �� ����� ����� 
-- ����������: �������, �����

function Review.Seek(Orig, Val)
  return Plugin.Call(ID, "Seek", Orig, Val)
end;


-- ������������� ������� Audio �����
-- Orig=0 - Val - ���������� ����� ������
-- Orig=1 - Val - ������������ �������� ������ (� �����)
-- ����������: ����� ������, ���������� �������

function Review.Audio(Orig, Val)
  return Plugin.Call(ID, "Audio", Orig, Val)
end;

-- ����������� ������� 

function Review.Thumbs(...)
  return Plugin.Call(ID, "Thumbs", ...)
end;


-- ������������� ������ ������, ���� ������ Val
-- ����������: ����� ������ ������

function Review.Size(Val)
  return Plugin.Call(ID, "Size", Val)
end;

return Review