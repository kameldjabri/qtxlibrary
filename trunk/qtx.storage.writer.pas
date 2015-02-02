unit qtx.storage.writer;


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

  TQTXWriter = Class(TObject)
  private
    FBuffer:  Variant;
  public
    function    Deserialize:String;
    procedure   Serialize(value:String);

    procedure   WriteStr(name:string;value:String;const encode:Boolean);overload;
    procedure   WriteInt(name:string;Value:Integer);overload;
    procedure   WriteBool(name:string;value:Boolean);overload;
    procedure   WriteFloat(name:String;value:Float);overload;
    procedure   WriteDateTime(name:String;value:TDateTime);overload;

    procedure   WriteStr(name:String;value:Array of String);overload;
    procedure   WriteInt(name:String;value:Array of integer);overload;
    procedure   WriteBool(name:String;value:Array of boolean);overload;
    procedure   WriteFloat(name:String;value:Array of float);overload;
    procedure   WriteDateTime(name:String;value:Array of TDateTime);overload;

    procedure   Write(name:String;value:variant);overload;virtual;
    procedure   Write(name:String;value:Array of variant);overload;

    Constructor Create(const aBuffer:Variant);virtual;
  end;

implementation

uses qtx.helpers;

//############################################################################
// TQTXWriter
//###########################################################################

Constructor TQTXWriter.Create(const aBuffer:Variant);
begin
  inherited Create;
  if not TVariant.IsNull(aBuffer)
  and not TQTXVariant.IsUnassigned(aBuffer) then
  FBuffer:=aBuffer else
  FBuffer:=TVariant.CreateObject;
end;

function TQTXWriter.Deserialize:String;
begin
  if (FBuffer<>unassigned)
  and (FBuffer<>NULL) then
  result:=JSON.Stringify(FBuffer);
end;

procedure TQTXWriter.Serialize(value:String);
begin
  value:=trim(Value);
  if value.length>0 then
  FBuffer:=JSON.Parse(value) else
  FBuffer:=TVariant.CreateObject;
end;

procedure TQTXWriter.Write(name:String;value:variant);
begin
  FBuffer[name]:=value;
end;

procedure TQTXWriter.Write(name:String;value:Array of variant);
Begin
  Write(name,value);
end;

procedure TQTXWriter.WriteStr(name:string;value:String;const encode:Boolean);
begin
  (* base64 encode string to avoid possible recursion
     should someone store another JSON object as a string *)
  if encode then
  Begin
    asm
      @value = btoa(@value);
    end;
  end;
  Write(name,value);
end;

procedure TQTXWriter.WriteInt(name:string;Value:Integer);
begin
  Write(name,value);
end;

procedure TQTXWriter.WriteBool(name:string;value:Boolean);
begin
  Write(name,value);
end;

procedure TQTXWriter.WriteFloat(name:String;value:Float);
begin
  Write(name,value);
end;

procedure TQTXWriter.WriteDateTime(name:String;value:TDateTime);
begin
  Write(name,value);
end;

procedure TQTXWriter.WriteStr(name:String;value:Array of String);
begin
  Write(name,value);
end;

procedure TQTXWriter.WriteInt(name:String;value:Array of integer);
begin
  Write(name,value);
end;

procedure TQTXWriter.WriteBool(name:String;value:Array of boolean);
begin
  Write(name,value);
end;

procedure TQTXWriter.WriteFloat(name:String;value:Array of float);
begin
  Write(name,value);
end;

procedure TQTXWriter.WriteDateTime(name:String;value:Array of TDateTime);
begin
  Write(name,value);
end;




end.
