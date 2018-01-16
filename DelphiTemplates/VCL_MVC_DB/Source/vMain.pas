unit vMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  API_MVC_VCL;

type
  TViewMain = class(TViewVCLBase)
  private
    { Private declarations }
    procedure InitMVC; override;
  public
    { Public declarations }
  end;

var
  ViewMain: TViewMain;

implementation

{$R *.dfm}

uses
  cController;

procedure TViewMain.InitMVC;
begin
  FControllerClass := TController;
end;

end.
