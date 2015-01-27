unit qtx.ioaccess;

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
  SmartCL.System,
  SmartCL.Inet,
  w3c.dom;

type

  TQTXTextDataReadyEvent = procedure
    (sender:TW3HttpRequest;aText:String);

  TQTXXMLDataReadyEvent = procedure
    (sender:TW3HttpRequest;aObject:JXMLDocument);

  (* This class isolates common functionality for loading resource files.
     All methods accept a callback delegate, which can be used to track
     loaded files - or know when to begin something that relies on
     a file being loaded. *)
  TQTXIOAccess = Class(TObject)
  public
    (* Loading XML without a callback serves no purpose, so I dont
       provide an overloaded versin *)
    class procedure LoadXML(aFilename:String;
          const OnComplete:TQTXXMLDataReadyEvent);

    (* Loading a HTML or Textfile without a processing
       callback has no purpose, so no overloaded version here *)
    class procedure LoadFile(aFilename:String;
          const OnComplete:TQTXTextDataReadyEvent);

    class function LoadCSS(const aRel,aHref:String;
         const OnComplete:TProcedureRef):THandle;overload;
    class function LoadCSS(const aRel,aHref:String):THandle;overload;

    class Procedure LoadScript(aFilename:String;
          const OnComplete:TProcedureRef);overload;
    class procedure LoadScript(aFilename:String);overload;

    class function LoadImage(aFilename:String;
          const OnComplete:TProcedureRef):THandle;overload;
    class function LoadImage(aFilename:String):THandle;overload;

    class Procedure PreloadImages(aFileNames:Array of String;
          const OnComplete:TProcedureRef);

  End;


implementation

uses qtx.helpers;

type
TQTXPreLoadBatch = Record
  id:       String;
  Count:    Integer;
  Callback: TProcedureRef;
End;

var
_PreloadImages: Array of TQTXPreLoadBatch;


resourcestring

CNT_ERR_IO_FailedLoadScript = 'Failed to load script-file [%s] error';
CNT_ERR_IO_FailedLoadImage  = 'Failed to load image.file [%s] error';
CNT_ERR_IO_FailedLoadCSS    = 'Failed to load CSS file [%s] error';

//############################################################################
// TQTXIOAccess
//############################################################################


class procedure TQTXIOAccess.LoadScript(aFilename:String);
begin
  LoadScript(aFilename,NIL);
end;

class procedure TQTXIOAccess.LoadScript(aFilename:String;
      const OnComplete:TProcedureRef);
var
  mRef: THandle;
Begin
  asm
    @mRef = document.createElement("script");
  end;
  if mRef.valid then
  begin
    mRef.setAttribute("src",aFilename);
    if assigned(OnComplete) then
    mRef.onload := procedure ()
      begin
        OnComplete();
      end;

    asm
      document.getElementsByTagName('head')[0].appendChild(@mRef);
    end;

  end else
  raise EW3Exception.CreateFmt(CNT_ERR_IO_FailedLoadScript,[aFilename]);
end;

class procedure TQTXIOAccess.PreloadImages(aFileNames:Array of String;
      const OnComplete:TProcedureRef);
var
  x:  Integer;
  mBatch: TQTXPreLoadBatch;
Begin
  if aFilenames.length>0 then
  begin
  (* Create preload batch *)
  mBatch.id:=String.CreateGUID;
  mBatch.Count:=aFileNames.Count;
  mBatch.callback:=OnComplete;

  (* push to list *)
  _PreLoadImages.push(mBatch);

  for x:=aFilenames.low to aFilenames.high do
  Begin
    LoadImage(aFilenames[x], procedure ()
      begin
        if mBatch.Count>0 then
        begin
          dec(mBatch.Count);
          if mBatch.Count=0 then
          begin
              (* Batch done, callback *)
              if assigned(mBatch.callback) then
              mBatch.callback();

            (* Delete batch record *)
            _PreLoadImages.delete(_preloadimages.indexOf(mBatch));
          end;
        end;
      end);
    end;
  end;
end;


class function TQTXIOAccess.LoadImage(aFilename:String):THandle;
Begin
  result:=LoadImage(aFilename,NIL);
end;

class function TQTXIOAccess.LoadImage(aFilename:String;
          const OnComplete:TProcedureRef):THandle;
Begin

  asm
    @result = new Image();
  end;

  if result.valid then
  Begin
    if assigned(OnComplete) then
    result.onload := procedure ()
      begin
        OnComplete();
      end;

    result.src := aFilename;
  end else
  Raise EW3Exception.CreateFmt(CNT_ERR_IO_FailedLoadImage,[aFilename]);
end;

class function TQTXIOAccess.LoadCSS(const aRel,aHref:String):THandle;
Begin
  result:=LoadCSS(aRel,aHref,NIL);
end;

class function TQTXIOAccess.LoadCSS(const aRel,aHref:String;
      const OnComplete:TProcedureRef):THandle;
var
  mLink:  THandle;
Begin
  //REL: Can be "stylesheet" and many more values.
  //     See http://www.w3schools.com/tags/att_link_rel.asp
  //     for a list of all options
  asm
  @mLink = document.createElement('link');
  end;

  if mLink.valid then
  begin
    asm
    (@mLink).href = @aHref;
    (@mLink).rel=@aRel;
    document.head.appendChild(@mLink);
    end;

    if assigned(OnComplete) then
    mLink.onload := procedure ()
    Begin
      OnComplete();
    end;

    result:=mLink;
  end else
  Raise EW3Exception.CreateFmt(CNT_ERR_IO_FailedLoadCSS,[aHref]);
end;

class procedure TQTXIOAccess.LoadFile(aFilename:String;
      const OnComplete:TQTXTextDataReadyEvent);
var
  mLoader:  TW3HttpRequest;
Begin
  mLoader:=TW3HttpRequest.Create;
  mLoader.OnDataReady:=Procedure (sender:TW3HttpRequest)
  Begin
    try
      try
        if assigned(OnComplete) then
        OnComplete(mLoader,sender.responseText);
      except
        on e: exception do;
      end;
    finally
      mLoader.free;
    end;
  end;
  mLoader.OnError:=procedure (sender:TW3HttpRequest)
    Begin
      try
        if assigned(OnComplete) then
        OnComplete(mLoader,'');
      finally
        mLoader.free;
      end;
    end;
  mLoader.Get(aFilename);
end;

class procedure TQTXIOAccess.LoadXML(aFilename:String;
      const OnComplete:TQTXXMLDataReadyEvent);
var
  mLoader:  TW3HttpRequest;
Begin
  mLoader:=TW3HttpRequest.Create;
  mLoader.OnDataReady:=Procedure (sender:TW3HttpRequest)
  Begin
    try
      try
        if assigned(OnComplete) then
        OnComplete(mLoader,JXMLDocument(mLoader.ResponseXML));
      except
        on e: exception do;
      end;
    finally
      sender.free;
    end;
  end;
  mLoader.OnError:=procedure (sender:TW3HttpRequest)
    Begin
      try
        if assigned(OnComplete) then
        OnComplete(mLoader,NIL);
      finally
        mLoader.free;
      end;
    end;
  mLoader.Get(aFilename);
end;


end.
