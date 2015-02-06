unit qtx.api.mutationobserver;

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
  system.types,
  SmartCL.System;

type

  TQTXMutationObserver        = Class;
  TQTXMutationObserverOptions = Class;


  TQTXMutationObserverEvent = Procedure
  (sender:TQTXMutationObserver;mutationRecord:variant);

  TQTXMutationRecordHandler = procedure (data:Variant);

  TQTXMutationObserverOptions = Class(TObject)
  protected
    function  toObject:Variant;
  public
    Property  Attributes:             Boolean;
    property  ChildList:              Boolean;
    Property  CharacterData:          Boolean;
    property  SubTree:                Boolean;
    property  AttributeOldValue:      Boolean;
    property  CharacterDataOldValue:  Boolean;
    property  AttributeFilter:        Variant;
    Constructor Create;Virtual;
  end;

  EQTXMutationObserver = Class(EW3Exception);

  TQTXMutationObserver = Class(TObject)
  public
    FObserving:   Boolean;
    FHandle:      THandle;
    FTarget:      THandle;
  protected
    procedure     CBMutationChange(mutationRecordsList:variant);virtual;
  public
    Property      OnDisconnect:TNotifyEvent;
    Property      OnConnect:TNotifyEvent;
    property      OnChanged:TQTXMutationObserverEvent;
    Property      Handle:THandle read FHandle;
    Property      TargetHandle:THandle read FTarget;
    Property      Options:TQTXMutationObserverOptions;
    Property      Observing:Boolean read FObserving;
    Procedure     Observe(targetHandle:THandle);
    Procedure     Disconnect;
    Constructor   Create;virtual;
    Destructor    Destroy;Override;
  end;

implementation

{$R 'mutation.observer.shim.js'}

//#############################################################################
// TQTXMutationObserver
//#############################################################################

Constructor TQTXMutationObserverOptions.Create;
begin
  inherited Create;
  Attributes:=True;
  AttributeOldValue:=true;
end;

function TQTXMutationObserverOptions.toObject:Variant;
begin
  result:=TVariant.createObject;
  result.attributes := Attributes;
  result.childList  := ChildList;
  result.characterData := CharacterData;
  result.subtree := SubTree;
  result.attributeOldValue :=AttributeOldValue;
  result.characterDataOldValue := CharacterDataOldValue;
  result.attributeFilter:=AttributeFilter;
end;

//#############################################################################
// TQTXMutationObserver
//#############################################################################

Constructor TQTXMutationObserver.Create;
var
  mRef: TQTXMutationRecordHandler;
  mhandle:  THandle;
begin
  inherited Create;
  Options:=TQTXMutationObserverOptions.Create;

  mRef:=@CBMutationChange;
  try
    asm
      @mHandle = new MutationObserver(function (_a_d)
        {
          @mRef(_a_d);
        }
        );
    end;
  except
    on e: exception do
    raise EQTXMutationObserver.CreateFmt
    ('Failed to allocate mutation observer, system threw <%s>',
    [e.message]);
  end;

  Fhandle:=mHandle;
end;

Destructor TQTXMutationObserver.Destroy;
begin
  if Observing then
  Disconnect;

  if (FHandle) then
  FHandle:=NIL;

  Options.free;
  inherited;
end;

procedure TQTXMutationObserver.CBMutationChange(mutationRecordsList:variant);
begin
  if assigned(OnChanged) then
  OnChanged(self,mutationRecordsList);
end;

Procedure TQTXMutationObserver.Observe(targetHandle:THandle);
var
  mRef: THandle;
begin
  (* Already observing? Disconnect *)
  if Observing then
  Disconnect;

  (* Validate handle *)
  if (FHandle) then
  begin
    mRef:=FHandle;

    (* Attempt to observe target handle *)
    try
      FHandle.observe(targetHandle,Options.toObject);
    except
      on e: exception do
      Raise;
    end;

    (* Mark as observed *)
    FObserving:=true;

    (* Trigger event if defined *)
    if assigned(OnConnect) then
    OnConnect(self);
  end else
  Raise EQTXMutationObserver.Create('Mutation observer not allocated error');
end;

Procedure TQTXMutationObserver.Disconnect;
Begin
  (* Only execute when observing *)
  if Observing then
  begin
    (* Validate handle *)
    if (FHandle) then
    begin

      (* Issue a disconnect *)
      try
        Fhandle.disconnect();
      except
        on e: exception do
        raise EQTXMutationObserver.CreateFmt
        ('Failed to disconnect mutation observer, system threw <%>',
        [e.message]);
      end;

      (* Mark as not active *)
      FObserving:=False;

      (* trigger event if defined *)
      if assigned(OnDisconnect) then
      OnDisconnect(self);

    end else
    Raise EQTXMutationObserver.Create
    ('Mutation observer not allocated error');
  end;
end;


end.
