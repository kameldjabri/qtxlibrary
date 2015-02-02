unit qtx.codec.rc4;

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
  qtx.codec,
  qtx.storage.options;

type

  (* RC4 encryption codec *)
  TQTCRC4Codec = Class(TQTXCustomCodec)
  public
    Property  Key:String;
    Procedure SetOptions(Const Options:TQTXOptions);override;
    function  Encode(const data:String):String;override;
    function  Decode(const data:String):String;override;
  end;


implementation

uses  qtx.helpers;

//############################################################################
// TQTCRC4Codec
//###########################################################################

Procedure TQTCRC4Codec.SetOptions(Const Options:TQTXOptions);
begin
  if options<>NIl then
  begin
    Key:=options.Option['key']
  end;
end;

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

end.
