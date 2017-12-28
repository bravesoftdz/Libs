unit API_MVC_DB;

interface

uses
  API_Crypt,
  API_MVC,
  API_DB;

type
  TControllerDB = class abstract(TControllerAbstract)
  private
    FCryptEngine: TCryptEngine;
    FDBEngine: TDBEngine;
    procedure ConnectToDB;
  protected
    FConnectOnCreate: Boolean;
    FConnectParams: TConnectParams;
    FCryptEngineClass: TCryptEngineClass;
    FCryptParams: TCryptParams;
    FDBEngineClass: TDBEngineClass;
    procedure Init; virtual; abstract;
  public
    constructor Create; override;
    destructor Destroy; override;
    property CryptEngine: TCryptEngine read FCryptEngine;
    property DBEngine: TDBEngine read FDBEngine;
  end;

implementation

destructor TControllerDB.Destroy;
begin
  FDBEngine.Free;
  if Assigned(FCryptEngine) then FCryptEngine.Free;

  inherited;
end;

procedure TControllerDB.ConnectToDB;
begin
  FDBEngine.OpenConnection;
end;

constructor TControllerDB.Create;
begin
  inherited;

  Init;

  FDBEngine := FDBEngineClass.Create(FConnectParams);
  if FConnectOnCreate then ConnectToDB;

  if Assigned(FCryptEngineClass) then
    FCryptEngine := FCryptEngineClass.Create(FCryptParams);
end;

end.
