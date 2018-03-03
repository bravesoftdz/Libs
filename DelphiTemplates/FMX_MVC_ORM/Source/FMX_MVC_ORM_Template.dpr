program FMX_MVC_ORM_Template;

uses
  System.StartUpCopy,
  FMX.Forms,
  cController in 'cController.pas',
  vMain in 'vMain.pas' {ViewMain},
  API_DB in '..\..\..\Delphi\API_DB.pas',
  API_MVC_FMXDB in '..\..\..\Delphi\API_MVC_FMXDB.pas',
  API_MVC_DB in '..\..\..\Delphi\API_MVC_DB.pas',
  API_MVC in '..\..\..\Delphi\API_MVC.pas',
  API_MVC_FMX in '..\..\..\Delphi\API_MVC_FMX.pas' {ViewFMXBase},
  eCommon in 'eCommon.pas',
  API_ORM in '..\..\..\Delphi\API_ORM.pas',
  API_ORM_BindFMX in '..\..\..\Delphi\API_ORM_BindFMX.pas',
  API_ORM_Bind in '..\..\..\Delphi\API_ORM_Bind.pas';

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF DEBUG}

  Application.Initialize;
  Application.CreateForm(TViewMain, ViewMain);
  Application.Run;
end.
