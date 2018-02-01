program VCL_MVC_ORM_Template;

uses
  Vcl.Forms,
  vMain in 'vMain.pas' {ViewMain},
  cController in 'cController.pas',
  API_MVC_DB in '..\..\..\Delphi\API_MVC_DB.pas',
  API_DB in '..\..\..\Delphi\API_DB.pas',
  API_MVC_VCLDB in '..\..\..\Delphi\API_MVC_VCLDB.pas',
  API_ORM in '..\..\..\Delphi\API_ORM.pas',
  API_Crypt in '..\..\..\Delphi\API_Crypt.pas',
  API_MVC_VCL in '..\..\..\Delphi\API_MVC_VCL.pas' {ViewVCLBase},
  API_MVC in '..\..\..\Delphi\API_MVC.pas',
  eCommon in 'eCommon.pas';

// ..\..\..\ replace with ..\..\

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
