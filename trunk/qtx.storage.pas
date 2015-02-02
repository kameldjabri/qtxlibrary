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
  TQTXStorage = Class(TObject)
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

  TQTXFileSystemObject      = Class;
  TQTXFileSystemFolder      = Class;
  TQTXFileSystemFile        = Class;
  TQTXFileSystemObjectList  = Array of TQTXFileSystemObject;

  TQTXFileSystemObject = Class(TObject)
  private
    FName:      String;
    FSize:      Integer;
    FParent:    TQTXFileSystemFolder;
  protected
    FChildren:  TQTXFileSystemObjectList;

    procedure setName(value:String);

    function  getName:String;virtual;
    function  getSize:Integer;virtual;
    property  Size:Integer read getSize;

    Property  Files[index:Integer]:TQTXFileSystemObject
              read ( FChildren[index] );
    property  Count:Integer
              read ( FChildren.length );

  public
    Property  Parent:TQTXFileSystemFolder read FParent;
    Property  Name:String read getName;
    Constructor Create(Aowner:TQTXFileSystemFolder);
  end;

  TQTXFileSystemObjectClass = Class of TQTXFileSystemObject;

  TQTXFileSystemFolder = Class(TQTXFileSystemObject)
  protected
    function  getFileObj(aFileName:String):TQTXFileSystemObject;
    function  getPath:String;virtual;
  public
    Property  Path:String read getPath;
    Property  Files;
    property  Count;
    function  FileExists(aFileName:String):Boolean;virtual;
    function  mkDir(aFilename:String):TQTXFileSystemFolder;virtual;
    function  mkFile(aFilename:String;const Data:Variant):TQTXFileSystemFile;virtual;
  end;

  IQTXFileSystemFile = Interface
    function  getData:Variant;
    procedure setData(Const value:Variant);
  end;

  TQTXFileSystemFile = Class(TQTXFileSystemObject,IQTXFileSystemFile)
  private
    FData:    Variant;
  protected
    function  getData:Variant;
    procedure setData(Const value:Variant);
  public
    property  Name;
  end;

  TQTXFileSystem = Class(TQTXFileSystemFolder)
  private
    FCurrent:   TQTXFileSystemFolder;
    //function    getNodeNames(Const clsType:TQTXFileSystemObjectClass):Array of String;
  protected
    function    getPath:String;override;
    function    getCurrent:TQTXFileSystemFolder;virtual;
  public
    Property    Files;
    Property    Count;
    Property    Current:TQTXFileSystemFolder read getCurrent;
    procedure   chDir(NewPath:String);

    function    FileExists(aFileName:String):Boolean;override;
    function    mkDir(aFilename:String):TQTXFileSystemFolder;override;
    function    mkFile(aFilename:String;const Data:Variant):TQTXFileSystemFile;override;
  end;


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
// TQTXFileSystem
//############################################################################

function TQTXFileSystem.getCurrent:TQTXFileSystemFolder;
begin
  if FCurrent=NIL then
  FCurrent:=self;
  result:=FCurrent;
end;

function TQTXFileSystem.FileExists(aFileName:String):Boolean;
begin
  if Current<>self then
  result:=Current.FileExists(aFilename) else
  result:=inherited FileExists(aFilename);
end;

function TQTXFileSystem.mkDir(aFilename:String):TQTXFileSystemFolder;
begin
  if Current<>self then
  result:=Current.mkdir(aFilename) else
  result:=inherited mkDir(aFilename);
end;

function TQTXFileSystem.mkFile(aFilename:String;
         const Data:Variant):TQTXFileSystemFile;
begin
  if Current<>self then
  result:=Current.mkFile(aFilename,Data) else
  result:=inherited mkFile(aFilename,Data);
end;

function TQTXFileSystem.getPath:String;
begin
  if Current<>Self then
  result:=Current.path else
  result:='/';
end;

procedure TQTXFileSystem.chDir(NewPath:String);
var
  mList:  Array of String;
  mItems: Array of String;
  x:  Integer;
  mItem:  TQTXFileSystemObject;
begin
  newPath:=newPath.Trim();
  if newpath.length>0 then
  begin

    (* strip left double delimiters *)
    while (newpath.length>0)
      and (newpath.left(1)="/") do
      newpath.DeleteLeft(1);

    (* strip right double delimiters *)
    while (newpath.length>0)
      and (newpath.right(1)="/") do
      newpath.DeleteRight(1);

    (* Strip contained double delimiters *)
    while newPath.Contains('//') do
    newPath:=newpath.Replace('//','/');

    mItems:=newPath.Explode('/');
    if mItems.length >0 then
    Begin

      FCurrent:=self;

      for x:=mitems.low to mItems.High do
      begin
        mItem:=Current.getFileObj(mItems[x]);
        if mItem<>NIL then
        Begin
          if (mItem is TQTXFileSystemFolder) then
          begin
            FCurrent:=TQTXFileSystemFolder(mItem);
          end else
          Raise exception.Create('Directory error, filename in path error');
        end else
        raise exception.create('Invalid path error');
      end;

    end;
  end;
end;

//############################################################################
// TQTXFileSystemFolder
//############################################################################

function TQTXFileSystemFolder.getPath:String;
var
  mItem:  TQTXFileSystemFolder;
begin
  result:='';
  mItem:=self;
  repeat
    result:=(mItem.Name + '\' + result);
    mItem:=mItem.Parent;
  until mItem=NIL;
end;

function TQTXFileSystemFolder.getFileObj(aFileName:String):TQTXFileSystemObject;
var
  x:  Integer;
begin
  result:=NIL;
  for x:=0 to Count-1 do
  begin
    if sameText(Files[x].Name,aFileName) then
    begin
      result:=Files[x];
      break;
    end;
  end;
end;

function TQTXFileSystemFolder.mkFile(aFilename:String;const Data:Variant):TQTXFileSystemFile;
var
  mItem:  TQTXFileSystemObject;
begin
  result:=NIL;

  aFileName:=aFileName.lowercase().trim();
  if aFileName.length>0 then
  begin
    if not FileExists(aFileName) then
    begin

      mItem:=TQTXFileSystemFile.Create(self);
      mItem.setName(aFileName);
      FChildren.Add(mItem);

      (* Default data? *)
      if not TQTXVariant.IsUnassigned(Data)
      and not TVariant.IsNull(Data) then
      (mItem as IQTXFileSystemFile).setData(Data);

      result:=TQTXFileSystemFile(mItem);
    end else
    raise exception.Create('File <' + name + '> already exists error');
  end;
end;

function TQTXFileSystemFolder.mkDir(aFileName:String):TQTXFileSystemFolder;
var
  mItem:  TQTXFileSystemObject;
begin
  result:=NIL;
  aFileName:=aFileName.lowercase().trim();
  if aFileName.length>0 then
  begin
    if not FileExists(aFileName) then
    begin

      mItem:=TQTXFileSystemFolder.Create(self);
      mItem.setName(aFileName);
      FChildren.Add(mItem);

      result:=TQTXFileSystemFolder(mItem);

    end else
    raise exception.Create('File <' + name + '> already exists error');
  end;
end;

function TQTXFileSystemFolder.FileExists(aFileName:String):Boolean;
var
  x:  Integer;
begin
  result:=False;
  for x:=0 to Count-1 do
  begin
    result:=sameText(Files[x].Name,aFileName);
    if result then
    break;
  end;
end;

//############################################################################
// TQTXFileSystemFile
//############################################################################

function TQTXFileSystemFile.getData:Variant;
begin
  result:=FData;
end;

procedure TQTXFileSystemFile.setData(Const value:Variant);
begin
  FData:=Value;
end;

//############################################################################
// TQTXFileSystemObject
//############################################################################

Constructor TQTXFileSystemObject.Create(Aowner:TQTXFileSystemFolder);
begin
  inherited Create;
  FParent:=AOwner;
end;

procedure TQTXFileSystemObject.setName(value:String);
begin
  FName:=value;
end;

function TQTXFileSystemObject.getName:String;
begin
  result:=FName;
end;

function TQTXFileSystemObject.getSize:Integer;
begin
  result:=FSize;
end;

//############################################################################
// TQTXStorage
//############################################################################


class procedure TQTXStorage.LoadScript(aFilename:String);
begin
  LoadScript(aFilename,NIL);
end;

class procedure TQTXStorage.LoadScript(aFilename:String;
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

class procedure TQTXStorage.PreloadImages(aFileNames:Array of String;
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


class function TQTXStorage.LoadImage(aFilename:String):THandle;
Begin
  result:=LoadImage(aFilename,NIL);
end;

class function TQTXStorage.LoadImage(aFilename:String;
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

class function TQTXStorage.LoadCSS(const aRel,aHref:String):THandle;
Begin
  result:=LoadCSS(aRel,aHref,NIL);
end;

class function TQTXStorage.LoadCSS(const aRel,aHref:String;
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

class procedure TQTXStorage.LoadFile(aFilename:String;
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

class procedure TQTXStorage.LoadXML(aFilename:String;
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
