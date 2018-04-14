unit API_ORM_BindVCL;

interface

uses
  API_ORM,
  System.Classes,
  Vcl.Forms;

type
  PBindItem = ^TBindItem;
  TBindItem = record
    Control: TComponent;
    Entity: TEntityAbstract;
    Index: Integer;
    PropName: string;
  end;

  TORMBind = class
  private
    FBindItemArr: TArray<TBindItem>;
    FForm: TForm;
    function GetEntity(aControl: TComponent): TEntityAbstract;
    function GetItemIndex(aControl: TComponent): Integer;
    function GetPropNameByComponent(aComponent: TComponent; aPrefix: string): string;
    procedure PropControlChange(Sender: TObject);
    procedure SetControlProps(aControl: TComponent; aValue: Variant; aNotifyEvent: TNotifyEvent);
  public
    procedure AddBindItem(aControl: TComponent; aEntity: TEntityAbstract; aPropName: string; aIndex: Integer = 0);
    procedure BindEntity(aEntity: TEntityAbstract; aPrefix: string = '');
    procedure RemoveBind(aControl: TComponent);
    constructor Create(aForm: TForm);
    property Entity[aControl: TComponent]: TEntityAbstract read GetEntity;
  end;

implementation

uses
  Vcl.ExtCtrls,
  Vcl.StdCtrls;

function TORMBind.GetItemIndex(aControl: TComponent): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to Length(FBindItemArr) - 1 do
    if FBindItemArr[i].Control = aControl then
      Exit(i);
end;

procedure TORMBind.SetControlProps(aControl: TComponent; aValue: Variant; aNotifyEvent: TNotifyEvent);
begin
  if aControl.ClassType = TLabeledEdit then
    begin
      TLabeledEdit(aControl).OnChange := aNotifyEvent;
      TLabeledEdit(aControl).Text := aValue;
    end;

  if aControl.ClassType = TEdit then
    begin
      TEdit(aControl).OnChange := aNotifyEvent;
      TEdit(aControl).Text := aValue;
    end;

  if aControl.ClassType = TCheckBox then
    begin
      TCheckBox(aControl).OnClick := aNotifyEvent;

      if aValue = True then
        TCheckBox(aControl).Checked := True
      else
        TCheckBox(aControl).Checked := False;
    end;
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

constructor TORMBind.Create(aForm: TForm);
begin
  FForm := aForm;
end;

procedure TORMBind.BindEntity(aEntity: TEntityAbstract; aPrefix: string = '');
var
  Component: TComponent;
  i: Integer;
  PropName: string;
begin
  for i := 0 to FForm.ComponentCount - 1 do
    begin
      Component := FForm.Components[i];
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

procedure TORMBind.PropControlChange(Sender: TObject);
var
  Entity: TEntityAbstract;
  ItemIndex: Integer;
  PropName: string;
begin
  ItemIndex := GetItemIndex(TComponent(Sender));

  Entity := FBindItemArr[ItemIndex].Entity;
  PropName := FBindItemArr[ItemIndex].PropName;

  if Sender is TLabeledEdit then
    Entity.Prop[PropName] := TLabeledEdit(Sender).Text;

  if Sender is TEdit then
    Entity.Prop[PropName] := TCustomEdit(Sender).Text;

  if Sender is TCheckBox then
    if TCheckBox(Sender).Checked then
      Entity.Prop[PropName] := 1
    else
      Entity.Prop[PropName] := 0;
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
