{
   Double Commander
   -------------------------------------------------------------------------
   Build-in File Viewer.

   Copyright (C) 2007-2025  Alexander Koblov (alexx2000@mail.ru)

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see <http://www.gnu.org/licenses/>.

   Legacy comment from its origin:
   -------------------------------------------------------------------------
   Seksi Commander
   Integrated viewer form
   Licence  : GNU GPL v 2.0
   Author   : radek.cervinka@centrum.cz

   contributors:

   Radek Polak
    ported to lazarus:
    changes:
     23.7.
        - fixed: scroll bar had wrong max value until user pressed key (by Radek Polak)
        - fixed: wrong scrolling with scroll bar - now look at ScrollBarVertScroll (by Radek Polak)

   Dmitry Kolomiets
   15.03.08
   changes:
     - Added WLX api support (TC WLX api v 1.8)

   Rustem Rakhimov
   25.04.10
   changes:
     - fullscreen
     - function for edit image
     - slide show
     - some Viwer function

}

unit fViewer;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls, ComCtrls, LMessages,
  LCLProc, Menus, Dialogs, ExtDlgs, StdCtrls, Buttons, SynEditHighlighter,
  Grids, ActnList, viewercontrol, uGifViewer, fFindView, WLXPlugin, uWLXModule,
  uFileSource, fModView, Types, uThumbnails, uFormCommands, uOSForms,Clipbrd,
  uExifReader, KASStatusBar, SynEdit, uShowForm, uRegExpr, uRegExprU,
  Messages, fEditSearch, uMasks, uSearchTemplate, uFileSourceOperation,
  uFileSourceCalcStatisticsOperation, KASComCtrls, LCLVersion;

type

  TEncodingMenu = (emViewer, emPlugin, emEditor);

  TViewerCopyMoveAction=(vcmaCopy,vcmaMove);

  { TDrawGrid }

  TDrawGrid = class(Grids.TDrawGrid)
  private
    FMutex: Integer;
    FFileList: TStringList;
  private
    function GetIndex: Integer;
    procedure SetIndex(AValue: Integer);
  protected
    procedure CalculateColRowCount;
    function MouseOnGrid(X, Y: LongInt): Boolean;
    function  CellToIndex(ACol, ARow: Integer): Integer;
    procedure IndexToCell(Index: Integer; out ACol, ARow: Integer);
  protected
    procedure MoveSelection; override;
    procedure DoAutoAdjustLayout(const AMode: TLayoutAdjustmentPolicy;
                const AXProportion, AYProportion: Double); override;
    procedure KeyDown(var Key : Word; Shift : TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y: Integer); override;
  public
    procedure DrawCell(aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState); override;
    property Index: Integer read GetIndex write SetIndex;
    property FileList: TStringList write FFileList;
  end;

  { TfrmViewer }

  TfrmViewer = class(TAloneForm, IFormCommands)
    actAbout: TAction;
    actCopyFile: TAction;
    actDeleteFile: TAction;
    actCopyToClipboard: TAction;
    actImageCenter: TAction;
    actFullscreen: TAction;
    actCopyToClipboardFormatted: TAction;
    actChangeEncoding: TAction;
    actAutoReload: TAction;
    actShowCode: TAction;
    actUndo: TAction;
    actShowTransparency: TAction;
    actWrapText: TAction;
    actShowCaret: TAction;
    actPrint: TAction;
    actPrintSetup: TAction;
    actShowAsDec: TAction;
    actScreenShotDelay5sec: TAction;
    actScreenShotDelay3Sec: TAction;
    actScreenshot: TAction;
    actZoomOut: TAction;
    actZoomIn: TAction;
    actZoom: TAction;
    actStretchOnlyLarge: TAction;
    actFindNext: TAction;
    actShowGraphics: TAction;
    actExitViewer: TAction;
    actMirrorVert: TAction;
    actSave: TAction;
    actShowOffice: TAction;
    actShowPlugins: TAction;
    actShowAsBook: TAction;
    actShowAsWrapText: TAction;
    actShowAsHex: TAction;
    actShowAsBin: TAction;
    actShowAsText: TAction;
    actPreview: TAction;
    actGotoLine: TAction;
    actFindPrev: TAction;
    actFind: TAction;
    actSelectAll: TAction;
    actMirrorHorz: TAction;
    actRotate270: TAction;
    actRotate180: TAction;
    actRotate90: TAction;
    actSaveAs: TAction;
    actStretchImage: TAction;
    actMoveFile: TAction;
    actLoadPrevFile: TAction;
    actLoadNextFile: TAction;
    actReload: TAction;
    actionList: TActionList;
    btnCopyFile1: TSpeedButton;
    btnDeleteFile1: TSpeedButton;
    btnMoveFile1: TSpeedButton;
    btnNext1: TSpeedButton;
    btnPenColor: TToolButtonClr;
    btnPrev1: TSpeedButton;
    btnReload1: TSpeedButton;
    DrawPreview: TDrawGrid;
    GifAnim: TGIFView;
    memFolder: TMemo;
    mnuPlugins: TMenuItem;
    miCode: TMenuItem;
    miShowTransparency: TMenuItem;
    miWrapText: TMenuItem;
    miPen: TMenuItem;
    miRect: TMenuItem;
    miEllipse: TMenuItem;
    miShowCaret: TMenuItem;
    miPrintSetup: TMenuItem;
    miAutoReload: TMenuItem;
    pmiCopyFormatted: TMenuItem;
    miDec: TMenuItem;
    MenuItem2: TMenuItem;
    miScreenshot5sec: TMenuItem;
    miScreenshot3sec: TMenuItem;
    miScreenshotImmediately: TMenuItem;
    miReload: TMenuItem;
    miLookBook: TMenuItem;
    miDiv4: TMenuItem;
    miPreview: TMenuItem;
    miScreenshot: TMenuItem;
    miFullScreen: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    Image: TImage;
    miZoomOut: TMenuItem;
    miZoomIn: TMenuItem;
    miRotate: TMenuItem;
    miMirror: TMenuItem;
    mi270: TMenuItem;
    mi180: TMenuItem;
    mi90: TMenuItem;
    miGotoLine: TMenuItem;
    miSearchPrev: TMenuItem;
    miPrint: TMenuItem;
    miSearchNext: TMenuItem;
    pnlFolder: TPanel;
    pnlPreview: TPanel;
    pnlEditFile: TPanel;
    pmiSelectAll: TMenuItem;
    miDiv5: TMenuItem;
    pmiCopy: TMenuItem;
    pnlImage: TPanel;
    pnlText: TPanel;
    pnlCode: TPanel;
    pmStatusBar: TPopupMenu;
    SynEdit: TSynEdit;
    miDiv3: TMenuItem;
    miOffice: TMenuItem;
    miEncoding: TMenuItem;
    miPlugins: TMenuItem;
    miSeparator: TMenuItem;
    pmEditMenu: TPopupMenu;
    pmPenTools: TPopupMenu;
    pmPenWidth: TPopupMenu;
    pmTimeShow: TPopupMenu;
    SavePictureDialog: TSavePictureDialog;
    sboxImage: TScrollBox;
    Splitter: TSplitter;
    Status: TKASStatusBar;
    MainMenu: TMainMenu;
    miFile: TMenuItem;
    miPrev: TMenuItem;
    miNext: TMenuItem;
    miView: TMenuItem;
    miExit: TMenuItem;
    miImage: TMenuItem;
    miStretch: TMenuItem;
    miStretchOnlyLarge: TMenuItem;
    miCenter: TMenuItem;
    miText: TMenuItem;
    miBin: TMenuItem;
    miHex: TMenuItem;
    miAbout: TMenuItem;
    miAbout2: TMenuItem;
    miDiv1: TMenuItem;
    miSearch: TMenuItem;
    miDiv2: TMenuItem;
    miGraphics: TMenuItem;
    miEdit: TMenuItem;
    miSelectAll: TMenuItem;
    miCopyToClipboard: TMenuItem;
    TimerReload: TTimer;
    TimerScreenshot: TTimer;
    TimerViewer: TTimer;
    tmUpdateFolderSize: TTimer;
    ToolBar1: TToolBarAdv;
    btnReload: TToolButton;
    btn270: TToolButton;
    btn90: TToolButton;
    btnMirror: TToolButton;
    btnCutTuImage: TToolButton;
    btnRedEye: TToolButton;
    btnPaintSeparator: TToolButton;
    btnUndo: TToolButton;
    btnPenMode: TToolButton;
    btnGifSeparator: TToolButton;
    btnGifMove: TToolButton;
    btnPrevGifFrame: TToolButton;
    btnNextGifFrame: TToolButton;
    btnGifToBmp: TToolButton;
    btnPenWidth: TToolButton;
    btnPrev: TToolButton;
    btnNext: TToolButton;
    btnCopyFile: TToolButton;
    btnMoveFile: TToolButton;
    btnDeleteFile: TToolButton;
    btnSeparator: TToolButton;
    btnSlideShow: TToolButton;
    btnFullScreen: TToolButton;
    btnResize: TToolButton;
    btnPaint: TToolButton;
    btnZoomSeparator: TToolButton;
    btnZoomIn: TToolButton;
    btnZoomOut: TToolButton;
    btnHightlightSeparator: TToolButton;
    btnHightlight: TToolButton;
    ViewerControl: TViewerControl;
    procedure actExecute(Sender: TObject);
    procedure btnCutTuImageClick(Sender: TObject);
    procedure btnFullScreenClick(Sender: TObject);
    procedure btnGifMoveClick(Sender: TObject);
    procedure btnGifToBmpClick(Sender: TObject);
    procedure btnPaintHightlight(Sender: TObject);
    procedure btnPenModeClick(Sender: TObject);
    procedure btnPrevGifFrameClick(Sender: TObject);
    procedure btnRedEyeClick(Sender: TObject);
    procedure btnResizeClick(Sender: TObject);
    procedure btnSlideShowClick(Sender: TObject);
    procedure DrawPreviewSelection(Sender: TObject; aCol, aRow: Integer);
    procedure DrawPreviewTopleftChanged(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender : TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GifAnimMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GifAnimMouseEnter(Sender: TObject);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseEnter(Sender: TObject);
    procedure ImageMouseLeave(Sender: TObject);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure ImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ImageMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure miPenClick(Sender: TObject);
    procedure miLookBookClick(Sender: TObject);
    procedure pmEditMenuPopup(Sender: TObject);
    procedure miPluginsClick(Sender: TObject);

    procedure sboxImageMouseEnter(Sender: TObject);
    procedure sboxImageMouseLeave(Sender: TObject);
    procedure sboxImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnNextGifFrameClick(Sender: TObject);
    procedure sboxImageResize(Sender: TObject);
    procedure SplitterChangeBounds;
    procedure TimerReloadTimer(Sender: TObject);
    procedure TimerScreenshotTimer(Sender: TObject);
    procedure TimerViewerTimer(Sender: TObject);
    procedure tmUpdateFolderSizeTimer(Sender: TObject);
    procedure FileSourceOperationStateChangedNotify(Operation: TFileSourceOperation;
                                                    State: TFileSourceOperationState);
    procedure ViewerControlMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure frmViewerClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure miPaintClick(Sender:TObject);
    procedure miChangeEncodingClick(Sender:TObject);
    procedure SynEditStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure SynEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SynEditMouseWheel(Sender: TObject; Shift: TShiftState;
         WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ViewerControlMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ViewerControlMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ViewerPositionChanged(Sender:TObject);
    function  PluginShowFlags : Integer;
    procedure UpdateImagePlacement;
    procedure StartCalcFolderSize;
    procedure StopCalcFolderSize;
    procedure UpdateAnimState;

  private
    FFileName: String;
    FileList: TStringList;
    iActiveFile,
    tmpX, tmpY,
    startX, startY, endX, endY,
    UndoSX, UndoSY, UndoEX, UndoEY,
    cas, i_timer:Integer;
    bAnimation,
    bImage,
    bPlugin,
    bQuickView,
    MDFlag,
    ImgEdit: Boolean;
    FThumbSize: TSize;
    FFindDialog:TfrmFindView;
    FWaitData: TWaitData;
    FLastSearchPos: PtrInt;
    FLastMatchLength: IntPtr;
    tmp_all: TCustomBitmap;
    FModSizeDialog: TfrmModView;
    FThumbnailManager: TThumbnailManager;
    FFileSourceCalcStatisticsOperation: TFileSourceCalcStatisticsOperation;
    FCommands: TFormCommands;
    FScaleFactor: Double;
    FZoomFactor: Integer;
    FExif: TExifReader;
    FWindowState: TWindowState;
    FElevate: TDuplicates;
{$IF DEFINED(LCLWIN32)}
    FWindowBounds: TRect;
{$ENDIF}
    FThread: TThread;
    FMode: Integer;

    FRegExp: TRegExprEx;
    FPluginEncoding: Integer;
    //---------------------
    FSynEditOriginalText: String;
{$if lcl_fullversion >= 4990000}
    FSynEditWrap: TLazSynEditPlugin;
{$endif}
    FSearchOptions: TEditSearchOptions;
    FHighlighter: TSynCustomHighlighter;
    //---------------------
    WlxPlugins: TWLXModuleList;
    FWlxModule: TWlxModule;
    ActivePlugin: Integer;
    //---------------------
    function GetListerRect: TRect;
    function CheckOffice(const sFileName: String): Boolean;
    function CheckSynEdit(const sFileName: String; bForce: Boolean = False): Boolean;
    function CheckPlugins(const sFileName: String; bForce: Boolean = False): Boolean;
    function CheckGraphics(const sFileName:String):Boolean;
    function LoadGraphics(const sFileName:String): Boolean;
    function LoadSynEdit(const sFileName: String): Boolean;
    function LoadPlugin(const sFileName: String; Index, ShowFlags: Integer): Boolean;
    procedure AdjustImageSize;
    procedure DoSearchCode(bQuickSearch: Boolean; bSearchBackwards: Boolean);
    procedure DoSearch(bQuickSearch: Boolean; bSearchBackwards: Boolean);
    procedure UpdateTextEncodingsMenu(AType: TEncodingMenu);
    procedure MakeTextEncodingsMenu;
    procedure ActivatePanel(Panel: TPanel);
    procedure ReopenAsTextIfNeeded;
    procedure UpdatePluginsMenu;
    procedure MakePluginsMenu;
    procedure CheckXY;
    procedure UndoTmp;
    procedure CreateTmp;
    procedure CutToImage;
    procedure Res(W, H: integer);
    procedure RedEyes;
    procedure SynEditCaret;
    procedure ExitPluginMode;
    procedure DeleteCurrentFile;
    procedure EnableCopy(AEnabled: Boolean);
    procedure EnablePrint(AEnabled: Boolean);
    procedure EnableSearch(AEnabled: Boolean);
    procedure EnableActions(AEnabled: Boolean);
    procedure SavingProperties(Sender: TObject);
    procedure SetFileName(const AValue: String);
    procedure SaveImageAs (Var sExt: String; senderSave: boolean; Quality: integer);
    procedure ImagePaintBackground(ASender: TObject; ACanvas: TCanvas; ARect: TRect);
    procedure CreatePreview(FullPathToFile:string; index:integer; delete: boolean = false);

    property Commands: TFormCommands read FCommands implements IFormCommands;
    property FileName: String write SetFileName;

  protected
    procedure WMCommand(var Message: TLMCommand); message LM_COMMAND;
    procedure WMSetFocus(var Message: TLMSetFocus); message LM_SETFOCUS;
    procedure CMThemeChanged(var Message: TLMessage); message CM_THEMECHANGED;

  public
    constructor Create(TheOwner: TComponent; aWaitData: TWaitData; aQuickView: Boolean = False); overload;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure LoadFile(iIndex: Integer);
    procedure LoadFile(const aFileName: String);
    procedure LoadNextFile(Index: Integer);
    procedure LoadNextFile(const aFileName: String);

    procedure ExitQuickView;

    procedure ShowTextViewer(AMode: TViewerControlMode);
    procedure CopyMoveFile(AViewerAction:TViewerCopyMoveAction);
    procedure ZoomImage(ADelta: Double);
    function DoZoom( const delta: Double; const inc: Integer ): Boolean;
    function DoZoomIn: Boolean;
    function DoZoomOut: Boolean;
    procedure RotateImage(AGradus:integer);
    procedure MirrorImage(AVertically:boolean=False);

  published
    // Commands for hotkey manager
    procedure cm_About(const Params: array of string);
    procedure cm_Reload(const Params: array of string);
    procedure cm_AutoReload(const Params: array of string);
    procedure cm_LoadNextFile(const Params: array of string);
    procedure cm_LoadPrevFile(const Params: array of string);
    procedure cm_MoveFile(const Params: array of string);
    procedure cm_CopyFile(const Params: array of string);
    procedure cm_DeleteFile(const Params: array of string);
    procedure cm_StretchImage(const Params: array of string);
    procedure cm_StretchOnlyLarge(const Params: array of string);
    procedure cm_ShowTransparency(const Params: array of string);
    procedure cm_Save(const Params:array of string);
    procedure cm_Undo(const Params: array of string);
    procedure cm_SaveAs(const Params: array of string);
    procedure cm_Rotate90(const Params: array of string);
    procedure cm_Rotate180(const Params: array of string);
    procedure cm_Rotate270(const Params: array of string);
    procedure cm_MirrorHorz(const Params: array of string);
    procedure cm_MirrorVert(const Params: array of string);
    procedure cm_ImageCenter(const Params: array of string);
    procedure cm_Zoom(const Params: array of string);
    procedure cm_ZoomIn(const Params: array of string);
    procedure cm_ZoomOut(const Params: array of string);
    procedure cm_Fullscreen(const Params: array of string);
    procedure cm_Screenshot(const Params: array of string);
    procedure cm_ScreenshotWithDelay(const Params: array of string);
    procedure cm_ScreenshotDelay3sec(const Params: array of string);
    procedure cm_ScreenshotDelay5sec(const Params: array of string);

    procedure cm_ChangeEncoding(const Params: array of string);
    procedure cm_CopyToClipboard (const Params: array of string);
    procedure cm_CopyToClipboardFormatted (const Params: array of string);
    procedure cm_SelectAll       (const Params: array of string);
    procedure cm_Find          (const Params: array of string);
    procedure cm_FindNext      (const Params: array of string);
    procedure cm_FindPrev      (const Params: array of string);
    procedure cm_GotoLine      (const Params: array of string);

    procedure cm_Preview         (const Params: array of string);
    procedure cm_ShowAsText      (const Params: array of string);
    procedure cm_ShowAsBin       (const Params: array of string);
    procedure cm_ShowAsHex       (const Params: array of string);
    procedure cm_ShowAsDec       (const Params: array of string);
    procedure cm_ShowAsWrapText  (const Params: array of string);
    procedure cm_ShowAsBook      (const Params: array of string);

    procedure cm_ShowGraphics    (const Params: array of string);
    procedure cm_ShowPlugins     (const Params: array of string);

    procedure cm_ShowOffice      (const Params: array of string);
    procedure cm_ShowCode        (const Params: array of string);

    procedure cm_ExitViewer      (const Params: array of string);

    procedure cm_Print(const Params:array of string);
    procedure cm_PrintSetup(const Params:array of string);
    procedure cm_ShowCaret(const Params: array of string);
    procedure cm_WrapText(const Params: array of string);
  end;

procedure ShowViewer(const FilesToView: TStringList; WaitData: TWaitData = nil); overload;
procedure ShowViewer(const FilesToView: TStringList; AMode: Integer; WaitData: TWaitData = nil); overload;

implementation

{$R *.lfm}

uses
  FileUtil, IntfGraphics, Math, uLng, uShowMsg, uGlobs, LCLType, LConvEncoding,
  DCClassesUtf8, uFindMmap, DCStrUtils, uDCUtils, LCLIntf, uDebug, uHotkeyManager,
  uConvEncoding, DCBasicTypes, DCOSUtils, uOSUtils, uFindByrMr, uFileViewWithGrid,
  fPrintSetup, uFindFiles, uAdministrator, uOfficeXML, uHighlighterProcs, dmHigh,
  SynEditTypes, uFile, uFileSystemFileSource, uFileProcs, uOperationsManager,
  uFileSourceOperationOptions
{$if lcl_fullversion >= 4990000}
  , SynEditWrappedView
{$endif}
{$IFDEF LCLGTK2}
  , uGraphics
{$ENDIF}
  ;

const
  HotkeysCategory = 'Viewer';

  // Status bar panels indexes.
  sbpFileName             = 4;
  sbpFileNr               = 0;
  // Text
  sbpPosition             = 1;
  sbpFileSize             = 2;
  sbpTextEncoding         = 3;
  // WLX
  sbpPluginName           = 1;
  // Graphics
  sbpCurrentResolution    = 1;
  sbpFullResolution       = 2;
  sbpImageSelection       = 3;

const
  WRAP_MODE: array[Boolean] of TViewerControlMode = (vcmText, vcmWrap);

type

  { TThumbThread }

  TThumbThread = class(TThread)
  private
    FOwner: TfrmViewer;
    procedure ClearList;
    procedure DoOnTerminate(Sender: TObject);
  protected
    procedure Execute; override;
  public
    constructor Create(Owner: TfrmViewer);
    class procedure Finish(var Thread: TThread);
  end;

procedure ShowViewer(const FilesToView: TStringList; WaitData: TWaitData);
begin
  ShowViewer(FilesToView, 0, WaitData);
end;

procedure ShowViewer(const FilesToView: TStringList; AMode: Integer;
  WaitData: TWaitData);
var
  Viewer: TfrmViewer;
begin
  //DCDebug('ShowViewer - Using Internal');
  Viewer := TfrmViewer.Create(Application, WaitData);
  Viewer.FileList.Assign(FilesToView);// Make a copy of the list
  Viewer.DrawPreview.FileList:= Viewer.FileList;
  Viewer.actMoveFile.Enabled := FilesToView.Count > 1;
  Viewer.actDeleteFile.Enabled := FilesToView.Count > 1;
  with Viewer.ViewerControl do
  begin
    if (AMode = 0) then
      AMode:= gViewerMode
    else begin
      Viewer.FMode:= AMode;
    end;
    case AMode of
      1: Mode:= WRAP_MODE[gViewerWrapText];
      2: Mode:= vcmBin;
      3: Mode:= vcmHex;
      6: Mode:= vcmDec;
    end;
  end;
  Viewer.LoadFile(0);

  if (WaitData = nil) then
    Viewer.ShowOnTop
  else begin
    WaitData.ShowOnTop(Viewer);
  end;
end;

{ TDrawGrid }

function TDrawGrid.GetIndex: Integer;
begin
  Result:= Row * ColCount + Col;
end;

procedure TDrawGrid.SetIndex(AValue: Integer);
begin
  if (FMutex = 0) then
  try
    Inc(FMutex);
    MoveExtend(False, AValue mod ColCount, AValue div ColCount);
  finally
    Dec(FMutex)
  end;
end;

procedure TDrawGrid.CalculateColRowCount;
begin
  if ClientWidth div (DefaultColWidth + 6) > 0 then
  begin
    ColCount:= ClientWidth div (DefaultColWidth + 6);
  end;
  if Assigned(FFileList) then
  begin
    if FFileList.Count mod ColCount > 0 then
      RowCount:= FFileList.Count div ColCount + 1
    else begin
      RowCount:= FFileList.Count div ColCount;
    end;
  end;
end;

function TDrawGrid.MouseOnGrid(X, Y: LongInt): Boolean;
var
  bTemp: Boolean;
  iRow, iCol: LongInt;
begin
  bTemp:= AllowOutboundEvents;
  AllowOutboundEvents:= False;
  MouseToCell(X, Y, iCol, iRow);
  AllowOutboundEvents:= bTemp;
  Result:= not (CellToIndex(iCol, iRow) < 0);
end;

function TDrawGrid.CellToIndex(ACol, ARow: Integer): Integer;
begin
  if (ARow < 0) or (ARow >= RowCount) or (ACol <  0) or (ACol >= ColCount) then Exit(-1);
  Result:= ARow * ColCount + ACol;
  if (Result < 0) or (Result >= FFileList.Count) then
    Result:= -1;
end;

procedure TDrawGrid.IndexToCell(Index: Integer; out ACol, ARow: Integer);
begin
  if (Index < 0) or (Index >= FFileList.Count) or (ColCount = 0) then
    begin
      ACol:= -1;
      ARow:= -1;
    end
  else
    begin
      ARow:= Index div ColCount;
      ACol:= Index mod ColCount;
    end;
end;

procedure TDrawGrid.MoveSelection;
begin
  if (FMutex = 0) then
  try
    Inc(FMutex);
    inherited MoveSelection;
  finally
    Dec(FMutex)
  end;
end;

procedure TDrawGrid.DoAutoAdjustLayout(const AMode: TLayoutAdjustmentPolicy;
  const AXProportion, AYProportion: Double);
begin
  // Don't auto adjust vertical layout
  inherited DoAutoAdjustLayout(AMode, AXProportion, 1.0);
end;

procedure TDrawGrid.KeyDown(var Key: Word; Shift: TShiftState);
var
  ACol, ARow: Integer;
begin
  case Key of
    VK_LEFT:
      begin
        if (Col - 1 < 0) and (Row > 0) then
        begin
          MoveExtend(False, ColCount - 1, Row - 1);
          Key:= 0;
        end;
      end;
    VK_RIGHT:
      begin
        if (CellToIndex(Col + 1, Row) < 0) then
        begin
          if (Row + 1 < RowCount) then
            MoveExtend(False, 0, Row + 1)
          else
            begin
              IndexToCell(FFileList.Count - 1, ACol, ARow);
              MoveExtend(False, ACol, ARow);
            end;
          Key:= 0;
        end;
      end;
    VK_HOME:
      begin
        MoveExtend(False, 0, 0);
        Key:= 0;
      end;
    VK_END:
      begin
        IndexToCell(FFileList.Count - 1, ACol, ARow);
        MoveExtend(False, ACol, ARow);
        Key:= 0;
      end;
    VK_DOWN:
      begin
        if (CellToIndex(Col, Row + 1) < 0) then
          begin
            IndexToCell(FFileList.Count - 1, ACol, ARow);
            MoveExtend(False, ACol, ARow);
            Key:= 0;
          end
      end;
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TDrawGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if MouseOnGrid(X, Y) then
    inherited MouseDown(Button, Shift, X, Y)
  else begin
    if Assigned(OnMouseDown) then
    begin
      OnMouseDown(Self, Button, Shift, X, Y);
    end;
    if not Focused then
    begin
      if CanSetFocus then SetFocus;
    end;
  end;
end;

procedure TDrawGrid.DrawCell(aCol, aRow: Integer; aRect: TRect;
  aState: TGridDrawState);
var
  ATextSize: TSize;
  sFileName: String;
  bmpThumb: TBitmap;
  AIndex, X, Y: Integer;
begin

  // in TfrmOptionsHotkeys.FillCommandList(), a TfrmViewer instance may be created
  // to obtain Hotkeys.
  // in this case, the TfrmViewer is not initialized normally, and an exception
  // may occur in some WidgetSets due to the Paint event.
  // therefore, the code is added here.
  // this is a hack-like patch, and the root cause is that the implementation of
  // TfrmOptionsHotkeys.FillCommandList() is unreasonable.
  // to completely avoid such issue, TfrmOptionsHotkeys.FillCommandList() should
  // be reimplemented in the future.
  if FFileList = nil then
    Exit;

  AIndex:= CellToIndex(aCol, aRow);

  if InRange(AIndex, 0, FFileList.Count - 1) then
  begin
    PrepareCanvas(aCol, aRow, aState);
    DefaultDrawCell(aCol, aRow, aRect, aState);

    LCLIntf.InflateRect(aRect, -2, -2);
    bmpThumb:= TBitmap(FFileList.Objects[AIndex]);
    sFileName:= ExtractFileName(FFileList.Strings[AIndex]);
    sFileName:= FitOtherCellText(sFileName, Canvas, aRect.Width);
    ATextSize:= Canvas.TextExtent(sFileName);

    if Assigned(bmpThumb) then
    begin
      // Draw thumbnail at center
      X:= aRect.Left + (aRect.Width - bmpThumb.Width) div 2;
      Y:= aRect.Top + (aRect.Height - bmpThumb.Height - ATextSize.Height - 4) div 2;
      Canvas.Draw(X, Y, bmpThumb);
    end;

    // Draw file name at center
    Y:= (aRect.Bottom - ATextSize.Height) - 2;
    X:= aRect.Left + (aRect.Width - ATextSize.Width) div 2;
    Canvas.TextOut(X, Y, sFileName);

    // Draw grid
    LCLIntf.InflateRect(aRect, 2, 2);
    DrawCellGrid(aCol, aRow, aRect, aState);
  end
  else begin
    Canvas.Brush.Color:= Color;
    Canvas.FillRect(aRect);
  end;
end;

{ TThumbThread }

procedure TThumbThread.ClearList;
var
  Index: Integer;
begin
  for Index:= 0 to FOwner.FileList.Count - 1 do
  begin
    FOwner.FileList.Objects[Index].Free;
    FOwner.FileList.Objects[Index]:= nil;
  end;
end;

procedure TThumbThread.DoOnTerminate(Sender: TObject);
begin
  FOwner.EnableActions(True);
  FOwner := nil;
end;

procedure TThumbThread.Execute;
var
  I: Integer = 0;
begin
  while (not Terminated) and (I < FOwner.FileList.Count) do
  begin
    FOwner.CreatePreview(FOwner.FileList.Strings[I], I);
    if (I mod 3 = 0) then Synchronize(@FOwner.DrawPreview.Invalidate);
    Inc(I);
  end;
  Synchronize(@FOwner.DrawPreview.Invalidate);
end;

constructor TThumbThread.Create(Owner: TfrmViewer);
begin
  inherited Create(True);
  Owner.EnableActions(False);
  OnTerminate := @DoOnTerminate;
  FOwner := Owner;
  ClearList;
  Start;
end;

class procedure TThumbThread.Finish(var Thread: TThread);
begin
  if Assigned(Thread) then
  begin
    Thread.Terminate;
    Thread.WaitFor;
    FreeAndNil(Thread);
  end;
end;

constructor TfrmViewer.Create(TheOwner: TComponent; aWaitData: TWaitData;
  aQuickView: Boolean);
begin
  bQuickView:= aQuickView;
  inherited Create(TheOwner);
  FWaitData := aWaitData;
  FLastSearchPos := -1;
  FZoomFactor := 100;
  ActivePlugin := -1;
  FThumbnailManager:= nil;
  FExif:= TExifReader.Create;
  FRegExp:= TRegExprEx.Create;
  if not bQuickView then Menu:= MainMenu;
  FCommands := TFormCommands.Create(Self, actionList);

  FontOptionsToFont(gFonts[dcfMain], memFolder.Font);
  memFolder.Color:= gColors.FilePanel^.BackColor;

  actShowCaret.Checked := gShowCaret;
  actWrapText.Checked := gViewerWrapText;
  ViewerControl.ShowCaret := gShowCaret;
  ViewerControl.TabSpaces := gTabSpaces;
  ViewerControl.AutoCopy := gViewerAutoCopy;
  ViewerControl.MaxTextWidth := gMaxTextWidth;
  ViewerControl.LeftMargin := gViewerLeftMargin;
  ViewerControl.ExtraLineSpacing := gViewerLineSpacing;
  if gViewerWrapText then ViewerControl.Mode:= vcmWrap;
end;

constructor TfrmViewer.Create(TheOwner: TComponent);
begin
  Create(TheOwner, nil);
end;

destructor TfrmViewer.Destroy;
begin
  FExif.Free;
  StopCalcFolderSize;
  FreeAndNil(FRegExp);
  FreeAndNil(FileList);
  FreeAndNil(FThumbnailManager);
  inherited Destroy;
  FreeAndNil(WlxPlugins);
  FWaitData.Free; // If this is temp file source, the files will be deleted.
  tmp_all.Free;
end;

procedure TfrmViewer.AfterConstruction;
begin
  inherited AfterConstruction;
  ToolBar1.ImagesWidth:= gToolIconsSize;
  ToolBar1.SetButtonSize(gToolIconsSize + ScaleX(6, 96),
                         gToolIconsSize + ScaleY(6, 96));
end;

procedure TfrmViewer.LoadFile(const aFileName: String);
var
  i: Integer;
  aName: String;
  dwFileAttributes: TFileAttrs;
begin
  FLastSearchPos := -1;
  Caption := ReplaceHome(aFileName);
  ViewerControl.FileName := EmptyStr;

  // Clear text on status bar.
  for i := 0 to Status.Panels.Count - 1 do
    Status.Panels[i].Text := '';

  dwFileAttributes := mbFileGetAttr(aFileName);

  if FPS_ISLNK(dwFileAttributes) then
  begin
    dwFileAttributes := mbFileGetAttrNoLinks(aFileName);
  end;

  if dwFileAttributes = faInvalidAttributes then
  begin
    ActivatePanel(pnlFolder);
    ExitPluginMode;
    memFolder.Font.Color:= clRed;
    memFolder.Lines.Text:= rsMsgErrNoFiles;
    Exit;
  end;

  if bQuickView then
  begin
    iActiveFile := 0;
    FileList.Text := aFileName;
  end;

  Screen.BeginWaitCursor;
  try
    if FPS_ISDIR(dwFileAttributes) then
      aName:= IncludeTrailingPathDelimiter(aFileName)
    else begin
      aName:= aFileName;
    end;
    if (FMode > 0) then
    begin
      ViewerControl.FileName := aFileName;
      ActivatePanel(pnlText);
      FMode:= 0;
    end
    else if CheckPlugins(aName) then
      ActivatePanel(nil)
    else if FPS_ISDIR(dwFileAttributes) then
      begin
        ActivatePanel(pnlFolder);
        memFolder.Clear;
        memFolder.Font.Color:= gColors.FilePanel^.ForeColor;
        memFolder.Lines.Add(rsPropsFolder + ': ');
        memFolder.Lines.Add(aFileName);
        memFolder.Lines.Add('');
        StartCalcFolderSize;
      end
    else if CheckGraphics(aFileName) and LoadGraphics(aFileName) then
      ActivatePanel(pnlImage)
    else if CheckOffice(aFileName) then
    begin
      ActivatePanel(pnlText);
      miOffice.Checked:= True;
    end
    else if CheckSynEdit(aFileName) and LoadSynEdit(aFileName) then
    begin
      ActivatePanel(pnlCode);
    end
    else begin
      ViewerControl.FileName := aFileName;
      ActivatePanel(pnlText)
    end;

    FileName:= aFileName;
  finally
    Screen.EndWaitCursor;
  end;
end;

procedure TfrmViewer.LoadNextFile(Index: Integer);
begin
  try
    if bPlugin and FWlxModule.FileParamVSDetectStr(FileList[Index], False) then
    begin
      if (FWlxModule.CallListLoadNext(Self.Handle, FileList[Index], PluginShowFlags) <> LISTPLUGIN_ERROR) then
      begin
        Status.Panels[sbpFileNr].Text:= Format('%d/%d', [Index + 1, FileList.Count]);
        FileName:= FileList[Index];
        Caption:= ReplaceHome(FFileName);
        iActiveFile := Index;
        Exit;
      end;
    end;
    ExitPluginMode;
    LoadFile(Index);
  finally
    if pnlPreview.Visible then
      DrawPreview.Index:= iActiveFile;
  end;
end;

procedure TfrmViewer.LoadNextFile(const aFileName: String);
begin
  if bPlugin and FWlxModule.FileParamVSDetectStr(aFileName, False) then
  begin
    if FWlxModule.CallListLoadNext(Self.Handle, aFileName, PluginShowFlags) <> LISTPLUGIN_ERROR then
    begin
      Self.FileName:= aFileName;
      Exit;
    end;
  end;
  ExitPluginMode;
  ViewerControl.ResetEncoding;
  LoadFile(aFileName);
  if ViewerControl.IsFileOpen then
  begin
    ViewerControl.GoHome;
    if (ViewerControl.Mode = vcmText) then
      ViewerControl.HGoHome;
  end;
  if actAutoReload.Checked then cm_AutoReload([]);
end;

procedure TfrmViewer.LoadFile(iIndex: Integer);
var
  ANewFile: Boolean;
begin
  ANewFile:= iActiveFile <> iIndex;

  iActiveFile := iIndex;
  LoadFile(FileList.Strings[iIndex]);

  btnPaint.Down:= False;
  btnHightlight.Down:= False;
  Status.Panels[sbpFileNr].Text:= Format('%d/%d', [iIndex + 1, FileList.Count]);

  if ANewFile then begin
    if ViewerControl.IsFileOpen then
    begin
      ViewerControl.GoHome;
      if (ViewerControl.Mode = vcmText) then
        ViewerControl.HGoHome;
    end;
    if actAutoReload.Checked then cm_AutoReload([]);
  end;
end;

procedure TfrmViewer.FormResize(Sender: TObject);
begin
  if bPlugin then FWlxModule.ResizeWindow(GetListerRect);
end;

procedure TfrmViewer.FormShow(Sender: TObject);
begin
{$IF DEFINED(LCLGTK2)}
  if not pnlPreview.Visible then
  begin
    pnlPreview.Visible:= True;
    pnlPreview.Visible:= False;
  end;
{$ENDIF}
  // Was not supposed to be necessary, but this fix a problem with old "hpg_ed" plugin
  // that needed a resize to be spotted in correct position. Through 27 plugins tried, was the only one required that. :-(
  FormResize(Self);

  if miPreview.Checked then
  begin
    miPreview.Checked := not (miPreview.Checked);
    cm_Preview(['']);
  end;
end;

procedure TfrmViewer.GifAnimMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbRight then
  begin
    pmEditMenu.PopUp;
  end;
end;

procedure TfrmViewer.GifAnimMouseEnter(Sender: TObject);
begin
  if miFullScreen.Checked then TimerViewer.Enabled:=true;
end;

procedure TfrmViewer.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MDFlag := true;
  X:=round(X*Image.Picture.Width/Image.Width);                  // for correct paint after zoom
  Y:=round(Y*Image.Picture.Height/Image.Height);
  cas:=0;
    if (button = mbLeft) and btnHightlight.Down then
       begin
         if (X>StartX) and (X<=StartX+10) then
            begin
              if (Y>StartY) and (Y<=StartY+10) then begin
                                                 cas:=1;
                                                 tmpX:=X-StartX;
                                                 tmpY:=Y-StartY;
                                                 end;
              if (Y>StartY+10) and (Y<=EndY-10) then begin
                                                  cas:=2;
                                                  tmpX:=X-StartX;
                                                  end;
              if (Y>EndY-9) and (Y<=EndY) then begin
                                            cas:=3;
                                            tmpX:=X-StartX;
                                            tmpY:=EndY-Y;
                                            end;
              if (Y<StartY) or (Y>EndY) then cas:=0;
            end;
         if (X>StartX+10) and (X<=EndX-10) then
            begin
              if (Y>StartY) and (Y<=StartY+10) then begin
                                                    cas:=4;
                                                    tmpY:=Y-StartY;
                                                    end;
              if (Y>StartY+10) and (Y<=EndY-10)then begin
                                                    cas:=5;
                                                    tmpX:=X-StartX;
                                                    tmpY:=Y-StartY;
                                                    end;
              if (Y>EndY-9) and (Y<=EndY) then begin
                                               cas:=6;
                                               tmpY:=EndY-Y;
                                               end;
              If (Y<StartY) or (Y>EndY) then cas:=0;
            end;
         if (X>EndX-10) and (X<=EndX) then
            begin
              if (Y>StartY) and (Y<=StartY+10) then begin
                                                    cas:=7;
                                                    tmpX := EndX-X;
                                                    tmpY:=StartY-Y;
                                                    end;
              if (Y>StartY+10) and (Y<=EndY-10) then begin
                                                     cas:=8;
                                                     tmpX := EndX-X;
                                                     end;
              if (Y>EndY-9) and (Y<=EndY) then begin
                                               cas:=9;
                                               tmpX := EndX-X;
                                               tmpY:=EndY-Y;
                                               end;
              If (Y<StartY) or (Y>EndY) then cas:=0;
            end;
         if (X<StartX) or (X>EndX) then cas:=0;
        end;
    if Button=mbRight then
      begin
        pmEditMenu.PopUp;
      end;

    if cas=0 then
         begin
           StartX := X;
           StartY := Y;
         end;

    if btnPaint.Down then
      begin
        CreateTmp;
        Image.Picture.Bitmap.Canvas.MoveTo (x,y);
    end;
  if not (btnHightlight.Down) and not (btnPaint.Down) then
    begin
    tmpX:=x;
    tmpY:=y;
    Image.Cursor:=crHandPoint;
    end;
end;

procedure TfrmViewer.ImageMouseEnter(Sender: TObject);
begin
  if miFullScreen.Checked then TimerViewer.Enabled:=true;
end;

procedure TfrmViewer.ImageMouseLeave(Sender: TObject);
begin
  if miFullScreen.Checked then TimerViewer.Enabled:=false;
end;

procedure TfrmViewer.ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  tmp: integer;
begin
  if btnHightlight.Down then Image.Cursor:=crCross;
  if miFullScreen.Checked then
    begin
      sboxImage.Cursor:=crDefault;
      Image.Cursor:=crDefault;
      i_timer:=0;
    end;
  X:=round(X*Image.Picture.Width/Image.Width);                      // for correct paint after zoom
  Y:=round(Y*Image.Picture.Height/Image.Height);
  if MDFlag then
        begin
      if btnHightlight.Down then
        begin
            if cas=0 then
            begin
              EndX:=X;
              EndY:=Y;
            end;
            if cas=1 then
            begin
              StartX:= X-tmpX;
              StartY:=Y-tmpY;
            end;
            if cas=2 then StartX:= X-tmpX;
            if cas=3then
            begin
              StartX:= X-tmpX;
              EndY:=Y+tmpY;
            end;
            if cas=4 then StartY:=Y-tmpY;
            if cas=5 then
            begin
              tmp:=EndX-StartX;
              StartX:= X-tmpX;
              EndX:=StartX+tmp;
              tmp:=EndY-StartY;
              StartY:= Y-tmpY;
              EndY:=StartY+tmp;
            end;
            if cas=6 then EndY:=Y+tmpY;
            if cas=7 then
            begin
              EndX:=X+tmpX;
              StartY:=Y-tmpY;
            end;
            if cas=8 then endX:=X+tmpX;
            if cas=9 then
            begin
              EndX:=X+tmpX;
              EndY:=Y+tmpY;
            end;
            if StartX<0 then
              begin
                StartX:=0;
                EndX:= UndoEX;
              end;
            if StartY<0 then
              begin
                StartY:=0;
                EndY:= UndoEY;
              end;
            if endX> Image.Picture.Width then endX:=Image.Picture.Width;
            if endY> Image.Picture.Height then endY:=Image.Picture.Height;
            with Image.Picture.Bitmap.Canvas do
              begin
                DrawFocusRect(Rect(UndoSX,UndoSY,UndoEX,UndoEY));
                DrawFocusRect(Rect(UndoSX+10,UndoSY+10,UndoEX-10,UndoEY-10));
                DrawFocusRect(Rect(StartX,StartY,EndX,EndY));
                DrawFocusRect(Rect(StartX+10,StartY+10,EndX-10,EndY-10));//Pen.Mode := pmNotXor;
                Status.Panels[sbpImageSelection].Text := IntToStr(EndX-StartX)+'x'+IntToStr(EndY-StartY);
                UndoSX:=StartX;
                UndoSY:=StartY;
                UndoEX:=EndX;
                UndoEY:=EndY;
              end;
          end;
        if btnPaint.Down then
        begin
          with Image.Picture.Bitmap.Canvas do
          begin
            Brush.Style:= bsClear;
            Pen.Width := btnPenWidth.Tag;
            Pen.Color := btnPenColor.ButtonColor;
            Pen.Style := psSolid;
            tmp:= Pen.Width+10;

            case TViewerPaintTool(btnPenMode.Tag) of
              vptPen: LineTo (x,y);
              vptRectangle, vptEllipse:
              begin
                if (startX>x) and (startY<y) then CopyRect (Rect(UndoSX+tmp,UndoSY-tmp,UndoEX-tmp,UndoEY+tmp), tmp_all.canvas,Rect(UndoSX+tmp,UndoSY-tmp,UndoEX-tmp,UndoEY+tmp));
                if (startX<x) and (startY>y) then CopyRect (Rect(UndoSX-tmp,UndoSY+tmp,UndoEX+tmp,UndoEY-tmp), tmp_all.canvas,Rect(UndoSX-tmp,UndoSY+tmp,UndoEX+tmp,UndoEY-tmp));
                if (startX>x) and (startY>y) then
                  CopyRect (Rect(UndoSX+tmp,UndoSY+tmp,UndoEX-tmp,UndoEY-tmp), tmp_all.canvas,Rect(UndoSX+tmp,UndoSY+tmp,UndoEX-tmp,UndoEY-tmp))
                else
                  CopyRect (Rect(UndoSX-tmp,UndoSY-tmp,UndoEX+tmp,UndoEY+tmp), tmp_all.canvas,Rect(UndoSX-tmp,UndoSY-tmp,UndoEX+tmp,UndoEY+tmp));//UndoTmp;

                case TViewerPaintTool(btnPenMode.Tag) of
                  vptRectangle: Rectangle(Rect(StartX,StartY,X,Y));
                  vptEllipse:Ellipse(StartX,StartY,X,Y);
                end;
              end;
            end;

            UndoSX:=StartX;
            UndoSY:=StartY;
            UndoEX:=X;
            UndoEY:=Y;
          end;
        end;
      if not (btnHightlight.Down) and not (btnPaint.Down) then
    begin
      sboxImage.VertScrollBar.Position:=sboxImage.VertScrollBar.Position+tmpY-y;
      sboxImage.HorzScrollBar.Position:=sboxImage.HorzScrollBar.Position+tmpX-x;
    end;
  end;
end;

procedure TfrmViewer.ImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  X:=round(X*Image.Picture.Width/Image.Width);             // for correct paint after zoom
  Y:=round(Y*Image.Picture.Height/Image.Height);
  MDFlag:=false;
  if ToolBar1.Visible then
    begin
      if (button = mbLeft) and btnHightlight.Down then
    begin
      UndoTmp;
      CheckXY;
      with Image.Picture.Bitmap.Canvas do
      begin
        Brush.Style := bsClear;
        Pen.Style := psDot;
        Pen.Color := clHighlight;
        DrawFocusRect(Rect(StartX,StartY,EndX,EndY));
        DrawFocusRect(Rect(StartX+10,StartY+10,EndX-10,EndY-10));
        Status.Panels[sbpImageSelection].Text := IntToStr(EndX-StartX)+'x'+IntToStr(EndY-StartY);
      end;
    end;
    end;
  Image.Cursor:=crDefault;
end;

procedure TfrmViewer.ImageMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then ZoomImage(0.9);
end;

procedure TfrmViewer.ImageMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then ZoomImage(1.1);
end;

procedure TfrmViewer.miPenClick(Sender: TObject);
begin
  btnPenMode.Tag:= TMenuItem(Sender).Tag;
  btnPenMode.ImageIndex:= TMenuItem(Sender).ImageIndex;
end;

procedure TfrmViewer.miLookBookClick(Sender: TObject);
begin
  cm_ShowAsBook(['']);
//  miLookBook.Checked:=not miLookBook.Checked;
end;

procedure TfrmViewer.pmEditMenuPopup(Sender: TObject);
begin
  pmiCopyFormatted.Visible:= ViewerControl.Mode in [vcmHex, vcmDec];
end;

procedure TfrmViewer.CreatePreview(FullPathToFile: string; index: integer;
  delete: boolean);
var
  bmpThumb : TBitmap = nil;
begin
  if pnlPreview.Visible or delete then
    begin
      if not Assigned(FThumbnailManager) then
        FThumbnailManager:= TThumbnailManager.Create(DrawPreview.Canvas.Brush.Color);
      if delete then
        begin
          FThumbnailManager.RemovePreview(FullPathToFile); // delete thumb if need
          if pnlPreview.Visible then begin
            FileList.Objects[Index].Free;
            FileList.Objects[Index]:= nil;
          end;
        end
      else
        begin
          bmpThumb:= FThumbnailManager.CreatePreview(FullPathToFile);
          // Insert to the BitmapList
          FileList.Objects[Index]:= bmpThumb;
        end;
    end;
end;

procedure TfrmViewer.WMCommand(var Message: TLMCommand);
var
  Index: Integer;
begin
  case Message.NotifyCode of
    itm_center:
      miCenter.Checked:= Boolean(Message.ItemID);
    itm_next: begin
      if Message.ItemID = 0 then cm_LoadNextFile([]);
    end;
    itm_wrap: begin
      gViewerWrapText:= Boolean(Message.ItemID);
      actWrapText.Checked:= gViewerWrapText;
    end;
    itm_fit: begin
      case Message.ItemID of
        0:
        begin
          miStretch.Checked:= False;
          miStretchOnlyLarge.Checked:= False;
        end;
        2, 3:
        begin
          miStretch.Checked:= (Message.ItemID = 2);
          miStretchOnlyLarge.Checked:= (Message.ItemID = 3);
        end;
      end;
    end;
    itm_fontstyle: begin
      case Message.ItemID of
        lcp_ansi:
        begin
          FPluginEncoding:= lcp_ansi;
          Index:= miEncoding.IndexOfCaption(ViewerEncodingsNames[veAnsi]);
        end;
        lcp_ascii:
        begin
          FPluginEncoding:= lcp_ascii;
          Index:= miEncoding.IndexOfCaption(ViewerEncodingsNames[veOem]);
        end;
        else begin
          Index:= 0;
          FPluginEncoding:= 0;
        end;
        miEncoding.Items[Index].Checked:= True;
        ViewerControl.Encoding:= TViewerEncoding(Index);
        Status.Panels[sbpTextEncoding].Text := rsViewEncoding + ': ' + ViewerControl.EncodingName;
      end;
    end;
  end;
end;

procedure TfrmViewer.WMSetFocus(var Message: TLMSetFocus);
begin
  if bPlugin then FWlxModule.SetFocus;
end;

procedure TfrmViewer.CMThemeChanged(var Message: TLMessage);
var
  Highlighter: TSynCustomHighlighter;
begin
  if miCode.Checked then
  begin
    Highlighter:= TSynCustomHighlighter(dmHighl.SynHighlighterHashList.Data[SynEdit.Highlighter.LanguageName]);
    if Assigned(Highlighter) then dmHighl.SetHighlighter(SynEdit, Highlighter);
  end;
end;

procedure TfrmViewer.RedEyes;
var
  tmp:TBitMap;
  x,y,r,g,b: integer;
  col: TColor;
begin
  if (EndX=StartX) or (EndY=StartY) then Exit;
  UndoTmp;
  tmp:=TBitMap.Create;
  tmp.Width:= EndX-StartX;
  tmp.Height:= EndY-StartY;
  for x:=0 to (EndX-StartX) div 2 do
     begin
       for y:=0 to (EndY-StartY) div 2  do
          begin
          if y<round(sqrt((1-(sqr(x)/sqr((EndX-StartX)/2)))*sqr((EndY-StartY)/2))) then
            begin
            col:=Image.Picture.Bitmap.Canvas.Pixels[x+StartX+(EndX-StartX) div 2,y+StartY+(EndY-StartY) div 2];
            r:=GetRValue(col);
            g:=GetGValue(col);
            b:=GetBValue(col);
            if (r>100) and (g<100) and (b<100) then r:=b;
            tmp.Canvas.Pixels[x+(EndX-StartX) div 2,y+(EndY-StartY) div 2]:= rgb(r,g,b);

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX-x+(EndX-StartX) div 2,y+StartY+(EndY-StartY) div 2];
            r:=GetRValue(col);
            g:=GetGValue(col);
            b:=GetBValue(col);
            if (r>100) and (g<100) and (b<100) then r:=b;
            tmp.Canvas.Pixels[(EndX-StartX) div 2-x,y+(EndY-StartY) div 2]:= rgb(r,g,b);

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX+x+(EndX-StartX) div 2,StartY-y+(EndY-StartY) div 2];
            r:=GetRValue(col);
            g:=GetGValue(col);
            b:=GetBValue(col);
            if (r>100) and (g<100) and (b<100) then r:=b;
            tmp.Canvas.Pixels[(EndX-StartX) div 2+x,(EndY-StartY) div 2-y]:= rgb(r,g,b);

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX-x+(EndX-StartX) div 2,StartY-y+(EndY-StartY) div 2];
            r:=GetRValue(col);
            g:=GetGValue(col);
            b:=GetBValue(col);
            if (r>100) and (g<100) and (b<100) then r:=b;
            tmp.Canvas.Pixels[(EndX-StartX) div 2-x,(EndY-StartY) div 2-y]:= rgb(r,g,b);
          end
       else
          begin
            col:=Image.Picture.Bitmap.Canvas.Pixels[x+StartX+(EndX-StartX) div 2,y+StartY+(EndY-StartY) div 2];
            tmp.Canvas.Pixels[x+(EndX-StartX) div 2,y+(EndY-StartY) div 2]:= col;

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX-x+(EndX-StartX) div 2,y+StartY+(EndY-StartY) div 2];
            tmp.Canvas.Pixels[(EndX-StartX) div 2-x,y+(EndY-StartY) div 2]:= col;

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX+x+(EndX-StartX) div 2,StartY-y+(EndY-StartY) div 2];
            tmp.Canvas.Pixels[(EndX-StartX) div 2+x,(EndY-StartY) div 2-y]:= col;

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX-x+(EndX-StartX) div 2,StartY-y+(EndY-StartY) div 2];
            tmp.Canvas.Pixels[(EndX-StartX) div 2-x,(EndY-StartY) div 2-y]:= col;
          end;
          end;
     end;
  Image.Picture.Bitmap.Canvas.Draw (StartX,StartY,tmp);
  CreateTmp;
  tmp.Free;
end;

procedure TfrmViewer.SynEditCaret;
begin
  if gShowCaret then
    SynEdit.Options:= SynEdit.Options - [eoNoCaret]
  else begin
    SynEdit.Options:= SynEdit.Options + [eoNoCaret];
  end;
end;

procedure TfrmViewer.DeleteCurrentFile;
var
  OldIndex, NewIndex: Integer;
begin
  if (iActiveFile + 1) < FileList.Count then
    NewIndex := iActiveFile + 1
  else begin
    NewIndex := iActiveFile - 1;
  end;
  OldIndex:= iActiveFile;

  LoadNextFile(NewIndex);

  CreatePreview(FileList.Strings[OldIndex], OldIndex, True);
  mbDeleteFile(FileList.Strings[OldIndex]);
  FileList.Delete(OldIndex);

  if OldIndex < FileList.Count then
    iActiveFile := OldIndex
  else begin
    iActiveFile := FileList.Count - 1;
  end;

  if pnlPreview.Visible then
    DrawPreview.Index := iActiveFile;

  actMoveFile.Enabled := FileList.Count > 1;
  actDeleteFile.Enabled := FileList.Count > 1;

  DrawPreview.Repaint;
  SplitterChangeBounds;
end;

procedure TfrmViewer.EnableCopy(AEnabled: Boolean);
begin
  actSelectAll.Enabled:= AEnabled;
  actCopyToClipboard.Enabled:= AEnabled;
  actSelectAll.Visible:= AEnabled;
  actCopyToClipboard.Visible:= AEnabled;
end;

procedure TfrmViewer.EnablePrint(AEnabled: Boolean);
begin
  actPrint.Enabled:= AEnabled;
  actPrint.Visible:= AEnabled;
  actPrintSetup.Enabled:= AEnabled;
  actPrintSetup.Visible:= AEnabled;
end;

procedure TfrmViewer.EnableSearch(AEnabled: Boolean);
begin
  actFind.Enabled:= AEnabled;
  actFindNext.Enabled:= AEnabled;
  actFindPrev.Enabled:= AEnabled;
  actFind.Visible:= AEnabled;
  actFindNext.Visible:= AEnabled;
  actFindPrev.Visible:= AEnabled;
end;

procedure TfrmViewer.EnableActions(AEnabled: Boolean);
begin
  actCopyFile.Enabled:= AEnabled;
  actSave.Enabled:= AEnabled and bImage;
  actSaveAs.Enabled:= AEnabled and bImage;
  actMoveFile.Enabled:= AEnabled and (FileList.Count > 1);
  actDeleteFile.Enabled:= AEnabled and (FileList.Count > 1);
end;

procedure TfrmViewer.SavingProperties(Sender: TObject);
begin
  if miFullScreen.Checked then SessionProperties:= EmptyStr;
end;

procedure TfrmViewer.SetFileName(const AValue: String);
begin
  if actAutoReload.Checked then
    Status.Panels[sbpFileName].Text:= '* ' + AValue
  else begin
    Status.Panels[sbpFileName].Text:= AValue;
  end;
  if FFileName <> AValue then
  begin
    FFileName:= AValue;
    MakePluginsMenu;
  end;
  UpdatePluginsMenu;
end;

procedure TfrmViewer.CutToImage;
var
  w,h:integer;
begin
  UndoTmp;

  with Image.Picture.Bitmap do
  begin
    w:=EndX-StartX;
    h:=EndY-StartY;
    Canvas.CopyRect(rect(0,0,w,h), Image.Picture.Bitmap.Canvas, rect(startX,StartY,EndX,EndY));
    SetSize (w,h);
  end;
  Image.Width:=w;
  Image.Height:=h;

  CreateTmp;
  StartX:=0;StartY:=0;EndX:=0;EndY:=0;
end;

procedure TfrmViewer.UndoTmp;
begin
  Image.Picture.Bitmap.Canvas.Clear;
  Image.Picture.Bitmap.Canvas.Draw(0,0,tmp_all);
end;

procedure TfrmViewer.CreateTmp;
begin
  tmp_all.Free;
  tmp_all:= TBitmap.Create;
  tmp_all.Assign(Image.Picture.Graphic);
end;

procedure TfrmViewer.CheckXY;
var
  tmp: integer;
begin
  if EndX<StartX then
    begin
      tmp:=StartX;
      StartX:=EndX;
      EndX:=tmp
    end;
  if EndY<StartY then
    begin
      tmp:=StartY;
      StartY:=EndY;
      EndY:=tmp
    end;
end;

procedure TfrmViewer.Res (W, H: integer);
var
  tmp: TCustomBitmap;
  r: TRect;
begin
  if btnHightlight.Down then UndoTmp;
  tmp:= TBitmap.Create;
  tmp.Assign(Image.Picture.Graphic);
  r := Rect(0, 0, W, H);
  Image.Picture.Bitmap.SetSize(W,H);
  Image.Picture.Bitmap.Canvas.Clear;
  Image.Picture.Bitmap.Canvas.StretchDraw(r, tmp);
  tmp.free;
  CreateTmp;
  StartX:=0;
  StartY:=0;
  EndX:=0;
  EndY:=0;
end;

function TfrmViewer.PluginShowFlags : Integer;
begin
  Result:= FPluginEncoding or
           IfThen(miWrapText.Checked, lcp_wraptext, 0) or
           IfThen(miStretch.Checked, lcp_fittowindow, 0) or
           IfThen(miCenter.Checked, lcp_center, 0) or
           IfThen(miStretchOnlyLarge.Checked, lcp_fittowindow or lcp_fitlargeronly, 0)
end;

function TfrmViewer.CheckPlugins(const sFileName: String; bForce: Boolean = False): Boolean;
var
  I, J: Integer;
  AFileName: String;
  ShowFlags: Integer;
  Start, Finish: Integer;
begin
  AFileName:= ExcludeTrailingBackslash(sFileName);
  ShowFlags:= IfThen(bForce, lcp_forceshow, 0) or PluginShowFlags;
  // DCDebug('WlXPlugins.Count = ' + IntToStr(WlxPlugins.Count));
  for J := 1 to 2 do
  begin
    // Find after active plugin
    if (J = 1) then begin
      Start := ActivePlugin + 1;
      Finish :=  WlxPlugins.Count - 1;
    end
    // Find before active plugin
    else begin
      Start := 0;
      Finish := ActivePlugin;
    end;
    for I:= Start to Finish do
    begin
      if WlxPlugins.GetWlxModule(I).FileParamVSDetectStr(AFileName, bForce) then
      begin
        if LoadPlugin(sFileName, I, ShowFlags) then Exit(True);
      end;
    end;
  end;
  // Plugin not found
  ActivePlugin:= -1;
  FWlxModule:= nil;
  Result:= False;
end;

procedure TfrmViewer.ExitPluginMode;
begin
  if Assigned(FWlxModule) then begin
    FWlxModule.CallListCloseWindow;
  end;
  bPlugin:= False;
  FWlxModule:= nil;
  ActivePlugin:= -1;
  UpdatePluginsMenu;
  EnablePrint(False);
end;

procedure TfrmViewer.ExitQuickView;
begin
  ExitPluginMode;

  gImageStretch:= miStretch.Checked;
  gImageStretchOnlyLarge:= miStretchOnlyLarge.Checked;
  gImageCenter:= miCenter.Checked;
end;

procedure TfrmViewer.ShowTextViewer(AMode: TViewerControlMode);
begin
  ExitPluginMode;
  ReopenAsTextIfNeeded;
  ViewerControl.Mode:= AMode;
  if ViewerControl.Mode = vcmBook then
  begin
    with ViewerControl, gColors.Viewer^ do
      begin
        Color:= BookBackgroundColor;
        Font.Color:= BookFontColor;
        ColCount:= gColCount;
        Position:= gTextPosition;
      end;
    FontOptionsToFont(gFonts[dcfViewerBook], ViewerControl.Font);
  end
  else begin
    with ViewerControl do
      begin
        Color:= clWindow;
        Font.Color:= clWindowText;
        ColCount:= 1;
      end;
    FontOptionsToFont(gFonts[dcfViewer], ViewerControl.Font);
  end;
  ActivatePanel(pnlText);
end;

procedure TfrmViewer.CopyMoveFile(AViewerAction: TViewerCopyMoveAction);
begin
  FModSizeDialog:= TfrmModView.Create(Self);
  try
    FModSizeDialog.pnlQuality.Visible:= False;
    FModSizeDialog.pnlSize.Visible:= False;
    FModSizeDialog.pnlCopyMoveFile.Visible:= True;
    if AViewerAction = vcmaMove then
      FModSizeDialog.Caption:= rsDlgMv
    else
      FModSizeDialog.Caption:= rsDlgCp;
    if FModSizeDialog.ShowModal = mrOk then
    begin
      if FModSizeDialog.Path = '' then
        msgError(rsMsgInvalidPath)
      else
        begin
          CopyFile(FileList.Strings[iActiveFile],FModSizeDialog.Path+PathDelim+ExtractFileName(FileList.Strings[iActiveFile]));
          if AViewerAction = vcmaMove then
          begin
            DeleteCurrentFile;
          end;
        end;
    end;
  finally
    FreeAndNil(FModSizeDialog);
  end;
end;

procedure TfrmViewer.ZoomImage(ADelta: Double);
begin
  if (FZoomFactor = 100) and (miStretch.Checked or miStretchOnlyLarge.Checked) then
  begin
    // Calculate zoom factor at first zoom
    FZoomFactor:= Round(FScaleFactor * 100);
  end;
  FZoomFactor := Round(FZoomFactor * ADelta);
  AdjustImageSize;
end;

function TfrmViewer.DoZoom( const delta: Double; const inc: Integer ): Boolean;
var
  ALine: Integer;
begin
  Result:= False;
  if miGraphics.Checked then begin
    ZoomImage( delta );
    Result:= True;
    Exit;
  end;

  if (inc>0) and (gFonts[dcfViewer].Size>=gFonts[dcfViewer].MaxValue) then
    Exit;
  if (inc<0) and (gFonts[dcfViewer].Size<=gFonts[dcfViewer].MinValue) then
    Exit;
  gFonts[dcfViewer].Size:= gFonts[dcfViewer].Size + inc;
  Result:= True;

  if miCode.Checked then begin
    ALine:= SynEdit.TopLine;
    FontOptionsToFont(gFonts[dcfViewer], SynEdit.Font);
    SynEdit.TopLine:= ALine;
    SynEdit.Refresh;
  end else begin
    ViewerControl.Font.Size:= gFonts[dcfViewer].Size;
    ViewerControl.Repaint;
  end;
end;

function TfrmViewer.DoZoomIn: Boolean;
begin
  Result:= DoZoom( 1.1, 1 );
end;

function TfrmViewer.DoZoomOut: Boolean;
begin
  Result:= DoZoom( 0.909, -1 );
end;

procedure TfrmViewer.RotateImage(AGradus: integer);
// AGradus now supported only 90,180,270 values
var
  x, y: Integer;
  xWidth,
  yHeight: Integer;
  SourceImg: TLazIntfImage;
  TargetImg: TLazIntfImage;
begin
  TargetImg:= TLazIntfImage.Create(0, 0);
  SourceImg := TLazIntfImage.Create(TRasterImage(Image.Picture.Graphic).RawImage, False);
  TargetImg.DataDescription:= SourceImg.DataDescription; // use the same image format
  xWidth:= SourceImg.Width - 1;
  yHeight:= SourceImg.Height - 1;

  if AGradus = 90 then
  begin
    TargetImg.SetSize(yHeight + 1, xWidth + 1);
    for y:= 0 to xWidth do
    begin
      for x:= 0 to yHeight do
      begin
        TargetImg.Colors[x, y]:= SourceImg.Colors[y, yHeight - x];
      end;
    end;
    x:= Image.Width;
    Image.Width:= Image.Height;
    Image.Height:= x;
  end;

  if AGradus = 180 then
  begin
    TargetImg.SetSize(xWidth + 1, yHeight + 1);
    for y:= 0 to yHeight do
    begin
      for x:= 0 to xWidth do
      begin
        TargetImg.Colors[x, y]:= SourceImg.Colors[xWidth - x, yHeight - y];
      end;
    end;
  end;

  if AGradus = 270 then
  begin
    TargetImg.SetSize(yHeight + 1, xWidth + 1);
    for y:= 0 to xWidth do
    begin
      for x:= 0 to yHeight do
      begin
        TargetImg.Colors[x, y]:= SourceImg.Colors[xWidth - y, x];
      end;
    end;
    x:= Image.Width;
    Image.Width:= Image.Height;
    Image.Height:= x;
  end;

  TRasterImage(Image.Picture.Graphic).LoadFromIntfImage(TargetImg);
  FreeAndNil(SourceImg);
  FreeAndNil(TargetImg);
  AdjustImageSize;
  CreateTmp;
end;

procedure TfrmViewer.MirrorImage(AVertically:boolean);
var
  x, y: Integer;
  xWidth,
  yHeight: Integer;
  SourceImg: TLazIntfImage;
  TargetImg: TLazIntfImage;
begin
  TargetImg:= TLazIntfImage.Create(0, 0);
  SourceImg := TLazIntfImage.Create(TRasterImage(Image.Picture.Graphic).RawImage, False);
  TargetImg.DataDescription:= SourceImg.DataDescription; // use the same image format
  xWidth:= SourceImg.Width - 1;
  yHeight:= SourceImg.Height - 1;

  if not AVertically then
    for y:= 0 to yHeight do
    begin
      for x:= 0 to xWidth do
      begin
        TargetImg.Colors[x, y]:= SourceImg.Colors[xWidth - x, y];
      end;
    end
  else
    for y:= 0 to yHeight do
    begin
      for x:= 0 to xWidth do
      begin
        TargetImg.Colors[x, y]:= SourceImg.Colors[ x,yHeight - y];
      end;
    end;

  TRasterImage(Image.Picture.Graphic).LoadFromIntfImage(TargetImg);
  FreeAndNil(SourceImg);
  FreeAndNil(TargetImg);
  AdjustImageSize;
  CreateTmp;
end;

procedure TfrmViewer.SaveImageAs(var sExt: String; senderSave: boolean; Quality: integer);
var
  sFileName: String;
  fsFileStream: TFileStreamEx;
begin
  if senderSave then
  begin
    sExt:= LowerCase(sExt);
    sFileName:= FileList.Strings[iActiveFile];
  end
  else begin
    with SavePictureDialog do
    begin
      FileName:= EmptyStr;
      InitialDir:= ExtractFileDir(FileList.Strings[iActiveFile]);
      if not Execute then Exit;
      sExt:= ExtensionSeparator + GetFilterExt;
      sFileName:= ChangeFileExt(FileName, sExt);
    end;

    if (sExt = '.jpg') or (sExt = '.jpeg') then
    begin
      FModSizeDialog:= TfrmModView.Create(Self);
      try
        FModSizeDialog.pnlSize.Visible:= False;
        FModSizeDialog.pnlCopyMoveFile.Visible:= False;
        FModSizeDialog.pnlQuality.Visible:= True;
        FModSizeDialog.Caption:= SavePictureDialog.Title;
        if FModSizeDialog.ShowModal <> mrOk then Exit;
        Quality:= FModSizeDialog.teQuality.Value;
      finally
        FreeAndNil(FModSizeDialog);
      end;
    end;
  end;

  try
    fsFileStream:= TFileStreamEx.Create(sFileName, fmCreate);
    try
      if (sExt = '.jpg') or (sExt = '.jpeg') then
      begin
        with TJpegImage.Create do
        try
          // Special case
          if Image.Picture.Graphic is TJPEGImage then
          begin
            LoadFromRawImage(Image.Picture.Jpeg.RawImage, False);
          end
          else begin
            Assign(Image.Picture.Graphic);
          end;
          CompressionQuality := Quality;
          SaveToStream(fsFileStream);
        finally
          Free;
        end;
      end
      else if sExt = '.ico' then
      begin
        with TIcon.Create do
        try
          Assign(Image.Picture.Graphic);
          SaveToStream(fsFileStream);
        finally
          Free;
        end;
      end
      else begin
        Image.Picture.SaveToStreamWithFileExt(fsFileStream, sExt);
      end;
    finally
      FreeAndNil(fsFileStream);
    end;
  except
    on E: Exception do msgError(E.Message);
  end;
end;

procedure TfrmViewer.ImagePaintBackground(ASender: TObject; ACanvas: TCanvas;
  ARect: TRect);
const
  CELL_SIZE = 8;
var
  X, Y: Integer;
begin
  with gColors.Viewer^ do
  begin
    if ImageBackColor2 = clDefault then
      ACanvas.Brush.Color:= ContrastColor(sboxImage.Color, 30)
    else begin
      ACanvas.Brush.Color:= ImageBackColor2;
    end;
  end;

  for Y:= 0 to (ARect.Height div CELL_SIZE) + 1 do
  begin
    for X:= 0 to (ARect.Width div CELL_SIZE) + 1 do
    begin
      if Odd(X) <> Odd(Y) then
      begin
        ACanvas.FillRect(X * CELL_SIZE, Y * CELL_SIZE, (X + 1) * CELL_SIZE, (Y + 1) * CELL_SIZE);
      end;
    end;
  end;
end;

procedure TfrmViewer.miPluginsClick(Sender: TObject);
var
  ShowFlags: Integer;
  MenuItem: TMenuItem absolute Sender;
begin
  ExitPluginMode;
  ShowFlags:= PluginShowFlags or lcp_forceshow;

  if LoadPlugin(FFileName, MenuItem.Tag, ShowFlags) then
  begin
    ActivatePanel(nil);
  end
  else begin
    LoadFile(FFileName);
  end;
end;

procedure TfrmViewer.sboxImageMouseEnter(Sender: TObject);
begin
  if miFullScreen.Checked then TimerViewer.Enabled:=true;
end;

procedure TfrmViewer.sboxImageMouseLeave(Sender: TObject);
begin
  if miFullScreen.Checked then TimerViewer.Enabled:=false;
end;

procedure TfrmViewer.sboxImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if miFullScreen.Checked then
  begin
    sboxImage.Cursor:=crDefault;
    Image.Cursor:=crDefault;
    i_timer:=0;
  end;
end;

procedure TfrmViewer.UpdateAnimState;
begin
  btnPrevGifFrame.Enabled:= GifAnim.Paused and (GifAnim.CurrentFrameIndex > 0);
  btnNextGifFrame.Enabled:= GifAnim.Paused and (GifAnim.CurrentFrameIndex < GifAnim.FrameCount - 1);
end;

procedure TfrmViewer.btnPrevGifFrameClick(Sender: TObject);
begin
  GifAnim.PriorFrame;
  UpdateAnimState;
end;

procedure TfrmViewer.btnNextGifFrameClick(Sender: TObject);
begin
  GifAnim.NextFrame;
  UpdateAnimState;
end;

procedure TfrmViewer.sboxImageResize(Sender: TObject);
begin
  if bImage or bAnimation then AdjustImageSize;
end;

procedure TfrmViewer.SplitterChangeBounds;
begin
  DrawPreview.CalculateColRowCount;
  if bPlugin then FWlxModule.ResizeWindow(GetListerRect);
end;

procedure TfrmViewer.TimerReloadTimer(Sender: TObject);
var
  NewSize: Int64;
begin
  if ViewerControl.IsFileOpen then
  begin
    if ViewerControl.FileHandle <> 0 then
      NewSize:= FileGetSize(ViewerControl.FileHandle)
    else begin
      NewSize:= mbFileSize(ViewerControl.FileName);
    end;
    if (NewSize <> ViewerControl.FileSize) then
    begin
      Screen.BeginWaitCursor;
      try
        ViewerControl.FileName := ViewerControl.FileName;
        ViewerControl.Enabled := Self.Active;
        try
          ActivatePanel(pnlText);
        finally
          ViewerControl.Enabled := True;
        end;
        FLastSearchPos := -1;
        ViewerControl.GoEnd;
      finally
        Screen.EndWaitCursor;
      end;
    end;
  end;
end;

procedure TfrmViewer.TimerScreenshotTimer(Sender: TObject);
begin
  cm_Screenshot(['']);
  TimerScreenshot.Enabled:=False;
  Application.Restore;
  Self.BringToFront;
end;

procedure TfrmViewer.DrawPreviewSelection(Sender: TObject; aCol, aRow: Integer);
begin
  LoadNextFile(DrawPreview.Index);
end;

procedure TfrmViewer.DrawPreviewTopleftChanged(Sender: TObject);
begin
  DrawPreview.LeftCol:= 0;
end;

procedure TfrmViewer.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  TThumbThread.Finish(FThread);
end;

procedure TfrmViewer.TimerViewerTimer(Sender: TObject);
begin
  if (miFullScreen.Checked) then
  begin
    if (ToolBar1.Visible) and (i_timer > 60) and (not ToolBar1.MouseInClient) then
    begin
      ToolBar1.Visible:= False;
      AdjustImageSize;
    end
    else if (not ToolBar1.Visible) and (sboxImage.ScreenToClient(Mouse.CursorPos).Y < ToolBar1.Height div 2) then
    begin
      ToolBar1.Visible:= True;
      AdjustImageSize;
    end;
  end;
  Inc(i_timer);
  if (btnSlideShow.Down) and (i_timer = 60 * btnSlideShow.Tag) then
  begin
    if (ToolBar1.Visible) and (not ToolBar1.MouseInClient) then
    begin
      ToolBar1.Visible:= False;
      AdjustImageSize;
    end;
    cm_LoadNextFile([]);
    i_timer:= 0;
  end;
  if i_timer = 180 then
  begin
   sboxImage.Cursor:= crNone;
   Image.Cursor:= crNone;
  end;
end;

procedure TfrmViewer.tmUpdateFolderSizeTimer(Sender: TObject);
begin
  if Assigned(FFileSourceCalcStatisticsOperation) then
    with FFileSourceCalcStatisticsOperation.RetrieveStatistics do
    begin
      if Size < 0 then
        memFolder.Lines[2]:= Format(rsSpaceMsg, [Files, Directories, '???', '???'])
      else begin
        memFolder.Lines[2]:= Format(rsSpaceMsg, [Files, Directories, cnvFormatFileSize(Size), IntToStrTS(Size)]);
      end;
    end;
end;

procedure TfrmViewer.FileSourceOperationStateChangedNotify(
  Operation: TFileSourceOperation; State: TFileSourceOperationState);
begin
  if Assigned(FFileSourceCalcStatisticsOperation) and (State = fsosStopped) then
  begin
    tmUpdateFolderSize.Enabled:= False;
    tmUpdateFolderSizeTimer(tmUpdateFolderSize);
    FFileSourceCalcStatisticsOperation := nil;
  end;
end;

procedure TfrmViewer.ViewerControlMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    pmEditMenu.PopUp();
end;

procedure TfrmViewer.frmViewerClose(Sender: TObject;
                                    var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
  gImageStretch:= miStretch.Checked;
  gImageStretchOnlyLarge:= miStretchOnlyLarge.Checked;
  gImageShowTransparency:= actShowTransparency.Checked;
  gImageCenter:= miCenter.Checked;
  gPreviewVisible := miPreview.Checked;
  gImagePaintMode := TViewerPaintTool(btnPenMode.Tag);
  gImagePaintWidth := btnPenWidth.Tag;
  gImagePaintColor := btnPenColor.ButtonColor;
  case ViewerControl.Mode of
    vcmText: gViewerMode := 1;
    vcmWrap: gViewerMode := 1;
    vcmBin : gViewerMode := 2;
    vcmHex : gViewerMode := 3;
    vcmDec : gViewerMode := 6;
    vcmBook: gTextPosition := ViewerControl.Position;
  end;

  if Assigned(WlxPlugins) then ExitPluginMode;

{$IF NOT DEFINED(LCLWIN32)}
  if WindowState = wsFullScreen then WindowState:= wsNormal;
{$ENDIF}
end;

procedure TfrmViewer.UpdateImagePlacement;
begin
  if bPlugin then
    FWlxModule.CallListSendCommand(lc_newparams , PluginShowFlags)
  else if bImage then
  begin
    if btnHightlight.Down then
    begin
      btnPaint.Down:=false;
      btnHightlight.Down:=false;
      //gboxView.Visible:=true;
      UndoTmp;
    end;
    AdjustImageSize;
  end
  else if bAnimation then
  begin
    AdjustImageSize;
  end;
end;

procedure TfrmViewer.StartCalcFolderSize;
var
  aFile: TFile;
  aFiles: TFiles;
  AFileSource: IFileSource;
begin
  try
    aFile:= TFileSystemFileSource.CreateFileFromFile(memFolder.Lines[1]);
  except
    Exit;
  end;
  aFiles:= TFiles.Create(EmptyStr);
  try
    aFiles.Add(aFile);
    AFileSource:= TFileSystemFileSource.GetFileSource;
    FFileSourceCalcStatisticsOperation:= AFileSource.CreateCalcStatisticsOperation(aFiles) as TFileSourceCalcStatisticsOperation;
    if Assigned(FFileSourceCalcStatisticsOperation) then
    begin
      FFileSourceCalcStatisticsOperation.SkipErrors:= True;
      FFileSourceCalcStatisticsOperation.SymLinkOption:= fsooslDontFollow;
      FFileSourceCalcStatisticsOperation.AddStateChangedListener([fsosStopped], @FileSourceOperationStateChangedNotify);
      OperationsManager.AddOperation(FFileSourceCalcStatisticsOperation, False);
      tmUpdateFolderSize.Enabled:= True;
    end;
  finally
    aFiles.Free;
  end;
end;

procedure TfrmViewer.StopCalcFolderSize;
begin
  if Assigned(FFileSourceCalcStatisticsOperation) then
  begin
    tmUpdateFolderSize.Enabled:= False;
    FFileSourceCalcStatisticsOperation.RemoveStateChangedListener([fsosStopped], @FileSourceOperationStateChangedNotify);
    FFileSourceCalcStatisticsOperation.Stop;
  end;
  FFileSourceCalcStatisticsOperation:= nil;
end;

procedure TfrmViewer.FormCreate(Sender: TObject);
var
  Index: Integer;
  HMViewer: THMForm;
  MenuItem: TMenuItem;
begin
  if not bQuickView then
  begin
    with InitPropStorage(Self) do
      OnSavingProperties:= @SavingProperties;
  end
  else begin
    miDiv4.Visible:= False;
    actPreview.Enabled:= False;
    actPreview.Visible:= False;
    actScreenshot.Enabled:= False;
    actFullscreen.Enabled:= False;
    actScreenShotDelay3Sec.Enabled:= False;
    actScreenShotDelay5Sec.Enabled:= False;

    Status.PopupMenu:= pmStatusBar;
    MainMenu.Items.Remove(miView);
    MainMenu.Items.Remove(mnuPlugins);
    MainMenu.Items.Remove(miEncoding);
    MainMenu.Items.Remove(miImage);
    pmStatusBar.Items.Add(miView);
    pmStatusBar.Items.Add(mnuPlugins);
    pmStatusBar.Items.Add(miEncoding);
    pmStatusBar.Items.Add(miImage);
  end;
  actExitViewer.Enabled:= not bQuickView;

  HMViewer := HotMan.Register(Self, HotkeysCategory);
  HMViewer.RegisterActionList(actionList);

  ViewerControl.OnFileOpen:= @FileOpenUAC;
  ViewerControl.OnGuessEncoding:= @DetectEncoding;

  FontOptionsToFont(gFonts[dcfViewer], ViewerControl.Font);

  FileList := TStringList.Create;
  FileList.OwnsObjects:= True;

  WlxPlugins:=TWLXModuleList.Create;
  WlxPlugins.Assign(gWLXPlugins);

  FFindDialog:= nil; // dialog is created in first use

  sboxImage.DoubleBuffered := True;
  miStretch.Checked := gImageStretch;
  sboxImage.Color := gColors.Viewer^.ImageBackColor1;
  miStretchOnlyLarge.Checked := gImageStretchOnlyLarge;
  miCenter.Checked := gImageCenter;
  miPreview.Checked := gPreviewVisible;
  btnPenMode.Tag := Integer(gImagePaintMode);
  btnPenWidth.Tag := gImagePaintWidth;
  btnPenColor.ButtonColor := gImagePaintColor;

  if gImageShowTransparency then
  begin
    Image.OnPaintBackground:= @ImagePaintBackground;
    actShowTransparency.Checked := gImageShowTransparency;
  end;

  Image.Stretch:= True;
  Image.AutoSize:= False;
  Image.Proportional:= False;
  Image.SetBounds(0, 0, sboxImage.ClientWidth, sboxImage.ClientHeight);

  FThumbSize := gThumbSize;
  DrawPreview.DefaultColWidth := FThumbSize.cx + 4;
  DrawPreview.DefaultRowHeight := FThumbSize.cy + DrawPreview.Canvas.TextHeight('Pp') + 6;

  MakeTextEncodingsMenu;

  Status.Panels[sbpFileNr].Alignment := taRightJustify;
  Status.Panels[sbpPosition].Alignment := taRightJustify;
  Status.Panels[sbpFileSize].Alignment := taRightJustify;

  ViewerPositionChanged(Self);

  FixFormIcon(Handle);

  for Index:= 1 to 25 do
  begin
    MenuItem:= TMenuItem.Create(btnPenWidth);
    MenuItem.Caption:= IntToStr(Index);
    MenuItem.OnClick:= @miPaintClick;
    MenuItem.Tag:= Index;
    pmPenWidth.Items.Add(MenuItem);

    MenuItem:= TMenuItem.Create(btnSlideShow);
    MenuItem.Caption:= IntToStr(Index);
    MenuItem.OnClick:= @miPaintClick;
    MenuItem.Tag:= Index;
    pmTimeShow.Items.Add(MenuItem);
  end;

  // SynEdit
  FSearchOptions.Flags := [ssoEntireScope];

  HotMan.Register(pnlText ,'Text files');
  HotMan.Register(pnlImage,'Image files');

  SavePictureDialog.Filter:= GraphicFilter(TPortableNetworkGraphic) + '|' +
                             GraphicFilter(TBitmap) + '|' +
                             GraphicFilter(TJPEGImage) + '|' +
                             GraphicFilter(TIcon) + '|' +
                             GraphicFilter(TPortableAnyMapGraphic);

end;

procedure TfrmViewer.FormKeyPress(Sender: TObject; var Key: Char);
begin
  // The following keys work only in QuickView mode because there is no menu there.
  // Otherwise this function is never called for those keys
  // because the menu shortcuts are automatically used.
  if bQuickView then
    case Key of
      'N', 'n':
        begin
          cm_LoadNextFile([]);
          Key := #0;
        end;
      'P', 'p':
        begin
          cm_LoadPrevFile([]);
          Key := #0;
        end;
      '1':
        begin
          cm_ShowAsText(['']);
          Key := #0;
        end;
      '2':
        begin
          cm_ShowAsBin(['']);
          Key := #0;
        end;
      '3':
        begin
          cm_ShowAsHex(['']);
          Key := #0;
        end;
      '4':
        begin
          cm_ShowAsDec(['']);
          Key := #0;
        end;
      '6':
        begin
          cm_ShowGraphics(['']);
          Key := #0;
        end;
      '7':
        begin
          cm_ShowPlugins(['']);
          Key := #0;
        end;
      '8':
        begin
          cm_ShowOffice(['']);
          Key := #0;
        end;
    end;
end;

procedure TfrmViewer.btnCutTuImageClick(Sender: TObject);
begin
  CutToImage;
end;

procedure TfrmViewer.actExecute(Sender: TObject);
var
  cmd: string;
begin
  cmd := (Sender as TAction).Name;
  cmd := 'cm_' + Copy(cmd, 4, Length(cmd) - 3);
  Commands.ExecuteCommand(cmd, []);
end;

procedure TfrmViewer.btnFullScreenClick(Sender: TObject);
begin
  cm_Fullscreen(['']);
end;

procedure TfrmViewer.btnGifMoveClick(Sender: TObject);
begin
  if GifAnim.Paused then
    GifAnim.Start
  else begin
    GifAnim.Pause;
  end;
  if GifAnim.Paused then
    btnGifMove.ImageIndex:= 12
  else begin
    btnGifMove.ImageIndex:= 11
  end;
  UpdateAnimState;
end;

procedure TfrmViewer.btnGifToBmpClick(Sender: TObject);
begin
  GifAnim.Pause;
  btnGifMove.ImageIndex:= 12;
  Image.Picture.Bitmap:= GifAnim.CurrentView;
  cm_SaveAs(['']);
  UpdateAnimState;
end;

procedure TfrmViewer.btnPaintHightlight(Sender: TObject);
var
  bmp: TCustomBitmap = nil;
  GraphicClass: TGraphicClass;
  sExt: String;
  fsFileStream: TFileStreamEx = nil;
begin
  if not ImgEdit then
  begin
    try
      sExt:= ExtractFileExt(FileList.Strings[iActiveFile]);
      fsFileStream:= TFileStreamEx.Create(FileList.Strings[iActiveFile], fmOpenRead or fmShareDenyNone);
      GraphicClass := GetGraphicClassForFileExtension(sExt);
      if (GraphicClass <> nil) and (GraphicClass.InheritsFrom(TCustomBitmap)) then
        begin
          Image.DisableAutoSizing;
          bmp := TCustomBitmap(GraphicClass.Create);
          bmp.LoadFromStream(fsFileStream);
          Image.Picture.Bitmap := TBitmap.Create;
          Image.Picture.Bitmap.Height:= bmp.Height;
          Image.Picture.Bitmap.Width:= bmp.Width;
          Image.Picture.Bitmap.Canvas.Draw(0, 0, bmp);
          Image.EnableAutoSizing;
        end;
    finally
      FreeAndNil(bmp);
      FreeAndNil(fsFileStream);
    end;
    {miStretch.Checked:= False;
    Image.Stretch:= miStretch.Checked;
    Image.Proportional:= Image.Stretch;
    Image.Autosize:= not(miStretch.Checked);
    AdjustImageSize; }
  end;
  if Sender = btnHightlight then
    begin
      //btnHightlight.Down := not (btnHightlight.Down);
      btnPaint.Down:= False;
      if not btnHightlight.Down then UndoTmp;
    end
  else
    begin
      if btnHightlight.Down then UndoTmp;
     // btnPaint.Down:= not (btnPaint.Down);
      btnHightlight.Down:= False;
    end;
  btnCutTuImage.Enabled:= btnHightlight.Down;
  btnRedEye.Enabled:= btnHightlight.Down;
  actUndo.Enabled:= btnPaint.Down;
  btnPenMode.Enabled:= btnPaint.Down;
  btnPenWidth.Enabled:= btnPaint.Down;
  btnPenColor.Enabled:= btnPaint.Down;
  ImgEdit:= True;
  CreateTmp;
end;

procedure TfrmViewer.btnPenModeClick(Sender: TObject);
begin
  btnPenMode.Down:= not btnPenMode.Down;
end;

procedure TfrmViewer.btnRedEyeClick(Sender: TObject);
begin
  RedEyes;
end;

procedure TfrmViewer.btnResizeClick(Sender: TObject);
begin
  FModSizeDialog:= TfrmModView.Create(Self);
  try
    FModSizeDialog.pnlQuality.Visible:=false;
    FModSizeDialog.pnlCopyMoveFile.Visible :=false;
    FModSizeDialog.pnlSize.Visible:=true;
    FModSizeDialog.teHeight.Text:= IntToStr(Image.Picture.Bitmap.Height);
    FModSizeDialog.teWidth.Text := IntToStr(Image.Picture.Bitmap.Width);
    FModSizeDialog.Caption:= rsViewNewSize;
    if FModSizeDialog.ShowModal = mrOk then
    begin
      Res(StrToInt(FModSizeDialog.teWidth.Text), StrToInt(FModSizeDialog.teHeight.Text));
      AdjustImageSize;
    end;
  finally
    FreeAndNil(FModSizeDialog);
  end;
end;

procedure TfrmViewer.btnSlideShowClick(Sender: TObject);
begin
  btnSlideShow.Down:= not btnSlideShow.Down;
end;

procedure TfrmViewer.FormDestroy(Sender: TObject);
begin
  if Assigned(HotMan) then
  begin
    HotMan.UnRegister(pnlText);
    HotMan.UnRegister(pnlImage);
  end;

  FreeAndNil(FFindDialog);
  HotMan.UnRegister(Self);
end;

procedure TfrmViewer.miPaintClick(Sender: TObject);
var
  MenuItem: TMenuItem absolute Sender;
begin
  MenuItem.Owner.Tag:= MenuItem.Tag;
  TToolButton(MenuItem.Owner).Caption:= MenuItem.Caption;
end;

procedure TfrmViewer.ReopenAsTextIfNeeded;
begin
  if bImage or bAnimation or bPlugin or miPlugins.Checked or miOffice.Checked or miCode.Checked then
  begin
    Image.Picture := nil;
    ViewerControl.FileName := FileList.Strings[iActiveFile];
    ActivatePanel(pnlText);
  end;
end;

procedure TfrmViewer.UpdatePluginsMenu;
var
  I: Integer;
begin
  for I:= mnuPlugins.Count - 1 downto 0 do
  begin
    if mnuPlugins.Items[I].Tag = ActivePlugin then
    begin
      mnuPlugins.Items[I].Checked:= True;
      Exit;
    end;
  end;
end;

procedure TfrmViewer.MakePluginsMenu;
var
  I, J: Integer;
  MenuItem: TMenuItem;
  WlxModule: TWlxModule;
begin
  J:= 1;
  mnuPlugins.Clear;

  MenuItem:= TMenuItem.Create(mnuPlugins);
  MenuItem.Caption:= rsDlgButtonNone;
  MenuItem.RadioItem:= True;
  MenuItem.Enabled:= False;
  MenuItem.Checked:= True;
  MenuItem.GroupIndex:= 2;
  MenuItem.Tag:= -1;
  mnuPlugins.Add(MenuItem);

  for I:= 0 to WlxPlugins.Count - 1 do
  begin
    WlxModule:= WlxPlugins.GetWlxModule(I);
    if not WlxModule.Enabled then Continue;

    MenuItem:= TMenuItem.Create(mnuPlugins);
    MenuItem.RadioItem:= True;
    MenuItem.GroupIndex:= 2;
    MenuItem.Tag:= I;

    MenuItem.OnClick:= @miPluginsClick;
    MenuItem.Caption:= ExtractOnlyFileName(WlxModule.FileName);

    if WlxModule.FileParamVSDetectStr(FFileName, True) then
    begin
      mnuPlugins.Insert(J, MenuItem);
      Inc(J);
    end
    else begin
      mnuPlugins.Add(MenuItem);
    end;
    if ActivePlugin = I then
    begin
      MenuItem.Checked:= True;
    end;
  end;
  if (J > 1) and (J < mnuPlugins.Count) then
  begin
    MenuItem:= TMenuItem.Create(mnuPlugins);
    MenuItem.Caption:= '-';
    mnuPlugins.Insert(J, MenuItem);
  end;
  mnuPlugins.Visible:= (mnuPlugins.Count > 1);
end;

procedure TfrmViewer.miChangeEncodingClick(Sender: TObject);
begin
  cm_ChangeEncoding([(Sender as TMenuItem).Caption]);
end;

procedure TfrmViewer.SynEditStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  Status.Panels[sbpPosition].Text:= Format('%d:%d', [SynEdit.CaretX, SynEdit.CaretY]);
end;

procedure TfrmViewer.SynEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (not gShowCaret) and (Key in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_LEFT, VK_RIGHT]) then
  begin
    case Key of
      VK_UP:    SynEdit.Perform(WM_VSCROLL, SB_LINEUP, 0);
      VK_DOWN:  SynEdit.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
      VK_PRIOR: SynEdit.Perform(WM_VSCROLL, SB_PAGEUP, 0);
      VK_NEXT:  SynEdit.Perform(WM_VSCROLL, SB_PAGEDOWN, 0);
      VK_LEFT:  SynEdit.Perform(WM_HSCROLL, SB_LINELEFT, 0);
      VK_RIGHT: SynEdit.Perform(WM_HSCROLL, SB_LINERIGHT, 0);
    end;
    Key:= 0;
  end;
end;

procedure TfrmViewer.SynEditMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  inc: Integer;
begin
  if WheelDelta = 0 then
    Exit;

  if gZoomWithCtrlWheel and (Shift = [ssCtrl]) then
  begin
    if WheelDelta > 0 then
      inc:= 1
    else
      inc:= -1;
    self.DoZoom( 1, inc );
  end;
end;

procedure TfrmViewer.ViewerControlMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if gZoomWithCtrlWheel and (Shift=[ssCtrl]) then begin
    if self.DoZoomOut then
      Handled:= True;
  end;
end;

procedure TfrmViewer.ViewerControlMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if gZoomWithCtrlWheel and (Shift=[ssCtrl]) then begin
    if self.DoZoomIn then
      Handled:= True;
  end;
end;

function TfrmViewer.CheckGraphics(const sFileName:String):Boolean;
var
  sExt: String;
begin
  sExt:= LowerCase(ExtractFileExt(sFileName));
  Result:= Image.Picture.FindGraphicClassWithFileExt(sExt, False) <> nil;
end;

// Adjust Image size (width and height) to sboxImage size
procedure TfrmViewer.AdjustImageSize;
const
  fmtImageInfo = '%dx%d (%.0f %%)';
var
  AControl: TControl;
  ImgWidth, ImgHeight : Integer;
  iLeft, iTop, iWidth, iHeight : Integer;
begin
  if not (bImage or bAnimation) then
    Exit;

  if bImage then
  begin
    if (Image.Picture = nil) then Exit;
    ImgHeight:= Image.Picture.Height;
    ImgWidth:= Image.Picture.Width;
    AControl:= Image;
  end
  else if (bAnimation) then
  begin
    if GifAnim.CurrentView = nil then Exit;
    ImgHeight:= GifAnim.CurrentView.Height;
    ImgWidth:= GifAnim.CurrentView.Width;
    AControl:= GifAnim;
  end;

  if (ImgWidth = 0) or (ImgHeight = 0) then Exit;

  FScaleFactor:= FZoomFactor / 100;

  // Place and resize image
  if (FZoomFactor = 100) and (miStretch.Checked or miStretchOnlyLarge.Checked) then
  begin
    FScaleFactor:= Min(sboxImage.ClientWidth / ImgWidth, sboxImage.ClientHeight / ImgHeight);
    FScaleFactor:= IfThen((miStretchOnlyLarge.Checked) and (FScaleFactor > 1.0), 1.0, FScaleFactor);
  end;

  iWidth:= Trunc(ImgWidth * FScaleFactor);
  iHeight:= Trunc(ImgHeight * FScaleFactor);
  if (miCenter.Checked) then
  begin
    iLeft:= (sboxImage.ClientWidth - iWidth) div 2;
    iTop:= (sboxImage.ClientHeight - iHeight) div 2;
  end
  else
  begin
    iLeft:= 0;
    iTop:= 0;
  end;
  AControl.SetBounds(Max(iLeft,0), Max(iTop,0), iWidth , iHeight);

  // Update scrollbars
  // TODO: fix - calculations are correct but it seems like scroll bars
  // are being updated only after a second call to Form.Resize
  if sboxImage.HandleAllocated then
  begin
    if (iLeft < 0) then
      sboxImage.HorzScrollBar.Position:= -iLeft;
    if (iTop < 0) then
      sboxImage.VertScrollBar.Position:= -iTop;
  end;

  // Update status bar
  Status.Panels[sbpCurrentResolution].Text:= Format(fmtImageInfo, [iWidth, iHeight,  100.0 * FScaleFactor]);
  Status.Panels[sbpFullResolution].Text:= Format(fmtImageInfo, [ImgWidth, ImgHeight, 100.0]);
end;

function TfrmViewer.GetListerRect: TRect;
begin
  Result:= ClientRect;
  Dec(Result.Bottom, Status.Height);
  if Splitter.Visible then
  begin
    Inc(Result.Left, Splitter.Left + Splitter.Width);
  end;
end;

function TfrmViewer.CheckOffice(const sFileName: String): Boolean;
var
  AText: String;
begin
  Result:= OfficeMask.Matches(sFileName) and LoadFromOffice(sFileName, AText);
  if Result then
  begin
    ViewerControl.Text:= AText;
    ViewerControl.Mode:= WRAP_MODE[gViewerWrapText];
    ViewerControl.Encoding:= veUtf8;
  end;
end;

function TfrmViewer.CheckSynEdit(const sFileName: String; bForce: Boolean = False): Boolean;
var
  AFile: TFile;
  ATemplate: TSearchTemplate;
begin
  if bForce then
    Result:= True
  else if (Length(gViewerSynEditMask) = 0) then
    Result:= False
  else if not IsMaskSearchTemplate(gViewerSynEditMask) then
  begin
    Result:= MatchesMaskList(sFileName, gViewerSynEditMask);
  end
  else
  try
    ATemplate:= gSearchTemplateList.TemplateByName[gViewerSynEditMask];
    if (ATemplate = nil) then
      Result:= False
    else begin
      AFile:= TFileSystemFileSource.CreateFileFromFile(sFileName);
      try
        Result:= ATemplate.CheckFile(AFile);
      finally
        AFile.Free;
      end;
    end;
  except
    Exit(False);
  end;

  if Result and not bForce then
  begin
    if (mbFileSize(sFileName) > (gMaxCodeSize * $100000)) then
      Exit(False);
  end;

  if Result then
  begin
    FHighlighter:= GetHighlighterFromFileExt(dmHighl.SynHighlighterList, ExtractFileExt(sFileName));
    Result:= Assigned(FHighlighter);
  end;

  if Result and not bForce then
  begin
    PushPop(FElevate);
    try
      Result:= mbFileIsText(sFileName);
    finally
      PushPop(FElevate);
    end;
  end;
end;

function TfrmViewer.LoadGraphics(const sFileName:String): Boolean;

  procedure UpdateToolbar(bImage: Boolean);
  begin
    btnHightlight.Enabled:= bImage and (not miFullScreen.Checked);
    btnPaint.Enabled:= bImage and (not miFullScreen.Checked);
    btnResize.Enabled:= bImage and (not miFullScreen.Checked);
    btnZoomIn.Enabled:= bImage;
    btnZoomOut.Enabled:= bImage;
    btn270.Enabled:= bImage;
    btn90.Enabled:= bImage;
    btnMirror.Enabled:= bImage;
    btnZoomSeparator.Enabled:= bImage;
    btnGifMove.Enabled:= not bImage;
    btnGifToBmp.Enabled:= not bImage;
    btnGifSeparator.Enabled:= not bImage;
    btnNextGifFrame.Enabled:= not bImage;
    btnPrevGifFrame.Enabled:= not bImage;
  end;

var
  sExt: String;
  fsFileStream: TFileStreamEx;
begin
  Result:= True;
  FZoomFactor:= 100;
  sExt:= ExtractOnlyFileExt(sFilename);
  if not SameText(sExt, 'gif') then
  begin
      Image.Visible:= True;
      GifAnim.Visible:= False;
      try
        fsFileStream:= TFileStreamEx.Create(sFileName, fmOpenRead or fmShareDenyNone);
        try
          Image.Picture.LoadFromStreamWithFileExt(fsFileStream, sExt);
{$IF DEFINED(LCLGTK2)}
          // TImage crash on displaying monochrome bitmap on Linux/GTK2
          // https://doublecmd.sourceforge.io/mantisbt/view.php?id=2474
          // http://bugs.freepascal.org/view.php?id=12362
          if Image.Picture.Graphic is TRasterImage then
          begin
            if TRasterImage(Image.Picture.Graphic).RawImage.Description.BitsPerPixel = 1 then
            begin
              BitmapConvert(TRasterImage(Image.Picture.Graphic));
            end;
          end;
{$ENDIF}
          bImage:= True;
          bAnimation:= False;
          UpdateToolbar(True);
        finally
          FreeAndNil(fsFileStream);
        end;
        if gImageExifRotate and SameText(sExt, 'jpg') then
        begin
          if FExif.LoadFromFile(sFileName) then
          begin
            case FExif.Orientation of
              2: cm_MirrorHorz([]);
              3: cm_Rotate180([]);
              4: cm_MirrorVert([]);
              6: cm_Rotate90([]);
              8: cm_Rotate270([]);
            end;
          end;
        end;
        AdjustImageSize;
      except
        on E: Exception do
        begin
          DCDebug(E.Message);
          Exit(False);
        end;
      end;
    end
  else
    begin
      GifAnim.Visible:= True;
      Image.Visible:= False;
      try
        fsFileStream:= TFileStreamEx.Create(sFileName, fmOpenRead or fmShareDenyNone);
        try
          GifAnim.LoadFromStream(fsFileStream);
          bImage:= False;
          bAnimation:= True;
          UpdateToolbar(False);
          AdjustImageSize;
          GifAnim.Start;
          UpdateAnimState;
        finally
          fsFileStream.Free;
        end;
      except
        on E: Exception do
        begin
          DCDebug(E.Message);
          Exit(False);
        end;
      end;
    end;
  ImgEdit:= False;
end;

function TfrmViewer.LoadSynEdit(const sFileName: String): Boolean;
var
  Index: Integer;
  sEncoding: String;
  Buffer: AnsiString;
  Reader: TFileStreamUAC;
begin
  if (SynEdit = nil) then
  begin
    SynEdit:= TSynEdit.Create(pnlCode);
    SynEdit.Parent:= pnlCode;
    SynEdit.Align:= alClient;
    SynEdit.ReadOnly:= True;
    SynEdit.PopupMenu:= pmEditMenu;
    with SynEdit.Gutter.SeparatorPart() do
    begin
      MarkupInfo.Background:= clWindow;
      MarkupInfo.Foreground:= clGrayText;
    end;
    with SynEdit.Gutter.LineNumberPart() do
    begin
      MarkupInfo.Background:= clBtnFace;
      MarkupInfo.Foreground:= clBtnText;
    end;
{$if lcl_fullversion >= 4990000}
    if gViewerWrapText then begin
      FSynEditWrap:= TLazSynEditLineWrapPlugin.Create(SynEdit);
    end;
{$endif}
    SynEdit.Options:= gEditorSynEditOptions;
    SynEdit.TabWidth := gEditorSynEditTabWidth;
    SynEdit.RightEdge := gEditorSynEditRightEdge;
    FontOptionsToFont(gFonts[dcfViewer], SynEdit.Font);
    SynEdit.OnKeyDown:= @SynEditKeyDown;
    SynEdit.OnMouseWheel:= @SynEditMouseWheel;
    SynEdit.OnStatusChange:= @SynEditStatusChange;
    SynEditCaret;
  end;
  dmHighl.SetHighlighter(SynEdit, FHighlighter);

  PushPop(FElevate);
  try
    Result := False;
    try
      Reader := TFileStreamUAC.Create(sFileName, fmOpenRead or fmShareDenyNone);
      try
        SetLength(FSynEditOriginalText, Reader.Size);
        Reader.Read(Pointer(FSynEditOriginalText)^, Length(FSynEditOriginalText));
      finally
        Reader.Free;
      end;

      Status.Panels[sbpTextEncoding].Text:= EmptyStr;
      // Try to detect encoding by first 4 kb of text
      Buffer := Copy(FSynEditOriginalText, 1, 4096);
      sEncoding := NormalizeEncoding(DetectEncoding(Buffer));

      for Index:= 0 to miEncoding.Count - 1 do
      begin
        if SameStr(miEncoding.Items[Index].Hint, sEncoding) then
        begin
          miEncoding.Items[Index].Checked:= True;
          Status.Panels[sbpTextEncoding].Text := rsViewEncoding + ': ' + miEncoding.Items[Index].Caption;
          Break;
        end;
      end;

      // Convert encoding if needed
      if sEncoding = EncodingUTF8 then
        Buffer := FSynEditOriginalText
      else begin
        if (sEncoding = EncodingUTF16LE) or (sEncoding = EncodingUTF16BE) then
        begin
          FSynEditOriginalText := Copy(FSynEditOriginalText, 3, MaxInt); // Skip BOM
        end;
        Buffer := ConvertEncoding(FSynEditOriginalText, sEncoding, EncodingUTF8);
      end;

      // Load text into editor
      SynEdit.Lines.Text := Buffer;

      // Add empty line if needed
      if (Length(Buffer) > 0) and (Buffer[Length(Buffer)] in [#10, #13]) then
        SynEdit.Lines.Add(EmptyStr);

      Result := True;
    except
      // Ignore
    end;
  finally
    PushPop(FElevate);
  end;
end;

function TfrmViewer.LoadPlugin(const sFileName: String; Index,
  ShowFlags: Integer): Boolean;
var
  WlxModule: TWlxModule;
begin
  if not WlxPlugins.LoadModule(Index) then
    Exit(False);
  WlxModule:= WlxPlugins.GetWlxModule(Index);
  WlxModule.QuickView:= bQuickView;
  if WlxModule.CallListLoad(Self.Handle, sFileName, ShowFlags) = 0 then
  begin
    WlxModule.UnloadModule;
    Exit(False);
  end;
  ActivePlugin:= Index;
  FWlxModule:= WlxModule;
  WlxModule.ResizeWindow(GetListerRect);
  EnablePrint(WlxModule.CanPrint);
  // Set focus to plugin window
  if not bQuickView then WlxModule.SetFocus;
  UpdatePluginsMenu;
  Result:= True;
end;

procedure TfrmViewer.DoSearchCode(bQuickSearch: Boolean;
  bSearchBackwards: Boolean);
var
  Index: Integer;
  Options: TTextSearchOptions;
begin
  for Index:= 0 to glsSearchHistory.Count - 1 do
  begin
    Options:= TTextSearchOptions(UInt32(UIntPtr(glsSearchHistory.Objects[Index])));

    if (tsoHex in Options) then
      Continue;

    if (tsoMatchCase in Options) then
      FSearchOptions.Flags += [ssoMatchCase];
    if (tsoRegExpr in Options) then
      FSearchOptions.Flags += [ssoRegExpr];

    FSearchOptions.SearchText:= glsSearchHistory[Index];
    Break;
  end;

  if (bQuickSearch and gFirstTextSearch) or (not bQuickSearch) then
  begin
    if bQuickSearch then
    begin
      if bSearchBackwards then
        FSearchOptions.Flags += [ssoBackwards]
      else begin
        FSearchOptions.Flags -= [ssoBackwards];
      end;
    end;
    ShowSearchReplaceDialog(Self, SynEdit, cbGrayed, FSearchOptions);
  end
  else begin
    if bSearchBackwards then
    begin
     SynEdit.SelEnd := SynEdit.SelStart;
    end;
    DoSearchReplaceText(SynEdit, False, bSearchBackwards, FSearchOptions);
    FSearchOptions.Flags -= [ssoEntireScope];
  end;
end;

procedure TfrmViewer.DoSearch(bQuickSearch: Boolean; bSearchBackwards: Boolean);
const
  bNewSearch: Boolean = False;
var
  T: QWord;
  PAdr: PtrInt;
  PAnsiAddr: PByte;
  bTextFound: Boolean;
  sSearchTextU: String;
  sSearchTextA: AnsiString;
  RecodeTable: TRecodeTable;
  Options: TTextSearchOptions;
  iSearchParameter: Integer = 0;
begin
  // in first use create dialog
  if not Assigned(FFindDialog) then
     FFindDialog:= TfrmFindView.Create(Self);

  if glsSearchHistory.Count > 0 then
  begin
    Options:= TTextSearchOptions(UInt32(UIntPtr(glsSearchHistory.Objects[0])));
    if (tsoMatchCase in Options) then
      FFindDialog.cbCaseSens.Checked:= True;
    if (tsoRegExpr in Options) then
      FFindDialog.cbRegExp.Checked:= True;
    if (tsoHex in Options) then
      FFindDialog.chkHex.Checked:= True;
  end;

  if (bQuickSearch and gFirstTextSearch) or (not bQuickSearch) or (bPlugin and FFindDialog.chkHex.Checked) then
    begin
      if bPlugin then
      begin
        FFindDialog.chkHex.Checked:= False;
        // if plugin has specific search dialog
        if FWlxModule.CallListSearchDialog(0) = LISTPLUGIN_OK then
          Exit;
        iSearchParameter:= iSearchParameter or lcs_findfirst;
      end;

      FFindDialog.chkHex.Visible:= not bPlugin;
      FFindDialog.cbRegExp.Visible:= (not bPlugin) and
                                     (ViewerControl.FileSize < High(IntPtr)) and
                                     (
                                       (ViewerControl.Encoding = veUtf16le) or
                                       (not (ViewerControl.Encoding in ViewerEncodingMultiByte)) or
                                       (TRegExprU.Available and (ViewerControl.Encoding in [veUtf8, veUtf8bom]))
                                     );
      if not FFindDialog.cbRegExp.Visible then FFindDialog.cbRegExp.Checked:= False;
      if FFindDialog.cbRegExp.Checked then bSearchBackwards:= False;
      FFindDialog.cbBackwards.Checked:= bSearchBackwards;
      // Load search history
      FFindDialog.cbDataToFind.Items.Assign(glsSearchHistory);
      sSearchTextU:= ViewerControl.Selection;
      if Length(sSearchTextU) > 0 then
        FFindDialog.cbDataToFind.Text:= sSearchTextU;

      if FFindDialog.ShowModal <> mrOK then Exit;

      if FFindDialog.cbDataToFind.Text = '' then Exit;
      sSearchTextU:= FFindDialog.cbDataToFind.Text;
      bSearchBackwards:= FFindDialog.cbBackwards.Checked;
      // Save search history
      glsSearchHistory.Assign(FFindDialog.cbDataToFind.Items);
      gFirstTextSearch:= False;
    end
  else
    begin
      if bPlugin then
      begin
        // if plugin has specific search dialog
        if FWlxModule.CallListSearchDialog(1) = LISTPLUGIN_OK then
          Exit;
      end;
      if glsSearchHistory.Count > 0 then
        sSearchTextU:= glsSearchHistory[0];
      FFindDialog.cbBackwards.Checked:= bSearchBackwards;
    end;

  if FFindDialog.cbRegExp.Checked then
  begin
    FRegExp.SetInputString(ViewerControl.GetDataAdr, ViewerControl.FileSize)
  end;

  if bPlugin then
  begin
    if bSearchBackwards then iSearchParameter:= iSearchParameter or lcs_backwards;
    if FFindDialog.cbCaseSens.Checked then iSearchParameter:= iSearchParameter or lcs_matchcase;
    FWlxModule.CallListSearchText(sSearchTextU, iSearchParameter);
  end
  else if ViewerControl.IsFileOpen then
  begin
    T:= GetTickCount64;

    if bSearchBackwards and FFindDialog.cbRegExp.Checked then
    begin
      msgError(rsMsgErrNotSupported);
      Exit;
    end;

    if not FFindDialog.cbRegExp.Checked then
    begin
      if not FFindDialog.chkHex.Checked then
        sSearchTextA:= ViewerControl.ConvertFromUTF8(sSearchTextU)
      else try
        sSearchTextA:= HexToBin(sSearchTextU);
      except
        on E: EConvertError do
        begin
          msgError(E.Message);
          Exit;
        end;
      end;
    end;

    // Choose search start position.
    if FLastSearchPos <> ViewerControl.CaretPos then
    begin
      FLastMatchLength := 0;
      FLastSearchPos := ViewerControl.CaretPos
    end
    else if FFindDialog.cbRegExp.Checked then
    begin
      if bNewSearch then
      begin
        FLastSearchPos := 0;
        FLastMatchLength := 0;
      end;
    end
    else if not bSearchBackwards then
    begin
      iSearchParameter:= Length(sSearchTextA);
      if bNewSearch then
        FLastSearchPos := 0
      else if FLastSearchPos < ViewerControl.FileSize - iSearchParameter then
        FLastSearchPos := FLastSearchPos + iSearchParameter;
    end
    else begin
      iSearchParameter:= IfThen(ViewerControl.Encoding in ViewerEncodingDoubleByte, 2, 1);
      if bNewSearch then
        FLastSearchPos := ViewerControl.FileSize - 1
      else if FLastSearchPos >= iSearchParameter then
        FLastSearchPos := FLastSearchPos - iSearchParameter;
    end;
    bNewSearch := False;

    if FFindDialog.cbRegExp.Checked then
    begin
      FRegExp.ModifierI:= not FFindDialog.cbCaseSens.Checked;
      try
        FRegExp.Expression:= sSearchTextU;
        bTextFound:= FRegExp.Exec(FLastSearchPos + FLastMatchLength + 1);
      except
        on E: Exception do
        begin
          msgError(StripHotkey(FFindDialog.cbRegExp.Caption) + ': ' + E.Message);
          Exit;
        end;
      end;
      if bTextFound then
      begin
        FLastMatchLength:= FRegExp.MatchLen[0];
        FLastSearchPos:= FRegExp.MatchPos[0] - 1;
      end;
    end
    else begin
      // Using standard search algorithm if hex or case sensitive and multibyte
      if FFindDialog.chkHex.Checked or (FFindDialog.cbCaseSens.Checked and (ViewerControl.Encoding in ViewerEncodingMultiByte)) then
      begin
        PAnsiAddr := PosMem(ViewerControl.GetDataAdr, ViewerControl.FileSize,
                            FLastSearchPos, sSearchTextA,
                            FFindDialog.cbCaseSens.Checked, bSearchBackwards);
        bTextFound := (PAnsiAddr <> Pointer(-1));
        if bTextFound then FLastSearchPos := PAnsiAddr - ViewerControl.GetDataAdr;
      end
      // Using special case insensitive UTF-8 search algorithm
      else if (ViewerControl.Encoding in [veUtf8, veUtf8bom]) then
      begin
        PAnsiAddr := PosMemU(ViewerControl.GetDataAdr, ViewerControl.FileSize,
                             FLastSearchPos, sSearchTextA, bSearchBackwards);
        bTextFound := (PAnsiAddr <> Pointer(-1));
        if bTextFound then FLastSearchPos := PAnsiAddr - ViewerControl.GetDataAdr;
      end
      // Using special case insensitive UTF-16 search algorithm
      else if (ViewerControl.Encoding in [veUtf16le, veUtf16be, veUcs2le, veUcs2be]) then
      begin
        PAnsiAddr := PosMemW(ViewerControl.GetDataAdr, ViewerControl.FileSize,
                             FLastSearchPos, sSearchTextA, bSearchBackwards,
                             ViewerControl.Encoding in [veUtf16le, veUcs2le]);
        bTextFound := (PAnsiAddr <> Pointer(-1));
        if bTextFound then FLastSearchPos := PAnsiAddr - ViewerControl.GetDataAdr;
      end
      // Using very slow search algorithm
      else if (ViewerControl.Encoding in [veUtf32le, veUtf32be]) then
      begin
        PAdr := ViewerControl.FindUtf8Text(FLastSearchPos, sSearchTextU,
                                           FFindDialog.cbCaseSens.Checked,
                                           bSearchBackwards);
        bTextFound := (PAdr <> PtrInt(-1));
        if bTextFound then FLastSearchPos := PAdr;
      end
      // Using special case insensitive single byte encoding search algorithm
      else if bSearchBackwards then
      begin
        RecodeTable:= InitRecodeTable(ViewerControl.EncodingName, FFindDialog.cbCaseSens.Checked);
        PAnsiAddr := PosMemA(ViewerControl.GetDataAdr, ViewerControl.FileSize,
                            FLastSearchPos, sSearchTextA,
                            FFindDialog.cbCaseSens.Checked, bSearchBackwards, RecodeTable);
        bTextFound := (PAnsiAddr <> Pointer(-1));
        if bTextFound then FLastSearchPos := PAnsiAddr - ViewerControl.GetDataAdr;
      end
      // Using very fast Boyer–Moore search algorithm
      else begin
        RecodeTable:= InitRecodeTable(ViewerControl.EncodingName, FFindDialog.cbCaseSens.Checked);
        PAdr := PosMemBoyerMur(ViewerControl.GetDataAdr + FLastSearchPos,
                               ViewerControl.FileSize - FLastSearchPos, sSearchTextA, RecodeTable);
        bTextFound := (PAdr <> PtrInt(-1));
        if bTextFound then FLastSearchPos := PAdr + FLastSearchPos;
      end;
      FLastMatchLength:= Length(sSearchTextA);
    end;

    if bTextFound then
      begin
        DCDebug('Search time: ' + IntToStr(GetTickCount64 - T));
        // Text found, show it in ViewerControl if not visible
        ViewerControl.MakeVisible(FLastSearchPos);
        // Select found text.
        ViewerControl.CaretPos := FLastSearchPos;
        ViewerControl.SelectText(FLastSearchPos, FLastSearchPos + FLastMatchLength);
      end
    else
      begin
        msgOK(Format(rsViewNotFound, ['"' + sSearchTextU + '"']));
        if (ViewerControl.Selection <> sSearchTextU) then begin
          ViewerControl.SelectText(0, 0);
        end;
        bNewSearch := True;
        FLastMatchLength := 0;
        FLastSearchPos := ViewerControl.CaretPos;
      end;
    end;
end;

procedure TfrmViewer.MakeTextEncodingsMenu;
var
  I: Integer;
  mi: TMenuItem;
  EncodingsList: TStringList;
begin
  miEncoding.Clear;
  EncodingsList := TStringList.Create;
  try
    ViewerControl.GetSupportedEncodings(EncodingsList);
    for I:= 0 to EncodingsList.Count - 1 do
      begin
        mi:= TMenuItem.Create(miEncoding);
        mi.Caption:= EncodingsList[I];
        mi.Hint:= NormalizeEncoding(mi.Caption);
        mi.AutoCheck:= True;
        mi.RadioItem:= True;
        mi.GroupIndex:= 1;
        mi.Tag:= I;
        mi.OnClick:= @miChangeEncodingClick;
        if ViewerControl.EncodingName = EncodingsList[I] then
          mi.Checked := True;
        miEncoding.Add(mi);
      end;
  finally
    FreeAndNil(EncodingsList);
  end;
end;

procedure TfrmViewer.UpdateTextEncodingsMenu(AType: TEncodingMenu);
var
  I: Integer;
  Encoding: TViewerEncoding;
begin
  if AType = emViewer then
  begin
    for I:= 0 to miEncoding.Count - 1 do
    begin
      miEncoding.Items[I].Visible:= True;
    end;
  end
  else if AType = emEditor then
  begin
    for I:= 0 to miEncoding.Count - 1 do
    begin
      Encoding:= TViewerEncoding(I);
      miEncoding.Items[I].Visible:= not (Encoding in [veAutoDetect, veUcs2le, veUcs2be, veUtf32le, veUtf32be]);
    end;
  end
  else begin
    for I:= 0 to miEncoding.Count - 1 do
    begin
      Encoding:= TViewerEncoding(I);
      miEncoding.Items[I].Visible:= Encoding in [veAutoDetect, veAnsi, veOem];
    end;
  end;
end;

procedure TfrmViewer.ViewerPositionChanged(Sender:TObject);
begin
  if ViewerControl.FileSize > 0 then
    begin
      Status.Panels[sbpPosition].Text :=
          cnvFormatFileSize(ViewerControl.Position) +
          ' (' + IntToStr(ViewerControl.Percent) + ' %)';
    end
  else
    Status.Panels[sbpPosition].Text:= cnvFormatFileSize(0) + ' (0 %)';
end;

procedure TfrmViewer.ActivatePanel(Panel: TPanel);
begin
  bPlugin    := (Panel = nil);
  bAnimation := (Panel = pnlImage) and (GifAnim.Visible);
  bImage     := (Panel = pnlImage) and (bAnimation = False);

  if Panel <> pnlText then pnlText.Hide;
  if Panel <> pnlCode then pnlCode.Hide;
  if Panel <> pnlImage then pnlImage.Hide;
  if Panel <> pnlFolder then pnlFolder.Hide;

  if Assigned(Panel) then Panel.Visible := True;

  if Panel = nil then
  begin
    Status.Panels[sbpFileSize].Text:= EmptyStr;
    Status.Panels[sbpPluginName].Text:= FWlxModule.Name;

    UpdateTextEncodingsMenu(emPlugin);
    Status.Panels[sbpTextEncoding].Text := rsViewEncoding + ': ' + ViewerControl.EncodingName;
  end
  else if Panel = pnlCode then
  begin
    miCode.Checked:= True;
    UpdateTextEncodingsMenu(emEditor);

    if (not bQuickView) and CanFocus and SynEdit.CanFocus then
       SynEdit.SetFocus;

    Status.Panels[sbpFileSize].Text:= IntToStr(SynEdit.Lines.Count);
  end
  else if Panel = pnlText then
  begin
    if (not bQuickView) and CanFocus and ViewerControl.CanFocus then
       ViewerControl.SetFocus;

    case ViewerControl.Mode of
      vcmText: miText.Checked := True;
      vcmWrap: miText.Checked := True;
      vcmBin:  miBin.Checked := True;
      vcmHex:  miHex.Checked := True;
      vcmDec:  miDec.Checked := True;
      vcmBook: miLookBook.Checked := True;
    end;

    UpdateTextEncodingsMenu(emViewer);
    FRegExp.ChangeEncoding(ViewerControl.EncodingName);
    Status.Panels[sbpFileSize].Text:= cnvFormatFileSize(ViewerControl.FileSize) + ' (100 %)';
    Status.Panels[sbpTextEncoding].Text := rsViewEncoding + ': ' + ViewerControl.EncodingName;
  end
  else if Panel = pnlImage then
  begin
    pnlImage.TabStop:= True;
    Status.Panels[sbpTextEncoding].Text:= EmptyStr;
    if (not bQuickView) and CanFocus and pnlImage.CanFocus then pnlImage.SetFocus;
    ToolBar1.Visible:= not (bQuickView or (miFullScreen.Checked and not ToolBar1.MouseInClient));
  end;

  miPlugins.Checked    := (Panel = nil);
  miGraphics.Checked   := (Panel = pnlImage);
  miEncoding.Visible   := (Panel = pnlText) or (Panel = pnlCode) or (bPlugin and FWlxModule.CanCommand);
  miAutoReload.Visible := (Panel = pnlText);
  miImage.Visible      := (bImage or bAnimation or (bPlugin and FWlxModule.CanCommand));
  miRotate.Visible     := bImage;
  miZoomIn.Visible     := bImage;
  miZoomOut.Visible    := bImage;
  miFullScreen.Visible := (bImage and not bQuickView);
  miScreenshot.Visible := (bImage and not bQuickView);
  miSave.Visible       := bImage;
  actSave.Enabled      := bImage;
  miSaveAs.Visible     := bImage;
  actSaveAs.Enabled    := bImage;

  miShowTransparency.Visible := bImage;

  actGotoLine.Enabled  := (Panel = pnlCode);
  actShowCaret.Enabled := (Panel = pnlText) or (Panel = pnlCode);
  actWrapText.Enabled  := (bPlugin and FWlxModule.CanCommand) or ((Panel = pnlText) and (ViewerControl.Mode in [vcmText, vcmWrap]))
{$if lcl_fullversion >= 4990000}
    or (Panel = pnlCode);
{$endif}
  ;

  miGotoLine.Visible       := (Panel = pnlCode);
  miDiv5.Visible           := (Panel = pnlText) or (Panel = pnlCode);
  pmiSelectAll.Visible     := (Panel = pnlText) or (Panel = pnlCode);
  pmiCopyFormatted.Visible := (Panel = pnlText);

  EnableCopy((Panel = pnlText) or (Panel = pnlCode) or (bPlugin and FWlxModule.CanCommand));
  EnableSearch((Panel = pnlText) or (Panel = pnlCode) or (bPlugin and FWlxModule.CanSearch));

  miDiv3.Visible:= actFind.Visible and actCopyToClipboard.Visible;

  miEdit.Visible:= (actFind.Visible or actCopyToClipboard.Visible);

  if (Panel <> pnlText) and actAutoReload.Checked then
    cm_AutoReload([]);

  StopCalcFolderSize;
end;

procedure TfrmViewer.cm_About(const Params: array of string);
begin
  MsgOK(rsViewAboutText);
end;

procedure TfrmViewer.cm_Reload(const Params: array of string);
begin
  ExitPluginMode;
  LoadFile(iActiveFile);
end;

procedure TfrmViewer.cm_AutoReload(const Params: array of string);
begin
  actAutoReload.Checked := not actAutoReload.Checked;
  if actAutoReload.Checked then ViewerControl.GoEnd;
  TimerReload.Enabled := actAutoReload.Checked;
  FileName:= FFileName;
end;

procedure TfrmViewer.cm_LoadNextFile(const Params: array of string);
var
  Index : Integer;
begin
  if not bQuickView then
  begin
    Index:= iActiveFile + 1;
    if Index >= FileList.Count then
      Index:= 0;

    LoadNextFile(Index);
  end;
end;

procedure TfrmViewer.cm_LoadPrevFile(const Params: array of string);
var
  Index: Integer;
begin
  if not bQuickView then
  begin
    Index:= iActiveFile - 1;
    if Index < 0 then
      Index:= FileList.Count - 1;

    LoadNextFile(Index);
  end;
end;

procedure TfrmViewer.cm_MoveFile(const Params: array of string);
begin
  if actMoveFile.Enabled then CopyMoveFile(vcmaMove);
end;

procedure TfrmViewer.cm_CopyFile(const Params: array of string);
begin
  if actCopyFile.Enabled then CopyMoveFile(vcmaCopy);
end;

procedure TfrmViewer.cm_DeleteFile(const Params: array of string);
begin
  if actDeleteFile.Enabled and msgYesNo(Format(rsMsgDelSel, [FileList.Strings[iActiveFile]])) then
  begin
    DeleteCurrentFile;
  end;
end;

procedure TfrmViewer.cm_StretchImage(const Params: array of string);
begin
  miStretch.Checked:= not miStretch.Checked;
  if miStretch.Checked then
  begin
    FZoomFactor:= 100;
    miStretchOnlyLarge.Checked:= False
  end;
  UpdateImagePlacement;
end;

procedure TfrmViewer.cm_StretchOnlyLarge(const Params: array of string);
begin
  miStretchOnlyLarge.Checked:= not miStretchOnlyLarge.Checked;
  if miStretchOnlyLarge.Checked then miStretch.Checked:= False;
  UpdateImagePlacement;
end;

procedure TfrmViewer.cm_ShowTransparency(const Params: array of string);
begin
  gImageShowTransparency:= not gImageShowTransparency;
  actShowTransparency.Checked:= gImageShowTransparency;
  if actShowTransparency.Checked then
    Image.OnPaintBackground:= @ImagePaintBackground
  else begin
    Image.OnPaintBackground:= nil;
  end;
  Image.Repaint;
end;

procedure TfrmViewer.cm_Save(const Params: array of string);
var
  sExt: String;
begin
  if actSave.Enabled then
  begin
    DrawPreview.BeginUpdate;
    try
      CreatePreview(FileList.Strings[iActiveFile], iActiveFile, True);
      sExt:= ExtractFileExt(FileList.Strings[iActiveFile]);
      SaveImageAs(sExt, True, gViewerJpegQuality);
      CreatePreview(FileList.Strings[iActiveFile], iActiveFile);
    finally
      DrawPreview.EndUpdate;
    end;
  end;
end;

procedure TfrmViewer.cm_Undo(const Params: array of string);
begin
  if bImage then UndoTmp;
end;

procedure TfrmViewer.cm_SaveAs(const Params: array of string);
var
  sExt: String;
begin
  if bAnimation or bImage then
  begin
    sExt:= EmptyStr;
    SaveImageAs(sExt, False, gViewerJpegQuality);
  end;
end;

procedure TfrmViewer.cm_Rotate90(const Params: array of string);
begin
  if bImage then RotateImage(90);
end;

procedure TfrmViewer.cm_Rotate180(const Params: array of string);
begin
  if bImage then RotateImage(180);
end;

procedure TfrmViewer.cm_Rotate270(const Params: array of string);
begin
  if bImage then RotateImage(270);
end;

procedure TfrmViewer.cm_MirrorHorz(const Params: array of string);
begin
  if bImage then MirrorImage;
end;

procedure TfrmViewer.cm_MirrorVert(const Params: array of string);
begin
  if bImage then MirrorImage(True);
end;

procedure TfrmViewer.cm_ImageCenter(const Params: array of string);
begin
   miCenter.Checked:= not miCenter.Checked;
   UpdateImagePlacement;
end;

procedure TfrmViewer.cm_Zoom(const Params: array of string);
begin
  if miGraphics.Checked then
  try
    ZoomImage(StrToFloat(Params[0]));
  except
    // Exit
  end;
end;

procedure TfrmViewer.cm_ZoomIn(const Params: array of string);
begin
  self.DoZoomIn;
end;

procedure TfrmViewer.cm_ZoomOut(const Params: array of string);
begin
  self.DoZoomOut;
end;

procedure TfrmViewer.cm_Fullscreen(const Params: array of string);
begin
  miFullScreen.Checked:= not (miFullScreen.Checked);
  if miFullScreen.Checked then
    begin
      FWindowState:= WindowState;
{$IF DEFINED(LCLWIN32)}
      FWindowBounds.Top:= Top;
      FWindowBounds.Left:= Left;
      FWindowBounds.Right:= Width;
      FWindowBounds.Bottom:= Height;
      BorderStyle:= bsNone;
{$ENDIF}
      WindowState:= wsFullScreen;
      Self.Menu:= nil;
      btnPaint.Down:= false;
      btnHightlight.Down:=false;
      ToolBar1.Visible:= False;
      miStretch.Checked:= True;
      miStretchOnlyLarge.Checked:= False;
      if miPreview.Checked then cm_Preview(['']);
      actFullscreen.ImageIndex:= 25;
      sboxImage.BorderStyle:= bsNone;
    end
  else
    begin
      Self.Menu:= MainMenu;
{$IFDEF LCLGTK2}
      WindowState:= wsFullScreen;
{$ENDIF}
      WindowState:= FWindowState;
{$IF DEFINED(LCLWIN32)}
      BorderStyle:= bsSizeable;
      SetBounds(FWindowBounds.Left, FWindowBounds.Top, FWindowBounds.Right, FWindowBounds.Bottom);
{$ENDIF}
      ToolBar1.Visible:= True;
      actFullscreen.ImageIndex:= 22;
      sboxImage.BorderStyle:= bsSingle;
    end;
  if ExtractOnlyFileExt(FileList.Strings[iActiveFile]) <> 'gif' then
  begin
    btnHightlight.Enabled:= not (miFullScreen.Checked);
    btnPaint.Enabled:= not (miFullScreen.Checked);
    btnResize.Enabled:= not (miFullScreen.Checked);
  end;
  sboxImage.HorzScrollBar.Visible:= not(miFullScreen.Checked);
  sboxImage.VertScrollBar.Visible:= not(miFullScreen.Checked);
  TimerViewer.Enabled:=miFullScreen.Checked;
  btnReload.Enabled:=not(miFullScreen.Checked);
  Status.Visible:=not(miFullScreen.Checked);
  btnSlideShow.Visible:=miFullScreen.Checked;
  AdjustImageSize;
  ShowOnTop;
end;

procedure TfrmViewer.cm_Screenshot(const Params: array of string);
var
  ScreenDC: HDC;
  bmp: TCustomBitmap;
begin
  Visible:= False;
  Application.ProcessMessages; // Hide viewer window
  bmp := TBitmap.Create;
  ScreenDC := GetDC(0);
  bmp.LoadFromDevice(ScreenDC);
  ReleaseDC(0, ScreenDC);
  Image.Picture.Bitmap.Height:= bmp.Height;
  Image.Picture.Bitmap.Width:= bmp.Width;
  Image.Picture.Bitmap.Canvas.Draw(0, 0, bmp);
  CreateTmp;
  bmp.Free;
  Visible:= True;
  ImgEdit:= True;
end;

procedure TfrmViewer.cm_ScreenshotWithDelay(const Params: array of string);
var
  i:integer;
begin
  i:=StrToInt(Params[0]);
  i:=i*1000;
  TimerScreenshot.Interval:=i;
  TimerScreenshot.Enabled:=True;
end;

procedure TfrmViewer.cm_ScreenshotDelay3sec(const Params: array of string);
begin
  cm_ScreenshotWithDelay(['3']);
end;

procedure TfrmViewer.cm_ScreenshotDelay5sec(const Params: array of string);
begin
  cm_ScreenshotWithDelay(['5']);
end;

procedure TfrmViewer.cm_ChangeEncoding(const Params: array of string);
var
  Encoding: String;
  MenuItem: TMenuItem;
begin
  if miEncoding.Visible and (Length(Params) > 0) then
  begin
    MenuItem:= miEncoding.Find(Params[0]);
    if Assigned(MenuItem) then
    begin
      MenuItem.Checked := True;
      Encoding:= NormalizeEncoding(Params[0]);
      if miCode.Checked then
      begin
        SynEdit.Lines.Text:= ConvertEncoding(FSynEditOriginalText, Encoding, EncodingUTF8);
        Status.Panels[sbpTextEncoding].Text := rsViewEncoding + ': ' + MenuItem.Caption;
      end
      else begin
        if bPlugin then
        begin
          if (Encoding = EncodingAnsi) then
            FPluginEncoding:= lcp_ansi
          else if (Encoding = EncodingOem) then
            FPluginEncoding:= lcp_ascii
          else begin
            FPluginEncoding:= 0;
          end;
          FWlxModule.CallListSendCommand(lc_newparams, PluginShowFlags);
        end;
        FRegExp.ChangeEncoding(Encoding);
        ViewerControl.EncodingName := Encoding;
        Status.Panels[sbpTextEncoding].Text := rsViewEncoding + ': ' + ViewerControl.EncodingName;
      end;
    end;
  end;
end;

procedure TfrmViewer.cm_CopyToClipboard(const Params: array of string);
begin
  if miCode.Checked then
    SynEdit.CopyToClipboard
  else if bPlugin then
   FWlxModule.CallListSendCommand(lc_copy, 0)
  else begin
    if (miGraphics.Checked)and(Image.Picture<>nil)and(Image.Picture.Bitmap<>nil)then
    begin
      if not bAnimation then
        Clipboard.Assign(Image.Picture)
      else
        Clipboard.Assign(GifAnim.CurrentView);
    end else
       ViewerControl.CopyToClipboard;
  end;
end;

procedure TfrmViewer.cm_CopyToClipboardFormatted(const Params: array of string);
begin
  if ViewerControl.Mode in [vcmHex, vcmDec] then ViewerControl.CopyToClipboardF;
end;

procedure TfrmViewer.cm_SelectAll(const Params: array of string);
begin
  if miCode.Checked then
    SynEdit.SelectAll
  else if bPlugin then
    FWlxModule.CallListSendCommand(lc_selectall, 0)
  else begin
    ViewerControl.SelectAll;
  end;
end;

procedure TfrmViewer.cm_Find(const Params: array of string);
var
  bSearchBackwards: Boolean;
begin
  if miCode.Checked then
  begin
    DoSearchCode(False, ssoBackwards in FSearchOptions.Flags);
  end
  else if not miGraphics.Checked then
  begin
    if (FFindDialog = nil) then
      bSearchBackwards:= False
    else begin
      bSearchBackwards:= FFindDialog.cbBackwards.Checked;
    end;
    DoSearch(False, bSearchBackwards);
  end;
end;

procedure TfrmViewer.cm_FindNext(const Params: array of string);
begin
  if miCode.Checked then
  begin
    DoSearchCode(True, False);
  end
  else if not miGraphics.Checked then
  begin
    DoSearch(True, False);
  end;
end;

procedure TfrmViewer.cm_FindPrev(const Params: array of string);
begin
  if miCode.Checked then
  begin
    DoSearchCode(True, True);
  end
  else if not miGraphics.Checked then
  begin
    DoSearch(True, True);
  end;
end;

procedure TfrmViewer.cm_GotoLine(const Params: array of string);
var
  P: TPoint;
  Value: String;
  NewTopLine: Integer;
begin
  if ShowInputQuery(rsEditGotoLineTitle, rsEditGotoLineQuery, Value) then
  begin
    P.X := 1;
    P.Y := StrToIntDef(Value, 1);
    NewTopLine := P.Y - (SynEdit.LinesInWindow div 2);
    if NewTopLine < 1 then NewTopLine:= 1;
    SynEdit.CaretXY := P;
    SynEdit.TopLine := NewTopLine;
    SynEdit.SetFocus;
  end;
end;

procedure TfrmViewer.cm_Preview(const Params: array of string);
begin
  if not actPreview.Enabled then Exit;

  miPreview.Checked:= not (miPreview.Checked);
  pnlPreview.Visible := miPreview.Checked;
  Splitter.Visible := pnlPreview.Visible;

  if miPreview.Checked then
    FThread:= TThumbThread.Create(Self)
  else begin
    TThumbThread.Finish(FThread);
  end;

  if bPlugin then FWlxModule.ResizeWindow(GetListerRect);
end;

procedure TfrmViewer.cm_ShowAsText(const Params: array of string);
begin
  ShowTextViewer(WRAP_MODE[gViewerWrapText]);
end;

procedure TfrmViewer.cm_ShowAsBin(const Params: array of string);
begin
  ShowTextViewer(vcmBin);
end;

procedure TfrmViewer.cm_ShowAsHex(const Params: array of string);
begin
  ShowTextViewer(vcmHex);
end;

procedure TfrmViewer.cm_ShowAsDec(const Params: array of string);
begin
  ShowTextViewer(vcmDec);
end;

procedure TfrmViewer.cm_ShowAsWrapText(const Params: array of string);
begin
  gViewerWrapText:= True;
  actWrapText.Checked:= True;
  ShowTextViewer(vcmWrap);
end;

procedure TfrmViewer.cm_ShowAsBook(const Params: array of string);
begin
  ShowTextViewer(vcmBook);
end;

procedure TfrmViewer.cm_ShowGraphics(const Params: array of string);
begin
  if CheckGraphics(FileList.Strings[iActiveFile]) then
  begin
    ExitPluginMode;
    ViewerControl.FileName := ''; // unload current file if any is loaded
    if LoadGraphics(FileList.Strings[iActiveFile]) then
      ActivatePanel(pnlImage)
    else
      begin
        ViewerControl.FileName := FileList.Strings[iActiveFile];
        ActivatePanel(pnlText);
      end;
  end;
end;

procedure TfrmViewer.cm_ShowPlugins(const Params: array of string);
var
  Index: Integer;
begin
  Index := ActivePlugin;
  ExitPluginMode;
  ActivePlugin := Index;
  bPlugin:= CheckPlugins(FileList.Strings[iActiveFile], True);
  if bPlugin then
  begin
    ViewerControl.FileName := ''; // unload current file if any is loaded
    ActivatePanel(nil);
  end;
end;

procedure TfrmViewer.cm_ShowOffice(const Params: array of string);
begin
  if CheckOffice(FileList.Strings[iActiveFile]) then
  begin
    ExitPluginMode;
    ActivatePanel(pnlText);
    miOffice.Checked:= True;
  end;
end;

procedure TfrmViewer.cm_ShowCode(const Params: array of string);
begin
  if CheckSynEdit(FileList.Strings[iActiveFile], True) then
  begin
    ExitPluginMode;
    ViewerControl.FileName := ''; // unload current file if any is loaded
    if LoadSynEdit(FileList.Strings[iActiveFile]) then
      ActivatePanel(pnlCode)
    else begin
      ViewerControl.FileName := FileList.Strings[iActiveFile];
      ActivatePanel(pnlText);
    end;
  end;
end;

procedure TfrmViewer.cm_ExitViewer(const Params: array of string);
begin
  if not bQuickView then Close;
end;

procedure TfrmViewer.cm_Print(const Params: array of string);
begin
  if bPlugin and actPrint.Enabled then
    FWlxModule.CallListPrint(ExtractFileName(FileList.Strings[iActiveFile]), '', 0, gPrintMargins);
end;

procedure TfrmViewer.cm_PrintSetup(const Params: array of string);
begin
  if bPlugin and actPrintSetup.Enabled then
  begin
    with TfrmPrintSetup.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
  end;
end;

procedure TfrmViewer.cm_ShowCaret(const Params: array of string);
begin
  if not miGraphics.Checked then
  begin
    gShowCaret:= not gShowCaret;
    actShowCaret.Checked:= gShowCaret;
    ViewerControl.ShowCaret:= gShowCaret;
    if Assigned(SynEdit) then SynEditCaret;
  end;
end;

procedure TfrmViewer.cm_WrapText(const Params: array of string);
{$if lcl_fullversion >= 4990000}
var
  TopLine: Integer;
{$endif}
begin
  gViewerWrapText:= not gViewerWrapText;
  actWrapText.Checked:= gViewerWrapText;

  if bPlugin then
    FWlxModule.CallListSendCommand(lc_newparams, PluginShowFlags)
  else if not miGraphics.Checked then
  begin
{$if lcl_fullversion >= 4990000}
    if miCode.Checked then
    begin
      TopLine:= SynEdit.TopLine;
      if gViewerWrapText then
        FSynEditWrap:= TLazSynEditLineWrapPlugin.Create(SynEdit)
      else begin
        FreeAndNil(FSynEditWrap);
      end;
      SynEdit.TopLine:= TopLine;
    end
    else
{$endif}
    if ViewerControl.Mode in [vcmText, vcmWrap] then
    begin
      ViewerControl.Mode:= WRAP_MODE[gViewerWrapText];
    end;
  end;
end;

initialization
  TFormCommands.RegisterCommandsForm(TfrmViewer, HotkeysCategory, @rsHotkeyCategoryViewer);

end.

