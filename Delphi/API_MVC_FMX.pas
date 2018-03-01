unit API_MVC_FMX;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  API_MVC;

type
  TViewFMXBase = class(TForm, IViewAbstract)
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

  TFMXSupport = class(TPlatformSupport)
  public
    function CreateView<T: TViewFMXBase>(aInstantShow: Boolean = False): T;
  end;

  TControllerFMXBase = class(TControllerAbstract)
  private
    FFMX: TFMXSupport;
  public
    constructor Create; override;
    destructor Destroy; override;
    property FMX: TFMXSupport read FFMX;
  end;

var
  ViewFMXBase: TViewFMXBase;

implementation

{$R *.fmx}

destructor TControllerFMXBase.Destroy;
begin
  FFMX.Free;

  inherited;
end;

constructor TControllerFMXBase.Create;
begin
  inherited;

  FFMX := TFMXSupport.Create(Self);
end;

procedure TViewFMXBase.InitMVC(var aControllerClass: TControllerClass);
begin
end;

function TFMXSupport.CreateView<T>(aInstantShow: Boolean = False): T;
begin
  Result := T.Create(nil);
  Result.OnViewMessage := FController.ViewListener;

  if aInstantShow then
    Result.Show;
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

procedure TViewFMXBase.SendMessage(aMsg: string);
begin
  FOnViewMessage(aMsg);
end;

end.
