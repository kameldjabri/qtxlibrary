unit qtx.msgport;

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

type

  TQTXMsgPortMessageEvent = procedure  (sender:TObject;EventObj:JMessageEvent);
  TQTXMsgPortErrorEvent   = procedure  (sender:TObject;EventObj:JDOMError);

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

  (* This message-port can be connected to a window-handle to access
     the message-features. For instance:

      mPort:=TQTXOwnedMsgPort.Create(browserAPI.window);
      try
        mport.postMessage("this is a message","*");
      finally
        mPort.free;
      end;
  *)
  TQTXOwnedMsgPort = Class(TQTXCustomMsgPort)
  end;

  (* This message-port type creates it's own window-handle
     and functions more or less as a message hub. Perfect for
     communication between objects *)
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


implementation

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

end.