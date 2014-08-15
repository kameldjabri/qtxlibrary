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
  W3System;

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

  TQTXControlTools = Class
  public
    class function calcTextMetrics(const aText:String;
          const aFontName:String;const aFontSize:Integer):TQTXTextMetric;

    class function calcTextAverage(const aFontName:String;
          const aFontSize:Integer):TQTXTextMetric;

          (*
    class function getElementRootAncestor(const aElement:THandle):THandle;
    class function getElementInDOM(const aElement:THandle):Boolean;
    class function ExecuteOnElementReady(const aElement:THandle;
          const aFunc:TProcedureRef);
    class procedure RepeatExecute(const aFunc:TProcedureRef;
          const aCount:Integer;
          const aDelay:Integer); *)
  end;

(* Helper functions *)
function  QTX_FindElementRootAncestor(const aElement:THandle):THandle;
function  QTX_ElementInDOM(const aElement:THandle):Boolean;
procedure QTX_ExecuteOnElementReady(const aElement:THandle;
          Const aFunc:TProcedureRef);

Procedure QTX_ExecuteRepeat(const aFunc:TProcedureRef;
          const Count:Integer;const aDelayMS:Integer);

function  QTX_HandleReady(const aHandle:THandle):Boolean;

implementation


//############################################################################
// TQTXTextMetric
//############################################################################

function TQTXTextMetric.toString:String;
Begin
  result:=Format('width=%d px, height=%d px',[tmWidth,tmHeight]);
end;

//############################################################################
// TQTXControlTools
//############################################################################

class function TQTXControlTools.calcTextAverage(const aFontName:String;
      const aFontSize:Integer):TQTXTextMetric;
Begin
  result:=calcTextMetrics('gWÅzj§',afontName,aFontSize);
end;

class function TQTXControlTools.calcTextMetrics(const aText:String;
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

  asm
    document.body.removeChild(@mHandle);
  end;
end;

//############################################################################
// QTX UTIL METHODS
//############################################################################

function  QTX_HandleReady(const aHandle:THandle):Boolean;
Begin
  if (aHandle) then
  result:=QTX_ElementInDOM(aHandle);
end;

function QTX_FindElementRootAncestor(const aElement:THandle):THandle;
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

function QTX_ElementInDOM(const aElement:THandle):Boolean;
var
  mRef: THandle;
begin
  if (aElement) then
  Begin
    (* Check that top-level ancestor is window->document->body *)
    mRef:=QTX_FindElementRootAncestor(aElement);
    result:=(mRef.body);
  end;
end;

procedure QTX_ExecuteOnElementReady(const aElement:THandle;
          Const aFunc:TProcedureRef);
Begin
  if (aElement) then
  begin
    if assigned(aFunc) then
    Begin
      if QTX_ElementInDOM(aElement) then
      aFunc() else
      w3_callback(
        procedure ()
        begin
          QTX_ExecuteOnElementReady(aElement,aFunc);
        end,
        100);
    end;
  end;
end;

Procedure QTX_ExecuteRepeat(const aFunc:TProcedureRef;
          const Count:Integer;const aDelayMS:Integer);
Begin
  if assigned(aFunc) then
  begin
    if Count>0 then
    begin
      aFunc();
      if Count>1 then
      w3_callback(
        procedure ()
        begin
          QTX_ExecuteRepeat(aFunc,Count-1,aDelayMS);
        end,
        aDelayMS);
    end;
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
