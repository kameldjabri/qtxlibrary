unit qtx.storage.filesystem;

interface

uses 
  System.Types,
  SmartCL.System,
  qtx.helpers;

type


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

uses qtx.storage;

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



end.
