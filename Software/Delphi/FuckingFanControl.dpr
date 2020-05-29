program FuckingFanControl;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {Form1},
  GetCoreTempInfoDelphi in 'GetCoreTempInfoDelphi.pas',
  SPComm in 'SPComm.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
