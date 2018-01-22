unit API_MVC_DB;

interface

uses
  //API_Crypt,
  API_DB,
  API_MVC;

type
  TControllerDB = class abstract(TControllerAbstract)
  private
    //FCryptEngine: TCryptEngine;
    FDBEngine: TDBEngine;
    procedure ConnectToDB;
  protected
    FConnectOnCreate: Boolean;
    FConnectParams: TConnectParams;
    //FCryptEngineClass: TCryptEngineClass;
    //FCryptParams: TCryptParams;
    FDBEngineClass: TDBEngineClass;
    procedure AfterCreate; virtual;
    /// <summary>
    /// Override this procedure for assign FDBEngineClass and set FConnectParams.
    /// </summary>
    procedure InitDB(var aDBEngineClass: TDBEngineClass; out aConnectParams: TConnectParams;
      out aConnectOnCreate: Boolean); virtual; abstract;
  public
    constructor Create; override;
    destructor Destroy; override;
    //property CryptEngine: TCryptEngine read FCryptEngine;
    property DBEngine: TDBEngine read FDBEngine;
  end;

implementation

uses
  System.SysUtils;

procedure TControllerDB.AfterCreate;
begin
end;

destructor TControllerDB.Destroy;
begin
  FDBEngine.Free;
  //if Assigned(FCryptEngine) then FCryptEngine.Free;

  inherited;
end;

procedure TControllerDB.ConnectToDB;
begin
  FDBEngine.OpenConnection;
end;

constructor TControllerDB.Create;
begin
  inherited;

  try
    InitDB(FDBEngineClass, FConnectParams, FConnectOnCreate);
  except
    on e:EAbstractError do
      raise Exception.Create('Necessary procedure InitDB of Controller is absent!');
  else
      raise;
  end;

  if not Assigned(FDBEngineClass) then
    raise Exception.Create('FDBEngineClass isn`t assigned!');

  FDBEngine := FDBEngineClass.Create(FConnectParams);
  if FConnectOnCreate then ConnectToDB;

  //if Assigned(FCryptEngineClass) then
  //  FCryptEngine := FCryptEngineClass.Create(FCryptParams);

  AfterCreate;
end;

end.
