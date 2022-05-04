object FrmLogDownloads: TFrmLogDownloads
  Left = 0
  Top = 0
  Caption = 'Log Downloads'
  ClientHeight = 446
  ClientWidth = 781
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  DesignSize = (
    781
    446)
  PixelsPerInch = 96
  TextHeight = 13
  object gdLog: TDBGrid
    Left = 121
    Top = 4
    Width = 655
    Height = 438
    Anchors = [akLeft, akTop, akRight, akBottom]
    Ctl3D = True
    DataSource = dsLog
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ParentCtl3D = False
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDrawColumnCell = gdLogDrawColumnCell
    Columns = <
      item
        Expanded = False
        FieldName = 'PERC'
        Title.Alignment = taCenter
        Title.Caption = '%'
        Width = 104
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'URL'
        Width = 399
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DATAINICIO'
        Title.Caption = 'In'#237'cio'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DATAFIM'
        Title.Caption = 'Fim'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'CODIGO'
        Visible = False
      end>
  end
  object Panel1: TPanel
    Left = 3
    Top = 4
    Width = 114
    Height = 438
    Anchors = [akLeft, akTop, akBottom]
    BevelInner = bvLowered
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
    object btnAdicionar: TBitBtn
      Left = 5
      Top = 5
      Width = 105
      Height = 25
      Caption = 'Adicionar URL'
      Glyph.Data = {
        06030000424D060300000000000036000000280000000F0000000F0000000100
        180000000000D002000000000000000000000000000000000000C9AEFFC9AEFF
        C9AEFFC9AEFFC9AEFF000000000000000000000000000000C9AEFFC9AEFFC9AE
        FFC9AEFFC9AEFF000000C9AEFFC9AEFFC9AEFFC9AEFFC9AEFF00000000000000
        0000000000000000C9AEFFC9AEFFC9AEFFC9AEFFC9AEFF000000C9AEFFC9AEFF
        C9AEFFC9AEFFC9AEFF000000000000000000000000000000C9AEFFC9AEFFC9AE
        FFC9AEFFC9AEFF000000C9AEFFC9AEFFC9AEFFC9AEFFC9AEFF00000000000000
        0000000000000000C9AEFFC9AEFFC9AEFFC9AEFFC9AEFF000000C9AEFFC9AEFF
        C9AEFFC9AEFFC9AEFF000000000000000000000000000000C9AEFFC9AEFFC9AE
        FFC9AEFFC9AEFF00000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000C9AEFFC9AEFF
        C9AEFFC9AEFFC9AEFF000000000000000000000000000000C9AEFFC9AEFFC9AE
        FFC9AEFFC9AEFF000000C9AEFFC9AEFFC9AEFFC9AEFFC9AEFF00000000000000
        0000000000000000C9AEFFC9AEFFC9AEFFC9AEFFC9AEFF000000C9AEFFC9AEFF
        C9AEFFC9AEFFC9AEFF000000000000000000000000000000C9AEFFC9AEFFC9AE
        FFC9AEFFC9AEFF000000C9AEFFC9AEFFC9AEFFC9AEFFC9AEFF00000000000000
        0000000000000000C9AEFFC9AEFFC9AEFFC9AEFFC9AEFF000000C9AEFFC9AEFF
        C9AEFFC9AEFFC9AEFF000000000000000000000000000000C9AEFFC9AEFFC9AE
        FFC9AEFFC9AEFF000000}
      TabOrder = 0
      OnClick = btnAdicionarClick
    end
    object btnRemoverURL: TBitBtn
      Left = 5
      Top = 32
      Width = 105
      Height = 25
      Caption = 'Remover URL'
      TabOrder = 1
      OnClick = btnRemoverURLClick
    end
    object btnIniciar: TBitBtn
      Left = 5
      Top = 59
      Width = 105
      Height = 25
      Caption = 'Iniciar Download'
      TabOrder = 2
      OnClick = btnIniciarClick
    end
    object btnIniciarTodos: TBitBtn
      Left = 5
      Top = 86
      Width = 105
      Height = 25
      Caption = 'Iniciar Todos'
      TabOrder = 3
      OnClick = btnIniciarTodosClick
    end
    object btnInterromper: TBitBtn
      Left = 5
      Top = 113
      Width = 105
      Height = 25
      Caption = 'Interromper'
      TabOrder = 4
    end
  end
  object dsLog: TDataSource
    DataSet = DM.CDS
    Left = 152
    Top = 48
  end
end
