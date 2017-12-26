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
    function GetInsertSQLString: string;
    function GetInstanceFieldType(aFieldName: string): TFieldType;
    function GetEmptySelectSQLString: string;
    function GetPrimKeyFieldType(aFieldName: string): TFieldType;
    function GetProp(aPropName: string): Variant;
    function GetPropNameByFieldName(aFieldName: string): string;
    function GetSelectSQLString: string; virtual;
    procedure AssignFromInstance;
    procedure AssignToInstance;
    procedure FillParam(aParam: TFDParam; aValue: Variant);
    procedure InsertToDB; virtual;
    procedure ReadInstance(aPKeyValueArr: TArray<Variant>);
    procedure SetProp(aPropName: string; aValue: Variant);
    procedure UpdateToDB;
  public
    class function GetStructure: TSructure; virtual; abstract;
    class function GetTableName: string;
    class procedure AddKey(var aKeyArr: TArray<TKeyField>; aFieldName: string;
      aFieldType: TFieldType);
    procedure Store;
    constructor Create(aDBEngine: TDBEngine; aInstanceArr: TArray<TInstance>); overload;
    constructor Create(aDBEngine: TDBEngine; aPKeyValueArr: TArray<Variant>); overload;
    property Prop[aPropName: string]: Variant read GetProp write SetProp;
  end;
{$M-}

  TEntityClass = class of TEntityAbstract;

  TEntityFeatID = class abstract(TEntityAbstract)
  private
    FID: Integer;
    function GetSelectSQLString: string; override;
    procedure InsertToDB; override;
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
  System.Math,
  System.TypInfo,
  System.SysUtils,
  System.Variants;

function TEntityAbstract.GetInstanceFieldType(aFieldName: string): TFieldType;
var
  Instance: TInstance;
begin
  Result := ftUnknown;

  for Instance in FInstanceArr do
    if Instance.FieldName = aFieldName then
      Exit(Instance.FieldType);
end;

procedure TEntityFeatID.InsertToDB;
var
  i: Integer;
  LastInsertedID: Integer;
begin
  inherited;

  LastInsertedID := FDBEngine.GetLastInsertedID;

  for i := 0 to Length(FInstanceArr) - 1 do
    if FInstanceArr[i].FieldName = 'Id' then
      begin
        FInstanceArr[i].Value := LastInsertedID;
        Break;
      end;

  Prop['ID'] := LastInsertedID;
end;

procedure TEntityAbstract.AssignToInstance;
var
  i: Integer;
  PropInfo: PPropInfo;
  PropName: string;
begin
  for i := 0 to Length(FInstanceArr) - 1 do
    begin
      PropName := GetPropNameByFieldName(FInstanceArr[i].FieldName);
      PropInfo := GetPropInfo(Self, PropName);

      if PropInfo <> nil then
        FInstanceArr[i].Value := Prop[PropName];
    end;
end;

procedure TEntityAbstract.SetProp(aPropName: string; aValue: Variant);
begin
  SetPropValue(Self, aPropName, aValue);
end;

function TEntityAbstract.GetProp(aPropName: string): Variant;
begin
  Result := GetPropValue(Self, aPropName);
end;

function TEntityAbstract.GetInsertSQLString: string;
var
  FieldsPart: string;
  i: Integer;
  Instance: TInstance;
  ValuesPart: string;
begin
  i := 0;
  FieldsPart := '';
  ValuesPart := '';
  for Instance in FInstanceArr do
    begin
      if Instance.FieldType <> ftAutoInc then
        begin
          if i > 0 then
            begin
              FieldsPart := FieldsPart + ', ';
              ValuesPart := ValuesPart + ', ';
            end;
          FieldsPart := FieldsPart + Instance.FieldName;
          ValuesPart := ValuesPart + ':' + Instance.FieldName;
          Inc(i);
        end;
    end;

  Result := Format('insert into %s (%s) values (%s)', [GetTableName, FieldsPart, ValuesPart]);
end;

function TEntityAbstract.GetEmptySelectSQLString: string;
begin
  Result := Format('select * from %s where 1 = 2', [GetTableName]);
end;

procedure TEntityAbstract.InsertToDB;
var
  dsQuery: TFDQuery;
  i: Integer;
  PropName: string;
  SQL: string;
begin
  ReadInstance([]);

  SQL := GetInsertSQLString;

  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := SQL;

    for i := 0 to dsQuery.Params.Count - 1 do
      begin
        PropName := GetPropNameByFieldName(dsQuery.Params[i].Name);
        FillParam(dsQuery.Params[i], Prop[PropName]);
      end;

    FDBEngine.ExecQuery(dsQuery);
    AssignToInstance;
  finally
    dsQuery.Free;
  end;
end;

procedure TEntityAbstract.UpdateToDB;
begin

end;

procedure TEntityAbstract.Store;
begin
  if FIsNewInstance then
    begin
      InsertToDB;
      FIsNewInstance := False;
    end
  else
    UpdateToDB;
end;

constructor TEntityAbstract.Create(aDBEngine: TDBEngine; aInstanceArr: TArray<TInstance>);
begin
  FDBEngine := aDBEngine;
  FIsNewInstance := False;

  FInstanceArr := aInstanceArr;
  AssignFromInstance;
end;

class function TORMEngine.GetInstanceArr(aQuery: TFDQuery): TArray<TInstance>;
var
  i: Integer;
  Instance: TInstance;
begin
  Result := [];

  for i := 0 to aQuery.Fields.Count - 1 do
    begin
      Instance.FieldName := aQuery.Fields[i].FullName;
      Instance.FieldType := aQuery.Fields[i].DataType;
      Instance.Value := aQuery.Fields[i].Value;

      Result := Result + [Instance];
    end;
end;

procedure TEntityAbstract.AssignFromInstance;
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
  if Length(FInstanceArr) > 0 then
    FieldType := GetInstanceFieldType(aParam.Name)
  else
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
  if Length(aPKeyValueArr) = 0 then
    SQL := GetEmptySelectSQLString
  else
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
      AssignFromInstance;
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
