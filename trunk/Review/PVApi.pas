{$I Defines.inc}

unit PVApi;

// Интерфейс PVD плагинов-декодеров, v1.0 / v2.0
// v1.0: Кодировка всех символьных строк: UTF-8.

// Copyright (c) Skakov Pavel

// Copyright (c) Maximus5,
// http://code.google.com/p/conemu-maximus5

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
  PVD_IP_DECODE     = 1;         // Декодер (как версия 1)
  PVD_IP_TRANSFORM  = 2;         // Содержит функции для Lossless transform (интерфейс в разработке)
  PVD_IP_DISPLAY    = 4;         // Может быть использован вместо встроенной в PicView поддержки DX (интерфейс в разработке)
  PVD_IP_PROCESSING = 8;         // PostProcessing operations (интерфейс в разработке)

  PVD_IP_MULTITHREAD   = $100;   // Декодер может вызываться одновременно в разных нитях
  PVD_IP_ALLOWCACHE    = $200;   // PicView может длительное время НЕ вызывать pvdFileClose2 для кэширования декодированных изображений
  PVD_IP_CANREFINE     = $400;   // Декодер поддерживает улучшенный рендеринг (алиасинг)
  PVD_IP_CANREFINERECT = $800;   // Декодер поддерживает улучшенный рендеринг (алиасинг) заданного региона
  PVD_IP_CANREDUCE     = $1000;  // Декодер может загрузить большое изображение с уменьшенным масштабом
  PVD_IP_NOTERMINAL    = $2000;  // Этот модуль дисплея нельзя использовать в терминальных консолях
  PVD_IP_PRIVATE       = $4000;  // Имеет смысл только в сочетании (PVD_IP_DECODE|PVD_IP_DISPLAY).
                                 // Этот субплагин НЕ может быть использован как универсальный модуль вывода
                                 // он умеет отображать только то, что декодировал сам
  PVD_IP_DIRECT        = $8000;  // "Быстрый" модуль вывода. Например, вывод через DirectX.
  PVD_IP_FOLDER        = $10000; // Модуль может показывать Thumbnail для папок (a'la проводник Windows в режиме эскизов)
  PVD_IP_CANDESCALE    = $20000; // Поддерживается рендеринг в режиме уменьшения
  PVD_IP_CANUPSCALE    = $40000; // Поддерживается рендеринг в режиме увеличения

  // Review: Не требуется предварительная буферизация файла - плагин все читает сам
  PVD_IP_NEEDFILE    = $1000000;

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

  // Review: Видео файл. nPages содержит длительность файла в мс.
  PVD_IIF_MOVIE = $1000;


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


{pvdColorModel}
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

{pvdOrientation}
const
  PVD_Ornt_Default      = 0;
  PVD_Ornt_TopLeft      = 1; // The 0th row is at the visual top of the image, and the 0th column is the visual left-hand side.
  PVD_Ornt_TopRight     = 2; // The 0th row is at the visual top of the image, and the 0th column is the visual right-hand side.
  PVD_Ornt_BottomRight  = 3; // The 0th row is at the visual bottom of the image, and the 0th column is the visual right-hand side.
  PVD_Ornt_BottomLeft   = 4; // The 0th row is at the visual bottom of the image, and the 0th column is the visual left-hand side.
  PVD_Ornt_LeftTop      = 5; // The 0th row is the visual left-hand side of the image, and the 0th column is the visual top.
  PVD_Ornt_RightTop     = 6; // The 0th row is the visual right-hand side of the image, and the 0th column is the visual top.
  PVD_Ornt_RightBottom  = 7; // The 0th row is the visual right-hand side of the image, and the 0th column is the visual bottom.
  PVD_Ornt_LeftBottom   = 8; // The 0th row is the visual left-hand side of the image, and the 0th column is the visual bottom.


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

  BOOL (__stdcall* CallSehed)(pvdCallSehedProc2 CalledProc, LONG_PTR Param1, LONG_PTR Param2, LONG_PTR* Result);
  int (__stdcall* SortExtensions)(wchar_t* pszExtensions);
  int (__stdcall* MulDivI32)(int a, int b, int c);  // (__int64)a * b / c;
  UINT (__stdcall* MulDivU32)(UINT a, UINT b, UINT c);  // (uint)((unsigned long long)(a)*(b)/(c))
  UINT (__stdcall* MulDivU32R)(UINT a, UINT b, UINT c);  // (uint)(((unsigned long long)(a)*(b) + (c)/2)/(c))
  int (__stdcall* MulDivIU32R)(int a, UINT b, UINT c);  // (int)(((long long)(a)*(b) + (c)/2)/(c))
//PRAGMA_ERROR("Добавить функцию декодирования PNG. Чтобы облегчить вызов из ICO.PVD да и не использовать gdi+ при открытии CMYK");
  UINT32 Flags;                // [IN] возможные флаги: PVD_IPF_xxx
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

    CallSehed :Pointer;
    SortExtensions :Pointer;
    MulDivI32 :Pointer;
    MulDivU32 :Pointer;
    MulDivU32R :Pointer;
    MulDivIU32R :Pointer;

    Flags :UINT;
  end;


(*
// pvdInfoPlugin - информация о плагине
struct pvdInfoPlugin
{
  UINT32 Priority;          // приоритет плагина; если 0, то плагин не будет вызываться в процессе автораспознавания
  const char *pName;        // имя плагина
  const char *pVersion;     // версия плагина
  const char *pComments;    // комментарии о плагине: для чего предназначен, кто автор плагина, ...
};
*)
type
  PPVDInfoPlugin = ^TPVDInfoPlugin;
  TPVDInfoPlugin = record
    Priority :UINT;
    pName :PAnsiChar;
    pVersion :PAnsiChar;
    pComments :PAnsiChar;
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
struct pvdFormats2
{
  UINT32 cbSize;		 // [IN]  размер структуры в байтах
  const wchar_t *pActive;	 // [OUT] Список активных расширений через запятую.
				 //	  Это расширения, которые модуль умеет "хорошо" открывать.
				 //       Здесь допускается указание "*" означающее, что
				 //       субплагин является универсальным.
				 //       Если при распознавании ни один из субплагинов не подошел по расширению -
				 //       PicView все равно попытается открыть файл субплагином, если расширение
				 //       не указано в списке его запрещенных.
   const wchar_t *pForbidden;	 // [OUT] Список игнорируемых расширений через запятую.
				 //       Для файлов с указанными расширениями субплагин не
				 //       будет вызываться вообще. Укажите "." для игнорирования
				 //       файлов без расширений.
   const wchar_t *pInactive;	 // [OUT] Список неактивных расширений через запятую.
				 //       Здесь указываются расширения, которые модуль может открыть
				 //       "в принципе", но возможно, с проблемами.
   // !!! Списки являются "умолчанием". Пользователь может перенастроить список расширений.
};
*)
type
  PPVDFormats2 = ^TPVDFormats2;
  TPVDFormats2 = record
    cbSize :UINT;
    pSupported :PWideChar;
    pIgnored :PWideChar;
    pInactive :PWideChar;
  end;


(*
// pvdInfoImage - информация о файле
struct pvdInfoImage
{
  UINT32 nPages;            // количество страниц изображения
  UINT32 Flags;             // возможные флаги: PVD_IIF_ANIMATED
  const char *pFormatName;  // название формата файла
  const char *pCompression; // алгоритм сжатия
  const char *pComments;    // различные комментарии о файле
};
*)
type
  PPVDInfoImage = ^TPVDInfoImage;
  TPVDInfoImage = record
    nPages :UINT;
    Flags :UINT;
    pFormatName :PAnsiChar;
    pCompression :PAnsiChar;
    pComments :PAnsiChar;
  end;

(*
struct pvdInfoImage2
{
  UINT32 cbSize;               // [IN]  размер структуры в байтах
  void   *pImageContext;       // [IN]  При вызове из pvdFileOpen2 может быть НЕ NULL,
                               //       если плагин экспортирует функцию pvdFileDetect2
                               // [OUT] Контекст, используемый при обращении к файлу
  UINT32 nPages;               // [OUT] количество страниц изображения
                               //       При вызове из pvdFileDetect2 заполнение необязательно
  UINT32 Flags;                // [OUT] возможные флаги: PVD_IIF_xxx
                               //       При выозве из pvdFileDetect2 критичен флаг PVD_IIF_FILE_REQUIRED
  const wchar_t *pFormatName;  // [OUT] название формата файла
                               //       При вызове из pvdFileDetect2 заполнение необязательно, но желательно
  const wchar_t *pCompression; // [OUT] алгоритм сжатия
                               //       При вызове из pvdFileDetect2 заполнение необязательно
  const wchar_t *pComments;    // [OUT] различные комментарии о файле
                               //       При вызове из pvdFileDetect2 заполнение необязательно
  DWORD  nErrNumber;           // [OUT] Информация об ошибке детектирования формата файла
                               //       Субплагину желательно экспортировать функцию pvdTranslateError2
                               //       При возврате кода (< 0x7FFFFFFF) PicView считает что
                               //       субплагину просто неизвестен этот формат файла. PicView
                               //       не будет отображать эту ошибку пользователю, если сможет
                               //       открыть файл каким-то другим субплагином-декодером.
  DWORD nReserved, nReserver2;
};

// pvdFileOpen - открытие файла: субплагин решает, хочет ли он декодировать файл, и заполняет общую информацию о файле
//  Вызывается: при открытии файла
//  Аргументы:
//   pFileName   - имя открываемого файла
//   lFileSize   - длина открываемого файла в байтах. Если 0, то файл отсутствует, а переданный параметром pBuf буфер
//                 содержит все возможные данные и будет доступен вплоть до вызова pvdFileClose.
//   pBuf        - буфер, содержащий начало открываемого файла
//   lBuf        - длина буфера pBuf в байтах. Рекомендуется предоставлять не менее 16 Кб.
//   pImageInfo  - указатель на структуру с информацией о файле для заполнения субплагином, если он может декодировать файл
//   ppImageContext - указатель на контекст. Через этот параметр субплагин может вернуть контекст - произвольное значение,
//                 которое будет передаваться ему при вызове других функций работы с данным файлом. Следует иметь в
//                 виду, что одним экземпляром плагина в один момент времени может декодироваться несколько файлов,
//                 поэтому рекомендуется использовать контекст, а не внутренние глобальные переменные плагина.
//  Возвращаемое значение: TRUE - если субплагин может декодировать указанный файл; иначе - FALSE

BOOL __stdcall pvdFileOpen2(void *pContext, const wchar_t *pFileName, INT64 lFileSize, const BYTE *pBuf, UINT32 lBuf, pvdInfoImage2 *pImageInfo);
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
// pvdInfoPage - информация о странице изображения
struct pvdInfoPage
{
  UINT32 lWidth;            // ширина страницы
  UINT32 lHeight;           // высота страницы
  UINT32 nBPP;              // количество бит на пиксель (только информационное поле - в рассчётах не используется)
  UINT32 lFrameTime;        // для анимированных изображений - длительность отображения страницы в тысячных секунды;
                            // иначе - не используется
};
*)
type
  PPVDInfoPage = ^TPVDInfoPage;
  TPVDInfoPage = record
    lWidth :UINT;
    lHeight :UINT;
    nBPP :UINT;
    lFrameTime :UINT;
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


(*
// pvdInfoDecode - информация о декодированном изображении
struct pvdInfoDecode
{
  BYTE   *pImage;            // указатель на данные изображения в формате RGB
  UINT32 *pPalette;          // указатель на палитру изображения, используется в форматах 8 и меньше бит на пиксель
  UINT32 Flags;              // возможные флаги: PVD_IDF_READONLY
  UINT32 nBPP;               // количество бит на пиксель в декодированном изображении
  UINT32 nColorsUsed;        // количество используемых цветов в палитре; если 0, то используются все возможные цвета
  INT32  lImagePitch;        // модуль - длина строки декодированного изображения в байтах;
                             // положительные значения - строки идут сверху вниз, отрицательные - снизу вверх
};
*)
type
  PPVDInfoDecode = ^TPVDInfoDecode;
  TPVDInfoDecode = record
    pImage :Pointer;
    pPalette :Pointer;
    Flags :UINT;
    nBPP :UINT;
    nColorsUsed :UINT;
    lImagePitch :Integer;
  end;

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
  UINT32 lSrcWidth,          // [OUT] Декодер может уточнить размер исходного изображения. Именно этот размер
         lSrcHeight;         // [OUT] будет показан в заголовке окна (через TitleTemplate). Если уточнение не
                             //       не требуется - возвращайте {0,0}.
};

// pvdPageDecode - декодирование страницы изображения
//  Вызывается: между удачным pvdFileOpen и pvdFileClose
//  Аргументы:
//   pImageContext  - контекст, возвращённый субплагином в pvdFileOpen
//   iPage          - номер страницы изображения (нумерация начинается с 0)
//   pDecodeInfo    - указатель на структуру с информацией о декодированном изображении для заполнения субплагином
//   DecodeCallback - указатель на функцию, через которую субплагин может информировать вызывающую программу о ходе
//                    декодирования; NULL, если такая функция не предоставляется
//   pDecodeCallbackContext - контекст, передаваемый в DecodeCallback
//  Возвращаемое значение: TRUE - при успешном выполнении; иначе - FALSE
//  Дополнительные аргументы версии 2:
//   pContext      - контекст, возвращённый субплагином в pvdInit2
//   pImageContext - контекст, возвращаемый субплагином в pvdFileOpen2
BOOL __stdcall pvdPageDecode2(void *pContext, void *pImageContext, pvdInfoDecode2 *pDecodeInfo, 
							  pvdDecodeCallback2 DecodeCallback, void *pDecodeCallbackContext);
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
    lSrcWidth :UINT;
    lSrcHeight :UINT;
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
// pvdDecodeCallback - функция, указатель на которую передаётся в pvdPageDecode
//  Вызывается: плагином из pvdPageDecode
//   Не обязательно, но рекомендуется периодически вызывать, если декодирование может занять длительное время.
//  Аргументы:
//   pDecodeCallbackContext - контекст, переданный соответствующим параметром pvdPageDecode
//   iStep  - номер текущего шага декодирования (нумерация от 0 до nSteps - 1)
//   nSteps - общее количество шагов декодирования
//  Возвращаемое значение: TRUE - продолжение декодирования; FALSE - декодирование следует прервать
typedef BOOL (__stdcall *pvdDecodeCallback)(void *pDecodeCallbackContext, UINT32 iStep, UINT32 nSteps);
typedef BOOL (__stdcall *pvdDecodeCallback2)(void *pDecodeCallbackContext2, UINT32 iStep, UINT32 nSteps, pvdInfoDecodeStep2* pImagePart);
*)
type
  {!!!}
  TPVDDecodeCallback = pointer;
  TPVDDecodeCallback2 = pointer;


type
// pvdInit - инициализация плагина
//  Вызывается: один раз - сразу после загрузки плагина
//  Возвращаемое значение: версия интерфейса плагина
//   Если это число не понравится вызывающей программе, то вызовется pvdExit и плагин будет выгружен.
//   На время тестирования это -1. Затем будет 1. Рекомендуется использовать макроопределение PVD_CURRENT_INTERFACE_VERSION
//   0 - ошибка загрузки/инициализации плагина.

//UINT32 __stdcall pvdInit(void);
  TpvdInit = function() :integer; stdcall;

// pvdExit - завершение работы с плагином
//  Вызывается: один раз - непосредственно перед выгрузкой плагина

//void __stdcall pvdExit(void);
  TpvdExit = procedure(); stdcall;

// pvdPluginInfo - общая информация о плагине
//  Вызывается: когда угодно
//  Аргументы:
//   pPluginInfo - указатель на структуру с информацией о плагине для заполнения плагином

//void __stdcall pvdPluginInfo(pvdInfoPlugin *pPluginInfo);
  TpvdPluginInfo = procedure(pPluginInfo :PPVDInfoPlugin); stdcall;

// pvdFileOpen - открытие файла: плагин решает, хочет ли он декодировать файл, и заполняет общую информацию о файле
//  Вызывается: при открытии файла
//  Аргументы:
//   pFileName   - имя открываемого файла
//   lFileSize   - длина открываемого файла в байтах. Если 0, то файл отсутствует, а переданный параметром pBuf буфер
//                 содержит все возможные данные и будет доступен вплоть до вызова pvdFileClose.
//   pBuf        - буфер, содержащий начало открываемого файла
//   lBuf        - длина буфера pBuf в байтах. Рекомендуется предоставлять не менее 16 Кб.
//   pImageInfo  - указатель на структуру с информацией о файле для заполнения плагином, если он может декодировать файл
//   ppContext   - указатель на контекст. Через этот параметр плагин может вернуть контекст - произвольное значение,
//                 которое будет передаваться ему при вызове других функций работы с данным файлом. Следует иметь в
//                 виду, что одним экземпляром плагина в один момент времени может декодироваться несколько файлов,
//                 поэтому рекомендуется использовать контекст, а не внутренние глобальные переменные плагина.
//  Возвращаемое значение: TRUE - если плагин может декодировать указанный файл; иначе - FALSE

//BOOL __stdcall pvdFileOpen(const char *pFileName, INT64 lFileSize, const BYTE *pBuf, UINT32 lBuf, pvdInfoImage *pImageInfo, void **ppContext);
  TpvdFileOpen = function(pFileName :PAnsiChar; lFileSize :Int64; pBuf :Pointer; lBuf :UINT; pImageInfo :PPVDInfoImage; var pContext :Pointer) :BOOL; stdcall;

// pvdPageInfo - информация о странице изображения
//  Вызывается: между удачным pvdFileOpen и pvdFileClose
//  Аргументы:
//   pContext    - контекст, возвращённый плагином в pvdFileOpen
//   iPage       - номер страницы изображения (нумерация начинается с 0)
//   pPageInfo   - указатель на структуру с информацией о странице изображения для заполнения плагином
//  Возвращаемое значение: TRUE - при успешном выполнении; иначе - FALSE

//BOOL __stdcall pvdPageInfo(void *pContext, UINT32 iPage, pvdInfoPage *pPageInfo);
  TpvdPageInfo = function(pContext :Pointer; iPage :UINT; pPageInfo :PPVDInfoPage) :BOOL; stdcall;

// pvdPageDecode - декодирование страницы изображения
//  Вызывается: между удачным pvdFileOpen и pvdFileClose
//  Аргументы:
//   pContext       - контекст, возвращённый плагином в pvdFileOpen
//   iPage          - номер страницы изображения (нумерация начинается с 0)
//   pDecodeInfo    - указатель на структуру с информацией о декодированном изображении для заполнения плагином
//   DecodeCallback - указатель на функцию, через которую плагин может информировать вызывающую программу о ходе
//                    декодирования; NULL, если такая функция не предоставляется
//   pDecodeCallbackContext - контекст, передаваемый в DecodeCallback
//  Возвращаемое значение: TRUE - при успешном выполнении; иначе - FALSE

//BOOL __stdcall pvdPageDecode(void *pContext, UINT32 iPage, pvdInfoDecode *pDecodeInfo, pvdDecodeCallback DecodeCallback, void *pDecodeCallbackContext);
  TpvdPageDecode = function(pContext :Pointer; iPage :UINT; pDecodeInfo :PPVDInfoDecode; DecodeCallback :TPVDDecodeCallback; pDecodeCallbackContext :Pointer) :BOOL; stdcall;


// pvdPageFree - освобождение декодированного изображения
//  Вызывается: после удачного pvdPageDecode, когда декодированное изображение больше не нужно
//  Аргументы:
//   pContext    - контекст, возвращённый плагином в pvdFileOpen
//   pDecodeInfo - указатель на структуру с информацией о декодированном изображении, заполненной в pvdPageDecode

//void __stdcall pvdPageFree(void *pContext, pvdInfoDecode *pDecodeInfo);
  TpvdPageFree = procedure(pContext :Pointer; pDecodeInfo :PPVDInfoDecode); stdcall;


// pvdFileClose - закрытие файла
//  Вызывается: после удачного pvdFileOpen, когда файл больше не нужен
//  Аргументы:
//   pContext    - контекст, возвращённый плагином в pvdFileOpen

//void __stdcall pvdFileClose(void *pContext);
  TpvdFileClose = procedure(pContext :Pointer); stdcall;


type
  TpvdInit2 = function(pInit :PpvdInitPlugin2) :integer; stdcall;
  TpvdExit2 = procedure(pContext :Pointer); stdcall;
  TpvdPluginInfo2 = procedure(pPluginInfo :PPVDInfoPlugin2); stdcall;
  TpvdReloadConfig2 = procedure(pContext :Pointer); stdcall;

  TpvdGetFormats2 = procedure(pContext :Pointer; pFormats :PPVDFormats2); stdcall;
  TpvdFileOpen2 = function(pContext :Pointer; pFileName :PWideChar; lFileSize :Int64; pBuf :Pointer; lBuf :UINT; pImageInfo :PPVDInfoImage2) :BOOL; stdcall;
  TpvdPageInfo2 = function(pContext :Pointer; pImageContext :Pointer; pPageInfo :PPVDInfoPage2) :BOOL; stdcall;
  TpvdPageDecode2 = function(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2; DecodeCallback :TPVDDecodeCallback2; pDecodeCallbackContext :Pointer) :BOOL; stdcall;
  TpvdPageFree2 = procedure(pContext :Pointer; pImageContext :Pointer; pDecodeInfo :PPVDInfoDecode2); stdcall;
  TpvdFileClose2 = procedure(pContext :Pointer; pImageContext :Pointer); stdcall;

  TpvdDisplayInit2 = function(pContext :Pointer; pDisplayInit :PPVDInfoDisplayInit2) :BOOL; stdcall;
  TpvdDisplayAttach2 = function(pContext :Pointer; pDisplayAttach :PPVDInfoDisplayAttach2) :BOOL; stdcall;
  TpvdDisplayCreate2 = function(pContext :Pointer; pDisplayCreate :PPVDInfoDisplayCreate2) :BOOL; stdcall;
  TpvdDisplayPaint2 = function(pContext :Pointer; pDisplayContext :Pointer; pDisplayPaint :PPVDInfoDisplayPaint2) :BOOL; stdcall;
  TpvdDisplayClose2 = procedure(pContext :Pointer; pDisplayContext :Pointer); stdcall;
  TpvdDisplayExit2 = procedure(pContext :Pointer); stdcall;


{------------------------------------------------------------------------------}
{ PVD_IIF_MOVIE                                                                }

const
  PVD_PC_Play      = 1;
  PVD_PC_Pause     = 2;
  PVD_PC_Stop      = 3;
  PVD_PC_GetState  = 4;
  PVD_PC_GetPos    = 5;
  PVD_PC_SetPos    = 6;
  PVD_PC_GetVolume = 7;
  PVD_PC_SetVolume = 8;
  PVD_PC_Mute      = 9;

type
  TpvdPlayControl = function(pContext :Pointer; pImageContext :Pointer; aCmd :Integer; pInfo :Pointer) :Integer; stdcall;


{------------------------------------------------------------------------------}
{ Поддержка тэгов                                                              }


(*

Relative Path	Name	Type
/{ushort=256}	ImageWidth	VT_UI2 or VT_UI4
/{ushort=257}	ImageLength	VT_UI2 or VT_UI4
/{ushort=258}	BitsPerSample	VT_UI2
/{ushort=259}	Compression	VT_UI2
/{ushort=262}	PhotometricInterpretation	VT_UI2
/{ushort=274}	Orientation	VT_UI2
/{ushort=277}	SamplesPerPixel	VT_UI2
/{ushort=284}	PlanarConfiguration	VT_UI2
/{ushort=530}	YCbCrSubSampling	VT_VECTOR | VT_UI2
/{ushort=531}	YCbCrPositioning	VT_UI2
/{ushort=282}	XResolution	 VT_UI8
/{ushort=283}	YResolution	VT_UI8
/{ushort=296}	ResolutionUnit	VT_UI2

*** /{ushort=306}  DateTime         VT_LPSTR
*** /{ushort=270}  ImageDescription VT_LPSTR
*** /{ushort=271}  Make	            VT_LPSTR
*** /{ushort=272}  Model	    VT_LPSTR

*** /{ushort=305}  Software	    VT_LPSTR
*** /{ushort=315}  Artist	    VT_LPSTR
*** /{ushort=33432} Copyright	VT_LPSTR

/{ushort=338}	ExtraSamples	VT_UI2
/{ushort=254}	NewSubfileType	VT_UI4
/{ushort=278}	RowsPerStrip	VT_UI2 or VT_UI4
/{ushort=279}	StripByteCounts	VT_VECTOR | VT_UI2 or VT_VECTOR | VT_UI4
/{ushort=273}	StripOffsets	VT_VECTOR | VT_UI2 or VT_VECTOR | VT_UI4


/{ushort=36864}	ExifVersion	VT_BLOB
/{ushort=40960}	FlashpixVersion	VT_BLOB
/{ushort=40961}	ColorSpace	VT_UI2
/{ushort=40962}	PixelXDimension	VT_UI2 or VT_UI4
/{ushort=40963}	PixelYDimension	VT_UI2 or VT_UI4
/{ushort=37500}	MakerNote	VT_BLOB
/{ushort=37510}	UserComment	VT_LPWSTR
/{ushort=36867}	DateTimeOriginal	VT_LPSTR
/{ushort=36868}	DateTimeDigitized	VT_LPSTR
/{ushort=42016}	ImageUniqueID	VT_LPSTR
/{ushort=42032}	CameraOwnerName	VT_LPSTR
/{ushort=42033}	BodySerialNumber	VT_LPSTR
/{ushort=42034}	LensSpecification	VT_VECTOR | VT_UI8
/{ushort=42035}	LensMake	VT_LPSTR
/{ushort=42036}	LensModel	VT_LPSTR
/{ushort=42037}	LensSerialNumber	VT_LPSTR

/{ushort=33434}	ExposureTime	VT_UI8
/{ushort=33437}	FNumber	VT_UI8

/{ushort=34850}	ExposureProgram	VT_UI2
/{ushort=34852}	SpectralSensitivity	VT_LPSTR
/{ushort=34855}	PhotographicSensitivity	VT_VECTOR | VT_UI2
/{ushort=34856}	OECF	VT_BLOB
/{ushort=34864}	SensitivityType	VT_UI2
/{ushort=34865}	StandardOutputSensitivity	VT_UI4
/{ushort=34866}	RecommendedExposureIndex	VT_UI4
/{ushort=34867}	ISOSpeed	VT_UI4
/{ushort=34868}	ISOSpeedLatitudeyyy	VT_UI4
/{ushort=34869}	ISOSpeedLatitudezzz	VT_UI4
/{ushort=37377}	ShutterSpeedValue	VT_I8
/{ushort=37378}	ApertureValue	VT_UI8
/{ushort=37379}	BrightnessValue	VT_I8
/{ushort=37380}	ExposureBiasValue	VT_I8
/{ushort=37381}	MaxApertureValue	VT_UI8
/{ushort=37382}	SubjectDistance	VT_UI8
/{ushort=37383}	MeteringMode	VT_UI2
/{ushort=37384}	LightSource	VT_UI2
/{ushort=37385}	Flash	VT_UI2
/{ushort=37386}	FocalLength	VT_UI8
/{ushort=37396}	SubjectArea	VT_VECTOR | VT_UI2
/{ushort=41483}	FlashEnergy	VT_UI8
/{ushort=41484}	SpatialFrequencyResponse	VT_BLOB
/{ushort=41486}	FocalPlaneXResolution	VT_UI8
/{ushort=41487}	FocalPlaneYResolution	VT_UI8
/{ushort=41488}	FocalPlaneResolutionUnit	VT_UI2
/{ushort=41492}	SubjectLocation	VT_VECTOR | VT_UI2
/{ushort=41493}	ExposureIndex	VT_UI8
/{ushort=41495}	SensingMethod	VT_UI2
/{ushort=41728}	FileSource	VT_BLOB
/{ushort=41729}	SceneType	VT_BLOB
/{ushort=41730}	CFAPattern	VT_BLOB
/{ushort=41985}	CustomRendered	VT_UI2
/{ushort=41986}	ExposureMode	VT_UI2
/{ushort=41987}	WhiteBalance	VT_UI2
/{ushort=41988}	DigitalZoomRatio	VT_UI8
/{ushort=41989}	FocalLengthIn35mmFilm	VT_UI2
/{ushort=41990}	SceneCaptureType	VT_UI2
/{ushort=41991}	GainControl	VT_UI8
/{ushort=41992}	Contrast	VT_UI2
/{ushort=41993}	Saturation	VT_UI2
/{ushort=41994}	Sharpness	VT_UI2
/{ushort=41995}	DeviceSettingDescription	VT_BLOB
/{ushort=41996}	SubjectDistanceRange	VT_UI2

{ushort=0}	GPSVersionID	VT_VECTOR | VT_UI1
{ushort=1}	GPSLatitudeRef	VT_LPSTR
{ushort=2}	GPSLatitude	VT_VECTOR | VT_UI8
{ushort=3}	GPSLongitudeRef	VT_LPSTR
{ushort=4}	GPSLongitude	{ushort=4}	GPSLongitude	VT_VECTOR | VT_UI8
{ushort=5}	GPSAltitudeRef	VT_UI1
{ushort=6}	GPSAltitude	VT_UI8
{ushort=7}	GPSTimeStamp	VT_VECTOR | VT_UI8
{ushort=8}	GPSSatellites	VT_LPSTR
{ushort=9}	GPSStatus	VT_LPSTR
{ushort=10}	GPSMeasureMode	VT_LPSTR
{ushort=11}	GPSDOP	VT_UI8
{ushort=12}	GPSSpeedRef	VT_LPSTR
{ushort=13}	GPSSpeed	VT_UI8
{ushort=14}	GPSTrackRef	VT_LPSTR
{ushort=15}	GPSTrack	VT_UI8


rdf	http://www.w3.org/1999/02/22-rdf-syntax-ns#	http://www.w3.org/TR/REC-rdf-syntax/
dc	http://purl.org/dc/elements/1.1/	http://www.adobe.com/devnet/xmp.html
xmp	http://ns.adobe.com/xap/1.0/	http://www.adobe.com/devnet/xmp.html
xmpidq	http://ns.adobe.com/xmp/Identifier/qual/1.0/	http://www.adobe.com/devnet/xmp.html
xmpRights	http://ns.adobe.com/xap/1.0/rights/	http://www.adobe.com/devnet/xmp.html
xmpMM	http://ns.adobe.com/xap/1.0/mm/	http://www.adobe.com/devnet/xmp.html
xmpBJ	http://ns.adobe.com/xap/1.0/bj/	http://www.adobe.com/devnet/xmp.html
xmpTPg	http://ns.adobe.com/xap/1.0/t/pg/	http://www.adobe.com/devnet/xmp.html
pdf	http://ns.adobe.com/pdf/1.3/	http://www.adobe.com/devnet/xmp.html
photoshop	http://ns.adobe.com/photoshop/1.0/	http://www.adobe.com/devnet/xmp.html
tiff	http://ns.adobe.com/tiff/1.0/	http://www.adobe.com/devnet/xmp.html
exif	http://ns.adobe.com/exif/1.0/	http://www.adobe.com/devnet/xmp.html
stDim	http://ns.adobe.com/xap/1.0/sType/Dimensions#	http://www.adobe.com/devnet/xmp.html
xapGImg	http://ns.adobe.com/xap/1.0/g/img/	http://www.adobe.com/devnet/xmp.html
stEvt	http://ns.adobe.com/xap/1.0/sType/ResourceEvent#	http://www.adobe.com/devnet/xmp.html
stRef	http://ns.adobe.com/xap/1.0/sType/ResourceRef#	http://www.adobe.com/devnet/xmp.html
stVer	http://ns.adobe.com/xap/1.0/sType/Version#	http://www.adobe.com/devnet/xmp.html
stJob	http://ns.adobe.com/xap/1.0/sType/Job#	http://www.adobe.com/devnet/xmp.html
aux	http://ns.adobe.com/exif/1.0/aux/	http://www.adobe.com/devnet/xmp.html
crs	http://ns.adobe.com/camera-raw-settings/1.0/	http://www.adobe.com/devnet/xmp.html
xmpDM	http://ns.adobe.com/xmp/1.0/DynamicMedia/	http://www.adobe.com/devnet/xmp.html
Iptc4xmpCore	http://iptc.org/std/Iptc4xmpCore/1.0/xmlns/	http://www.iptc.org/cms/site/index.html?channel=CH0099
MicrosoftPhoto	http://ns.microsoft.com/photo/1.0/	People Tagging Overview
MP	http://ns.microsoft.com/photo/1.2/	People Tagging Overview
MPRI	http://ns.microsoft.com/photo/1.2/t/RegionInfo#	People Tagging Overview
MPReg	http://ns.microsoft.com/photo/1.2/t/Region#	People Tagging Overview
*)

const
  PVD_Tag_Description  = 101;  // Описание
  PVD_Tag_Time         = 102;  // Дата съемки
  PVD_Tag_EquipMake    = 103;  // Производитель камеры
  PVD_Tag_EquipModel   = 104;  // Модель камеры
  PVD_Tag_Software     = 105;  // Программа
  PVD_Tag_Author       = 106;  // Автор
  PVD_Tag_Copyright    = 107;  // Права

  PVD_Tag_Title        = 201;
  PVD_Tag_Artist       = 202;
  PVD_Tag_Album        = 203;
  PVD_Tag_Year         = 204;
  PVD_Tag_Genre        = 205;

  PVD_Tag_ExposureTime = 301;  // Выдержка
  PVD_Tag_FNumber      = 302;  // Диафрагма
  PVD_Tag_ISO          = 303;  // Светочувствительность (Photographic Sensitivity)
  PVD_Tag_FocalLength  = 304;  // Фокусное расстояние
  PVD_Tag_Flash        = 305;  // Вспышка

const
  PVD_TagCmd_Get   = 1;

const
  PVD_TagType_Int     = 1;
  PVD_TagType_Int64   = 2;
  PVD_TagType_Double  = 3;
  PVD_TagType_Str     = 4;

type
(*
  PPvdTagRec = ^TPvdTagRec;
  TPvdTagRec = record
    TagCode :UINT;
    TagName :PWideChar;
    TagType :Byte;
    case Integer of
      0: (IntValue :Integer);
      1: (NumVaule :Double);
      2: (StrVaule :PWideChar);
  end;

  PPvdTagArray = ^TPvdTagArray;
  TPvdTagArray = array[0..$7FFF] of TPvdTagRec;

  TpvdTagInfo = function(pContext :Pointer; pImageContext :Pointer; aCmd :Integer; var aTagCount :Integer; var aTags :PPvdTagArray) :Integer; stdcall;
*)
  TpvdTagInfo = function(pContext :Pointer; pImageContext :Pointer; aCmd, aCode :Integer; var aType :Integer; var aValue :Pointer) :BOOL; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


end.

