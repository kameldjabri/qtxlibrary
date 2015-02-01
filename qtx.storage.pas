unit qtx.storage;

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

  TQTXReader = Class(TObject)
  private
    FBuffer:  Variant;
  public
    function    Deserialize:String;
    procedure   Serialize(value:String);

    function    ReadStr(name:String;const decode:Boolean):String;
    function    ReadStrA(name:String):Array of String;

    function    ReadInt(name:String):Integer;
    function    ReadIntA(name:String):Array of integer;

    function    ReadBool(name:String):Boolean;
    function    ReadBoolA(name:String):Array of boolean;

    function    ReadFloat(name:String):float;
    function    ReadFloatA(name:String):Array of float;

    function    ReadDateTime(name:String):TDateTime;
    function    ReadDateTimeA(name:String):Array of TDateTime;

    function    Read(name:String):Variant;

    Constructor Create(const aBuffer:Variant);virtual;
  end;

implementation

uses qtx.helpers;

//############################################################################
// TQTXReader
//###########################################################################

Constructor TQTXReader.Create(const aBuffer:Variant);
begin
  inherited Create;
  if not TQTXVariant.IsUnassigned(aBuffer) then
  Begin
    if not TVariant.IsNull(aBuffer) then
    begin
      (* The constructor can accept serialized JSON strings *)
      if TVariant.IsString(aBuffer) then
      serialize(aBuffer) else
      Fbuffer:=aBuffer;
    end else
    FBuffer:=TVariant.CreateObject;
  end else
  FBuffer:=TVariant.CreateObject;
end;

function TQTXReader.Deserialize:String;
begin
  if (FBuffer<>unassigned)
  and (FBuffer<>NULL) then
  result:=JSON.Stringify(FBuffer);
end;

procedure TQTXReader.Serialize(value:String);
begin
  value:=trim(Value);
  if value.length>0 then
  FBuffer:=JSON.Parse(value) else
  FBuffer:=TVariant.CreateObject;
end;

function TQTXReader.Read(name:String):Variant;
begin
  result:=FBuffer[name];
end;

function TQTXReader.ReadStr(name:String;const decode:Boolean):String;
begin
  result:=FBuffer[name];
  if decode then
  begin
    asm
      @result = atob(@result);
    end;
  end;
end;

function TQTXReader.ReadStrA(name:String):Array of String;
begin
  asm
    @result = @FBuffer[@name];
  end;
end;

function TQTXReader.ReadInt(name:String):Integer;
begin
  result:=FBuffer[name];
end;

function TQTXReader.ReadIntA(name:String):Array of integer;
begin
  asm
    @result = @FBuffer[@name];
  end;
end;

function TQTXReader.ReadBool(name:String):Boolean;
begin
  result:=FBuffer[name];
end;

function TQTXReader.ReadBoolA(name:String):Array of boolean;
begin
  asm
    @result = @FBuffer[@name];
  end;
end;

function TQTXReader.ReadFloat(name:String):float;
begin
  result:=FBuffer[name];
end;

function TQTXReader.ReadFloatA(name:String):Array of float;
begin
  asm
    @result = @FBuffer[@name];
  end;
end;

function TQTXReader.ReadDateTime(name:String):TDateTime;
begin
  result:=FBuffer[name];
end;

function TQTXReader.ReadDateTimeA(name:String):Array of TDateTime;
begin
  asm
    @result = @FBuffer[@name];
  end;
end;

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
