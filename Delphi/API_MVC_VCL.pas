unit API_MVC_VCL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls,
  API_MVC,
  API_Types;

type
  TViewVCLBase = class(TForm, IViewAbstract)
  private
    { Private declarations }
    FController: TControllerAbstract;
    FControllerClass: TControllerClass;
    FDoNotFreeAfterClose: Boolean;
    FIsMainView: Boolean;
    FOnViewMessage: TViewMessageProc;
    function GetCloseMessage: string;
    procedure FormFree(Sender: TObject; var Action: TCloseAction);
  protected
    function AssignPicFromFile(aImage: TImage; const aPath: string): Boolean;
    function AssignPicFromStream(aImage: TImage; var aMIMEType: TMIMEType; aPictureStream: TStream; aDefType: Boolean = False): Boolean;
    /// <summary>
    /// Override this procedure for assign FControllerClass in the main Application View(Form).
    /// </summary>
    procedure InitMVC(var aControllerClass: TControllerClass); virtual;
    procedure SendMessage(aMsg: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property OnViewMessage: TViewMessageProc read FOnViewMessage write FOnViewMessage;
  end;

  TVCLSupport = class(TPlatformSupport)
  public
    function CreateView<T: TViewVCLBase>(aInstantShow: Boolean = False): T;
  end;

  TControllerVCLBase = class(TControllerAbstract)
  private
    FVCL: TVCLSupport;
  public
    constructor Create; override;
    destructor Destroy; override;
    property VCL: TVCLSupport read FVCL;
  end;

implementation

{$R *.dfm}

uses
  API_Files,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage;

function TViewVCLBase.AssignPicFromStream(aImage: TImage; var aMIMEType: TMIMEType; aPictureStream: TStream; aDefType: Boolean = False): Boolean;
var
  JPEGPicture: TJPEGImage;
  PNGPicture: TPNGImage;
begin
  Result := False;
  if aDefType then
    aMIMEType := mtUnknown;

  if aDefType or
     (aMIMEType = mtJPEG)
  then
    begin
      JPEGPicture := TJPEGImage.Create;
      try
        try
          JPEGPicture.LoadFromStream(aPictureStream);
          JPEGPicture.DIBNeeded;
          aImage.Picture.Assign(JPEGPicture);

          aDefType := False;
          aMIMEType := mtJPEG;
          Result := True;
        except
        end;
      finally
        JPEGPicture.Free;
      end;
    end;

  if aDefType or
     (aMIMEType = mtPNG)
  then
    begin
      PNGPicture := TPNGImage.Create;
      try
        try
          PNGPicture.LoadFromStream(aPictureStream);
          aImage.Picture.Assign(PNGPicture);

          aDefType := False;
          aMIMEType := mtPNG;
          Result := True;
        except
        end;
      finally
        PNGPicture.Free;
      end;
    end;

  if aDefType or
     (aMIMEType = mtBMP)
  then
    begin
      try
        aPictureStream.Seek(0, soFromBeginning);
        aImage.Picture.Bitmap.LoadFromStream(aPictureStream);

        aDefType := False;
        aMIMEType := mtBMP;
        Result := True;
      except
      end;
    end;
end;

function TViewVCLBase.AssignPicFromFile(aImage: TImage; const aPath: string): Boolean;
var
  FileStream: TFileStream;
  MIMEType: TMIMEType;
begin
  FileStream := TFilesEngine.CreateFileStream(aPath);
  try
    MIMEType := TFilesEngine.GetMIMEType(aPath);

    if MIMEType <> mtUnknown then
      Result := AssignPicFromStream(aImage, MIMEType, FileStream);
  finally
    FileStream.Free;
  end;
end;

function TViewVCLBase.GetCloseMessage: string;
begin
  Result := Self.Name + 'Closed';
end;

destructor TControllerVCLBase.Destroy;
begin
  FVCL.Free;

  inherited;
end;

constructor TControllerVCLBase.Create;
begin
  inherited;

  FVCL := TVCLSupport.Create(Self);
end;

procedure TViewVCLBase.InitMVC(var aControllerClass: TControllerClass);
begin
end;

procedure TViewVCLBase.FormFree(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

function TVCLSupport.CreateView<T>(aInstantShow: Boolean = False): T;
begin
  Result := T.Create(nil);
  Result.OnViewMessage := FController.ViewListener;

  if aInstantShow then
    Result.Show;
end;

destructor TViewVCLBase.Destroy;
begin
  SendMessage(Self.Name + 'Closed');

  if FIsMainView then
    FController.Free;

  inherited;
end;

constructor TViewVCLBase.Create(AOwner: TComponent);
begin
  inherited;

  InitMVC(FControllerClass);

  if Assigned(FControllerClass) and not Assigned(FController) then
    begin
      FIsMainView := True;
      FController := FControllerClass.Create;
      FOnViewMessage := FController.ViewListener;
    end;

  if not FDoNotFreeAfterClose then
    OnClose := FormFree;
end;

procedure TViewVCLBase.SendMessage(aMsg: string);
begin
  FOnViewMessage(aMsg);
end;

end.
