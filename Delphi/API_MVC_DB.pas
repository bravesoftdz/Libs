unit API_MVC_DB;

interface

uses
  API_MVC,
  API_DB;

type
  TControllerDB = class abstract(TControllerAbstract)
  private
    procedure ConnectToDB;
  protected
    FConnectOnCreate: Boolean;
    FConnectParams: TConnectParams;
    FDBEngine: TDBEngine;
    FDBEngineClass: TDBEngineClass;
    procedure InitDB; virtual; abstract;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

implementation

destructor TControllerDB.Destroy;
begin
  FDBEngine.Free;

  inherited;
end;

procedure TControllerDB.ConnectToDB;
begin
  FDBEngine.ConnectParams := FConnectParams;
  FDBEngine.OpenConnection;
end;

constructor TControllerDB.Create;
begin
  inherited;

  InitDB;
  FDBEngine := FDBEngineClass.Create;
  if FConnectOnCreate then ConnectToDB;
end;

end.
