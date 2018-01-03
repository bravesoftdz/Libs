unit API_MVC_FMX;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  API_MVC,
  API_MVC_DB;

type
  TViewFMXBase = class(TForm, IViewAbstract)
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

  TViewFMXBaseClass = class of TViewFMXBase;

  TControllerFMXBase = class(TControllerDB)
  protected
    procedure CreateView(aViewFMXClass: TViewFMXBaseClass; aInstantShow: Boolean = False);
  end;

var
  ViewFMXBase: TViewFMXBase;

implementation

{$R *.fmx}

procedure TControllerFMXBase.CreateView(aViewFMXClass: TViewFMXBaseClass; aInstantShow: Boolean = False);
var
  View: TViewFMXBase;
begin
  View := aViewFMXClass.Create(nil);
  View.OnViewMessage := ProcessMessage;

  if aInstantShow then
    View.Show;
end;

destructor TViewFMXBase.Destroy;
begin
  SendMessage(Self.Name + 'Closed');

  if FIsMainView then
    FController.Free;

  inherited;
end;

procedure TViewFMXBase.FormFree(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

constructor TViewFMXBase.Create(AOwner: TComponent);
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

procedure TViewFMXBase.SendMessage(aMsg: string);
begin
  FOnViewMessage(aMsg);
end;

end.
