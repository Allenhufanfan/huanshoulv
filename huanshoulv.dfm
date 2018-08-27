object frm_hsl: Tfrm_hsl
  Left = 293
  Top = 165
  Caption = #25442#25163#29575#36873#32929
  ClientHeight = 568
  ClientWidth = 806
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 806
    Height = 270
    Align = alTop
    TabOrder = 0
    object Button1: TButton
      Left = 16
      Top = 210
      Width = 100
      Height = 26
      Caption = #28165#31354'memo'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Panel5: TPanel
      Left = 131
      Top = 1
      Width = 674
      Height = 268
      Align = alRight
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Panel5'
      TabOrder = 1
      object lv_block: TListView
        Left = 250
        Top = 1
        Width = 423
        Height = 266
        Align = alClient
        Columns = <>
        ReadOnly = True
        RowSelect = True
        PopupMenu = pp_stock
        TabOrder = 0
      end
      object lv_theme: TListView
        Left = 1
        Top = 1
        Width = 249
        Height = 266
        Align = alLeft
        Columns = <>
        ReadOnly = True
        RowSelect = True
        TabOrder = 1
        OnClick = lv_themeClick
      end
    end
    object Button2: TButton
      Left = 16
      Top = 239
      Width = 100
      Height = 25
      Caption = #26174#31034'memo'
      TabOrder = 2
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 16
      Top = 179
      Width = 100
      Height = 25
      Caption = #20851#38381#23450#26102#21047#26032
      TabOrder = 3
      OnClick = Button3Click
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 270
    Width = 806
    Height = 191
    Align = alClient
    TabOrder = 1
    object Panel4: TPanel
      Left = 131
      Top = 1
      Width = 674
      Height = 189
      Align = alRight
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      object GroupBox1: TGroupBox
        Left = 1
        Top = 1
        Width = 672
        Height = 187
        Align = alClient
        TabOrder = 0
        object lv_other: TListView
          Left = 2
          Top = 15
          Width = 668
          Height = 170
          Align = alClient
          Columns = <>
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 461
    Width = 806
    Height = 107
    Align = alBottom
    Caption = 'Panel1'
    TabOrder = 2
    Visible = False
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 804
      Height = 105
      Align = alClient
      TabOrder = 0
    end
  end
  object http_hsl: TIdHTTP
    IOHandler = IdSSLIOHandlerSocketOpenSSL
    AllowCookies = False
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 45
    Top = 50
  end
  object IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Method = sslvSSLv23
    SSLOptions.SSLVersions = [sslvSSLv2, sslvSSLv3, sslvTLSv1]
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 43
    Top = 110
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 20000
    OnTimer = Timer1Timer
    Left = 196
    Top = 297
  end
  object pp_link: TPopupMenu
    Left = 76
    Top = 70
    object N1: TMenuItem
      Caption = #27983#35272#22120#25171#24320#38142#25509
      OnClick = N1Click
    end
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 120000
    OnTimer = Timer2Timer
    Left = 398
    Top = 289
  end
  object pp_stock: TPopupMenu
    Left = 78
    Top = 124
    object MenuItem1: TMenuItem
      Caption = #38634#29699#32593#25171#24320
      OnClick = MenuItem1Click
    end
  end
end
