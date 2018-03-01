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
    FController: TControllerAbstract;
    FControllerClass: TControllerClass;
    FDoNotFreeAfterClose: Boolean;
    FIsMainView: Boolean;
    FOnViewMessage: TViewMessageProc;
    procedure FormFree(Sender: TObject; var Action: TCloseAction);
  protected
    /// <summary>
    /// Override this procedure for assign FControllerClass in the main Application View(Form).
    /// </summary>
    procedure InitMVC(var aControllerClass: TControllerClass); virtual;
    procedure SendMessage(aMsg: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property OnViewMessage: TViewMessageProc read FOnViewMessage write FOnViewMessage;
  end;

  TVCLSupport = class(TPlatformSupport)
  public
    function CreateView<T: TViewVCLBase>(aInstantShow: Boolean = False): T;
  end;

  TControllerVCLBase = class(TControllerAbstract)
  private
    FVCL: TVCLSupport;
  public
    constructor Create; override;
    destructor Destroy; override;
    property VCL: TVCLSupport read FVCL;
  end;

implementation

{$R *.dfm}

destructor TControllerVCLBase.Destroy;
begin
  FVCL.Free;

  inherited;
end;

constructor TControllerVCLBase.Create;
begin
  inherited;

  FVCL := TVCLSupport.Create(Self);
end;

procedure TViewVCLBase.InitMVC(var aControllerClass: TControllerClass);
begin
end;

procedure TViewVCLBase.FormFree(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

function TVCLSupport.CreateView<T>(aInstantShow: Boolean = False): T;
begin
  Result := T.Create(nil);
  Result.OnViewMessage := FController.ViewListener;

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

  InitMVC(FControllerClass);

  if Assigned(FControllerClass) and not Assigned(FController) then
    begin
      FIsMainView := True;
      FController := FControllerClass.Create;
      FOnViewMessage := FController.ViewListener;
    end;

  if not FDoNotFreeAfterClose then
    OnClose := FormFree;
end;

procedure TViewVCLBase.SendMessage(aMsg: string);
begin
  FOnViewMessage(aMsg);
end;

end.
