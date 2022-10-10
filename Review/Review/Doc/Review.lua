--
-- Review Macro API
-- Размещается в каталоге Macro\modules
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


-- Переход к следующему изображению в текщей панели
-- Orig=0, Next=1 - к следующему
-- Orig=0, Next=0 - к предыдущему
-- Orig=1         - к первому
-- Orig=2         - к последнему
-- Возвращает: Признак успешности перехода

function Review.Goto(Orig, Next)
  return Plugin.Call(ID, "Goto", Orig, Next)
end;

-- Установка масштаба изображения
-- Mode=0  - Автоматический масштаб
--   Val=1 - По максимальному размеру
--   Val=2 - По ширине
--   Val=3 - По высоте
-- Mode=1  - Установка линейного масштаба
--   Val   - Масштабный коээфициент (вещественное число), 1 - 100%
-- Mode=2  - Изменение логарифмического масштаба
--   Val   - Шаг изменения. При 100% масштабе 1 соответствует 1%
-- Mode=3  - То-же, что Mode=2, относительно курсора мыши
-- Возвращает: Режим, Коэффициент

function Review.Scale(Mode, Val)
  return Plugin.Call(ID, "Scale", Mode, Val)
end;

-- Установка текущей страницы для многостраничного изображения
-- Возвращает: Текущая страница, Количество страниц

function Review.Page(Number)
  return Plugin.Call(ID, "Page", Number)
end;


-- Повторное декодирование изображения с помощью определенного декодера
-- Mode=0 - То-же декодер
-- Mode=1 - Декодер по умолчанию
-- Mode=2 - Следующий декодер
-- Mode=3 - Предыдущий декодер
-- Возвращает имя нового декодера

function Review.Decoder(Mode)
  return Plugin.Call(ID, "Decoder", Mode)
end;


-- Поворот/отражение изображения
-- Mode=0  - относительный поворот
--   Val=1 - поворот +90
--   Val=2 - поворот -90
--   Val=3 - отражение по горизонтали
--   Val=4 - отражение по вертикали

function Review.Rotate(Mode, Val)
  return Plugin.Call(ID, "Rotate", Mode, Val)
end;


-- Сохранение повернутого изображения
-- Flags&1 - Поворот путем коррекции EXIF заголовка (если возможно)
-- Flags&2 - Поворот путем трансформации
-- Flags&4 - Допустима трансформация с потерей качества
-- Возвращает признак успешности сохранения

function Review.Save(Flags)
  return Plugin.Call(ID, "Save", Flags)
end;


-- Включает/выключает режим полноэкранного отображения
-- Если входной параметр опущен - возвращает текущее состояние

function Review.Fullscreen(On)
  return Plugin.Call(ID, "Fullscreen", On)
end;


-- Устанавливает громкость воспроизведения
-- Если входной параметр опущен - возвращает текущую громкость

function Review.Volume(Val)
  return Plugin.Call(ID, "Volume", Val)
end;


-- Устанавливает текущую позицию медиа файла (Val - в ms)
-- Orig=0 - Val - позиция от начала файла
-- Orig=1 - Val - смещение от текущей позиции 
-- Orig=2 - Val - позиция от конца файла 
-- Возвращает: Позиция, Длина

function Review.Seek(Orig, Val)
  return Plugin.Call(ID, "Seek", Orig, Val)
end;


-- Устанавливает текущий Audio поток
-- Orig=0 - Val - Абсолютный номер потока
-- Orig=1 - Val - Переключение текущего потока (в цикле)
-- Возвращает: Номер потока, Количество потоков

function Review.Audio(Orig, Val)
  return Plugin.Call(ID, "Audio", Orig, Val)
end;

-- Отображение эскизов 

function Review.Thumbs(...)
  return Plugin.Call(ID, "Thumbs", ...)
end;


-- Устанавливает размер эскиза, если задано Val
-- Возвращает: Новый размер эскиза

function Review.Size(Val)
  return Plugin.Call(ID, "Size", Val)
end;

return Review