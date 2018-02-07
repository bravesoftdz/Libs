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
    constructor Create(aDataObj: TObjectDictionary<string, TObject>; aTaskIndex: Integer = 0); override;
  end;

  TControllerDB = class abstract(TControllerAbstract)
  private
    //FCryptEngine: TCryptEngine;
    FDBEngine: TDBEngine;
    function CreateDBEngine: TDBEngine;
    procedure ConnectToDB(aDBEngine: TDBEngine);
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
    procedure ModelListener(const aMsg: string; aModel: TModelAbstract); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    //property CryptEngine: TCryptEngine read FCryptEngine;
    property DBEngine: TDBEngine read FDBEngine;
  end;

implementation

uses
  System.SysUtils;

procedure TControllerDB.ModelListener(const aMsg: string; aModel: TModelAbstract);
begin
  if (aMsg = aModel.EndMessage) and
     (aModel.InheritsFrom(TModelDB)) and
     (aModel.TaskIndex > 0)
  then
    TModelDB(aModel).FDBEngine.Free;

  inherited;
end;

function TControllerDB.CreateDBEngine: TDBEngine;
begin
  Result := FDBEngineClass.Create(FConnectParams);
  if FConnectOnCreate then
    ConnectToDB(Result);
end;

procedure TControllerDB.CallModel<T>(aThreadCount: Integer = 1);
var
  DBEngine: TDBEngine;
  DBEngineList: TObjectList<TDBEngine>;
  i: Integer;
begin
  DBEngineList := TObjectList<TDBEngine>.Create(False);
  try
    DBEngineList.Add(FDBEngine);

    for i := 2 to aThreadCount do
      begin
        DBEngine := CreateDBEngine;
        DBEngineList.Add(DBEngine);
      end;

    FDataObj.AddOrSetValue('DBEngineList', DBEngineList);
    inherited CallModel<T>(aThreadCount);
  finally
    DBEngineList.Free;
  end;
end;

constructor TModelDB.Create(aDataObj: TObjectDictionary<string, TObject>; aTaskIndex: Integer = 0);
var
  DBEngineList: TObjectList<TDBEngine>;
begin
  inherited;

  DBEngineList := aDataObj.Items['DBEngineList'] as TObjectList<TDBEngine>;
  FDBEngine := DBEngineList[aTaskIndex];
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

procedure TControllerDB.ConnectToDB(aDBEngine: TDBEngine);
begin
  aDBEngine.OpenConnection;
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

  FDBEngine := CreateDBEngine;

  //if Assigned(FCryptEngineClass) then
  //  FCryptEngine := FCryptEngineClass.Create(FCryptParams);

  AfterCreate;
end;

end.
