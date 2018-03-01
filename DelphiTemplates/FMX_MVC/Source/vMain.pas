unit vMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  API_MVC,
  API_MVC_FMX;

type
  TViewMain = class(TViewFMXBase)
  private
    { Private declarations }
  protected
    procedure InitMVC(var aControllerClass: TControllerClass); override;
  public
    { Public declarations }
  end;

var
  ViewMain: TViewMain;

implementation

{$R *.fmx}

uses
  cController;

procedure TViewMain.InitMVC(var aControllerClass: TControllerClass);
begin
  aControllerClass := TController;
  ViewMain := Self;
end;

end.
