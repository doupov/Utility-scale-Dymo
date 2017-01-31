unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvComponentBase, JvHidControllerClass, StdCtrls, ShellApi,ClipBrd;

type
  TForm1 = class(TForm)
    JvHidDeviceController1: TJvHidDeviceController;
    Edit5: TEdit;
    Label3: TLabel;
    boxclip: TCheckBox;
    boxadd: TCheckBox;
    boxconv: TCheckBox;
    Button1: TButton;
    procedure JvHidDeviceController1Arrival(HidDev: TJvHidDevice);
    procedure JvHidDeviceController1DeviceData(HidDev: TJvHidDevice;
      ReportID: Byte; const Data: Pointer; Size: Word);
    procedure FormCreate(Sender: TObject);
    procedure boxaddClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  ReceivedData : Array[0..5] of Byte;
  HIDDevice: TJvHidDevice;
  gram : boolean;
  division : boolean;
const
  VendorID = $0922;
  ProductID = $8000;

implementation

{$R *.dfm}


procedure TForm1.boxaddClick(Sender: TObject);
begin
boxconv.Enabled := boxadd.Checked;
Label3.Visible := NOT boxadd.Checked;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
ShellExecute(Handle,
               'open',
               'http://www.jera.cz/donate_scale.php',
               nil,
               nil,
               SW_SHOW);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
gram := true;
division := false;
Label3.Caption := '';
end;

procedure TForm1.JvHidDeviceController1Arrival(HidDev: TJvHidDevice);
begin
if ((HidDev.Attributes.VendorID = VendorID) AND
    (HidDev.Attributes.ProductID > ProductID)) then
  begin
    HIDDevice := HidDev;
    HIDDevice.CheckOut;
  end;

end;



procedure TForm1.JvHidDeviceController1DeviceData(HidDev: TJvHidDevice;
  ReportID: Byte; const Data: Pointer; Size: Word);
  var raw_weight : integer;
  var raw_weight_oz : real;
  var weight_conv : real;
  var weight_conv_int : integer;
  var weight_conv_h : integer;
  var weight_conv_l : real;
begin
  CopyMemory(@ReceivedData, Data, Size);
  raw_weight := ReceivedData[3] + ReceivedData[4] * 256;
  if(raw_weight > 0) then
    begin
      if (ReceivedData[1] = 2) then   //grams
      begin
        Edit5.Text := IntToStr(raw_weight);
        Label3.Caption := 'g';
        gram := true;

      end;
      if (ReceivedData[1] = 11) then  //oz
      begin
        raw_weight_oz := raw_weight*0.1;
        Edit5.Text := FloatToStr(raw_weight_oz);
        Label3.Caption := 'oz';
        gram := false;
      end;
   end
   else
     begin
       Edit5.Text := '0';
     end;


  if(boxadd.Checked) then
  begin
    if(gram) then
    begin
      if(boxconv.Checked) then
        begin
        weight_conv := StrToFloat(Edit5.Text);
        weight_conv_int := Trunc(weight_conv);
        weight_conv_h := weight_conv_int div 1000;
        weight_conv_l := weight_conv - (weight_conv_h*1000);
        if(weight_conv_h > 0) then Edit5.Text := FloatToStr(weight_conv_h)+'kg '+FloatToStr(weight_conv_l)+'g'
        else Edit5.Text := FloatToStr(weight_conv_l)+'g'
        end
      else Edit5.Text := Edit5.Text+'g';
    end
    else
    begin
        if(boxconv.Checked) then
        begin
        weight_conv := StrToFloat(Edit5.Text);
        weight_conv_int := Trunc(weight_conv*10);
        weight_conv_h := weight_conv_int div 160;
        weight_conv_l := weight_conv - (weight_conv_h*16);
        if(weight_conv_h > 0) then Edit5.Text := FloatToStr(weight_conv_h)+'lb '+FloatToStr(weight_conv_l)+'oz'
        else Edit5.Text := FloatToStr(weight_conv_l)+'oz'
        end
      else Edit5.Text := Edit5.Text+'oz';
    end;
  end;

  if(boxclip.Checked) then Clipboard.AsText := Edit5.Text;

  end;


end.
