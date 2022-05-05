object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 184
  Width = 165
  object qLog: TFDQuery
    Connection = Conexao
    Transaction = Transacao
    SQL.Strings = (
      'SELECT 0 AS PERC, CODIGO, URL, DATAINICIO, DATAFIM'
      'FROM LOGDOWNLOAD')
    Left = 16
    Top = 80
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
      ReadOnly = True
    end
    object qLogURL: TWideStringField
      FieldName = 'URL'
      Origin = 'URL'
      Required = True
      Size = 600
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
  object DSP: TDataSetProvider
    DataSet = qLog
    Left = 48
    Top = 80
  end
  object CDS: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DSP'
    Left = 80
    Top = 80
    object CDSPERC: TLargeintField
      Alignment = taCenter
      FieldName = 'PERC'
    end
    object CDSURL: TWideStringField
      FieldName = 'URL'
      Required = True
      Size = 600
    end
    object CDSDATAINICIO: TDateTimeField
      FieldName = 'DATAINICIO'
      Required = True
      OnGetText = CDSDATAINICIOGetText
    end
    object CDSDATAFIM: TDateTimeField
      FieldName = 'DATAFIM'
      Required = True
      OnGetText = CDSDATAINICIOGetText
    end
    object CDSCODIGO: TAutoIncField
      FieldName = 'CODIGO'
      ReadOnly = True
    end
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
    Left = 16
    Top = 16
  end
  object Transacao: TFDTransaction
    Connection = Conexao
    Left = 72
    Top = 16
  end
end
