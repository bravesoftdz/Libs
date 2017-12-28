unit API_DB;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.DApt,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def;

type
  TConnectParams = record
    CharacterSet: string;
    DataBase: string;
    Host: string;
    Login: string;
    Password: string;
  end;

  TDBEngine = class abstract
  private
    FIsConnected: Boolean;
  protected
    FDConnection: TFDConnection;
    FConnectParams: TConnectParams;
    procedure SetConnectParams; virtual;
  public
    function GetLastInsertedID: Integer; virtual; abstract;
    procedure CloseConnection;
    procedure ExecQuery(aQuery: TFDQuery); virtual;
    procedure OpenConnection;
    procedure OpenQuery(aQuery: TFDQuery; aIsFetchAll: Boolean = True);
    constructor Create(aConnectParams: TConnectParams);
    destructor Destroy; override;
  end;

  TDBEngineClass = class of TDBEngine;

implementation

constructor TDBEngine.Create(aConnectParams: TConnectParams);
begin
  FConnectParams := aConnectParams;
end;

procedure TDBEngine.ExecQuery(aQuery: TFDQuery);
begin
  aQuery.Connection := FDConnection;
  aQuery.ExecSQL;
end;

procedure TDBEngine.OpenQuery(aQuery: TFDQuery; aIsFetchAll: Boolean = True);
begin
  aQuery.Connection := FDConnection;
  aQuery.Open;
  if aIsFetchAll then aQuery.FetchAll;
end;

procedure TDBEngine.SetConnectParams;
begin
  FDConnection.Params.Values['Server'] := FConnectParams.Host;
  FDConnection.Params.Values['Database'] := FConnectParams.DataBase;
  FDConnection.Params.Values['User_Name'] := FConnectParams.Login;
  FDConnection.Params.Values['Password'] := FConnectParams.Password;
  FDConnection.Params.Values['CharacterSet'] := FConnectParams.CharacterSet;
end;

procedure TDBEngine.CloseConnection;
begin
  FDConnection.Connected := False;
  FDConnection.Free;
  FIsConnected := False;
end;

destructor TDBEngine.Destroy;
begin
  if FIsConnected then
    CloseConnection;

  inherited;
end;

procedure TDBEngine.OpenConnection;
begin
  FDConnection := TFDConnection.Create(nil);
  SetConnectParams;

  FDConnection.LoginPrompt := False;
  FDConnection.ResourceOptions.SilentMode := True;
  FDConnection.Connected := True;

  FIsConnected := True;
end;

end.
