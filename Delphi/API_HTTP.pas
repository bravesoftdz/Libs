unit API_HTTP;

interface

uses
  IdCookieManager,
  IdHTTP,
  IdSSLOpenSSL,
  System.Classes;

type
  THTTPEvent = procedure(aIdCookieManager: TIdCookieManager) of object;

  THTTP = class
  private
    FEnableCookies: Boolean;
    FIdCookieManager: TIdCookieManager;
    FIdHTTP: TIdHTTP;
    FIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    FOnAfterLoad: THTTPEvent;
    FOnBeforeLoad: THTTPEvent;
    FURL: string;
    function GetPage(const aURL: string; aPostData: TStringList): string;
    procedure FreeHTTP;
    procedure InitHTTP;
  public
    function Get(const aURL: string): string;
    function Post(const aURL: string; aPostData: TStringList): string;
    procedure SetHeaders(aHeadersStr: string);
    constructor Create(aEnabledCookies: Boolean = False);
    destructor Destroy; override;
    property OnAfterLoad: THTTPEvent read FOnAfterLoad write FOnAfterLoad;
    property OnBeforeLoad: THTTPEvent read FOnBeforeLoad write FOnBeforeLoad;
    property URL: string read FURL;
  end;

implementation

uses
  API_Strings,
  System.SysUtils;

function THTTP.GetPage(const aURL: string; aPostData: TStringList): string;
begin
  if Assigned(FOnBeforeLoad) then
    FOnBeforeLoad(FIdHTTP.CookieManager);

  if Assigned(aPostData) then
    Result := FIdHTTP.Post(aURL, aPostData)
  else
    Result := FIdHTTP.Get(aURL);

  FURL := FIdHTTP.URL.URI;

  if Assigned(FOnAfterLoad) then
    FOnAfterLoad(FIdHTTP.CookieManager);
end;

procedure THTTP.SetHeaders(aHeadersStr: string);
var
  Header: string;
  HeadersArr: TArray<string>;
  Name: string;
  Value: string;
begin
  FIdHTTP.Request.CustomHeaders.Clear;
  HeadersArr := aHeadersStr.Split([';']);

  for Header in HeadersArr do
    begin
      Name := TStrTool.ExtractKey(Header);
      Value := TStrTool.ExtractValue(Header);
      FIdHTTP.Request.CustomHeaders.AddValue(Name, Value);
    end;

end;

function THTTP.Post(const aURL: string; aPostData: TStringList): string;
begin
  Result := GetPage(aURL, aPostData);
end;

procedure THTTP.FreeHTTP;
begin
  if Assigned(FIdHTTP) then
    FreeAndNil(FIdHTTP);

  if Assigned(FIdSSLIOHandlerSocketOpenSSL) then
    FreeAndNil(FIdSSLIOHandlerSocketOpenSSL);

  if Assigned(FIdCookieManager) then
    FreeAndNil(FIdCookieManager);
end;

function THTTP.Get(const aURL: string): string;
begin
  Result := GetPage(aURL, nil);
end;

destructor THTTP.Destroy;
begin
  FreeHTTP;

  inherited;
end;

procedure THTTP.InitHTTP;
begin
  FreeHTTP;

  FIdHTTP := TIdHTTP.Create;
  FIdHTTP.HandleRedirects:=True;
  FIdHTTP.Request.UserAgent:='Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36';

  FIdSSLIOHandlerSocketOpenSSL:=TIdSSLIOHandlerSocketOpenSSL.Create;
  FIdHTTP.IOHandler:=FIdSSLIOHandlerSocketOpenSSL;

  if FEnableCookies then
    begin
      FIdCookieManager := TIdCookieManager.Create(nil);
      FIdHTTP.CookieManager := FIdCookieManager;
    end;
end;

constructor THTTP.Create(aEnabledCookies: Boolean = False);
begin
  FEnableCookies := aEnabledCookies;
  InitHTTP;
end;

end.
