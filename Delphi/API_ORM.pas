unit API_ORM;

interface

uses
  API_DB,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  System.Generics.Collections;

type
  TKeyField = record
    FieldName: string;
    FieldType: TFieldType;
  end;

  TSructure = record
    ForeignKeyArr: TArray<TKeyField>;
    PrimaryKeyArr: TArray<TKeyField>;
    TableName: string;
  end;

  TInstance = record
    FieldName: string;
    FieldType: TFieldType;
    Value: Variant;
  end;

  TORMEngine = class
  public
    class function GetInstanceArr(aQuery: TFDQuery): TArray<TInstance>;
  end;

{$M+}
  TEntityAbstract = class abstract
  private
    FDBEngine: TDBEngine;
    FInstanceArr: TArray<TInstance>;
    FIsNewInstance: Boolean;
    function GetPrimKeyFieldType(aFieldName: string): TFieldType;
    function GetPropNameByFieldName(aFieldName: string): string;
    function GetSelectSQLString: string; virtual;
    procedure AssignInstance;
    procedure ReadInstance(aPKeyValueArr: TArray<Variant>);
    procedure FillParam(aParam: TFDParam; aValue: Variant);
  public
    class function GetStructure: TSructure; virtual; abstract;
    class function GetTableName: string;
    class procedure AddKey(var aKeyArr: TArray<TKeyField>; aFieldName: string;
      aFieldType: TFieldType);
    constructor Create(aDBEngine: TDBEngine; aInstanceArr: TArray<TInstance>); overload;
    constructor Create(aDBEngine: TDBEngine; aPKeyValueArr: TArray<Variant>); overload;
  end;
{$M-}

  TEntityClass = class of TEntityAbstract;

  TEntityFeatID = class abstract(TEntityAbstract)
  private
    FID: Integer;
    function GetSelectSQLString: string; override;
  public
    constructor Create(aDBEngine: TDBEngine; aID: Integer);
  published
    property ID: Integer read FID write FID;
  end;

  TEntityList<T: TEntityAbstract> = class abstract(TObjectList<T>)
  private
    FDBEngine: TDBEngine;
    function GetSelectSQLString(aFilterArr, aOrderArr: TArray<string>): string;
    procedure FillListByInstances(aFilterArr, aOrderArr: TArray<string>);
  public
    class function GetEntityClass: TEntityClass;
    constructor Create(aDBEngine: TDBEngine; aFilterArr, aOrderArr: TArray<string>);
  end;

implementation

uses
  System.TypInfo,
  System.SysUtils;

constructor TEntityAbstract.Create(aDBEngine: TDBEngine; aInstanceArr: TArray<TInstance>);
begin
  FDBEngine := aDBEngine;
  FIsNewInstance := False;

  FInstanceArr := aInstanceArr;
  AssignInstance;
end;

class function TORMEngine.GetInstanceArr(aQuery: TFDQuery): TArray<TInstance>;
var
  i: Integer;
  Instance: TInstance;
begin
  for i := 0 to aQuery.Fields.Count - 1 do
    begin
      Instance.FieldName := aQuery.Fields[i].FullName;
      Instance.FieldType := aQuery.Fields[i].DataType;
      Instance.Value := aQuery.Fields[i].Value;

      Result := Result + [Instance];
    end;
end;

procedure TEntityAbstract.AssignInstance;
var
  Instance: TInstance;
  PropInfo: PPropInfo;
  PropName: string;
begin
  for Instance in FInstanceArr do
    begin
      PropName := GetPropNameByFieldName(Instance.FieldName);
      PropInfo := GetPropInfo(Self, PropName);

      if PropInfo <> nil then
        SetPropValue(Self, PropName, Instance.Value);
    end;
end;

class function TEntityList<T>.GetEntityClass: TEntityClass;
begin
  Result := T;
end;

function TEntityList<T>.GetSelectSQLString(aFilterArr, aOrderArr: TArray<string>): string;
var
  FromPart: string;
  i: Integer;
  OrderPart: string;
  WherePart: string;
begin
  FromPart := GetEntityClass.GetStructure.TableName;

  WherePart := '1 = 1';
  for i := 0 to Length(aFilterArr) - 1 do
    begin
      WherePart := WherePart + ' and ';
      WherePart := WherePart + aFilterArr[i];
    end;

  OrderPart := '';
  for i := 0 to Length(aOrderArr) - 1 do
    begin
      if i > 0 then OrderPart := OrderPart + ', ';
      OrderPart := OrderPart + aOrderArr[i];
    end;
  if not OrderPart.IsEmpty then OrderPart := 'order by ' + OrderPart;

  Result := 'select * from %s where %s %s';
  Result := Format(Result, [FromPart, WherePart, OrderPart]);
end;

function TEntityFeatID.GetSelectSQLString: string;
begin
  Result := Format('select * from %s where ID = :ID', [GetTableName]);
end;

constructor TEntityFeatID.Create(aDBEngine: TDBEngine; aID: Integer);
var
  ValArr: TArray<Variant>;
begin
  if aID = 0 then
    ValArr := []
  else
    ValArr := [aID];

  inherited Create(aDBEngine, ValArr);
end;

function TEntityAbstract.GetPropNameByFieldName(aFieldName: string): string;
begin
  Result := aFieldName.Replace('_', '');
end;

function TEntityAbstract.GetPrimKeyFieldType(aFieldName: string): TFieldType;
var
  KeyField: TKeyField;
begin
  Result := ftUnknown;

  for KeyField in GetStructure.PrimaryKeyArr do
    if KeyField.FieldName = aFieldName then
      Exit(KeyField.FieldType);
end;

procedure TEntityAbstract.FillParam(aParam: TFDParam; aValue: Variant);
var
  FieldType: TFieldType;
begin
  FieldType := GetPrimKeyFieldType(aParam.Name);

  case FieldType of
    ftFloat: aParam.AsFloat := aValue;
    ftInteger: aParam.AsInteger := aValue;
    ftDateTime: aParam.AsDateTime := aValue;
    ftBoolean: aParam.AsBoolean := aValue;
  else
    aParam.AsString := aValue;
  end;
end;

function TEntityAbstract.GetSelectSQLString: string;
var
  i: Integer;
  KeyField: TKeyField;
begin
  Result := Format('select * from %s where', [GetTableName]);

  i := 0;
  for KeyField in GetStructure.PrimaryKeyArr do
    begin
      if i > 0 then Result := Result + ' and';
      Result := Result + Format(' %s = :%s', [KeyField.FieldName, KeyField.FieldName]);

      Inc(i);
    end;
end;

class function TEntityAbstract.GetTableName: string;
begin
  Result := GetStructure.TableName;
end;

class procedure TEntityAbstract.AddKey(var aKeyArr: TArray<TKeyField>;
   aFieldName: string; aFieldType: TFieldType);
var
  KeyField: TKeyField;
begin
  KeyField.FieldName := aFieldName;
  KeyField.FieldType := aFieldType;

  aKeyArr := aKeyArr + [KeyField];
end;

procedure TEntityAbstract.ReadInstance(aPKeyValueArr: TArray<Variant>);
var
  dsQuery: TFDQuery;
  i: Integer;
  SQL: string;
begin
  SQL := GetSelectSQLString;

  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := SQL;

    for i := 0 to dsQuery.Params.Count - 1 do
      FillParam(dsQuery.Params[i], aPKeyValueArr[i]);

    FDBEngine.OpenQuery(dsQuery);

    FInstanceArr := TORMEngine.GetInstanceArr(dsQuery);
  finally
    dsQuery.Free;
  end;
end;

constructor TEntityAbstract.Create(aDBEngine: TDBEngine; aPKeyValueArr: TArray<Variant>);
begin
  FDBEngine := aDBEngine;
  FIsNewInstance := (Length(aPKeyValueArr) = 0);

  if not FIsNewInstance then
    begin
      ReadInstance(aPKeyValueArr);
      AssignInstance;
    end;
end;

procedure TEntityList<T>.FillListByInstances(aFilterArr, aOrderArr: TArray<string>);
var
  dsQuery: TFDQuery;
  Entity: TEntityAbstract;
  InstanceArr: TArray<TInstance>;
  SQL: string;
begin
  SQL := GetSelectSQLString(aFilterArr, aOrderArr);

  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := SQL;
    FDBEngine.OpenQuery(dsQuery);

    while not dsQuery.EOF do
      begin
        InstanceArr := TORMEngine.GetInstanceArr(dsQuery);

        Entity := GetEntityClass.Create(FDBEngine, InstanceArr);
        Add(Entity);

        dsQuery.Next;
      end;
  finally
    dsQuery.Free;
  end;
end;

constructor TEntityList<T>.Create(aDBEngine: TDBEngine; aFilterArr, aOrderArr: TArray<string>);
begin
  inherited Create(True);

  FDBEngine := aDBEngine;
  FillListByInstances(aFilterArr, aOrderArr);
end;

end.
