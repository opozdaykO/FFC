object FFCForm: TFFCForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Fucking Fan Control'
  ClientHeight = 276
  ClientWidth = 585
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PortSelector: TComboBox
    Left = 8
    Top = 8
    Width = 145
    Height = 21
    TabOrder = 0
    Text = 'PortSelector'
  end
  object PrtUpd: TButton
    Left = 159
    Top = 6
    Width = 34
    Height = 25
    Caption = 'UPD'
    TabOrder = 1
    OnClick = PrtUpdClick
  end
  object Log: TMemo
    Left = 8
    Top = 37
    Width = 569
    Height = 231
    Lines.Strings = (
      'Log')
    TabOrder = 2
  end
  object CnBtn: TButton
    Left = 199
    Top = 6
    Width = 58
    Height = 25
    Caption = 'Connect'
    TabOrder = 3
    OnClick = CnBtnClick
  end
  object TrayCB: TCheckBox
    Left = 263
    Top = 8
    Width = 112
    Height = 17
    Caption = #1047#1072#1087#1091#1089#1082#1072#1090#1100' '#1074' '#1090#1088#1077#1077
    TabOrder = 4
  end
  object AutoRunCB: TCheckBox
    Left = 381
    Top = 8
    Width = 82
    Height = 17
    Caption = #1040#1074#1090#1086#1079#1072#1087#1091#1089#1082'.'
    TabOrder = 5
    OnClick = AutoRunCBClick
  end
  object MaxEdit: TEdit
    Left = 469
    Top = 8
    Width = 52
    Height = 21
    NumbersOnly = True
    TabOrder = 6
    Text = 'StartFanTemp'
    OnChange = MaxEditChange
  end
  object MinEdit: TEdit
    Left = 525
    Top = 8
    Width = 52
    Height = 21
    TabOrder = 7
    Text = 'StopFanTemp'
    OnChange = MinEditChange
  end
  object TrayIcon1: TTrayIcon
    OnDblClick = TrayIcon1DblClick
    Left = 552
    Top = 240
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer1Timer
    Left = 512
    Top = 240
  end
  object Timer2: TTimer
    OnTimer = Timer2Timer
    Left = 480
    Top = 240
  end
end
