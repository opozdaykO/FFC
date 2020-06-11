object FFCForm: TFFCForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'FFC'
  ClientHeight = 333
  ClientWidth = 201
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
  object Image1: TImage
    Left = 8
    Top = 139
    Width = 185
    Height = 185
    Center = True
    Stretch = True
    OnClick = Image1Click
  end
  object temper: TLabel
    Left = 66
    Top = 115
    Width = 69
    Height = 13
    Alignment = taCenter
    AutoSize = False
    BiDiMode = bdLeftToRight
    Caption = 'temper'
    EllipsisPosition = epEndEllipsis
    ParentBiDiMode = False
  end
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
  object CnBtn: TButton
    Left = 8
    Top = 35
    Width = 185
    Height = 25
    Caption = 'Connect'
    TabOrder = 2
    OnClick = CnBtnClick
  end
  object TrayCB: TCheckBox
    Left = 8
    Top = 66
    Width = 112
    Height = 17
    Caption = #1047#1072#1087#1091#1089#1082#1072#1090#1100' '#1074' '#1090#1088#1077#1077
    TabOrder = 3
  end
  object AutoRunCB: TCheckBox
    Left = 8
    Top = 89
    Width = 82
    Height = 17
    Caption = #1040#1074#1090#1086#1079#1072#1087#1091#1089#1082'.'
    TabOrder = 4
    OnClick = AutoRunCBClick
  end
  object MaxEdit: TEdit
    Left = 8
    Top = 112
    Width = 52
    Height = 21
    NumbersOnly = True
    TabOrder = 5
    Text = 'StartFanTemp'
    OnChange = MaxEditChange
  end
  object MinEdit: TEdit
    Left = 141
    Top = 112
    Width = 52
    Height = 21
    TabOrder = 6
    Text = 'StopFanTemp'
    OnChange = MinEditChange
  end
  object TrayIcon1: TTrayIcon
    PopupMenu = PopupMenu1
    OnClick = TrayIcon1Click
    OnDblClick = TrayIcon1DblClick
    Left = 72
    Top = 168
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer1Timer
    Left = 112
    Top = 216
  end
  object Timer2: TTimer
    OnTimer = Timer2Timer
    Left = 96
    Top = 256
  end
  object PopupMenu1: TPopupMenu
    Left = 64
    Top = 264
    object N1: TMenuItem
      Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1086#1093#1083#1072#1078#1076#1077#1085#1080#1077'.'
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = #1042#1099#1082#1083#1102#1095#1080#1090#1100' '#1086#1093#1083#1072#1078#1076#1077#1085#1080#1077'.'
      OnClick = N2Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object N4: TMenuItem
      Caption = #1054#1090#1082#1088#1099#1090#1100'.'
      OnClick = N4Click
    end
    object N5: TMenuItem
      Caption = #1042#1099#1093#1086#1076'.'
      OnClick = N5Click
    end
  end
end
