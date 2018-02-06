unit API_Yandex;

interface

uses
  API_HTTP;

type
  TTransDirection = (tdRuEn, tdRuUa);

  TYaTranslater = class
  private
    FHTTP: THTTP;
    FIDKey: string;
    function GetIDKey: string;
    function GetLangParam(aTransDirection: TTransDirection): string;
    function GetPartArr(aText: string): TArray<string>;
    function ProcessJSONResponse(aResponse: string): string;
  public
    function Translate(aTransDirection: TTransDirection; aText: string): string;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  API_Files,
  API_Strings,
  System.Classes,
  System.JSON,
  System.SysUtils;

function TYaTranslater.GetPartArr(aText: string): TArray<string>;
var
  i: Integer;
  Part: string;
  Sub: string;
  TextRest: string;
begin
  Result := [];
  TextRest := aText;

  while TextRest.Length > 0 do
    begin
      Part := TextRest.Substring(0, 10000);
      TextRest := TextRest.Substring(10000, TextRest.Length);

      if TextRest.Length > 0 then
        for i := Part.Length downto 1 do
          if (Part[i] = '.') or
             (Part[i] = #10) or
             (Part[i] = #13)
          then
            begin
              Sub := Part.Substring(i, Part.Length);
              Part := Part.Remove(i, Part.Length);
              TextRest := Sub + TextRest;

              Break;
            end;

      Result := Result + [Part];
    end;
end;

function TYaTranslater.GetLangParam(aTransDirection: TTransDirection): string;
begin
  Result := '';

  case aTransDirection of
    tdRuEn: Result := 'ru-en';
    tdRuUa: Result := 'ru-uk';
  end;
end;

function TYaTranslater.ProcessJSONResponse(aResponse: string): string;
var
  jsnResponse: TJSONObject;
  jsnValueArr: TJSONArray;
begin
  try
    jsnResponse := TJSONObject.ParseJSONValue(aResponse) as TJSONObject;
    jsnValueArr := jsnResponse.GetValue('text') as TJSONArray;

    Result := jsnValueArr.Items[0].Value;
  finally
    if Assigned(jsnResponse) then
      jsnResponse.Free;
  end;
end;

destructor TYaTranslater.Destroy;
begin
  FHTTP.Free;

  inherited;
end;

constructor TYaTranslater.Create;
begin
  FHTTP := THTTP.Create;
end;

function TYaTranslater.GetIDKey: string;
var
  NewSIDArr: TArray<string>;
  Page: TMyStr;
  SID: string;
  SIDItem: string;
  SIDArr: TArray<string>;
begin
  Page := FHTTP.Get('https://translate.yandex.by');

  SID := TStrTool.CutByKey(Page, 'SID: ''', '''');
  SIDArr := SID.Split(['.']);

  for SIDItem in SIDArr do
    NewSIDArr := NewSIDArr + [TStrTool.Reverse(SIDItem)];

  Result := Result.Join('.', NewSIDArr);
end;

function TYaTranslater.Translate(aTransDirection: TTransDirection; aText: string): string;
var
  i: Integer;
  LangParam: string;
  PartArr: TArray<string>;
  SL: TStringList;
  strJSONResponse: string;
  URL: string;
begin
  if FIDKey.IsEmpty then
    FIDKey := GetIDKey;

  LangParam := GetLangParam(aTransDirection);
  PartArr := GetPartArr(aText);

  URL := 'https://translate.yandex.net/api/v1/tr.json/translate?id=%s-0-0&srv=tr-touch&lang=%s&reason=auto';
  URL := Format(URL, [FIDKey, LangParam]);
  SL := TStringList.Create;
  try
    Result := '';

    for i := 0 to Length(PartArr) - 1 do
      begin
        SL.Clear;
        SL.Add('text=' + PartArr[i]);
        SL.Add('options=0');

        strJSONResponse := FHTTP.Post(URL, SL);
        if i > 0 then Result := Result + ' ';
        Result := Result + ProcessJSONResponse(strJSONResponse);
      end;
  finally
    SL.Free;
  end;
end;

end.
