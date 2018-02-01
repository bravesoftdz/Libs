unit cController;

interface

uses
  API_DB,
  API_MVC_VCLDB;

type
  TController = class(TControllerVCLDB)
  private
    procedure InitDB(var aDBEngineClass: TDBEngineClass; out aConnectParams: TConnectParams;
      out aConnectOnCreate: Boolean); override;
  protected
    procedure AfterCreate; override;
  end;

var
  DBEngine: TDBEngine;

implementation

procedure TController.AfterCreate;
begin
  cController.DBEngine := Self.DBEngine;
end;

procedure TController.InitDB(var aDBEngineClass: TDBEngineClass; out aConnectParams: TConnectParams;
      out aConnectOnCreate: Boolean);
begin
// Assign aDBEngineClass and set aConnectParams here.
// For example:
//  aDBEngineClass := TSQLiteEngine;
//  aConnectOnCreate := True;
//  aConnectParams.DataBase := GetCurrentDir + '\DB\local.db';
end;

end.
