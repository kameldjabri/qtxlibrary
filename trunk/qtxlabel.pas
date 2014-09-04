unit qtxlabel;



//#############################################################################
//
//  Unit:       qtxlabel.pas
//  Author:     Jon Lennart Aasenden [cipher diaz of quartex]
//  Copyright:  Jon Lennart Aasenden, all rights reserved
//
//  Description:
//  ============
//  This unit contains a more lightweight label control.
//  It has no horizontal alignment, but for pure "text" labels which doesnt
//  need special treatment, this control is much better than TW3Label.
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
//#############################################################################

interface

uses 
  qtxutils,
  W3System, w3graphics, w3components;

type

  TQTXLabel = Class(TW3CustomControl)
  private
    FAuto:    Boolean;
    FOnChanged: TNotifyEvent;
  protected
    procedure AdjustSize;virtual;
    procedure setAuto(const aValue:Boolean);virtual;
    function  getCaption:String;virtual;
    Procedure setCaption(Const aValue:String);virtual;
    function  MakeElementTagId: String; override;
    procedure InitializeObject;override;
  published
    Property  OnChanged:TNotifyEvent read FOnChanged write FOnChanged;
    Property  Autosize:Boolean read FAuto write setAuto;
    Property  Caption:String read getCaption write setCaption;
  End;

implementation

//############################################################################
// TQTXLabel
//############################################################################

procedure TQTXLabel.InitializeObject;
Begin
  inherited;
  setAuto(True);
  setCaption(ClassName);

  Handle.readyExecute( Procedure ()
    Begin
      //Handle.style['overflow']:='hidden';
      AdjustSize;
    end);
end;

procedure TQTXLabel.AdjustSize;
var
  mSize: TQTXTextMetric;
  mObj: TQTXFontDetector;
Begin
  if FAuto then
  Begin
    mObj:=TQTXFontDetector.Create;
    try
      mSize:=mObj.MeasureText(mObj.getfontInfo(Handle),innerHTML);
    finally
      mObj.free;
    end;

    if (mSize.tmWidth<1)
    or (mSize.tmHeight<1) then
    Begin
      (* no size is only valid if caption is empty *)
      if getCaption.Length>0 then
      exit else
      self.SetSize(mSize.tmWidth,mSize.tmHeight);
    end else
    self.SetSize(mSize.tmWidth,mSize.tmHeight);
  end;
end;

procedure TQTXLabel.setAuto(const aValue:Boolean);
Begin
  if aValue<>FAuto then
  Begin
    FAuto:=aValue;
    if FAuto then
    AdjustSize;
  end;
end;

function TQTXLabel.getCaption:String;
Begin
  result:=innerHTML;
end;

Procedure TQTXLabel.setCaption(Const aValue:String);
Begin
  if aValue<>innerHTML then
  Begin
    innerHTML:=aValue;

    if assigned(FOnChanged) then
    FOnChanged(self);

    AdjustSize;
  end;
end;

function  TQTXLabel.MakeElementTagId: String;
Begin
  result:='PRE';
end;


end.
