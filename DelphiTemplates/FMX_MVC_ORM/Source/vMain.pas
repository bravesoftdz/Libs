unit vMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  API_MVC,
  API_MVC_FMX,
  API_ORM_BindFMX;

type
  TViewMain = class(TViewFMXBase)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FBind: TORMBindFMX;
  protected
    procedure InitMVC(var aControllerClass: TControllerClass); override;
  public
    { Public declarations }
    property Bind: TORMBindFMX read FBind;
  end;

var
  ViewMain: TViewMain;

implementation

{$R *.fmx}

uses
  cController;

procedure TViewMain.FormCreate(Sender: TObject);
begin
  inherited;

  FBind := TORMBindFMX.Create(Self);
end;

procedure TViewMain.FormDestroy(Sender: TObject);
begin
  inherited;

  FBind.Free;
end;

procedure TViewMain.InitMVC(var aControllerClass: TControllerClass);
begin
  aControllerClass := TController;
  ViewMain := Self;
end;

end.
