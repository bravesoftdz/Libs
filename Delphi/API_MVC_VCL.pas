unit API_MVC_VCL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  API_MVC,
  API_MVC_DB,
  FireDAC.VCLUI.Wait;

type
  TViewVCLBase = class(TForm, IViewAbstract)
  private
    { Private declarations }
    FOnViewMessage: TViewMessageProc;
    procedure FormFree(Sender: TObject; var Action: TCloseAction);
  protected
    FController: TControllerAbstract;
    FControllerClass: TControllerClass;
    FDoNotFreeAfterClose: Boolean;
    FIsMainView: Boolean;
    procedure InitView; virtual; abstract;
    procedure SendMessage(aMsg: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property OnViewMessage: TViewMessageProc read FOnViewMessage write FOnViewMessage;
  end;

  TViewVCLBaseClass = class of TViewVCLBase;

  TControllerVCLBase = class(TControllerDB)
  protected
    procedure CallView(aViewVCLClass: TViewVCLBaseClass; aIsModal: Boolean = False);
  end;

var
  ViewVCLBase: TViewVCLBase;

implementation

{$R *.dfm}

procedure TViewVCLBase.FormFree(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TControllerVCLBase.CallView(aViewVCLClass: TViewVCLBaseClass; aIsModal: Boolean = False);
var
  View: TViewVCLBase;
begin
  View := aViewVCLClass.Create(nil);
  View.OnViewMessage := ProcessMessage;

  if aIsModal then
    View.ShowModal
  else
    View.Show;
end;

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

  if Assigned(FControllerClass) and not Assigned(FController) then
    begin
      FIsMainView := True;
      FController := FControllerClass.Create;
      FOnViewMessage := FController.ProcessMessage;
    end;

  if not FDoNotFreeAfterClose then
    OnClose := FormFree;
end;

procedure TViewVCLBase.SendMessage(aMsg: string);
begin
  FOnViewMessage(aMsg);
end;

end.
