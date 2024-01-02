unit start_trd;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, ComCtrls, Forms;

type
  StartKeyChange = class(TThread)
  private

    { Private declarations }
  protected
  var
    Result: TStringList;

    procedure Execute; override;

    procedure ShowLog;
    procedure StartProgress;
    procedure StopProgress;

  end;

implementation

uses Unit1;

{ TRD }

procedure StartKeyChange.Execute;
var
  ExProcess: TProcess;
begin
  try //Вывод лога и прогресса
    Synchronize(@StartProgress);

    FreeOnTerminate := True; //Уничтожить по завершении
    Result := TStringList.Create;

    //Рабочий процесс
    ExProcess := TProcess.Create(nil);

    //Создаём раздел ${usb}1
    ExProcess.Executable := 'bash';
    ExProcess.Parameters.Add('-c');
    //Группа команд (parted)
    ExProcess.Parameters.Add(command);

    ExProcess.Options := [poUsePipes, poStderrToOutPut, poWaitOnExit];
    //, poWaitOnExit (синхронный вывод)

    ExProcess.Execute;

    //Выводим лог динамически
   { while ExProcess.Running do
    begin
      Result.LoadFromStream(ExProcess.Output);

      //Выводим лог
      if Result.Count <> 0 then
        Synchronize(@ShowLog);
    end;}
    Result.LoadFromStream(ExProcess.Output);
    Synchronize(@ShowLog);

  finally
    Synchronize(@StopProgress);
    Result.Free;
    ExProcess.Free;
    Terminate;
  end;
end;

{ БЛОК ОТОБРАЖЕНИЯ ЛОГА }

//Старт индикатора
procedure StartKeyChange.StartProgress;
begin
  with MainForm do
  begin
    LogMemo.Text := SWaitChangeKey;

    ProgressBar1.Style := pbstMarquee;
    ProgressBar1.Refresh;

    ListBox1.Enabled := False;
    Edit1.Enabled := False;
    Edit2.Enabled := False;
    ChangeBtn.Enabled := False;

    Application.ProcessMessages;
  end;
end;

//Стоп индикатора
procedure StartKeyChange.StopProgress;
begin
  with MainForm do
  begin
    //    LogMemo.Append('');
    LogMemo.Lines.Append(SCompleted);
    ProgressBar1.Style := pbstNormal;
    ProgressBar1.Refresh;

    //Курсор в начало
    LogMemo.SelStart := 0;
    MainForm.LogMemo.SelLength := 0;

    ListBox1.Enabled := True;
    Edit1.Enabled := True;
    Edit2.Enabled := True;
    ChangeBtn.Enabled := True;

    Application.ProcessMessages;
  end;
end;

//Вывод лога
procedure StartKeyChange.ShowLog;
{var
  i: integer;}
begin
  //Вывод построчно
  // for i := 0 to Result.Count - 1 do
  //   MainForm.LogMemo.Lines.Append(Result[i]);

  //Вывод пачками
  MainForm.LogMemo.Lines.Assign(Result);

  //Промотать список вниз
  MainForm.LogMemo.SelStart := Length(MainForm.LogMemo.Text);
  MainForm.LogMemo.SelLength := 0;
end;

end.
