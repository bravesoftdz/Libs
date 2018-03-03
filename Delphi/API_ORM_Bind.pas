unit API_ORM_Bind;

interface

uses
  API_ORM,
  System.Classes;

type
  PBindItem = ^TBindItem;
  TBindItem = record
    Control: TComponent;
    Entity: TEntityAbstract;
    Index: Integer;
    PropName: string;
  end;

  TORMBind = class abstract
  private
    FBindItemArr: TArray<TBindItem>;
    function GetEntity(aControl: TComponent): TEntityAbstract;
    function GetItemIndex(aControl: TComponent): Integer;
    function GetPropNameByComponent(aComponent: TComponent; aPrefix: string): string;
    procedure PropControlChange(Sender: TObject);
  protected
    function GetFormComponent(aIndex: Integer): TComponent; virtual; abstract;
    function GetFormComponentCount: Integer; virtual; abstract;
    procedure SetControlProps(aControl: TComponent; aValue: Variant; aNotifyEvent: TNotifyEvent); virtual; abstract;
    procedure SetEntityProp(aEntity: TEntityAbstract; const aPropName: string; Sender: TObject); virtual; abstract;
  public
    procedure AddBindItem(aControl: TComponent; aEntity: TEntityAbstract; aPropName: string; aIndex: Integer = 0);
    procedure BindEntity(aEntity: TEntityAbstract; aPrefix: string = '');
    procedure RemoveBind(aControl: TComponent);
    property Entity[aControl: TComponent]: TEntityAbstract read GetEntity;
  end;

implementation

procedure TORMBind.PropControlChange(Sender: TObject);
var
  Entity: TEntityAbstract;
  ItemIndex: Integer;
  PropName: string;
begin
  ItemIndex := GetItemIndex(TComponent(Sender));

  Entity := FBindItemArr[ItemIndex].Entity;
  PropName := FBindItemArr[ItemIndex].PropName;

  SetEntityProp(Entity, PropName, Sender);
end;

function TORMBind.GetItemIndex(aControl: TComponent): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to Length(FBindItemArr) - 1 do
    if FBindItemArr[i].Control = aControl then
      Exit(i);
end;

procedure TORMBind.RemoveBind(aControl: TComponent);
var
  BindItem: TBindItem;
  ItemIndex: Integer;
begin
  SetControlProps(aControl, '', nil);

  ItemIndex := GetItemIndex(aControl);
  Delete(FBindItemArr, ItemIndex, 1);
end;

procedure TORMBind.BindEntity(aEntity: TEntityAbstract; aPrefix: string = '');
var
  Component: TComponent;
  i: Integer;
  PropName: string;
begin
  for i := 0 to GetFormComponentCount - 1 do
    begin
      Component := GetFormComponent(i);
      PropName := GetPropNameByComponent(Component, aPrefix);

      if PropName <> '' then
        begin
          RemoveBind(Component);
          AddBindItem(Component, aEntity, PropName);

          SetControlProps(Component, aEntity.Prop[PropName], PropControlChange);
        end;
    end;
end;

procedure TORMBind.AddBindItem(aControl: TComponent; aEntity: TEntityAbstract; aPropName: string; aIndex: Integer = 0);
var
  BindItem: TBindItem;
begin
  BindItem.Control := aControl;
  BindItem.Entity := aEntity;
  BindItem.Index := aIndex;
  BindItem.PropName := aPropName;

  FBindItemArr := FBindItemArr + [BindItem];
end;

function TORMBind.GetPropNameByComponent(aComponent: TComponent; aPrefix: string): string;
var
  PrefixLength: Integer;
begin
  PrefixLength := Length(aPrefix);

  if Copy(aComponent.Name, 1, 2 + PrefixLength) = 'bc' + aPrefix then
    Result := Copy(aComponent.Name, 3 + PrefixLength, Length(aComponent.Name))
  else
    Result := '';
end;

function TORMBind.GetEntity(aControl: TComponent): TEntityAbstract;
var
  BindItem: TBindItem;
begin
  Result := nil;

  for BindItem in FBindItemArr do
    if BindItem.Control = aControl then
      Exit(BindItem.Entity);
end;

end.
