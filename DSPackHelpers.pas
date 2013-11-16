Unit DSPackHelpers;
interface
uses windows, sysUtils, classes
     , forms
     , MMSystem
     , ActiveX
     , DirectShow9
     , DSPack, DSUtil, DSUtils
     ;
Type
  TMediaTypeHelper = class helper for TMediaType
  public
   function FourCCToString:string;
   function VideoSizes:string;
   function VideoBitRate:DWORD;
   function AudioFormat:string;
  end;

  TFilterHelper = class helper for TFilter
  public
    procedure ShowPropertyDialog(Handle:HWND);
  end;

  TVideoWindowHelper = class helper for TVideoWindow
  public
    procedure SetFullScreenOnCurrentMonitor(Value: boolean);
  end;

function bitRateToString(br:DWORD):string;
function AvgTimeToFPS(avgt:TReferenceTime):double;


implementation

function bitRateToString(br:DWORD):string;
var dd:double;
begin
  // in bytes
  dd := br / 8;
  if dd > 1024*1024 then Result := format('%0.2f MBytes/s',[dd/(1024*1024)]) else
  if dd > 1024 then Result := format('%0.1f KBytes/s',[dd / 1024]) else
  Result := format('%0.f Bytes/s',[dd])
end;

function AvgTimeToFPS(avgt:TReferenceTime):double;
begin
  Result := 1 / (avgt * 100e-9);
end;

{ TMediaTypeHelper }

function TMediaTypeHelper.FourCCToString:string;
begin
  Result := '';
  with AMMediaType^ do
   if IsEqualGUID(formattype,FORMAT_VideoInfo) and
      ((cbFormat > 0) and assigned(pbFormat)) then
     with PVideoInfoHeader(pbFormat)^.bmiHeader do
      begin
        Result  := GetFOURCC(biCompression);
      end;
end;

function TMediaTypeHelper.VideoBitRate:DWORD;
begin
  Result := 0;
  with AMMediaType^ do
   if IsEqualGUID(formattype,FORMAT_VideoInfo) and
      ((cbFormat > 0) and assigned(pbFormat)) then
     with PVideoInfoHeader(pbFormat)^ do
      begin
        Result := dwBitRate;
      end;
end;

function TMediaTypeHelper.VideoSizes:string;
begin
  Result := '';
  with AMMediaType^ do
   if IsEqualGUID(formattype,FORMAT_VideoInfo) and
      ((cbFormat > 0) and assigned(pbFormat)) then
     with PVideoInfoHeader(pbFormat)^ do
      begin
        Result := sysutils.Format('%dx%d %d bits %s %0.f fps',[
                    bmiHeader.biWidth,
                    bmiHeader.biHeight,
                    bmiHeader.biBitCount,
                    bitRateToString(dwBitRate),
                    AvgTimeToFPS(AvgTimePerFrame)
                    ]);
      end;
end;

function TMediaTypeHelper.AudioFormat:string;
begin
  Result := '';
  with AMMediaType^ do
  if IsEqualGUID(formattype,FORMAT_WaveFormatEx) then
  begin
    if ((cbFormat > 0) and assigned(pbFormat)) then
    begin
      case PWaveFormatEx(pbFormat)^.wFormatTag of
        $0001: result := result+'PCM';  // common
        $0002: result := result+'ADPCM';
        $0003: result := result+'IEEE_FLOAT';
        $0005: result := result+'IBM_CVSD';
        $0006: result := result+'ALAW';
        $0007: result := result+'MULAW';
        $0010: result := result+'OKI_ADPCM';
        $0011: result := result+'DVI_ADPCM';
        $0012: result := result+'MEDIASPACE_ADPCM';
        $0013: result := result+'SIERRA_ADPCM';
        $0014: result := result+'G723_ADPCM';
        $0015: result := result+'DIGISTD';
        $0016: result := result+'DIGIFIX';
        $0017: result := result+'DIALOGIC_OKI_ADPCM';
        $0018: result := result+'MEDIAVISION_ADPCM';
        $0020: result := result+'YAMAHA_ADPCM';
        $0021: result := result+'SONARC';
        $0022: result := result+'DSPGROUP_TRUESPEECH';
        $0023: result := result+'ECHOSC1';
        $0024: result := result+'AUDIOFILE_AF36';
        $0025: result := result+'APTX';
        $0026: result := result+'AUDIOFILE_AF10';
        $0030: result := result+'DOLBY_AC2';
        $0031: result := result+'GSM610';
        $0032: result := result+'MSNAUDIO';
        $0033: result := result+'ANTEX_ADPCME';
        $0034: result := result+'CONTROL_RES_VQLPC';
        $0035: result := result+'DIGIREAL';
        $0036: result := result+'DIGIADPCM';
        $0037: result := result+'CONTROL_RES_CR10';
        $0038: result := result+'NMS_VBXADPCM';
        $0039: result := result+'CS_IMAADPCM';
        $003A: result := result+'ECHOSC3';
        $003B: result := result+'ROCKWELL_ADPCM';
        $003C: result := result+'ROCKWELL_DIGITALK';
        $003D: result := result+'XEBEC';
        $0040: result := result+'G721_ADPCM';
        $0041: result := result+'G728_CELP';
        $0050: result := result+'MPEG';
        $0055: result := result+'MPEGLAYER3';
        $0060: result := result+'CIRRUS';
        $0061: result := result+'ESPCM';
        $0062: result := result+'VOXWARE';
        $0063: result := result+'CANOPUS_ATRAC';
        $0064: result := result+'G726_ADPCM';
        $0065: result := result+'G722_ADPCM';
        $0066: result := result+'DSAT';
        $0067: result := result+'DSAT_DISPLAY';
        $0075: result := result+'VOXWARE'; // aditionnal  ???
        $0080: result := result+'SOFTSOUND';
        $0100: result := result+'RHETOREX_ADPCM';
        $0200: result := result+'CREATIVE_ADPCM';
        $0202: result := result+'CREATIVE_FASTSPEECH8';
        $0203: result := result+'CREATIVE_FASTSPEECH10';
        $0220: result := result+'QUARTERDECK';
        $0300: result := result+'FM_TOWNS_SND';
        $0400: result := result+'BTV_DIGITAL';
        $1000: result := result+'OLIGSM';
        $1001: result := result+'OLIADPCM';
        $1002: result := result+'OLICELP';
        $1003: result := result+'OLISBC';
        $1004: result := result+'OLIOPR';
        $1100: result := result+'LH_CODEC';
        $1400: result := result+'NORRIS';
      else
        result := result+'Unknown';
      end;

      with PWaveFormatEx(pbFormat)^ do
      result := result + sysutils.format(', %d Hertz, %d Bits, %d Channels',[nSamplesPerSec, wBitsPerSample, nChannels]);
    end;
  end;
end;

{ TFilterHelper }

procedure TFilterHelper.ShowPropertyDialog(Handle:HWND);
var hrslt:HRESULT;
    SpecifyPropertyPages:ISpecifyPropertyPages;
    FilterInfo: TFilterInfo;
    CAGUID:TCAGUID;
    AFilter: IBaseFilter;
begin
  if FilterGraph<>nil then
   begin
     hrslt := QueryInterface(IID_ISpecifyPropertyPages, SpecifyPropertyPages);
     if hrslt <> S_OK then exit;
     hrslt := SpecifyPropertyPages.GetPages(CAGUID);
     if hrslt <> S_OK then exit;
     hrslt := (self as IBaseFilter).QueryFilterInfo(FilterInfo);
     if hrslt = S_OK then
     begin
       AFilter := (self as IBaseFilter);
       hrslt := OleCreatePropertyFrame(Handle, 0, 0, FilterInfo.achName, 1, @AFilter, CAGUID.cElems, CAGUID.pElems, 0, 0, nil );
       FilterInfo.pGraph := nil;
     end;
     if Assigned(CAGUID.pElems) then CoTaskMemFree(CAGUID.pElems);
     SpecifyPropertyPages := nil;
   end;
end;

procedure TVideoWindowHelper.SetFullScreenOnCurrentMonitor(Value: boolean);
var mon:TMonitor; intf:IVideoWindow;
begin
  FullScreen := value;
  if FullScreen then
   begin
     CheckDSError(QueryInterface(IVideoWindow,intf));
     if Assigned(intf) then
      begin
        mon := Screen.MonitorFromPoint(ClientToScreen(Point(self.Left,self.Top)));
        CheckDSError(intf.SetWindowPosition(mon.Left, mon.Top, mon.Width, mon.Height));
      end;
   end;
end;

end.


