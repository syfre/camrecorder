program camrecorder;

uses
  Forms,
  main in 'main.pas', {Form1}
  config in 'config.pas' {ConfigForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TConfigForm, ConfigForm);
  Application.Run;
end.
