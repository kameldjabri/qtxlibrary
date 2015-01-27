unit qtx.font;

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


type

  (*  TextMetric information record.
      Returned by MeasureText() functions
      in response to measuring the width and height
      if a piece of HTML within an element's context *)
  TQTXTextMetric  = Record
    tmWidth:  Integer;
    tmHeight: Integer;
    function  toString:String;
  End;

  (* FontInfo information record.
     Returned by getFontInfo() functions, which is a
     function that uses font detection to avail what
     font is selected into an element's context *)
  TQTXFontInfo = Record
    fiName: String;
    fiSize: Integer;
    function  toString:String;
  End;


  (* This is a very important class. It provides functions for:
    1. Detecting if a font is installed and can be used
    2. Measuring the width/height (metrics) of a piece of HTML
    3. -- // -- restricted to a fixed width
    4. -- // -- for the selected font on an element
  *)
  TQTXFontDetector = Class(TObject)
  private
    FBaseFonts:     array of string;
    FtestString:    String = "mmmmmmmmmmlli";
    FtestSize:      String = '72px';
    Fh:             THandle;
    Fs:             THandle;
    FdefaultWidth:  Variant;
    FdefaultHeight: Variant;
  public
    function    Detect(aFont:String):Boolean;

    function    MeasureText(aFontInfo:TQTXFontInfo;
                aContent:String):TQTXTextMetric;overload;

    function    MeasureText(aFontInfo:TQTXFontInfo;
                aFixedWidth:Integer;
                aContent:String):TQTXTextMetric;overload;

    function    MeasureText(aFontName:String;aFontSize:Integer;
                aContent:String):TQTXTextMetric;overload;

    function    MeasureText(aFontName:String;aFontSize:Integer;
                aFixedWidth:Integer;
                aContent:String):TQTXTextMetric;overload;

    function    getFontInfo(const aHandle:THandle):TQTXFontInfo;

    Constructor Create;virtual;
  End;

  function QTXFontDetector:TQTXFontDetector;


implementation

var
_FontDetect:TQTXFontDetector;

function QTXFontDetector:TQTXFontDetector;
begin
  result:=_FontDetect;
end;

//############################################################################
// TQTXTextMetric
//############################################################################

function TQTXTextMetric.toString:String;
Begin
  result:=Format('width=%d px, height=%d px',[tmWidth,tmHeight]);
end;

//############################################################################
// TQTXFontInfo
//############################################################################

function TQTXFontInfo.toString:String;
begin
  result:=Format('%s %dpx',[fiName,fiSize]);
end;

//############################################################################
// TQTXFontDetector
//############################################################################

Constructor TQTXFontDetector.Create;
var
  x:  Integer;
begin
  inherited Create;
  FBaseFonts.add('monospace');
  FBaseFonts.add('sans-serif');
  FBaseFonts.add('serif');

  Fh:=browserApi.document.body;

  Fs:=browserApi.document.createElement("span");
  Fs.style.fontSize:=FtestSize;
  Fs.innerHTML := FtestString;
  FDefaultWidth:=TVariant.createObject;
  FDefaultHeight:=TVariant.createObject;

  if FBaseFonts.Count>0 then
  for x:=FBaseFonts.low to FBaseFonts.high do
  begin
    Fs.style.fontFamily := FbaseFonts[x];
    Fh.appendChild(Fs);
    FdefaultWidth[FbaseFonts[x]]  :=  Fs.offsetWidth;
    FdefaultHeight[FbaseFonts[x]] :=  Fs.offsetHeight;
    Fh.removeChild(Fs);
  end;
end;

function TQTXFontDetector.getFontInfo(const aHandle:THandle):TQTXFontInfo;
var
  mName:  String;
  mSize:  Integer;
  mData:  Array of string;
  x:  Integer;
Begin
  result.fiSize:=-1;
  if aHandle.valid then
  begin
    mName:=w3_getStyleAsStr(aHandle,'font-family');
    mSize:=w3_getStyleAsInt(aHandle,'font-size');

    if length(mName)>0 then
    begin
      asm
        @mData = (@mName).split(",");
      end;
      if mData.Length>0 then
      Begin
        for x:=mData.low to mData.high do
        begin
          if Detect(mData[x]) then
          begin
            result.fiName:=mData[x];
            result.fiSize:=mSize;
            break;
          end;
        end;
      end;
    end;
  end;
end;

function TQTXFontDetector.Detect(aFont:String):Boolean;
var
  x:  Integer;
Begin
  aFont:=trim(aFont);
  if aFont.Length>0 then
  Begin
    if FBaseFonts.Count>0 then
    for x:=FBaseFonts.low to FBaseFonts.high do
    begin
      Fs.style.fontFamily:=aFont + ',' + FbaseFonts[x];
      Fh.appendChild(Fs);
      result:= (Fs.offsetWidth  <> FdefaultWidth[FBaseFonts[x]])
          and  (Fs.offsetHeight <> FdefaultHeight[FBaseFonts[x]]);
      Fh.removeChild(Fs);
      if result then
      break;
    end;
  end;
end;

function TQTXFontDetector.MeasureText(aFontInfo:TQTXFontInfo;
         aFixedWidth:Integer;
         aContent:String):TQTXTextMetric;
Begin
  result:=MeasureText(aFontInfo.fiName,aFontInfo.fiSize,aFixedWidth,aContent);
end;

function TQTXFontDetector.MeasureText(aFontInfo:TQTXFontInfo;
         aContent:String):TQTXTextMetric;
Begin
  result:=MeasureText(aFontInfo.fiName,aFontInfo.fiSize,aContent);
end;

function TQTXFontDetector.MeasureText(aFontName:String;aFontSize:Integer;
         aContent:String):TQTXTextMetric;
var
  mElement: THandle;
Begin
  if Detect(aFontName) then
  begin
    aContent:=trim(aContent);
    if length(aContent)>0 then
    begin
      mElement:=BrowserAPi.document.createElement("p");
      if (mElement) then
      begin
        mElement.style['font-family']:=aFontName;
        mElement.style['font-size']:=TInteger.toPxStr(aFontSize);
        mElement.style['overflow']:='scroll';

        mElement.style['display']:='inline-block';
        mElement.style['white-space']:='nowrap';

        mElement.innerHTML := aContent;
        Fh.appendChild(mElement);

        result.tmWidth:=mElement.scrollWidth;
        result.tmHeight:=mElement.scrollHeight;
        Fh.removeChild(mElement);

      end;
    end;
  end;
end;

function TQTXFontDetector.MeasureText(aFontName:String;aFontSize:Integer;
         aFixedWidth:Integer;
         aContent:String):TQTXTextMetric;
var
  mElement: THandle;
Begin
  if Detect(aFontName) then
  begin
    aContent:=trim(aContent);
    if length(aContent)>0 then
    begin
      mElement:=BrowserAPi.document.createElement("p");
      if (mElement) then
      begin
        mElement.style['font-family']:=aFontName;
        mElement.style['font-size']:=TInteger.toPxStr(aFontSize);
        mElement.style['overflow']:='scroll';

        mElement.style.maxWidth:=TInteger.toPxStr(aFixedWidth);
        mElement.style.width:=TInteger.toPxStr(aFixedWidth);

        mElement.innerHTML := aContent;
        Fh.appendChild(mElement);

        result.tmWidth:=mElement.scrollWidth;
        result.tmHeight:=mElement.scrollHeight;

        Fh.removeChild(mElement);

      end;
    end;
  end;
end;


Initialization
begin
  _FontDetect:=TQTXFontDetector.Create;
end;


end.
