#include once "MainFormWndProc.bi"
#include once "win\windowsx.bi"
#include once "crt.bi"
#include once "DisplayError.bi"
#include once "GameModel.bi"
#include once "InputHandler.bi"
#include once "Resources.RH"
#include once "Scene.bi"
#include once "Settings.bi"
#include once "Stage.bi"

Const ANIMATION_TIMER_ID As UINT_PTR = 1
Const ANIMATION_TIMER_INTERVAL As UINT = 1000

Type UpdateContext
	hWin As HWND
End Type

Dim Shared pScene As Scene Ptr
Dim Shared pStage As Stage Ptr
Dim Shared pModel As GameModel Ptr
Dim Shared pHandler As InputHandler Ptr

Sub ColorLinesStageChanged( _
		ByVal pContext As Any Ptr, _
		ByVal pCoordinates As POINT Ptr, _
		ByVal Count As Integer _
	)
	
	Dim pUpdateContext As UpdateContext Ptr = CPtr(UpdateContext Ptr, pContext)
	
	SceneRender( _
		pScene, _
		pStage _
	)
	
	For i As Integer = 0 To Count - 1
		Dim ScreenRectangle As RECT = Any
		SceneTranslateBounds( _
			pScene, _
			@pStage->Lines(pCoordinates[i].y, pCoordinates[i].x).Bounds, _
			@pStage->Lines(pCoordinates[i].y, pCoordinates[i].x).PositionMatrix, _
			@ScreenRectangle _
		)
		
		InvalidateRect(pUpdateContext->hWin, @ScreenRectangle, FALSE)
	Next
	
End Sub

Sub ColorLinesTabloChanged( _
		ByVal pContext As Any Ptr _
	)
	
	Dim pUpdateContext As UpdateContext Ptr = CPtr(UpdateContext Ptr, pContext)
	
	SceneRender( _
		pScene, _
		pStage _
	)
	
	For i As Integer = 0 To 2
		Dim ScreenRectangle As RECT = Any
		SceneTranslateBounds( _
			pScene, _
			@pStage->Tablo(i).Bounds, _
			@pStage->Tablo(i).PositionMatrix, _
			@ScreenRectangle _
		)
		
		InvalidateRect(pUpdateContext->hWin, @ScreenRectangle, FALSE)
	Next
	
End Sub

Sub ColorLinesMovedBallChanged( _
		ByVal pContext As Any Ptr _
	)
End Sub

Sub ColorLinesScoreChanged( _
		ByVal pContext As Any Ptr, _
		ByVal Added As Integer _
	)
	
	Dim pUpdateContext As UpdateContext Ptr = CPtr(UpdateContext Ptr, pContext)
	
	SceneRender( _
		pScene, _
		pStage _
	)
	
	InvalidateRect(pUpdateContext->hWin, NULL, FALSE)
	
End Sub

Sub ColorLinesHiScoreChanged( _
		ByVal pContext As Any Ptr, _
		ByVal Added As Integer _
	)
	
End Sub

Sub ColorLinesStageAnimated( _
		ByVal pContext As Any Ptr _
	)
	
	Dim pUpdateContext As UpdateContext Ptr = CPtr(UpdateContext Ptr, pContext)
	
	SetTimer( _
		pUpdateContext->hWin, _
		ANIMATION_TIMER_ID, _
		ANIMATION_TIMER_INTERVAL, _
		NULL _
	)
	
End Sub

Sub ColorLinesPathNotExist( _
		ByVal pContext As Any Ptr _
	)
	
	MessageBeep(&hFFFFFFFF)
	
End Sub

Sub MoveSceneToCenterCoordinate( _
	)
	
	Dim rcStage As RECT = Any
	StageGetBounds(pStage, @rcStage)
	
	Dim StageWidth As Long = rcStage.right + (-1 * rcStage.left)
	Dim StageHeight As Long = rcStage.bottom + (-1 * rcStage.top)
	
	Dim dx As Integer = -1 * (StageWidth \ 2)
	Dim dy As Integer = -1 * (StageHeight \ 2)
	
	SceneTranslate(pScene, CSng(dx), CSng(dy))
	
End Sub

Sub SetSceneIsotropicExtent( _
		ByVal HorizontalExtent As Integer, _
		ByVal VerticalExtent As Integer _
	)
	
	Dim rcStage As RECT = Any
	StageGetBounds(pStage, @rcStage)
	
	Dim StageWidth As Long = rcStage.right + (-1 * rcStage.left)
	Dim StageHeight As Long = rcStage.bottom + (-1 * rcStage.top)
	
	Dim fAspectX As Single = max(1.0, CSng(HorizontalExtent) / CSng(StageWidth))
	Dim fAspectY As Single = max(1.0, CSng(VerticalExtent) / CSng(StageHeight))
	Dim fIsotropicAspect As Single = min(fAspectX, fAspectY)
	
	SceneScale(pScene, fIsotropicAspect, fIsotropicAspect)
	
End Sub

Sub SetSceneViewportOrg( _
		ByVal x As Integer, _
		ByVal y As Integer _
	)
	
	SceneTranslate(pScene, CSng(x), CSng(y))
	
End Sub

Function MainFormWndProc(ByVal hWin As HWND, ByVal wMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
	
	Select Case wMsg
		
		Case WM_CREATE
			Dim HiScore As Integer = SettingsGetHiScore()
			pStage = CreateStage(HiScore)
			If pStage = NULL Then
				Return -1
			End If
			
			Dim ScreenWidth As Long = GetSystemMetrics(SM_CXSCREEN)
			Dim ScreenHeight As Long = GetSystemMetrics(SM_CYSCREEN)
			pScene = CreateScene(hWin, ScreenWidth, ScreenHeight)
			If pScene = NULL Then
				Return -1
			End If
			
			Dim pContext As UpdateContext Ptr = Allocate(SizeOf(UpdateContext))
			If pContext = NULL Then
				Return -1
			End If
			pContext->hWin = hWin
			
			Dim Events As StageEvents = Any
			Events.OnLinesChanged = @ColorLinesStageChanged
			Events.OnTabloChanged = @ColorLinesTabloChanged
			Events.OnMovedBallChanged = @ColorLinesMovedBallChanged
			Events.OnScoreChanged = @ColorLinesScoreChanged
			Events.OnHiScoreChanged = @ColorLinesHiScoreChanged
			Events.OnAnimated = @ColorLinesStageAnimated
			Events.OnPathNotExist = @ColorLinesPathNotExist
			
			pModel = CreateGameModel(pStage, @Events, pContext)
			If pModel = NULL Then
				Return -1
			End If
			
			pHandler = CreateInputHandler( _
				pStage, _
				pScene, _
				pModel _
			)
			If pHandler = NULL Then
				Return -1
			End If
			
			/'
			EnableMenuItem(
				HMENU hmenu,
				UINT idItem, 
				UINT uEnable = MF_ENABLED или MF_GRAYED
			)
			'/
			
		Case WM_SIZE
			If wParam <> SIZE_MINIMIZED Then
				Dim ClientAreaWidth As UINT = LOWORD(lParam)
				Dim ClientAreaHeight As UINT = HIWORD(lParam)
				Dim SceneHorizontalExtent As Integer = ClientAreaWidth
				Dim SceneVerticalExtent As Integer = ClientAreaHeight
				
				SceneLoadIdentity(pScene)
				MoveSceneToCenterCoordinate()
				SetSceneIsotropicExtent(SceneHorizontalExtent, SceneVerticalExtent)
				Dim dx As Integer = ClientAreaWidth \ 2
				Dim dy As Integer = ClientAreaHeight \ 2
				SetSceneViewportOrg(dx, dy)
				
				SceneRender(pScene, pStage)
				
			End If
			
		Case WM_COMMAND
			Select Case HiWord(wParam)
				
				Case 0
					
					Select Case LoWord(wParam)
						
						Case IDM_GAME_NEW
							GameModelNewGame(pModel)
							
						Case IDM_GAME_UNDO
							' GameModelCommand(pModel, MenuCommands.Undo)
							
						Case IDM_GAME_REDO
							' GameModelCommand(pModel, MenuCommands.Redo)
							
						' Case IDM_GAME_STATISTICS
							' MainFormMenuStatistics_Click(hWin)
							
						' Case IDM_GAME_SETTINGS
							'
							
						Case IDM_GAME_EXIT
							DestroyWindow(hWin)
							
						' Case IDM_HELP_CONTENTS
							' MainFormMenuHelpContents_Click(hWin)
							
						' Case IDM_HELP_ABOUT
							' MainFormMenuHelpAbout_Click(hWin)
							
					End Select
					
				Case 1
					
					Select Case LoWord(wParam)
						
						Case IDM_GAME_NEW_ACS
							GameModelNewGame(pModel)
							
						Case IDM_GAME_UNDO_ACS
							' GameModelCommand(pModel, MenuCommands.Undo)
							
						Case IDM_GAME_REDO_ACS
							' GameModelCommand(pModel, MenuCommands.Redo)
							
						' Case IDM_GAME_STATISTICS_ACS
							' MainFormMenuStatistics_Click(hWin)
							
						' Case IDM_GAME_SETTINGS_ACS
							'
							
					End Select
					
				' Case Else ' Ёлемент управлени€
					
					
			End Select
			
		Case WM_ERASEBKGND
			Return TRUE
			
		Case WM_PAINT
			Dim ps As PAINTSTRUCT = Any
			Dim hDC As HDC = BeginPaint(hWin, @ps)
			SceneCopyRectangle(pScene, hDC, @ps.rcPaint)
			EndPaint(hWin, @ps)
			
		Case WM_DESTROY
			If pHandler <> NULL Then
				DestroyInputHandler(pHandler)
			End If
			If pModel <> NULL Then
				DestroyGameModel(pModel)
			End If
			If pScene <> NULL Then
				DestroyScene(pScene)
			End If
			If pStage <> NULL Then
				SettingsSetHiScore(pStage->HiScore)
				DestroyStage(pStage)
			End If
			PostQuitMessage(0)
			
		Case WM_LBUTTONDOWN
			SetCapture(hWin)
			Dim pt As POINT = Any
			pt.x = GET_X_LPARAM(lParam)
			pt.y = GET_Y_LPARAM(lParam)
			Dim pICommand As ICommand Ptr = Any
			Dim hr As HRESULT = InputHandlerLMouseDown(pHandler, @pt, @pICommand)
			If SUCCEEDED(hr) Then
				ICommand_Execute(pICommand)
			End If
			
		Case WM_LBUTTONUP
			ReleaseCapture()
			Dim pt As POINT = Any
			pt.x = GET_X_LPARAM(lParam)
			pt.y = GET_Y_LPARAM(lParam)
			Dim pICommand As ICommand Ptr = Any
			Dim hr As HRESULT = InputHandlerLMouseUp(pHandler, @pt, @pICommand)
			If SUCCEEDED(hr) Then
				ICommand_Execute(pICommand)
			End If
			
		Case WM_KEYDOWN
			Dim pICommand As ICommand Ptr = Any
			Dim hr As HRESULT = InputHandlerKeyDown(pHandler, wParam, @pICommand)
			If SUCCEEDED(hr) Then
				ICommand_Execute(pICommand)
			End If
			
		Case WM_KEYUP
			Dim pICommand As ICommand Ptr = Any
			Dim hr As HRESULT = InputHandlerKeyUp(pHandler, wParam, @pICommand)
			If SUCCEEDED(hr) Then
				ICommand_Execute(pICommand)
			End If
			
		Case WM_TIMER
			Select Case wParam
				
				Case ANIMATION_TIMER_ID
					Dim AnimationNeeded As Boolean = GameModelUpdate(pModel)
					If AnimationNeeded = False Then
						KillTimer(hWin, ANIMATION_TIMER_ID)
					End If
					
			End Select
			
		Case Else
			Return DefWindowProc(hWin, wMsg, wParam, lParam)
			
	End Select
	
	Return 0
	
End Function
