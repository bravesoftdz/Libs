unit API_MVC_FMXDB;

interface

uses
  API_MVC_DB,
  API_MVC_FMX;

type
  TControllerFMXDB = class(TControllerDB)
  private
    FFMX: TFMXSupport;
  public
    constructor Create; override;
    destructor Destroy; override;
    property FMX: TFMXSupport read FFMX;
  end;

implementation

destructor TControllerFMXDB.Destroy;
begin
  FFMX.Free;

  inherited;
end;

constructor TControllerFMXDB.Create;
begin
  inherited;

  FFMX := TFMXSupport.Create(Self);
end;

end.
