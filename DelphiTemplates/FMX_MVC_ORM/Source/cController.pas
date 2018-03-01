unit cController;

interface

uses
  API_DB,
  API_MVC_FMXDB;

type
  TController = class(TControllerFMXDB)
  protected
    procedure InitDB(var aDBEngineClass: TDBEngineClass; out aConnectParams: TConnectParams;
      out aConnectOnCreate: Boolean); override;
  end;

implementation

procedure TController.InitDB(var aDBEngineClass: TDBEngineClass;
  out aConnectParams: TConnectParams; out aConnectOnCreate: Boolean);
begin
// Assign aDBEngineClass and set aConnectParams here.
// For example:
//  aDBEngineClass := TSQLiteEngine;
//  aConnectOnCreate := True;
//  aConnectParams.DataBase := GetCurrentDir + '\DB\local.db';
end;

end.
