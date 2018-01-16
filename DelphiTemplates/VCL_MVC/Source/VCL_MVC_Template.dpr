program VCL_MVC_Template;

uses
  Vcl.Forms,
  API_MVC_VCL in '..\..\..\Delphi\API_MVC_VCL.pas' {ViewVCLBase},
  vMain in 'vMain.pas' {ViewMain},
  API_MVC in '..\..\..\Delphi\API_MVC.pas',
  cController in 'cController.pas';

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF DEBUG}

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TViewMain, ViewMain);
  Application.Run;
end.
