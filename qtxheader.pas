unit qtxheader;

//#############################################################################
//
//  Unit:       qtxheader.pas
//  Author:     Jon Lennart Aasenden [Cipher Diaz of Quartex]
//  Company:    Jon Lennart Aasenden LTD
//  Copyright:  Copyright Jon Lennart Aasenden, all rights reserved
//
//  About:      This unit introduces a replacement for TW3HeaderControl.
//              It uses CSS3 animation effects to slide and fade header
//              elements out of view, which makes for a more responsive
//              and living UI experience.
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
//
//#############################################################################


interface

uses 
  W3System, w3components, w3graphics, w3ToolButton, w3borders,
  qtxutils,
  qtxeffects,
  qtxlabel;

{.$DEFINE USE_ANIMFRAME_SYNC}

const
CNT_ANIM_DELAY  = 0.22;

type

  TQTXButtonVisibleEvent = Procedure (sender:TObject;aVisible:Boolean);

  (* Isolate commonalities for Back/Next buttons in ancestor class *)
  TQTXHeaderButton = Class(TW3ToolButton)
  private
    FOnVisible: TQTXButtonVisibleEvent;
  public
    property  OnVisibleChange:TQTXButtonVisibleEvent
              read FOnVisible write FOnVisible;
  Protected
    Procedure setInheritedVisible(const aValue:Boolean);
  End;

  (* Back-button, slides to the left out of view *)
  TQTXBackButton = Class(TQTXHeaderButton)
  protected
    procedure setVisible(const aValue:Boolean);reintroduce;
  published
    Property  Visible:Boolean read getVisible write setVisible;
  End;

  (* Next-button, slides to the right out of view *)
  TQTXNextButton = Class(TQTXHeaderButton)
  protected
    procedure setVisible(const aValue:Boolean);reintroduce;
  published
    Property  Visible:Boolean read getVisible write setVisible;
  End;

  (* Header title label, uses fx to change text *)
  TQTXHeaderTitle = Class(TQTXLabel)
  private
    Procedure SetInheritedCaption(const aValue:String);
  protected
    procedure setCaption(const aValue:String);override;
  End;

  (* Header control, dynamically resizes and positions caption and
     button based on visibility. Otherwise identical to TW3HeaderControl *)
  TQTXHeaderBar = Class(TW3CustomControl)
  private
    FBackButton:  TQTXBackButton;
    FNextButton:  TQTXNextButton;
    FCaption:     TQTXHeaderTitle;
    FMargin:  Integer = 4;
    Procedure HandleBackButtonVisibleChange(sender:TObject;aVisible:Boolean);
    Procedure HandleNextButtonVisibleChange(sender:TObject;aVisible:Boolean);
  protected
    Procedure setMargin(const aValue:Integer);
    Procedure Resize;override;
    Procedure InitializeObject;override;
    Procedure FinalizeObject;Override;
  public
    Property  Margin:Integer read FMargin write setMargin;
    Property  Title:TQTXHeaderTitle read FCaption;
    Property  BackButton:TQTXBackButton read FBackButton;
    property  NextButton:TQTXNextButton read FNextButton;
  End;

implementation

//#############################################################################
// TQTXHeaderButton
//#############################################################################

Procedure TQTXHeaderButton.setInheritedVisible(const aValue:Boolean);
Begin
  inherited setVisible(aValue);
end;

//#############################################################################
// TQTXBackButton
//#############################################################################

procedure TQTXBackButton.setVisible(const aValue:Boolean);
var
  mParent:  TQTXHeaderBar;
  dx: Integer;
Begin
  if  ObjectReady
  and TQTXTools.getElementInDOM(Handle) then
  Begin

    mParent:=TQTXHeaderBar(Parent);

    if aValue<>getVisible then
    begin

      case aValue of
      false:
        Begin
          if mParent.ObjectReady
          and TQTXTools.getElementInDOM(mParent.Handle) then
          Begin

            dx:=-Width;

            {$IFDEF USE_ANIMFRAME_SYNC}
            w3_requestAnimationFrame( procedure ()
            begin
            {$ENDIF}
              self.fxMoveTo(dx,top,CNT_ANIM_DELAY,
              procedure ()
              begin
                setInheritedVisible(false);
              end);
            {$IFDEF USE_ANIMFRAME_SYNC}
            end);
            {$ENDIF}

          end else
          setInheritedVisible(false);
        end;
      True:
        Begin
          setInheritedVisible(true);
          self.MoveTo(-Width,
           (mParent.ClientHeight div 2) - self.height div 2);

          if mParent.ObjectReady
          and TQTXTools.getElementInDOM(mParent.Handle) then
          {$IFDEF USE_ANIMFRAME_SYNC}
          w3_requestAnimationFrame( procedure ()
          {$ENDIF}
          Begin
            self.fxMoveTo(mParent.margin,
            (mParent.ClientHeight div 2) - self.height div 2,CNT_ANIM_DELAY);
          {$IFDEF USE_ANIMFRAME_SYNC}
          end);
          {$ELSE}
          end;
          {$ENDIF}


        end;
      end;

      if assigned(OnVisibleChange)
      and TQTXTools.getElementInDOM(mParent.Handle) then
      OnVisibleChange(self,aValue);

    end;
  end else
  inherited setVisible(aValue);
end;

//#############################################################################
// TQTXNextButton
//#############################################################################

procedure TQTXNextButton.setVisible(const aValue:Boolean);
var
  dy: Integer;
  dx: Integer;
  mParent:  TQTXHeaderBar;
Begin
  if  ObjectReady
  and TQTXTools.getElementInDOM(Handle) then
  Begin
    if aValue<>getVisible then
    Begin
      mParent:=TQTXHeaderBar(Parent);

      dy:=top;

      if not aValue then
      Begin
        self.fxMoveTo(mParent.width,dy,CNT_ANIM_DELAY,
        procedure ()
        begin
          setInheritedVisible(false);
        end);
      end else
      Begin
        setInheritedVisible(true);

        if (parent<>NIL)
        and (parent is TW3CustomControl) then
        dx:=(mParent.ClientWidth - mParent.Margin) - self.width else
        dx:=2 + width;
        self.fxMoveTo(dx,dy,CNT_ANIM_DELAY);
      end;

      if assigned(OnVisibleChange) then
      OnVisibleChange(self,aValue);
    end;
  end else
  inherited setVisible(aValue);
end;

//#############################################################################
// TQTXHeaderTitle
//#############################################################################

Procedure TQTXHeaderTitle.SetInheritedCaption(const aValue:String);
Begin
  inherited setCaption(aValue);
end;

Procedure TQTXHeaderTitle.setCaption(const aValue:String);
begin
  if  ObjectReady
  and TQTXTools.getElementInDOM(Handle) then
  Begin
    inherited setCaption(aValue);
    exit;

    self.fxWarpOut(CNT_ANIM_DELAY,
      procedure ()
      Begin
        setInheritedCaption(aValue);
        self.fxWarpIn(CNT_ANIM_DELAY);
      end);
  end else
  inherited setCaption(aValue);
end;

//#############################################################################
// TQTXHeaderBar
//#############################################################################

Procedure TQTXHeaderBar.InitializeObject;
Begin
  inherited;

  StyleClass:='TW3HeaderControl';

  FBackButton:=TQTXBackButton.Create(self);
  FBackButton.setInheritedVisible(false);
  FBackbutton.styleClass:='TW3ToolButton';
  FBackbutton.Caption:='Back';
  FBackbutton.Height:=28;


  FNextButton:=TQTXNextButton.Create(self);
  FNextButton.setInheritedVisible(false);
  FNextButton.styleClass:='TW3ToolButton';
  FNextButton.Caption:='Next';
  FNextButton.height:=28;

  FCaption:=TQTXHeaderTitle.Create(self);
  FCaption.Autosize:=False;
  FCaption.Caption:='Welcome';
  (* FCaption.handle.style['border']:='1px solid #444444';
  FCaption.handle.style['background-color']:='rgba(255,255,255,0.3)'; *)

  (* hook up events when element is injected in the DOM *)
  TQTXTools.ExecuteOnElementReady(Handle, procedure ()
    Begin
      FBackButton.OnVisibleChange:=HandleBackButtonVisibleChange;
      FNextButton.OnVisibleChange:=HandleNextButtonVisibleChange;
      resize;
      LayoutChildren;
    end);
end;

Procedure TQTXHeaderBar.FinalizeObject;
Begin
  FBackbutton.free;
  FNextButton.free;
  FCaption.free;
  inherited;
end;

Procedure TQTXHeaderBar.setMargin(const aValue:Integer);
Begin
  if aValue<>FMargin then
  begin
    FMargin:=TInteger.EnsureRange(aValue,1,MAX_INT);

    if ObjectReady
    and TQTXTools.getElementInDOM(Handle) then
    {$IFDEF USE_ANIMFRAME_SYNC}
    w3_requestAnimationFrame( procedure ()
      Begin
        Resize;
      end);
    {$ELSE}
    Resize;
    {$ENDIF}

  end;
end;

Procedure TQTXHeaderBar.HandleNextButtonVisibleChange
          (sender:TObject;aVisible:Boolean);
var
  wd,dx:  Integer;
Begin
  case aVisible of
  false:
    begin
      wd:=clientwidth;
      dec(wd,FMargin);
      if FBackButton.Visible then
      dec(wd,FBackButton.width + FMargin);

      dx:=FMargin;
      if FBackButton.visible then
      inc(dx,FBackButton.Width + FMargin);

      if ObjectReady
      and TQTXTools.getElementInDOM(Handle) then
      {$IFDEF USE_ANIMFRAME_SYNC}
      w3_requestAnimationFrame( procedure ()
      {$ENDIF}
      Begin
        FCaption.fxMoveTo(dx,
          (clientHeight div 2) - FCaption.Height div 2, CNT_ANIM_DELAY,
          Procedure ()
          Begin
            wd:=wd - FMargin;
            FCaption.fxSizeTo(wd,FCaption.Height,CNT_ANIM_DELAY);
          end);
      {$IFDEF USE_ANIMFRAME_SYNC}
      end);
      {$ELSE}
      end;
      {$ENDIF}


    end;
  true:
    Begin

        dx:=FMargin;
        if FBackButton.visible then
        inc(dx,FBackButton.Width + FMargin);

        wd:=ClientWidth - (2 * FMargin);
        if FBackButton.Visible then
        dec(wd,FBackButton.width);
        dec(wd,FNextButton.Width);

            dec(wd,FMargin * 2);
        FCaption.fxSizeTo(wd,FCaption.Height,CNT_ANIM_DELAY,
        procedure ()
        Begin
          FCaption.fxMoveTo(dx,
          (clientHeight div 2) - FCaption.Height div 2, CNT_ANIM_DELAY);
        end);

    end;
  end;

  if ObjectReady
  and TQTXTools.getElementInDOM(Handle) then
  {$IFDEF USE_ANIMFRAME_SYNC}
  w3_requestAnimationFrame( procedure ()
  Begin
    Resize;
  end);
  {$ELSE}
  Resize;
  {$ENDIF}
end;

Procedure TQTXHeaderBar.HandleBackButtonVisibleChange
          (sender:TObject;aVisible:Boolean);
var
  dx: Integer;
  wd: Integer;
Begin

  case aVisible of
  false:
    begin
      FBackButton.fxMoveTo(-FBackButton.width,
        (clientheight div 2) - FBackButton.height div 2,
        CNT_ANIM_DELAY);
    end;
  true:
    Begin
      FBackButton.fxMoveTo(FMargin,
        (clientheight div 2) - FBackButton.height div 2,
        CNT_ANIM_DELAY);
    end;
  end;

  case aVisible of
  false:
    Begin
      {$IFDEF USE_ANIMFRAME_SYNC}
      w3_requestAnimationFrame( procedure ()
      Begin
      {$ENDIF}

        wd:=ClientWidth - (FMargin * 2);
        //dec(wd,FBackButton.width);

        if FNextButton.Visible then
        Begin
          dec(wd,FNextButton.Width);
          dec(wd,FMargin);
        end;

        FCaption.fxMoveTo(FMargin, (clientHeight div 2) - (FCaption.height div 2), CNT_ANIM_DELAY,
        procedure ()
        Begin
          (*
          w3_requestAnimationFrame( procedure ()
          begin *)
            FCaption.fxSizeTo(wd,FCaption.Height,CNT_ANIM_DELAY);
          //end);
        end);

      {$IFDEF USE_ANIMFRAME_SYNC}
      end);
      {$ENDIF}
    end;
  true:
    Begin

      //FBackButton.Top:=(ClientHeight div 2) - FBackButton.height div 2;

      dx:=FMargin + BackButton.Width + FMargin;

      wd:=ClientWidth - (FMargin * 2);
      dec(wd,FBackButton.width);

      if FNextButton.visible then
      Begin
        dec(wd,FNextButton.Width);
        dec(wd,FMargin * 2);
      end else
      dec(wd,FMargin);

      {$IFDEF USE_ANIMFRAME_SYNC}
      w3_requestAnimationFrame( procedure ()
      Begin
      {$ENDIF}
          FCaption.fxMoveTo(dx,
            (clientHeight div 2) - (FCaption.height div 2), CNT_ANIM_DELAY,
            procedure ()
            begin
              w3_requestAnimationFrame( procedure ()
              begin
                FCaption.fxSizeTo(wd,FCaption.Height,CNT_ANIM_DELAY);
              end);
          end);
      {$IFDEF USE_ANIMFRAME_SYNC}
      end);
      {$ENDIF}

    end;
  end;
end;

Procedure TQTXHeaderBar.Resize;
var
  dx: Integer;
  wd: Integer;
Begin
  inherited;
  if FBackbutton.visible then
  FBackbutton.setbounds(FMargin,
    (clientheight div 2) - FBackButton.height div 2,
    FBackButton.width,
    FBackbutton.height);

  if FNextButton.visible then
  FNextButton.setBounds((clientwidth-FMargin)-FNextButton.width,
    (clientHeight div 2) - FNextButton.height div 2,
    FNextButton.width,
    FNextButton.Height);

  dx:=FMargin;
  if FBackButton.visible then
  inc(dx,FBackButton.Width + FMargin);

  wd:=ClientWidth - FMargin;
  if FBackButton.visible then
  dec(wd,FBackButton.Width + FMargin);

  if FNextButton.visible then
  begin
    dec(wd,FNextButton.width + FMargin);
    dec(wd,FMargin);
  end else
  dec(wd,FMargin);

  FCaption.SetBounds(dx,
     (clientHeight div 2) - (FCaption.height div 2),
     wd,FCaption.Height);
end;

end.
