unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Unit3;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //Unit3.Rename:='';
  Unit3.Rename:=Edit1.Text;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  Unit3.Rename_Ok:=true;
  Form2.Close;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  Form2.Close;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  //showmessage(Unit3.Rename);
  Unit3.Rename_Ok:=false;
  if (trim(Unit3.Rename) ='') then begin Unit3.Rename:=FormatDateTime('DD',  Now)+'_'+FormatDateTime('MM',  Now)+'_'+FormatDateTime('YYYY',  Now)+'_'+FormatDateTime('hh',  Now)+'_'+FormatDateTime('nn',  Now)+'_'+FormatDateTime('ss',  Now) end;
  Edit1.Text:=Unit3.Rename;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin

end;

end.

