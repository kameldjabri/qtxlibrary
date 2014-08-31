unit qtxutils;


//#############################################################################
//
//  Unit:       qtxutils.pas
//  Author:     Jon Lennart Aasenden [cipher diaz of quartex]
//  Copyright:  Jon Lennart Aasenden, all rights reserved
//
//  Description:
//  ============
//  Common utility functions and classes
//
//  _______           _______  _______ _________ _______
// (  ___  )|\     /|(  ___  )(  ____ )\__   __/(  ____ \|\     /|
// | (   ) || )   ( || (   ) || (    )|   ) (   | (    \/( \   / )
// | |   | || |   | || (___) || (____)|   | |   | (__     \ (_) /
// | |   | || |   | ||  ___  ||     __)   | |   |  __)     ) _ (
// | | /\| || |   | || (   ) || (\ (      | |   | (       / ( ) \
// | (_\ \ || (___) || )   ( || ) \ \__   | |   | (____/\( /   \ )
// (____\/_)(_______)|/     \||/   \__/   )_(   (_______/|/     \|
//
//
//#############################################################################


interface

uses 
  W3System, w3Components, w3effects;

type

  TQTXTextMetric  = Record
    tmWidth:  Integer;
    tmHeight: Integer;
    function  toString:String;
  End;

  TQTXFontInfo = Record
    fiName: String;
    fiSize: Integer;
    function  toString:String;
  End;

  TQTXGUID = Class
  public
    class function CreateGUID:String;
  end;

  TQTXHandleHelper = helper for THandle
  public
    function  Valid:Boolean;
    function  Ready:Boolean;
    procedure ReadyExecute(OnReady:TProcedureRef);

    Function  Defined:Boolean;
    function  Equals(const aHandle:THandle):Boolean;
    function  Parent:THandle;
    function  Root:THandle;
  end;


  TQTXFontDetector = Class(TObject)
  private
    FBaseFonts:     array of string;
    FtestString:    String = "mmmmmmmmmmlli";
    FtestSize:      String = '72px';
    Fh:             THandle;
    Fs:             THandle;
    FdefaultWidth:  Variant;
    FdefaultHeight: Variant;
  public
    function    Detect(aFont:String):Boolean;

    function    MeasureText(aFontInfo:TQTXFontInfo;
                aContent:String):TQTXTextMetric;overload;

    function    MeasureText(aFontInfo:TQTXFontInfo;
                aFixedWidth:Integer;
                aContent:String):TQTXTextMetric;overload;

    function    MeasureText(aFontName:String;aFontSize:Integer;
                aContent:String):TQTXTextMetric;overload;

    function    MeasureText(aFontName:String;aFontSize:Integer;
                aFixedWidth:Integer;
                aContent:String):TQTXTextMetric;overload;

    function    getFontInfo(const aHandle:THandle):TQTXFontInfo;

    Constructor Create;virtual;
  End;


  TQTXAnimationHelper = helper for TW3CustomAnimation
  public
    procedure Pause;
    procedure Resume;
    procedure Stop;
  End;

  TQTXAttrAccess = Class(TObject)
  private
    FHandle:  THandle;
  public
    Property  Handle:THandle read FHandle;

    function  Exists(aName:String):Boolean;
    function  Read(aName:String):Variant;
    procedure Write(aName:String;const aValue:Variant);

    Constructor Create(Const aHandle:THandle);virtual;
  End;

  TW3CustomControl = partial class(TW3MovableControl)
  private
    FAccess:    TQTXAttrAccess;
  public
    Property    ElementData:TQTXAttrAccess read FAccess;
    Constructor Create(AOwner:TW3Component);override;
    Destructor  Destroy;Override;
  end;

  TQTXTools = Class
  public
    class function calcTextMetrics(const aText:String;
          const aFontName:String;
          const aFontSize:Integer):TQTXTextMetric;

    class function calcTextAverage(const aFontName:String;
          const aFontSize:Integer):TQTXTextMetric;

    class procedure ExecuteOnElementReady(const aElement:THandle;
          const aFunc:TProcedureRef);

    class procedure ExecuteRepeat(const aFunc:TProcedureRef;
          const aCount:Integer;
          const aDelay:Integer);

    class procedure ExecuteOnDocumentReady(const aFunc:TProcedureRef);

    class function getDocumentReady:Boolean;

    class function LoadCSS(const aRel,aHref:String;
         const aCallback:TProcedureRef):THandle;

    class Procedure LoadScript(aFilename:String;
          const aCallback:TProcedureRef);

    class function LoadImage(aFilename:String;
          const aCallback:TProcedureRef):THandle;
  end;

implementation

//############################################################################
// TQTXFontInfo
//############################################################################

function TQTXFontInfo.toString:String;
begin
  result:=Format('%s %dpx',[fiName,fiSize]);
end;

//############################################################################
// TQTXFontDetector
//############################################################################

Constructor TQTXFontDetector.Create;
var
  x:  Integer;
begin
  inherited Create;
  FBaseFonts.add('monospace');
  FBaseFonts.add('sans-serif');
  FBaseFonts.add('serif');

  Fh:=browserApi.document.body;

  Fs:=browserApi.document.createElement("span");
  Fs.style.fontSize:=FtestSize;
  Fs.innerHTML := FtestString;
  FDefaultWidth:=TVariant.createObject;
  FDefaultHeight:=TVariant.createObject;

  if FBaseFonts.Count>0 then
  for x:=FBaseFonts.low to FBaseFonts.high do
  begin
    Fs.style.fontFamily := FbaseFonts[x];
    Fh.appendChild(Fs);
    FdefaultWidth[FbaseFonts[x]]  :=  Fs.offsetWidth;
    FdefaultHeight[FbaseFonts[x]] :=  Fs.offsetHeight;
    Fh.removeChild(Fs);
  end;
end;


function TQTXFontDetector.getFontInfo(const aHandle:THandle):TQTXFontInfo;
var
  mName:  String;
  mSize:  Integer;
  mData:  Array of string;
  x:  Integer;
Begin
  result.fiSize:=-1;
  if aHandle.valid then
  begin
    mName:=w3_getStyleAsStr(aHandle,'font-family');
    mSize:=w3_getStyleAsInt(aHandle,'font-size');

    if length(mName)>0 then
    begin
      asm
        @mData = (@mName).split(",");
      end;
      if mData.Length>0 then
      Begin
        for x:=mData.low to mData.high do
        begin
          if Detect(mData[x]) then
          begin
            result.fiName:=mData[x];
            result.fiSize:=mSize;
            break;
          end;
        end;
      end;
    end;
  end;
end;

function TQTXFontDetector.MeasureText(aFontInfo:TQTXFontInfo;
         aFixedWidth:Integer;
         aContent:String):TQTXTextMetric;
Begin
  result:=MeasureText(aFontInfo.fiName,aFontInfo.fiSize,aFixedWidth,aContent);
end;

function TQTXFontDetector.MeasureText(aFontInfo:TQTXFontInfo;
         aContent:String):TQTXTextMetric;
Begin
  result:=MeasureText(aFontInfo.fiName,aFontInfo.fiSize,aContent);
end;

function TQTXFontDetector.MeasureText(aFontName:String;aFontSize:Integer;
         aFixedWidth:Integer;
         aContent:String):TQTXTextMetric;
var
  mElement: THandle;
Begin
  if Detect(aFontName) then
  begin
    aContent:=trim(aContent);
    if length(aContent)>0 then
    begin
      mElement:=BrowserAPi.document.createElement("div");
      if (mElement) then
      begin
        mElement.style['font-family']:=aFontName;
        mElement.style['font-size']:=TInteger.toPxStr(aFontSize);
        mElement.style['overflow']:='scroll';

        mElement.style.maxWidth:=TInteger.toPxStr(aFixedWidth);
        mElement.style.width:=TInteger.toPxStr(aFixedWidth);
        mElement.style.height:='10000px';

        mElement.innerHTML := aContent;
        Fh.appendChild(mElement);

        mElement.style.width:="4px";
        mElement.style.height:="4px";

        result.tmWidth:=mElement.scrollWidth;
        result.tmHeight:=mElement.scrollHeight;
        Fh.removeChild(mElement);

      end;
    end;
  end;
end;

function TQTXFontDetector.MeasureText(aFontName:String;aFontSize:Integer;
         aContent:String):TQTXTextMetric;
var
  mElement: THandle;
Begin
  if Detect(aFontName) then
  begin
    aContent:=trim(aContent);
    if length(aContent)>0 then
    begin
      mElement:=BrowserAPi.document.createElement("div");
      if (mElement) then
      begin
        mElement.style['font-family']:=aFontName;
        mElement.style['font-size']:=TInteger.toPxStr(aFontSize);
        mElement.style['overflow']:='scroll';

        mElement.style['display']:='inline-block';
        mElement.style['white-space']:='nowrap';


        mElement.style.width:='10000px';
        mElement.style.height:='10000px';

        mElement.innerHTML := aContent;
        Fh.appendChild(mElement);

        mElement.style.width:="4px";
        mElement.style.height:="4px";

        result.tmWidth:=mElement.scrollWidth;
        result.tmHeight:=mElement.scrollHeight;
        Fh.removeChild(mElement);

      end;
    end;
  end;
end;

function TQTXFontDetector.Detect(aFont:String):Boolean;
var
  x:  Integer;
Begin
  aFont:=trim(aFont);
  if aFont.Length>0 then
  Begin
    if FBaseFonts.Count>0 then
    for x:=FBaseFonts.low to FBaseFonts.high do
    begin
      Fs.style.fontFamily:=aFont + ',' + FbaseFonts[x];
      Fh.appendChild(Fs);
      result:= (Fs.offsetWidth  <> FdefaultWidth[FBaseFonts[x]])
          and  (Fs.offsetHeight <> FdefaultHeight[FBaseFonts[x]]);
      Fh.removeChild(Fs);
      if result then
      break;
    end;
  end;
end;


//############################################################################
// TQTXAnimationHelper
//############################################################################

procedure TQTXAnimationHelper.Pause;
begin
  if self.Active then
  Begin
    self.target.handle.style['-webkit-animation-play-state']:='paused';
  end;
end;

procedure TQTXAnimationHelper.Resume;
Begin
  if self.active then
  begin
    if self.target.handle.style['-webkit-animation-play-state']='paused' then
    self.target.handle.style['-webkit-animation-play-state']:='running';
  end;
end;

procedure TQTXAnimationHelper.Stop;
begin
  if Active then
  begin
    FinalizeTransition;
  end;
end;

//############################################################################
// TQTXHandleHelper
//############################################################################

function TQTXHandleHelper.Root:THandle;
var
  mAncestor:  THandle;
Begin
  if valid then
  Begin
    mAncestor:=self;
    while (mAncestor.parentNode) do
    mAncestor:=mAncestor.parentNode;
    result:=mAncestor;
  end else
  result:=null;
end;

Function TQTXHandleHelper.Defined:Boolean;
Begin
  asm
    @result = !(self == undefined);
  end;
end;

function TQTXHandleHelper.Valid:Boolean;
Begin
  asm
    @Result = !( (@self == undefined) || (@self == null) );
  end;
end;

function TQTXHandleHelper.Parent:THandle;
Begin
  if self.valid then
  result:=self.parentNode else
  result:=null;
end;

function TQTXHandleHelper.Ready:Boolean;
var
  mRef: THandle;
begin
  if valid then
  begin
    mRef:=root;
    result:=mRef.valid and (mRef.body);
  end;
end;

function TQTXHandleHelper.Equals(const aHandle:THandle):Boolean;
Begin
  asm
    @result = (@self == @aHandle);
  end;
end;

procedure TQTXHandleHelper.ReadyExecute(OnReady:TProcedureRef);
Begin
  if Valid then
  begin
    if assigned(OnReady) then
    Begin
      (* Element already in DOM? Execute now *)
      if Ready then
      OnReady() else

      (* Try again in 100ms *)
      w3_callback(
        procedure ()
        begin
          self.ReadyExecute(OnReady);
        end,100);
    end;
  end;
end;


//############################################################################
// TQTXAttrAccess
//############################################################################

Constructor TQTXAttrAccess.Create(Const aHandle:THandle);
Begin
  inherited Create;
  if aHandle.valid then
  FHandle:=aHandle else
  raise Exception.Create
  ('Failed to create attribute access, invalid handle error');
end;

function  TQTXAttrAccess.Exists(aName:String):Boolean;
var
  mName:  String;
begin
  mName:=lowercase('data-' + aName);
  result:=FHandle.hasAttribute(mName);
end;

function  TQTXAttrAccess.Read(aName:String):Variant;
var
  mName:  String;
begin
  try
    mName:=lowercase('data-' + aName);
    if FHandle.hasAttribute(mName) then
    Result := FHandle.getAttribute(mName) else
    result:=null;
  except
    on e: exception do
    raise EW3Exception.CreateFmt('Failed to read attribute: %s',
      [e.message]);
  end;
end;

procedure TQTXAttrAccess.Write(aName:String;const aValue:Variant);
var
  mName:  String;
begin
  try
    mName:=lowercase('data-' + aName);
    FHandle.setAttribute(mName, aValue);
  except
    on e: exception do
    raise EW3Exception.CreateFmt('Failed to write attribute: %s',
      [e.message]);
  end;
end;

//############################################################################
// TW3CustomControl
//############################################################################

Constructor TW3CustomControl.Create(AOwner:TW3Component);
Begin
  inherited Create(AOwner);
  FAccess:=TQTXAttrAccess.Create(self.Handle);
end;

Destructor TW3CustomControl.Destroy;
Begin
  FAccess.free;
  inherited;
end;

//############################################################################
// TQTXTextMetric
//############################################################################

function TQTXTextMetric.toString:String;
Begin
  result:=Format('width=%d px, height=%d px',[tmWidth,tmHeight]);
end;

//############################################################################
// TQTXTools
//############################################################################

class procedure TQTXTools.LoadScript(aFilename:String;
      const aCallback:TProcedureRef);
var
  mRef: THandle;
  mLoaded:  Boolean;
Begin
  asm
    @mRef = document.createElement("script");
  end;
  if mRef.valid then
  begin
    mRef.setAttribute("src",aFilename);
    if assigned(aCallback) then
    mRef.onload := procedure ()
      begin
        aCallback();
      end;

    asm
      document.getElementsByTagName('head')[0].appendChild(@mRef);
    end;

  end else
  raise exception.Create('Failed to allocate script element error');
end;


class function TQTXTools.LoadImage(aFilename:String;
          const aCallback:TProcedureRef):THandle;
var
  mRef: THandle;
Begin

  asm
    @result = new Image();
  end;

  if result.valid then
  Begin
    if assigned(aCallback) then
    result.onload := procedure ()
      begin
        aCallback();
      end;

    result.src := aFilename;
  end;
end;

class function TQTXTools.LoadCSS(const aRel,aHref:String;
      const aCallback:TProcedureRef):THandle;
var
  mLink:  THandle;
Begin
  //REL: Can be "stylesheet" and many more values.
  //     See http://www.w3schools.com/tags/att_link_rel.asp
  //     for a list of all options
  asm
    @mLink = document.createElement('link');
    (@mLink).href = @aHref;
    (@mLink).rel=@aRel;
    document.head.appendChild(@mLink);
  end;
  if assigned(aCallback) then
  mLink.onload := procedure ()
  Begin
    aCallback();
  end;

  result:=mLink;
end;

class function TQTXTools.getDocumentReady:Boolean;
begin
  asm
    @result = document.readyState == "complete";
  end;
end;

{
class function TQTXTools.getHandleReady(const aHandle:THandle):Boolean;
Begin
  if (aHandle) then
  result:=getElementInDOM(aHandle);
end;

class function TQTXTools.getElementRootAncestor(const aElement:THandle):THandle;
var
  mAncestor:  THandle;
Begin
  if (aElement) then
  Begin
    mAncestor:=aElement;
    while (mAncestor.parentNode) do
    mAncestor:=mAncestor.parentNode;
    result:=mAncestor;
  end;
end;

class function TQTXTools.getElementInDOM(const aElement:THandle):Boolean;
var
  mRef: THandle;
begin
  if (aElement) then
  Begin
    (* Check that top-level ancestor is window->document->body *)
    mRef:=getElementRootAncestor(aElement);
    result:=(mRef.body);
  end;
end;       }

class procedure TQTXTools.ExecuteOnDocumentReady(const aFunc:TProcedureRef)
Begin
  if getDocumentReady then
  aFunc() else
  Begin
    w3_callback( procedure ()
      begin
        ExecuteOnDocumentReady(aFunc);
      end,
      100);
  end;
end;


class procedure TQTXTools.ExecuteOnElementReady(const aElement:THandle;
      const aFunc:TProcedureRef);
Begin
  if (aElement) then
  begin
    if assigned(aFunc) then
    Begin
      //if TQTXTools.getElementInDOM(aElement) then
      if aElement.ready then
      aFunc() else
      w3_callback(
        procedure ()
        begin
          aElement.readyExecute(aFunc);
          //TQTXTools.ExecuteOnElementReady(aElement,aFunc);
        end,
        100);
    end;
  end;
end;

class procedure TQTXTools.ExecuteRepeat(const aFunc:TProcedureRef;
      const aCount:Integer;
      const aDelay:Integer);
Begin
  if assigned(aFunc) then
  begin
    if aCount>0 then
    begin
      aFunc();
      if aCount>1 then
      w3_callback(
        procedure ()
        begin
          ExecuteRepeat(aFunc,aCount-1,aDelay);
        end,
        aDelay);
    end;
  end;
end;

class function TQTXTools.calcTextAverage(const aFontName:String;
      const aFontSize:Integer):TQTXTextMetric;
Begin
  result:=calcTextMetrics('mmMMMwwWWW',afontName,aFontSize);
end;

class function TQTXTools.calcTextMetrics(const aText:String;
  const aFontName:String;const aFontSize:Integer):TQTXTextMetric;
var
  mHandle:  THandle;
Begin
  asm
    @mHandle = document.createElement("PRE");
  end;

  mHandle.style['display']:='block';
  mHandle.style['overflow']:='scroll';
  mHandle.style['visibility']:='hidden';
  mHandle.style['font']:=TInteger.toPxStr(aFontSize) + ' ' + aFontName;
  mHandle.style['text-wrap']:='none';
  mHandle.style['border-style']:='none';
  mHandle.style['borderWidth']:='0px';
  mHandle.style['margin-top']:='0px';
  mHandle.style['margin-bottom']:='0px';
  mHandle.style['margin-right']:='0px';
  mHandle.style['margin-left']:='0px';

  (* scale out large *)
  mHandle.style.width:='10000px';
  mHandle.style.height:='10000px';

  (* set content *)
  mhandle.innerText := aText ;

  (* Insert into DOM *)
  asm
    document.body.appendChild(@mHandle);
  end;

  (* scale down, force scrolling region we can measure *)
  mHandle.style.width:='4px';
  mHandle.style.height:='4px';

  (* get calculated width/height *)
  result.tmWidth := mHandle.scrollWidth;
  result.tmHeight :=mHandle.scrollHeight;

  inc(result.tmHeight,4);

  asm
    document.body.removeChild(@mHandle);
  end;
end;


//#############################################################################
// TQTXGUID
//#############################################################################

// http://www.ietf.org/rfc/rfc4122.txt
class function TQTXGUID.CreateGUID:String;
Begin
  asm
    var s = [];
    var hexDigits = "0123456789abcdef";
    for (var i = 0; i < 36; i++) {
        s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1);
    }
    s[14] = "4";
    s[19] = hexDigits.substr((s[19] & 0x3) | 0x8, 1);
    s[8] = s[13] = s[18] = s[23] = "-";

    @result = s.join("");
  end;
  result:=uppercase(result);
end;


end.
