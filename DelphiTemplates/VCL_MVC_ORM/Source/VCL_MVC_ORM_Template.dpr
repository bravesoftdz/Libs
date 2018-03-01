program VCL_MVC_ORM_Template;

uses
  Vcl.Forms,
  vMain in 'vMain.pas' {ViewMain},
  cController in 'cController.pas',
  API_MVC_DB in 'D:\Git\Libs\Delphi\API_MVC_DB.pas',
  API_DB in 'D:\Git\Libs\Delphi\API_DB.pas',
  API_MVC_VCLDB in 'D:\Git\Libs\Delphi\API_MVC_VCLDB.pas',
  API_ORM in 'D:\Git\Libs\Delphi\API_ORM.pas',
  API_MVC_VCL in 'D:\Git\Libs\Delphi\API_MVC_VCL.pas' {ViewVCLBase},
  API_MVC in 'D:\Git\Libs\Delphi\API_MVC.pas',
  eCommon in 'eCommon.pas';

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
