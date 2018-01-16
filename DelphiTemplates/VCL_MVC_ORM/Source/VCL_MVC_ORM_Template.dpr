program VCL_MVC_ORM_Template;

uses
  Vcl.Forms,
  API_MVC_VCL in '..\..\..\Delphi\API_MVC_VCL.pas' {ViewVCLBase},
  vMain in 'vMain.pas' {ViewMain},
  API_MVC in '..\..\..\Delphi\API_MVC.pas',
  cController in 'cController.pas',
  API_MVC_DB in '..\..\..\Delphi\API_MVC_DB.pas',
  API_DB in '..\..\..\Delphi\API_DB.pas',
  API_MVC_VCLDB in '..\..\..\Delphi\API_MVC_VCLDB.pas',
  API_DB_MySQL in '..\..\..\Delphi\API_DB_MySQL.pas';

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
