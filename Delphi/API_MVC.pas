unit API_MVC;

interface

type
  TModelAbstract = class abstract
  end;

  IViewAbstract = interface
    procedure InitView;
    procedure SendMessage(aMsg: string);
  end;

{$M+}
  TControllerAbstract = class abstract
  protected
    procedure PerfomMessage(aMsg: string); virtual;
  public
    procedure ProcessMessage(aMsg: string);
    constructor Create; virtual;
  end;
{$M-}

  TControllerClass = class of TControllerAbstract;

  TProc = procedure of object;

implementation

procedure TControllerAbstract.PerfomMessage(aMsg: string);
begin
end;

procedure TControllerAbstract.ProcessMessage(aMsg: string);
var
  ControllerProc: TProc;
begin
  TMethod(ControllerProc).Code := Self.MethodAddress(aMsg);
  TMethod(ControllerProc).Data := Self;

  if Assigned(ControllerProc) then
    ControllerProc
  else
    PerfomMessage(aMsg);
end;

constructor TControllerAbstract.Create;
begin
end;

end.
