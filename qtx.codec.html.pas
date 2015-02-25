unit qtx.codec.html;

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
  SmartCL.System,
  qtx.codec.base,
  qtx.storage.options;

type

  (* Base64 codec *)
  TQTXHTMLCodec = Class(TQTXCustomCodec)
  public
    function  Encode(const data:variant):variant;override;
    function  Decode(const data:variant):variant;override;
  end;


implementation

uses qtx.helpers;

function TQTXHTMLCodec.Encode(const data:variant):variant;
begin
  result:=unassigned;
  if data.IsString then
  begin
    if string(data).length>0 then
    begin
      asm
        @result = (@data).replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;');
      end;
    end;
  end else
  raise EW3Exception.Create('Invalid datatype for codec, expected string');
end;

function TQTXHTMLCodec.Decode(const data:variant):variant;
begin
  result:=unassigned;
  if data.IsString then
  begin
    if string(data).length>0 then
    begin
      asm
        @result = (@data).replace(/&amp;/g, '&')
          .replace(/&lt;/g, '<')
          .replace(/&gt;/g, '>');
      end;
    end;
  end else
  raise EW3Exception.Create('Invalid datatype for codec, expected string');
end;

end.
