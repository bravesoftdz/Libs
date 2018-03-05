unit API_ORM_BindFMX;

interface

uses
  API_ORM,
  API_ORM_Bind,
  FMX.Forms,
  System.Classes;

type
  TORMBindFMX = class(TORMBind)
  private
    FForm: TForm;
  protected
    function GetFormComponent(aIndex: Integer): TComponent; override;
    function GetFormComponentCount: Integer; override;
    procedure SetControlProps(aControl: TComponent; aValue: Variant; aNotifyEvent: TNotifyEvent); override;
    procedure SetEntityProp(aEntity: TEntityAbstract; const aPropName: string; Sender: TObject); override;
  public
    constructor Create(aForm: TForm);
  end;

implementation

uses
  FMX.Edit,
  FMX.ListBox,
  System.Variants;

function TORMBindFMX.GetFormComponent(aIndex: Integer): TComponent;
begin
  Result := FForm.Components[aIndex];
end;

function TORMBindFMX.GetFormComponentCount: Integer;
begin
  Result := FForm.ComponentCount;
end;

procedure TORMBindFMX.SetEntityProp(aEntity: TEntityAbstract; const aPropName: string; Sender: TObject);
begin
  if Sender is TEdit then
    aEntity.Prop[aPropName] := TCustomEdit(Sender).Text;

  if Sender is TComboBox then
    aEntity.Prop[aPropName] := TComboBox(Sender).ItemIndex + 1;
end;

constructor TORMBindFMX.Create(aForm: TForm);
begin
  FForm := aForm;
end;

procedure TORMBindFMX.SetControlProps(aControl: TComponent; aValue: Variant; aNotifyEvent: TNotifyEvent);
begin
  if aControl is TEdit then
    begin
      TEdit(aControl).OnChange := aNotifyEvent;
      TEdit(aControl).Text := aValue;
    end;

  if aControl is TComboBox then
    begin
      TComboBox(aControl).OnChange := aNotifyEvent;
      if VarIsNumeric(aValue) then
        TComboBox(aControl).ItemIndex := aValue - 1;
    end;

{  if aControl.ClassType = TCheckBox then
    begin
      TCheckBox(aControl).OnClick := aNotifyEvent;

      if aValue = True then
        TCheckBox(aControl).Checked := True
      else
        TCheckBox(aControl).Checked := False;
    end; }
end;

end.
