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
    procedure InitMVC; virtual;
    procedure SendMessage(aMsg: string);
  public
    { Public declarations }
  end;

var
  ViewVCLBase: TViewVCLBase;

implementation

{$R *.dfm}

procedure TViewVCLBase.InitMVC;
begin
end;

procedure TViewVCLBase.SendMessage(aMsg: string);
begin

end;

end.
