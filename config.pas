unit config;
interface
uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Dialogs,
     Buttons, ComCtrls, ExtCtrls, IniFiles, FileCtrl
     , DirectShow9
     , DSPack, DSUtil, DSUtils
     , DSPackhelpers
     ;

type
  TSourceSelector = class(TStringList)
  public
    deviceName: string;
    pinNum: Integer;
    fourCC: string;
    mediaNum: Integer;
    mediaName: string;
    mediaIndex: Integer;
    constructor Create(const iDevideName:string; iPinNum:Integer; const iFourCC:string);
    procedure SaveToFile(reg:TMemIniFile; const iSection:string);
    function Complete:boolean;
  end;

  TConfigForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    PageControl1: TPageControl;
    tsSource: TTabSheet;
    tsPreferences: TTabSheet;
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    Panel3: TPanel;
    cbVideoSizes: TComboBox;
    Label3: TLabel;
    cbVideoFormats: TComboBox;
    Label2: TLabel;
    cbVideoCapFilters: TComboBox;
    Label1: TLabel;
    VideoSourceFilter: TFilter;
    CaptureGraph: TFilterGraph;
    Panel4: TPanel;
    Label4: TLabel;
    cbAudioCapFIlters: TComboBox;
    Label5: TLabel;
    cbAudioFormats: TComboBox;
    AudioSourceFilter: TFilter;
    cbAudioInputs: TComboBox;
    Label6: TLabel;
    Panel5: TPanel;
    edtDestFolder: TEdit;
    Label7: TLabel;
    btnDestFolder: TSpeedButton;
    chkCaptureActive: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure cbVideoCapFiltersChange(Sender: TObject);
    procedure cbVideoFormatsDropDown(Sender: TObject);
    procedure cbVideoSizesDropDown(Sender: TObject);
    procedure cbVideoSizesChange(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbAudioCapFIltersChange(Sender: TObject);
    procedure cbAudioFormatsDropDown(Sender: TObject);
    procedure cbAudioFormatsChange(Sender: TObject);
    procedure btnDestFolderClick(Sender: TObject);
  private
    { Private declarations }
    CapEnum: TSysDevEnum;
    fVideoSelected: TSourceSelector;
    fAudioSelected: TSourceSelector;
    fCurrentCapFile: WideString;
    procedure SaveToFile;
    procedure LoadFromFile;
    function getCapture:boolean;
    function getDisplayStatus:string;
  public
    { Public declarations }
    function CanRun:boolean;
    function GetNewCapFile:WideString;
    property VideoSelected:TSourceSelector read fVideoSelected;
    property AudioSelected:TSourceSelector read faudioSelected;
    property Capture:boolean read getCapture;
    property CurrentCapFile:WideString read fCurrentCapFile;
    property DisplayStatus:string read getDisplayStatus;
  end;

var
  ConfigForm: TConfigForm;

implementation

{$R *.dfm}

const
 cPrefFileName = 'preferences.ini';

{ TSourceSelector }

constructor TSourceSelector.Create(const iDevideName:string; iPinNum:Integer; const iFourCC:string);
begin
  deviceName := iDevideName;
  pinNum := iPinNum;
  fourCC := iFourCC;
  mediaNum := -1;
end;

procedure TSourceSelector.SaveToFile(reg:TMemIniFile; const iSection:string);
begin
  reg.WriteString(iSection,'device',deviceName);
  if fourCC<>'' then reg.WriteString(iSection,'format',fourCC);
  reg.WriteInteger(iSection,'pinIndex',pinNum);
  reg.WriteInteger(iSection,'mediaNum',mediaNum);
  reg.WriteInteger(iSection,'mediaIndex',mediaIndex);
  reg.WriteString(iSection,'mediaName',mediaName);
end;

function TSourceSelector.Complete:boolean;
begin
  Result := (deviceName<>'') and (pinNum>=0) and (mediaNum>=0)
end;

{ TConfigForm }

procedure TConfigForm.FormCreate(Sender: TObject);
var i: integer;
begin
  CapEnum := TSysDevEnum.Create(CLSID_VideoInputDeviceCategory);
  for i := 0 to CapEnum.CountFilters - 1 do
    cbVideoCapFilters.Items.Add(CapEnum.Filters[i].FriendlyName);

  CapEnum.SelectGUIDCategory(CLSID_AudioInputDeviceCategory);
  for i := 0 to CapEnum.CountFilters - 1 do
    cbAudioCapFilters.Items.Add(CapEnum.Filters[i].FriendlyName);

  LoadFromFile;
end;

procedure TConfigForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(CapEnum);
end;

////////////////////////////////////////////////////////////////////////////////
// Capture
////////////////////////////////////////////////////////////////////////////////

function TConfigForm.getCapture:boolean;
begin
  Result := chkCaptureActive.Checked;
end;

function TConfigForm.GetNewCapFile:WideString;
begin
  if chkCaptureActive.Checked
     then Result := IncludeTrailingPathdelimiter(edtDestFolder.Text)+Format('capture-%s.avi',[FormatDatetime('yyyymmdd-HHMMSS',Now)])
     else Result := '';
  fCurrentCapFile := Result;
end;

procedure TConfigForm.btnDestFolderClick(Sender: TObject);
var ADir:String;
begin
  ADir := edtDestFolder.Text;
  //
  if Win32MajorVersion >= 6 then
  with TFileOpenDialog.Create(nil) do
    try
      Title := 'Select Directory';
      Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem]; // YMMV
      OkButtonLabel := 'Select';
      DefaultFolder := '';
      FileName := '';
      if Execute then ADir := FileName;
    finally
    Free;
    end
    else
    FileCtrl.SelectDirectory('Select Directory', ExtractFileDrive(ADir), ADir,[sdNewUI, sdNewFolder]);

  edtDestFolder.Text := ADir;
end;

////////////////////////////////////////////////////////////////////////////////
// VIDEO
////////////////////////////////////////////////////////////////////////////////

procedure TConfigForm.cbVideoCapFiltersChange(Sender: TObject);
begin
  cbVideoFormats.Clear;
  cbVideoSizes.Clear;
end;

procedure TConfigForm.cbVideoFormatsDropDown(Sender: TObject);
var
  PinList: TPinList;
  Pininfo: TPinInfo;
  MediaTypes: TEnumMediaType;
  i,num,indx: integer;
  Sel: TSourceSelector;
  AFourCC:string;
begin
  if (cbVideoCapFilters.ItemIndex <> -1) and (cbVideoFormats.Items.Count=0) then
  begin
    CapEnum.SelectGUIDCategory(CLSID_VideoInputDeviceCategory);
    VideoSourceFilter.BaseFilter.Moniker := CapEnum.GetMoniker(cbVideoCapFilters.ItemIndex);
    VideoSourceFilter.FilterGraph := CaptureGraph;
    CaptureGraph.Active := true;
    //
    PinList := TPinList.Create(VideoSourceFilter as IBaseFilter);
    MediaTypes := TEnumMediaType.Create;
    try
     for i:=0 to PinList.Count-1 do
      begin
        PinList[i].QueryPinInfo(PinInfo);
        if Pininfo.dir = PINDIR_OUTPUT then
         begin
           MediaTypes.Assign(PinList[i]);
           for num := 0 to MediaTypes.Count - 1 do
            begin
              if MediaTypes.Items[num].VideoBitRate=0 then continue;
              //
              AFourCC := MediaTypes.Items[num].FourCCToString;
              indx := cbVideoFormats.Items.IndexOf(AFourCC);
              if indx=-1 then
               begin
                 Sel := TSourceSelector.Create(cbVideoCapFilters.Text,i,AFourCC);
                 cbVideoFormats.Items.AddObject(AFourCC,Sel);
               end
               else
               begin
                 Sel := TSourceSelector(cbVideoFormats.Items.Objects[indx]);
               end;
              Sel.AddObject(MediaTypes.Items[num].VideoSizes,Pointer(num))
           end;
         end;
      end;
    finally
    PinList.Free;
    MediaTypes.Free;
    end;
    CaptureGraph.Active := false;
  end;
  cbVideoSizes.Clear;
end;

procedure TConfigForm.cbVideoSizesDropDown(Sender: TObject);
var Sel:TSourceSelector;
begin
  if (cbVideoCapFilters.ItemIndex <> -1) and (cbVideoFormats.ItemIndex<>-1) and (cbVideoSizes.Items.Count=0) then
   begin
     Sel := TSourceSelector(cbVideoFormats.Items.Objects[cbVideoFormats.ItemIndex]);
     cbVideoSizes.Items.AddStrings(Sel);
   end;
end;

procedure TConfigForm.cbVideoSizesChange(Sender: TObject);
begin
  if (cbVideoCapFilters.ItemIndex <> -1) and (cbVideoFormats.ItemIndex<>-1) then
   begin
     fVideoSelected := TSourceSelector(cbVideoFormats.Items.Objects[cbVideoFormats.ItemIndex]);
     VideoSelected.mediaIndex := cbVideoSizes.ItemIndex;
     VideoSelected.mediaNum := Integer(cbVideoSizes.Items.Objects[cbVideoSizes.ItemIndex]);
     VideoSelected.mediaName := cbVideoSizes.Text;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
// AUDIO
////////////////////////////////////////////////////////////////////////////////

procedure TConfigForm.cbAudioCapFIltersChange(Sender: TObject);
begin
  cbAudioFormats.Clear;
end;

procedure TConfigForm.cbAudioFormatsDropDown(Sender: TObject);
var
  PinList: TPinList;
  MediaTypes: TEnumMediaType;
  num,i, LineIndex: integer;
  ABool: LongBool;
begin
  if cbAudioCapFilters.ItemIndex <> -1 then
  begin
    CapEnum.SelectGUIDCategory(CLSID_AudioInputDeviceCategory);
    AudioSourceFilter.BaseFilter.Moniker := CapEnum.GetMoniker(cbAudioCapFilters.ItemIndex);
    AudioSourceFilter.FilterGraph := CaptureGraph;

    CaptureGraph.Active := true;
    PinList := TPinList.Create(AudioSourceFilter as IBaseFilter);
    MediaTypes := TEnumMediaType.Create;
    try
      cbAudioFormats.Clear;

      for num:=0 to PinList.Count-1 do
       if PinList.PinInfo[num].dir = PINDIR_OUTPUT then
        begin
          MediaTypes.Assign(PinList.Items[num]);
          for i := 0 to MediaTypes.Count - 1 do
           begin
             cbAudioFormats.Items.AddObject(MediaTypes.Items[i].AudioFormat,TSourceSelector.Create(cbAudioCapFilters.Text,num,''));
           end;
        end;

      cbAudioInputs.Clear;
      LineIndex := -1;
      for num := 0 to PinList.Count - 1 do
       if PinList.PinInfo[num].dir = PINDIR_INPUT then
        begin
          cbAudioInputs.Items.Add(PinList.PinInfo[num].achName);
          with (PinList.Items[num] as IAMAudioInputMixer) do get_Enable(ABool);
          if ABool then LineIndex := i;
        end;
      cbAudioInputs.ItemIndex := LineIndex;

      CaptureGraph.Active := false;
    finally
    PinList.Free;
    MediaTypes.Free;
    end;
  end;
end;

procedure TConfigForm.cbAudioFormatsChange(Sender: TObject);
begin
  fAudioSelected := TSourceSelector(cbAudioFormats.Items.Objects[cbAudioFormats.ItemIndex]);
  fAudioSelected.mediaIndex := cbAudioFormats.ItemIndex;
  fAudioSelected.mediaNum := cbAudioFormats.ItemIndex;
  fAudioSelected.mediaName := cbAudioFormats.Text;
end;

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////

procedure TConfigForm.SaveToFile;
var reg:TmemIniFile;
begin
  if FileExists(cPrefFileName) then
   begin
     if FileExists(cPrefFileName+'.old') then deleteFile(cPrefFileName+'.old');
     renameFile(cPrefFileName,cPrefFileName+'.old');
     deleteFile(cPrefFileName);
   end;
  //
  reg := TmemIniFile.Create(cPrefFileName);
  try
    if Assigned(VideoSelected) then VideoSelected.SaveToFile(reg,'video');
    if Assigned(AudioSelected) then AudioSelected.SaveToFile(reg,'audio');
    reg.WriteString('capture','destination',edtDestFolder.Text);
    reg.WriteBool('capture','active',chkCaptureActive.Checked);
    reg.UpdateFile;
  finally
  reg.Free;
  end;
end;

procedure TConfigForm.LoadFromFile;
var reg:TmemIniFile;
begin
  reg := TmemIniFile.Create(cPrefFileName);
  try
    if reg.SectionExists('video') then
     begin
       cbVideoCapFilters.ItemIndex := cbVideoCapFilters.Items.IndexOf(reg.ReadString('video','device',''));
       if cbVideoCapFilters.ItemIndex<>-1 then
        begin
          cbVideoFormatsDropDown(Self);
          cbVideoFormats.ItemIndex := cbVideoFormats.Items.IndexOf(reg.ReadString('video','format',''));
          if cbVideoFormats.ItemIndex<>-1 then
           begin
             cbVideoSizesDropDown(Self);
             cbVideoSizes.ItemIndex := reg.ReadInteger('video','mediaIndex',-1);
             cbVideoSizesChange(Self);
           end;
        end;
     end;
    if reg.SectionExists('audio') then
     begin
       cbAudioCapFilters.ItemIndex := cbAudioCapFilters.Items.IndexOf(reg.ReadString('audio','device',''));
       if cbAudioCapFilters.ItemIndex<>-1 then
        begin
          cbAudioFormatsDropDown(Self);
          cbAudioFormats.ItemIndex := reg.ReadInteger('audio','mediaIndex',-1);
          cbAudioFormatsChange(Self);
        end;
     end;
    if reg.SectionExists('capture') then
     begin
       edtDestFolder.Text := reg.ReadString('capture','destination','');
       chkCaptureActive.Checked := reg.ReadBool('capture','active',false);
     end;
  finally
  reg.Free;
  end;
end;

procedure TConfigForm.OKBtnClick(Sender: TObject);
begin
  SaveToFile;
  ModalResult := mrOK;
end;

function TConfigForm.CanRun:boolean;
begin
  Result := Assigned(VideoSelected) and VideoSelected.Complete;
end;

function TConfigForm.getDisplayStatus:string;
begin
  Result := Format('%s %s',[cbVideoFormats.Text,cbVideoSizes.Text]);
  if Capture then Result := Result+ExtractFileName(CurrentCapFile);
end;

end.


