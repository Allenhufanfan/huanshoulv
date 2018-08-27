program hsl;

uses
  Vcl.Forms,
  huanshoulv in 'huanshoulv.pas' {frm_hsl};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tfrm_hsl, frm_hsl);
  Application.Run;
end.
