program OctalynTelegram;

{$R *.dres}

uses
  Vcl.Forms,
  OctaTeleg in 'OctaTeleg.pas' {Form3},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Light');
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
