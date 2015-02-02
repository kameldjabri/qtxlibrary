unit qtx.codec.rle;

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

  (* Run-Length-Encoding text compression *)
  TQTXRLECodec = Class(TQTXCustomCodec)
  public
    function  Encode(const data:String):String;override;
    function  Decode(const data:String):String;override;
  end;

implementation

uses  qtx.helpers;


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


end.
