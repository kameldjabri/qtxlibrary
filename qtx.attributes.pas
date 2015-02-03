unit qtx.attributes;

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

  (* This class provides <TAG Attr=Value ATTR=Value> attribute read/write
     access. Under HTML5 all attributes which starts with "data-" are
     ignored by the browser and can be accessed by javascript.
     This is perfect for storing information about a tag construct.
     In our case we also use it to mark an element (control) with a busy
     flag for effects. So while an effect is running, its state is stored
     in the actual tag which is affected.
     This gives the tag a high level of freedom, since a JS instance does
     not have to be permanently connected to the tag. *)
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


implementation


const
  (* Prefix for "data-attr" tag fields.
     All data-attributes are ignored by the browser, and resemble the "tag"
     property in Delphi. JS coders use it to store persistent data which
     belongs to a construct. Perfect for effects which are triggered by
     a single command, and thus can remain persistent without any
     instance connected to it *)
  CNT_ATTR_PREFIX = 'data-';

resourcestring
CNT_ERR_ATTR_InvalidHandle =
'Failed to create attribute storage object, invalid handle error';

CNT_ERR_ATTR_FailedRead =
'Failed to read attribute field, browser threw exception: %s';

CNT_ERR_ATTR_FailedWrite =
'Failed to write attribute field, browser threw exception: %s';


//############################################################################
// TQTXAttrAccess
//############################################################################

Constructor TQTXAttrAccess.Create(Const aHandle:THandle);
Begin
  inherited Create;
  if aHandle.valid then
  FHandle:=aHandle else
  raise Exception.Create(CNT_ERR_ATTR_InvalidHandle);
end;

function  TQTXAttrAccess.Exists(aName:String):Boolean;
var
  mName:  String;
begin
  mName:=lowercase(CNT_ATTR_PREFIX + aName);
  result:=FHandle.hasAttribute(mName);
end;

function  TQTXAttrAccess.Read(aName:String):Variant;
var
  mName:  String;
begin
  try
    mName:=lowercase(CNT_ATTR_PREFIX + aName);
    if FHandle.hasAttribute(mName) then
    Result := FHandle.getAttribute(mName) else
    result:=null;
  except
    on e: exception do
    raise EW3Exception.CreateFmt(CNT_ERR_ATTR_FailedRead,[e.message]);
  end;
end;

procedure TQTXAttrAccess.Write(aName:String;const aValue:Variant);
var
  mName:  String;
begin
  try
    mName:=lowercase(CNT_ATTR_PREFIX + aName);
    FHandle.setAttribute(mName, aValue);
  except
    on e: exception do
    raise EW3Exception.CreateFmt(CNT_ERR_ATTR_FailedWrite,[e.message]);
  end;
end;




end.
