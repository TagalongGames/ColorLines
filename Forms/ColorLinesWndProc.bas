#include once "ColorLinesWndProc.bi"
#include once "win\windowsx.bi"
#include once "win\GdiPlus.bi"
#include once "DisplayError.bi"
#include once "Resources.RH"

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

Type Scene
	DeviceContext As HDC
	Bitmap As HBITMAP
	OldBitmap As HGDIOBJ
	Width As UINT
	Height As UINT
End Type

Declare Function CreateScene( _
	ByVal hWin As HWND, _
	ByVal nWidth As UINT, _
	ByVal nHeight As UINT _
)As Scene Ptr

Declare Sub DestroyScene( _
	ByVal pScene As Scene Ptr _
)

Declare Sub SceneRender( _
	ByVal pScene As Scene Ptr _
)

Declare Sub SceneCopy( _
	ByVal pScene As Scene Ptr, _
	ByVal hDCDestination As hDC, _
	ByVal pRectangle As RECT Ptr _
)

' Сцена
Dim Shared ColorLinesScene As Scene Ptr
Dim Shared GdiplusToken As ULONG_PTR

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

' Игровое поле 9x9
Dim Shared ColorLinesStage(0 To 8, 0 To 8) As Cell
' Табло
Dim Shared ColorLinesTablo(0 To 2) As Cell
' Двигающийся шар
Dim Shared MovedBall As Cell

' Масштаб игрового поля
' Dim Shared Scale As UINT

' Размер ячейки {40, 40} * множитель
' Dim Shared CellWidth As UINT
' Dim Shared CellHeight As UINT
' Отступ 2 * множитель
' Dim Shared BallMargin As UINT
' Размер шара {CellWidth - BallMargin, CellHeight - BallMargin} * множитель
' Dim Shared BallWidth As UINT
' Dim Shared BallHeight As UINT

Function CreateScene( _
		ByVal hWin As HWND, _
		ByVal nWidth As UINT, _
		ByVal nHeight As UINT _
	)As Scene Ptr
	
	Dim pScene As Scene Ptr = Allocate(SizeOf(Scene))
	If pScene = NULL Then
		Return NULL
	End If
	
	Dim WindowDC As HDC = GetDC(hWin)
	
	' Контекст устройства в памяти
	pScene->DeviceContext = CreateCompatibleDC(WindowDC)
	
	' Цветной рисунок на основе окна
	pScene->Bitmap = CreateCompatibleBitmap(WindowDC, nWidth, nHeight)
	' Выбираем цветной рисунок, сохраняя старый
	pScene->OldBitmap = SelectObject(pScene->DeviceContext, pScene->Bitmap)
	
	pScene->Width = nWidth
	pScene->Height = nHeight
	
	ReleaseDC(hWin, WindowDC)
	
	Return pScene
	
End Function

Sub DestroyScene( _
		ByVal pScene As Scene Ptr _
	)
	SelectObject(pScene->DeviceContext, pScene->OldBitmap)
	DeleteObject(pScene->Bitmap)
	DeleteDC(pScene->DeviceContext)
End Sub

Sub SceneRender( _
		ByVal pScene As Scene Ptr _
	)
	
	Dim OldPen As HGDIOBJ = Any
	Dim OldBrush As HGDIOBJ = Any
	
	' Прямоугольник обновления
	Dim MemoryBMRectangle As RECT = Any
	SetRect(@MemoryBMRectangle, 0, 0, pScene->Width, pScene->Height)
	
	' Очистка
	FillRect(pScene->DeviceContext, @MemoryBMRectangle, Cast(HBRUSH, GetStockObject(BLACK_BRUSH)))
	
	' Рисуем
	
	' Ячейки
	OldPen = SelectObject(pScene->DeviceContext, DarkGrayPen)
	OldBrush = SelectObject(pScene->DeviceContext, GrayBrush)
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			Rectangle(pScene->DeviceContext, ColorLinesStage(j, i).CellRectangle.left, ColorLinesStage(j, i).CellRectangle.top, ColorLinesStage(j, i).CellRectangle.right, ColorLinesStage(j, i).CellRectangle.bottom)
		Next
	Next
	SelectObject(pScene->DeviceContext, OldBrush)
	SelectObject(pScene->DeviceContext, OldPen)
	
	' Стоящие шары
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			
			If ColorLinesStage(j, i).Exist Then
				
				Select Case ColorLinesStage(j, i).Color
					
					Case BallColor.Red
						' OldPen = SelectObject(pScene->DeviceContext, GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, RedBrush)
						
					Case BallColor.Green
						' OldPen = SelectObject(pScene->DeviceContext, GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, GreenBrush)
						
					Case BallColor.Blue
						' OldPen = SelectObject(pScene->DeviceContext, GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, BlueBrush)
						
					Case BallColor.Yellow
						' OldPen = SelectObject(pScene->DeviceContext, GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, YellowBrush)
						
					Case BallColor.Magenta
						' OldPen = SelectObject(pScene->DeviceContext, GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, MagentaBrush)
						
					Case BallColor.DarkRed
						' OldPen = SelectObject(pScene->DeviceContext, GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, DarkRedBrush)
						
					Case BallColor.Cyan
						' OldPen = SelectObject(pScene->DeviceContext, GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, CyanBrush)
						
				End Select
				
				Ellipse(pScene->DeviceContext, ColorLinesStage(j, i).BallRectangle.left, ColorLinesStage(j, i).BallRectangle.top, ColorLinesStage(j, i).BallRectangle.right, ColorLinesStage(j, i).BallRectangle.bottom)
				
				SelectObject(pScene->DeviceContext, OldBrush)
				' SelectObject(pScene->DeviceContext, OldPen)
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
	
End Sub

Sub SceneCopy( _
		ByVal pScene As Scene Ptr, _
		ByVal hDCDestination As hDC, _
		ByVal pRectangle As RECT Ptr _
	)
	
	BitBlt( _
		hDCDestination, _
		pRectangle->left, pRectangle->top, pRectangle->right, pRectangle->bottom, _
		pScene->DeviceContext, _
		pRectangle->left, pRectangle->top, _
		SRCCOPY _
	)
	
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
			' GDI+ Initialize
			Dim gsi As GdiPlus.GdiplusStartupInput = Any
			ZeroMemory(@gsi, SizeOf(GdiPlus.GdiplusStartupInput))
			gsi.GdiplusVersion = 1
			Dim st As GdiPlus.GpStatus = GdiPlus.GdiplusStartup(@GdiplusToken, @gsi, NULL)
			If st <> GdiPlus.Ok Then
				DisplayError(st, __TEXT("GdiplusStartup"))
			End If
			
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
			
			' Три случайных цвета
			
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
				
				SceneRender(ColorLinesScene)
			End If
			
		Case WM_ERASEBKGND
			Return TRUE
			
		Case WM_PAINT
			Dim ps As PAINTSTRUCT = Any
			Dim hDC As HDC = BeginPaint(hWin, @ps)
			
			' BitBlt( _
				' hDC, _
				' ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom, _
				' ColorLinesScene->DeviceContext, _
				' ps.rcPaint.left, ps.rcPaint.top, _
				' SRCCOPY _
			' )
			SceneCopy(ColorLinesScene, hDC, @ps.rcPaint)
			
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
			
			DestroyScene(ColorLinesScene)
			
			' GDI+ Uninitialize
			GdiPlus.GdiplusShutdown(GdiplusToken)
			
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
		
		Case Else
			Return DefWindowProc(hWin, wMsg, wParam, lParam)
			
	End Select
	
	Return 0
	
End Function
