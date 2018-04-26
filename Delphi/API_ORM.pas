unit API_ORM;

interface

uses
  API_DB,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  System.Generics.Collections;

type
  TEntityAbstract = class;
  TEntityClass = class of TEntityAbstract;

  TPrimaryKeyField = record
    FieldName: string;
    FieldType: TFieldType;
  end;

  TPrimaryKey = array of TPrimaryKeyField;

  TRelType = (rtUnknown, rtOne2One, rtOne2Many);

  TForeignKey = record
    FieldName: string;
    ReferEntityClass: TEntityClass;
    ReferFieldName: string;
    RelType: TRelType;
  end;

  TSructure = record
    ForeignKeyArr: TArray<TForeignKey>;
    PrimaryKey: TPrimaryKey;
    TableName: string;
  end;

  TInstance = record
    FieldName: string;
    FieldType: TFieldType;
    Value: Variant;
  end;

  TObjProc = procedure of object;
  TEachJoinEntProp = procedure(aJoinEntity: TEntityAbstract; aEntityClass: TEntityClass;
   aEntityPropName, aFieldName, aReferFieldName: string) of object;

{$M+}
  TEntityAbstract = class abstract
  private
    FFreeListProcArr: TArray<TMethod>;
    FInstanceArr: TArray<TInstance>;
    FIsNewInstance: Boolean;
    FStoreListProcArr: TArray<TMethod>;
    class function GetInstanceArr(aQuery: TFDQuery): TArray<TInstance>;
    class function GetPropNameByFieldName(aFieldName: string): string;
    function CheckPropExist(aFieldName: string; out aPropName: string): Boolean;
    function GetDeleteSQLString: string;
    function GetInsertSQLString: string;
    function GetInstanceFieldType(aFieldName: string): TFieldType;
    function GetInstanceValue(aFieldName: string): Variant;
    function GetEmptySelectSQLString: string;
    function GetNormInstanceValue(aInstance: TInstance): Variant;
    function GetNormPropValue(aPropName: string): Variant;
    function GetPrimKeyFieldType(aFieldName: string): TFieldType;
    function GetProp(aPropName: string): Variant;
    function GetSelectSQLString: string; virtual; 
    function GetUpdateSQLString: string;
    function GetWherePart: string; virtual;
    procedure AddProcToArr(var aProcArr: TArray<TMethod>; aCode, aData: Pointer);
    procedure AssignInstanceFromProps;
    procedure AssignProps;
    procedure AssignPropsFromInstance;
    procedure CreateJoinEntity(aJoinEntity: TEntityAbstract; aEntityClass: TEntityClass;
      aEntityPropName, aFieldName, aReferFieldName: string);
    procedure ExecProcArr(aProcArr: TArray<TMethod>);
    procedure ExecToDB(aSQL: string);
    procedure FillParam(aParam: TFDParam; aFieldName: string; aValue: Variant);
    procedure ForEachJoinChildProp(aEachJoinEntProp: TEachJoinEntProp);
    procedure ForEachJoinParentProp(aEachJoinEntProp: TEachJoinEntProp);
    procedure FreeJoinEntity(aJoinEntity: TEntityAbstract; aEntityClass: TEntityClass;
      aEntityPropName, aFieldName, aReferFieldName: string);
    procedure FreeLists;
    procedure InsertToDB; virtual;
    procedure ReadInstance(aPKeyValueArr: TArray<Variant>);
    procedure SetProp(aPropName: string; aValue: Variant);
    procedure StoreJoinChildEnt(aJoinEntity: TEntityAbstract; aEntityClass: TEntityClass;
      aEntityPropName, aFieldName, aReferFieldName: string);
    procedure StoreJoinParentEnt(aJoinEntity: TEntityAbstract; aEntityClass: TEntityClass;
      aEntityPropName, aFieldName, aReferFieldName: string);
    procedure StoreLists;
    procedure UpdateToDB;
  protected
    FDBEngine: TDBEngine;
    procedure AfterCreate; virtual;
    procedure BeforeDelete; virtual;
  public
    class function GetStructure: TSructure; virtual; abstract;
    class function GetTableName: string;
    class procedure AddForeignKey(var aForeignKeyArr: TArray<TForeignKey>; aFieldName: string;
      aReferEntityClass: TEntityClass; aReferFieldName: string = ''; aRelType: TRelType = rtUnknown);
    class procedure AddPimaryKeyField(var aPrimaryKey: TPrimaryKey; aFieldName: string;
      aFieldType: TFieldType);
    function IsPropExists(const aPropName: string): Boolean;
    procedure Delete;
    procedure Revert;
    procedure Store;
    procedure StoreAll;
    constructor Create(aDBEngine: TDBEngine); overload;
    constructor Create(aDBEngine: TDBEngine; aInstanceArr: TArray<TInstance>); overload;
    constructor Create(aDBEngine: TDBEngine; aPKeyValueArr: TArray<Variant>); overload;
    destructor Destroy; override;
    property IsNewInstance: Boolean read FIsNewInstance;
    property Prop[aPropName: string]: Variant read GetProp write SetProp;
  end;
{$M-}

  TEntityFeatID = class abstract(TEntityAbstract)
  private
    FID: Integer;
    function GetWherePart: string; override;
    procedure InsertToDB; override;
  public
    constructor Create(aDBEngine: TDBEngine; aID: Integer = 0);
  published
    property ID: Integer read FID write FID;
  end;

  TEntityAbstractList<T: TEntityAbstract> = class(TObjectList<T>)
  private
    FDBEngine: TDBEngine;
    FFilterArr: TArray<string>;
    FForeignKeyArr: TArray<TForeignKey>;
    FOrderArr: TArray<string>;
    FOwnerEntity: TEntityAbstract;
    FRecycleBin: TArray<T>;
    function GetSelectSQLString(aFilterArr, aOrderArr: TArray<string>): string;
    procedure CleanRecycleBin;
    procedure FillListByInstances(aFilterArr, aOrderArr: TArray<string>);
  public
    class function GetEntityClass: TEntityClass;
    procedure Clear;
    procedure Delete(const aIndex: Integer);
    procedure Refresh;
    procedure Remove(const aEntity: T); overload;
    procedure Remove(const aIndex: Integer); overload;
    procedure Store;
    constructor Create(aDBEngine: TDBEngine; aFilterArr, aOrderArr: TArray<string>); overload;
    constructor Create(aOwnerEntity: TEntityAbstract); overload;
    constructor Create(aOwnerEntity: TEntityAbstract; aOrderArr: TArray<string>); overload;
    destructor Destroy; override;
    property DBEngine: TDBEngine read FDBEngine;
  end;

implementation

uses
  System.SysUtils,
  System.TypInfo,
  System.Variants;

function TEntityAbstract.IsPropExists(const aPropName: string): Boolean;
var
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(Self, aPropName);

  if PropInfo <> nil then
    Result := True
  else
    Result := False;
end;

procedure TEntityAbstractList<T>.Refresh;
begin
  inherited Clear;
  FillListByInstances(FFilterArr, FOrderArr);
end;

procedure TEntityAbstract.AfterCreate;
begin
end;

procedure TEntityAbstract.BeforeDelete;
begin
end;

constructor TEntityAbstract.Create(aDBEngine: TDBEngine);
var
  VarArr: TArray<Variant>;
begin
  VarArr := [];

  Create(aDBEngine, VarArr);
end;

procedure TEntityAbstract.StoreJoinChildEnt(aJoinEntity: TEntityAbstract; aEntityClass: TEntityClass;
  aEntityPropName, aFieldName, aReferFieldName: string);
var
  PropName: string;
  ReferPropName: string;
begin
  if not Assigned(aJoinEntity) then
    Exit;

  PropName := GetPropNameByFieldName(aFieldName);
  ReferPropName := GetPropNameByFieldName(aReferFieldName);

  aJoinEntity.Prop[ReferPropName] := Prop[PropName];

  aJoinEntity.StoreAll;
end;

procedure TEntityAbstract.StoreJoinParentEnt(aJoinEntity: TEntityAbstract; aEntityClass: TEntityClass;
  aEntityPropName, aFieldName, aReferFieldName: string);
var
  PropName: string;
  ReferPropName: string;
begin
  if not Assigned(aJoinEntity) then
    Exit;

  aJoinEntity.StoreAll;

  PropName := GetPropNameByFieldName(aFieldName);
  ReferPropName := GetPropNameByFieldName(aReferFieldName);

  Prop[PropName] := aJoinEntity.Prop[ReferPropName];
end;

procedure TEntityAbstract.FreeJoinEntity(aJoinEntity: TEntityAbstract; aEntityClass: TEntityClass;
  aEntityPropName, aFieldName, aReferFieldName: string);
begin
  if Assigned(aJoinEntity) then
    aJoinEntity.Free;
end;

procedure TEntityAbstract.CreateJoinEntity(aJoinEntity: TEntityAbstract; aEntityClass: TEntityClass;
  aEntityPropName, aFieldName, aReferFieldName: string);
var
  dsQuery: TFDQuery;
  InstanceArr: TArray<TInstance>;
  KeyValue: Variant;
  PropName: string;
  SQL: string;
begin
  if aJoinEntity <> nil then
    Exit;

  PropName := GetPropNameByFieldName(aFieldName);
  KeyValue := Prop[PropName];

  if (VarToStr(KeyValue) <> '') and
     (VarToStr(KeyValue) <> '0')
  then
    begin
      SQL := 'select * from %s where %s = ''%s''';
      SQL := Format(SQL, [
        aEntityClass.GetTableName,
        aReferFieldName,
        VarToStr(KeyValue)
      ]);

      dsQuery := TFDQuery.Create(nil);
      try
        dsQuery.SQL.Text := SQL;
        FDBEngine.OpenQuery(dsQuery);

        if not dsQuery.IsEmpty then
          begin
            InstanceArr := GetInstanceArr(dsQuery);

            aJoinEntity := aEntityClass.Create(FDBEngine, InstanceArr);

            SetObjectProp(Self, aEntityPropName, aJoinEntity);
          end;
      finally
        dsQuery.Free;
      end;
    end;
end;

procedure TEntityAbstract.ForEachJoinChildProp(aEachJoinEntProp: TEachJoinEntProp);
var
  ChildEntity: TEntityAbstract;
  Entity: TEntityAbstract;
  EntityClass: TEntityClass;
  ForeignKey: TForeignKey;
  ForeignKeyArr: TArray<TForeignKey>;
  i: Integer;
  PropCount: Integer;
  PropClass: TClass;
  PropList: PPropList;
  PropName: string;
begin
  PropCount := GetPropList(Self, PropList);
  try
    for i := 0 to PropCount - 1 do
      begin
        if PropList^[i].PropType^.Kind = tkClass then
          begin
            PropClass := GetObjectPropClass(Self, PropList^[i]);

            if PropClass.InheritsFrom(TEntityAbstract) then
              begin
                EntityClass := TEntityClass(PropClass);
                ForeignKeyArr := EntityClass.GetStructure.ForeignKeyArr;

                for ForeignKey in ForeignKeyArr do
                  if (Self.ClassType = ForeignKey.ReferEntityClass) and
                     (ForeignKey.RelType <> rtOne2Many)
                  then
                    begin
                      PropName := GetPropName(PropList^[i]);
                      Entity := GetObjectProp(Self, PropName) as EntityClass;

                      aEachJoinEntProp(
                        Entity,
                        EntityClass,
                        PropName,
                        ForeignKey.ReferFieldName,
                        ForeignKey.FieldName
                      );
                    end;
              end;
          end;
      end;
  finally
    FreeMem(PropList);
  end;
end;

procedure TEntityAbstract.ExecProcArr(aProcArr: TArray<TMethod>);
var
  Proc: TObjProc;
  Method: TMethod;
begin
  for Method in aProcArr do
    begin
      Proc := TObjProc(Method);
      Proc;
    end;
end;

procedure TEntityAbstract.AddProcToArr(var aProcArr: TArray<TMethod>; aCode, aData: Pointer);
var
  Method: TMethod;
begin
  Method.Code := aCode;
  Method.Data := aData;

  aProcArr := aProcArr + [Method];
end;

function TEntityAbstract.GetInstanceValue(aFieldName: string): Variant;
var
  Instance: TInstance;
begin
  Result := Null;

  for Instance in FInstanceArr do
    if Instance.FieldName = aFieldName then
      Exit(Instance.Value);
end;

procedure TEntityAbstract.ForEachJoinParentProp(aEachJoinEntProp: TEachJoinEntProp);
var
  Entity: TEntityAbstract;
  ForeignKey: TForeignKey;
  i: Integer;
  PropCount: Integer;
  PropClass: TClass;
  PropList: PPropList;
  PropName: string;
begin
  PropCount := GetPropList(Self, PropList);
  try
    for ForeignKey in GetStructure.ForeignKeyArr do
      begin
        for i := 0 to PropCount - 1 do
          begin
            PropClass := GetObjectPropClass(Self, PropList^[i]);

            if (ForeignKey.ReferEntityClass = PropClass) and
               (ForeignKey.RelType <> rtOne2Many)
            then
              begin
                PropName := GetPropName(PropList^[i]);
                Entity := GetObjectProp(Self, PropName) as ForeignKey.ReferEntityClass;

                aEachJoinEntProp(
                  Entity,
                  ForeignKey.ReferEntityClass,
                  PropName,
                  ForeignKey.FieldName,
                  ForeignKey.ReferFieldName
                );
              end;
          end;
      end;
  finally
    FreeMem(PropList);
  end;
end;

procedure TEntityAbstract.AssignProps;
begin
  AssignPropsFromInstance;
  ForEachJoinParentProp(CreateJoinEntity);
  ForEachJoinChildProp(CreateJoinEntity);
end;

procedure TEntityAbstractList<T>.Clear;
var
  Entity: T;
  EntityArr: TArray<T>;
begin
  EntityArr := Self.ToArray;

  for Entity in EntityArr do
    Self.Remove(Entity);
end;

procedure TEntityAbstractList<T>.CleanRecycleBin;
var
  Entity: T;
begin
  for Entity in FRecycleBin do
    Entity.Delete;
end;

destructor TEntityAbstractList<T>.Destroy;
var
  Entity: T;
begin
  for Entity in FRecycleBin do
    Entity.Free;

  inherited;
end;

procedure TEntityAbstractList<T>.Delete(const aIndex: Integer);
begin
  Remove(aIndex);
end;

procedure TEntityAbstractList<T>.Remove(const aEntity: T);
begin
  Extract(aEntity);
  FRecycleBin := FRecycleBin + [aEntity];
end;

procedure TEntityAbstractList<T>.Remove(const aIndex: Integer);
var
  Entity: T;
begin
  Entity := Items[aIndex];
  Remove(Entity);
end;

procedure TEntityAbstractList<T>.Store;
var
  Entity: T;
  ForeignKey: TForeignKey;
  KeyPropName: string;
  RefPropName: string;
begin
  CleanRecycleBin;

  for Entity in Self do
    begin
      if Assigned(FOwnerEntity) then
        begin
          for ForeignKey in FForeignKeyArr do
            begin
              KeyPropName := TEntityAbstract.GetPropNameByFieldName(ForeignKey.FieldName);
              RefPropName := TEntityAbstract.GetPropNameByFieldName(ForeignKey.ReferFieldName);

              Entity.Prop[KeyPropName] := FOwnerEntity.Prop[RefPropName];
            end;
        end;

      Entity.StoreAll;
    end;
end;

procedure TEntityAbstract.StoreLists;
begin
  ExecProcArr(FStoreListProcArr);
end;

procedure TEntityAbstract.StoreAll;
begin
  ForEachJoinParentProp(StoreJoinParentEnt);
  Store;
  ForEachJoinChildProp(StoreJoinChildEnt);
  StoreLists;
end;

procedure TEntityAbstract.FreeLists;
begin
  ExecProcArr(FFreeListProcArr);
end;

destructor TEntityAbstract.Destroy;
begin
  ForEachJoinParentProp(FreeJoinEntity);
  ForEachJoinChildProp(FreeJoinEntity);
  FreeLists;

  inherited;
end;

constructor TEntityAbstractList<T>.Create(aOwnerEntity: TEntityAbstract; aOrderArr: TArray<string>);
var
  Filter: string;
  FilterArr: TArray<string>;
  ForeignKey: TForeignKey;
  ForeignKeyArr: TArray<TForeignKey>;
  Proc: TObjProc;
begin
  ForeignKeyArr := GetEntityClass.GetStructure.ForeignKeyArr;

  FilterArr := [];
  for ForeignKey in ForeignKeyArr do
    begin
      if (ForeignKey.ReferEntityClass = aOwnerEntity.ClassType) and
         (ForeignKey.RelType <> rtOne2One)
      then
        begin
          Filter := Format('%s = ''%s''', [
            ForeignKey.FieldName,
            VarToStr(aOwnerEntity.Prop[ForeignKey.ReferFieldName])
          ]);

          FilterArr := FilterArr + [Filter];
          FForeignKeyArr := FForeignKeyArr + [ForeignKey];
        end;
    end;

  if Length(FilterArr) > 0 then
    begin
      FOwnerEntity := aOwnerEntity;

      Create(aOwnerEntity.FDBEngine, FilterArr, aOrderArr);

      Proc := Free;
      aOwnerEntity.AddProcToArr(aOwnerEntity.FFreeListProcArr, @Proc, Self);

      Proc := Store;
      aOwnerEntity.AddProcToArr(aOwnerEntity.FStoreListProcArr, @Proc, Self);
    end;
end;

constructor TEntityAbstractList<T>.Create(aOwnerEntity: TEntityAbstract);
var
  OrderArr: TArray<string>;
begin
  OrderArr := [];
  Create(aOwnerEntity, OrderArr);
end;

class procedure TEntityAbstract.AddForeignKey(var aForeignKeyArr: TArray<TForeignKey>;
  aFieldName: string; aReferEntityClass: TEntityClass; aReferFieldName: string = ''; aRelType: TRelType = rtUnknown);
var
  ForeignKey: TForeignKey;
begin
  ForeignKey.FieldName := aFieldName;
  ForeignKey.ReferEntityClass := aReferEntityClass;
  ForeignKey.RelType := aRelType;

  if not aReferFieldName.IsEmpty then
    ForeignKey.ReferFieldName := aReferFieldName
  else
    ForeignKey.ReferFieldName := aFieldName;

  aForeignKeyArr := aForeignKeyArr + [ForeignKey];
end;

function TEntityAbstract.GetNormPropValue(aPropName: string): Variant;
var
  PropInfo: PPropInfo;
begin
  Result := Prop[aPropName];

  PropInfo := GetPropInfo(Self, aPropName);

  if PropInfo^.PropType^.Name = 'Boolean' then
    if Result = 'True' then
      Result := 1
    else
      Result := 0;
end;

function TEntityAbstract.GetNormInstanceValue(aInstance: TInstance): Variant;
begin
  Result := aInstance.Value;

  if (aInstance.FieldType = ftString) and
     VarIsNull(Result)
  then
    Result := '';

  if (aInstance.FieldType in [ftInteger, ftShortint, ftFloat]) and
     VarIsNull(Result)
  then
    Result := 0;
end;

procedure TEntityAbstract.Revert;
begin
  if not FIsNewInstance then
    AssignPropsFromInstance;
end;

function TEntityAbstract.GetDeleteSQLString: string;
begin
  Result := Format('delete from %s where %s', [GetTableName, GetWherePart]);
end;

procedure TEntityAbstract.Delete;
var
  SQL: string;
begin
  BeforeDelete;

  if not FIsNewInstance then
    begin
      SQL := GetDeleteSQLString;
      ExecToDB(SQL);
    end;
end;

procedure TEntityAbstract.ExecToDB(aSQL: string);
var
  dsQuery: TFDQuery;
  i: Integer;
  FieldName: string;
  ParamName: string;
  ParamValue: Variant;
  PropName: string;
begin
  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := aSQL;

    for i := 0 to dsQuery.Params.Count - 1 do
      begin
        ParamName := dsQuery.Params[i].Name;

        if ParamName.StartsWith('OLD_') then
          begin
            FieldName := ParamName.Substring(4);
            ParamValue := GetInstanceValue(FieldName);
          end
        else
          begin
            FieldName := ParamName;
            PropName := GetPropNameByFieldName(FieldName);
            ParamValue := GetNormPropValue(PropName);
          end;

        FillParam(dsQuery.Params[i], FieldName, ParamValue);
      end;

    FDBEngine.ExecQuery(dsQuery);
  finally
    dsQuery.Free;
  end;
end;

function TEntityAbstract.GetWherePart: string;
var
  i: Integer;
  KeyField: TPrimaryKeyField;
begin
  i := 0;
  Result := '';
  for KeyField in GetStructure.PrimaryKey do
    begin
      if i > 0 then
        Result := Result + ' and ';
      Result := Result + Format('%s = :OLD_%s', [KeyField.FieldName, KeyField.FieldName]);
      Inc(i);
    end;
end;

function TEntityAbstract.CheckPropExist(aFieldName: string; out aPropName: string): Boolean;
var
  PropInfo: PPropInfo;
begin
  aPropName := GetPropNameByFieldName(aFieldName);
  Result := IsPropExists(aPropName);
end;

function TEntityAbstract.GetUpdateSQLString: string;
var
  i: Integer;
  Instance: TInstance;
  PropName: string;
  SetPart: string;
begin
  i := 0;
  SetPart := '';
  for Instance in FInstanceArr do
    begin
      if CheckPropExist(Instance.FieldName, PropName) and
         (GetNormInstanceValue(Instance) <> GetNormPropValue(PropName))
      then
        begin
          if i > 0 then
            SetPart := SetPart + ', ';
          SetPart := SetPart + Format('`%s` = :%s', [Instance.FieldName, Instance.FieldName]);
          Inc(i);
        end;
    end;

  if i = 0 then
    Result := ''
  else
    Result := Format('update %s set %s where %s', [GetTableName, SetPart, GetWherePart]);
end;

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
    if FInstanceArr[i].FieldName = 'ID' then
      begin
        FInstanceArr[i].Value := LastInsertedID;
        Break;
      end;

  Prop['ID'] := LastInsertedID;
end;

procedure TEntityAbstract.AssignInstanceFromProps;
var
  i: Integer;
  PropName: string;
begin
  for i := 0 to Length(FInstanceArr) - 1 do
    begin
      if CheckPropExist(FInstanceArr[i].FieldName, PropName) and
         (GetNormInstanceValue(FInstanceArr[i]) <> GetNormPropValue(PropName))
      then
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
  PropName: string;
  ValuesPart: string;
begin
  i := 0;
  FieldsPart := '';
  ValuesPart := '';
  for Instance in FInstanceArr do
    begin
      if (Instance.FieldType <> ftAutoInc) and
         (CheckPropExist(Instance.FieldName, PropName))
      then
        begin
          if i > 0 then
            begin
              FieldsPart := FieldsPart + ', ';
              ValuesPart := ValuesPart + ', ';
            end;
          FieldsPart := FieldsPart + Format('`%s`', [Instance.FieldName]);
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
  SQL: string;
begin
  ReadInstance([]);
  SQL := GetInsertSQLString;
  ExecToDB(SQL);
  AssignInstanceFromProps;
end;

procedure TEntityAbstract.UpdateToDB;
var
  SQL: string;
begin
  SQL := GetUpdateSQLString;
  if SQL.IsEmpty then Exit;

  ExecToDB(SQL);
  AssignInstanceFromProps;
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
  AssignProps;

  AfterCreate;
end;

class function TEntityAbstract.GetInstanceArr(aQuery: TFDQuery): TArray<TInstance>;
var
  i: Integer;
  Instance: TInstance;
begin
  Result := [];

  for i := 0 to aQuery.Fields.Count - 1 do
    begin
      Instance.FieldName := UpperCase(aQuery.Fields[i].FullName);
      Instance.FieldType := aQuery.Fields[i].DataType;
      Instance.Value := aQuery.Fields[i].Value;

      Result := Result + [Instance];
    end;
end;

procedure TEntityAbstract.AssignPropsFromInstance;
var
  Instance: TInstance;
  PropName: string;
begin
  for Instance in FInstanceArr do
    begin
      if (CheckPropExist(Instance.FieldName, PropName)) and
         (not VarIsNull(Instance.Value))
      then
        Prop[PropName] := Instance.Value;
    end;
end;

class function TEntityAbstractList<T>.GetEntityClass: TEntityClass;
begin
  Result := T;
end;

function TEntityAbstractList<T>.GetSelectSQLString(aFilterArr, aOrderArr: TArray<string>): string;
var
  FromPart: string;
  i: Integer;
  OrderPart: string;
  WherePart: string;
begin
  FromPart := GetEntityClass.GetTableName;

  for i := 0 to Length(aFilterArr) - 1 do
    begin
      if aFilterArr[i] = '*' then
        aFilterArr[i] := '1 = 1';

      if i > 0 then
        WherePart := WherePart + ' and ';

      WherePart := WherePart + aFilterArr[i];
    end;

  OrderPart := '';
  for i := 0 to Length(aOrderArr) - 1 do
    begin
      if i > 0 then
        OrderPart := OrderPart + ', ';

      OrderPart := OrderPart + aOrderArr[i];
    end;

  if not OrderPart.IsEmpty then
    OrderPart := 'order by ' + OrderPart;

  Result := 'select * from %s where %s %s';
  Result := Format(Result, [FromPart, WherePart, OrderPart]);
end;

function TEntityFeatID.GetWherePart: string;
begin
  Result := 'ID = :OLD_ID';
end;

constructor TEntityFeatID.Create(aDBEngine: TDBEngine; aID: Integer = 0);
var
  ValArr: TArray<Variant>;
begin
  if aID = 0 then
    ValArr := []
  else
    ValArr := [aID];

  inherited Create(aDBEngine, ValArr);
end;

class function TEntityAbstract.GetPropNameByFieldName(aFieldName: string): string;
begin
  Result := aFieldName.Replace('_', '');
end;

function TEntityAbstract.GetPrimKeyFieldType(aFieldName: string): TFieldType;
var
  KeyField: TPrimaryKeyField;
begin
  Result := ftUnknown;

  for KeyField in GetStructure.PrimaryKey do
    if KeyField.FieldName = aFieldName then
      Exit(KeyField.FieldType);
end;

procedure TEntityAbstract.FillParam(aParam: TFDParam; aFieldName: string; aValue: Variant);
var
  FieldType: TFieldType;
begin
  if Length(FInstanceArr) > 0 then
    FieldType := GetInstanceFieldType(aParam.Name)
  else
    FieldType := GetPrimKeyFieldType(aParam.Name);

  aParam.DataType := FieldType;

  case FieldType of
    ftFloat, ftInteger, ftSmallint:
      begin
        if aValue = 0 then
          aParam.Clear
        else
          aParam.AsFloat := aValue;
      end;
    ftDateTime: aParam.AsDateTime := aValue;
    ftBoolean: aParam.AsBoolean := aValue;
    ftString, ftWideString, ftWideMemo:
      begin
        if aValue = '' then
          aParam.Clear
        else
          aParam.AsString := aValue;
      end
  else
    aParam.AsString := aValue;
  end;
end;

function TEntityAbstract.GetSelectSQLString: string;
begin
  Result := Format('select * from %s where %s', [GetTableName, GetWherePart]);
end;

class function TEntityAbstract.GetTableName: string;
begin
  Result := GetStructure.TableName;
end;

class procedure TEntityAbstract.AddPimaryKeyField(var aPrimaryKey: TPrimaryKey;
  aFieldName: string; aFieldType: TFieldType);
var
  KeyField: TPrimaryKeyField;
begin
  KeyField.FieldName := aFieldName;
  KeyField.FieldType := aFieldType;

  aPrimaryKey := aPrimaryKey + [KeyField];
end;

procedure TEntityAbstract.ReadInstance(aPKeyValueArr: TArray<Variant>);
var
  dsQuery: TFDQuery;
  FieldName: string;
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
      begin
        FieldName := dsQuery.Params[i].Name.Substring(5);
        FillParam(dsQuery.Params[i], FieldName, aPKeyValueArr[i]);
      end;

    FDBEngine.OpenQuery(dsQuery);

    FInstanceArr := GetInstanceArr(dsQuery);
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
      AssignProps;
    end;

  AfterCreate; 
end;

procedure TEntityAbstractList<T>.FillListByInstances(aFilterArr, aOrderArr: TArray<string>);
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
        InstanceArr := TEntityAbstract.GetInstanceArr(dsQuery);

        Entity := GetEntityClass.Create(FDBEngine, InstanceArr);
        Add(Entity);

        dsQuery.Next;
      end;
  finally
    dsQuery.Free;
  end;
end;

constructor TEntityAbstractList<T>.Create(aDBEngine: TDBEngine; aFilterArr, aOrderArr: TArray<string>);
begin
  inherited Create(True);

  FFilterArr := aFilterArr;
  FOrderArr := aOrderArr;
  FDBEngine := aDBEngine;

  if Length(FFilterArr) > 0 then
    FillListByInstances(FFilterArr, FOrderArr);
end;

end.
