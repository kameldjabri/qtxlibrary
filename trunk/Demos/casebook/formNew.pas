unit formNew;

interface

uses 
  W3System, W3Graphics, W3Components, W3Forms, W3Fonts, W3Borders,
  W3Application,
  qtxutils,
  qtxeffects;

type
  TformNew=class(TW3form)
  private
    {$I 'formNew:intf'}
  protected
    procedure InitializeForm; override;
    procedure InitializeObject; override;
    procedure Resize; override;
  public
    procedure FormActivated;override;
  end;

implementation

{ TformNew}
uses casebook, qtxheader;

procedure TformNew.InitializeForm;
begin
  inherited;
  // this is a good place to initialize components
end;

procedure TformNew.InitializeObject;
begin
  inherited;
  {$I 'formNew:impl'}
end;

procedure TformNew.FormActivated;
var
  mOldTitle:  String;
  mHead:  TQTXHeaderBar;
Begin
  inherited;
  mHead:=TApplication(application).Header;

  mOldTitle:=mHead.Title.Caption;
  mHead.Title.Caption:='CaseBook <i class="fa fa-angle-double-right"></i> New post';
  mHead.backbutton.Visible:=True;
  mHead.backbutton.caption:='Back';
  //mHead.Width:=TApplication(application).Header.Width +1;
  //mHead.Width:=TApplication(application).Header.Width -1;
  mHead.backbutton.OnClick:=Procedure (sender:TObject)
    begin
      Application.gotoForm('mainform',feToLeft);
    end;
end;
 
procedure TformNew.Resize;
begin
  inherited;
end;
 
end.
