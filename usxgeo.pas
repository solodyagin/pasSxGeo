unit usxgeo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, Math;

const
  //SXGEO_FILE = 0;
  //SXGEO_MEMORY = 1;
  //SXGEO_BATCH = 2;

  SXGEO_ID2ISO: array[0..254] of String = (
    '', 'AP', 'EU', 'AD', 'AE', 'AF', 'AG', 'AI', 'AL', 'AM', 'CW', 'AO', 'AQ', 'AR', 'AS', 'AT', 'AU', 'AW', 'AZ', 'BA',
    'BB', 'BD', 'BE', 'BF', 'BG', 'BH', 'BI', 'BJ', 'BM', 'BN', 'BO', 'BR', 'BS', 'BT', 'BV', 'BW', 'BY', 'BZ', 'CA', 'CC',
    'CD', 'CF', 'CG', 'CH', 'CI', 'CK', 'CL', 'CM', 'CN', 'CO', 'CR', 'CU', 'CV', 'CX', 'CY', 'CZ', 'DE', 'DJ', 'DK', 'DM',
    'DO', 'DZ', 'EC', 'EE', 'EG', 'EH', 'ER', 'ES', 'ET', 'FI', 'FJ', 'FK', 'FM', 'FO', 'FR', 'SX', 'GA', 'GB', 'GD', 'GE',
    'GF', 'GH', 'GI', 'GL', 'GM', 'GN', 'GP', 'GQ', 'GR', 'GS', 'GT', 'GU', 'GW', 'GY', 'HK', 'HM', 'HN', 'HR', 'HT', 'HU',
    'ID', 'IE', 'IL', 'IN', 'IO', 'IQ', 'IR', 'IS', 'IT', 'JM', 'JO', 'JP', 'KE', 'KG', 'KH', 'KI', 'KM', 'KN', 'KP', 'KR',
    'KW', 'KY', 'KZ', 'LA', 'LB', 'LC', 'LI', 'LK', 'LR', 'LS', 'LT', 'LU', 'LV', 'LY', 'MA', 'MC', 'MD', 'MG', 'MH', 'MK',
    'ML', 'MM', 'MN', 'MO', 'MP', 'MQ', 'MR', 'MS', 'MT', 'MU', 'MV', 'MW', 'MX', 'MY', 'MZ', 'NA', 'NC', 'NE', 'NF', 'NG',
    'NI', 'NL', 'NO', 'NP', 'NR', 'NU', 'NZ', 'OM', 'PA', 'PE', 'PF', 'PG', 'PH', 'PK', 'PL', 'PM', 'PN', 'PR', 'PS', 'PT',
    'PW', 'PY', 'QA', 'RE', 'RO', 'RU', 'RW', 'SA', 'SB', 'SC', 'SD', 'SE', 'SG', 'SH', 'SI', 'SJ', 'SK', 'SL', 'SM', 'SN',
    'SO', 'SR', 'ST', 'SV', 'SY', 'SZ', 'TC', 'TD', 'TF', 'TG', 'TH', 'TJ', 'TK', 'TM', 'TN', 'TO', 'TL', 'TR', 'TT', 'TV',
    'TW', 'TZ', 'UA', 'UG', 'UM', 'US', 'UY', 'UZ', 'VA', 'VC', 'VE', 'VG', 'VI', 'VN', 'VU', 'WF', 'WS', 'YE', 'YT', 'RS',
    'ZA', 'ZM', 'ME', 'ZW', 'A1', 'XK', 'O1', 'AX', 'GG', 'IM', 'JE', 'BL', 'MF', 'BQ', 'SS'
    );

  SXGEO_TYPES: array[0..7] of String = ('n/a', 'SxGeo Country', 'SxGeo City RU', 'SxGeo City EN', 'SxGeo City', 'SxGeo City Max RU',
    'SxGeo City Max EN', 'SxGeo City Max');

  SXGEO_CHARSET: array[0..2] of String = ('utf-8', 'latin1', 'cp1251');

type
  TSxGeoSignature = array[0..2] of Byte;

const
  SXGEO_SIGNATURE: TSxGeoSignature = ($53, $78, $47);

type
  TIPv4 = packed record
    case Integer of
      0: (D, C, B, A: Byte);
      1: (Value: LongWord);
  end;

  TSxGeoHeader = packed record
    Signature: TSxGeoSignature; // Идентификатор файла, "SxG"
    Ver: Byte;                  // Версия файла (21 => 2.1)
    Time: LongWord;             // Время создания (Unix timestamp)
    Kind: Byte;                 // Тип (0-Universal, 1-SxGeo Country, 2-SxGeo City, 11-GeoIP Country, 12-GeoIP City, 21-ipgeobase)
    Charset: Byte;              // Кодировка (0-UTF-8, 1-latin1, 2-cp1251)
    BIdxLen: Byte;              // Элементов в индексе первых байт (до 255)
    MIdxLen: Word;              // Элементов в основном индексе (до 65 тыс.)
    Range: Word;                // Блоков в одном элементе индекса (до 65 тыс.)
    Items: LongWord;            // Количество диапазонов (до 4 млрд.)
    IdLen: Byte;                // Размер ID-блока в байтах (1 для стран, 3 для городов)
    MaxRegion: Word;            // Максимальный размер записи региона (до 64 КБ)
    MaxCity: Word;              // Максимальный размер записи города (до 64 КБ)
    RegionSize: LongWord;       // Размер справочника регионов
    CitySize: LongWord;         // Размер справочника городов
    MaxCountry: Word;           // Максимальный размер записи страны (до 64 КБ)
    CountrySize: LongWord;      // Размер справочника стран
    PackSize: Word;             // Размер описания формата упаковки города/региона/страны
  end;

  TSxGeo = class;
  TOnSxGeoEvent = procedure(Sender: TSxGeo) of object;
  TOnSxGeoError = procedure(Sender: TSxGeo; ErrMsg: String) of object;

  TSxGeo = class
  private
    fHeader: TSxGeoHeader;
    //fBatchMode: Boolean;
    //fMemoryMode: Boolean;
    fDb: TMemoryStream;
    fRegionsDb: TMemoryStream;
    fCitiesDb: TMemoryStream;
    fBlockLen: Word;
    fBIdxArr: array of LongWord;
    fMIdxArr: array of LongWord;
    fOnOpen: TOnSxGeoEvent;
    fOnClose: TOnSxGeoEvent;
    fOnError: TOnSxGeoError;
    fPack: String;
    fIsOpened: Boolean;
    fDbBegin: LongWord;
    fRegionsBegin: LongWord;
    fCitiesBegin: LongWord;
    function SearchIdx(ipn, min, max: LongWord): LongWord;
    function SearchDb(ipn, min, max: LongWord): LongWord;
    function GetNum(ip: String): Byte;
  public
    function GetCountry(ip: String): String;
  public
    constructor Create;
    destructor Destroy; override;
    function Open(AFileName: String{; AMode: Byte = SXGEO_FILE}): Boolean;
    procedure Close;
  published
    property Ver: Byte read fHeader.Ver;
    property Time: LongWord read fHeader.Time;
    property Kind: Byte read fHeader.Kind;
    property Charset: Byte read fHeader.Charset;
    property BIdxLen: Byte read fHeader.BIdxLen;
    property MIdxLen: Word read fHeader.MIdxLen;
    property Range: Word read fHeader.Range;
    property Items: LongWord read fHeader.Items;
    property IdLen: Byte read fHeader.IdLen;
    property MaxRegion: Word read fHeader.MaxRegion;
    property MaxCity: Word read fHeader.MaxCity;
    property RegionSize: LongWord read fHeader.RegionSize;
    property CitySize: LongWord read fHeader.CitySize;
    property MaxCountry: Word read fHeader.MaxCountry;
    property CountrySize: LongWord read fHeader.CountrySize;
    property PackSize: Word read fHeader.PackSize;
    property Pack: String read fPack;
    property BlockLen: Word read fBlockLen;
    property IsOpened: Boolean read fIsOpened;
    property OnOpen: TOnSxGeoEvent read fOnOpen write fOnOpen;
    property OnClose: TOnSxGeoEvent read fOnClose write fOnClose;
    property OnError: TOnSxGeoError read fOnError write fOnError;
  end;

  function StrToIPv4(IP: String): TIPv4;
  function IPv4ToStr(IP: TIPv4): String;

implementation

{ TSxGeo }

constructor TSxGeo.Create;
begin
  inherited Create;
  fDb := TMemoryStream.Create;
  fRegionsDb := TMemoryStream.Create;
  fCitiesDb := TMemoryStream.Create;
end;

destructor TSxGeo.Destroy;
begin
  Close;
  fDb.Free;
  fRegionsDb.Free;
  fCitiesDb.Free;
  inherited Destroy;
end;

function TSxGeo.Open(AFileName: String{; AMode: Byte = SXGEO_FILE}): Boolean;
var
  fs: TFileStream;
  rd: Integer;
  tmp: PChar;
  i: Integer;
begin
  Result := False;

  if fIsOpened then
    Close;

  //fBatchMode := Boolean(AMode and SXGEO_BATCH);
  //fMemoryMode := Boolean(AMode and SXGEO_MEMORY);

  fs := TFileStream.Create(AFileName, fmOpenRead);
  try
    try
      fs.Seek(0, soBeginning);

      rd := fs.Read(fHeader, SizeOf(TSxGeoHeader));
      if rd <> SizeOf(TSxGeoHeader) then
        raise Exception.Create('Файл БД повреждён');

      if not CompareMem(@fHeader.Signature, @SXGEO_SIGNATURE, SizeOf(TSxGeoSignature)) then
        raise Exception.Create('Файл не распознан');

      if (fHeader.Ver <> 22) or (fHeader.Kind <> 1) then
        raise Exception.Create('Не поддерживаемый формат БД');

      fHeader.Time := SwapEndian(fHeader.Time);
      fHeader.MIdxLen := SwapEndian(fHeader.MIdxLen);
      fHeader.Range := SwapEndian(fHeader.Range);
      fHeader.Items := SwapEndian(fHeader.Items);
      fHeader.MaxRegion := SwapEndian(fHeader.MaxRegion);
      fHeader.MaxCity := SwapEndian(fHeader.MaxCity);
      fHeader.RegionSize := SwapEndian(fHeader.RegionSize);
      fHeader.CitySize := SwapEndian(fHeader.CitySize);
      fHeader.MaxCountry := SwapEndian(fHeader.MaxCountry);
      fHeader.CountrySize := SwapEndian(fHeader.CountrySize);
      fHeader.PackSize := SwapEndian(fHeader.PackSize);

      if (PackSize > 0) then
      begin
        tmp := StrAlloc(PackSize);
        fs.Read(tmp^, PackSize);
        fPack := StrPas(tmp);
        StrDispose(tmp);
      end;

      fBlockLen := 3 + IdLen;

      SetLength(fBIdxArr, BIdxLen);
      fs.Read(fBIdxArr[0], BIdxLen * 4{SizeOf(LongWord)});
      for i := 0 to Length(fBIdxArr) - 1 do
        fBIdxArr[i] := SwapEndian(fBIdxArr[i]);

      SetLength(fMIdxArr, MIdxLen);
      fs.Read(fMIdxArr[0], MIdxLen * 4{SizeOf(LongWord)});
      for i := 0 to Length(fMIdxArr) - 1 do
        fMIdxArr[i] := SwapEndian(fMIdxArr[i]);

      fDbBegin := fs.Position;

      fDb.CopyFrom(fs, Items * fBlockLen);
      if RegionSize > 0 then
        fRegionsDb.CopyFrom(fs, RegionSize);
      if CitySize > 0 then
        fCitiesDb.CopyFrom(fs, CitySize);

      fRegionsBegin := fDbBegin + Items * fBlockLen;
      fCitiesBegin := fRegionsBegin + RegionSize;

      fIsOpened := True;

      Result := True;
    except
      on E: Exception do
      begin
        if Assigned(fOnError) then
          fOnError(Self, E.Message);
      end;
    end;
  finally
    fs.Free;
  end;
  if Result and Assigned(fOnOpen) then
    fOnOpen(Self);
end;

procedure TSxGeo.Close;
begin
  FillByte(fHeader, SizeOf(TSxGeoHeader), 0);
  SetLength(fBIdxArr, 0);
  SetLength(fMIdxArr, 0);
  fDb.Clear;
  fRegionsDb.Clear;
  fCitiesDb.Clear;
  fIsOpened := False;
  if Assigned(fOnClose) then
    fOnClose(Self);
end;

function TSxGeo.SearchIdx(ipn, min, max: LongWord): LongWord;
var
  offset: LongWord;
begin
  while max - min > 8 do
  begin
    offset := (min + max) shr 1;
    if ipn > fMIdxArr[offset] then min := offset
    else
      max := offset;
  end;
  while (ipn > fMIdxArr[min]) and (min <= max) do
    min := min + 1;
  Result := min;
end;

function TSxGeo.SearchDb(ipn, min, max: LongWord): LongWord;
var
  offset: LongWord;
  tmp: array[0..2] of Byte;
  ipv4: TIPv4;
  res: LongWord;
begin
  if max - min > 1 then
  begin
    ipv4.Value := ipn;
    ipv4.A := 0;
    ipn := ipv4.Value;

    while max - min > 8 do
    begin
      offset := (min + max) shr 1;
      fDb.Position := offset * fBlockLen;
      fDb.Read(tmp, 3);
      ipv4.A := 0;
      ipv4.B := tmp[0];
      ipv4.C := tmp[1];
      ipv4.D := tmp[2];
      if (ipn > ipv4.Value) then
        min := offset
      else
        max := offset;
    end;

    fDb.Position := min * fBlockLen;
    fDb.Read(tmp, 3);
    ipv4.A := 0;
    ipv4.B := tmp[0];
    ipv4.C := tmp[1];
    ipv4.D := tmp[2];

    while (ipn >= ipv4.Value) and (min < max) do
    begin
      min := min + 1;
      fDb.Position := min * fBlockLen;
      fDb.Read(tmp, 3);
      ipv4.A := 0;
      ipv4.B := tmp[0];
      ipv4.C := tmp[1];
      ipv4.D := tmp[2];
    end;
  end
  else
    min := min + 1;

  fDb.Position := min * fBlockLen - IdLen;
  fDb.Read(res, IdLen);
  //if IdLen > 1 then
  //  res := SwapEndian(res);
  Result := res;
end;

function TSxGeo.GetNum(ip: String): Byte;
var
  ipln: TIPv4;
  ipn: LongWord;
  blocks_min: LongWord;
  blocks_max: LongWord;
  part: LongWord;
  min: LongWord;
  max: LongWord;
begin
  ipln := StrToIPv4(ip);
  if (ipln.A = 0) or (ipln.A = 10) or (ipln.A = 127) or (ipln.A >= BIdxLen) then Exit;
  ipn := ipln.Value;
  // Находим блок данных в индексе первых байт
  blocks_min := fBIdxArr[ipln.A - 1];
  blocks_max := fBIdxArr[ipln.A];
  if blocks_max - blocks_min > Range then
  begin
    // Ищем блок в основном индексе
    part := SearchIdx(ipn, Math.Floor(blocks_min / Range), Math.Floor(blocks_max / Range) - 1);
    // Нашли номер блока в котором нужно искать IP, теперь находим нужный блок в БД
    if part > 0 then
      min := part * Range
    else
      min := 0;
    if part > MIdxLen then
      max := Items
    else
      max := (part + 1) * Range;
    // Нужно проверить чтобы блок не выходил за пределы блока первого байта
    if min < blocks_min then min := blocks_min;
    if max > blocks_max then max := blocks_max;
  end
  else
  begin
    min := blocks_min;
    max := blocks_max;
  end;
  // Находим нужный диапазон в БД
  Result := SearchDb(ipn, min, max);
end;

function TSxGeo.GetCountry(ip: String): String;
begin
  if not fIsOpened then Exit;
  Result := SXGEO_ID2ISO[GetNum(ip)];
end;

function StrToIPv4(IP: String): TIPv4;
begin
  Result.A := StrToIntDef(Copy2SymbDel(IP, '.'), 0);
  Result.B := StrToIntDef(Copy2SymbDel(IP, '.'), 0);
  Result.C := StrToIntDef(Copy2SymbDel(IP, '.'), 0);
  Result.D := StrToIntDef(Copy2SymbDel(IP, '.'), 0);
end;

function IPv4ToStr(IP: TIPv4): String;
begin
  with IP do
    Result := Format('%d.%d.%d.%d', [A, B, C, D]);
end;

end.
