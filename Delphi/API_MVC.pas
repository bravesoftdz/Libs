unit API_MVC;

interface

uses
  System.Generics.Collections,
  System.Threading;

type
  TModelAbstract = class;

  TProc = procedure of object;
  TViewMessageProc = procedure(const aMsg: string) of object;
  TModelMessageProc = procedure(const aMsg: string; aModel: TModelAbstract) of object;
  TModelInitProc = procedure(aModel: TModelAbstract) of object;

  TModelAbstract = class abstract
  private
    FOnModelMessage: TModelMessageProc;
    procedure Execute(Sender: TObject);
  protected
    FDataObj: TObjectDictionary<string, TObject>;
    FDataPointer: TDictionary<string, Pointer>;
    procedure SendMessage(aMsg: string);
  public
    /// <summary>
    /// Override this procedure as point of enter to Model work.
    /// </summary>
    procedure Start; virtual; abstract;
    constructor Create(aDataObj: TObjectDictionary<string, TObject>;
      aDataPointer: TDictionary<string, Pointer>);
  end;

  TModelClass = class of TModelAbstract;

  IViewAbstract = interface
    procedure InitMVC;
    procedure SendMessage(aMsg: string);
  end;

  TTaskData = record
    Model: TModelAbstract;
    Task: ITask;
  end;

{$M+}
  TControllerAbstract = class abstract
  private
    FTaskDataArr: TArray<TTaskData>;
    procedure ModelListener(const aMsg: string; aModel: TModelAbstract);
    procedure ModelInit<T: TModelAbstract>(aModel: T);
  protected
    FDataObj: TObjectDictionary<string, TObject>;
    FDataPointer: TDictionary<string, Pointer>;
    procedure CallModel<T: TModelAbstract>(aThreadCount: Integer = 1);
    procedure PerfomMessage(const aMsg: string); virtual;
  public
    procedure ProcessMessage(const aMsg: string);
    constructor Create; virtual;
    destructor Destroy; override;
  end;
{$M-}

  TControllerClass = class of TControllerAbstract;

implementation

uses
  System.SysUtils;

procedure TControllerAbstract.ModelInit<T>(aModel: T);
var
  ModelInitProc: TModelInitProc;
  ModelInitProcName: string;
begin
  ModelInitProcName := Format('On%sInit',[aModel.ClassName.Substring(1)]);

  TMethod(ModelInitProc).Code := Self.MethodAddress(ModelInitProcName);
  TMethod(ModelInitProc).Data := Self;

  if Assigned(ModelInitProc) then
    ModelInitProc(aModel);
end;

procedure TModelAbstract.SendMessage(aMsg: string);
begin
  FOnModelMessage(aMsg, Self);
end;

procedure TControllerAbstract.ModelListener(const aMsg: string; aModel: TModelAbstract);
var
  ModelMessageProc: TModelMessageProc;
begin
  TMethod(ModelMessageProc).Code := Self.MethodAddress(aMsg);
  TMethod(ModelMessageProc).Data := Self;

  if Assigned(ModelMessageProc) then
    ModelMessageProc(aMsg, aModel);
end;

constructor TModelAbstract.Create(aDataObj: TObjectDictionary<string, TObject>;
  aDataPointer: TDictionary<string, Pointer>);
begin
  FDataObj := aDataObj;
  FDataPointer := aDataPointer;
end;

procedure TModelAbstract.Execute(Sender: TObject);
begin
  Start;
  SendMessage(Format('On%sEnd',[Self.ClassName.Substring(1)]));
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
      Model := ModelClass.Create(FDataObj, FDataPointer);
      Model.FOnModelMessage := ModelListener;

      ModelInit<T>(Model);

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
  FDataPointer.Free;

  inherited;
end;

procedure TControllerAbstract.PerfomMessage(const aMsg: string);
begin
end;

procedure TControllerAbstract.ProcessMessage(const aMsg: string);
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
  FDataPointer := TDictionary<string, Pointer>.Create;
end;

end.
