unit qtx.helpers;

interface

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



uses 
  System.Types,
  SmartCL.System;

type

  (* This is a helper class for THandle value-types, which
     provides some very simple but handy functionality.
     Now handles (all handles) can be tested by:

      FHandle.Valid()

    Handles which references HTML elements can use the
    Ready() function, which checks if the handle
    exists in the DOM and thus can be accessed:

      if FHandle.ready then            // ready for action?
      DoSomethingVisual else           // execute at once
      FHandle.readyExecute( ThisProc); // come back later & try again
  *)
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



implementation

uses qtx.runtime;

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
      if not (self[x] in CNT_NUMBERS) then
      //if pos(self[x],CNT_NUMBERS)<1 then
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
      TQTXRuntime.DelayedDispatch( procedure ()
        begin
          self.ReadyExecute(OnReady);
        end,100);
    end;
  end;
end;




end.
