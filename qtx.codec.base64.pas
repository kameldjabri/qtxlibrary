unit qtx.codec.base64;

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

interface

uses 
  system.types,
  SmartCL.System,
  qtx.codec;


type

  (* Base64 codec *)
  TQTXBase64Codec = Class(TQTXCustomCodec)
  public
    function  Encode(const data:String):String;override;
    function  Decode(const data:String):String;override;
  end;


implementation

uses  qtx.helpers;


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




end.
