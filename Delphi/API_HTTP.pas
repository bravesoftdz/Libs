unit API_HTTP;

interface

uses
  IdCookieManager,
  IdHTTP,
  IdSSLOpenSSL,
  System.Classes;

type
  THTTP = class
  private
    FEnableCookies: Boolean;
    FIdCookieManager: TIdCookieManager;
    FIdHTTP: TIdHTTP;
    FIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    procedure FreeHTTP;
    procedure InitHTTP;
  public
    function Get(const aURL: string): string;
    function Post(const aURL: string; aPostData: TStringList): string;
    constructor Create(aEnabledCookies: Boolean = False);
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils;

function THTTP.Post(const aURL: string; aPostData: TStringList): string;
begin
  Result := FIdHTTP.Post(aURL, aPostData);
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
  Result := FIdHTTP.Get(aURL);
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
