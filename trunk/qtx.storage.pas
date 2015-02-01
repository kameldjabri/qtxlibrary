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


  IQTXSerialization  = Interface
    function  Deserialize:String;
    procedure Serialize(value:String);
  end;

  TQTXWriter = Class(TObject,IQTXSerialization)
  private
    FBuffer:  Variant;
  public
      (* IMPLEMENTS:: IQTXSerialization *)
    function    Deserialize:String;
    procedure   Serialize(value:String);
  public
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

  TQTXReader = Class(TObject,IQTXSerialization)
  private
    FBuffer:  Variant;
  public
    (* IMPLEMENTS:: IQTXSerialization *)
    function    Deserialize:String;
    procedure   Serialize(value:String);
  public
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

  TQTXCustomCodec = class(TObject)
  public
    function  Encode(const data:Variant):Variant;virtual;
    function  Decode(const data:Variant):Variant;virtual;
  end;

  TQTXRLECodec = Class(TQTXCustomCodec)
  public
    function  Encode(const data:String):String;reintroduce;virtual;
    function  Decode(const data:String):String;reintroduce;virtual;
  end;

  TQTCRC4Codec = Class(TQTXCustomCodec)
  public
    Property  Key:String;
    function  Encode(const data:String):String;reintroduce;virtual;
    function  Decode(const data:String):String;reintroduce;virtual;
  end;

  TQTXBase64Codec = Class(TQTXCustomCodec)
  public
    function  Encode(const data:String):String;reintroduce;virtual;
    function  Decode(const Data:String):String;reintroduce;virtual;
  end;

  TQTXURICodec = Class(TQTXCustomCodec)
  public
    function  Encode(const data:String):String;reintroduce;virtual;
    function  Decode(const Data:String):String;reintroduce;virtual;
  end;

implementation

uses qtx.helpers;

//############################################################################
// TQTXURICodec
//###########################################################################

function  TQTXURICodec.Encode(const data:String):String;
begin
  if data.length>0 then
  begin
    asm
      @result = encodeURI(@data);
    end;
  end else
  Raise Exception.Create('Encoding failed, input was empty or invalid error');
end;

function  TQTXURICodec.Decode(const Data:String):String;
Begin
  if data.length>0 then
  begin
    asm
      @result = decodeURI(@data);
    end;
  end else
  Raise Exception.Create('Decoding failed, input was empty or invalid error');
end;

//############################################################################
// TQTXBase64Codec encodeURI
//###########################################################################

function  TQTXBase64Codec.Encode(const data:String):String;
begin
  if data.length>0 then
  begin
    asm
      @result = btoa(@data);
    end;
  end else
  Raise Exception.Create('Encoding failed, input was empty or invalid error');
end;

function  TQTXBase64Codec.Decode(const Data:String):String;
Begin
  if data.length>0 then
  begin
    asm
      @result = atob(@data);
    end;
  end else
  Raise Exception.Create('Decoding failed, input was empty or invalid error');
end;

//############################################################################
// TQTCRC4Codec
//###########################################################################

function TQTCRC4Codec.Encode(const data:String):String;
var
  mKey: String;
begin
  result:="";
  mKey:=self.key;
  if mKey.length>0 then
  Begin
    if data.length>0 then
    begin
      asm
        var s = [], j = 0, x, res = '';
        for (var i = 0; i < 256; i++) {
          s[i] = i;
        }
        for (i = 0; i < 256; i++) {
          j = (j + s[i] + (@mKey).charCodeAt(i % (@mKey).length)) % 256;
          x = s[i];
          s[i] = s[j];
          s[j] = x;
        }

        i = 0;
        j = 0;
        for (var y = 0; y < (@data).length; y++) {
          i = (i + 1) % 256;
          j = (j + s[i]) % 256;
          x = s[i];
          s[i] = s[j];
          s[j] = x;
          @result += String.fromCharCode((@data).charCodeAt(y)
            ^ s[(s[i] + s[j]) % 256]);
        }
      end;
    end;
  end else
  Raise Exception.Create('Decoding failed, invalid or empty key error');
end;

function TQTCRC4Codec.Decode(const Data:String):String;
begin
  if key.length>0 then
  result:=Encode(Data) else
  Raise Exception.Create('Decoding failed, invalid or empty key error');
end;

//############################################################################
// TQTXRLECodec
//###########################################################################

function TQTXRLECodec.Encode(const data:String):String;
begin
  asm
    @result = new Array;
    if((@data).length == 0)  {
		  @result = "";
    } else {
      var count = 1;
      var r = 0;
      for(var i = 0; i < ((@data).length - 1); i++) {
		    if(@data[i] != @data[i+1])
        {
          @result[r] = @data[i];
          @result[r+1] = count;
          count = 0;
          r +=2;
        }
		    count++;
      }
      @result[r] = @data[i];
      @result[r+1] = count;
    }
  end;
  writeln(result);
end;

function TQTXRLECodec.Decode(const Data:String):String;
begin
  asm
    @result = new Array;
    if((@data).length == 0) {
      return result;
    } else {
      if(((@data).length % 2) <> 0)
      {
        for(var i = 0; i < (@data).length; i+=2)
        {
          var val = @data[i];
          var count = @data[i+1];
          for(var c = 0; c < count; c++)
            @result[(@result).length] = val;
        }
      }
    }
  end;
end;

//############################################################################
// TQTXCustomCodec
//###########################################################################

function TQTXCustomCodec.Encode(const data:Variant):Variant;
begin
  result:=null;
  Raise Exception.Create('NOT IMPLEMENTED');
end;

function TQTXCustomCodec.Decode(const Data:Variant):Variant;
begin
  result:=null;
  Raise Exception.Create('NOT IMPLEMENTED');
end;

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
