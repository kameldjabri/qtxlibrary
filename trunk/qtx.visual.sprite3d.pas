unit qtx.visual.sprite3d;

//#############################################################################
//
//  Author:     Jon Lennart Aasenden [cipher diaz of quartex]
//  Copyright:  Jon Lennart Aasenden, all rights reserved
//
//  Description:
//  ============
//  Updated port of Sprite3D, which allows for 3D manipulation of any
//  HTML elements, powered by the CSS GPU capabilities
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
  System.Types,
  SmartCL.System,
  SmartCL.Components,
  SmartCL.Graphics;

type

  TQTXTransformOptions = set of
    (
      toUsePos,   //  You will use position properties
      toUseRotX,  //  You will use ROTX property
      toUseRotY,  //  You will use ROTY property
      toUseRotZ,  //  You will use ROTZ property
      toUseScale  //  You will apply scale property
    );

  TQTXTransformController = Class(TObject)
  private
    FHandle:  THandle;
    FX:       Float;
    FY:       Float;
    FZ:       Float;
    FRotX:    Float;
    FRotY:    Float;
    FRotZ:    Float;
    FRegX:    Float;
    FRegY:    Float;
    FRegZ:    Float;
    FScaleX:  Float;
    FScaleY:  Float;
    FScaleZ:  Float;
    FFlags:   TQTXTransformOptions;
  public
    Property    Handle:THandle read FHandle;
    property    RotationX: Float read FRotX write FRotX;
    property    RotationY: Float read FRotY write FRotY;
    property    RotationZ: Float read FRotZ write FRotZ;
    property    ScaleX: Float read FScaleX write FScaleX;
    property    ScaleY: Float read FScaleY write FScaleY;
    property    ScaleZ: Float read FScaleZ write FScaleZ;
    property    RegX: Float read FRegX write FRegX;
    property    RegY: Float read FRegY write FRegY;
    property    RegZ: Float read FRegZ write FRegZ;
    property    X: Float read FX write FX;
    property    Y: Float read FY write FY;
    property    Z: Float read FZ write FZ;

    procedure   SetRegistrationPoint(const X, Y, Z: Float);
    procedure   SetTransformOrigin(const X, Y: Float);
    procedure   Scale(const X, Y, Z: Float); overload;
    procedure   Scale(const aValue: Float); overload;
    procedure   RotateX(const aValue: Float);
    procedure   RotateY(const aValue: Float);
    procedure   RotateZ(const aValue: Float);
    procedure   Rotate(const XFactor, YFactor, ZFactor: Float); overload;
    procedure   Rotate(const aValue: Float); overload;
    procedure   SetRotation(const X, Y, Z: Float);
    procedure   SetPosition(const X, Y, Z: Float);
    procedure   MoveX(const aValue: Float);
    procedure   MoveY(const aValue: Float);
    procedure   MoveZ(const aValue: Float);
    procedure   Move(X, Y, Z: Float);
    procedure   SetTransformFlags(const aValue:TQTXTransformOptions);
    procedure   Update; virtual;
    Constructor Create(const aHandle:THandle);
  End;

  TQTX3dObject = Class(TW3MovableControl)
  private
    FHandle:  THandle;
    FX:       Float;
    FY:       Float;
    FZ:       Float;
    FRotX:    Float;
    FRotY:    Float;
    FRotZ:    Float;
    FRegX:    Float;
    FRegY:    Float;
    FRegZ:    Float;
    FScaleX:  Float;
    FScaleY:  Float;
    FScaleZ:  Float;
    FFlags:   TQTXTransformOptions;
  protected
    procedure   InitializeObject;override;
    procedure   StyleTagObject;override;
  public
    Property    Handle:THandle read FHandle;
    property    RotationX: Float read FRotX write FRotX;
    property    RotationY: Float read FRotY write FRotY;
    property    RotationZ: Float read FRotZ write FRotZ;
    property    ScaleX: Float read FScaleX write FScaleX;
    property    ScaleY: Float read FScaleY write FScaleY;
    property    ScaleZ: Float read FScaleZ write FScaleZ;
    property    RegX: Float read FRegX write FRegX;
    property    RegY: Float read FRegY write FRegY;
    property    RegZ: Float read FRegZ write FRegZ;
    property    X: Float read FX write FX;
    property    Y: Float read FY write FY;
    property    Z: Float read FZ write FZ;

    procedure   SetRegistrationPoint(const X, Y, Z: Float);
    procedure   SetTransformOrigin(const X, Y: Float);
    procedure   Scale(const X, Y, Z: Float); overload;
    procedure   Scale(const aValue: Float); overload;
    procedure   RotateX(const aValue: Float);
    procedure   RotateY(const aValue: Float);
    procedure   RotateZ(const aValue: Float);
    procedure   Rotate(const XFactor, YFactor, ZFactor: Float); overload;
    procedure   Rotate(const aValue: Float); overload;
    procedure   SetRotation(const X, Y, Z: Float);
    procedure   SetPosition(const X, Y, Z: Float);
    procedure   MoveX(const aValue: Float);
    procedure   MoveY(const aValue: Float);
    procedure   MoveZ(const aValue: Float);
    procedure   Move(X, Y, Z: Float);
    procedure   SetTransformFlags(const aValue:TQTXTransformOptions);
    procedure   Update; virtual;
  end;

  TQTX3dContainer = Class(TQTX3dObject)
  protected
    procedure StyleTagObject;override;
  public
    function  AddObject:TQTX3dObject;
  end;

  TQTX3dScene = Class(TQTX3dObject)
  protected
    procedure StyleTagObject;override;
  public
    function  AddScene:TQTX3dContainer;
  end;


implementation

uses qtx.helpers;

//############################################################################
// TQTX3dContainer
//############################################################################

procedure TQTX3dContainer.StyleTagObject;
Begin
  inherited;
  Handle.style[w3_CSSPrefix('transformStyle')] := 'preserve-3d';
  Handle.style[w3_CSSPrefix('Perspective')] := 800;
  Handle.style[w3_CSSPrefix('transformOrigin')] := '50% 50%';
  Handle.style[w3_CSSPrefix('Transform')] := 'translateZ(0px)';
end;

function TQTX3dContainer.AddObject:TQTX3dContainer;
begin
  result:=TQTX3dObject.Create(self);
end;

//############################################################################
// TQTX3dScene
//############################################################################

procedure TQTX3dScene.StyleTagObject;
Begin
  inherited;
  Handle.style[w3_CSSPrefix('transformStyle')] := 'preserve-3d';
  Handle.style[w3_CSSPrefix('Perspective')] := 800;
  Handle.style[w3_CSSPrefix('transformOrigin')] := '50% 50%';
  Handle.style[w3_CSSPrefix('Transform')] := 'translateZ(0px)';
end;

function TQTX3dScene.AddScene:TQTX3dContainer;
begin
  result:=TQTX3dContainer.Create(self);
end;

//############################################################################
// TQTX3dObject
//############################################################################

procedure TQTX3dObject.InitializeObject;
begin
  inherited;
  FScaleX := 1.0;
  FScaleY := 1.0;
  FScaleZ := 1.0;
  FFlags:=[toUsePos,toUseRotX,toUseRotY,toUseRotZ,toUseScale];
end;

procedure TQTX3dObject.StyleTagObject;
Begin
  Handle.style[w3_CSSPrefix('transformStyle')] := 'preserve-3d';
  Handle.style[w3_CSSPrefix('Transform')] := 'translateZ(0px)';
end;

procedure TQTX3dObject.MoveX(const aValue: Float);
begin
  FX+=aValue;
end;

procedure TQTX3dObject.MoveY(const aValue: Float);
begin
  FY+=aValue;
end;

procedure TQTX3dObject.MoveZ(const aValue: Float);
begin
  FZ+=aValue;
end;

procedure TQTX3dObject.Move(x, y, z: Float);
begin
  FX+=X;
  FY+=Y;
  FZ+=Z;
end;

procedure TQTX3dObject.SetRegistrationPoint(const X,Y,Z: Float);
begin
  FRegX := X;
  FRegY := Y;
  FRegZ := Z;
end;

procedure TQTX3dObject.Scale(const X,Y,Z: Float);
begin
  FScaleX := X;
  FScaleY := Y;
  FScaleZ := Z;
end;

procedure TQTX3dObject.Scale(const aValue: Float);
begin
  FScaleX := aValue;
  FScaleY := aValue;
  FScaleZ := aValue;
end;

procedure TQTX3dObject.SetPosition(const X,Y,Z: Float);
begin
  FX := X;
  FY := Y;
  FZ := Z;
end;

procedure TQTX3dObject.SetRotation(const X,Y,Z: Float);
begin
  FRotX := X;
  FRotY := Y;
  FRotZ := Z;
end;

procedure TQTX3dObject.Rotate(const XFactor,YFactor,ZFactor: Float);
begin
  FRotX+=XFactor;
  FRotY+=YFactor;
  FRotZ+=ZFactor;
end;

procedure TQTX3dObject.Rotate(const aValue: Float);
begin
  FRotX+=aValue;
  FRotY+=aValue;
  FRotZ+=aValue;
end;

procedure TQTX3dObject.RotateX(const aValue: Float);
begin
  FRotX+=aValue;
end;

procedure TQTX3dObject.RotateY(const aValue: Float);
begin
  FRotY+=aValue;
end;

procedure TQTX3dObject.RotateZ(const aValue: Float);
begin
  FRotZ+=aValue;
end;

procedure TQTX3dObject.SetTransformOrigin(const X, Y: Float);
begin
  FHandle.style[w3_CSSPrefix('transformOrigin')]  :=
  FloatToStr(X) +'px ' + FloatToStr(Y) +'px';
end;

procedure TQTX3dObject.setTransformFlags(const aValue:TQTXTransformOptions);
begin
  FFlags := aValue;
end;

procedure TQTX3dObject.Update;
var
  mTemp:  String;
begin
  if (FHandle) then
  begin
    mTemp:='';

    if (toUseRotX in FFlags) then
    mTemp += 'rotateX(' + FloatToStr(FRotX) + 'deg) ';

    if (toUseRotY in FFlags) then
    mTemp += 'rotateY(' + FloatToStr(FRotY) + 'deg) ';

    if (toUseRotZ in FFlags) then
    mTemp += 'rotateZ(' + FloatToStr(FRotZ) + 'deg) ';

    if (toUsePos in FFlags) then
    mTemp += 'translate3d('
      + FloatToStr(FX - FRegX) + 'px,'
      + FloatToStr(FY - FRegY) + 'px,'
      + FloatToStr(FZ - FRegZ) + 'px) ';


    if (toUseScale in FFlags) then
    mTemp += 'scale3d(' + FloatToStr(FScaleX) + ','
      + FloatToStr(FScaleY) +','
      + FloatToStr(FScaleZ) + ') ';

    FHandle.style[w3_CSSPrefix('Transform')] := mTemp;
  end;
end;

//############################################################################
// TQTXTransformController
//############################################################################

Constructor TQTXTransformController.Create(const aHandle:THandle);
Begin
  inherited Create;

  FScaleX := 1.0;
  FScaleY := 1.0;
  FScaleZ := 1.0;

  FFlags:=[toUsePos,toUseRotX,toUseRotY,toUseRotZ,toUseScale];

  if (aHandle) then
  begin
    FHandle:=aHandle;

    FHandle.style[w3_CSSPrefix('transformStyle')] := 'preserve-3d';
    FHandle.style[w3_CSSPrefix('Transform')] := 'translateZ(0px)';

    Update;
  end else
  Raise EW3Exception.Create('Invalid control handle error');
end;

procedure TQTXTransformController.MoveX(const aValue: Float);
begin
  FX+=aValue;
end;

procedure TQTXTransformController.MoveY(const aValue: Float);
begin
  FY+=aValue;
end;

procedure TQTXTransformController.MoveZ(const aValue: Float);
begin
  FZ+=aValue;
end;

procedure TQTXTransformController.Move(x, y, z: Float);
begin
  FX+=X;
  FY+=Y;
  FZ+=Z;
end;

procedure TQTXTransformController.SetRegistrationPoint(const X,Y,Z: Float);
begin
  FRegX := X;
  FRegY := Y;
  FRegZ := Z;
end;

procedure TQTXTransformController.Scale(const X,Y,Z: Float);
begin
  FScaleX := X;
  FScaleY := Y;
  FScaleZ := Z;
end;

procedure TQTXTransformController.Scale(const aValue: Float);
begin
  FScaleX := aValue;
  FScaleY := aValue;
  FScaleZ := aValue;
end;

procedure TQTXTransformController.SetPosition(const X,Y,Z: Float);
begin
  FX := X;
  FY := Y;
  FZ := Z;
end;

procedure TQTXTransformController.SetRotation(const X,Y,Z: Float);
begin
  FRotX := X;
  FRotY := Y;
  FRotZ := Z;
end;

procedure TQTXTransformController.Rotate(const XFactor,YFactor,ZFactor: Float);
begin
  FRotX+=XFactor;
  FRotY+=YFactor;
  FRotZ+=ZFactor;
end;

procedure TQTXTransformController.Rotate(const aValue: Float);
begin
  FRotX+=aValue;
  FRotY+=aValue;
  FRotZ+=aValue;
end;

procedure TQTXTransformController.RotateX(const aValue: Float);
begin
  FRotX+=aValue;
end;

procedure TQTXTransformController.RotateY(const aValue: Float);
begin
  FRotY+=aValue;
end;

procedure TQTXTransformController.RotateZ(const aValue: Float);
begin
  FRotZ+=aValue;
end;

procedure TQTXTransformController.SetTransformOrigin(const X, Y: Float);
begin
  FHandle.style[w3_CSSPrefix('transformOrigin')]  :=
  FloatToStr(X) +'px ' + FloatToStr(Y) +'px';
end;

procedure TQTXTransformController.setTransformFlags(const aValue:TQTXTransformOptions);
begin
  FFlags := aValue;
end;

procedure TQTXTransformController.Update;
var
  mTemp:  String;
begin
  if (FHandle) then
  begin
    mTemp:='';

    if (toUseRotX in FFlags) then
    mTemp += 'rotateX(' + FloatToStr(FRotX) + 'deg) ';

    if (toUseRotY in FFlags) then
    mTemp += 'rotateY(' + FloatToStr(FRotY) + 'deg) ';

    if (toUseRotZ in FFlags) then
    mTemp += 'rotateZ(' + FloatToStr(FRotZ) + 'deg) ';

    if (toUsePos in FFlags) then
    mTemp += 'translate3d('
      + FloatToStr(FX - FRegX) + 'px,'
      + FloatToStr(FY - FRegY) + 'px,'
      + FloatToStr(FZ - FRegZ) + 'px) ';


    if (toUseScale in FFlags) then
    mTemp += 'scale3d(' + FloatToStr(FScaleX) + ','
      + FloatToStr(FScaleY) +','
      + FloatToStr(FScaleZ) + ') ';

    FHandle.style[w3_CSSPrefix('Transform')] := mTemp;
  end;
end;

end.
