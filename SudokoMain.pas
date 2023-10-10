unit SudokoMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, ovctcmmn, ovctcell,
  ovctcstr, ovctcedt, ovcbase, ovctable, ovctcbef, ovctcsim, Menus,
  ActnList;

const
  MINVAL = 1;
  MAXVAL = 9;
  SUBRECSIZE = 3;

type
  TRowColNum = MINVAL..MAXVAL;

  TRowColNumE = 0..MAXVAL;

  TValueSet = set of TRowColNum;

  TGrid = class;

  TCell = class
  private
    fGrid            : TGrid;
    fValue           : TRowColNumE;
    fImpossibleValues: TValueSet;
    function GetValue: TRowColNumE;
    procedure SetValue(const Value: TRowColNumE);
    function GetPossibleValues: TValueSet;
  public
    Row              : TRowColNum;
    Col              : TRowColNum;
    procedure Assign(aCell: TCell);
    Constructor Create(aGrid: TGrid; aCol, aRow: TRowColNum);
    Destructor Destroy; override;
    function BitCount: byte;
    function RowValues(ExcludeCell: TCell): TValueSet;
    function ColValues(ExcludeCell: TCell): TValueSet;
    function RectValues(ExcludeCell: TCell): TValueSet;
    property Value: TRowColNumE
             read GetValue
             write SetValue;
    property PossibleValues: TValueSet
             read GetPossibleValues;
    function IsAPossibleValue(aValue: TRowColNum): boolean;
  end;

  TSquare = record
    Row, Col: byte;
    Possibilities: TValueSet;
  end;

  TSquaresList = class
  private
    function GetCount: integer;
    procedure SetCount(const Value: integer);
  public
    Item: array of TSquare;
    procedure Add(aCol, aRow: byte; aPossibilities: TValueSet);
    property Count: integer
             read GetCount
             write SetCount;
    constructor Create; 
    procedure Sort;
  end;

  TGrid = class
  private
    fChanged: boolean;
    fData: array[TRowColNum, TRowColNum] of TCell;
    fEmptySquares: TSquaresList;
    function GetData(Col, Row: TRowColNum): TCell;
    procedure ClearData;
    procedure SetChanged(const Value: boolean);
  public
    procedure Assign(aGrid: TGrid);
    property Changed: boolean
             read fChanged
             write SetChanged;
    Constructor Create(aOwner: TGrid); 
    Destructor Destroy; override;
    property Data[Col, Row: TRowColNum]: TCell
             read GetData;
    function EmptySquares: TSquaresList;
    function SaveData(const FileName: string): boolean;
    function LoadData(const FileName: string): boolean;
    function SolveIt(Level: integer): boolean;
    function Solved: boolean;
    function Impossible: boolean;
  end;

  THistRec = record
    LastCol: byte;
    LastRow: byte;
    LastVal: byte;
  end;

  TfrmSudoko = class(TForm)
    lblStatus: TLabel;
    OvcTable1: TOvcTable;
    OvcTCSimpleField1: TOvcTCSimpleField;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Revert1: TMenuItem;
    Clear1: TMenuItem;
    SolveIt1: TMenuItem;
    ActionList1: TActionList;
    actExit: TAction;
    actRevert: TAction;
    actClear: TAction;
    actSave: TAction;
    actPrint: TAction;
    Print1: TMenuItem;
    actSaveAs: TAction;
    SaveDialog1: TSaveDialog;
    actSolveIt: TAction;
    Help1: TMenuItem;
    RedNoCSolution1: TMenuItem;
    Green1PossibleNUmber1: TMenuItem;
    Yellow2PossibleNumbers1: TMenuItem;
    Fuschiamorethan2possiblenumbers1: TMenuItem;
    Undo2: TMenuItem;
    procedure StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
      const cValue: String);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnClearClick(Sender: TObject);
    procedure OvcTable1GetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure OvcTable1GetCellData(Sender: TObject; RowNum,
      ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure OvcTable1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure OvcTable1DoneEdit(Sender: TObject; RowNum, ColNum: Integer);
    procedure OvcTCSimpleField1MouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure OvcTCSimpleField1Change(Sender: TObject);
    procedure btnRevertClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actRevertExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actSolveItExecute(Sender: TObject);
    procedure OvcTable1PaintUnusedArea(Sender: TObject);
    procedure OvcTable1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Undo2Click(Sender: TObject);
  private
    fGrid: TGrid;
    fIsSolved: boolean;
    fSaveFileName: string;
    fCellData: string[255];
    fHistory: array of THistRec;

    function IsAPossibleValue(aValue: integer; Col, Row: TRowColNum;
                              var ErrMsg: string): boolean;
    function GetGrid: TGrid;
    procedure ClearData;
    procedure AddHist(Hist: THistRec);
    { Private declarations }
  public
    { Public declarations }
    property Grid: TGrid
             read GetGrid;
    function SaveFileName: string;
    Destructor Destroy; override;
    Constructor Create(aOwner: TComponent); override;
  end;

var
  frmSudoko: TfrmSudoko;

implementation

uses
  MyUtils, ovcsf;

{$R *.dfm}

function TheFirstPossibility(Possibilities: TValueSet): byte;
var
  i: integer;
begin
  for i := MINVAL to MAXVAL do
    if i in Possibilities then
      begin
        result := i;
        exit;
      end;
  raise Exception.Create('Possibilities set is empty');
end;

function BitCount(Possibilities: TValueSet): byte;
var
  i: integer;
begin
  result := 0;
  for i := MINVAL to MAXVAL do
    if i in Possibilities then
      inc(result)
end;

// Its a possible value if
//   1. Its not already in the RowValues
//   2. Its not already in the ColValues
//   3. Its not already in the RectValues
function TfrmSudoko.IsAPossibleValue( aValue: integer; Col, Row: TRowColNum;
                                   var ErrMsg: string): boolean;
var
  InRow, InCol, InRect: boolean;
  ExcludeCell: TCell;
begin
  ExcludeCell := Grid.Data[Col, Row];
  with ExcludeCell do
    begin
      InRow  := aValue in RowValues(ExcludeCell);
      if InRow then
        begin
          ErrMsg := Format('%d already exists in row %d', [aValue, Row]);
          result := false;
          exit;
        end;
      InCol  := aValue in ColValues(ExcludeCell);
      if InCol then
        begin
          ErrMsg := Format('%d already exists in col %d', [aValue, Col]);
          result := false;
          exit;
        end;
      InRect := aValue in RectValues(ExcludeCell);
      if InRect then
        begin
          ErrMsg := Format('%d already exists in subrect', [aValue]);
          result := false;
          exit;
        end;
      result := true;
    end;
end;

procedure TfrmSudoko.StringGrid1SetEditText(Sender: TObject; ACol,
  ARow: Integer; const cValue: String);
var
  Value: integer;
  ErrMsg: string;
begin
  if cValue <> '' then
    try
      Value := StrToInt(cValue);
      if (Value >= MINVAL) and (Value <= MAXVAL) then
        begin
          if IsAPossibleValue(Value, aCol+1, aRow+1, ErrMsg) then
            begin
              Grid.Data[aCol+1, aRow+1].Value := Value;
              lblStatus.Caption := '';
            end
          else
            begin
              lblStatus.Caption := ErrMsg;
              Beep;
            end;
        end;
    except
      on e:Exception do
        begin
          lblStatus.Caption := e.Message;
          Beep;
        end;
    end
  else
    Grid.Data[aCol+1, aRow+1].Value := 0;
end;

procedure TfrmSudoko.FormCreate(Sender: TObject);
begin
  lblStatus.Caption := '';
end;

{ TCell }

constructor TCell.Create(aGrid: TGrid; aCol, aRow: TRowColNum);
begin
  fGrid := aGrid;
  Col   := aCol;
  Row   := aRow;
end;

function TCell.ColValues(ExcludeCell: TCell): TValueSet;
  var
    aRow: TRowColNum;
begin
  result := [];
  for aRow := MINVAL to MAXVAL do
    if fGrid.Data[Col, aRow] <> ExcludeCell then
      with fGrid.Data[Col, aRow] do
        if Value in [MINVAL..MAXVAL] then
          result := result + [Value];
end;

function TCell.RectValues(ExcludeCell: TCell): TValueSet;
  var
    aMinCol, aMaxCol, aMinRow, aMaxRow, aCol, aRow: TRowColNum;

  function f(n: TRowColNum): TRowColNum;
    var
      Grp: integer;
  begin
    Grp    := (n-1) div SUBRECSIZE;
    result := (Grp * SUBRECSIZE) + 1;
  end;

begin { TCell.RectValues }
  aMinCol := f(Col);
  aMaxCol := aMinCol + SUBRECSIZE - 1;
  aMinRow := f(Row);
  aMaxRow := aMinRow + SUBRECSIZE - 1;

  result  := [];
  for aRow := aMinRow to aMaxRow do
    for aCol := aMinCol to aMaxCol do
      if fGrid.Data[aCol, aRow] <> ExcludeCell then
        with fGrid.Data[aCol, aRow] do
          if Value in [MINVAL..MAXVAL] then
            result := result + [Value];
end;  { TCell.RectValues }

function TCell.RowValues(ExcludeCell: TCell): TValueSet;
  var
    aCol: TRowColNum;
begin
  result := [];
  for aCol := MINVAL to MAXVAL do
    if fGrid.Data[aCol, Row] <> ExcludeCell then
      with fGrid.Data[aCol, Row] do
        if Value in [MINVAL..MAXVAL] then
          result := result + [Value];
end;

function TCell.GetValue: TRowColNumE;
begin
  result := fValue;
end;

procedure TCell.SetValue(const Value: TRowColNumE);
begin
  fValue := Value;
  fGrid.Changed := true;
end;

function TCell.GetPossibleValues: TValueSet;
  var
    val: TRowColNum;
begin
  result := [];
  if Value <> 0 then
    result := [Value]
  else
    for Val := MINVAL to MAXVAL do
      if IsAPossibleValue(Val) then
        result := result + [Val];
end;

function TCell.IsAPossibleValue(aValue: TRowColNum): boolean;
var
  ExcludeCell: TCell;
begin
  ExcludeCell := fGrid.Data[Col, Row];
  
  if aValue in ExcludeCell.fImpossibleValues then
    result := false
  else
    begin
      result := (not (aValue in RowValues(ExcludeCell))) and
                (not (aValue in ColValues(ExcludeCell))) and
                (not (aValue in RectValues(ExcludeCell)));
    end;
end;

function TCell.BitCount: byte;
  var
    bn: byte;
    pv: TValueSet;
begin
  result := 0;
  pv     := PossibleValues;
  for bn := MINVAL to MAXVAL do
    if bn in pv then
      inc(result);
end;

destructor TCell.Destroy;
begin
  inherited;
end;

procedure TCell.Assign(aCell: TCell);
begin
  fImpossibleValues := aCell.fImpossibleValues;
  fValue            := aCell.Value;
  Col               := aCell.Col;
  Row               := aCell.Row;
end;

{ TGrid }

function TGrid.GetData(Col, Row: TRowColNum): TCell;
begin
  if not Assigned(fData[Col, Row]) then
    fData[Col, Row] := TCell.Create(Self, Col, Row);
  result := fData[Col, Row];
end;

function TfrmSudoko.GetGrid: TGrid;
begin
  if not Assigned(fGrid) then
    fGrid := TGrid.Create(nil);
  result := fGrid;
end;

function TGrid.LoadData(const FileName: string): boolean;
  var
    aRow, aCol: integer;
    temp: integer;
    InFile: Text;
begin
  result := false;
  if FileExists(FileName) then
    begin
      AssignFile(InFile, FileName);
      Reset(InFile);
      try
        for aRow := MINVAL to MAXVAL do
          begin
            for aCol := MINVAL to MAXVAL do
              begin
                Read(InFile, temp);
                Data[aCol, aRow].Value := Temp;
              end;
            ReadLn(InFile);
          end;
        result := true;
      finally
        CloseFile(InFile);
      end;
    end;
  Changed := false;
end;

function TGrid.SaveData(const FileName: string): boolean;
  var
    aRow, aCol: integer;
    OutFile: Text;
begin
  try
    AssignFile(OutFile, FileName);
    ReWrite(OutFile);
    try
      for aRow := MINVAL to MAXVAL do
        begin
          for aCol := MINVAL to MAXVAL do
            write(OutFile, fData[aCol, aRow].Value:3);
          writeln(OutFile);
        end;
      result := true;
    finally
      CloseFile(OutFile);
    end;
  except
    result := false;
  end;
end;

function TfrmSudoko.SaveFileName: string;
begin
  if fSaveFileName = '' then
    fSaveFileName := ExtractFilePath(ParamStr(0)) + 'SUDOKU.TXT';
  result := fSaveFileName;
end;

destructor TfrmSudoko.Destroy;
begin
  FreeAndNil(fGrid);
  inherited;
end;

constructor TfrmSudoko.Create(aOwner: TComponent);
begin
  inherited;
  if Grid.LoadData(SaveFileName) then
    begin
      fIsSolved := false;
      OvcTable1.Invalidate
    end;
end;

procedure TfrmSudoko.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if Grid.Changed then
    if Yes('Save current data? ') then
      Grid.SaveData(SaveFileName);
  CanClose := true;
end;

procedure TGrid.ClearData;
  var
    aRow, aCol: integer;
begin
  for aRow := MINVAL to MAXVAL do
    for aCol := MINVAL to MAXVAL do
      begin
        Data[aCol, aRow].Value := 0;
      end;
  Changed := false;
end;

procedure TfrmSudoko.btnClearClick(Sender: TObject);
begin
  fIsSolved := false;
  ClearData;
end;

procedure TfrmSudoko.OvcTable1GetCellAttributes(Sender: TObject; RowNum,
  ColNum: Integer; var CellAttr: TOvcCellAttributes);
var
  BitCount: byte;
begin
  if fIsSolved then
    CellAttr.caColor := clAqua else
  if Grid.Data[ColNum+1, RowNum+1].Value > 0 then
    CellAttr.caColor := clWhite
  else
    begin
      BitCount := Grid.Data[ColNum+1, RowNum+1].BitCount;
      case BitCount of
        0: CellAttr.caColor := clRed;
        1: CellAttr.caColor := clGreen;
        2: CellAttr.caColor := clYellow;
        else
          CellAttr.caColor := clFuchsia;
      end;
    end;
end;

procedure TfrmSudoko.OvcTable1GetCellData(Sender: TObject; RowNum,
  ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
var
  aRow, aCol: integer;
begin
  aRow := RowNum + 1;
  aCol := ColNum + 1;
  case Purpose of
    cdpForPaint,
    cdpForEdit,
    cdpForSave:
      if Grid.Data[aCol, aRow].Value <> 0 then
        begin
          fCellData := IntToStr(Grid.Data[aCol, aRow].Value);
          Data      := @fCellData;
        end
      else
        begin
          fCellData := '';
          Data      := @fCellData;
        end;
  end;
end;

procedure TfrmSudoko.OvcTable1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  aRowNum, aColNum: integer;
  PossibleValues: TValueSet;
  Val: TRowColNum;
  Temp: string;
  TblRegion: TOvcTblRegion;
begin
  if not fIsSolved then
    begin
      TblRegion := OvcTable1.CalcRowColFromXY(X, Y, aRowNum, aColNum);
      if TblRegion = otrInMain then
        begin
          PossibleValues := Grid.Data[aColNum+1, aRowNum+1].PossibleValues;

          Temp := '';
          for Val := MINVAL to MAXVAL do
            if Val in PossibleValues then
              Temp := Temp + ' ' + IntToStr(Val);
          lblStatus.Caption := Temp;
        end;
    end;
end;

procedure TfrmSudoko.OvcTable1DoneEdit(Sender: TObject; RowNum, ColNum: Integer);
  var
    Temp: string;
    aCol, aRow: integer;
    Value: integer;
    ErrMsg: string;
begin
  aCol     := ColNum+1;
  aRow     := RowNum+1;

  Temp     := fCellData;
  if Temp <> '' then
    try
      Value := StrToInt(Temp);
      if IsAPossibleValue(Value, aCol, aRow, ErrMsg) then
        begin
          Grid.Data[aCol, aRow].Value := Value;
          fIsSolved := Grid.Solved;
          if fIsSolved then
            begin
              lblStatus.Caption := 'SOLVED!';
              lblStatus.Color   := clLime;
            end;
        end
      else
        Error(ErrMsg);
      OvcTable1.Invalidate;
    except
      // if we can't convert it, ignore it.
    end
  else
    begin
      Grid.Data[aCol, aRow].Value := 0;
      OvcTable1.Invalidate;
    end;
end;

procedure TfrmSudoko.OvcTCSimpleField1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  OvcTable1MouseMove(nil, Shift, X, y);
end;

procedure TfrmSudoko.OvcTCSimpleField1Change(Sender: TObject);
begin
  fCellData := (Sender as TOvcSimpleField).AsString;
  with OvcTable1 do
    OvcTable1DoneEdit(Sender, ActiveRow, ActiveCol);
end;

procedure TfrmSudoko.btnRevertClick(Sender: TObject);
begin
  if Grid.LoadData(SaveFileName) then
    OvcTable1.Invalidate
end;

procedure TfrmSudoko.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmSudoko.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmSudoko.actRevertExecute(Sender: TObject);
begin
  if Grid.LoadData(SaveFileName) then
    OvcTable1.Invalidate
end;

procedure TfrmSudoko.actSaveExecute(Sender: TObject);
begin
  if Grid.SaveData(SaveFileName) then
    MessageFmt('Saved to file %s', [SaveFileName]);
end;

procedure TfrmSudoko.actClearExecute(Sender: TObject);
begin
  fIsSolved := false;
  ClearData;
end;

procedure TfrmSudoko.actPrintExecute(Sender: TObject);
begin
  Print;
end;

procedure TfrmSudoko.actSaveAsExecute(Sender: TObject);
  var
    Ok: boolean;
begin
  with SaveDialog1 do
    begin
      FileName := ExtractFileName(SaveFileName);
      InitialDir := ExtractFilePath(SaveFileName);
      if Execute then
        begin
          if FileExists(FileName) then
            Ok := YesFmt('File "%s" already exists. Overwrite it?', [FileName])
          else
            Ok := true;

          if Ok then
            if Grid.SaveData(FileName) then
              MessageFmt('Saved to file "%s"', [FileName])
            else
              AlertFmt('Unable to save to file "%s"', [FileName]);
        end;
    end;
end;

procedure TfrmSudoko.ClearData;
begin
  fIsSolved := false;
  Grid.ClearData;
  OvcTable1.Invalidate;
end;

procedure TfrmSudoko.actSolveItExecute(Sender: TObject);
begin
  if fGrid.SolveIt(1) then
    OvcTable1.Invalidate;
end;

function TGrid.SolveIt(Level: integer): boolean;
var
  aSquare: TSquare;
  Value: TRowColNum;
  TempGrid: TGrid;
begin
  while not (Solved or Impossible) do
    begin
      // Create a new temporary grid which copies the current grid
      TempGrid := TGrid.Create(self);
      try
        if TempGrid.EmptySquares.Count > 0 then
          begin
            // Sort the list of EmptySquares in ascending order
            // of the number of possibilities
            TempGrid.EmptySquares.Sort;   // Can't get here if 'Impossible' was set

            // try the first square in the list
            aSquare := TempGrid.EmptySquares.Item[0];

            // try each of the possibilities for that square
            with aSquare do
              begin
                while BitCount(Possibilities) > 0 do
                  begin
                    Value := TheFirstPossibility(Possibilities);
                    TempGrid.Data[Col, Row].Value := Value;

                    if TempGrid.SolveIt(Level+1) then
                      begin
                        // Copy the values from the TempGrid and exit
                        Assign(TempGrid);
                        result := true;
                        Exit;
                      end
                    else // if that didn't solve it, try the next possibility for that square
                      begin
                        Exclude(Possibilities, Value);

                        // and exclude that value from further consideration
                        Include(TempGrid.Data[Col, Row].fImpossibleValues, Value);
                      end
                  end;
              end;
          end;

        result := TempGrid.Solved;
        Exit;
      finally
        FreeAndNil(TempGrid);
      end;
    end;
  result := Solved;
end;

function TGrid.Impossible: boolean;
var
  aRow, aCol: TRowColNum;
begin
  result := EmptySquares.Count = 0;
  if not result then
    for aRow := MINVAL to MAXVAL do
      for aCol := MINVAL to MAXVAL do
        if fData[aCol, aRow].BitCount = 0 then // at least one square with no possibilities
          begin
            result := true;
            exit;
          end;
end;

function TGrid.Solved: boolean;
  var
    aRow, aCol: TRowColNum;
begin
  result := true;
  for aRow := MINVAL to MAXVAL do
    for aCol := MINVAL to MAXVAL do
      if fData[aCol, aRow].Value = 0 then
        begin
          result := false;
          exit;
        end;
end;

// return a list of squares which haven't been assigned yet
function TGrid.EmptySquares: TSquaresList;
  var
    aRow, aCol: TRowColNum;
begin
  if not Assigned(fEmptySquares) then
    begin
      fEmptySquares := TSquaresList.Create;
      for aRow := MINVAL to MAXVAL do
        for aCol := MINVAL to MAXVAL do
          if fData[aCol, aRow].Value = 0 then
            fEmptySquares.Add(aCol, aRow, fData[aCol, aRow].PossibleValues);
    end;
  result := fEmptySquares;
end;

destructor TGrid.Destroy;
var
  aCol, aRow: TRowColNum;
begin
  for aRow := MINVAL to MAXVAL do
    for aCol := MINVAL to MAXVAL do
      fData[aCol, aRow].Free;
  FreeAndNil(fEmptySquares);
  inherited;
end;

constructor TGrid.Create(aOwner: TGrid);
begin
  if Assigned(aOwner) then
    Assign(aOwner);
end;

procedure TGrid.Assign(aGrid: TGrid);
  var
    aRow, aCol: TRowColNum;
begin
  for aRow := MINVAL to MAXVAL do
    for aCol := MINVAL to MAXVAL do
      begin
        if not Assigned(fData[aCol, aRow]) then
          fData[aCol, aRow] := TCell.Create(self, aCol, aRow);
        fData[aCol, aRow].Assign(aGrid.fData[aCol, aRow]);
      end;
end;

procedure TGrid.SetChanged(const Value: boolean);
begin
  fChanged := Value;
end;

{ TSquaresList }

procedure TSquaresList.Add(aCol, aRow: byte; aPossibilities: TValueSet);
begin
  Count := Count + 1;
  with Item[pred(Count)] do
    begin
      Row := aRow;
      Col := aCol;
      Possibilities := aPossibilities;
    end;
end;

constructor TSquaresList.Create;
begin
end;

function TSquaresList.GetCount: integer;
begin
  result := Length(Item);
end;

procedure TSquaresList.SetCount(const Value: integer);
begin
  SetLength(Item, Value);
end;

procedure TSquaresList.Sort;
var
  i, j: integer;
  TempSquare: TSquare;
begin
  for i := 0 to Pred(Pred(Count)) do
    for j := Succ(i) to Pred(Count) do
      begin
        if BitCount(Item[i].Possibilities) > BitCount(Item[j].Possibilities) then
          begin
            TempSquare   := Item[i];
            Item[i]      := Item[j];
            Item[j]      := TempSquare;
          end;
      end;
end;

// Draw the "tic-tac-toe" grid
procedure TfrmSudoko.OvcTable1PaintUnusedArea(Sender: TObject);
  var
    x1, x2, y1, y2: integer;
begin
  with OvcTable1 do
    begin
      Canvas.Brush.Style := bsSolid;
      Canvas.Pen.Width   := 3;
      Canvas.Pen.Color   := clBlack;

      x1 := ClientWidth div 3;
      x2 := x1 * 2;

      y1 := ClientHeight div 3;
      y2 := y1 * 2;

      Canvas.MoveTo(x1, 0);
      Canvas.LineTo(x1, ClientHeight);

      Canvas.MoveTo(x2, 0);
      Canvas.LineTo(x2, ClientHeight);

      Canvas.MoveTo(0, y1);
      Canvas.LineTo(ClientWidth, y1);

      Canvas.MoveTo(0, y2);
      Canvas.LineTo(ClientWidth, y2);
    end;
end;

procedure TfrmSudoko.AddHist(Hist: THistRec);
var
  Len: integer;
begin
  Len := Length(fHistory);
  SetLength(fHistory, Len+1);
  with fHistory[Len] do
    begin
      LastCol := Hist.LastCol;
      LastRow := Hist.LastRow;
      LastVal := Hist.LastVal;
    end;
end;


procedure TfrmSudoko.OvcTable1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TblRegion: TOvcTblRegion;
  Hist: THistRec;
  iLastRow, iLastCol: integer;
begin
  with Hist do
    begin
      TblRegion  := OvcTable1.CalcRowColFromXY(X, Y, iLastRow, iLastCol);
      if TblRegion = otrInMain then
        begin
          LastRow    := iLastRow;
          LastCol    := iLastCol;
          LastVal    := Grid.Data[LastCol+1, LastRow+1].Value;
          AddHist(Hist);
        end;
    end;
end;


procedure TfrmSudoko.Undo2Click(Sender: TObject);
var
  Len: integer;
begin
  Len := Length(fHistory);
  if Len > 0 then
    begin
      with fHistory[Len-1] do
        Grid.Data[LastCol+1, LastRow+1].Value := LastVal;
      SetLength(fHistory, Len-1);
      OvcTable1.Invalidate;
    end;
end;

end.
