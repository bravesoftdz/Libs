unit API_MVC_VCL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  API_MVC;

type
  TViewVCLBase = class(TForm, IViewAbstract)
  private
    { Private declarations }
  protected
    FController: TControllerAbstract;
    FControllerClass: TControllerClass;
    FIsMainView: Boolean;
    procedure InitView; virtual; abstract;
    procedure SendMessage(aMsg: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  ViewVCLBase: TViewVCLBase;

implementation

{$R *.dfm}

destructor TViewVCLBase.Destroy;
begin
  SendMessage(Self.Name + 'Closed');

  if FIsMainView then
    FController.Free;

  inherited;
end;

constructor TViewVCLBase.Create(AOwner: TComponent);
begin
  inherited;

  InitView;

  if Assigned(FControllerClass) then
    begin
      FIsMainView := True;
      FController := FControllerClass.Create;
    end;
end;

procedure TViewVCLBase.SendMessage(aMsg: string);
begin
  FController.ProcessMessage(aMsg);
end;

end.
