unit API_MVC;

interface

type
  TModelAbstract = class abstract
  end;

  IViewAbstract = interface
    procedure InitMVC;
    procedure SendMessage(aMsg: string);
  end;

  TControllerAbstract = class abstract
  end;

implementation

end.
