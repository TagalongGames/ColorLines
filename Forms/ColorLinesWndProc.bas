#include "ColorLinesWndProc.bi"
#include "win\windowsx.bi"
#include "DisplayError.bi"
#include "Resources.RH"

Enum
	rgbBlack =       &h00000000
	rgbDarkBlue =    &h00800000
	rgbDarkGreen =   &h00008000
	rgbDarkCyan =    &h00808000
	rgbDarkRed =     &h00000080
	rgbDarkMagenta = &h00800080
	rgbDarkYellow =  &h00008080
	rgbGray =        &h00C0C0C0
	rgbDarkGray =    &h00808080
	rgbBlue =        &h00FF0000
	rgbGreen =       &h0000FF00
	rgbCyan =        &h00FFFF00
	rgbRed =         &h000000FF
	rgbMagenta =     &h00FF00FF
	rgbYellow =      &h0000FFFF
	rgbWhite =       &h00FFFFFF
End Enum

Type RgbColors As COLORREF

Enum BallColor
	Red
	Green
	Blue
	Yellow
	Magenta
	DarkRed
	Cyan
End Enum

Type Cell
	Color As BallColor
	CellRectangle As RECT
	BallRectangle As RECT
	Exist As Boolean
End Type

' Поверхности для рисования
Dim Shared MemoryDC As HDC
Dim Shared MemoryBM As HBITMAP
Dim Shared OldMemoryBM As HGDIOBJ
Dim Shared MemoryBMWidth As UINT
Dim Shared MemoryBMHeight As UINT

' Кисти и перья
Dim Shared GreenPen As HPEN
Dim Shared DarkGrayPen As HPEN

Dim Shared RedBrush As HBRUSH
Dim Shared GreenBrush As HBRUSH
Dim Shared BlueBrush As HBRUSH
Dim Shared YellowBrush As HBRUSH
Dim Shared MagentaBrush As HBRUSH
Dim Shared DarkRedBrush As HBRUSH
Dim Shared CyanBrush As HBRUSH
Dim Shared GrayBrush As HBRUSH

Dim Shared OldPen As HGDIOBJ
Dim Shared OldBrush As HGDIOBJ

' Игровое поле 9x9
Dim Shared ColorLinesStage(0 To 8, 0 To 8) As Cell
' Табло
Dim Shared ColorLinesTablo(0 To 2) As Cell
' Двигающийся шар
Dim Shared MovedBall As Cell

' Масштаб игрового поля
' Dim Shared Scale As UINT

' Размер ячейки {40, 40} * множитель
Dim Shared CellWidth As UINT
Dim Shared CellHeight As UINT
' Отступ 2 * множитель
Dim Shared BallMargin As UINT
' Размер шара {CellWidth - BallMargin, CellHeight - BallMargin} * множитель
Dim Shared BallWidth As UINT
Dim Shared BallHeight As UINT

Declare Function CreateMemoryDC( _
	ByVal hWin As HWND, _
	ByVal nWidth As UINT, _
	ByVal nHeight As UINT _
)As HDC

Declare Sub DestroyMemoryDC( _
	ByVal hDC As HDC _
)

Function CreateMemoryDC( _
		ByVal hWin As HWND, _
		ByVal nWidth As UINT, _
		ByVal nHeight As UINT _
	)As HDC
	
	Dim WindowDC As HDC = GetDC(hWin)
	
	' Контекст устройства в памяти
	Dim hDC As HDC = CreateCompatibleDC(WindowDC)
	
	' Цветной рисунок на основе окна
	MemoryBM = CreateCompatibleBitmap(WindowDC, nWidth, nHeight)
	' Выбираем цветной рисунок, сохраняя старый
	OldMemoryBM = SelectObject(hDC, MemoryBM)
	
	ReleaseDC(hWin, WindowDC)
	
	Return hDC
	
End Function

Sub DestroyMemoryDC(ByVal hDC As HDC)
	SelectObject(MemoryDC, OldMemoryBM)
	DeleteObject(MemoryBM)
	DeleteDC(hDC)
End Sub

Sub Render(ByVal hDC As HDC)
	' Прямоугольник обновления
	Dim MemoryBMRectangle As RECT = Any
	SetRect(@MemoryBMRectangle, 0, 0, MemoryBMWidth, MemoryBMHeight)
	
	' Очистка
	FillRect(hDC, @MemoryBMRectangle, Cast(HBRUSH, GetStockObject(BLACK_BRUSH)))
	
	' Рисуем
	
	' Ячейки
	OldPen = SelectObject(hDC, DarkGrayPen)
	OldBrush = SelectObject(hDC, GrayBrush)
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			Rectangle(hDC, ColorLinesStage(j, i).CellRectangle.left, ColorLinesStage(j, i).CellRectangle.top, ColorLinesStage(j, i).CellRectangle.right, ColorLinesStage(j, i).CellRectangle.bottom)
		Next
	Next
	SelectObject(hDC, OldBrush)
	SelectObject(hDC, OldPen)
	
	' Стоящие шары
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			
			If ColorLinesStage(j, i).Exist Then
				
				Select Case ColorLinesStage(j, i).Color
					
					Case BallColor.Red
						' OldPen = SelectObject(hDC, GreenPen)
						OldBrush = SelectObject(hDC, RedBrush)
						
					Case BallColor.Green
						' OldPen = SelectObject(hDC, GreenPen)
						OldBrush = SelectObject(hDC, GreenBrush)
						
					Case BallColor.Blue
						' OldPen = SelectObject(hDC, GreenPen)
						OldBrush = SelectObject(hDC, BlueBrush)
						
					Case BallColor.Yellow
						' OldPen = SelectObject(hDC, GreenPen)
						OldBrush = SelectObject(hDC, YellowBrush)
						
					Case BallColor.Magenta
						' OldPen = SelectObject(hDC, GreenPen)
						OldBrush = SelectObject(hDC, MagentaBrush)
						
					Case BallColor.DarkRed
						' OldPen = SelectObject(hDC, GreenPen)
						OldBrush = SelectObject(hDC, DarkRedBrush)
						
					Case BallColor.Cyan
						' OldPen = SelectObject(hDC, GreenPen)
						OldBrush = SelectObject(hDC, CyanBrush)
						
				End Select
				
				Ellipse(hDC, ColorLinesStage(j, i).BallRectangle.left, ColorLinesStage(j, i).BallRectangle.top, ColorLinesStage(j, i).BallRectangle.right, ColorLinesStage(j, i).BallRectangle.bottom)
				
				SelectObject(hDC, OldBrush)
				' SelectObject(hDC, OldPen)
			End If
		Next
	Next
	
	' Двигающийся шар
	' тип движения:
	' - появление из точки в нормальный размер (от 0 до 9)
	' - прыжки при выборе мышью (от 0 до 5 и обратно)
	' - уничтожение, рассыпался в прах (от 9 до 0)
	' координаты
	If MovedBall.Exist Then
	End If
	
	' Табло с тремя новыми шарами
	For i As Integer = 0 To 2
	Next
	
	' Выводим в окно
	' InvalidateRect(hWin, @UpdateRectangle, FALSE)
End Sub

Function GetRandomBoolean()As Boolean
	
	Dim RndValue As Long = rand()
	
	If RndValue > RAND_MAX \ 2 Then
		Return True
	End If
	
	Return False
	
End Function

Function GetRandomBallColor()As BallColor
	
	Const SevenPart As Long = RAND_MAX \ 7
	Dim RndValue As Long = rand()
	
	Return Cast(BallColor, RndValue Mod 7)
	
End Function

Function MainFormWndProc(ByVal hWin As HWND, ByVal wMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
	
	Select Case wMsg
		
		Case WM_CREATE
			' Перья и кисти
			GreenPen = CreatePen(PS_SOLID, 2, rgbGreen)
			DarkGrayPen = CreatePen(PS_SOLID, 2, rgbDarkGray)
			RedBrush = CreateSolidBrush(rgbRed)
			GreenBrush = CreateSolidBrush(rgbGreen)
			BlueBrush = CreateSolidBrush(rgbBlue)
			YellowBrush = CreateSolidBrush(rgbYellow)
			MagentaBrush = CreateSolidBrush(rgbMagenta)
			DarkRedBrush = CreateSolidBrush(rgbDarkRed)
			CyanBrush = CreateSolidBrush(rgbCyan)
			GrayBrush = CreateSolidBrush(rgbGray)
			' Игровое поле
			For j As Integer = 0 To 8
				For i As Integer = 0 To 8
					' Dim RndExists As Boolean = GetRandomBoolean()
					ColorLinesStage(j, i).Exist = True 'RndExists
					
					Dim RndColor As BallColor = GetRandomBallColor()
					ColorLinesStage(j, i).Color = RndColor
				Next
			Next
			
		Case WM_SIZE
			If wParam <> SIZE_MINIMIZED Then
				Dim nWidth As UINT = LOWORD(lParam)
				Dim nHeight As UINT = HIWORD(lParam)
				MemoryBMWidth = nWidth
				MemoryBMHeight = nHeight
				
				'Scale = max(nHeight \ 480, 1)
				CellWidth = max(40, (nHeight - 100) \ 9)
				CellHeight = max(40, (nHeight - 100) \ 9)
				BallMargin = max(2, CellWidth \ 20)
				BallWidth = CellWidth - BallMargin
				BallHeight = CellHeight - BallMargin
				
				' Ячейка
				For j As Integer = 0 To 8
					For i As Integer = 0 To 8
						SetRect(@ColorLinesStage(j, i).CellRectangle, _
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
						SetRect(@ColorLinesStage(j, i).BallRectangle, _
							i * CellWidth + BallMargin, _
							j * CellHeight + BallMargin, _
							i * CellWidth + CellWidth - BallMargin, _
							j * CellHeight + CellHeight - BallMargin _
						)
					Next
				Next
				
				' Контекст устройства в памяти
				If MemoryDC <> NULL Then
					DestroyMemoryDC(MemoryDC)
				End If
				MemoryDC = CreateMemoryDC(hWin, nWidth, nHeight)
				
				Render(MemoryDC)
			End If
			
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
					Render(MemoryDC)
					
				Case VK_UP
					' Переместить объект
					OffsetRect(@CellRectangle, 0, -MOVE_DY)
					' Визуализация
					Render(MemoryDC)
					
				Case VK_RIGHT
					' Переместить объект
					OffsetRect(@CellRectangle, MOVE_DX, 0)
					' Визуализация
					Render(MemoryDC)
					
				Case VK_DOWN
					' Переместить объект
					OffsetRect(@CellRectangle, 0, MOVE_DY)
					' Визуализация
					Render(MemoryDC)
					
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
			
		Case WM_ERASEBKGND
			Return TRUE
			
		Case WM_PAINT
			Dim ps As PAINTSTRUCT = Any
			Dim hDC As HDC = BeginPaint(hWin, @ps)
			
			BitBlt( _
				hDC, _
				ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom, _
				MemoryDC, _
				ps.rcPaint.left, ps.rcPaint.top, _
				SRCCOPY _
			)
			
			EndPaint(hWin, @ps)
			
		Case WM_DESTROY
			DeleteObject(RedBrush)
			DeleteObject(GreenBrush)
			DeleteObject(BlueBrush)
			DeleteObject(YellowBrush)
			DeleteObject(MagentaBrush)
			DeleteObject(DarkRedBrush)
			DeleteObject(CyanBrush)
			DeleteObject(GrayBrush)
			DeleteObject(GreenPen)
			DeleteObject(DarkGrayPen)
			DestroyMemoryDC(MemoryDC)
			PostQuitMessage(0)
			
		Case Else
			Return DefWindowProc(hWin, wMsg, wParam, lParam)
			
	End Select
	
	Return 0
	
End Function
