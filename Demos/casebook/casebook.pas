unit casebook;

interface

uses 
  W3System, W3Components, W3Forms, W3Application,
  mainForm, w3header,w3toolbutton, w3graphics,
  qtxutils,
  qtxeffects,
  qtxheader,
  formLogin,
  formNew,
  formAccount,
  formProfile;

type

  TApplication = class(TW3CustomApplication)
  private
    FForm1:   TForm1;
    FLogin:   TformLogin;
    FProfile: TformProfile;
    FNew:     TFormNew;
    FAccount: TformAccount;
    FHeader:  TQTXHeaderBar;
  protected
    procedure ApplicationStarting; override;
  public
    Property  NewForm:TFormNew read FNew;
    Property  FormLogin:TformLogin read FLogin;
    Property  MainForm:TForm1 read FForm1;
    Property  ProfileForm:TformProfile read FProfile;
    Property  AccountForm:TformAccount read FAccount;
    Property  Header:TQTXHeaderBar read FHeader;
  end;

implementation

{ TApplication}

procedure TApplication.ApplicationStarting;
var
  mLogin: TformLogin;
  mTemp:  TQTXHeaderBar;
begin
  (* Link to Font-Awesome *)
  TQTXTools.loadCSS('stylesheet',
  'http://maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css',NIL);


  (* Setup global header control *)
  //w3_callback( procedure ()
  //begin
  TQTXTools.ExecuteOnDocumentReady( procedure ()
  begin
    w3_callback( procedure ()
    Begin

      Fheader:=TQTXHeaderBar.Create(display);
      FHeader.top:=-1;
      //FHeader.Title.Caption:='CaseBook';
      FHeader.Height:=40;
      application.display.layoutchildren;

    end,
    200);
  end);

  //FHeader.Height:=40;
  //FHeader.Title.Container.StyleClass:='Headings';
  //end,200);

  (* mTemp:=TQTXHeaderBar.Create(display);
  mTemp.height:=40;
  mTemp.title.background.fromColor(clRed);
  mTemp.nextButton.OnClick:=Procedure (sender:TObject)
    Begin
      mTemp.BackButton.Visible:=not mTemp.BackButton.Visible;
    end;
  mTemp.BackButton.OnClick:=Procedure (sender:TObject)
    Begin
      mTemp.Title.Caption:='Testing changes';
      w3_callback( procedure ()
        Begin
          mTemp.title.caption:='And this is cool stuff';
        end,
        1000);
    end;   *)


  FLogin:=TformLogin.Create(display.view);
  FLogin.name:='FormLogin';
  RegisterFormInstance(FLogin, true);

  FForm1 := TForm1.Create(Display.View);
  FForm1.Name := 'mainForm';
  RegisterFormInstance(FForm1, false);

  FProfile:=TformProfile.Create(display.view);
  FProfile.name:='FormProfile';
  RegisterFormInstance(FProfile,false);

  FAccount:=TformAccount.Create(display.view);
  FAccount.name:='FormAccount';
  RegisterFormInstance(FAccount,false);


  FNew:=TFormNew.Create(display.view);
  FNew.name:='FormNew';
  RegisterFormInstance(FNew,false);
  inherited;
end;


end.
