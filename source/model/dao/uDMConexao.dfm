object DMConexao: TDMConexao
  OldCreateOrder = False
  Height = 151
  Width = 197
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 41
    Top = 79
  end
  object Transaction: TFDTransaction
    Options.AutoStop = False
    Options.DisconnectAction = xdRollback
    Connection = FDConnection
    Left = 128
    Top = 24
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=C:\BD\MEGASYS.FDB'
      'Password=masterkey'
      'Port=3050'
      'Server=127.0.0.1'
      'User_Name=SYSDBA'
      'Protocol=TCPIP'
      'DriverID=FB')
    LoginPrompt = False
    Transaction = Transaction
    UpdateTransaction = Transaction
    Left = 40
    Top = 24
  end
  object DriverLink: TFDPhysFBDriverLink
    Left = 127
    Top = 79
  end
end
