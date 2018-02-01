unit API_MVC_DB;

interface

uses
  //API_Crypt,
  API_DB,
  API_MVC,
  System.Generics.Collections;

type
  TModelDB = class abstract(TModelAbstract)
  protected
    FDBEngine: TDBEngine;
  public
    constructor Create(aDataObj: TObjectDictionary<string, TObject>); override;
  end;

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
    procedure BeforeDestroy; virtual;
    procedure CallModel<T: TModelAbstract>(aThreadCount: Integer = 1);
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

procedure TControllerDB.CallModel<T>(aThreadCount: Integer = 1);
begin
  FDataObj.AddOrSetValue('DBEngine', FDBEngine);

  inherited CallModel<T>(aThreadCount);
end;

constructor TModelDB.Create(aDataObj: TObjectDictionary<string, TObject>);
begin
  inherited;

  FDBEngine := aDataObj.Items['DBEngine'] as TDBEngine;
end;

procedure TControllerDB.BeforeDestroy;
begin
end;

procedure TControllerDB.AfterCreate;
begin
end;

destructor TControllerDB.Destroy;
begin
  BeforeDestroy;

  if FDBEngine.IsConnected then
    FDBEngine.CloseConnection;
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
