program FMX_MVC_DB_Template;

uses
  System.StartUpCopy,
  FMX.Forms,
  vMain in 'vMain.pas' {ViewMain},
  API_MVC_FMX in '..\..\..\Delphi\API_MVC_FMX.pas' {ViewFMXBase},
  API_MVC in '..\..\..\Delphi\API_MVC.pas',
  cController in 'cController.pas',
  API_MVC_FMXDB in '..\..\..\Delphi\API_MVC_FMXDB.pas',
  API_MVC_DB in '..\..\..\Delphi\API_MVC_DB.pas',
  API_DB in '..\..\..\Delphi\API_DB.pas';

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF DEBUG}

  Application.Initialize;
  Application.CreateForm(TViewMain, ViewMain);
  Application.Run;
end.
