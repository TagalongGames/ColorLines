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
				Dim nWidth As UINT = LOWORD(lParam)
				Dim nHeight As UINT = HIWORD(lParam)
				
				'Scale = max(nHeight \ 480, 1)
				Dim CellWidth As UINT = max(40, (nHeight - 100) \ 9)
				Dim CellHeight As UINT = max(40, (nHeight - 100) \ 9)
				Dim BallMarginWidth As UINT = max(2, CellWidth \ 20)
				Dim BallMarginHeight As UINT = max(2, CellHeight \ 20)
				' Dim BallWidth As UINT = CellWidth - BallMargin
				' Dim BallHeight As UINT = CellHeight - BallMargin
				
				' Ячейка
				For j As Integer = 0 To 8
					For i As Integer = 0 To 8
						SetRect(@ColorLinesStage->Lines(j, i).CellRectangle, _
							i * CellWidth, _
							j * CellHeight, _
							i * CellWidth + CellWidth, _
							j * CellHeight + CellHeight _
						)
					Next
				Next
				
				' Шар
				For j As Integer = 0 To 8
					For i As Integer = 0 To 8
						SetRect(@ColorLinesStage->Lines(j, i).Ball.BallRectangle, _
							i * CellWidth + BallMarginWidth, _
							j * CellHeight + BallMarginHeight, _
							i * CellWidth + CellWidth - BallMarginWidth, _
							j * CellHeight + CellHeight - BallMarginHeight _
						)
					Next
				Next
				
				' Пересоздать сцену с новым размером
				If ColorLinesScene <> NULL Then
					DestroyScene(ColorLinesScene)
				End If
				ColorLinesScene = CreateScene(hWin, nWidth, nHeight)
				
				SceneRender(ColorLinesScene, ColorLinesStage)
			End If
			
		Case WM_ERASEBKGND
			Return TRUE
			
		Case WM_PAINT
			Dim ps As PAINTSTRUCT = Any
			Dim hDC As HDC = BeginPaint(hWin, @ps)
			
			SceneCopyRectangle(ColorLinesScene, hDC, @ps.rcPaint)
			
			EndPaint(hWin, @ps)
			
		Case WM_DESTROY
			If ColorLinesStage <> NULL Then
				DestroyStage(ColorLinesStage)
			End If
			If ColorLinesScene <> NULL Then
				DestroyScene(ColorLinesScene)
			End If
			PostQuitMessage(0)
			
		/'
		Case WM_LBUTTONDOWN
			PtInRect(RECT *lprc, POINT pt)
			MainForm_LeftMouseDown(hWin, wParam, GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam))
			
		'/
		
		/'
		Case WM_KEYDOWN
			Select Case wParam
				
				Case VK_LEFT
					' Переместить объект
					OffsetRect(@CellRectangle, -MOVE_DX, 0)
					' Визуализация
					SceneRender(ColorLinesScene, @ColorLinesStage)
					
				Case VK_UP
					' Переместить объект
					OffsetRect(@CellRectangle, 0, -MOVE_DY)
					' Визуализация
					SceneRender(ColorLinesScene, @ColorLinesStage)
					
				Case VK_RIGHT
					' Переместить объект
					OffsetRect(@CellRectangle, MOVE_DX, 0)
					' Визуализация
					SceneRender(ColorLinesScene, @ColorLinesStage)
					
				Case VK_DOWN
					' Переместить объект
					OffsetRect(@CellRectangle, 0, MOVE_DY)
					' Визуализация
					SceneRender(ColorLinesScene, @ColorLinesStage)
					
				Case VK_ESCAPE
					DestroyWindow(hWin)
					
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
