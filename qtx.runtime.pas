unit qtx.runtime;

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


  (* This class isolates functionality dealing with execution of code.
     The earlier W3_Callback (w3system.pas) is here re-incarnated
     as DelayedDispatch.

     The execute() function allows you to execute a delegate
     X number of times, which can be handy for precise count-downs
     or procedures which should only run a fixed number of times
     (e.g a count-down to automatic form close).
  *)
  TQTXRuntime = class(TObject)
  public
    class function DelayedDispatch( const OnEntry:TProcedureRef;
          const aDelay:Integer):THandle;
    class procedure CancelDelayedDispatch(const aHandle:THandle);
    class procedure Execute(const OnExecute:TProcedureRef;
            const aCount:Integer;
            const aDelay:Integer);

    class function  Ready:Boolean;
    class procedure ExecuteDocumentReady(const OnReady:TProcedureRef);

  end;


implementation

uses
  qtx.helpers,
  qtx.runtime;

//############################################################################
// TQTXRuntime
//############################################################################

class procedure TQTXRuntime.CancelDelayedDispatch(const aHandle:THandle);
begin
  if aHandle.valid then
  begin
    asm
      clearTimeout(@aHandle);
    end;
  end;
end;

class function TQTXRuntime.DelayedDispatch(const OnEntry:TProcedureRef;
          const aDelay:Integer):THandle;
Begin
  asm
    @result = setTimeout(@OnEntry,@aDelay);
  end;
end;

class procedure TQTXRuntime.ExecuteDocumentReady(const OnReady:TProcedureRef);
Begin
  if Ready then
  OnReady() else
  Begin
    TQTXRuntime.DelayedDispatch( procedure ()
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
      DelayedDispatch( procedure ()
        begin
          Execute(OnExecute,aCount-1,aDelay);
        end,
        aDelay);
    end;
  end;
end;



end.
