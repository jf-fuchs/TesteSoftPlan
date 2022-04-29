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
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    781
    446)
  PixelsPerInch = 96
  TextHeight = 13
  object gdLog: TDBGrid
    Left = 8
    Top = 96
    Width = 765
    Height = 342
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = dsLog
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
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
  object btnIniciar: TBitBtn
    Left = 8
    Top = 65
    Width = 161
    Height = 25
    Caption = 'Inicar Download'
    TabOrder = 1
    OnClick = btnIniciarClick
  end
  object pgProgresso: TProgressBar
    Left = 296
    Top = 73
    Width = 477
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    MarqueeInterval = 1
    Step = 1
    TabOrder = 2
  end
  object btnAdicionar: TBitBtn
    Left = 8
    Top = 8
    Width = 161
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
    TabOrder = 3
    OnClick = btnAdicionarClick
  end
  object btnRemoverURL: TBitBtn
    Left = 175
    Top = 8
    Width = 161
    Height = 25
    Caption = 'Remover URL'
    TabOrder = 4
    OnClick = btnRemoverURLClick
  end
  object Conexao: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=C:\JFF\Teste\DB\Downloads.db'
      'DateTimeFormat=DateTime')
    FormatOptions.AssignedValues = [fvFmtDisplayDateTime, fvFmtDisplayDate]
    FormatOptions.FmtDisplayDateTime = 'dd/mm/yyyy HH:MM:SS'
    FormatOptions.FmtDisplayDate = 'dd/mm/yyyy'
    Connected = True
    LoginPrompt = False
    Left = 24
    Top = 256
  end
  object dsLog: TDataSource
    DataSet = CDS
    Left = 200
    Top = 176
  end
  object qLog: TFDQuery
    Connection = Conexao
    Transaction = Transacao
    SQL.Strings = (
      'SELECT 0 AS PERC, CODIGO, URL, DATAINICIO, DATAFIM'
      'FROM LOGDOWNLOAD')
    Left = 104
    Top = 176
    object qLogPERC: TLargeintField
      AutoGenerateValue = arDefault
      FieldName = 'PERC'
      Origin = 'PERC'
      ProviderFlags = []
    end
    object qLogCODIGO: TFDAutoIncField
      FieldName = 'CODIGO'
      Origin = 'CODIGO'
      ProviderFlags = [pfInWhere, pfInKey]
    end
    object qLogURL: TWideStringField
      FieldName = 'URL'
      Origin = 'URL'
      Required = True
      Size = 200
    end
    object qLogDATAINICIO: TDateTimeField
      FieldName = 'DATAINICIO'
      Origin = 'DATAINICIO'
      Required = True
      DisplayFormat = 'dd/mm/yyyy HH:MM:SS'
    end
    object qLogDATAFIM: TDateTimeField
      FieldName = 'DATAFIM'
      Origin = 'DATAFIM'
      Required = True
      DisplayFormat = 'dd/mm/yyyy HH:MM:SS'
    end
  end
  object Transacao: TFDTransaction
    Connection = Conexao
    Left = 72
    Top = 256
  end
  object DSP: TDataSetProvider
    DataSet = qLog
    Left = 136
    Top = 176
  end
  object CDS: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DSP'
    Left = 168
    Top = 176
    object CDSPERC: TLargeintField
      Alignment = taCenter
      FieldName = 'PERC'
    end
    object CDSURL: TWideStringField
      FieldName = 'URL'
      Required = True
      Size = 200
    end
    object CDSDATAINICIO: TDateTimeField
      FieldName = 'DATAINICIO'
      Required = True
      OnGetText = CDSDATAFIMGetText
    end
    object CDSDATAFIM: TDateTimeField
      FieldName = 'DATAFIM'
      Required = True
      OnGetText = CDSDATAFIMGetText
    end
    object CDSCODIGO: TAutoIncField
      FieldName = 'CODIGO'
      ReadOnly = True
    end
  end
end
