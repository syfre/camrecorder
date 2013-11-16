object ConfigForm: TConfigForm
  Left = 195
  Top = 108
  Caption = 'Configuration'
  ClientHeight = 457
  ClientWidth = 586
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 586
    Height = 415
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 5
    ParentColor = True
    TabOrder = 0
    ExplicitWidth = 576
    ExplicitHeight = 406
    object PageControl1: TPageControl
      Left = 5
      Top = 5
      Width = 576
      Height = 405
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      ActivePage = tsSource
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 566
      ExplicitHeight = 396
      object tsSource: TTabSheet
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Sources'
        ExplicitWidth = 558
        ExplicitHeight = 365
        object Panel3: TPanel
          Left = 0
          Top = 0
          Width = 568
          Height = 177
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          ExplicitWidth = 558
          object Label3: TLabel
            Left = 10
            Top = 118
            Width = 67
            Height = 16
            Caption = 'Video size :'
          end
          object Label2: TLabel
            Left = 10
            Top = 66
            Width = 83
            Height = 16
            Caption = 'Video format :'
          end
          object Label1: TLabel
            Left = 10
            Top = 10
            Width = 128
            Height = 16
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Caption = 'Video capture device :'
          end
          object cbVideoSizes: TComboBox
            Left = 10
            Top = 140
            Width = 305
            Height = 24
            Style = csDropDownList
            TabOrder = 0
            OnChange = cbVideoSizesChange
            OnDropDown = cbVideoSizesDropDown
          end
          object cbVideoFormats: TComboBox
            Left = 10
            Top = 88
            Width = 305
            Height = 24
            Style = csDropDownList
            TabOrder = 1
            OnDropDown = cbVideoFormatsDropDown
          end
          object cbVideoCapFilters: TComboBox
            Left = 10
            Top = 33
            Width = 305
            Height = 24
            Style = csDropDownList
            TabOrder = 2
            OnChange = cbVideoCapFiltersChange
          end
        end
        object Panel4: TPanel
          Left = 0
          Top = 177
          Width = 568
          Height = 185
          Align = alTop
          TabOrder = 1
          ExplicitWidth = 558
          object Label4: TLabel
            Left = 10
            Top = 6
            Width = 81
            Height = 16
            Caption = 'Audio device :'
          end
          object Label5: TLabel
            Left = 10
            Top = 64
            Width = 83
            Height = 16
            Caption = 'Audio format :'
          end
          object Label6: TLabel
            Left = 10
            Top = 116
            Width = 116
            Height = 16
            Caption = 'Audio input control :'
          end
          object cbAudioCapFIlters: TComboBox
            Left = 10
            Top = 28
            Width = 305
            Height = 24
            Style = csDropDownList
            BiDiMode = bdLeftToRight
            ParentBiDiMode = False
            TabOrder = 0
            OnChange = cbAudioCapFIltersChange
          end
          object cbAudioFormats: TComboBox
            Left = 10
            Top = 86
            Width = 305
            Height = 24
            Style = csDropDownList
            TabOrder = 1
            OnChange = cbAudioFormatsChange
            OnDropDown = cbAudioFormatsDropDown
          end
          object cbAudioInputs: TComboBox
            Left = 10
            Top = 137
            Width = 305
            Height = 24
            Style = csDropDownList
            TabOrder = 2
          end
        end
      end
      object tsPreferences: TTabSheet
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Preferences'
        ExplicitWidth = 558
        ExplicitHeight = 365
        object Panel5: TPanel
          Left = 0
          Top = 0
          Width = 568
          Height = 105
          Align = alTop
          TabOrder = 0
          DesignSize = (
            568
            105)
          object Label7: TLabel
            Left = 16
            Top = 8
            Width = 109
            Height = 16
            Caption = 'Destination folder :'
          end
          object btnDestFolder: TSpeedButton
            Left = 530
            Top = 30
            Width = 23
            Height = 22
            Anchors = [akTop, akRight]
            Caption = '...'
            OnClick = btnDestFolderClick
            ExplicitLeft = 520
          end
          object edtDestFolder: TEdit
            Left = 16
            Top = 30
            Width = 499
            Height = 24
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            ExplicitWidth = 489
          end
          object chkCaptureActive: TCheckBox
            Left = 16
            Top = 72
            Width = 121
            Height = 17
            Caption = 'Capture to file '
            TabOrder = 1
          end
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 415
    Width = 586
    Height = 42
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    ExplicitTop = 406
    ExplicitWidth = 576
    object OKBtn: TButton
      Left = 230
      Top = 2
      Width = 92
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = OKBtnClick
    end
    object CancelBtn: TButton
      Left = 329
      Top = 2
      Width = 92
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object HelpBtn: TButton
      Left = 427
      Top = 2
      Width = 92
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = '&Help'
      TabOrder = 2
    end
  end
  object VideoSourceFilter: TFilter
    BaseFilter.data = {00000000}
    Left = 16
    Top = 416
  end
  object CaptureGraph: TFilterGraph
    GraphEdit = False
    LinearVolume = True
    Left = 56
    Top = 416
  end
  object AudioSourceFilter: TFilter
    BaseFilter.data = {00000000}
    Left = 104
    Top = 408
  end
end
