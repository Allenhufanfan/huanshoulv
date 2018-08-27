unit huanshoulv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.DateUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  qjson, qxml, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,
  IdSSLOpenSSL, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, Vcl.ComCtrls, Vcl.OleCtrls, Vcl.ExtCtrls, ShellAPI, Vcl.Menus,qworker;

type
  RHeaders = record
    UserAgent: string;
    Connection: string;
    Cookie: string;
    appversion: string;
    deviceId: string;
    mobiledevice: string;
    userid: string;
  end;

type
  Tfrm_hsl = class(TForm)
    http_hsl: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    lv_theme: TListView;
    lv_block: TListView;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    lv_other: TListView;
    Memo1: TMemo;
    Button1: TButton;
    Panel5: TPanel;
    Button2: TButton;
    Timer1: TTimer;
    Button3: TButton;
    pp_link: TPopupMenu;
    N1: TMenuItem;
    Timer2: TTimer;
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    pp_stock: TPopupMenu;
    MenuItem1: TMenuItem;
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lv_themeClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    sHomehost: string;
    sUrl_txt: string;
    // 初始化httpHeaders
    procedure InitHeaders;
    procedure CreateButton;
    // 获取时间戳
    function GetUnixTime: string;
    // Unicode转中文编码
    function UnicodeToChinese(inputstr: string): string;
    // 替换字符
    function Repleacestr(inputstr, key, sSrc: string): string;
    // 按钮事件
    procedure btnclick(Sender: TObject);
    // 更新listview
    procedure Updlistview(sHTML: string; tag: Integer);
    // 概念股详情
    procedure Updlistview_Block(sJson: TQJson; sType: string; FListView: TListView);
    // 初始化列表的列头
    procedure InitLvColumns(sType: string; FListView: TListView);
    // 初始化显示列表
    procedure showlist(AJob: PQJob);
    procedure Updlistview_bullbearindex(sJson: TQJson; sType: string; FListView: TListView);
  end;

var
  frm_hsl: Tfrm_hsl;
  VHeaders: RHeaders;
  hsl_json: TQJson;
  hsl_xml: TQXMLNode;

implementation

{$R *.dfm}

procedure Tfrm_hsl.FormDestroy(Sender: TObject);
begin
  Workers.Clear(Self);
end;

procedure Tfrm_hsl.btnclick(Sender: TObject);
var
  url: string;
  s_HTML: string;
  btnHint: string;
  sTimestamp: string;
  sTag: string;
  i: Integer;
begin
  sTimestamp := GetUnixTime;
  btnHint := (Sender as TButton).Hint;
  sTag := IntToStr((Sender as TButton).Tag);
  url := sHomehost + btnHint + sUrl_txt;
  url := Repleacestr(url, '%TS%', sTimestamp);
  if Panel1.Visible then
    Memo1.Lines.Add(url);
  try
    if Assigned(http_hsl.IOHandler) then
      http_hsl.IOHandler.Open;
    s_HTML := http_hsl.Get(url);
  except

  end;
  if s_HTML <> '' then
  begin
    if Panel1.Visible then
      Memo1.Lines.Add(s_HTML);
    Updlistview(s_HTML, (Sender as TButton).Tag);
  end;
end;

procedure Tfrm_hsl.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure Tfrm_hsl.Button2Click(Sender: TObject);
begin
  Panel1.Visible := not (Panel1.Visible);
  if Panel1.Visible then
    Button2.Caption := '关闭memo'
  else
    Button2.Caption := '显示memo';
end;

procedure Tfrm_hsl.Button3Click(Sender: TObject);
begin
  Workers.Enabled := not (Workers.Enabled);
  if Workers.Enabled then
    Button3.Caption := '关闭定时刷新'
  else
    Button3.Caption := '开启定时刷新';
end;

procedure Tfrm_hsl.CreateButton;
var
  AJson_content: TQJson;
  i, j: Integer;
  url: string;
  sBtn_name: string;
  sType: string;
begin
  AJson_content := hsl_json.ItemByName('textmod');
  for i := 0 to AJson_content.Count - 1 do
  begin
    sType := AJson_content[i].ValueByName('type', '');
    with TButton.Create(Self) do
    begin
      Name := 'Btn_' + sType;
      Parent := Self;
      Caption := AJson_content[i].ValueByName('name', '');
      Top := 10 + i * 30;
      Left := 10;
      Width := 100;
      OnClick := btnclick;
      Tag := i;
      if (sType = 'realHome') or (sType = 'fundflowBlockStocks') then
        Parent := Panel2
      else
        Parent := Panel3;

      for j := 0 to AJson_content[i].Count - 1 do
      begin
        if AJson_content[i].Items[j].Name <> 'name' then
        begin
          if j = 0 then
          begin
            //type后面接问号'？'
            Hint := AJson_content[i].Items[j].AsString + '?';
            sBtn_name := AJson_content[i].Items[j].AsString;
          end
          else
            Hint := Hint + AJson_content[i].Items[j].Name + '=' + AJson_content[i].Items[j].AsString + '&';
        end;
      end;
      Show;
      if (sType = 'fundflowBlockStocks') then
        Visible := False;
    end;
  end;
end;

procedure Tfrm_hsl.FormCreate(Sender: TObject);
var
  i: Integer;
  path_json: string;
  path_xml: string;
begin
  hsl_json := TQJson.Create;
  hsl_xml := TQXMLNode.Create;
  path_json := ExtractFileDir(ParamStr(0)) + '\huanshoulv.json';
  path_xml := ExtractFileDir(ParamStr(0)) + '\hsl_list.xml';
  hsl_json.LoadFromFile(path_json);
  hsl_xml.LoadFromFile(path_xml);

  sHomehost := hsl_json.ItemByName('url').ValueByName('homehost', '');
  for i := 1 to hsl_json.ItemByName('url').Count - 1 do
    sUrl_txt := sUrl_txt + '&' + hsl_json.ItemByName('url').Items[i].Name + '=' + hsl_json.ItemByName('url').Items[i].AsString;
  InitHeaders;
  CreateButton;
end;

procedure Tfrm_hsl.FormShow(Sender: TObject);
begin
  //showlist;
  Workers.At(showlist, -1, 15 * qworker.Q1Second, nil, True)
end;

function Tfrm_hsl.GetUnixTime: string;
begin
  Result := IntToStr(DateTimeToUnix(Now) - 8 * 60 * 60);
end;

procedure Tfrm_hsl.InitHeaders;
begin
  VHeaders.UserAgent := hsl_json.ItemByName('headers').ValueByName('User-Agent', '');
  VHeaders.Connection := hsl_json.ItemByName('headers').ValueByName('Connection', '');
  VHeaders.Cookie := hsl_json.ItemByName('headers').ValueByName('Cookie', '');
  VHeaders.appversion := hsl_json.ItemByName('headers').ValueByName('appversion', '');
  VHeaders.deviceId := hsl_json.ItemByName('headers').ValueByName('deviceId', '');
  VHeaders.mobiledevice := hsl_json.ItemByName('headers').ValueByName('mobiledevice', '');
  VHeaders.userid := hsl_json.ItemByName('headers').ValueByName('userid', '');

  http_hsl.HandleRedirects := true; //必须支持重定向否则可能出错
  http_hsl.ReadTimeout := 5000; //超过这个时间则不再访问
  http_hsl.ConnectTimeout := 5000;
  http_hsl.Request.UserAgent := VHeaders.UserAgent;
  http_hsl.Request.Connection := VHeaders.Connection;

  http_hsl.Request.CustomHeaders.Values['Cookie'] := VHeaders.Cookie;
  http_hsl.Request.CustomHeaders.Values['appversion'] := VHeaders.appversion;
  http_hsl.Request.CustomHeaders.Values['deviceId'] := VHeaders.deviceId;
  http_hsl.Request.CustomHeaders.Values['mobiledevice'] := VHeaders.mobiledevice;
  http_hsl.Request.CustomHeaders.Values['userid'] := VHeaders.userid;
end;

procedure Tfrm_hsl.InitLvColumns(sType: string; FListView: TListView);
var
  i: Integer;
  aXML_node: TQXMLNode;
begin
  FListView.Columns.Clear;
  //获取节点内容
  for i := 0 to hsl_xml.ItemByName('list').ItemByName(sType).Count - 1 do
  begin
    aXML_node := hsl_xml.ItemByName('list').ItemByName(sType).Items[i];
    Memo1.Lines.Add(aXML_node.AttrValueByPath('', 'name', ''));
    FListView.Columns.Add;
    FListView.Columns.Items[i].Caption := aXML_node.AttrValueByPath('', 'displayname', '');
    FListView.Columns.Items[i].Width := StrToInt(aXML_node.AttrValueByPath('', 'displaywidth', ''));
    FListView.Columns.Items[i].Alignment := taCenter;
  end;
end;

procedure Tfrm_hsl.lv_themeClick(Sender: TObject);
var
  url: string;
  s_HTML: string;
  btnHint: string;
  sTimestamp: string;
  sProdcode: string;
  i: Integer;
  AJson: TQJson;
  j: Integer;
begin
  AJson := TQJson.Create;
  try
    if lv_theme.Selected <> nil then
    begin
      sTimestamp := GetUnixTime;
      sProdcode := lv_theme.Selected.SubItems.Strings[0];
      btnHint := TButton(FindComponent('Btn_fundflowBlockStocks')).Hint;
      url := sHomehost + btnHint + sUrl_txt;
      url := Repleacestr(url, '%TS%', sTimestamp);
      url := Repleacestr(url, '%PROD_CODE%', sProdcode);
      Memo1.Lines.Add(url);
      s_HTML := http_hsl.Get(url);
      Memo1.Lines.Add(s_HTML);
      Ajson.Parse(s_HTML);
      Updlistview_Block(AJson.ItemByName('data'), 'fundflowBlockStocks', lv_block);
    end;
  except

  end;
  AJson.Free;
end;

procedure Tfrm_hsl.MenuItem1Click(Sender: TObject);
var
  sUrl: string;
  sStkCode: string;
begin
  if lv_other.Selected = nil then
  begin
    MessageBox(Handle, '请选择要打开的项！', '提示', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;
  sStkCode := lv_other.Selected.SubItems.Strings[0];
  if sStkCode < '600000' then
    sUrl := 'https://xueqiu.com/S/SZ' + sStkCode
  else
    sUrl := 'https://xueqiu.com/S/SH' + sStkCode;
  //打开浏览器
  ShellExecute(Handle, nil, PChar(sUrl), nil, nil, SW_SHOWNORMAL);
end;

procedure Tfrm_hsl.N1Click(Sender: TObject);
var
  sUrl: string;
begin
  if lv_other.Selected = nil then
  begin
    MessageBox(Handle, '请选择要打开的项！', '提示', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;
  sUrl := lv_other.Selected.SubItems.Strings[lv_other.Columns.Count - 2];
  //打开浏览器
  ShellExecute(Handle, nil, PChar(sUrl), nil, nil, SW_SHOWNORMAL);
end;

function Tfrm_hsl.Repleacestr(inputstr, key, sSrc: string): string;
var
  sStr: string;
begin
  sStr := inputstr;
  sStr := StringReplace(sStr, key, sSrc, [rfReplaceAll]);
  Result := sStr;
end;

procedure Tfrm_hsl.showlist(AJob: PQJob);
begin
  TButton(FindComponent('Btn_realHome')).Click;
  TButton(FindComponent('Btn_customFundflow')).Click;
  if lv_theme.Items.Count > 0 then
  begin
    lv_theme.SetFocus;
    lv_theme.ItemIndex := Random(lv_theme.Items.Count);
    lv_theme.OnClick(nil);
  end;
end;

procedure Tfrm_hsl.Timer1Timer(Sender: TObject);
begin
  //showlist;
end;

procedure Tfrm_hsl.Timer2Timer(Sender: TObject);
begin
  Button3Click(Sender);
  Timer2.Enabled := False;
end;

function Tfrm_hsl.UnicodeToChinese(inputstr: string): string;
var
  index: Integer;
  temp, top, last: string;
begin
  index := 1;
  while index >= 0 do
  begin
    index := Pos('\u', inputstr) - 1;
    if index < 0 then
    begin
      last := inputstr;
      Result := Result + last;
      Exit;
    end;
    top := Copy(inputstr, 1, index); // 取出 编码字符前的 非 unic 编码的字符，如数字
    temp := Copy(inputstr, index + 1, 6); // 取出编码，包括 \u,如\u4e3f
    Delete(temp, 1, 2);
    Delete(inputstr, 1, index + 6);
    Result := Result + top + WideChar(StrToInt('$' + temp));
  end;
end;

procedure Tfrm_hsl.Updlistview(sHTML: string; tag: Integer);
var
  i: integer;
  Ajson: TQJson;
  sErrrmsg: string;
begin
  Ajson := TQJson.Create;
  Ajson.Parse(sHTML);
  if Ajson.ItemByName('status').AsString = '200' then
  begin
    try
      case tag of
        0:
          Updlistview_Block(Ajson.ItemByName('data').ItemByName('fundflow').ItemByName('blocks'), 'realhome', lv_theme);
        2:
          Updlistview_Block(Ajson.ItemByName('data').ItemByName('stocks'), 'customFundflow', lv_other);
        3:
          begin
            if Ajson.ItemByName('data').ValueByName('list','') <> '' then
              Updlistview_Block(Ajson.ItemByName('data').ItemByName('list'), 'callAuction', lv_other);
          end;
        4:
          begin
            Button3Click(nil);
            Timer2.Enabled := False;
            Timer2.Enabled := True;
            Updlistview_Block(Ajson.ItemByName('data'), 'homeStatic', lv_other);
          end;
        5:
          begin
            Button3Click(nil);
            Timer2.Enabled := False;
            Timer2.Enabled := True;
            Updlistview_bullbearindex(Ajson, 'bullbearindex', lv_other);
          end;
      end;
    finally
      Ajson.Free;
    end;
  end
  else
  begin
    sErrrmsg := Ajson.ItemByName('status').AsString + ':' + Ajson.ItemByName('msg').AsString;
    Application.MessageBox(PChar(sErrrmsg), '错误', MB_OK + MB_ICONWARNING);
    //Workers.Clear(showlist(), INVALID_JOB_DATA);
    Workers.DisableWorkers;
  end;
end;

procedure Tfrm_hsl.Updlistview_Block(sJson: TQJson; sType: string; FListView: TListView);
var
  i, j, k: Integer;
  nTag: Integer;
  AXML_node, AChild: TQXMLNode;
  sKey: string;
begin
  GroupBox1.Caption := '';
  FListView.Columns.Clear;
  FListView.Items.Clear;
  FListView.PopupMenu := nil;
  //获取节点内容
  for i := 0 to hsl_xml.ItemByName('list').ItemByName(sType).Count do
  begin
    if i = 0 then
    begin
      FListView.Columns.Add;
      FListView.Columns.Items[0].Width := 0;
      FListView.Columns.Items[0].Caption := '';
    end
    else
    begin
      aXML_node := hsl_xml.ItemByName('list').ItemByName(sType).Items[i - 1];
      FListView.Columns.Add;
      FListView.Columns.Items[i].Caption := aXML_node.AttrValueByPath('', 'displayname', '');
      FListView.Columns.Items[i].Tag := StrToInt(aXML_node.AttrValueByPath('', 'tag', ''));
      FListView.Columns.Items[i].Width := StrToInt(aXML_node.AttrValueByPath('', 'displaywidth', ''));
      FListView.Columns.Items[i].Alignment := taCenter;
    end;
  end;
  FListView.ViewStyle := vsreport;
  FListView.GridLines := False;
  if (sType = 'homeStatic') or (sType = 'bullbearindex') then
    FListView.PopupMenu := pp_link
  else
    FListView.PopupMenu := pp_stock;

  begin
    FListView.Items.BeginUpdate;
    for i := 0 to sJson.Count - 1 do
    begin
      with FListView.items.add do
        for j := 1 to FListView.Columns.Count - 1 do
        begin
          //由于集合竞价看多净买没有key值，不能使用key值匹配
          if sType = 'callAuction' then
          begin
            nTag := FListView.Columns.Items[j].Tag;
            subitems.Add(sJson[i].Items[nTag].AsString);
          end
          else
          begin
            for AChild in hsl_xml.ItemByName('list').ItemByName(sType) do
            begin
              if FListView.Columns.Items[j].Caption = AChild.AttrValueByPath('', 'displayname', '') then
              begin
                sKey := AChild.AttrValueByPath('', 'name', '');
                subitems.Add(sJson[i].ItemByName(sKey).AsString);
              end;
            end;
          end;
        end;
    end;
  end;
  FListView.Items.EndUpdate;
end;

procedure Tfrm_hsl.Updlistview_bullbearindex(sJson: TQJson; sType: string; FListView: TListView);
var
  i, j, k: Integer;
  nTag: Integer;
  AXML_node, AChild: TQXMLNode;
  sKey: string;
  sDate: string;
  sjson_up, sjson_down: TQJson;
begin
  FListView.Columns.Clear;
  FListView.Items.Clear;
  FListView.PopupMenu := nil;
  //获取节点内容
  for i := 0 to hsl_xml.ItemByName('list').ItemByName(sType).Count do
  begin
    if i = 0 then
    begin
      FListView.Columns.Add;
      FListView.Columns.Items[0].Width := 0;
      FListView.Columns.Items[0].Caption := '';
    end
    else
    begin
      aXML_node := hsl_xml.ItemByName('list').ItemByName(sType).Items[i - 1];
      FListView.Columns.Add;
      FListView.Columns.Items[i].Caption := aXML_node.AttrValueByPath('', 'displayname', '');
      FListView.Columns.Items[i].Tag := StrToInt(aXML_node.AttrValueByPath('', 'tag', ''));
      FListView.Columns.Items[i].Width := StrToInt(aXML_node.AttrValueByPath('', 'displaywidth', ''));
      FListView.Columns.Items[i].Alignment := taCenter;
    end;
  end;
  FListView.ViewStyle := vsreport;
  FListView.GridLines := False;
  FListView.PopupMenu := pp_link;

  sjson_up := sJson.ItemByName('data').ItemByName('up');
  sjson_down := sJson.ItemByName('data').ItemByName('down');
  FListView.Items.BeginUpdate;
  for i := 0 to sjson_up.Count - 1 do
  begin
    with FListView.items.add do
      for j := 1 to FListView.Columns.Count - 1 do
      begin
        if j = 1 then
          subitems.Add('看涨')
        else
        begin
          nTag := FListView.Columns.Items[j].Tag;
          subitems.Add(sjson_up[i].Items[nTag].AsString);
        end;
      end;
  end;

  for i := 0 to sjson_down.Count - 1 do
  begin
    with FListView.items.add do
      for j := 1 to FListView.Columns.Count - 1 do
      begin
        if j = 1 then
          subitems.Add('看跌')
        else
        begin
          nTag := FListView.Columns.Items[j].Tag;
          subitems.Add(sjson_down[i].Items[nTag].AsString);
        end;
      end;
  end;
  FListView.Items.EndUpdate;
  sDate := sJson.ItemByName('data').ItemByName('target_date').AsString;
  GroupBox1.Caption := sDate + '看涨 ' + sJson.ItemByName('data').ItemByName('up_percentage').AsString + '%   ' + sDate + '看跌' + sJson.ItemByName('data').ItemByName('down_percentage').AsString + '%';
end;

end.

