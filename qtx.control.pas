unit qtx.control;

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
  SmartCL.Components,
  qtx.attributes,
  qtx.font;

type


  (* This is an extension to TW3Customcontrol which provides:
    1. Attribute read/write access
    2. Text measurement both for instance and generic
    3. font analysis (instance and generic)

  When you include this unit, all TW3Customcontrol instances will
  contain these functions. *)
  TW3CustomControl = partial class(TW3MovableControl)
  private
    FAccess:    TQTXAttrAccess;
    function    getAccess:TQTXAttrAccess;
  public
    Property    ElementData:TQTXAttrAccess read getAccess;

    function    MeasureText(aContent:String):TQTXTextMetric;overload;
    function    MeasureTextFixed(aContent:String):TQTXTextMetric;overload;

    class function MeasureTextSize(const aHandle:THandle;
          const aContent:String):TQTXTextMetric;

    class function MeasureTextSizeF(const aHandle:THandle;
          const aWidth:Integer;const aContent:String):TQTXTextMetric;

    function    getFontInfo:TQTXFontInfo;overload;
    class function  getFontInfo(const aHandle:THandle):TQTXFontInfo;overload;

  end;

implementation

//############################################################################
// TW3CustomControl
//############################################################################

function TW3CustomControl.getAccess:TQTXAttrAccess;
Begin
  if FAccess=NIL then
  FAccess:=TQTXAttrAccess.Create(self.Handle);
  result:=FAccess;
end;

function TW3CustomControl.getFontInfo:TQTXFontInfo;
Begin
  result:=QTXFontDetector.getFontInfo(Handle);
end;

class function  TW3CustomControl.getFontInfo(const aHandle:THandle):TQTXFontInfo;
Begin
  result:=QTXFontDetector.getFontInfo(aHandle);
end;

function TW3CustomControl.MeasureText(aContent:String):TQTXTextMetric;
Begin
  aContent:=trim(aContent);
  if aContent.length>0 then
  begin
    result:=QTXFontDetector.MeasureText(
    QTXFontDetector.getFontInfo(Handle),aContent);
  end;
end;

function TW3CustomControl.MeasureTextFixed(aContent:String):TQTXTextMetric;
Begin
  aContent:=trim(aContent);
  if aContent.length>0 then
  begin
    result:=QTXFontDetector.MeasureText(
    QTXFontDetector.getFontInfo(Handle),ClientWidth,aContent);
  end;
end;

class function TW3CustomControl.MeasureTextSize(const aHandle:THandle;
      const aContent:String):TQTXTextMetric;
Begin
  if aHandle.valid then
  begin
    if aContent.length>0 then
    begin
      result:=QTXFontDetector.MeasureText(
      QTXFontDetector.getFontInfo(aHandle),aContent);
    end;
  end;
end;

class function TW3CustomControl.MeasureTextSizeF(const aHandle:THandle;
      const aWidth:Integer;const aContent:String):TQTXTextMetric;
Begin
  if aHandle.valid then
  begin
    if aContent.length>0 then
    begin
      result:=QTXFontDetector.MeasureText(
      QTXFontDetector.getFontInfo(aHandle),aWidth,aContent);
    end;
  end;
end;


end.
