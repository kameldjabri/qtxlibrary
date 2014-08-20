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
  w3System, w3Components, w3Effects,
  qtxutils;

const
CNT_RELEASE_DELAY = 10;
CNT_CACHE_DELAY   = 50;

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

  TQTXEffectsHelper = Class helper for TW3CustomControl
    Procedure fxFadeOut(const Duration:Float);overload;
    Procedure fxFadeOut(const Duration:Float;
              const OnFinished:TProcedureRef);overload;

    Procedure fxFadeIn(const Duration:Float);overload;
    Procedure fxFadeIn(const Duration:Float;
              const OnFinished:TProcedureRef);overload;

    Procedure fxWarpOut(const Duration:Float);overload;
    Procedure fxWarpOut(const Duration:Float;
              const OnFinished:TProcedureRef);overload;

    procedure fxWarpIn(const Duration:Float);overload;
    procedure fxWarpIn(const Duration:Float;
              const OnFinished:TProcedureRef);overload;

    Procedure fxZoomIn(const Duration:Float);overload;
    Procedure fxZoomIn(const Duration:Float;
              const OnFinished:TProcedureRef);overload;

    Procedure fxZoomOut(const Duration:Float);overload;
    Procedure fxZoomOut(const Duration:Float;
              const OnFinished:TProcedureRef);overload;

    Procedure fxMoveTo(const dx,dy:Integer;
              const Duration:Float);overload;

    Procedure fxMoveTo(const dx,dy:Integer;
              const Duration:Float;
              const OnFinished:TProcedureRef);overload;

    Procedure fxMoveBy(const dx,dy:Integer;
              const Duration:Float);overload;

    Procedure fxMoveBy(const dx,dy:Integer;
              const Duration:Float;
              const OnFinished:TProcedureRef);overload;


    Procedure fxMoveUp(const Duration:Float);
    Procedure fxMoveDown(const Duration:Float);

    Procedure fxSizeTo(const aWidth,aHeight:Integer;
              const Duration:Float);

    procedure fxScaleDown(aFactor:Integer;const Duration:Float);
    Procedure fxScaleUp(aFactor:Integer;const Duration:Float);

    Procedure fxAbort;

    function  fxBusy:Boolean;
    Procedure fxSetBusy(const aValue:Boolean);
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

function TQTXEffectsHelper.fxBusy:Boolean;
Begin
  if self.elementData.exists('fxBusy') then
  result:=StrToBool( self.ElementData.read('fxBusy') ) else
  self.elementData.write('fxBusy',false);
end;

Procedure TQTXEffectsHelper.fxSetBusy(const aValue:Boolean);
Begin
  self.elementdata.write('fxBusy',BoolToStr(aValue));
end;

Procedure TQTXEffectsHelper.fxAbort;
Begin
  if fxBusy then
  begin
    try
      Handle.style.webkitAnimationPlayState:='stop';
      Handle.style.removeProperty("-webkit-animation");
      Handle.style.removeProperty("-webkit-animation-fill-mode");
      Handle.style.removeProperty("animation");
      Handle.style.removeProperty("animation-fill-mode");
    finally
      fxSetBusy(False);
    end;
  end;
end;

Procedure TQTXEffectsHelper.fxScaleUp(aFactor:Integer;
          const Duration:Float);
var
  mEffect: TW3CustomAnimation;
  mData:  Variant;
Begin
  if not fxBusy then
  begin
    (* Mark element as managed *)
    fxsetBusy(True);

    mEffect:=TQTXSizeAnimation.Create;
    mEffect.duration:=Duration;

    aFactor:=TInteger.ensureRange(aFactor,1,MAX_INT);

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
          fxSetBusy(False);
        end, CNT_RELEASE_DELAY);
      end;
    mEffect.execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxScaleUp(afactor,duration);
    end,
    CNT_CACHE_DELAY);
end;

procedure TQTXEffectsHelper.fxScaleDown(aFactor:Integer;
          const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  Begin
    fxsetBusy(True);

    mEffect:=TQTXSizeAnimation.Create;
    mEffect.duration:=Duration;

    TQTXSizeAnimation(mEffect).fromLeft:=self.Left;
    TQTXSizeAnimation(mEffect).fromTop:=self.top;
    TQTXSizeAnimation(mEffect).fromWidth:=self.width;
    TQTXSizeAnimation(mEffect).fromHeight:=self.Height;

    aFactor:=TInteger.ensureRange(aFactor,1,MAX_INT);
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
          fxSetBusy(False);
        end, CNT_RELEASE_DELAY);
      end;
    mEffect.execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxScaleDown(aFactor,duration);
    end,
    CNT_CACHE_DELAY);
end;

Procedure TQTXEffectsHelper.fxSizeTo(const aWidth,aHeight:Integer;
          const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  Begin
    fxSetBusy(true);
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
          fxSetBusy(False);
        end, CNT_RELEASE_DELAY);
      end;
    mEffect.execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxSizeTo(aWidth,aHeight,duration);
    end,
    CNT_CACHE_DELAY);
end;

Procedure TQTXEffectsHelper.fxMoveUp(const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  begin
    fxSetBusy(true);
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
          fxSetBusy(False);
        end, CNT_RELEASE_DELAY);
      end;
    mEffect.execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxMoveUp(duration);
    end,
    CNT_CACHE_DELAY);
end;

Procedure TQTXEffectsHelper.fxMoveDown(const Duration:Float);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  Begin
    fxSetBusy(True);
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
          fxSetBusy(False);
        end, CNT_RELEASE_DELAY);
      end;
    mEffect.execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxMoveDown(duration);
    end,
    CNT_CACHE_DELAY);
end;

Procedure TQTXEffectsHelper.fxMoveBy(const dx,dy:Integer;
              const Duration:Float);
Begin
  fxMoveBy(dx,dy,Duration,NIL);
end;

Procedure TQTXEffectsHelper.fxMoveBy(const dx,dy:Integer;
          const Duration:Float;
          const OnFinished:TProcedureRef);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  begin
    fxSetBusy(True);
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
          fxSetBusy(false);
          if assigned(OnFinished) then
          OnFinished();
        end, CNT_RELEASE_DELAY);
      end;
    mEffect.execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxMoveBy(dx,dy,duration,OnFinished);
    end,
    CNT_CACHE_DELAY);
end;


Procedure TQTXEffectsHelper.fxMoveTo(const dx,dy:Integer;const Duration:Float);
Begin
  fxMoveTo(dx,dy,Duration,NIL);
end;

Procedure TQTXEffectsHelper.fxMoveTo(const dx,dy:Integer;
          const Duration:Float;
          const OnFinished:TProcedureRef);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  begin
    fxSetBusy(True);
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
          fxSetBusy(false);
          if assigned(OnFinished) then
          OnFinished();
        end, CNT_RELEASE_DELAY);
      end;
    mEffect.execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxMoveTo(dx,dy,duration,OnFinished);
    end,
    CNT_CACHE_DELAY);
end;

Procedure TQTXEffectsHelper.fxZoomIn(const Duration:Float);
Begin
  fxZoomIn(Duration,NIL);
end;

Procedure TQTXEffectsHelper.fxZoomIn(const Duration:Float;
          const OnFinished:TProcedureRef);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  Begin
    fxSetBusy(true);
    mEffect:=TW3ZoomInTransition.Create;
    mEffect.Duration:=Duration;
    mEffect.OnAnimationEnds:=Procedure (Sender:TObject)
      Begin
        w3_callback( Procedure ()
          Begin
            TW3CustomAnimation(sender).free;
            fxSetBusy(False);
          end, CNT_RELEASE_DELAY);
      end;
    self.Visible:=true;
    mEffect.Execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxZoomIn(duration);
    end,
    100);
end;

Procedure TQTXEffectsHelper.fxZoomOut(const Duration:Float);
Begin
  fxZoomOut(Duration,NIL);
end;

Procedure TQTXEffectsHelper.fxZoomOut(const Duration:Float;
          const OnFinished:TProcedureRef);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  Begin
    fxSetBusy(True);
    mEffect:=TW3ZoomOutTransition.Create;
    mEffect.Duration:=Duration;
    mEffect.OnAnimationEnds:=Procedure (Sender:TObject)
      Begin
        self.Visible:=false;
        w3_callback( Procedure ()
          Begin
            TW3CustomAnimation(sender).free;
            fxSetBusy(false);
            if assigned(OnFinished) then
            OnFinished();
          end, CNT_RELEASE_DELAY);
      end;
    mEffect.Execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxZoomOut(duration);
    end,
    CNT_CACHE_DELAY);
end;

Procedure TQTXEffectsHelper.fxWarpOut(const Duration:Float);
begin
  fxWarpOut(Duration,NIL);
end;

Procedure TQTXEffectsHelper.fxWarpOut(const Duration:Float;
              const OnFinished:TProcedureRef);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  begin
    fxSetBusy(true);
    mEffect:=TW3WarpOutTransition.Create;
    mEffect.Duration:=Duration;
    mEffect.OnAnimationEnds:=Procedure (Sender:TObject)
      Begin
        self.Visible:=false;
        w3_callback( Procedure ()
          Begin
            TW3CustomAnimation(sender).free;
            fxSetBusy(false);
            if assigned(OnFinished) then
            OnFinished();
          end, CNT_RELEASE_DELAY);
      end;
    mEffect.Execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxWarpOut(duration);
    end,
    CNT_CACHE_DELAY);
end;

procedure TQTXEffectsHelper.fxWarpIn(const Duration:Float);
Begin
  fxWarpIn(Duration,NIL);
end;

procedure TQTXEffectsHelper.fxWarpIn(const Duration:Float;
          const OnFinished:TProcedureRef);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  Begin
    fxSetBusy(true);
    mEffect:=TW3WarpInTransition.Create;
    mEffect.Duration:=Duration;
    mEffect.OnAnimationEnds:=Procedure (Sender:TObject)
      Begin
        w3_callback( Procedure ()
          Begin
            TW3CustomAnimation(sender).free;
            fxSetBusy(False);
            if assigned(OnFinished) then
            OnFinished();
          end, CNT_RELEASE_DELAY);
      end;
    self.Visible:=true;
    mEffect.Execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxWarpIn(duration);
    end,
    CNT_CACHE_DELAY);
end;


Procedure TQTXEffectsHelper.fxFadeIn(const Duration:Float);
Begin
  fxFadeIn(Duration,NIL);
end;

Procedure TQTXEffectsHelper.fxFadeIn(const Duration:Float;
          const OnFinished:TProcedureRef);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  begin
    fxSetBusy(true);
    mEffect:=TW3FadeSlideTransition.Create;
    TW3FadeSlideTransition(mEffect).fromOpacity:=0.0;
    TW3FadeSlideTransition(mEffect).toOpacity:=1.0;
    mEffect.Duration:=Duration;
    mEffect.OnAnimationEnds:=Procedure (Sender:TObject)
      Begin
        w3_callback( Procedure ()
          Begin
            TW3CustomAnimation(sender).free;
            fxSetBusy(False);
            if assigned(OnFinished) then
            OnFinished();
          end, CNT_RELEASE_DELAY);
      end;
    self.Visible:=true;
    mEffect.Execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxFadeIn(duration);
    end,
    CNT_CACHE_DELAY);
end;

Procedure TQTXEffectsHelper.fxFadeOut(const Duration:Float);
(* var
  mEffect: TW3CustomAnimation; *)
Begin
  fxFadeOut(Duration,NIL);
  (*
  if not fxBusy then
  begin
    fxSetBusy(true);
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
            fxSetBusy(False);
          end, CNT_RELEASE_DELAY);
      end;
    mEffect.Execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxFadeOut(duration);
    end,
    CNT_CACHE_DELAY); *)
end;

Procedure TQTXEffectsHelper.fxFadeOut(const Duration:Float;
          const OnFinished:TProcedureRef);
var
  mEffect: TW3CustomAnimation;
Begin
  if not fxBusy then
  begin
    fxSetBusy(true);
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
            fxSetBusy(False);
            if assigned(OnFinished) then
            OnFinished();
          end, CNT_RELEASE_DELAY);
      end;
    mEffect.Execute(self);
  end else
  w3_callback( procedure ()
    Begin
      fxFadeOut(duration);
    end,
    CNT_CACHE_DELAY);
end;



end.
