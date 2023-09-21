program Sudoku;

uses
  Forms,
  SudokoMain in 'SudokoMain.pas' {frmSudoko},
  MyUtils in '..\MyUtils\MyUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmSudoko, frmSudoko);
  Application.Run;
end.
