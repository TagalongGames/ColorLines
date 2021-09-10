#include once "ColorLinesWndProc.bi"
#include once "win\windowsx.bi"
#include once "win\GdiPlus.bi"
#include once "Scene.bi"
#include once "Stage.bi"
#include once "DisplayError.bi"
#include once "Resources.RH"

' Сцена
Dim Shared ColorLinesScene As Scene Ptr

' Игровое поле
Dim Shared ColorLinesStage As Stage Ptr

Sub Visualisation()
	' Вычислить прямоугольник для старого положения объекта
	' Dim OldRect As RECT
	
	' Переместить объект
	' object.Move
	
	' Вычислить прямоугольник для нового положения объекта
	' Dim NewRect As RECT
	
	' Объединить оба прямоугольника
	' Dim UnionRect As RECT
	
	' Отрендерить сцену в буфер
	' Render(hDC)
	
	' Вывести в окно объединённый прямоугольник
	' InvalidateRect(hWin, @UnionRect, FALSE)
End Sub

Function MainFormWndProc(ByVal hWin As HWND, ByVal wMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
	
	Select Case wMsg
		
		Case WM_CREATE
			ColorLinesStage = CreateStage(0)
			
		Case WM_SIZE
			If wParam <> SIZE_MINIMIZED Then
				Dim ClientAreaWidth As UINT = LOWORD(lParam)
				Dim ClientAreaHeight As UINT = HIWORD(lParam)
				
				StageRecalculateSizes(ColorLinesStage, ClientAreaWidth, ClientAreaHeight)
				
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
							' MainFormMenuNewGame_Click(hWin)
							
						Case IDM_GAME_NEW_AI
							' MainFormMenuNewAIGame_Click(hWin)
							
						Case IDM_GAME_NEW_NETWORK
							' MainFormMenuNewNetworkGame_Click(hWin)
							
						Case IDM_GAME_STATISTICS
							' MainFormMenuStatistics_Click(hWin)
							
						Case IDM_GAME_SETTINGS
							'
							
						Case IDM_GAME_UNDO
							'
							
						Case IDM_FILE_EXIT
							DestroyWindow(hWin)
							
						Case IDM_HELP_CONTENTS
							' MainFormMenuHelpContents_Click(hWin)
							
						Case IDM_HELP_ABOUT
							' MainFormMenuHelpAbout_Click(hWin)
							
					End Select
					
				Case 1 ' Акселератор
					
					Select Case LoWord(wParam)
						
						Case IDM_GAME_NEW_ACS
							' MainFormMenuNewGame_Click(hWin)
							
						Case IDM_GAME_NEW_AI_ACS
							' MainFormMenuNewAIGame_Click(hWin)
							
						Case IDM_GAME_NEW_NETWORK_ACS
							' MainFormMenuNewNetworkGame_Click(hWin)
							
						Case IDM_GAME_STATISTICS_ACS
							' MainFormMenuStatistics_Click(hWin)
							
						Case IDM_GAME_SETTINGS_ACS
							'
							
						Case IDM_GAME_UNDO_ACS
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
			
			' Если мы можем тыкать — то получить координаты ячейки
			Dim CellCoord As POINT = Any
			Dim b As Boolean = StageGetCellFromPoint( _
				ColorLinesStage, _
				@pt, _
				@CellCoord _
			)
			If b Then
				' Получить ячейку
				' Если она существует, то если шар был выбран — развыбрать и выбрать новый шар
				' Если не существует и шар выбран — найти путь для перемещения и переместить
			End If
			
		/'
		Case WM_KEYDOWN
			Select Case wParam
				
				Case VK_TAB
					' Прыжок на следующий шар
					' Если Shift+TAB то на предыдущий шар
					
				Case VK_SPACE
					' Выбор шара, аналогично щелчку мыши
					
				Case VK_RETURN
					' Выбор шара, аналогично щелчку мыши
					
				Case VK_LEFT
					' Прямоугольник предварительного выделения
					
				Case VK_UP
					' Прямоугольник предварительного выделения
					
				Case VK_RIGHT
					' Прямоугольник предварительного выделения
					
				Case VK_DOWN
					' Прямоугольник предварительного выделения
					
				Case VK_ESCAPE
					' Снять прямоугольник предварительного выделения
					
			End Select
		'/
		
		/'
		Case WM_TIMER
			Select Case wParam
				
				Case RightEnemyDealCardTimer
					RightEnemyDealCardTimer_Tick(hWin)
					
			End Select
		'/
		
		Case Else
			Return DefWindowProc(hWin, wMsg, wParam, lParam)
			
	End Select
	
	Return 0
	
End Function
