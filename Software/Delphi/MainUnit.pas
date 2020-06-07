unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SPComm, Registry, Vcl.StdCtrls,
  System.StrUtils, GetCoreTempInfoDelphi, Vcl.ExtCtrls, INIFiles;

type
  TFFCForm = class(TForm)
    PortSelector: TComboBox;
    PrtUpd: TButton;
    Log: TMemo;
    CnBtn: TButton;
    TrayIcon1: TTrayIcon;
    Timer1: TTimer;
    TrayCB: TCheckBox;
    AutoRunCB: TCheckBox;
    Timer2: TTimer;
    MaxEdit: TEdit;
    MinEdit: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PrtUpdClick(Sender: TObject);
    procedure CnBtnClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure AutoRunCBClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure MaxEditChange(Sender: TObject);
    procedure MinEditChange(Sender: TObject);
  private
    procedure PortsUpd;
    function SendString(const Str: AnsiString): Boolean;
    procedure ReceiveData(Sender: TObject; Buffer: PAnsiChar;
      BufferLength: Word);
    procedure Connect(port: string);
    procedure OnMinimize(Sender: TObject);
    procedure Autorun(enable: Boolean);
    function f2c(f: single): single;
    // function c2f(c: single): single;
    function GetTemp: single;
  public

  end;

var
  FFCForm: TFFCForm;
  ComPort: TComm;
  INI: TINIFile;
  StartFan, StopFan: single;
  FanState, Trigger: Boolean;

implementation

{$R *.dfm}

procedure TFFCForm.Autorun(enable: Boolean);
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  R.RootKey := HKEY_CURRENT_USER;
  R.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', true);
  if enable then
    R.WriteString('FFC', Application.ExeName)
  else
    R.DeleteValue('FFC');
  R.Free;
end;

procedure TFFCForm.PrtUpdClick(Sender: TObject);
begin
  PortsUpd;
end;

procedure TFFCForm.CnBtnClick(Sender: TObject);
begin
  Connect(PortSelector.Text);
end;

{ function TForm1.c2f(c: single): single;
  begin
  result := (c * 9 / 5) + 32
  end; }

procedure TFFCForm.AutoRunCBClick(Sender: TObject);
begin
  if AutoRunCB.Checked then
    Autorun(true)
  else
    Autorun(false);
end;

procedure TFFCForm.Connect(port: string);
begin
  if (not ComPort.PortOpen) then
  begin
    if port = '' then
      Log.Lines.Add('Error: Serial port not exist.')
    else
    begin
      ComPort.CommName := port;
      ComPort.StartComm;
      if ComPort.PortOpen then
      begin
        Log.Lines.Add('Note: Connected to serial port.');
      end
      else
      begin
        Log.Lines.Add('Error: Serial port connect failed.');
      end;
    end;
  end
  else
  begin
    ComPort.StopComm;
    if (not ComPort.PortOpen) then
    begin
      Connect(port);
    end
    else
      Log.Lines.Add('Error: Serial port disconnect failed.');
  end;
end;

procedure TFFCForm.MaxEditChange(Sender: TObject);
begin
  StartFan := StrToFloat(MaxEdit.Text);
end;

procedure TFFCForm.MinEditChange(Sender: TObject);
begin
  StopFan := StrToFloat(MinEdit.Text);
end;

function TFFCForm.f2c(f: single): single;
begin
  result := (f - 32) * 5 / 9
end;

procedure TFFCForm.FormCreate(Sender: TObject);
var
  PortFromIni: string;
  I: integer;
  detect: Boolean;
begin
  detect := false;
  FanState := false;
  Trigger := false;
  Application.OnMinimize := OnMinimize;
  INI := TINIFile.Create(ExtractFilePath(Application.ExeName) + 'settings.ini');
  PortFromIni := INI.ReadString('Device', 'Port', '');
  StartFan := INI.ReadFloat('Temperature', 'StartFan', 50);
  StopFan := INI.ReadFloat('Temperature', 'StopFan', 45);
  TrayCB.Checked := INI.ReadBool('Soft', 'Tray', false);
  AutoRunCB.Checked := INI.ReadBool('Soft', 'Autorun', false);
  MaxEdit.Text := FloatToStrF(StartFan, ffFixed, 7, 0);
  MinEdit.Text := FloatToStrF(StopFan, ffFixed, 7, 0);
  ComPort := TComm.Create(Self);
  ComPort.OnReceiveData := ReceiveData;
  Log.Clear;
  Log.Lines.Add('Note: Max temperature = ' + MaxEdit.Text + 'C');
  Log.Lines.Add('Note: Min temperature = ' + MinEdit.Text + 'C');
  PortsUpd;
  if PortFromIni <> '' then
  begin
    for I := 0 to PortSelector.Items.Count - 1 do
      if PortSelector.Items.Strings[I] = PortFromIni then
        detect := true;
    if detect then
    begin
      Log.Lines.Add('Note: String "Port" detected. Port = ' + PortFromIni);
      PortSelector.Text := PortFromIni;
      Connect(PortFromIni);
    end
    else
      Log.Lines.Add('Note: String "Port" undetected.');
  end
  else
    Log.Lines.Add('Note: String "Port" is empty.');
  if TrayCB.Checked then
  begin
    AlphaBlend := true;
    AlphaBlendValue := 0;
    Timer1.Enabled := true;
  end;
  if ComPort.PortOpen then
    SendString('2');
end;

procedure TFFCForm.FormDestroy(Sender: TObject);
begin
  INI.WriteString('Device', 'Port', PortSelector.Text);
  StopFan := StrToFloat(MinEdit.Text);
  StartFan := StrToFloat(MaxEdit.Text);
  INI.WriteFloat('Temperature', 'StartFan', StartFan);
  INI.WriteFloat('Temperature', 'StopFan', StopFan);
  INI.WriteBool('Soft', 'Tray', TrayCB.Checked);
  INI.WriteBool('Soft', 'Autorun', AutoRunCB.Checked);
  INI.Free;
  ComPort.StopComm;
  ComPort.Free;
end;

function TFFCForm.GetTemp: single;
var
  Data: CORE_TEMP_SHARED_DATA;
  I: integer;
  Temp: single;
begin
  if fnGetCoreTempInfo(Data) then
  begin
    for I := 0 to Data.uiCoreCnt - 1 do
    begin
      Temp := Temp + Data.fTemp[I];
    end;
    if Data.ucFahrenheit then
      result := f2c(Temp / Data.uiCoreCnt)
    else
      result := Temp / Data.uiCoreCnt;
  end
  else
  begin
    MessageBox(0, 'Core Temp is not running!', 'Error!', MB_OK or MB_ICONERROR);
    result := -1;
  end;
end;

procedure TFFCForm.OnMinimize(Sender: TObject);
begin
  Hide();
  WindowState := wsMinimized;
  TrayIcon1.Visible := true;
end;

procedure TFFCForm.PortsUpd;
var
  R: TRegistry;
  buf: TStringList;
  I: integer;
begin
  R := TRegistry.Create;
  R.RootKey := HKEY_LOCAL_MACHINE;
  R.OpenKeyReadOnly('hardware\devicemap\serialcomm');
  buf := TStringList.Create;
  R.GetValueNames(buf);
  for I := 0 to buf.Count - 1 do
    buf.Strings[I] := R.ReadString(buf.Strings[I]);
  PortSelector.Clear;
  PortSelector.Items.Assign(buf);
  R.Free;
  buf.Free;
end;

procedure TFFCForm.ReceiveData(Sender: TObject; Buffer: PAnsiChar;
  BufferLength: Word);
begin
  case IndexStr(Buffer, ['0', '1']) of
    0:
      begin
        Log.Lines.Add('Note: Fan is off.');
        FanState := false;
      end;
    1:
      begin
        Log.Lines.Add('Note: Fan is on.');
        FanState := true;
      end
  else
    Log.Text := Log.Text + Buffer;
  end;
end;

function TFFCForm.SendString(const Str: AnsiString): Boolean;
begin
  result := ComPort.WriteCommData(PAnsiChar(Str), Length(Str));
end;

procedure TFFCForm.Timer1Timer(Sender: TObject);
begin
  Application.Minimize;
  AlphaBlend := false;
  Timer1.Enabled := false;
end;

procedure TFFCForm.Timer2Timer(Sender: TObject);
begin
  Log.Lines.Add('Note: Temperature ' + FloatToStrF(GetTemp, ffFixed, 7, 0));
  if Trigger then
  begin
    if GetTemp <= StopFan then
    begin
      if FanState then
        SendString('0');
      Trigger := false;
      Log.Lines.Add('Note: Fan is off by trigger.');
    end;
  end
  else
  begin
    if GetTemp >= StartFan then
    begin
      if not FanState then
        SendString('1');
      Trigger := true;
      Log.Lines.Add('Note: Fan is on by trigger.');
    end;
  end;
end;

procedure TFFCForm.TrayIcon1DblClick(Sender: TObject);
begin
  TrayIcon1.Visible := false;
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

end.
