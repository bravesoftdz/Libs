object frmRSAKeys: TfrmRSAKeys
  Left = 332
  Top = 305
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Generate RSA Public/Private Key Pair'
  ClientHeight = 323
  ClientWidth = 643
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Label4: TLabel
    Left = 10
    Top = 70
    Width = 80
    Height = 16
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Key Modulus:'
  end
  object Label5: TLabel
    Left = 10
    Top = 128
    Width = 125
    Height = 16
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Public Key Exponent:'
  end
  object Label6: TLabel
    Left = 10
    Top = 185
    Width = 130
    Height = 16
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Private Key Exponent:'
  end
  object Bevel1: TBevel
    Left = 10
    Top = 241
    Width = 621
    Height = 12
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Shape = bsBottomLine
  end
  object Label9: TLabel
    Left = 10
    Top = 28
    Width = 52
    Height = 16
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Key Size'
  end
  object Label1: TLabel
    Left = 200
    Top = 38
    Width = 54
    Height = 16
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Iterations'
  end
  object Label8: TLabel
    Left = 200
    Top = 20
    Width = 59
    Height = 16
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Prime test'
  end
  object btnClose: TButton
    Left = 538
    Top = 260
    Width = 93
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Close'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = btnCloseClick
  end
  object edtModulus: TEdit
    Left = 10
    Top = 90
    Width = 621
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Ctl3D = True
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 1
  end
  object edtPublicExponent: TEdit
    Left = 10
    Top = 148
    Width = 621
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Ctl3D = True
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 2
  end
  object edtPrivateExponent: TEdit
    Left = 10
    Top = 205
    Width = 621
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Ctl3D = True
    ParentColor = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 3
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 304
    Width = 643
    Height = 19
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Panels = <>
    SimplePanel = True
  end
  object cbxKeySize: TComboBox
    Left = 70
    Top = 23
    Width = 101
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Style = csDropDownList
    TabOrder = 5
    Items.Strings = (
      '128'
      '256'
      '512'
      '768'
      '1024')
  end
  object edtIterations: TEdit
    Left = 270
    Top = 23
    Width = 41
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 6
    Text = '20'
  end
  object btnGenerate: TButton
    Left = 329
    Top = 20
    Width = 112
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Generate Keys'
    TabOrder = 7
    OnClick = btnGenRSAKeysClick
  end
  object btnClear: TButton
    Left = 459
    Top = 20
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Clear'
    TabOrder = 8
    OnClick = btnClearClick
  end
end
