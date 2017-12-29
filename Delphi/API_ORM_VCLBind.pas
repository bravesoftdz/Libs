unit API_ORM_VCLBind;

interface

uses
  API_ORM,
  System.Classes,
  System.SysUtils,
  Vcl.Forms;

type
  TBind = record
    Control: TObject;
    Entity: TEntityAbstract;
    Index: Integer;
  end;

  TORMBind = class
  private
    FBindArr: TArray<TBind>;
    function GetEntity(aControl: TObject): TEntityAbstract;
  public
    procedure Add(aControl: TObject; aEntity: TEntityAbstract; aIndex: Integer = 0);
    property Entity[aControl: TObject]: TEntityAbstract read GetEntity;
  end;

  TORMBindedForm = class(TForm)
  private
    function GetPropNameByComponent(aComponent: TComponent): string;
    procedure PropControlChange(Sender: TObject);
  protected
    FBind: TORMBind;
  public
    procedure BindEntity(aEntity: TEntityAbstract);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

uses
  Vcl.ExtCtrls;

function TORMBind.GetEntity(aControl: TObject): TEntityAbstract;
var
  Bind: TBind;
begin
  Result := nil;

  for Bind in FBindArr do
    if Bind.Control = aControl then
      Exit(Bind.Entity);
end;

procedure TORMBind.Add(aControl: TObject; aEntity: TEntityAbstract; aIndex: Integer = 0);
var
  Bind: TBind;
begin
  Bind.Control := aControl;
  Bind.Entity := aEntity;
  Bind.Index := aIndex;

  FBindArr := FBindArr + [Bind];
end;

procedure TORMBindedForm.PropControlChange(Sender: TObject);
var
  Entity: TEntityAbstract;
  PropName: string;
begin
  PropName := GetPropNameByComponent(TComponent(Sender));

  Entity := FBind.Entity[Sender];
  Entity.Prop[PropName] := TLabeledEdit(Sender).Text;
end;

function TORMBindedForm.GetPropNameByComponent(aComponent: TComponent): string;
begin
  if Copy(aComponent.Name, 1, 2) = 'bc' then
    Result := Copy(aComponent.Name, 3, Length(aComponent.Name))
  else
    Result := '';
end;

procedure TORMBindedForm.BindEntity(aEntity: TEntityAbstract);
var
  Component: TComponent;
  i: Integer;
  PropName: string;
begin
  for i := 0 to ComponentCount - 1 do
    begin
      Component := Components[i];
      PropName := GetPropNameByComponent(Component);

      if not PropName.IsEmpty then
        begin
          FBind.Add(Component, aEntity);

          if Component.ClassType = TLabeledEdit then
            begin
              TLabeledEdit(Component).Text := aEntity.Prop[PropName];
              TLabeledEdit(Component).OnChange := PropControlChange;
            end;
        end;
    end;
end;

destructor TORMBindedForm.Destroy;
begin
  FBind.Free;

  inherited;
end;

constructor TORMBindedForm.Create(AOwner: TComponent);
begin
  inherited;

  FBind := TORMBind.Create;
end;

end.
