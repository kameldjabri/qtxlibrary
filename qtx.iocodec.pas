unit qtx.iocodec;

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


end.
