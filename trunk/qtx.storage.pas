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
    function  getPath:String;virtual;

    function  getName:String;virtual;
    function  getSize:Integer;virtual;
    property  Size:Integer read getSize;

    Property  Files[index:Integer]:TQTXFileSystemObject
              read ( FChildren[index] );
    property  Count:Integer
              read ( FChildren.length );

  public
    property  Path:String read getPath;
    Property  Parent:TQTXFileSystemFolder read FParent;
    Property  Name:String read getName;
    Constructor Create(Aowner:TQTXFileSystemFolder);
  end;

  TQTXFileSystemObjectClass = Class of TQTXFileSystemObject;

  TQTXFileSystemFolder = Class(TQTXFileSystemObject)
  protected
    function  getLocalFileObj(aFileName:String):TQTXFileSystemObject;
  public
    Property  Files;
    property  Count;

    function  FindFileObject(aFilename:String):TQTXFileSystemObject;

    function  getValidPath(aFilename:String):Boolean;

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
    procedure WriteData(Value:Variant);virtual;
    function  ReadData:Variant;virtual;
    property  Name;
  end;

  TQTXFileSystem = Class(TQTXFileSystemFolder)
  private
    FCurrent:   TQTXFileSystemFolder;
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
        mItem:=Current.getLocalFileObj(mItems[x]);
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

function TQTXFileSystemFolder.findFileObject
        (aFilename:String):TQTXFileSystemObject;
var
  mList:  Array of String;
  mItems: Array of String;
  x:  Integer;
  mItem:  TQTXFileSystemObject;
  mCurrent: TQTXFileSystemFolder;
  mFile:  String;
begin
  result:=NIL;
  aFilename:=aFilename.Trim();
  if aFilename.length>0 then
  begin

    (* strip left double delimiters *)
    while (aFilename.length>0)
      and (aFilename[1]="/") do
      delete(aFilename,1,1);

    (* strip right double delimiters *)
    while (aFilename.length>0)
      and (aFilename[aFilename.length]="/") do
      delete(aFilename,aFilename.length,1);

    (* Strip contained double delimiters *)
    while aFilename.Contains('//') do
    aFilename:=aFilename.Replace('//','/');

    (* Still valid ? *)
    aFilename:=aFilename.trim();
    if aFilename.length=0 then
    exit;

    (* grab filename *)
    mFile:=ExtractFileName(aFilename);

    //writeln('filename:' + mFile);
    //writeln('Ext:' + ExtractFileExt(mFile));

    if ExtractFileExt(mFile).length>0 then
    begin
      mItems:=aFilename.Explode('/');
      //writeln('Deleting:' + mItems[mitems.length-1]);
      mItems.Delete(mItems.length-1,1);
    end else
    Begin
      mFile:='';
      mItems:=aFilename.Explode('/');
    end;

    (* writeln('Working with:' + aFilename);
    for x:=mItems.low to mitems.high do
    begin
      writeln('   ' + mitems[x]);
    end; *)

    mCurrent:=self;
    if mItems.length >0 then
    Begin
      for x:=mitems.low to mItems.High do
      begin
        mItem:=mCurrent.getLocalFileObj(mItems[x]);
        if mItem<>NIL then
        begin
          if (mItem is TQTXFileSystemFolder) then
          mCurrent:=TQTXFileSystemFolder(mItem) else
          Begin
            mCurrent:=NIL;
            break;
          end;
        end else
        begin
          mCurrent:=NIL;
          break;
        end;
      end;
    end;

    if mCurrent<>NIl then
    begin
      if mFile.length>0 then
      begin
        if mCurrent.FileExists(mFile) then
        result:=mCurrent.getLocalFileObj(mFile);
      end else
      result:=mCurrent;
    end;

  end;
end;

function TQTXFileSystemFolder.getValidPath(aFilename:String):Boolean;
begin
  result:=FindFileObject(aFilename)<>NIL;
end;

function TQTXFileSystemFolder.getLocalFileObj
         (aFileName:String):TQTXFileSystemObject;
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

function TQTXFileSystemFolder.mkFile(aFilename:String;
         const Data:Variant):TQTXFileSystemFile;
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
    raise exception.Create
    ('A filesystem object <' + name + '> already exists error');
  end;
end;

function TQTXFileSystemFolder.FileExists(aFileName:String):Boolean;
begin
  if aFilename.Contains('/') then
  result:=self.FindFileObject(aFilename)<>NIL else
  result:=self.getLocalFileObj(aFilename)<>NIL;
end;

//############################################################################
// TQTXFileSystemFile
//############################################################################

procedure TQTXFileSystemFile.WriteData(Value:Variant);
begin
  setData(Value);
end;

function TQTXFileSystemFile.ReadData:Variant;
begin
  result:=getData;
end;

function TQTXFileSystemFile.getData:Variant;
begin
  if not TQTXVariant.IsUnassigned(FData)
  and not TVariant.IsNull(FData) then
  result:=JSON.parse(FData) else
  result:=null;
end;

procedure TQTXFileSystemFile.setData(Const value:Variant);
begin
  if not TQTXVariant.IsUnassigned(value)
  and not TVariant.IsNull(value) then
  FData:=JSON.Stringify(Value) else
  FData:=null;
end;

//############################################################################
// TQTXFileSystemObject
//############################################################################

Constructor TQTXFileSystemObject.Create(Aowner:TQTXFileSystemFolder);
begin
  inherited Create;
  FParent:=AOwner;
end;

function TQTXFileSystemObject.getPath:String;
var
  mItem:  TQTXFileSystemObject;
begin
  result:='';
  if parent<>NIL then
  begin
    mItem:=self.parent;
    repeat
      result:=(mItem.Name + '\' + result);
      mItem:=mItem.Parent;
    until mItem=NIL;

    result += self.name;
  end else
  result:=Name;
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
