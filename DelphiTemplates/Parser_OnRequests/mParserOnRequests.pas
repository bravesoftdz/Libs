unit mParserOnRequests;

interface

uses
  API_HTTP,
  eGroup,
  eLink,
  IdCookieManager,
  mParserCore;

type
  TModelParserOnRequests = class abstract(TModelParser)
  private
    FCurrLink: TLink;
    procedure AfterLoad(aIdCookieManager: TIdCookieManager);
    procedure BeforeLoad(aIdCookieManager: TIdCookieManager);
  protected
    FHTTP: THTTP;
    procedure AfterCreate; override;
    procedure AfterPageLoad(aIdCookieManager: TIdCookieManager; aLink: TLink); virtual;
    procedure BeforeDestroy; override;
    procedure BeforePageLoad(aIdCookieManager: TIdCookieManager; aLink: TLink); virtual;
    procedure ProcessLink(aLink: TLink; out aBodyGroup: TGroup); override;
    procedure ProcessPageRoute(const aPage: string; aLink: TLink; var aBodyGroup: TGroup); virtual; abstract;
  end;

implementation

procedure TModelParserOnRequests.BeforePageLoad(aIdCookieManager: TIdCookieManager; aLink: TLink);
begin
end;

procedure TModelParserOnRequests.BeforeLoad(aIdCookieManager: TIdCookieManager);
begin
  BeforePageLoad(aIdCookieManager, FCurrLink);
end;

procedure TModelParserOnRequests.AfterPageLoad(aIdCookieManager: TIdCookieManager; aLink: TLink);
begin
end;

procedure TModelParserOnRequests.AfterLoad(aIdCookieManager: TIdCookieManager);
begin
  AfterPageLoad(aIdCookieManager, FCurrLink);
end;

procedure TModelParserOnRequests.BeforeDestroy;
begin
  FHTTP.Free;
end;

procedure TModelParserOnRequests.AfterCreate;
begin
  FHTTP := THTTP.Create(True);
  FHTTP.OnBeforeLoad := BeforeLoad;
  FHTTP.OnAfterLoad := AfterLoad;
end;

procedure TModelParserOnRequests.ProcessLink(aLink: TLink; out aBodyGroup: TGroup);
var
  Page: string;
begin
  inherited;

  FCurrLink := aLink;
  Page := FHTTP.Get(aLink.URL);

  ProcessPageRoute(Page, aLink, aBodyGroup);
end;

end.
