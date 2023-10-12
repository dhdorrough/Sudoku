object frmSudoko: TfrmSudoko
  Left = 1398
  Top = 183
  BorderStyle = bsSingle
  Caption = 'Sudoku Assistant'
  ClientHeight = 333
  ClientWidth = 352
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    352
    333)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 11
    Top = 308
    Width = 40
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblStatus'
    Color = clBtnFace
    ParentColor = False
  end
  object lblStatus1: TLabel
    Left = 266
    Top = 297
    Width = 70
    Height = 14
    Alignment = taRightJustify
    Anchors = [akLeft, akTop, akRight, akBottom]
    BiDiMode = bdLeftToRight
    Caption = 'lblStatus1'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
  end
  object lblStatus2: TLabel
    Left = 267
    Top = 311
    Width = 70
    Height = 14
    Alignment = taRightJustify
    Anchors = [akLeft, akTop, akRight, akBottom]
    BiDiMode = bdLeftToRight
    Caption = 'lblStatus2'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentBiDiMode = False
    ParentFont = False
  end
  object OvcTable1: TOvcTable
    Left = 16
    Top = 16
    Width = 321
    Height = 275
    LockedRows = 0
    TopRow = 0
    ActiveRow = 0
    RowLimit = 9
    LockedCols = 0
    LeftCol = 0
    ActiveCol = 0
    ColorUnused = clBtnFace
    Colors.Editing = clInfoBk
    GridPenSet.NormalGrid.NormalColor = clBtnShadow
    GridPenSet.NormalGrid.Style = psDot
    GridPenSet.NormalGrid.Effect = geBoth
    GridPenSet.LockedGrid.NormalColor = clBtnShadow
    GridPenSet.LockedGrid.Style = psSolid
    GridPenSet.LockedGrid.Effect = ge3D
    GridPenSet.CellWhenFocused.NormalColor = clBlack
    GridPenSet.CellWhenFocused.Style = psSolid
    GridPenSet.CellWhenFocused.Effect = geBoth
    GridPenSet.CellWhenUnfocused.NormalColor = clBlack
    GridPenSet.CellWhenUnfocused.Style = psDash
    GridPenSet.CellWhenUnfocused.Effect = geBoth
    Options = [otoNoRowResizing, otoNoColResizing, otoTabToArrow, otoAlwaysEditing, otoNoSelection]
    ScrollBars = ssNone
    TabOrder = 0
    OnDoneEdit = OvcTable1DoneEdit
    OnGetCellData = OvcTable1GetCellData
    OnGetCellAttributes = OvcTable1GetCellAttributes
    OnMouseDown = OvcTable1MouseDown
    OnMouseMove = OvcTable1MouseMove
    OnPaintUnusedArea = OvcTable1PaintUnusedArea
    CellData = (
      'frmSudoko.OvcTCSimpleField1')
    RowData = (
      30)
    ColData = (
      35
      False
      True
      'frmSudoko.OvcTCSimpleField1'
      35
      False
      True
      'frmSudoko.OvcTCSimpleField1'
      35
      False
      True
      'frmSudoko.OvcTCSimpleField1'
      35
      False
      True
      'frmSudoko.OvcTCSimpleField1'
      35
      False
      True
      'frmSudoko.OvcTCSimpleField1'
      35
      False
      True
      'frmSudoko.OvcTCSimpleField1'
      35
      False
      True
      'frmSudoko.OvcTCSimpleField1'
      35
      False
      True
      'frmSudoko.OvcTCSimpleField1'
      35
      False
      True
      'frmSudoko.OvcTCSimpleField1')
  end
  object OvcTCSimpleField1: TOvcTCSimpleField
    Adjust = otaCenter
    CaretOvr.Shape = csBlock
    Color = clGradientActiveCaption
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    MaxLength = 1
    PictureMask = '9'
    Table = OvcTable1
    TableColor = False
    OnChange = OvcTCSimpleField1Change
    OnMouseMove = OvcTCSimpleField1MouseMove
    Left = 320
    RangeHigh = {00000000000000000000}
    RangeLow = {00000000000000000000}
  end
  object MainMenu1: TMainMenu
    AutoHotkeys = maManual
    AutoLineReduction = maManual
    Left = 80
    Top = 8
    object File1: TMenuItem
      AutoHotkeys = maAutomatic
      AutoLineReduction = maManual
      Caption = '&File'
      object Save1: TMenuItem
        Action = actSave
      end
      object SaveAs1: TMenuItem
        Action = actSaveAs
      end
      object Revert1: TMenuItem
        Action = actRevert
      end
      object Clear1: TMenuItem
        Action = actClear
      end
      object SolveIt1: TMenuItem
        Action = actSolveIt
      end
      object Print1: TMenuItem
        Action = actPrint
      end
      object Exit1: TMenuItem
        Action = actExit
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      OnClick = Edit1Click
      object Undo2: TMenuItem
        Caption = 'Undo'
        ShortCut = 16474
        OnClick = Undo2Click
      end
    end
    object Help1: TMenuItem
      Caption = 'Help'
      object RedNoCSolution1: TMenuItem
        Caption = 'Red = No Solution'
      end
      object Green1PossibleNUmber1: TMenuItem
        Caption = 'Green = 1 Possible Number'
      end
      object Yellow2PossibleNumbers1: TMenuItem
        Caption = 'Yellow = 2 Possible Numbers'
      end
      object Fuschiamorethan2possiblenumbers1: TMenuItem
        Caption = 'Fuschia = more than 2 possible numbers'
      end
    end
  end
  object ActionList1: TActionList
    Left = 48
    Top = 8
    object actExit: TAction
      Caption = 'E&xit'
      OnExecute = actExitExecute
    end
    object actRevert: TAction
      Caption = '&Revert'
      OnExecute = actRevertExecute
    end
    object actClear: TAction
      Caption = '&Clear'
      OnExecute = actClearExecute
    end
    object actSave: TAction
      Caption = '&Save'
      OnExecute = actSaveExecute
    end
    object actPrint: TAction
      Caption = '&Print'
      OnExecute = actPrintExecute
    end
    object actSaveAs: TAction
      Caption = 'Save &As'
      OnExecute = actSaveAsExecute
    end
    object actSolveIt: TAction
      Caption = 'Solve it'
      OnExecute = actSolveItExecute
    end
  end
  object SaveDialog1: TSaveDialog
    FileName = 'Sudoku.txt'
    Filter = 'Sudoku Text Save (*.txt)|*.txt'
    Left = 113
    Top = 9
  end
end
