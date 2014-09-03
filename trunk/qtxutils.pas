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
  W3System, w3Components, w3effects, w3inet, w3c.dom;

type

  (*  TextMetric information record.
      Returned by MeasureText() functions
      in response to measuring the width and height
      if a piece of HTML within an element's context *)
  TQTXTextMetric  = Record
    tmWidth:  Integer;
    tmHeight: Integer;
    function  toString:String;
  End;

  (* FontInfo information record.
     Returned by getFontInfo() functions, which is a
     function that uses font detection to avail what
     font is selected into an element's context *)
  TQTXFontInfo = Record
    fiName: String;
    fiSize: Integer;
    function  toString:String;
  End;

  TQTXTextDataReadyEvent = procedure
    (sender:TW3HttpRequest;aText:String);

  TQTXXMLDataReadyEvent = procedure
    (sender:TW3HttpRequest;aObject:JXMLDocument);

  TQTXIOAccess = Class(TObject)
  public
    class procedure LoadXML
          (aFilename:String;const OnComplete:TQTXXMLDataReadyEvent);
    class procedure LoadFile
          (aFilename:String;const OnComplete:TQTXTextDataReadyEvent);

    class function LoadCSS(const aRel,aHref:String;
         const OnComplete:TProcedureRef):THandle;

    class Procedure LoadScript(aFilename:String;
          const OnComplete:TProcedureRef);

    class function LoadImage(aFilename:String;
          const OnComplete:TProcedureRef):THandle;
  End;

  TQTXHandleHelper = helper for THandle
    function  Valid:Boolean;
    function  Ready:Boolean;
    procedure ReadyExecute(OnReady:TProcedureRef);

    Function  Defined:Boolean;
    function  Equals(const aHandle:THandle):Boolean;
    function  Parent:THandle;
    function  Root:THandle;
  end;

  TQTXIntegerHelper = helper for Integer
    function  toHex(digits:Integer):String;
    function  Negative:Boolean;
    function  Positive:Boolean;
    function  DividableBy(const aDivisor:Integer):Boolean;
  end;

  TQTXStringHelper = Helper for String
    function  Numeric:Boolean;
    function  Explode(const separator:String):Array of String;
    class function  CreateGUID:String;
  End;

  TQTXAnimationHelper = helper for TW3CustomAnimation
    procedure Pause;
    procedure Resume;
    procedure Stop;
  End;

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

  TQTXAttrAccess = Class(TObject)
  private
    FHandle:    THandle;
  public
    Property    Handle:THandle read FHandle;

    function    Exists(aName:String):Boolean;
    function    Read(aName:String):Variant;
    procedure   Write(aName:String;const aValue:Variant);

    Constructor Create(Const aHandle:THandle);virtual;
  End;

  TW3CustomControl = partial class(TW3MovableControl)
  private
    FAccess:    TQTXAttrAccess;
  public
    Property    ElementData:TQTXAttrAccess read FAccess;

    function    MeasureText(aContent:String):TQTXTextMetric;overload;
    function    MeasureTextFixed(aContent:String):TQTXTextMetric;overload;

    class function MeasureTextSize(const aHandle:THandle;
          const aContent:String):TQTXTextMetric;

    class function MeasureTextSizeF(const aHandle:THandle;
          const aWidth:Integer;const aContent:String):TQTXTextMetric;

    function    getFontInfo:TQTXFontInfo;overload;
    class function  getFontInfo(const aHandle:THandle):TQTXFontInfo;overload;

    Constructor Create(AOwner:TW3Component);override;
    Destructor  Destroy;Override;
  end;

  TQTXRuntime = class(TObject)
  public
    class procedure Execute(const OnExecute:TProcedureRef;
            const aCount:Integer;
            const aDelay:Integer);

    class function  Ready:Boolean;
    class procedure ExecuteDocumentReady(const OnReady:TProcedureRef);

  end;

implementation

var
_FontDetect:TQTXFontDetector;

Initialization
begin
  _FontDetect:=TQTXFontDetector.Create;
end;

//#############################################################################
// TQTXIntegerHelper
//#############################################################################

function  TQTXIntegerHelper.toHex(digits:Integer):String;
var
  mText:  String;
begin
  mtext:=IntToHex(self,digits);
  if (mtext.Length>0)
  and (mText[1] <> '-') then
  result:='$' + copy(mText,2,length(mtext));
end;

function TQTXIntegerHelper.Negative:Boolean;
begin
  result:=self<0;
end;

function TQTXIntegerHelper.Positive:Boolean;
begin
  result:=self>0;
end;

function TQTXIntegerHelper.DividableBy(const aDivisor:Integer):Boolean;
Begin
  result:=((self div aDivisor) * aDivisor) = self;
end;

//############################################################################
// TQTXIOAccess
//############################################################################


class procedure TQTXIOAccess.LoadScript(aFilename:String;
      const OnComplete:TProcedureRef);
var
  mRef: THandle;
Begin
  asm
    @mRef = document.createElement("script");
  end;
  if mRef.valid then
  begin
    mRef.setAttribute("src",aFilename);
    if assigned(OnComplete) then
    mRef.onload := procedure ()
      begin
        OnComplete();
      end;

    asm
      document.getElementsByTagName('head')[0].appendChild(@mRef);
    end;

  end else
  raise exception.Create('Failed to allocate script element error');
end;

class function TQTXIOAccess.LoadImage(aFilename:String;
          const OnComplete:TProcedureRef):THandle;
Begin

  asm
    @result = new Image();
  end;

  if result.valid then
  Begin
    if assigned(OnComplete) then
    result.onload := procedure ()
      begin
        OnComplete();
      end;

    result.src := aFilename;
  end;
end;

class function TQTXIOAccess.LoadCSS(const aRel,aHref:String;
      const OnComplete:TProcedureRef):THandle;
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
  if assigned(OnComplete) then
  mLink.onload := procedure ()
  Begin
    OnComplete();
  end;

  result:=mLink;
end;


class procedure TQTXIOAccess.LoadFile(aFilename:String;
      const OnComplete:TQTXTextDataReadyEvent);
var
  mLoader:  TW3HttpRequest;
Begin
  mLoader:=TW3HttpRequest.Create;
  mLoader.OnDataReady:=Procedure (sender:TW3HttpRequest)
  Begin
    try
      try
        if assigned(OnComplete) then
        OnComplete(mLoader,sender.responseText);
      except
        on e: exception do;
      end;
    finally
      mLoader.free;
    end;
  end;
  mLoader.OnError:=procedure (sender:TW3HttpRequest)
    Begin
      try
        if assigned(OnComplete) then
        OnComplete(mLoader,'');
      finally
        mLoader.free;
      end;
    end;
  mLoader.Get(aFilename);
end;


class procedure TQTXIOAccess.LoadXML(aFilename:String;
      const OnComplete:TQTXXMLDataReadyEvent);
var
  mLoader:  TW3HttpRequest;
Begin
  mLoader:=TW3HttpRequest.Create;
  mLoader.OnDataReady:=Procedure (sender:TW3HttpRequest)
  Begin
    try
      try
        if assigned(OnComplete) then
        OnComplete(mLoader,JXMLDocument(mLoader.ResponseXML));
      except
        on e: exception do;
      end;
    finally
      sender.free;
    end;
  end;
  mLoader.OnError:=procedure (sender:TW3HttpRequest)
    Begin
      try
        if assigned(OnComplete) then
        OnComplete(mLoader,NIL);
      finally
        mLoader.free;
      end;
    end;
  mLoader.Get(aFilename);
end;

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
         aContent:String):TQTXTextMetric;
var
  mElement: THandle;
Begin
  if Detect(aFontName) then
  begin
    aContent:=trim(aContent);
    if length(aContent)>0 then
    begin
      mElement:=BrowserAPi.document.createElement("p");
      if (mElement) then
      begin
        mElement.style['font-family']:=aFontName;
        mElement.style['font-size']:=TInteger.toPxStr(aFontSize);
        mElement.style['overflow']:='scroll';

        mElement.style['display']:='inline-block';
        mElement.style['white-space']:='nowrap';

        mElement.innerHTML := aContent;
        Fh.appendChild(mElement);

        result.tmWidth:=mElement.scrollWidth;
        result.tmHeight:=mElement.scrollHeight;
        Fh.removeChild(mElement);

      end;
    end;
  end;
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
      mElement:=BrowserAPi.document.createElement("p");
      if (mElement) then
      begin
        mElement.style['font-family']:=aFontName;
        mElement.style['font-size']:=TInteger.toPxStr(aFontSize);
        mElement.style['overflow']:='scroll';

        mElement.style.maxWidth:=TInteger.toPxStr(aFixedWidth);
        mElement.style.width:=TInteger.toPxStr(aFixedWidth);

        mElement.innerHTML := aContent;
        Fh.appendChild(mElement);

        result.tmWidth:=mElement.scrollWidth;
        result.tmHeight:=mElement.scrollHeight;

        Fh.removeChild(mElement);

      end;
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

function TW3CustomControl.getFontInfo:TQTXFontInfo;
//var
//  mObj: TQTXFontDetector;
Begin
  result:=_FontDetect.getFontInfo(Handle);
  (*
  mObj:=TQTXFontDetector.Create;
  try
    result:=mObj.getFontInfo(Handle);
  finally
    mObj.free;
  end; *)
end;

class function  TW3CustomControl.getFontInfo(const aHandle:THandle):TQTXFontInfo;
(* var
  mObj: TQTXFontDetector; *)
Begin
  result:=_FontDetect.getFontInfo(aHandle);
  (* mObj:=TQTXFontDetector.Create;
  try
    result:=mObj.getFontInfo(aHandle);
  finally
    mObj.free;
  end;  *)
end;

function TW3CustomControl.MeasureText(aContent:String):TQTXTextMetric;
(* var
  mObj: TQTXFontDetector; *)
Begin
  aContent:=trim(aContent);
  if aContent.length>0 then
  begin
    result:=_FontDetect.MeasureText(
    _FontDetect.getFontInfo(Handle),aContent);
    (*
    mObj:=TQTXFontDetector.Create;
    try
      result:=mObj.MeasureText(mObj.getFontInfo(Handle),aContent);
    finally
      mObj.free;
    end; *)
  end;
end;

function TW3CustomControl.MeasureTextFixed(aContent:String):TQTXTextMetric;
//var
//  mObj: TQTXFontDetector;
Begin
  aContent:=trim(aContent);
  if aContent.length>0 then
  begin
    result:=_FontDetect.MeasureText(
    _FontDetect.getFontInfo(Handle),ClientWidth,aContent);
    (* mObj:=TQTXFontDetector.Create;
    try
      result:=mObj.MeasureText(mObj.getFontInfo(Handle),ClientWidth,aContent);
    finally
      mObj.free;
    end; *)
  end;
end;

class function TW3CustomControl.MeasureTextSize(const aHandle:THandle;
      const aContent:String):TQTXTextMetric;
//var
//  mObj: TQTXFontDetector;
Begin
  if aHandle.valid then
  begin
    if aContent.length>0 then
    begin
      result:=_FontDetect.MeasureText(
      _FontDetect.getFontInfo(aHandle),aContent);
      (* mObj:=TQTXFontDetector.Create;
      try
        result:=mObj.MeasureText(mObj.getFontInfo(aHandle),-1,aContent);
      finally
        mObj.free;
      end; *)
    end;
  end;
end;

class function TW3CustomControl.MeasureTextSizeF(const aHandle:THandle;
      const aWidth:Integer;const aContent:String):TQTXTextMetric;
//var
//  mObj: TQTXFontDetector;
Begin
  if aHandle.valid then
  begin
    if aContent.length>0 then
    begin
      result:=_FontDetect.MeasureText(
      _FontDetect.getFontInfo(aHandle),aWidth,aContent);
      (* mObj:=TQTXFontDetector.Create;
      try
        result:=mObj.MeasureText(mObj.getFontInfo(aHandle),aWidth,aContent);
      finally
        mObj.free;
      end; *)
    end;
  end;
end;

//############################################################################
// TQTXTextMetric
//############################################################################

function TQTXTextMetric.toString:String;
Begin
  result:=Format('width=%d px, height=%d px',[tmWidth,tmHeight]);
end;

//############################################################################
// TQTXRuntime
//############################################################################

class procedure TQTXRuntime.ExecuteDocumentReady(const OnReady:TProcedureRef);
Begin
  if Ready then
  OnReady() else
  Begin
    w3_callback( procedure ()
      begin
        ExecuteDocumentReady(OnReady);
      end,
      100);
  end;
end;

class function TQTXRuntime.Ready:Boolean;
begin
  asm
    @result = document.readyState == "complete";
  end;
end;

class procedure TQTXRuntime.Execute(const OnExecute:TProcedureRef;
      const aCount:Integer;
      const aDelay:Integer);
Begin
  if assigned(OnExecute) then
  begin
    if aCount>0 then
    begin
      OnExecute();
      if aCount>1 then
      w3_callback(
        procedure ()
        begin
          Execute(OnExecute,aCount-1,aDelay);
        end,
        aDelay);
    end;
  end;
end;

//#############################################################################
// TQTXStringHelper
//#############################################################################

function TQTXStringHelper.Explode(const separator:String):Array of String;
var
  mText:  String;
Begin
  mText:=self;
  asm
    @result = (@mText).split(@separator);
  end;
end;

function TQTXStringHelper.Numeric:Boolean;
const
  CNT_NUMBERS = '0123456789';
  CNT_HEX     = '0123456789abcdef';
var
  x:  Integer;
begin
  if self.length>0 then
  Begin
    result:=true;
    for x:=self.low to self.high do
    Begin
      if pos(self[x],CNT_NUMBERS)<1 then
      begin

        if (self[x]<>'.') then
        Begin
          result:=False;
          break;
        end else
        begin
          (* Comma must have prefix numbers, like 0.3 or 12.5, not .50 *)
          if x<=1 then
          Begin
            result:=False;
            break;
          end;
        end;

        if pos(self[x],CNT_HEX)<1 then
        begin
          result:=False;
          Break;
        end;

      end;
    end;
  end;
end;


// http://www.ietf.org/rfc/rfc4122.txt
class function TQTXStringHelper.CreateGUID:String;
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
