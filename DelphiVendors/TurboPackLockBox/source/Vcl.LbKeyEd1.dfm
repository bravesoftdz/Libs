object frmSymmetricKey: TfrmSymmetricKey
  Left = 538
  Top = 127
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Generate Symmetric Encryption Key'
  ClientHeight = 269
  ClientWidth = 525
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
  object Label2: TLabel
    Left = 10
    Top = 70
    Width = 80
    Height = 16
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '&Pass Phrase:'
  end
  object Label3: TLabel
    Left = 10
    Top = 160
    Width = 26
    Height = 16
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Key:'
  end
  object Bevel1: TBevel
    Left = 10
    Top = 211
    Width = 501
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
    Left = 190
    Top = 28
    Width = 58
    Height = 16
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Key Type'
  end
  object btnClose: TButton
    Left = 418
    Top = 230
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
  end
  object edtKey: TEdit
    Left = 10
    Top = 180
    Width = 501
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
    TabOrder = 2
    OnChange = rgKeySizeChange
    Items.Strings = (
      '64'
      '128'
      '192'
      '256')
  end
  object cbxKeyType: TComboBox
    Left = 260
    Top = 23
    Width = 131
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Style = csDropDownList
    TabOrder = 3
    OnChange = rgKeyTypeChange
    Items.Strings = (
      'Random'
      'Text'
      'Text (Case Sensitive)')
  end
  object btnGenerate: TButton
    Left = 420
    Top = 20
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Generate'
    TabOrder = 4
    OnClick = btnGenerateClick
  end
  object edtPassphrase: TEdit
    Left = 10
    Top = 90
    Width = 501
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 5
    OnChange = edtPassphraseChange
  end
end
