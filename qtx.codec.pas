unit qtx.codec;

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
  qtx.options;

type

  (*  Codecs:
      A codec is a class which does two things, namely to:
        1.  Encode a piece of input data
        2.  Decode a previously Encoded piece of data

      A codec is traditionally associated with video and audio processing,
      but in reality the concept is applicable to almost any process
      which deals with standard IO processing.

      Technology such as compression, encryption and data-mapping have almost
      everything in common with a codec, hence my library treats them
      all the same.

      Note: Since some codec's require unique properties to be set,
            properties that cant be refactored so easily, the base codec
            class has a method called "SetOptions". You can override this
            to accept a standard TQTXOptions instance, from where you can
            read in any values you need.

            Users must also be aware of this, since they in turn have to
            deliver mentioned TQTXOptions instance fully populated.

      Tip:  All of this has been neatly isolated in classes and helper
            functions. You can encode and decode with a call to:

            QTX_Encode(Const Data:String;
            Const Options:TQTXOptions;
            Const Codec:TQTXCodecClassType):String;

            QTX_Decode(Const Data:String;
            Const Options:TQTXOptions;
            Const Codec:TQTXCodecClassType):String;

            So you dont need to create codec instances directly.
            Use the helper functions as a proxy.
       *)


  EQTXCodecException = Class(EW3Exception);

  (* This is the base-class from which all codec's derive *)
  TQTXCustomCodec = class(TObject)
  public
    Procedure SetOptions(Const Options:TQTXOptions);virtual;
    function  Encode(const data:String):String;virtual;
    function  Decode(const data:String):String;virtual;
  end;

  TQTXCodecClassType = Class of TQTXCustomCodec;

  function  QTX_Encode(Const Data:String;
            Const Options:TQTXOptions;
            Const Codec:TQTXCodecClassType):String;


  function  QTX_Decode(Const Data:String;
            Const Options:TQTXOptions;
            Const Codec:TQTXCodecClassType):String;


resourcestring
  QTX_CODEC_ERR_InvalidInputData  =
    'Codec operation failed, invalid input data error';

  QTX_CODEC_ERR_InvalidOption     =
    'Codec operation failed, invalid option value error';

  QTX_CODEC_ERR_NILCodec  =
    'Codec operation failed, codec reference was NIL or undefined error';

implementation

uses  qtx.helpers;

//############################################################################
// HELPER ROUTINES
//###########################################################################


function  QTX_Decode(const Data:String;
          Const Options:TQTXOptions;
          Const Codec:TQTXCodecClassType):String;
var
  mCodec: TQTXCustomCodec;
begin
  if data.length>0 then
  begin
    if codec<>NIL then
    Begin
      mCodec:=Codec.Create;
      try

        if Options<>NIL then
        mCodec.SetOptions(Options);

        result:=mCodec.Decode(Data);
      finally
        mCodec.free;
      end;

    end else
    raise EQTXCodecException.Create(QTX_CODEC_ERR_NILCodec);
  end else
  Raise EQTXCodecException.Create(QTX_CODEC_ERR_InvalidInputData);
end;

function  QTX_Encode(const Data:String;
          Const Options:TQTXOptions;
          Const Codec:TQTXCodecClassType):String;
var
  mCodec: TQTXCustomCodec;
begin
  if data.length>0 then
  begin
    if codec<>NIL then
    Begin
      mCodec:=Codec.Create;
      try

        if Options<>NIL then
        mCodec.SetOptions(Options);

        result:=mCodec.Encode(Data);
      finally
        mCodec.free;
      end;

    end else
    raise EQTXCodecException.Create(QTX_CODEC_ERR_NILCodec);
  end else
  Raise EQTXCodecException.Create(QTX_CODEC_ERR_InvalidInputData);
end;

//############################################################################
// TQTXCustomCodec
//###########################################################################

Procedure TQTXCustomCodec.SetOptions(Const Options:TQTXOptions);
begin
  Raise Exception.Create('NOT IMPLEMENTED');
end;

function TQTXCustomCodec.Encode(const data:string):string;
begin
  result:=null;
  Raise Exception.Create('NOT IMPLEMENTED');
end;

function TQTXCustomCodec.Decode(const Data:string):string;
begin
  result:=null;
  Raise Exception.Create('NOT IMPLEMENTED');
end;


end.
