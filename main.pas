unit main;
interface
{$DEFINE AUDIO}
{$DEFINE CAPTURE}
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus, ToolWin, ImgList
  , ActiveX, DirectShow9
  , DSPack, DSUtil, DSUtils, DSPackHelpers
  , config
  ;

type
  TMainForm = class(TForm)
    CaptureGraph: TFilterGraph;
    VideoSourceFilter: TFilter;
    AudioSourceFilter: TFilter;
    Timer: TTimer;
    pmVideoWindow: TPopupMenu;
    miFullScreen: TMenuItem;
    AudioCompressorFilter: TFilter;
    VideoWindow: TVideoWindow;
    ImageList: TImageList;
    ToolBar: TToolBar;
    btnStart: TToolButton;
    btnStop: TToolButton;
    ToolButton1: TToolButton;
    btnFullScreen: TToolButton;
    btnConfig: TToolButton;
    labelTime: TLabel;
    Label1: TLabel;
    btnCaptureDialog: TToolButton;
    procedure StartButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure miFullScreenClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnCaptureDialogClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TMainForm }

procedure TMainForm.FormActivate(Sender: TObject);
begin
  btnStart.Enabled := ConfigForm.CanRun;
end;

// Stop Capture
procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  Timer.Enabled := false;
  btnConfig.Enabled := true;
  btnStop.Enabled := false;
  btnStart.Enabled := true;
  btnFullScreen.Enabled := false;
  btnCaptureDialog.Enabled := false;
  CaptureGraph.Stop;
  CaptureGraph.Active := False;
end;

// Timer
procedure TMainForm.TimerTimer(Sender: TObject);
var
  position: int64;
  Hour, Min, Sec, MSec: Word;
const MiliSecInOneDay = 86400000;
begin
  if CaptureGraph.Active then
  begin
    with CaptureGraph as IMediaSeeking do
      GetCurrentPosition(position);
    DecodeTime(position div 10000 / MiliSecInOneDay, Hour, Min, Sec, MSec);
    LabelTime.Caption := Format('%d:%d:%d:%d',[Hour, Min, Sec, MSec]);
  end;
end;

procedure TMainForm.miFullScreenClick(Sender: TObject);
begin
  VideoWindow.SetFullScreenOnCurrentMonitor(not VideoWindow.FullScreen);
end;

procedure TMainForm.btnCaptureDialogClick(Sender: TObject);
begin
  VideoSourceFilter.ShowPropertyDialog(Handle);
end;

procedure TMainForm.btnConfigClick(Sender: TObject);
begin
  ConfigForm.ShowModal;
  btnStart.Enabled := ConfigForm.CanRun;
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
var ARect:TRect; VPinList,APinList:TPinList; VPin,APin:IPin; MediaTypes:TEnumMediaType; CapEnum:TSysDevEnum;
    multiplexer: IBaseFilter;
    Writer: IFileSinkFilter;
begin
  VPinList := nil;
  APinList := nil;
  VPin := nil;
  APin := nil;
  CapEnum := TSysDevEnum.Create;
  MediaTypes := TEnumMediaType.Create;
  try
    // set video
    CapEnum.SelectGUIDCategory(CLSID_VideoInputDeviceCategory);
    VideoSourceFilter.BaseFilter.Moniker := CapEnum.GetMoniker(CapEnum.FilterIndexOfFriendlyName(ConfigForm.VideoSelected.deviceName));
    VideoSourceFilter.FilterGraph := CaptureGraph;

    // set audio
    {$IFDEF AUDIO}
    if Assigned(ConfigForm.AudioSelected) then
     begin
       CapEnum.SelectGUIDCategory(CLSID_AudioInputDeviceCategory);
       AudioSourceFilter.BaseFilter.Moniker := CapEnum.GetMoniker(CapEnum.FilterIndexOfFriendlyName(ConfigForm.AudioSelected.deviceName));
       AudioSourceFilter.FilterGraph := CaptureGraph;
     end;
    {$ENDIF}

    // Activate the graph
    CaptureGraph.Active := True;

    // Configure video media format
    VPinList := TPinList.Create(VideoSourceFilter as IBaseFilter);
    VPin := VPinList[ConfigForm.VideoSelected.pinNum];
    MediaTypes.Assign(VPin);
    with (VPin as IAMStreamConfig) do
     CheckDSError(SetFormat(MediaTypes.Items[ConfigForm.VideoSelected.mediaNum].AMMediaType^));

    // Get video size
    //ARect := GetSourceRectFromMediaType(MediaTypes.Items[ConfigForm.VideoSelected.mediaNum].AMMediaType^);
    //VideoWindow.Width := ARect.Right-ARect.Left;
    //VideoWindow.Height := ARect.Bottom-ARect.Top;

    {$IFDEF AUDIO}
    if Assigned(ConfigForm.AudioSelected) then
     begin
       APinList := TPinList.Create(AudioSourceFilter as IBaseFilter);
       APin := APinList[ConfigForm.AudioSelected.pinNum];
       MediaTypes.Assign(APin);
       with (APin as IAMStreamConfig) do
        SetFormat(MediaTypes.Items[ConfigForm.AudioSelected.mediaNum].AMMediaType^);

       //if InputLines.ItemIndex <> -1 then
       //  with (APinList.Items[InputLines.ItemIndex] as IAMAudioInputMixer) do
       //    put_Enable(true);
     end;
    {$ENDIF}

    with CaptureGraph as IcaptureGraphBuilder2 do
     begin
       {$IFDEF CAPTURE}
       // if output file is defined
       if (ConfigForm.Capture) then
        begin
          // Set output file
          CheckDSError(SetOutputFileName(MEDIASUBTYPE_Avi, PWideChar(ConfigForm.GetNewCapFile), multiplexer, Writer));

          // render video capture
          CheckDSError(RenderStream(@PIN_CATEGORY_CAPTURE, nil, VPin, nil, multiplexer as IBaseFilter));

          {$IFDEF AUDIO}
          // render audio
          if Assigned(APin) then
           CheckDSError(RenderStream(nil, nil, AudioSourceFilter as IBaseFilter, nil, multiplexer as IBaseFilter));
          {$ENDIF}
        end;
       {$ENDIF}

       // Connect Video preview (VideoWindow)
       if VideoSourceFilter.BaseFilter.DataLength > 0 then
         CheckDSError(RenderStream(@PIN_CATEGORY_PREVIEW, nil, VPin, nil , VideoWindow as IBaseFilter));
     end;

    // Activate graph
    CaptureGraph.Play;
    //
    btnConfig.Enabled := false;
    btnStop.Enabled := true;
    btnStart.Enabled := false;
    btnFullScreen.Enabled := true;
    btnCaptureDialog.Enabled := True;
    Timer.Enabled := true;
    Caption := ConfigForm.DisplayStatus;
  finally
  FreeAndNil(VPinList);
  FreeAndNil(APinList);
  FreeAndNil(MediaTypes);
  FreeAndNil(CapEnum);
  end;
end;

end.
