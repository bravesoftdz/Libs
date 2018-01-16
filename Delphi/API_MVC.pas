unit API_MVC;

interface

uses
  System.Generics.Collections,
  System.Threading;

type
  TModelAbstract = class abstract
  private
    procedure Execute(Sender: TObject);
  protected
    FDataObj: TObjectDictionary<string, TObject>;
  public
    procedure Start; virtual; abstract;
    constructor Create(aDataObj: TObjectDictionary<string, TObject> = nil);
  end;

  TModelClass = class of TModelAbstract;

  IViewAbstract = interface
    procedure InitMVC;
    procedure SendMessage(aMsg: string);
  end;

  TProc = procedure of object;
  TViewMessageProc = procedure(aMsg: string) of object;

  TTaskData = record
    Model: TModelAbstract;
    Task: ITask;
  end;

{$M+}
  TControllerAbstract = class abstract
  private
    FTaskDataArr: TArray<TTaskData>;
  protected
    FDataObj: TObjectDictionary<string, TObject>;
    procedure CallModel<T: TModelAbstract>(aThreadCount: Integer = 1);
    procedure PerfomMessage(aMsg: string); virtual;
  public
    procedure ProcessMessage(aMsg: string);
    constructor Create; virtual;
    destructor Destroy; override;
  end;
{$M-}

  TControllerClass = class of TControllerAbstract;

implementation

constructor TModelAbstract.Create(aDataObj: TObjectDictionary<string, TObject> = nil);
begin
  FDataObj := aDataObj;
end;

procedure TModelAbstract.Execute(Sender: TObject);
begin
  Start;
  Free;
end;

procedure TControllerAbstract.CallModel<T>(aThreadCount: Integer = 1);
var
  i: Integer;
  Model: TModelAbstract;
  ModelClass: TModelClass;
  Task: ITask;
  TaskData: TTaskData;
begin
  for i := 1 to aThreadCount do
    begin
      ModelClass := T;
      Model := ModelClass.Create(FDataObj);

      Task := TTask.Create(Self, Model.Execute);
      Task.Start;

      TaskData.Task := Task;
      TaskData.Model := Model;

      FTaskDataArr := FTaskDataArr + [TaskData];
    end;
end;

destructor TControllerAbstract.Destroy;
begin
  FDataObj.Free;

  inherited;
end;

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
  FDataObj := TObjectDictionary<string, TObject>.Create([]);
end;

end.
