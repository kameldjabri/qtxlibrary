unit qtx.storage.common;

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


function ExtractFileName(aPath:String):String;
function ExtractFileExt(aFilename:String):String;

implementation


function ExtractFileName(aPath:String):String;
var
  x:  Integer;
begin
  result:='';

  aPath:=aPath.trim();
  if (aPath.length>0) then
  begin
    if aPath[aPath.length]<>'/' then
    begin

      for x:=aPath.high downto aPath.low do
      begin
        if aPath[x]<>'/' then
        result:=(aPath[x] + result) else
        break;
      end;

    end;
  end;
end;

function ExtractFileExt(aFilename:String):String;
var
  x:  integer;
Begin
  result:='';
  afileName:=aFilename.trim();
  if aFilename.length>0 then
  begin
    for x:=aFilename.high downto aFilename.low do
    begin
      if (aFilename[x]<>'.') then
      begin
        if (aFilename[x]<>'/') then
        result:=(aFilename[x] + result) else
        break;
      end else
      begin
        result:=(aFilename[x] + result);
        break;
      end;
    end;

    if result.length>0 then
    begin
      if result[1]<>'.' then
      result:='';
    end;

  end;
end;


end.