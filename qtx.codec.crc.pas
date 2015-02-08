unit qtx.codec.crc;

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

  TQTXCodecCRC = Class(TQTXCustomCodec)
  public
    function  GetCodecCaps:TQTXCodecCapabilities;override;
    function  Encode(const data:variant):variant;override;
    function  Decode(const data:variant):variant;override;
  end;

implementation

uses qtx.helpers;

var
  CRC_TABLE:  array[0..512] of integer;

function TQTXCodecCRC.GetCodecCaps:TQTXCodecCapabilities;
begin
  /* This codec provides encoding only */
  result:=[ccEncode];
end;

function TQTXCodecCRC.Encode(const Data:variant):variant;
var
  i:  Integer;
  res:  Integer;
  cc  : Integer;
begin

  res:= $FFFFFFFF;
  for i:=1 to String(data).length do
  begin
    cc:=String(data).charCode(i);
    res:= (res shr 8) xor CRC_TABLE[ cc  XOR (res and $000000FF)];
  end;

  asm
    @result = ( (@res ^ -1) >>> 0);
  end;
end;

function  TQTXCodecCRC.Decode(const data:variant):variant;
begin
  result:=Data;
end;

procedure BuildCRCTable;
const
  CRCPOLY = $EDB88320;
var
  i, j: Integer;
  r: Integer;
begin
  for i := 0 to 255 do
  begin
    r := i shl 1;
    for j := 8 downto 0 do
    begin
      if (r and 1) <> 0 then
      r := (r Shr 1) xor CRCPOLY else
      r := r shr 1;
      CRC_TABLE[i] := r;
    end;
  end;
end;


initialization
begin
  BuildCRCTable;
end;


end.
