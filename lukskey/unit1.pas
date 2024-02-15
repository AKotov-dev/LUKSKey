unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ComCtrls, Process, DefaultTranslator, AsyncProcess, Types, LCLType,
  IniPropStorage;

type

  { TMainForm }

  TMainForm = class(TForm)
    FindLUKSPartitions: TAsyncProcess;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    IniPropStorage1: TIniPropStorage;
    LUKSMountPoint: TAsyncProcess;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    LogMemo: TMemo;
    ProgressBar1: TProgressBar;
    ChangeBtn: TSpeedButton;
    StaticText1: TStaticText;
    procedure FindLUKSPartitionsReadData(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LUKSMountPointReadData(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure ChangeBtnClick(Sender: TObject);

  private

  public

  end;

resourcestring
  SStartKeyChange = 'Change the key of the selected partition?';
  SWaitChangeKey = 'Changing key, please wait...';
  SCompleted = 'Completed.';
  SMountPoint = 'Mount point (crypt_):';


var
  MainForm: TMainForm;
  command: string;

implementation

uses start_trd;

{$R *.lfm}

{ TMainForm }


procedure TMainForm.FormShow(Sender: TObject);
begin
  IniPropStorage1.Restore;
  //Показываем разделы LUKS
  FindLUKSPartitions.Execute;
end;

//Вывод точки монтирования
procedure TMainForm.ListBox1Click(Sender: TObject);
begin
  if ListBox1.SelCount <> 0 then
  begin
    LUKSMountPoint.Parameters.Clear;
    LUKSMountPoint.Parameters.Add('-c');
    LUKSMountPoint.Parameters.Add(
      'lsblk -l ' + ListBox1.Items[ListBox1.ItemIndex]);
    // 'lsblk -l ' + ListBox1.Items[ListBox1.ItemIndex] + ' | grep crypt');
    // | awk ' + '''' + '{print $NF}' + '''' + ')"');
    LUKSMountPoint.Execute;
  end;
end;

//Значки в списке разделов LUKS
procedure TMainForm.ListBox1DrawItem(Control: TWinControl; Index: integer;
  ARect: TRect; State: TOwnerDrawState);

var
  BitMap: TBitMap;
begin
  try
    BitMap := TBitMap.Create;
    with ListBox1 do
    begin
      Canvas.FillRect(aRect);

      //Название (текст по центру-вертикали)
      Canvas.TextOut(aRect.Left + 32, aRect.Top + ItemHeight div
        2 - Canvas.TextHeight('A') div 2 + 1, Items[Index]);

      //Иконки
      ImageList1.GetBitMap(0, BitMap);

      Canvas.Draw(aRect.Left + 2, aRect.Top + (ItemHeight - 24) div 2 + 1, BitMap);
    end;
  finally
    BitMap.Free;
  end;
end;


//Создание файлов ключей и запуск команды с выводом лога
procedure TMainForm.ChangeBtnClick(Sender: TObject);
var
  S: TStringList;
  FStartKeyChange: TThread;
begin
  if (ListBox1.SelCount = 0) or (Trim(Edit1.Text) = '') or (Trim(Edit2.Text) = '') then
    Exit;

  try
    S := TStringList.Create;

    if not DirectoryExists('/root/tmp') then MkDir('/root/tmp');

    S.Text := Edit1.Text;
    S.SaveToFile('/root/tmp/luksold.key');

    S.Text := Edit2.Text;
    S.SaveToFile('/root/tmp/luksnew.key');

    command :=
      'truncate -s -1 /root/tmp/{luksold.key,luksnew.key}; ' +
      'cryptsetup luksChangeKey ' + ListBox1.Items[ListBox1.ItemIndex] +
      ' --key-file /root/tmp/luksold.key /root/tmp/luksnew.key; ' +
      'shred -n 3 -u -z /root/tmp/{luksold.key,luksnew.key}';

    if MessageDlg(SStartKeyChange, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      FStartKeyChange := StartKeyChange.Create(False);
      FStartKeyChange.Priority := tpNormal;
    end;
  finally
    S.Free;
  end;
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_RETURN then ChangeBtn.Click;
end;

//Показать/Скрыть пароли
procedure TMainForm.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked then
  begin
    Edit1.PasswordChar := #0;
    Edit2.PasswordChar := #0;
  end
  else
  begin
    Edit1.PasswordChar := '*';
    Edit2.PasswordChar := '*';
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MainForm.Caption := Application.Title;

  if not DirectoryExists(GetUserDir + '.config') then
    MkDir(GetUserDir + '.config');
  IniPropStorage1.IniFileName := GetUserDir + '.config/lukskey.conf';
end;

//Показать UUID
procedure TMainForm.LUKSMountPointReadData(Sender: TObject);
begin
  LogMemo.Lines.LoadFromStream(LUKSMountPoint.Output);
end;

//Читаем список разделов LUKS
procedure TMainForm.FindLUKSPartitionsReadData(Sender: TObject);
begin
  ListBox1.Items.LoadFromStream(FindLUKSPartitions.Output);
end;

end.
