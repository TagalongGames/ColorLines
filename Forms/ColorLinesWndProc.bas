#include once "ColorLinesWndProc.bi"
#include once "win\windowsx.bi"
#include once "GameModel.bi"
#include once "Scene.bi"
#include once "Stage.bi"
#include once "DisplayError.bi"
#include once "Resources.RH"

Const ANIMATION_TIMER_ID As UINT_PTR = 1
Const ANIMATION_TIMER_INTERVAL As UINT = 1000

Type UpdateContext
	hWin As HWND
End Type

' Сцена
Dim Shared ColorLinesScene As Scene Ptr

' Игровое поле
Dim Shared ColorLinesStage As Stage Ptr

Function ColorLinesStageRenderFunction( _
		ByVal Context As Any Ptr, _
		ByVal pUpdateRectangle As RECT Ptr _
	)As Integer
	
	Dim pUpdateContext As UpdateContext Ptr = CPtr(UpdateContext Ptr, Context)
	
	SceneRender(ColorLinesScene, ColorLinesStage)
	
	InvalidateRect(pUpdateContext->hWin, pUpdateRectangle, FALSE)
	
	Return 0
	
End Function

Function ColorLinesStageAnimateFunction( _
		ByVal Context As Any Ptr _
	)As Integer
	
	Dim pUpdateContext As UpdateContext Ptr = CPtr(UpdateContext Ptr, Context)
	
	' Включить таймер анимации
	SetTimer( _
		pUpdateContext->hWin, _
		ANIMATION_TIMER_ID, _
		ANIMATION_TIMER_INTERVAL, _
		NULL _
	)
	
	Return 0
	
End Function

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
			
			ColorLinesStage = CreateStage(0, @CallBacks, Context)
			
		Case WM_SIZE
			If wParam <> SIZE_MINIMIZED Then
				Dim ClientAreaWidth As UINT = LOWORD(lParam)
				Dim ClientAreaHeight As UINT = HIWORD(lParam)
				
				If ColorLinesScene <> NULL Then
					DestroyScene(ColorLinesScene)
				End If
				ColorLinesScene = CreateScene(hWin, ClientAreaWidth, ClientAreaHeight)
				
				SceneRender(ColorLinesScene, ColorLinesStage)
			End If
			
		Case WM_COMMAND
			Select Case HiWord(wParam)
				
				Case 0 ' Меню или кнопка
					
					Select Case LoWord(wParam)
						
						Case IDM_GAME_NEW
							StageNewGame(ColorLinesStage)
							
						Case IDM_GAME_UNDO
							StageCommand(ColorLinesStage, StageCommands.Undo)
							
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
							StageNewGame(ColorLinesStage)
							
						Case IDM_GAME_UNDO_ACS
							StageCommand(ColorLinesStage, StageCommands.Undo)
							
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
			
			SceneCopyRectangle(ColorLinesScene, hDC, @ps.rcPaint)
			
			EndPaint(hWin, @ps)
			
		Case WM_DESTROY
			If ColorLinesScene <> NULL Then
				DestroyScene(ColorLinesScene)
			End If
			If ColorLinesStage <> NULL Then
				DestroyStage(ColorLinesStage)
			End If
			PostQuitMessage(0)
			
		Case WM_LBUTTONDOWN
			Dim pt As POINT = Any
			pt.x = GET_X_LPARAM(lParam)
			pt.y = GET_Y_LPARAM(lParam)
			StageClick(ColorLinesStage, @pt)
			
		Case WM_KEYDOWN
			Select Case wParam
				
				Case VK_TAB
					' Прыжок на следующий шар
					' Если Shift+TAB то на предыдущий шар
					StageKeyPress(ColorLinesStage, StageKeys.Tab)
					
				Case VK_SPACE
					' Выбор шара, аналогично щелчку мыши
					StageKeyPress(ColorLinesStage, StageKeys.KeyReturn)
					
				Case VK_RETURN
					' Выбор шара, аналогично щелчку мыши
					StageKeyPress(ColorLinesStage, StageKeys.KeyReturn)
					
				Case VK_LEFT
					' Прямоугольник предварительного выделения
					StageKeyPress(ColorLinesStage, StageKeys.Left)
					
				Case VK_UP
					' Прямоугольник предварительного выделения
					StageKeyPress(ColorLinesStage, StageKeys.Up)
					
				Case VK_RIGHT
					' Прямоугольник предварительного выделения
					StageKeyPress(ColorLinesStage, StageKeys.Right)
					
				Case VK_DOWN
					' Прямоугольник предварительного выделения
					StageKeyPress(ColorLinesStage, StageKeys.Down)
					
				Case VK_ESCAPE
					' Снять выбор шара
					StageKeyPress(ColorLinesStage, StageKeys.Escape)
					
			End Select
		
		Case WM_TIMER
			Select Case wParam
				
				Case ANIMATION_TIMER_ID
					Dim AnimationNeeded As Boolean = StageTick(ColorLinesStage)
					If AnimationNeeded = False Then
						KillTimer(hWin, ANIMATION_TIMER_ID)
					End If
					
			End Select
		
		Case Else
			Return DefWindowProc(hWin, wMsg, wParam, lParam)
			
	End Select
	
	Return 0
	
End Function
