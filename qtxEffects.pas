unit qtxEffects;

//#############################################################################
//
//  Unit:       qtxEffects.pas
//  Author:     Jon Lennart Aasenden
//  Company:    Jon Lennart Aasenden LTD
//  Copyright:  Copyright Jon Lennart Aasenden, all rights reserved
//
//  About:      This unit introduces a class helper for TW3CustomControl
//              which provides jQuery like "effects", such as fadeIn/out etc.
//
//  Note:       Simply add this unit to your uses-list, and all controls
//              based on TW3CustomControl will have the new methods.
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
//
//#############################################################################

(*
  fadein(0.4);
  moveTo(100,100,0.4);
  rotate(90,57);
  fadeout(0.5);
*)

interface

uses 
  w3System, w3Components, w3Effects;

type

  TQTXMoveAnimation = class(TW3TransitionAnimation)
  private
    FFromX: Integer;
    FFromY: Integer;
    FToX:   Integer;
    FToY:   Integer;
  protected
    function KeyFramesCSS: String; override;
  public
    Property  FromX:Integer read FFromX write FFromX;
    Property  FromY:Integer read FFromY write FFromY;
    Property  ToX:Integer read FToX write FToX;
    Property  ToY:Integer read FToY write FToY;
  end;

  TQTXSizeAnimation = Class(TW3TransitionAnimation)
  private
    FFromWidth:   Integer;
    FFromHeight:  Integer;
    FToWidth:     Integer;
    FToHeight:    Integer;
    FFromX:       Integer;
    FFromY:       Integer;
    FToX:         Integer;
    FToY:         Integer;
  protected
    function KeyFramesCSS: String; override;
  public
    Property  fromLeft:Integer read FFromX write FFromX;
    Property  fromTop:Integer read FFromY write FFromY;
    Property  fromWidth:Integer read FFromWidth write FFromWidth;
    property  fromHeight:Integer read FFromHeight write FFromHeight;
    Property  toWidth:Integer read FToWidth write FToWidth;
    Property  toHeight:Integer read FToHeight write FToHeight;
    Property  toLeft:Integer read FToX write FToX;
    property  toTop:Integer read FToY write FToY;
  End;

  TQTXEffectsHelper = Class helper for TW3MovableControl
    Procedure fxFadeOut(const Duration:Float);
    Procedure fxFadeIn(const Duration:Float);
    Procedure fxWarpOut(const Duration:Float);
    procedure fxWarpIn(const Duration:Float);
    Procedure fxZoomIn(const Duration:Float);
    Procedure fxZoomOut(const Duration:Float);

    Procedure fxMoveTo(const dx,dy:Integer;
              const Duration:Float);overload;

    Procedure fxMoveTo(const dx,dy:Integer;
              const Duration:Float;
              const callback:TProcedureRef);overload;

    Procedure fxMoveBy(const dx,dy:Integer;
              const Duration:Float);
    Procedure fxMoveUp(const Duration:Float);
    Procedure fxMoveDown(const Duration:Float);

    Procedure fxSizeTo(const aWidth,aHeight:Integer;
              const Duration:Float);
    procedure fxScaleDown(aFactor:Integer;const Duration:Float);
    Procedure fxScaleUp(aFactor:Integer;const Duration:Float);
  End;

implementation

//############################################################################
// TQTXMoveAnimation
//############################################################################

function TQTXSizeAnimation.KeyFramesCSS: String;
Begin
   Result := Format(#"
      from {
        left: %dpx;
        top:  %dpx;
        width: %dpx;
        height: %dpx;
      } to {
        left: %dpx;
        top:  %dpx;
        width: %dpx;
        height: %dpx;
   }",[ fFromX,fFromY,fFromWidth,fFromHeight,
        fToX,fToY,fToWidth,fToHeight]);
end;

//############################################################################
// TQTXMoveAnimation
//############################################################################

function TQTXMoveAnimation.KeyFramesCSS: String;
Begin
   Result := Format(#"
      from {
        left: %dpx;
        top:  %dpx;
      } to {
        left: %dpx;
        top: %dpx;
   }",[FFromX,FFromY,FToX,FToY]);
end;

//############################################################################
// TQTXEffectsHelper
//############################################################################

Procedure TQTXEffectsHelper.fxScaleUp(aFactor:Integer;
          const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  aFactor:=TInteger.ensureRange(aFactor,1,MAX_INT);

  mEffect:=TQTXSizeAnimation.Create;
  mEffect.duration:=Duration;

  TQTXSizeAnimation(mEffect).fromLeft:=self.Left;
  TQTXSizeAnimation(mEffect).fromTop:=self.top;
  TQTXSizeAnimation(mEffect).fromWidth:=self.width;
  TQTXSizeAnimation(mEffect).fromHeight:=self.Height;

  TQTXSizeAnimation(mEffect).toLeft:=self.left-aFactor;
  TQTXSizeAnimation(mEffect).toTop:=self.top-aFactor;
  TQTXSizeAnimation(mEffect).toWidth:=self.width + (aFactor*2);
  TQTXSizeAnimation(mEffect).toHeight:=self.height + (aFactor*2);

  TQTXSizeAnimation(mEffect).Timing:=atEaseInOut;
  mEffect.onAnimationEnds:=Procedure (sender:TObject)
    Begin
      setbounds(TQTXSizeAnimation(mEffect).toLeft,
        TQTXSizeAnimation(mEffect).toTop,
        TQTXSizeAnimation(mEffect).toWidth,
        TQTXSizeAnimation(mEffect).toHeight);
      w3_callback( Procedure ()
      Begin
        TW3CustomAnimation(sender).free;
      end, 100);
    end;
  mEffect.execute(self);
end;

procedure TQTXEffectsHelper.fxScaleDown(aFactor:Integer;
          const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  aFactor:=TInteger.ensureRange(aFactor,1,MAX_INT);

  mEffect:=TQTXSizeAnimation.Create;
  mEffect.duration:=Duration;

  TQTXSizeAnimation(mEffect).fromLeft:=self.Left;
  TQTXSizeAnimation(mEffect).fromTop:=self.top;
  TQTXSizeAnimation(mEffect).fromWidth:=self.width;
  TQTXSizeAnimation(mEffect).fromHeight:=self.Height;

  TQTXSizeAnimation(mEffect).toLeft:=self.left+aFactor;
  TQTXSizeAnimation(mEffect).toTop:=self.top+aFactor;
  TQTXSizeAnimation(mEffect).toWidth:=self.width - (aFactor*2);
  TQTXSizeAnimation(mEffect).toHeight:=self.height - (aFactor*2);

  TQTXSizeAnimation(mEffect).Timing:=atEaseInOut;
  mEffect.onAnimationEnds:=Procedure (sender:TObject)
    Begin
      setbounds(TQTXSizeAnimation(mEffect).toLeft,
        TQTXSizeAnimation(mEffect).toTop,
        TQTXSizeAnimation(mEffect).toWidth,
        TQTXSizeAnimation(mEffect).toHeight);
      w3_callback( Procedure ()
      Begin
        TW3CustomAnimation(sender).free;
      end, 100);
    end;
  mEffect.execute(self);
end;

Procedure TQTXEffectsHelper.fxSizeTo(const aWidth,aHeight:Integer;
          const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin

  mEffect:=TQTXSizeAnimation.Create;
  mEffect.duration:=Duration;

  TQTXSizeAnimation(mEffect).fromLeft:=self.Left;
  TQTXSizeAnimation(mEffect).fromTop:=self.top;
  TQTXSizeAnimation(mEffect).fromWidth:=self.width;
  TQTXSizeAnimation(mEffect).fromHeight:=self.Height;

  TQTXSizeAnimation(mEffect).toLeft:=self.left;
  TQTXSizeAnimation(mEffect).toTop:=self.top;
  TQTXSizeAnimation(mEffect).toWidth:=aWidth;
  TQTXSizeAnimation(mEffect).toHeight:=aHeight;

  TQTXSizeAnimation(mEffect).Timing:=atEaseInOut;
  mEffect.onAnimationEnds:=Procedure (sender:TObject)
    Begin
      setbounds(TQTXSizeAnimation(mEffect).toLeft,
        TQTXSizeAnimation(mEffect).toTop,
        TQTXSizeAnimation(mEffect).toWidth,
        TQTXSizeAnimation(mEffect).toHeight);
      w3_callback( Procedure ()
      Begin
        TW3CustomAnimation(sender).free;
      end, 100);
    end;
  mEffect.execute(self);
end;

Procedure TQTXEffectsHelper.fxMoveUp(const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  mEffect:=TQTXMoveAnimation.Create;
  mEffect.duration:=Duration;
  TQTXMoveAnimation(mEffect).fromX:=self.left;
  TQTXMoveAnimation(mEffect).fromY:=self.top;
  TQTXMoveAnimation(mEffect).toX:=self.left;
  TQTXMoveAnimation(mEffect).toY:=0;
  TQTXMoveAnimation(mEffect).Timing:=atEaseInOut;
  mEffect.onAnimationEnds:=Procedure (sender:TObject)
    Begin
      self.top:=0;
      w3_callback( Procedure ()
      Begin
        TW3CustomAnimation(sender).free;
      end, 100);
    end;
  mEffect.execute(self);
end;

Procedure TQTXEffectsHelper.fxMoveDown(const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  mEffect:=TQTXMoveAnimation.Create;
  mEffect.duration:=Duration;
  TQTXMoveAnimation(mEffect).fromX:=self.left;
  TQTXMoveAnimation(mEffect).fromY:=self.top;
  TQTXMoveAnimation(mEffect).toX:=self.left;
  TQTXMoveAnimation(mEffect).toY:=TW3MovableControl(self.Parent).Height-Self.Height;
  TQTXMoveAnimation(mEffect).Timing:=atEaseInOut;
  mEffect.onAnimationEnds:=Procedure (sender:TObject)
    Begin
      self.top:=TW3MovableControl(self.Parent).Height-Self.Height;;
      w3_callback( Procedure ()
      Begin
        TW3CustomAnimation(sender).free;
      end, 100);
    end;
  mEffect.execute(self);
end;

Procedure TQTXEffectsHelper.fxMoveBy(const dx,dy:Integer;
              const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  mEffect:=TQTXMoveAnimation.Create;
  mEffect.duration:=Duration;
  TQTXMoveAnimation(mEffect).fromX:=self.left;
  TQTXMoveAnimation(mEffect).fromY:=self.top;
  TQTXMoveAnimation(mEffect).toX:=self.left + dx;
  TQTXMoveAnimation(mEffect).toY:=self.top + dy;
  TQTXMoveAnimation(mEffect).Timing:=atEaseInOut;
  mEffect.onAnimationEnds:=Procedure (sender:TObject)
    Begin
      self.left:=dx;
      self.top:=dy;
      w3_callback( Procedure ()
      Begin
        TW3CustomAnimation(sender).free;
      end, 100);
    end;
  mEffect.execute(self);
end;

Procedure TQTXEffectsHelper.fxMoveTo(const dx,dy:Integer;
          const Duration:Float;
          const callback:TProcedureRef);
var
  mEffect: TW3CustomAnimation;
Begin
  mEffect:=TQTXMoveAnimation.Create;
  mEffect.duration:=Duration;
  TQTXMoveAnimation(mEffect).fromX:=self.left;
  TQTXMoveAnimation(mEffect).fromY:=self.top;
  TQTXMoveAnimation(mEffect).toX:=dx;
  TQTXMoveAnimation(mEffect).toY:=dy;
  TQTXMoveAnimation(mEffect).Timing:=atLinear;
  mEffect.onAnimationEnds:=Procedure (sender:TObject)
    Begin
      self.left:=dx;
      self.top:=dy;

      if assigned(callBack) then
      callback();

      w3_callback( Procedure ()
      Begin
        TW3CustomAnimation(sender).free;
      end, 100);
    end;
  mEffect.execute(self);
end;


Procedure TQTXEffectsHelper.fxMoveTo(const dx,dy:Integer;const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  mEffect:=TQTXMoveAnimation.Create;
  mEffect.duration:=Duration;
  TQTXMoveAnimation(mEffect).fromX:=self.left;
  TQTXMoveAnimation(mEffect).fromY:=self.top;
  TQTXMoveAnimation(mEffect).toX:=dx;
  TQTXMoveAnimation(mEffect).toY:=dy;
  TQTXMoveAnimation(mEffect).Timing:=atLinear;
  mEffect.onAnimationEnds:=Procedure (sender:TObject)
    Begin
      self.left:=dx;
      self.top:=dy;
      w3_callback( Procedure ()
      Begin
        TW3CustomAnimation(sender).free;
      end, 100);
    end;
  mEffect.execute(self);
end;

Procedure TQTXEffectsHelper.fxZoomIn(const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  mEffect:=TW3ZoomInTransition.Create;
  mEffect.Duration:=Duration;
  mEffect.OnAnimationEnds:=Procedure (Sender:TObject)
    Begin
      w3_callback( Procedure ()
        Begin
          TW3CustomAnimation(sender).free;
        end, 100);
    end;
  self.Visible:=true;
  mEffect.Execute(self);
end;

Procedure TQTXEffectsHelper.fxZoomOut(const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  mEffect:=TW3ZoomOutTransition.Create;
  mEffect.Duration:=Duration;
  mEffect.OnAnimationEnds:=Procedure (Sender:TObject)
    Begin
      self.Visible:=false;
      w3_callback( Procedure ()
        Begin
          TW3CustomAnimation(sender).free;
        end, 100);
    end;
  mEffect.Execute(self);
end;

Procedure TQTXEffectsHelper.fxWarpOut(const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  mEffect:=TW3WarpOutTransition.Create;
  mEffect.Duration:=Duration;
  mEffect.OnAnimationEnds:=Procedure (Sender:TObject)
    Begin
      self.Visible:=false;
      w3_callback( Procedure ()
        Begin
          TW3CustomAnimation(sender).free;
        end, 100);
    end;
  mEffect.Execute(self);
end;

procedure TQTXEffectsHelper.fxWarpIn(const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  mEffect:=TW3WarpInTransition.Create;
  mEffect.Duration:=Duration;
  mEffect.OnAnimationEnds:=Procedure (Sender:TObject)
    Begin
      w3_callback( Procedure ()
        Begin
          TW3CustomAnimation(sender).free;
        end, 100);
    end;
  self.Visible:=true;
  mEffect.Execute(self);
end;

Procedure TQTXEffectsHelper.fxFadeIn(const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  mEffect:=TW3FadeSlideTransition.Create;
  TW3FadeSlideTransition(mEffect).fromOpacity:=0.0;
  TW3FadeSlideTransition(mEffect).toOpacity:=1.0;
  mEffect.Duration:=Duration;
  mEffect.OnAnimationEnds:=Procedure (Sender:TObject)
    Begin
      w3_callback( Procedure ()
        Begin
          TW3CustomAnimation(sender).free;
        end, 100);
    end;
  self.Visible:=true;
  mEffect.Execute(self);
end;

Procedure TQTXEffectsHelper.fxFadeOut(const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  mEffect:=TW3FadeSlideTransition.Create;
  TW3FadeSlideTransition(mEffect).fromOpacity:=1.0;
  TW3FadeSlideTransition(mEffect).toOpacity:=0.0;
  mEffect.Duration:=Duration;
  mEffect.OnAnimationEnds:=Procedure (Sender:TObject)
    Begin
      self.Visible:=False;
      w3_callback( Procedure ()
        Begin
          TW3CustomAnimation(sender).free;
        end, 100);
    end;
  mEffect.Execute(self);
end;


end.
