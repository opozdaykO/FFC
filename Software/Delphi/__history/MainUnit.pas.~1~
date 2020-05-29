unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SPComm, Registry, Vcl.StdCtrls,
  System.StrUtils, GetCoreTempInfoDelphi, Vcl.ExtCtrls, INIFiles;

type
  TForm1 = class(TForm)
    PortSelector: TComboBox;
    Button1: TButton;
    Log: TMemo;
    Button2: TButton;
    TrayIcon1: TTrayIcon;
    Timer1: TTimer;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Timer2: TTimer;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
  private
    procedure PortsUpd;
    function SendString(const Str: AnsiString): Boolean;
    procedure ReceiveData(Sender: TObject; Buffer: PAnsiChar;
      BufferLength: Word);
    procedure Connect(port: string);
    procedure OnMinimize(Sender: TObject);
    procedure Autorun(enable: Boolean);
    function f2c(f: single): single;
    function c2f(c: single): single;
    function GetTemp: single;
  public

  end;

var
  Form1: TForm1;
  ComPort: TComm;
  INI: TINIFile;
  StartFan, StopFan: single;
  FanState, Trigger: Boolean;

implementation

{$R *.dfm}

procedure TForm1.Autorun(enable: Boolean);
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

procedure TForm1.Button1Click(Sender: TObject);
begin
  PortsUpd;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Connect(PortSelector.Text);
end;

function TForm1.c2f(c: single): single;
begin
  result := (c * 9 / 5) + 32
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.Checked then
    Autorun(true)
  else
    Autorun(false);
end;

procedure TForm1.Connect(port: string);
begin
  if (not ComPort.PortOpen) then
  begin
    if port = '' then
      Log.Lines.Add('Error:Serial port not exist.')
      // MessageBox(0,'Error:Serial port not exist.','ERROR!',MB_OK or MB_ICONERROR)
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

procedure TForm1.Edit1Change(Sender: TObject);
begin
  StartFan := StrToFloat(Edit1.Text);
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin
  StartFan := StrToFloat(Edit1.Text);
end;

function TForm1.f2c(f: single): single;
begin
  result := (f - 32) * 5 / 9
end;

procedure TForm1.FormCreate(Sender: TObject);
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
  CheckBox1.Checked := INI.ReadBool('Soft', 'Tray', false);
  CheckBox2.Checked := INI.ReadBool('Soft', 'Autorun', false);
  Edit1.Text := FloatToStrF(StartFan, ffFixed, 7, 0);
  Edit2.Text := FloatToStrF(StopFan, ffFixed, 7, 0);
  ComPort := TComm.Create(Self);
  ComPort.OnReceiveData := ReceiveData;
  Log.Clear;
  Log.Lines.Add('Note: Max temperature = ' + Edit1.Text + 'C');
  Log.Lines.Add('Note: Min temperature = ' + Edit2.Text + 'C');
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
  if CheckBox1.Checked then
  begin
    AlphaBlend := true;
    AlphaBlendValue := 0;
    Timer1.Enabled := true;
  end;
  if ComPort.PortOpen then
    SendString('2');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  INI.WriteString('Device', 'Port', PortSelector.Text);
  StopFan := StrToFloat(Edit2.Text);
  StartFan := StrToFloat(Edit1.Text);
  INI.WriteFloat('Temperature', 'StartFan', StartFan);
  INI.WriteFloat('Temperature', 'StopFan', StopFan);
  INI.WriteBool('Soft', 'Tray', CheckBox1.Checked);
  INI.WriteBool('Soft', 'Autorun', CheckBox2.Checked);
  INI.Free;
  ComPort.StopComm;
  ComPort.Free;
end;

function TForm1.GetTemp: single;
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
    // Log.Lines.Add('Note: Temperature ' + FloatToStrF((Temp / (Data.uiCoreCnt)),
    // ffFixed, 7, 0) + 'C');
  end;
end;

procedure TForm1.OnMinimize(Sender: TObject);
begin
  Hide();
  WindowState := wsMinimized;
  TrayIcon1.Visible := true;
end;

procedure TForm1.PortsUpd;
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

procedure TForm1.ReceiveData(Sender: TObject; Buffer: PAnsiChar;
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

function TForm1.SendString(const Str: AnsiString): Boolean;
begin
  result := ComPort.WriteCommData(PAnsiChar(Str), Length(Str));
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  { var
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
    Log.Lines.Add('Note: Temperature ' + FloatToStrF((Temp / (Data.uiCoreCnt)),
    ffFixed, 7, 0) + 'C');
    end; }
  Application.Minimize;
  AlphaBlend := false;
  Timer1.Enabled := false;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
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

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  TrayIcon1.Visible := false;
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

end.
