unit qtx.messages;

//#############################################################################
//
//  Author:     Jon Lennart Aasenden [cipher diaz of quartex]
//  Copyright:  Jon Lennart Aasenden, all rights reserved
//
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
// The QUARTEX library for Smart Mobile Studio is copyright
// Jon Lennart Aasenden. All rights reserved. This is a commercial product.
//
// Jon Lennart Aasenden LTD is a registered Norwegian company:
//
//      Company ID: 913494741
//      Legal Info: http://w2.brreg.no/enhet/sok/detalj.jsp?orgnr=913494741
//
//  The QUARTEX library of units is subject to international copyright
//  laws and regulations regarding intellectual properties.
//
//#############################################################################

interface

uses
  SmartCL.System,
  System.types,
  w3c.dom,
  qtx.runtime,
  qtx.helpers;

const
  CNT_QTX_MESSAGES_BASEID = 1000;

type

  TQTXMessageData       = Class;
  TQTXCustomMsgPort     = Class;
  TQTXOwnedMsgPort      = Class;
  TQTXMsgPort           = Class;
  TQTXMainMessagePort   = Class;
  TQTXMessageSubscription = Class;

  TQTXMessageSubCallback  = procedure (Message:TQTXMessageData);
  TQTXMsgPortMessageEvent = procedure  (sender:TObject;EventObj:JMessageEvent);
  TQTXMsgPortErrorEvent   = procedure  (sender:TObject;EventObj:JDOMError);

  (* The TQTXMessageData represents the actual message-data which is sent
     internally by the system. Unlike Delphi or FPC, it is a class rather
     than a record. Also, it does not derive from TObject - and as such
     is suitable for 1:1 JSON mapping.

     Note:  The Source string is special, as it's demanded by the browser to
            send the URL which is the source of whatever document the message
            is targeting. You can send messages between open windows in
            modern browser -- but we dont implement that (yet) since SMS is
            all about single-page, rich content applications.
            Either way, the source must either contain the current document
            URL -- or alternatively "*" which means "any". By default we
            set this value, so you really dont have to know about that

     Note:  You dont need to free TQTXMessageData objects, Javascript is
            garbage-collected. *)
  TQTXMessageData = class(JObject)
  public
    property    ID: Integer;
    property    Source: String;
    property    Data: String;

    function    Deserialize:String;
    procedure   Serialize(const value:String);

    Constructor Create;
  end;


  (* A mesaage port is a wrapper around the DOM->Window[]->OnMessage
     event and DOM->Window[]->PostMessage API.
     This base-class implements the generic behavior we want from this
     class. We later derive new variations from it *)
  TQTXCustomMsgPort = Class(TObject)
  private
    FWindow:    THandle;
  protected
    procedure   Releasewindow;virtual;
    procedure   HandleMessageReceived(eventObj:JMessageEvent);
    procedure   HandleError(eventObj:JDOMError);
  public
    Property    Handle:THandle read FWindow;
    Procedure   PostMessage(msg:Variant;targetOrigin:String);virtual;
    procedure   BroadcastMessage(msg:Variant;targetOrigin:String);virtual;
    Constructor Create(WND:THandle);virtual;
    Destructor  Destroy;Override;
  published
    property    OnMessageReceived:TQTXMsgPortMessageEvent;
    Property    OnError:TQTXMsgPortErrorEvent;
  end;

  (* This type of message-port is designed to be used with an already
     visible browser window, most notably the default "main" window.
     The base-class accepts a window-handle in it's constructor, so
     in this class we simply give it the main DOM window.
     We also re-introduce the constructor to isolate this fact *)
  TQTXOwnedMsgPort = Class(TQTXCustomMsgPort)
  end;

  (* This message-port type is very different from both the
     ad-hoc baseclass and "owned" variation above.
     This one actually creates it's own IFrame instance, which
     means it's a completely stand-alone entity which doesnt need an
     existing window to dispatch and handle messages *)
  TQTXMsgPort = Class(TQTXCustomMsgPort)
  private
    FFrame:     THandle;
    function    AllocIFrame:THandle;
    procedure   ReleaseIFrame(aHandle:THandle);
  protected
    procedure   ReleaseWindow;override;
  public
    Constructor Create;reintroduce;virtual;
  end;

  (* This message port represent the "main" message port for any
     application that includes this unit. It will connect to the main
     window (deriving from the "owned" base class) and has a custom
     message-handler which dispatches messages to any subscribers *)
  TQTXMainMessagePort = Class(TQTXOwnedMsgPort)
  protected
    procedure   HandleMessage(Sender:TObject;EventObj:JMessageEvent);
  public
    Constructor Create(WND:THandle);override;
  end;

  (* Information about registered subscriptions *)
  TQTXSubscriptionInfo = Record
    MSGID:    Integer;
    Callback: TQTXMessageSubCallback;
  end;

  (* A message subscription is an object that allows you to install
     X number of event-handlers for messages you want to recieve. Its
     important to note that all subscribers to a message will get the
     same message -- there is no blocking or ownership concepts
     involved. This system is a huge improvement over the older WinAPI *)
  TQTXMessageSubscription = Class(TObject)
  private
    FObjects:   Array of TQTXSubscriptionInfo;
  public
    function    SubscribesToMessage(MSGID:Integer):Boolean;
    procedure   Dispatch(const Message:TQTXMessageData);virtual;

    function    Subscribe(MSGID:Integer;
                const Callback:TQTXMessageSubCallback):THandle;

    procedure   Unsubscribe(Handle:THandle);
    Constructor Create;virtual;
    Destructor  Destroy;Override;
  end;

  (* Helper functions which simplify message handling *)
  function  QTX_MakeMsgData:TQTXMessageData;
  procedure QTX_PostMessage(const msgValue:TQTXMessageData);
  procedure QTX_BroadcastMessage(const msgValue:TQTXMessageData);

  (* Audience returns true if a message-ID have any
     subscriptions assigned to it *)
  function  QTX_Audience(msgId:Integer):Boolean;

implementation

uses SmartCL.System;

var
_mainport:    TQTXMainMessagePort = NIL;
_subscribers: Array of TQTXMessageSubscription;

//#############################################################################
//
//#############################################################################

procedure QTXDefaultMessageHandler(sender:TObject;EventObj:JMessageEvent);
var
  x:      Integer;
  mItem:  TQTXMessageSubscription;
  mData:  TQTXMessageData;
begin
  mData:=new TQTXMessageData();
  mData.Serialize(EventObj.Data);

  for x:=0 to _subscribers.count-1 do
  Begin
    mItem:=_subscribers[x];
    if mItem.SubscribesToMessage(mData.ID) then
    Begin
      (* We execute with a minor delay, allowing the browser to
         exit the function before we dispatch our data *)
      TQTXRuntime.DelayedDispatch(procedure ()
        begin
          mItem.Dispatch(mData);
        end,8);
    end;
  end;
end;

function  QTX_MakeMsgData:TQTXMessageData;
begin
  result:=new TQTXMessageData();
  result.Source:="*";
end;

function getMsgport:TQTXMainMessagePort;
begin
  if _mainport=NIL then
  _mainport:=TQTXMainMessagePort.Create(BrowserAPI.Window);
  result:=_mainport;
end;

procedure QTX_PostMessage(const msgValue:TQTXMessageData);
begin
  if msgValue<>NIL then
  getMsgport.PostMessage(msgValue.Deserialize,msgValue.Source) else
  raise exception.create('Postmessage failed, message object was NIL error');
end;

procedure QTX_BroadcastMessage(const msgValue:TQTXMessageData);
Begin
  if msgValue<>NIL then
  getMsgport.BroadcastMessage(msgValue,msgValue.Source) else
  raise exception.create('Broadcastmessage failed, message object was NIL error');
end;

function  QTX_Audience(msgId:Integer):Boolean;
var
  x:  Integer;
  mItem:  TQTXMessageSubscription;
begin
  result:=False;
  for x:=0 to _subscribers.count-1 do
  Begin
    mItem:=_subscribers[x];
    result:=mItem.SubscribesToMessage(mData.ID);
    if result then
    break;
  end;
end;

//#############################################################################
// TQTXMainMessagePort
//#############################################################################

Constructor TQTXMessageData.Create;
begin
  self.Source:="*";
end;

function  TQTXMessageData.Deserialize:String;
begin
  result:=JSON.Stringify(self);
end;

procedure TQTXMessageData.Serialize(const value:String);
var
  mTemp:  variant;
Begin
  mTemp:=JSON.Parse(value);
  self.id := TQTXMessageData(mTemp).ID;
  self.source:= TQTXMessageData(mTemp).source;
  self.data:=TQTXMessageData(mTemp).data;
end;

//#############################################################################
// TQTXMainMessagePort
//#############################################################################

Constructor TQTXMainMessagePort.Create(WND:THandle);
begin
  inherited Create(WND);
  OnMessageReceived:=QTXDefaultMessageHandler;
end;

procedure TQTXMainMessagePort.HandleMessage(Sender:TObject;
          EventObj:JMessageEvent);
begin
  QTXDefaultMessageHandler(self,eventObj);
end;

//#############################################################################
// TQTXMessageSubscription
//#############################################################################

Constructor TQTXMessageSubscription.Create;
begin
  inherited Create;
  _subscribers.add(self);
end;

Destructor TQTXMessageSubscription.Destroy;
Begin
  _subscribers.Remove(self);
  inherited;
end;

function TQTXMessageSubscription.SubScribe(MSGID:Integer;
         const Callback:TQTXMessageSubCallback):THandle;
var
  mObj: TQTXSubscriptionInfo;
begin
  mObj.MSGID:=MSGID;
  mObj.Callback:=@Callback;
  FObjects.add(mObj);
  result:=mObj;
end;

procedure TQTXMessageSubscription.Unsubscribe(Handle:THandle);
var
  x:  Integer;
begin
  for x:=0 to FObjects.Count-1 do
  Begin
    if Variant(FObjects[x]) = Handle then
    Begin
      FObjects.delete(x,1);
      break;
    end;
  end;
end;

function TQTXMessageSubscription.SubscribesToMessage(MSGID:Integer):Boolean;
var
  x:  Integer;
begin
  result:=False;
  for x:=0 to FObjects.Count-1 do
  Begin
    if FObjects[x].MSGID = MSGID then
    Begin
      result:=true;
      break;
    end;
  end;
end;

procedure TQTXMessageSubscription.Dispatch(const Message:TQTXMessageData);
var
  x:  Integer;
begin
  for x:=0 to FObjects.Count-1 do
  Begin
    if FObjects[x].MSGID = Message.ID then
    Begin
      if assigned(FObjects[x].Callback) then
      FObjects[x].Callback(Message);
      break;
    end;
  end;
end;


//#############################################################################
// TQTXMsgPort
//#############################################################################

Constructor TQTXMsgPort.Create;
begin
  FFrame:=allocIFrame;
  if (FFrame) then
  inherited Create(FFrame.contentWindow) else
  Raise Exception.Create('Failed to create message-port error');
end;

procedure TQTXMsgPort.ReleaseWindow;
Begin
  ReleaseIFrame(FFrame);
  FFrame:=unassigned;
  Inherited;
end;

Procedure TQTXMsgPort.ReleaseIFrame(aHandle:THandle);
begin
  If (aHandle) then
  Begin
    asm
      document.body.removeChild(@aHandle);
    end;
  end;
end;

function TQTXMsgPort.AllocIFrame:THandle;
Begin
  asm
    @result = document.createElement('iframe');
  end;

  if (result) then
  begin
    /* if no style property is created, we provide that */
    if not (result['style']) then
    result['style']:=TVariant.createObject;

    /* Set visible style to hidden */
    result['style'].display := 'none';

    asm
      document.body.appendChild(@result);
    end;

  end;
end;

//#############################################################################
// TQTXCustomMsgPort
//#############################################################################

Constructor TQTXCustomMsgPort.Create(WND:THandle);
Begin
  inherited Create;
  FWindow:=WND;
  if (FWindow) then
  Begin
    FWindow.addEventListener('message', @HandleMessageReceived, false);
    FWindow.addEventListener('error', @HandleError, false);
  end;
End;

Destructor TQTXCustomMsgPort.Destroy;
begin
  if (FWindow) then
  Begin
    FWindow.removeEventListener('message', @HandleMessageReceived, false);
    FWindow.removeEventListener('error', @HandleError, false);
    ReleaseWindow;
  end;
  inherited;
end;

procedure TQTXCustomMsgPort.HandleMessageReceived(eventObj:JMessageEvent);
Begin
  if assigned(OnMessageReceived) then
  OnMessageReceived(self,eventObj);
End;

procedure TQTXCustomMsgPort.HandleError(eventObj:JDOMError);
Begin
  if assigned(OnError) then
  OnError(self,eventObj);
end;

procedure TQTXCustomMsgPort.Releasewindow;
begin
  FWindow:=Unassigned;
end;

Procedure TQTXCustomMsgPort.PostMessage(msg:Variant;targetOrigin:String);
begin
  if (FWindow) then
  FWindow.postMessage(msg,targetOrigin);
end;

procedure TQTXCustomMsgPort.BroadcastMessage(msg:Variant;targetOrigin:String);
var
  x:  Integer;
  mLen: Integer;
begin
  mLen:=TVariant.AsInteger(browserAPI.Window.frames.length);
  for x:=0 to mLen-1 do
  browserAPI.window.frames[x].postMessage(msg,targetOrigin);
end;


finalization
begin
  if assigned(_mainport) then
  _mainport.free;
end;

end.