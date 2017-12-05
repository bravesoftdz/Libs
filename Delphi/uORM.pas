unit uORM;

interface

uses
  Classes,
  Contnrs,
  DB,
  Forms,
  SYS_uDBTools,
  SysUtils,
  TypInfo;

type
  TFieldInitial  = record
    FieldName: string;
    FieldType: TFieldType;
    Value: Variant;
  end;

  TFieldInitialArr = array of TFieldInitial;

  TKeyDef = record
    FieldName: string;
    FieldType: TFieldType;
  end;

  TKeyDefArr = array of TKeyDef;

  TSructure = record
    ForeignKeys: TKeyDefArr;
    PrimaryKeys: TKeyDefArr;
    TableName: string;
  end;

  TFreeListProcArr = array of TMethod;

{$M+}
  TEntityORM = class
  private
    FFieldInitialArr: TFieldInitialArr;
    FFreeListProcArr: TFreeListProcArr;
    FIsNewInstance: Boolean;
    FQuery: TMyQuery;
    FRowID: string;
    function GetFieldType(aFieldName: string): TFieldType;
    function GetNormPropValue(aPropName: string; aPropInfo: PPropInfo): Variant;
    function GetProp(aPropName: string): Variant;
    function GetPropNameByComponent(aComponent: TComponent): string;
    function InsertToDB: Boolean;
    function UpdateToDB: Boolean;
    procedure FillEntity;
    procedure FillParam(aParam: TParam; aValue: Variant; aDefaultType: TFieldType = ftUnknown);
    procedure FillParamsByProps(aQuery: TMyQuery);
    procedure FreeLists;
    procedure PropControlChange(Sender: TObject);
    procedure ReadEmptyInstance;
    procedure ReadInstance(aKeyValues: array of Variant);
    procedure SetProp(aPropName: string; aValue: Variant);
  protected
    procedure ClearLists; virtual;
    procedure StoreLists; virtual;
  public
    class function GetStructure: TSructure; virtual; abstract;
    class procedure AddKey(var aKeys: TKeyDefArr; aFieldName: string; aFieldType: TFieldType);
    procedure BindForm(aForm: TForm);
    procedure Delete;
    procedure Revert;
    procedure Store;
    procedure StoreAll;
    constructor Create; overload;
    constructor Create(aKeyValues: array of Variant); overload;
    destructor Destroy; override;
    property FreeListProcArr: TFreeListProcArr read FFreeListProcArr write FFreeListProcArr;
    property Prop[aPropName: string]: Variant read GetProp write SetProp;
  published
    property RowID: string read FRowID write FRowID;
  end;
{$M-}

  TEntityORMClass = class of TEntityORM;

  TObjProc = procedure of object;

  TEntityORMList = class(TObjectList)
  private
    FDelRowIDs: array of string;
    FEntityORMClass: TEntityORMClass;
    FOwnerEntity: TEntityORM;
    FFreeProc: TObjProc;
    FQuery: TMyQuery;
    procedure AddDelRowID(aRowID: string);
    procedure DeleteByRowID(aRowID: string);
    procedure FillList;
  protected
    procedure Clear; override;
  public
    function Add(aEntity: TEntityORM): Integer;
    procedure ClearAndStore;
    procedure Remove(aEntity: TEntityORM); overload;
    procedure Remove(aIndex: Integer); overload;
    procedure Revert;
    procedure Store;
    constructor Create(aEntityORMClass: TEntityORMClass; aOwnerEntity: TEntityORM; aOrder: string = ''); overload;
    constructor Create(aEntityORMClass: TEntityORMClass; aKeyFields: array of string;
      aValues: array of Variant; aOrder: string = ''); overload;
    destructor Destroy; override;
    property FreeProc: TObjProc read FFreeProc;
    property Query: TMyQuery read FQuery;
  end;

implementation

uses
  CurrEdit,
  StdCtrls,
  ToolEdit;

procedure TEntityORM.FreeLists;
var
  FreeListProc: TObjProc;
  i: Integer;
begin
  for i := 0 to Length(FreeListProcArr) - 1 do
    begin
      FreeListProc := TObjProc(FreeListProcArr[i]);
      FreeListProc;
    end;
end;

procedure TEntityORMList.FillList;
var
  ArrLength: Integer;
  EntityORM: TEntityORM;
  i: Integer;
  KeyValues: array of Variant;
  PrimaryKeys: TKeyDefArr;
begin
  PrimaryKeys := FEntityORMClass.GetStructure.PrimaryKeys;
  ArrLength := Length(PrimaryKeys);
  SetLength(KeyValues, ArrLength);

  while not FQuery.EOF do
    begin
      for i := 0 to Length(PrimaryKeys) - 1 do
        begin
          KeyValues[i] := FQuery.FieldByName(PrimaryKeys[i].FieldName).Value;
        end;

      EntityORM := FEntityORMClass.Create(KeyValues);
      Add(EntityORM);

      FQuery.Next;
    end;
end;

procedure TEntityORMList.Revert;
begin
  inherited Clear;

  FQuery.Close;
  FQuery.Open;
  FQuery.FetchAll;
  FillList;
  FQuery.First;
end;

procedure TEntityORM.Revert;
begin
  SetLength(FFieldInitialArr, 0);
  FQuery.Close;
  FQuery.Open;
  FillEntity;
end;

procedure TEntityORMList.Remove(aEntity: TEntityORM);
begin
  AddDelRowID(aEntity.RowID);

  inherited Remove(aEntity);
end;

procedure TEntityORMList.Remove(aIndex: Integer);
var
  RemoveEntity: TEntityORM;
begin
  RemoveEntity := Self[aIndex] as TEntityORM;
  Remove(RemoveEntity);
end;

procedure TEntityORMList.DeleteByRowID(aRowID: string);
var
  Query: TMyQuery;
  SQL: string;
begin
  SQL := Format('delete from %s where ROWID = ''%s''', [
    FEntityORMClass.GetStructure.TableName,
    aRowID
  ]);

  Query := TMyQuery.Create(nil);
  try
    Query.SQL.Text := SQL;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TEntityORMList.AddDelRowID(aRowID: string);
var
  ArrLength: Integer;
begin
  if aRowID = '' then Exit;

  ArrLength := Length(FDelRowIDs);
  SetLength(FDelRowIDs, ArrLength + 1);
  FDelRowIDs[ArrLength] := aRowID;
end;

procedure TEntityORMList.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    AddDelRowID(TEntityORM(Self[i]).RowID);

  inherited;
end;

procedure TEntityORMList.ClearAndStore;
begin
  Self.Clear;
  Self.Store;
end;

procedure TEntityORM.Delete;
var
  Query: TMyQuery;
  SQL: string;
begin
  ClearLists;

  SQL := Format('delete from %s where ROWID = ''%s''', [GetStructure.TableName, RowID]);

  Query := TMyQuery.Create(nil);
  try
    Query.SQL.Text := SQL;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TEntityORMList.Store;
var
  Entity: TEntityORM;
  ForeignKeyDefArr: TKeyDefArr;
  i, j: Integer;
begin
  for i := 0 to Length(FDelRowIDs) - 1 do
    begin
      DeleteByRowID(FDelRowIDs[i]);
    end;

  for i := 0 to Self.Count - 1 do
    begin
      Entity := Self[i] as TEntityORM;

      if Assigned(FOwnerEntity) then
        begin
          ForeignKeyDefArr := Entity.GetStructure.ForeignKeys;

          for j := 0 to Length(ForeignKeyDefArr) - 1 do
            begin
              Entity.Prop[ForeignKeyDefArr[j].FieldName] := FOwnerEntity.Prop[ForeignKeyDefArr[j].FieldName];
            end;
        end;

      Entity.Store;
    end;

  FQuery.Close;
  FQuery.Open;
end;

procedure TEntityORM.ClearLists;
begin
end;

procedure TEntityORM.StoreLists;
begin
end;

procedure TEntityORM.StoreAll;
begin
  Store;
  StoreLists;
end;

function TEntityORMList.Add(aEntity: TEntityORM): Integer;
begin
  inherited Add(aEntity);
end;

procedure TEntityORM.SetProp(aPropName: string; aValue: Variant);
begin
  SetPropValue(Self, aPropName, aValue);
end;

function TEntityORM.GetPropNameByComponent(aComponent: TComponent): string;
begin
  Result := Copy(aComponent.Name, 4, Length(aComponent.Name));
end;

procedure TEntityORM.PropControlChange(Sender: TObject);
var
  Component: TComponent;
  PropName: string;
begin
  Component := TComponent(Sender);
  PropName := GetPropNameByComponent(Component);

  if Component.ClassType = TEdit then
    begin
      Self.Prop[PropName] := TEdit(Component).Text;
    end;

  if Component.ClassType = TRXCalcEdit then
    begin
      Self.Prop[PropName] := TRXCalcEdit(Component).Value;
    end;

  if Component.ClassType = TCheckBox then
    begin
      if TCheckBox(Component).Checked then
        Self.Prop[PropName] := 1
      else
        Self.Prop[PropName] := 0;
    end;

  if Component.ClassType = TComboEdit then
    begin
      Self.Prop[PropName] := TComboEdit(Component).Text;
    end;

  if Component.ClassType = TDateEdit then
    begin
      Self.Prop[PropName] := TDateEdit(Component).Date;
    end;
end;

procedure TEntityORM.BindForm(aForm: TForm);
var
  Component: TComponent;
  i: Integer;
  PropName: string;
begin
  for i := 0 to aForm.ComponentCount - 1 do
    begin
      Component := aForm.Components[i];

      if Copy(Component.Name, 1, 3) = 'bnd' then
        begin
          PropName := GetPropNameByComponent(Component);

          if Component.ClassType = TEdit then
            begin
              TEdit(Component).Text := Self.Prop[PropName];
              TEdit(Component).OnChange := PropControlChange;
            end;

          if Component.ClassType = TComboEdit then
            begin
              TComboEdit(Component).Text := Self.Prop[PropName];
              TComboEdit(Component).OnChange := PropControlChange;
            end;

          if Component.ClassType = TRXCalcEdit then
            begin
              TRXCalcEdit(Component).Value := Self.Prop[PropName];
              TRXCalcEdit(Component).OnChange := PropControlChange;
            end;

          if Component.ClassType = TCheckBox then
            begin
              if not VarIsNull(Self.Prop[PropName]) and (Self.Prop[PropName] = True) then
                TCheckBox(Component).Checked := True
              else
                TCheckBox(Component).Checked := False;

              TCheckBox(Component).OnClick := PropControlChange;
            end;

          if Component.ClassType = TDateEdit then
            begin
              TDateEdit(Component).Date := Self.Prop[PropName];
              TDateEdit(Component).OnChange := PropControlChange;
            end;
        end;
    end;
end;

function TEntityORM.GetProp(aPropName: string): Variant;
begin
  Result := GetPropValue(Self, aPropName);
end;

constructor TEntityORMList.Create(aEntityORMClass: TEntityORMClass; aOwnerEntity: TEntityORM; aOrder: string = '');
var
  ArrLength: Integer;
  i: Integer;
  ForeignKeyDefArr: TKeyDefArr;
  FreeProcArr: TFreeListProcArr;
  Keys: array of string;
  Values: array of Variant;
begin
  FOwnerEntity := aOwnerEntity;
  ForeignKeyDefArr := aEntityORMClass.GetStructure.ForeignKeys;

  ArrLength := Length(ForeignKeyDefArr);
  SetLength(Keys, ArrLength);
  SetLength(Values, ArrLength);

  for i := 0 to ArrLength - 1 do
    begin
      Keys[i] := ForeignKeyDefArr[i].FieldName;
      Values[i] := FOwnerEntity.Prop[Keys[i]];
    end;

  Create(aEntityORMClass, Keys, Values, aOrder);

  FreeProcArr := aOwnerEntity.FreeListProcArr;
  ArrLength := Length(FreeProcArr);
  SetLength(FreeProcArr, ArrLength + 1);

  FFreeProc := Free;
  FreeProcArr[ArrLength].Code := @FreeProc;
  FreeProcArr[ArrLength].Data := Self;

  aOwnerEntity.FreeListProcArr := FreeProcArr;
end;

destructor TEntityORMList.Destroy;
begin
  FQuery.Free;
  inherited;
end;

constructor TEntityORMList.Create(aEntityORMClass: TEntityORMClass; aKeyFields: array of string;
  aValues: array of Variant; aOrder: string = '');
var
  i: Integer;
  SQL: string;
begin
  inherited Create;
  FEntityORMClass := aEntityORMClass;
  FQuery := TMyQuery.Create(nil);

  SQL := Format('select * from %s', [aEntityORMClass.GetStructure.TableName]);
  SQL := SQL + ' where ';

  for i := 0 to Length(aKeyFields) - 1 do
    begin
      if i > 0 then SQL := SQL + ' AND';
      SQL := SQL + Format(' %s = :%s', [aKeyFields[i], aKeyFields[i]]);
    end;

  if aOrder <> '' then SQL := SQL + ' order by ' + aOrder;

  FQuery.SQL.Text := SQL;

  for i := 0 to FQuery.Params.Count - 1 do
    begin
      FQuery.Params[i].Value := aValues[i];
    end;

  Revert;
end;

function TEntityORM.GetNormPropValue(aPropName: string; aPropInfo: PPropInfo): Variant;
begin
  Result := GetPropValue(Self, aPropName);

  if aPropInfo^.PropType^.Name = 'Boolean' then
    if Result = 'True' then Result := 1
    else Result := 0;
end;

function TEntityORM.UpdateToDB: Boolean;
var
  FieldInitial: TFieldInitial;
  i: Integer;
  ParamsCount: Integer;
  PropInfo: PPropInfo;
  Query: TMyQuery;
  SQL: string;
  Value: Variant;
begin
  Result := False;
  SQL := Format('update %s set', [GetStructure.TableName]);

  ParamsCount := 0;
  for i := 0 to Length(FFieldInitialArr) - 1 do
    begin
      FieldInitial := FFieldInitialArr[i];

      PropInfo := GetPropInfo(Self, FieldInitial.FieldName);
      if PropInfo <> nil then
        begin
          Value := GetNormPropValue(FieldInitial.FieldName, PropInfo);

          if (FieldInitial.FieldType = ftString) and VarIsNull(FieldInitial.Value) then
            FieldInitial.Value := '';

          if (FieldInitial.FieldType = ftFloat) and VarIsNull(FieldInitial.Value) then
            FieldInitial.Value := 0;

          if FieldInitial.Value <> Value then
            begin
              if ParamsCount > 0 then SQL := SQL + ',';
              SQL := SQL + Format(' %s = :%s', [FieldInitial.FieldName, FieldInitial.FieldName]);
              Inc(ParamsCount);
            end;
        end;
    end;

  SQL := SQL + Format(' where ROWID = ''%s''', [RowID]);

  if ParamsCount > 0 then
    begin
      Query := TMyQuery.Create(nil);
      try
        Query.SQL.Text := SQL;
        FillParamsByProps(Query);
        Query.ExecSQL;
      finally
        Query.Free;
      end;

      Result := True;
    end;
end;

function TEntityORM.GetFieldType(aFieldName: string): TFieldType;
var
  i: Integer;
begin
  Result := ftUnknown;

  for i := 0 to Length(FFieldInitialArr) - 1 do
    begin
      if FFieldInitialArr[i].FieldName = aFieldName then
        begin
          Result := FFieldInitialArr[i].FieldType;
          Break;
        end;
    end;
end;

procedure TEntityORM.FillParam(aParam: TParam; aValue: Variant; aDefaultType: TFieldType = ftUnknown);
var
  FieldType: TFieldType;
begin
  if aDefaultType = ftUnknown then
    FieldType := GetFieldType(aParam.Name)
  else
    FieldType := aDefaultType;

  case FieldType of
    ftFloat: aParam.AsFloat := aValue;
    ftInteger: aParam.AsInteger := aValue;
    ftDateTime: aParam.AsDateTime := aValue;
    ftBoolean: aParam.AsBoolean := aValue;
  else
    aParam.AsString := aValue;
  end;
end;

procedure TEntityORM.FillParamsByProps(aQuery: TMyQuery);
var
  i: Integer;
  PropInfo: PPropInfo;
  Value: Variant;
begin
  for i := 0 to aQuery.Params.Count - 1 do
    begin
      PropInfo := GetPropInfo(Self, aQuery.Params[i].Name);

      if PropInfo <> nil then
        begin
          Value := GetNormPropValue(aQuery.Params[i].Name, PropInfo);
          FillParam(aQuery.Params[i], Value);
        end
      else
        aQuery.Params[i].Clear;
    end;
end;

procedure TEntityORM.ReadEmptyInstance;
var
  SQL: string;
begin
  SQL := Format('select rowid, t.* from %s t where rowid = ''''', [GetStructure.TableName]);
  FQuery.SQL.Text := SQL;

  Revert;
end;

function TEntityORM.InsertToDB: Boolean;
var
  FieldInitial: TFieldInitial;
  FieldsString: string;
  i: Integer;
  ParamsString: string;
  Query: TMyQuery;
  SQL: string;
begin
  FieldsString := '';
  ParamsString := '';
  for i := 0 to Length(FFieldInitialArr) - 1 do
    begin
      FieldInitial := FFieldInitialArr[i];

      if i > 0 then FieldsString := FieldsString + ', ';
      FieldsString := FieldsString + FieldInitial.FieldName;

      if i > 0 then ParamsString := ParamsString + ', ';
      ParamsString := ParamsString + ':' + FieldInitial.FieldName;
    end;

  SQL := Format('insert into %s (%s) values (%s)',
    [
     GetStructure.TableName,
     FieldsString,
     ParamsString
    ]
  );

  Query := TMyQuery.Create(nil);
  try
    Query.SQL.Text := SQL;
    FillParamsByProps(Query);
    Query.ExecSQL;
  finally
    Query.Free;
  end;

  Result := True;
end;

procedure TEntityORM.Store;
var
  IsStored: Boolean;
begin
  if FIsNewInstance then
    begin
      IsStored := InsertToDB;
      FIsNewInstance := False;
    end
  else
    IsStored := UpdateToDB;

  if IsStored then Revert;
end;

constructor TEntityORM.Create;
begin
  FIsNewInstance := True;
  Create(['']);
end;

class procedure TEntityORM.AddKey(var aKeys: TKeyDefArr; aFieldName: string; aFieldType: TFieldType);
var
  ArrLength: Integer;
  KeyDef: TKeyDef;
begin
  KeyDef.FieldName := aFieldName;
  KeyDef.FieldType := aFieldType;

  ArrLength := Length(aKeys);
  SetLength(aKeys, ArrLength + 1);
  aKeys[ArrLength] := KeyDef;
end;

procedure TEntityORM.FillEntity;
var
  ArrLength: Integer;
  FieldInitial: TFieldInitial;
  i: Integer;
  PropInfo: PPropInfo;
begin
  for i := 0 to FQuery.Fields.Count - 1 do
    begin
      if FQuery.Fields[i].FullName <> 'ROWID' then
        begin
          FieldInitial.FieldName := FQuery.Fields[i].FullName;
          FieldInitial.FieldType := FQuery.Fields[i].DataType;
          FieldInitial.Value := FQuery.Fields[i].Value;

          ArrLength := Length(FFieldInitialArr);
          SetLength(FFieldInitialArr, ArrLength + 1);
          FFieldInitialArr[ArrLength] := FieldInitial;
        end;

      if not FIsNewInstance and not FQuery.Fields[i].IsNull then
        begin
          PropInfo := GetPropInfo(Self, FQuery.Fields[i].FullName);

          if PropInfo <> nil then
            SetPropValue(Self, FQuery.Fields[i].FullName, FQuery.Fields[i].Value);
        end;
    end;
end;

procedure TEntityORM.ReadInstance(aKeyValues: array of Variant);
var
  i: Integer;
  PrimaryKey: TKeyDef;
  PrimaryKeys: TKeyDefArr;
  SQL: string;
begin
  PrimaryKeys := GetStructure.PrimaryKeys;
  if Length(aKeyValues) <> Length(PrimaryKeys) then
    raise Exception.Create('Ќеверное кол-во параметров конструктора ORM!');

  SQL := Format('select rowid, t.* from %s t where', [GetStructure.TableName]);

  for i := 0 to Length(PrimaryKeys) - 1 do
    begin
      PrimaryKey := PrimaryKeys[i];
      if i > 0 then SQL := SQL + ' AND';
      SQL := SQL + Format(' %s = :%s', [PrimaryKey.FieldName, PrimaryKey.FieldName]);
    end;

  FQuery.SQL.Text := SQL;
  for i := 0 to FQuery.Params.Count - 1 do
    FillParam(FQuery.Params[i], aKeyValues[i], PrimaryKeys[i].FieldType);

  Revert;
end;

constructor TEntityORM.Create(aKeyValues: array of Variant);
begin
  FQuery := TMyQuery.Create(nil);

  if FIsNewInstance then
    ReadEmptyInstance
  else
    ReadInstance(aKeyValues);
end;

destructor TEntityORM.Destroy;
begin
  if Assigned(FQuery) then FQuery.Free;
  FreeLists;

  inherited;
end;

end.
