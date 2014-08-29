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


  TQTXAnimationHelper = helper for TW3CustomAnimation
  public
    procedure Pause;
    procedure Resume;
    procedure Stop;
  End;


  (* TQTXCustomAnimation = partial class(TW3CustomAnimation)
  public
    procedure Pause;virtual;
    procedure Resume;virtual;
    procedure Stop;virtual;
  End;   *)


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

    //class function getElementRootAncestor(const aElement:THandle):THandle;
    //class function getElementInDOM(const aElement:THandle):Boolean;

    class procedure ExecuteOnElementReady(const aElement:THandle;
          const aFunc:TProcedureRef);

    class procedure ExecuteRepeat(const aFunc:TProcedureRef;
          const aCount:Integer;
          const aDelay:Integer);

    class procedure ExecuteOnDocumentReady(const aFunc:TProcedureRef);

    class function getDocumentReady:Boolean;

    //class function  getHandleReady(const aHandle:THandle):Boolean;

    class function addLinkToHead(const aRel,aHref:String):THandle;

  end;


implementation


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

class function TQTXTools.addLinkToHead(const aRel,aHref:String):THandle;
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
