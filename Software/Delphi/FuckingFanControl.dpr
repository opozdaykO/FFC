program FuckingFanControl;



{$R *.dres}

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {FFCForm},
  GetCoreTempInfoDelphi in 'GetCoreTempInfoDelphi.pas',
  SPComm in 'SPComm.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 Dark');
  Application.CreateForm(TFFCForm, FFCForm);
  Application.Run;

end.
