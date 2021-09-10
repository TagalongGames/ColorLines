#include once "ColorLinesWndProc.bi"
#include once "win\windowsx.bi"
#include once "win\GdiPlus.bi"
#include once "Scene.bi"
#include once "Stage.bi"
#include once "DisplayError.bi"
#include once "Resources.RH"

' �����
Dim Shared ColorLinesScene As Scene Ptr

' ������� ����
Dim Shared ColorLinesStage As Stage Ptr

Sub Visualisation()
	' ��������� ������������� ��� ������� ��������� �������
	' Dim OldRect As RECT
	
	' ����������� ������
	' object.Move
	
	' ��������� ������������� ��� ������ ��������� �������
	' Dim NewRect As RECT
	
	' ���������� ��� ��������������
	' Dim UnionRect As RECT
	
	' ����������� ����� � �����
	' Render(hDC)
	
	' ������� � ���� ����������� �������������
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
				
				Case 0 ' ���� ��� ������
					
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
					
				Case 1 ' �����������
					
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
					
				' Case Else ' ������� ����������
					
					
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
			
			' ���� �� ����� ������ � �� �������� ���������� ������
			Dim CellCoord As POINT = Any
			Dim b As Boolean = StageGetCellFromPoint( _
				ColorLinesStage, _
				@pt, _
				@CellCoord _
			)
			If b Then
				' �������� ������
				' ���� ��� ����������, �� ���� ��� ��� ������ � ���������� � ������� ����� ���
				' ���� �� ���������� � ��� ������ � ����� ���� ��� ����������� � �����������
			End If
			
		/'
		Case WM_KEYDOWN
			Select Case wParam
				
				Case VK_TAB
					' ������ �� ��������� ���
					' ���� Shift+TAB �� �� ���������� ���
					
				Case VK_SPACE
					' ����� ����, ���������� ������ ����
					
				Case VK_RETURN
					' ����� ����, ���������� ������ ����
					
				Case VK_LEFT
					' ������������� ���������������� ���������
					
				Case VK_UP
					' ������������� ���������������� ���������
					
				Case VK_RIGHT
					' ������������� ���������������� ���������
					
				Case VK_DOWN
					' ������������� ���������������� ���������
					
				Case VK_ESCAPE
					' ����� ������������� ���������������� ���������
					
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
