{$I Defines.inc}

unit PVApi;

interface

uses
  Windows;

const
  // Версия интерфейса PVD, описываемая этим заголовочным файлом.
  // Именно это значение рекомендуется возвращать в pvdInit при успешной инициализации.
  PVD_CURRENT_INTERFACE_VERSION = 1;
  // Именно это значение рекомендуется возвращать в pvdInit2 при успешной инициализации.
  PVD_UNICODE_INTERFACE_VERSION = 2;

const
  // Режим работы субплагина (только версия 2 интерфейса)
  PVD_IP_DECODE     = 1;      // Декодер (как версия 1)
  PVD_IP_TRANSFORM  = 2;      // Содержит функции для Lossless transform (интерфейс в разработке)
  PVD_IP_DISPLAY    = 4;      // Может быть использован вместо встроенной в PicView поддержки DX (интерфейс в разработке)
  PVD_IP_PROCESSING = 8;      // PostProcessing operations (интерфейс в разработке)

  PVD_IP_MULTITHREAD   = $100;  // Декодер может вызываться одновременно в разных нитях
  PVD_IP_ALLOWCACHE    = $200;  // PicView может длительное время НЕ вызывать pvdFileClose2 для кэширования декодированных изображений
  PVD_IP_CANREFINE     = $400;  // Декодер поддерживает улучшенный рендеринг (алиасинг)
  PVD_IP_CANREFINERECT = $800;  // Декодер поддерживает улучшенный рендеринг (алиасинг) заданного региона
  PVD_IP_CANREDUCE     = $1000; // Декодер может загрузить большое изображение с уменьшенным масштабом
  PVD_IP_NOTERMINAL    = $2000; // Этот модуль дисплея нельзя использовать в терминальных консолях
  PVD_IP_PRIVATE       = $4000; // Имеет смысл только в сочетании (PVD_IP_DECODE|PVD_IP_DISPLAY).
                                // Этот субплагин НЕ может быть использован как универсальный модуль вывода
                                // он умеет отображать только то, что декодировал сам
  PVD_IP_DIRECT        = $8000; // "Быстрый" модуль вывода. Например, вывод через DirectX.


const
  // Анимированное многостраничное изображение
  PVD_IIF_ANIMATED   = 1;
  // Если декодер поддерживает улучшенный рендеринг (алиасинг) заданного региона
  PVD_IIF_CAN_REFINE = 2;
  // Устанавливается декодером, если требуется наличие физического файла (с буфером декодер работать не умеет)
  PVD_IIF_FILE_REQUIRED = 4;
  // Многостраничное изображение соответсвует скану книги или журнала
  // Скорее всего первая страница является лицевой, а далее следуют развороты (левая и правая страница)
  PVD_IIF_MAGAZINE = $100;

const
  // Данные декодированного изображения доступны только для чтения
  PVD_IDF_READONLY          = 1;
  // **** Следующие флаги используются только во 2-й версии интерфейса
  // pImage содержит 32бита на пиксель и старший байт является альфа каналом
  PVD_IDF_ALPHA             = 2;   // для режимов с палитрой - старший байт берется из палитры
  // Один из цветов (субплагин возвращает его в pvdInfoDecode2.TransparentColor) считать прозрачным (только версия 2 интерфейса)
  PVD_IDF_TRANSPARENT       = 4;   // pvdInfoDecode2.TransparentColor содержит COLORREF прозрачного цвета
  PVD_IDF_TRANSPARENT_INDEX = 8;   // pvdInfoDecode2.TransparentColor содержит индекс прозрачного цвета
  PVD_IDF_ASDISPLAY         = 16;  // Субплагин является активным модулем вывода (можно не возвращать битмап изображения)
  PVD_IDF_PRIVATE_DISPLAY   = 32;  // "Внутреннее" представление, которое может быть использовано для вывода
                                   // только этим же субплагином (у плагина должен быть флаг PVD_IP_DISPLAY)
  PVD_IDF_COMPAT_MODE       = 64;  // Плагин второй версии вызван в режиме совместимости с первой (через PVD1Helper.cpp)


(*
// pvdInitPlugin2 - параметры инициализации субплагина
struct pvdInitPlugin2
{
	UINT32 cbSize;               // [IN]  размер структуры в байтах
	UINT32 nMaxVersion;          // [IN]  максимальная версия интерфейса, которую может поддержать PictureView
	const wchar_t *pRegKey;      // [IN]  ключ реестра, в котором субплагин может хранить свои настройки.
	                             //       Например для субплагина pvd_bmp.pvd этот ключ будет таким
	                             //       "Software\\Far2\\Plugins\\PictureView\\pvd_bmp.pvd"
	                             //       естественно в HKEY_CURRENT_USER.
	                             //       Субплагину рекомендуется сразу создать умолчательные значения (если
	                             //       ему есть что настраивать), чтобы сам PicView мог дать пользователю
	                             //       возможность настроить эти значения.
	DWORD  nErrNumber;           // [OUT] внутренний (для субплагина) код ошибки инициализации
	                             //       Субплагину желательно экспортировать функцию pvdTranslateError2
	void  *pContext;             // [OUT] контекст, используемый при обращении к субплагину

	// Some helper functions
	void  *pCallbackContext;     // [IN]  Это значение должно быть передано в функции, идущие ниже
	// 0-информация, 1-предупреждение, 2-ошибка
	void (__stdcall* MessageLog)(void *pCallbackContext, const wchar_t* asMessage, UINT32 anSeverity);
	// asExtList может содержать '*' (тогда всегда TRUE) или '.' (TRUE если asExt пусто). Сравнение регистронезависимое
	BOOL (__stdcall* ExtensionMatch)(wchar_t* asExtList, const wchar_t* asExt);
	//
	HMODULE hModule;             // [IN]  HANDLE загруженной библиотеки
};
*)
type
  PPVDInitPlugin2 = ^TPVDInitPlugin2;
  TPVDInitPlugin2 = record
    cbSize :UINT;
    nMaxVersion :UINT;
    pRegKey :PWideChar;
    nErrNumber :DWORD;
    pContext :Pointer;
    pCallbackContext :Pointer;
    MessageLog :Pointer;
    ExtensionMatch :Pointer;
    hModule :THandle;
  end;

(*
struct pvdInfoPlugin2
{
	UINT32 cbSize;               // [IN]  размер структуры в байтах
	UINT32 Flags;                // [OUT] Возможные флаги PVD_IP_xxx
	const wchar_t *pName;        // [OUT] имя субплагина
	const wchar_t *pVersion;     // [OUT] версия субплагина
	const wchar_t *pComments;    // [OUT] комментарии о субплагине: для чего предназначен, кто автор субплагина, ...
	UINT32 Priority;             // [OUT] приоритет субплагина; используется только для новых субплагинов при формировании
	                             //       списка декодеров. Чем выше Priority тем выше в списке он будет размещен.
	HMODULE hModule;             // [IN]  HANDLE загруженной библиотеки
};
*)
type
  PPVDInfoPlugin2 = ^TPVDInfoPlugin2;
  TPVDInfoPlugin2 = record
    cbSize :UINT;
    Flags :UINT;
    pName :PWideChar;
    pVersion :PWideChar;
    pComments :PWideChar;
    Priority :UINT;
    hModule :THandle;
  end;

(*
// pvdFormats2 - список поддерживаемых форматов
struct pvdFormats2
{
    UINT32 cbSize;               // [IN]  размер структуры в байтах
    const wchar_t *pSupported;   // [OUT] Список поддерживаемых расширений через запятую.
                                 //       Здесь допускается указание "*" означающее, что
                                 //       субплагин является универсальным.
                                 //       Если при распознавании ни один из субплагинов не подошел по расширению -
                                 //       PicView все равно попытается открыть файл субплагином, если расширение
                                 //       не указано в списке его игнорируемых.
    const wchar_t *pIgnored;     // [OUT] Список игнорируемых расширений через запятую.
                                 //       Для файлов с указанными расширениями субплагин не
                                 //       будет вызываться вообще. Укажите "." для игнорирования
	                             //       файлов без расширений.
    // !!! Списки являются "умолчанием". Пользователь может перенастроить список расширений.
};
*)
type
  PPVDFormats2 = ^TPVDFormats2;
  TPVDFormats2 = record
    cbSize :UINT;
    pSupported :PWideChar;
    pIgnored :PWideChar;
  end;

(*
struct pvdInfoImage2
{
	UINT32 cbSize;               // [IN]  ?????? ????????? ? ??????
	void   *pImageContext;       // [IN]  ??? ?????? ?? pvdFileOpen2 ????? ???? ?? NULL,
								 //       ???? ?????? ???????????? ??????? pvdFileDetect2
								 // [OUT] ????????, ???????????? ??? ????????? ? ?????
	UINT32 nPages;               // [OUT] ?????????? ??????? ???????????
								 //       ??? ?????? ?? pvdFileDetect2 ?????????? ?????????????
	UINT32 Flags;                // [OUT] ????????? ?????: PVD_IIF_xxx
								 //       ??? ?????? ?? pvdFileDetect2 ???????? ???? PVD_IIF_FILE_REQUIRED
	const wchar_t *pFormatName;  // [OUT] ???????? ??????? ?????
								 //       ??? ?????? ?? pvdFileDetect2 ?????????? ?????????????, ?? ??????????
	const wchar_t *pCompression; // [OUT] ???????? ??????
								 //       ??? ?????? ?? pvdFileDetect2 ?????????? ?????????????
	const wchar_t *pComments;    // [OUT] ????????? ??????????? ? ?????
								 //       ??? ?????? ?? pvdFileDetect2 ?????????? ?????????????
	//
	DWORD  nErrNumber;           // [OUT] ?????????? ?? ?????? ?????????????? ??????? ?????
	                             //       ?????????? ?????????? ?????????????? ??????? pvdTranslateError2
	                             //       ??? ???????? ???? (< 0x7FFFFFFF) PicView ??????? ???
	                             //       ?????????? ?????? ?????????? ???? ?????? ?????. PicView
	                             //       ?? ????? ?????????? ??? ?????? ????????????, ???? ??????
	                             //       ??????? ???? ?????-?? ?????? ???????????-?????????.

	DWORD nReserved, nReserver2;
};
*)
type
  PPVDInfoImage2 = ^TPVDInfoImage2;
  TPVDInfoImage2 = record
    cbSize :UINT;
    pImageContext :Pointer;
    nPages :UINT;
    Flags :UINT;
    pFormatName :PWideChar;
    pCompression :PWideChar;
    pComments :PWideChar;
    nErrNumber :DWORD;
    nReserverd, nReserverd2 :DWORD;
  end;

(*
struct pvdInfoPage2
{
	UINT32 cbSize;            // [IN]  размер структуры в байтах
	UINT32 iPage;             // [IN]  номер страницы (0-based)
	UINT32 lWidth;            // [OUT] ширина страницы
	UINT32 lHeight;           // [OUT] высота страницы
	UINT32 nBPP;              // [OUT] количество бит на пиксель (только информационное поле - в расчётах не используется)
	UINT32 lFrameTime;        // [OUT] для анимированных изображений - длительность отображения страницы в тысячных секунды;
	                          //       иначе - не используется
	// Plugin output
	DWORD  nErrNumber;           // [OUT] Информация об ошибке
                                 //       Субплагину желательно экспортировать функцию pvdTranslateError2
	UINT32 nPages;               // [OUT] 0, или плагин может скорректировать количество страниц изображения
	const wchar_t *pFormatName;  // [OUT] NULL или плагин может скорректировать название формата файла
	const wchar_t *pCompression; // [OUT] NULL или плагин может скорректировать алгоритм сжатия
};
*)
type
  PPVDInfoPage2 = ^TPVDInfoPage2;
  TPVDInfoPage2 = record
    cbSize :UINT;
    iPage :UINT;
    lWidth :UINT;
    lHeight :UINT;
    nBPP :UINT;
    lFrameTime :UINT;
    nErrNumber :DWORD;
    nPages :UINT;
    pFormatName :PWideChar;
    pCompression :PWideChar;
  end;


const
  // Сейчас допустимы только "PVD_CM_BGR" и "PVD_CM_BGRA"
  PVD_CM_UNKNOWN =  0;  // -- Такое изображение скорее всего не будет показано плагином
  PVD_CM_GRAY    =  1;  // "Gray scale"  -- UNSUPPORTED !!!
  PVD_CM_AG      =  2;  // "Alpha_Gray"  -- UNSUPPORTED !!!
  PVD_CM_RGB     =  3;  // "RGB"         -- UNSUPPORTED !!!
  PVD_CM_BGR     =  4;  // "BGR"
  PVD_CM_YCBCR   =  5;  // "YCbCr"       -- UNSUPPORTED !!!
  PVD_CM_CMYK    =  6;  // "CMYK"
  PVD_CM_YCCK    =  7;  // "YCCK"        -- UNSUPPORTED !!!
  PVD_CM_YUV     =  8;  // "YUV"         -- UNSUPPORTED !!!
  PVD_CM_BGRA    =  9;  // "BGRA"
  PVD_CM_RGBA    = 10;  // "RGBA"        -- UNSUPPORTED !!!
  PVD_CM_ABRG    = 11;  // "ABRG"        -- UNSUPPORTED !!!
  PVD_CM_PRIVATE = 12;  // Только если Дисплей==Декодер и биты не возвращаются

(*
struct pvdInfoDecode2
{
	UINT32 cbSize;             // [IN]  размер структуры в байтах
	UINT32 iPage;              // [IN]  Номер декодируемой страницы (0-based)
	UINT32 lWidth, lHeight;    // [IN]  Рекомендуемый размер декодированного изображения (если декодер поддерживает антиалиасинг)
	                           // [OUT] Размер декодированной области (pImage)
	UINT32 nBPP;               // [IN]  PicView может запросить предпочтительный формат (пока не используется)
	                           // [OUT] количество бит на пиксель в декодированном изображении
	                           //       при использовании 32 бит может быть указан флаг PVD_IDF_ALPHA
                               //       PicView не отображает это значение пользователю - в заголовке 
	                           //       выводится pvdInfoPage2.nBPP, так что можно спокойно делать преобразования
	INT32  lImagePitch;        // [OUT] модуль - длина строки декодированного изображения в байтах;
	                           //       положительные значения - строки идут сверху вниз, отрицательные - снизу вверх
	UINT32 Flags;              // [IN]  PVD_IDF_ASDISPLAY | PVD_IDF_COMPAT_MODE
	                           // [OUT] возможные флаги: PVD_IDF_*
	union {
	RGBQUAD TransparentColor;  // [OUT] if (Flags&PVD_IDF_TRANSPARENT) - содержит цвет, который считается прозрачным
	DWORD  nTransparentColor;  //       if (Flags&PVD_IDF_TRANSPARENT_INDEX) - содержит индекс прозрачного цвета
	};                         // Внимание! При указании флага PVD_IDF_ALPHA - Transparent игнорируется

	BYTE   *pImage;            // [OUT] указатель на данные изображения в допустимом формате
	                           //       формат зависит от nBPP
	                           //       1,4,8 бит - ражимы с палитрой
	                           //       16 бит - каждый компонент цвета состоит из 5 бит (BGR)
	                           //       24 бит - 8 бит на компонент (BGR)
	                           //       32 бит - 8 бит на компонент (BGR или BGRA при указании PVD_IDF_ALPHA)
	UINT32 *pPalette;          // [OUT] указатель на палитру изображения, используется в форматах 8 и меньше бит на пиксель
	UINT32 nColorsUsed;        // [OUT] количество используемых цветов в палитре; если 0, то используются все возможные цвета
	                           //       (пока не используется, палитра должна содержать [1<<nBPP] цветов)

	DWORD  nErrNumber;         // [OUT] Информация об ошибке декодирования
	                           //       Субплагину желательно экспортировать функцию pvdTranslateError2

	LPARAM lParam;             // [OUT] Субплагин может использовать это поле на свое усмотрение

	pvdColorModel  ColorModel; // [OUT] Сейчас поддерживаются только PVD_CM_BGR & PVD_CM_BGRA
	DWORD          Precision;  // [RESERVED] bits per channel (8,12,16bit)
	POINT          Origin;     // [RESERVED] m_x & m_y; Interface apl returns m_x=0; m_y=Ymax;
	float          PAR;        // [RESERVED] Pixel aspect ratio definition
	pvdOrientation Orientation;// [RESERVED]
	UINT32 nPages;             // [OUT] 0, или плагин может скорректировать количество страниц изображения
	const wchar_t *pFormatName;  // [OUT] NULL или плагин может скорректировать название формата файла
	const wchar_t *pCompression; // [OUT] NULL или плагин может скорректировать алгоритм сжатия
	union {
		RGBQUAD BackgroundColor; // [IN] Декодер может использовать это поле при рендеринге
		DWORD  nBackgroundColor; //      прозрачных изображений
	};
};
*)
type
  PPVDInfoDecode2 = ^TPVDInfoDecode2;
  TPVDInfoDecode2 = packed record
    cbSize :UINT;
    iPage :UINT;
    lWidth :UINT;
    lHeight :UINT;
    nBPP :UINT;
    lImagePitch :Integer;
    Flags :UINT;
    nTransparentColor :DWORD;
    pImage :Pointer;
    pPalette :Pointer;
    nColorsUsed :UINT;
    nErrNumber :DWORD;
    lParam :LPARAM;
    ColorModel :byte; {PPVDColorModel}
    Precision :DWORD;
    Origin :TPoint;
    PAR :Extended; {???}
    Orientation :byte; {PPVDOrientation}
    nPages :UINT;
    pFormatName :PWideChar;
    pCompression :PWideChar;
    nBackgroundColor :DWORD;
  end;

(*
struct pvdInfoDisplayInit2
{
	UINT32 cbSize;               // [IN]  размер структуры в байтах
	HWND hWnd;                   // [IN]
	DWORD nCMYKparts;
	DWORD *pCMYKpalette;
	DWORD nCMYKsize;
	DWORD uCMYK2RGB;
	DWORD nErrNumber;            // [OUT]
};
*)
type
  PPVDInfoDisplayInit2 = ^TPVDInfoDisplayInit2;
  TPVDInfoDisplayInit2 = record
    cbSize :UINT;
    hWnd :HWND;
    nCMYKparts :DWORD;
    pCMYKpalette :Pointer;
    nCMYKsize :DWORD;
    uCMYK2RGB :DWORD;
    nErrNumber :DWORD;
  end;

(*
struct pvdInfoDisplayAttach2
{
	UINT32 cbSize;               // [IN]  размер структуры в байтах
	HWND hWnd;                   // [IN]  Окно может быть изменено в процессе работы
	BOOL bAttach;                // [IN]  Подцепиться или отцепиться от hWnd
	DWORD nErrNumber;            // [OUT]
};
*)
type
  PPVDInfoDisplayAttach2 = ^TPVDInfoDisplayAttach2;
  TPVDInfoDisplayAttach2 = record
    cbSize :UINT;
    hWnd :HWND;
    bAttach :BOOL;
    nErrNumber :DWORD;
  end;

(*
struct pvdInfoDisplayCreate2
{
	UINT32 cbSize;               // [IN]  размер структуры в байтах
	pvdInfoDecode2* pImage;      // [IN]
	DWORD BackColor;             // [IN]  RGB background
	void* pDisplayContext;       // [OUT]
	DWORD nErrNumber;            // [OUT]
	const wchar_t* pFileName;    // [IN]  Information only. Valid only in pvdDisplayCreate2
	UINT32 iPage;                // [IN]  Information only
};
*)
type
  PPVDInfoDisplayCreate2 = ^TPVDInfoDisplayCreate2;
  TPVDInfoDisplayCreate2 = record
    cbSize :UINT;
    pImage :PPVDInfoDecode2;
    BackColor :DWORD;
    pDisplayContext :Pointer;
    nErrNumber :DWORD;
    pFileName :PWideChar;
    iPage :UINT;
  end;


const
  PVD_IDP_BEGIN     = 1;
  PVD_IDP_PAINT     = 2;
  PVD_IDP_COLORFILL = 3;
  PVD_IDP_COMMIT    = 4;

(*
struct pvdInfoDisplayPaint2
{
	UINT32 cbSize;               // [IN]  размер структуры в байтах
	DWORD Operation;  // PVD_IDP_*
	HWND hWnd;                   // [IN]  Где рисовать
	HWND hParentWnd;             // [IN]
	union {
	RGBQUAD BackColor;  //
	DWORD  nBackColor;  //
	};
	RECT ImageRect;
	RECT DisplayRect;

	LPVOID pDrawContext; // Это поле может использоваться субплагином для хранения "HDC". Освобождать должен субплагин по команде PVD_IDP_COMMIT

	//RECT ParentRect;
	////DWORD BackColor;             // [IN]  RGB background
	//BOOL bFreePosition;
	//BOOL bCorrectMousePos;
	//POINT ViewCenter;
	//POINT DragBase;
	//UINT32 Zoom;
	//RECT rcGlobal;               // [IN]  в каком месте окна нужно показать изображение (остальное заливается фоном BackColor)
	//RECT rcCrop;                 // [IN]  прямоугольник отсечения (клиентская часть окна)
	DWORD nErrNumber;            // [OUT]
	
	DWORD nZoom; // [IN] передается только для информации. 0x10000 == 100%
	DWORD nFlags; // [IN] PVD_IDPF_*
	
	DWORD *pChessMate;
	DWORD uChessMateWidth;
	DWORD uChessMateHeight;
};
*)
type
  PPVDInfoDisplayPaint2 = ^TPVDInfoDisplayPaint2;
  TPVDInfoDisplayPaint2 = record
    cbSize :UINT;
    Operation :DWORD;
    hWnd :HWND;
    hParentWnd :HWND;
    nBackColor :DWORD;
    ImageRect :TRECT;
    DisplayRect :TRECT;
    pDrawContext :Pointer;
    nErrNumber :DWORD;
    nZoom :DWORD;
    nFlags :DWORD;
    pChessMate :Pointer;
    uChessMateWidth :DWORD;
    uChessMateHeight :DWORD;
  end;

(*
typedef BOOL (__stdcall *pvdDecodeCallback2)(void *pDecodeCallbackContext2, UINT32 iStep, UINT32 nSteps,
											 pvdInfoDecodeStep2* pImagePart);
*)
type
  {!!!}
  TPVDDecodeCallback2 = pointer;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

end.

