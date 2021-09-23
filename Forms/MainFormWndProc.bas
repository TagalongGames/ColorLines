#include once "MainFormWndProc.bi"
#include once "win\windowsx.bi"
#include once "crt.bi"
#include once "DisplayError.bi"
#include once "GameModel.bi"
#include once "GdiMatrix.bi"
#include once "Resources.RH"
#include once "Scene.bi"
#include once "Stage.bi"

Const ANIMATION_TIMER_ID As UINT_PTR = 1
Const ANIMATION_TIMER_INTERVAL As UINT = 1000

Type UpdateContext
	hWin As HWND
End Type

Dim Shared pScene As Scene Ptr
Dim Shared pStage As Stage Ptr

Function ColorLinesStageRenderFunction( _
		ByVal Context As Any Ptr, _
		ByVal pRenderRectangles As RECT Ptr, _
		ByVal Count As Integer _
	)As Integer
	
	Dim pUpdateContext As UpdateContext Ptr = CPtr(UpdateContext Ptr, Context)
	
	SceneRender( _
		pScene, _
		pStage _
	)
	
	For i As Integer = 0 To Count - 1
		Dim ScreenRectangle As RECT = Any
		SceneTranslateRectangle( _
			pScene, _
			pStage, _
			@pRenderRectangles[i], _
			@ScreenRectangle _
		)
		
		/'
		Dim buffer As WString * (512 + 1) = Any
		Const ffFormat = WStr("{%d, %d, %d, %d} = {%d, %d, %d, %d}")
		swprintf(@buffer, @ffFormat, pRenderRectangles[i].left, pRenderRectangles[i].top, pRenderRectangles[i].right, pRenderRectangles[i].bottom, ScreenRectangle.left, ScreenRectangle.top, ScreenRectangle.right, ScreenRectangle.bottom)
		buffer[255] = 0
		MessageBoxW(NULL, @buffer, NULL, MB_OK)
		'/
		
		InvalidateRect(pUpdateContext->hWin, @ScreenRectangle, FALSE)
	Next
	
	Return 0
	
End Function

Function ColorLinesStageAnimateFunction( _
		ByVal Context As Any Ptr _
	)As Integer
	
	Dim pUpdateContext As UpdateContext Ptr = CPtr(UpdateContext Ptr, Context)
	
	SetTimer( _
		pUpdateContext->hWin, _
		ANIMATION_TIMER_ID, _
		ANIMATION_TIMER_INTERVAL, _
		NULL _
	)
	
	Return 0
	
End Function

Sub SetOrthoProjection( _
		ByVal ScreenWidth As Integer, _
		ByVal ScreenHeight As Integer, _
		ByVal SceneWidth As Integer, _
		ByVal SceneHeight As Integer _
	)
	
	Dim fAspectX As Single = max(1.0, CSng(ScreenWidth) / CSng(SceneWidth))
	Dim fAspectY As Single = max(1.0, CSng(ScreenHeight) / CSng(SceneHeight))
	Dim fIsotropicAspect As Single = min(fAspectX, fAspectY)
	
	Dim ProjectionMatrix As XFORM = Any
	MatrixSetScale(@ProjectionMatrix, fIsotropicAspect, fIsotropicAspect)
	
	SceneSetProjectionMatrix( _
		pScene, _
		@ProjectionMatrix _
	)
	
End Sub

Function MainFormWndProc(ByVal hWin As HWND, ByVal wMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
	
	Select Case wMsg
		
		Case WM_CREATE
			Dim Context As UpdateContext Ptr = Allocate(SizeOf(UpdateContext))
			If Context = NULL Then
				Return -1
			End If
			Context->hWin = hWin
			
			Dim CallBacks As StageCallBacks = Any
			CallBacks.Render = @ColorLinesStageRenderFunction
			CallBacks.AnimateFunction = @ColorLinesStageAnimateFunction
			
			pStage = CreateStage(0, @CallBacks, Context)
			
		Case WM_SIZE
			If wParam <> SIZE_MINIMIZED Then
				Dim ClientAreaWidth As UINT = LOWORD(lParam)
				Dim ClientAreaHeight As UINT = HIWORD(lParam)
				
				If pScene <> NULL Then
					DestroyScene(pScene)
				End If
				pScene = CreateScene(hWin, ClientAreaWidth, ClientAreaHeight)
				
				SetOrthoProjection( _
					ClientAreaWidth, _
					ClientAreaHeight, _
					StageGetWidth(pStage), _
					StageGetHeight(pStage) _
				)
				
				SceneRender( _
					pScene, _
					pStage _
				)
			End If
			
		Case WM_COMMAND
			Select Case HiWord(wParam)
				
				Case 0 ' Меню или кнопка
					
					Select Case LoWord(wParam)
						
						Case IDM_GAME_NEW
							StageNewGame(pStage)
							
						Case IDM_GAME_UNDO
							StageCommand(pStage, StageCommands.Undo)
							
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
					
				Case 1 ' Акселератор
					
					Select Case LoWord(wParam)
						
						Case IDM_GAME_NEW_ACS
							StageNewGame(pStage)
							
						Case IDM_GAME_UNDO_ACS
							StageCommand(pStage, StageCommands.Undo)
							
						' Case IDM_GAME_STATISTICS_ACS
							' MainFormMenuStatistics_Click(hWin)
							
						' Case IDM_GAME_SETTINGS_ACS
							'
							
					End Select
					
				' Case Else ' Элемент управления
					
					
			End Select
			
		Case WM_ERASEBKGND
			Return TRUE
			
		Case WM_PAINT
			Dim ps As PAINTSTRUCT = Any
			Dim hDC As HDC = BeginPaint(hWin, @ps)
			
			SceneCopyRectangle(pScene, hDC, @ps.rcPaint)
			
			EndPaint(hWin, @ps)
			
		Case WM_DESTROY
			If pScene <> NULL Then
				DestroyScene(pScene)
			End If
			If pStage <> NULL Then
				DestroyStage(pStage)
			End If
			PostQuitMessage(0)
			
		Case WM_LBUTTONDOWN
			Dim pt As POINT = Any
			pt.x = GET_X_LPARAM(lParam)
			pt.y = GET_Y_LPARAM(lParam)
			SceneClick(pScene, pStage, @pt)
			
		Case WM_KEYDOWN
			Select Case wParam
				
				Case VK_TAB
					StageKeyPress(pStage, StageKeys.Tab)
					
				Case VK_SPACE
					StageKeyPress(pStage, StageKeys.KeyReturn)
					
				Case VK_RETURN
					StageKeyPress(pStage, StageKeys.KeyReturn)
					
				Case VK_LEFT
					StageKeyPress(pStage, StageKeys.Left)
					
				Case VK_UP
					StageKeyPress(pStage, StageKeys.Up)
					
				Case VK_RIGHT
					StageKeyPress(pStage, StageKeys.Right)
					
				Case VK_DOWN
					StageKeyPress(pStage, StageKeys.Down)
					
				Case VK_ESCAPE
					StageKeyPress(pStage, StageKeys.Escape)
					
			End Select
			
		Case WM_TIMER
			Select Case wParam
				
				Case ANIMATION_TIMER_ID
					Dim AnimationNeeded As Boolean = StageTick(pStage)
					If AnimationNeeded = False Then
						KillTimer(hWin, ANIMATION_TIMER_ID)
					End If
					
			End Select
			
		Case Else
			Return DefWindowProc(hWin, wMsg, wParam, lParam)
			
	End Select
	
	Return 0
	
End Function
