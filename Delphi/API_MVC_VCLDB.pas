unit API_MVC_VCLDB;

interface

uses
  API_MVC_DB,
  API_MVC_VCL;

type
  TControllerVCLDB = class(TControllerDB)
  private
    FVCL: TVCLSupport;
  public
    constructor Create; override;
    destructor Destroy; override;
    property VCL: TVCLSupport read FVCL;
  end;

implementation

destructor TControllerVCLDB.Destroy;
begin
  FVCL.Free;

  inherited;
end;

constructor TControllerVCLDB.Create;
begin
  inherited;

  FVCL := TVCLSupport.Create(Self);
end;

end.
