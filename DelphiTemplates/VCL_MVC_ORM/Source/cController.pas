unit cController;

interface

uses
  API_MVC_VCLDB;

type
  TController = class(TControllerVCLDB)
  private
    procedure InitDB; override;
  end;

implementation

procedure TController.InitDB;
begin
// Assign FDBEngineClass and set FConnectParams here.
// For example:
//  FDBEngineClass := TSQLiteEngine;
//  FConnectOnCreate := True;
//  FConnectParams.DataBase := GetCurrentDir + '\DB\local.db';
end;

end.
