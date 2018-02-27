unit mParserOnRequests;

interface

uses
  API_HTTP,
  eGroup,
  eIternalRequests,
  eLink,
  IdCookieManager,
  mParserCore;

type
  THandleRequestProc = procedure(const aPage: string; aIternalRequest: TIternalRequest; aGroup: TGroup) of object;

  TModelParserOnRequests = class abstract(TModelParser)
  private
    FCurrLink: TLink;
    procedure AfterLoad(aIdCookieManager: TIdCookieManager);
    procedure BeforeLoad(aIdCookieManager: TIdCookieManager);
  protected
    FHTTP: THTTP;
    function GetNextLinkSQL: string; override;
    procedure AfterCreate; override;
    procedure AfterPageLoad(aIdCookieManager: TIdCookieManager; aLink: TLink); virtual;
    procedure BeforeDestroy; override;
    procedure BeforePageLoad(aIdCookieManager: TIdCookieManager; aLink: TLink); virtual;
    procedure ProcessLink(aLink: TLink; out aBodyGroup: TGroup); override;
    procedure ProcessPageRoute(const aPage: string; aLink: TLink; var aBodyGroup: TGroup); virtual; abstract;
    procedure ProcessRequest(aIternalRequest: TIternalRequest; aGroup: TGroup; aHandleProc: THandleRequestProc);
  end;

implementation

function TModelParserOnRequests.GetNextLinkSQL: string;
begin

end;

procedure TModelParserOnRequests.ProcessRequest(aIternalRequest: TIternalRequest; aGroup: TGroup; aHandleProc: THandleRequestProc);
begin

end;

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
