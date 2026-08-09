unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  DBGrids, Grids, TAGraph, TASeries, TASources, TATools, Unit2, Unit3,
  Types, TAChartUtils, FileUtil, LCLType, Menus, Spin, IniFiles, TACustomSource;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    chPoints: TChart;
    chPointsLineSeries1: TLineSeries;
    chPointsLineSeries2: TLineSeries;
    ctPoints: TChartToolset;
    ctPointsDataPointDragTool1: TDataPointDragTool;
    ctPointsDataPointDragTool2: TDataPointDragTool;
    FloatSpinEdit1: TFloatSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListChartSource1: TListChartSource;
    Memo1: TMemo;
    MenuClearDefault: TMenuItem;
    MenuClearSource2: TMenuItem;
    MenuLoasSource2: TMenuItem;
    MenuSaveDefault: TMenuItem;
    MenuOpenDefault: TMenuItem;
    PopupMenu1: TPopupMenu;
    ScrollBar1: TScrollBar;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ctPointsDataPointDragTool1AfterMouseUp(ATool: TChartTool;
      APoint: TPoint);
    procedure FormCreate(Sender: TObject);
    function ListChartSource1Compare(AItem1, AItem2: Pointer): Integer;
    procedure MenuClearDefaultClick(Sender: TObject);
    procedure MenuClearSource2Click(Sender: TObject);
    procedure MenuLoasSource2Click(Sender: TObject);
    procedure MenuOpenDefaultClick(Sender: TObject);
    procedure MenuSaveDefaultClick(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public
    function StrIntToStr(Sender: string): string;
    function StrFloatToStr(Sender: string): string;
    Function CheckDirectory(C_DNAME: string;Debug_:TMemo):boolean; //True=Error
  end;

var
  Form1: TForm1;
  XY01: array[1..240, 0..1] of double;
  XY02: array[1..240, 0..1] of double;
  X1,X2:integer;
  Raw:extended;

implementation

{$R *.lfm}

{ TForm1 }

function TForm1.StrIntToStr(Sender: string): string;
var
  i:integer;
begin
  i:=0;
  Try
    i:=StrToInt(Sender);
  except
    On E : EConvertError do
      i:=0;
  end;
  result:= IntToStr(i);
end;

function TForm1.StrFloatToStr(Sender: string): string;
var
  i:double;
begin
  i:=0;
  Try
    i:=StrToFloat(Sender);
  except
    On E : EConvertError do
      i:=0;
  end;
  result:= FloatToStr(i);
end;

Function TForm1.CheckDirectory(C_DNAME: string;Debug_:TMemo):boolean; //True=Error
begin

  result:= false;

  if(C_DNAME<>'')then
  if Not DirectoryExists(C_DNAME) Then
  begin
    {$I-}
    //{$I-} or {$IOCHECKS OFF}
    //{$I-} rewrite (f); {$I+}
    //if IOResult<>0 then begin Writeln ('Error opening file: "file.txt"'); exit; end;
    mkdir(C_DNAME);
    {$I+}
    if IOResult<>0 then
    begin
      Debug_.Append('Directory '+C_DNAME+' error occurred. Details: '+ EInOutError.ClassName);
      ShowMessage('Cannot create '+C_DNAME+' directory. Details: '+ EInOutError.ClassName);
      result:= true;
    end;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
begin

  chPointsLineSeries1.Clear;
  X1:=1;
  X2:=1;
  for i:= 1 to 240 do
  begin
    XY01[i,0]:=i;
    XY02[i,0]:=1;
  end;
  Raw:=(ScrollBar1.Position*(-1))-600;
  Raw:=Raw/100;
end;

function TForm1.ListChartSource1Compare(AItem1, AItem2: Pointer): Integer;
begin

end;

procedure TForm1.MenuClearDefaultClick(Sender: TObject);
begin
  chPointsLineSeries1.Clear;
end;

procedure TForm1.MenuClearSource2Click(Sender: TObject);
begin
  chPointsLineSeries2.Clear;
end;

procedure TForm1.MenuLoasSource2Click(Sender: TObject);
var
  i:integer;
  s: string;
  MyIni: TIniFile;
  //User: string;
  //Attempts: Integer;
  //IsActive: Boolean;
begin
  if CheckDirectory('Default',Memo1) then begin Showmessage('Default Folder Error'); exit; end;

  s:= GetCurrentDir+'\Default\'+ 'default.default';

  with TOpenDialog.Create(Self) do
        begin
          InitialDir:=GetCurrentDir+'\Default';
          Filename := '_'+FormatDateTime('DD',  Now)+'_'+FormatDateTime('MM',  Now)+'_'+FormatDateTime('YYYY',  Now)+'_'+FormatDateTime('hh',  Now)+'_'+FormatDateTime('nn',  Now)+'_'+FormatDateTime('ss',  Now)+'.default';
          if Execute then
            s := FileName
          else
          begin
            Free; exit;
          end;
          Free;
        end;

  if FileExists(s) then
  begin
    MyIni := TIniFile.Create(s);
    try
      chPointsLineSeries2.Clear;
      for i:=1 to 240 do
      begin
        XY02[i,0]:=StrToFloat(StrFloatToStr(MyIni.ReadString('XY', 'X'+i.ToString, '0')));
        XY02[i,1]:=StrToFloat(StrFloatToStr(MyIni.ReadString('XY', 'Y'+i.ToString, '0.00000')));
        chPointsLineSeries2.AddXY(XY02[i,0],XY02[i,1]);
      end;
    finally
      // Always free the object
      MyIni.Free;
    end;
  end
  else
  begin
    Showmessage('File not found');
  end;
end;

procedure TForm1.MenuOpenDefaultClick(Sender: TObject);
var
  i:integer;
  s: string;
  MyIni: TIniFile;
  //User: string;
  //Attempts: Integer;
  //IsActive: Boolean;
begin
  if CheckDirectory('Default',Memo1) then begin Showmessage('Default Folder Error'); exit; end;

  s:= GetCurrentDir+'\Default\'+ 'default.default';

  with TOpenDialog.Create(Self) do
        begin
          InitialDir:=GetCurrentDir+'\Default';
          Filename := s;
          if Execute then
            s := FileName
          else
          begin
            Free; exit;
          end;
          Free;
        end;

  if FileExists(s) then
  begin
    MyIni := TIniFile.Create(s);
    try
      //MyIni.WriteString('User-Settings', 'Username', 'gfgg');
      //MyIni.WriteInteger('DB-INFO', 'MaxAttempts', 255522);
      //MyIni.WriteBool('Settings', 'AutoLogin', true);
      //User := MyIni.ReadString('User-Settings', 'Username', 'Guest');
      //Attempts := MyIni.ReadInteger('DB-INFO', 'MaxAttempts', 3);
      //IsActive := MyIni.ReadBool('Settings', 'AutoLogin', False);
      chPointsLineSeries1.Clear;
      for i:=1 to 240 do
      begin
        XY01[i,0]:=StrToFloat(StrFloatToStr(MyIni.ReadString('XY', 'X'+i.ToString, '0')));
        XY01[i,1]:=StrToFloat(StrFloatToStr(MyIni.ReadString('XY', 'Y'+i.ToString, '0.00000')));
        chPointsLineSeries1.AddXY(XY01[i,0],XY01[i,1]);
      end;
    finally
      // Always free the object
      MyIni.Free;
    end;
  end
  else
  begin
    Showmessage('File not found');
  end;
end;

procedure TForm1.MenuSaveDefaultClick(Sender: TObject);
var
  i:integer;
  s: string;
  p_:integer;
  MyIni: TIniFile;
  //User: string;
  //Attempts: Integer;
  //IsActive: Boolean;
  ResultCode: Integer;
  DirPath: string;
begin
  with TSaveDialog.Create(Self) do
        begin
          InitialDir:=GetCurrentDir+'\Default';
          Filename := '_'+FormatDateTime('DD',  Now)+'_'+FormatDateTime('MM',  Now)+'_'+FormatDateTime('YYYY',  Now)+'_'+FormatDateTime('hh',  Now)+'_'+FormatDateTime('nn',  Now)+'_'+FormatDateTime('ss',  Now)+'.default';
          if Execute then
            s := FileName
          else
          begin
            Free; exit;
          end;
          Free;
        end;

  p_:=pos('.default',LowerCase(s));
  if (p_>1) then
    s:= s
  else
    s:= s+'.default';

  DirPath := ExtractFilePath(s);
  if not DirectoryExists(DirPath) then begin Showmessage('Directory Not Exists'); exit; end;

  if FileExists(s) then
  begin
    ResultCode := Application.MessageBox('Over write file?' + sLineBreak + '!!!', 'Confirm',MB_ICONQUESTION + MB_YESNO);
    if (ResultCode = IDYES) then
      begin  end
    else
      begin exit; end;
  end;

  //if FileExists(s) then
  //begin
    MyIni := TIniFile.Create(s);
    try
      //MyIni.WriteString('User-Settings', 'Username', 'gfgg');
      //MyIni.WriteInteger('DB-INFO', 'MaxAttempts', 255522);
      //MyIni.WriteBool('Settings', 'AutoLogin', true);
      //User := MyIni.ReadString('User-Settings', 'Username', 'Guest');
      //Attempts := MyIni.ReadInteger('DB-INFO', 'MaxAttempts', 3);
      //IsActive := MyIni.ReadBool('Settings', 'AutoLogin', False);

      for i:=1 to 240 do
      begin
        MyIni.WriteString('XY', 'X'+i.ToString, StrFloatToStr(XY01[i,0].ToString));
        MyIni.WriteString('XY', 'Y'+i.ToString, StrFloatToStr(XY01[i,1].ToString));

      end;


    finally
      // Always free the object
      MyIni.Free;
    end;
  //end
  //else
  if not FileExists(s) then
  begin
    Showmessage('Can not save file');
    exit;
  end;

end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
  Raw:=(ScrollBar1.Position*(-1))-600;
  Raw:=Raw/100;
  //Label2.Caption:=FloatToStr(Raw);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin

  X1:=X1+1;
  if X1 >240 then
  begin
    X1:=240;
    Timer1.Enabled:=false;
    if Timer1.Enabled then Button6.Caption:='Stop' else Button6.Caption:='Start';
  end;

  if chPointsLineSeries1.Count>=X1 then
  begin
    chPointsLineSeries1.SetYValue(X1-1, Raw);
    XY01[X1,0]:=chPointsLineSeries1.GetXValue(X1-1);
    XY01[X1,1]:=chPointsLineSeries1.GetYValue(X1-1);
  end;

  if (chPointsLineSeries1.Count+1)<X1 then
  begin
    X1:=chPointsLineSeries1.Count+1;
    chPointsLineSeries1.AddXY(X1, Raw);
    XY01[X1,0]:=chPointsLineSeries1.GetXValue(X1-1);
    XY01[X1,1]:=chPointsLineSeries1.GetYValue(X1-1);
  end;

  if (chPointsLineSeries1.Count+1)=X1 then
  begin
    chPointsLineSeries1.AddXY(X1, Raw);
    XY01[X1,0]:=chPointsLineSeries1.GetXValue(X1-1);
    XY01[X1,1]:=chPointsLineSeries1.GetYValue(X1-1);
  end;

  Label1.Caption:=X1.ToString+' ,';
  Label2.Caption:=XY01[X1,0].ToString + ', '+ XY01[X1,1].ToString;
end;

procedure TForm1.ctPointsDataPointDragTool1AfterMouseUp(ATool: TChartTool; APoint: TPoint);
var
  i: Integer;
  P_:integer;
  Check_:boolean;
begin
  //Label1.Caption:='# X:Y';
  for i := 0 to 9 do
  begin
    Check_:=false;
    chPointsLineSeries1.SetXValue(i,StrToFloat(FormatFloat('0.00',chPointsLineSeries1.GetXValue(i))));
    chPointsLineSeries1.SetYValue(i,StrToFloat(FormatFloat('0.00',chPointsLineSeries1.GetYValue(i))));

    if (chPointsLineSeries1.GetXValue(i)>10) then  chPointsLineSeries1.SetXValue(i,10);
    if (chPointsLineSeries1.GetXValue(i)<0) then  chPointsLineSeries1.SetXValue(i,0);
    if (chPointsLineSeries1.GetYValue(i)>100) then  chPointsLineSeries1.SetYValue(i,100);
    if (chPointsLineSeries1.GetYValue(i)<0) then  chPointsLineSeries1.SetYValue(i,0);
    if (XY01[i,0]<>chPointsLineSeries1.GetXValue(i)) then  Check_:=true;
    if (XY01[i,1]<>chPointsLineSeries1.GetYValue(i)) then  Check_:=true;

    P_:=i+1;


    if ((i>=0) and (i<=8) and Check_) then
    begin
      if (chPointsLineSeries1.GetXValue(i)>chPointsLineSeries1.GetXValue(i+1)) then
      begin
        chPointsLineSeries1.SetXValue(i,chPointsLineSeries1.GetXValue(i+1)-0.1);
        //Label1.Caption:=Label1.Caption+chr(13)+P_.ToString + '>>';
      end;
    end;
    if ((i>=1) and (i<=9) and Check_) then
    begin
      if (chPointsLineSeries1.GetXValue(i)<chPointsLineSeries1.GetXValue(i-1)) then
      begin
        chPointsLineSeries1.SetXValue(i,chPointsLineSeries1.GetXValue(i-1)+0.1);
        //Label1.Caption:=Label1.Caption+chr(13)+P_.ToString + '<<';
      end;
    end;

    //Label1.Caption:=Label1.Caption+chr(13)+P_.ToString + ' ' + FormatFloat('0.00',chPointsLineSeries1.GetXValue(i)) + ':' + FormatFloat('0.00',chPointsLineSeries1.GetYValue(i));
    XY01[i,0]:=chPointsLineSeries1.GetXValue(i);
    XY01[i,1]:=chPointsLineSeries1.GetYValue(i);

  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if chPointsLineSeries1.Count>=X1 then
  begin
    chPointsLineSeries1.SetYValue(X1-1, FloatSpinEdit1.Value);
    XY01[X1,0]:=chPointsLineSeries1.GetXValue(X1-1);
    XY01[X1,1]:=chPointsLineSeries1.GetYValue(X1-1);
  end;

  if (chPointsLineSeries1.Count+1)<X1 then
  begin
    X1:=chPointsLineSeries1.Count+1;
    chPointsLineSeries1.AddXY(X1, FloatSpinEdit1.Value);
    XY01[X1,0]:=chPointsLineSeries1.GetXValue(X1-1);
    XY01[X1,1]:=chPointsLineSeries1.GetYValue(X1-1);
  end;

  if (chPointsLineSeries1.Count+1)=X1 then
  begin
    chPointsLineSeries1.Add(FloatSpinEdit1.Value,'sd',clRed);
    chPointsLineSeries1.AddXY(X1, FloatSpinEdit1.Value);
    XY01[X1,0]:=chPointsLineSeries1.GetXValue(X1-1);
    XY01[X1,1]:=chPointsLineSeries1.GetYValue(X1-1);
  end;

  Label1.Caption:=X1.ToString+' ,';
  Label2.Caption:=XY01[X1,0].ToString + ', '+ XY01[X1,1].ToString;

  //chPointsLineSeries2.AddXY(P_, P_*10);
  //XY02[P_,0]:=chPointsLineSeries2.GetXValue(i-1);
  //XY02[P_,1]:=chPointsLineSeries2.GetYValue(i-1);

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  X1:=X1-1;
  if X1<=0 then X1:=1;

  Label1.Caption:=X1.ToString+' ,';
  Label2.Caption:=XY01[X1,0].ToString + ', '+ XY01[X1,1].ToString;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  X1:=X1+1;
  if X1>240 then X1:=240;

  Label1.Caption:=X1.ToString+' ,';
  Label2.Caption:=XY01[X1,0].ToString + ', '+ XY01[X1,1].ToString;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if FloatSpinEdit1.Increment/10 >= 0.00001 then FloatSpinEdit1.Increment:=FloatSpinEdit1.Increment/10;
  Label3.Caption:=FloatSpinEdit1.Increment.ToString;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  if FloatSpinEdit1.Increment*10 <=1 then FloatSpinEdit1.Increment:=FloatSpinEdit1.Increment*10;
  Label3.Caption:=FloatSpinEdit1.Increment.ToString;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin

  Timer1.Enabled:= not Timer1.Enabled;
  if Timer1.Enabled then X1:=1;
  if Timer1.Enabled then Button6.Caption:='Stop' else Button6.Caption:='Start';
end;

end.

