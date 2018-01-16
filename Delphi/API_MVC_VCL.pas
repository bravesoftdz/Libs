unit API_MVC_VCL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  API_MVC;
  //API_MVC_DB,
  //API_ORM_VCLBind,
  //FireDAC.VCLUI.Wait;

type
  TViewVCLBase = class(TForm, IViewAbstract)
  private
    { Private declarations }
    FController: TControllerAbstract;
    FDoNotFreeAfterClose: Boolean;
    FIsMainView: Boolean;
    FOnViewMessage: TViewMessageProc;
    procedure FormFree(Sender: TObject; var Action: TCloseAction);
  protected
    FControllerClass: TControllerClass;
    /// <summary>
    /// Override this procedure for assign FControllerClass in the main Application View(Form).
    /// </summary>
    procedure InitMVC; virtual;
    procedure SendMessage(aMsg: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property OnViewMessage: TViewMessageProc read FOnViewMessage write FOnViewMessage;
  end;

  TControllerVCLBase = class(TControllerAbstract)
  protected
    function CreateView<T: TViewVCLBase>(aInstantShow: Boolean = False): T;
  end;

implementation

{$R *.dfm}

procedure TViewVCLBase.InitMVC;
begin
end;

procedure TViewVCLBase.FormFree(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

function TControllerVCLBase.CreateView<T>(aInstantShow: Boolean = False): T;
begin
  Result := T.Create(nil);
  Result.OnViewMessage := ProcessMessage;

  if aInstantShow then
    Result.Show;
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

  InitMVC;

  if Assigned(FControllerClass) and not Assigned(FController) then
    begin
      FIsMainView := True;
      FController := FControllerClass.Create;
      FOnViewMessage := FController.ProcessMessage;
    end;

  if not Assigned(FControllerClass) and
     not Assigned(FController)
  then
    Raise Exception.Create('FControllerClass isn`t assigned in the first View(Form)');

  if not FDoNotFreeAfterClose then
    OnClose := FormFree;
end;

procedure TViewVCLBase.SendMessage(aMsg: string);
begin
  FOnViewMessage(aMsg);
end;

end.
