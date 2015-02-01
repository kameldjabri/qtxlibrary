unit qtx.options;

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
  System.types,
  SmartCL.System;


type

  (* This ia generic name/value pair record. It is used by
     various classes throughout the QTX library *)
  TQTXOption = Record
    ppIdentifier: String;
    ppData: Variant;
    procedure init(Identifier:String;Data:Variant);
  end;
  TQTXOptionArray = Array of TQTXOption;


  (* This is a generic name/value pair option class.
     In many ways comparable to a COM propertybag.
     It allows you to write/add name-value-pairs to a list.
     The list is typically dispatched as a parameter for
     a special class. Codecs being an example *)
  TQTXOptions = Class(TObject)
  private
    FData:    TQTXOptionArray;
    function  getItem(Identifier:String):Variant;
    procedure setItem(Identifier:String;value:variant);
  public
    procedure Serialize(data:String);
    function  Deserialize:String;
    property  Option[Identifier:String]:Variant
              read getItem write setItem;
    function  Add(identifier:String;value:variant):Integer;
    function  IndexOf(identifier:String):Integer;
    procedure Clear;
  end;


implementation

uses  qtx.helpers;


//############################################################################
// TQTXOption
//###########################################################################

procedure TQTXOption.init(Identifier:String;Data:Variant);
begin
  ppIdentifier:=Identifier;
  ppData:=Data;
end;

//############################################################################
// TQTXOptions
//###########################################################################

procedure TQTXOptions.Clear;
begin
  FData.clear;
end;

procedure TQTXOptions.Serialize(data:String);
var
  mTemp:  Variant;
begin
  FData := TQTXOptionArray( JSON.parse(data) );
end;

function  TQTXOptions.Deserialize:String;
begin
  result:=JSON.Stringify(variant(FData));
end;

function TQTXOptions.Add(Identifier:String;value:variant):Integer;
var
  mItem:  TQTXOption;
begin
  mItem.init(Identifier,Value);
  FData.Add(mItem);
  result:=FData.High;
end;

function  TQTXOptions.getItem(Identifier:String):Variant;
var
  x:  Integer;
begin
  x:=IndexOf(Identifier);
  if x>=0 then
  result:=FData[x].ppData else
  result:=null;
end;

procedure TQTXOptions.setItem(Identifier:String;value:variant);
var
  mIndex: Integer;
begin
  mIndex:=IndexOf(Identifier);
  if mIndex>=0 then
  FData[mIndex].ppData:=Value else
  Add(Identifier,Value);
end;

function TQTXOptions.IndexOf(identifier:String):Integer;
var
  x:  Integer;
begin
  result:=-1;
  if FData.length>0 then
  Begin
    for x:=FData.low to FData.high do
    if SameText(FData[x].ppIdentifier,identifier) then
    begin
      result:=x;
      break;
    end;
  end;
end;




end.
