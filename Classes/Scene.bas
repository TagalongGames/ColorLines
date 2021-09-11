#include once "Scene.bi"
#include once "win\GdiPlus.bi"

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

' Type RgbColors As COLORREF

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

Type _Scene
	DeviceContext As HDC
	Bitmap As HBITMAP
	OldBitmap As HGDIOBJ
	
	' Для ячеек
	DarkGrayPen As HPEN
	GrayBrush As HBRUSH
	DarkGrayBrush As HBRUSH
	
	' Для шаров
	RedBrush As HBRUSH
	GreenBrush As HBRUSH
	BlueBrush As HBRUSH
	YellowBrush As HBRUSH
	MagentaBrush As HBRUSH
	DarkRedBrush As HBRUSH
	CyanBrush As HBRUSH
	
	Width As UINT
	Height As UINT
	
End Type

Function CreateScene( _
		ByVal hWin As HWND, _
		ByVal SceneWidth As UINT, _
		ByVal SceneHeight As UINT _
	)As Scene Ptr
	
	Dim pScene As Scene Ptr = Allocate(SizeOf(Scene))
	If pScene = NULL Then
		Return NULL
	End If
	
	' Перья и кисти
	pScene->DarkGrayPen = CreatePen(PS_SOLID, 1, rgbDarkGray)
	pScene->GrayBrush = CreateSolidBrush(rgbGray)
	pScene->DarkGrayBrush = CreateSolidBrush(rgbDarkGray)
	
	pScene->RedBrush = CreateSolidBrush(rgbRed)
	pScene->GreenBrush = CreateSolidBrush(rgbGreen)
	pScene->BlueBrush = CreateSolidBrush(rgbBlue)
	pScene->YellowBrush = CreateSolidBrush(rgbYellow)
	pScene->MagentaBrush = CreateSolidBrush(rgbMagenta)
	pScene->DarkRedBrush = CreateSolidBrush(rgbDarkRed)
	pScene->CyanBrush = CreateSolidBrush(rgbCyan)
	
	Dim WindowDC As HDC = GetDC(hWin)
	
	' Контекст устройства в памяти
	pScene->DeviceContext = CreateCompatibleDC(WindowDC)
	
	' Цветной рисунок на основе окна
	pScene->Bitmap = CreateCompatibleBitmap(WindowDC, SceneWidth, SceneHeight)
	' Выбираем цветной рисунок, сохраняя старый
	pScene->OldBitmap = SelectObject(pScene->DeviceContext, pScene->Bitmap)
	
	pScene->Width = SceneWidth
	pScene->Height = SceneHeight
	
	ReleaseDC(hWin, WindowDC)
	
	Return pScene
	
End Function

Sub DestroyScene( _
		ByVal pScene As Scene Ptr _
	)
	
	DeleteObject(pScene->DarkGrayPen)
	DeleteObject(pScene->GrayBrush)
	DeleteObject(pScene->DarkGrayBrush)
	
	DeleteObject(pScene->RedBrush)
	DeleteObject(pScene->GreenBrush)
	DeleteObject(pScene->BlueBrush)
	DeleteObject(pScene->YellowBrush)
	DeleteObject(pScene->MagentaBrush)
	DeleteObject(pScene->DarkRedBrush)
	DeleteObject(pScene->CyanBrush)
	
	SelectObject(pScene->DeviceContext, pScene->OldBitmap)
	DeleteObject(pScene->Bitmap)
	DeleteDC(pScene->DeviceContext)
	
	Deallocate(pScene)
	
End Sub

Sub SceneRender( _
		ByVal pScene As Scene Ptr, _
		ByVal pStage As Stage Ptr _
	)
	
	Scope
		Dim pGraphics As GdiPlus.GpGraphics Ptr = Any
		GdiPlus.GdipCreateFromHDC(pScene->DeviceContext, @pGraphics)
		GdiPlus.GdipDeleteGraphics(pGraphics) 
	End Scope
	
	Dim OldPen As HGDIOBJ = Any
	Dim OldBrush As HGDIOBJ = Any
	
	' Прямоугольник обновления
	Dim MemoryBMRectangle As RECT = Any
	SetRect(@MemoryBMRectangle, 0, 0, pScene->Width, pScene->Height)
	
	' Очистка
	FillRect(pScene->DeviceContext, @MemoryBMRectangle, Cast(HBRUSH, GetStockObject(BLACK_BRUSH)))
	
	' Рисуем
	OldPen = SelectObject(pScene->DeviceContext, Cast(HBRUSH, GetStockObject(NULL_PEN)))
	
	' Ячейки
			OldBrush = SelectObject(pScene->DeviceContext, pScene->DarkGrayBrush)
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			Rectangle( _
				pScene->DeviceContext, _
				pStage->Lines(j, i).Rectangle.left, _
				pStage->Lines(j, i).Rectangle.top, _
				pStage->Lines(j, i).Rectangle.right, _
				pStage->Lines(j, i).Rectangle.bottom _
			)
			
			' OldBrush = SelectObject(pScene->DeviceContext, pScene->GrayBrush)
			Rectangle( _
				pScene->DeviceContext, _
				pStage->Lines(j, i).Ball.Rectangle.left, _
				pStage->Lines(j, i).Ball.Rectangle.top, _
				pStage->Lines(j, i).Ball.Rectangle.right, _
				pStage->Lines(j, i).Ball.Rectangle.bottom _
			)
			' SelectObject(pScene->DeviceContext, OldBrush)
		Next
	Next
			SelectObject(pScene->DeviceContext, OldBrush)
	
	' Стоящие шары
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			
			If pStage->Lines(j, i).Ball.Exist Then
				
				Select Case pStage->Lines(j, i).Ball.Color
					
					Case BallColors.Red
						' OldPen = SelectObject(pScene->DeviceContext, pScene->GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, pScene->RedBrush)
						
					Case BallColors.Green
						' OldPen = SelectObject(pScene->DeviceContext, pScene->GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, pScene->GreenBrush)
						
					Case BallColors.Blue
						' OldPen = SelectObject(pScene->DeviceContext, pScene->GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, pScene->BlueBrush)
						
					Case BallColors.Yellow
						' OldPen = SelectObject(pScene->DeviceContext, pScene->GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, pScene->YellowBrush)
						
					Case BallColors.Magenta
						' OldPen = SelectObject(pScene->DeviceContext, pScene->GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, pScene->MagentaBrush)
						
					Case BallColors.DarkRed
						' OldPen = SelectObject(pScene->DeviceContext, pScene->GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, pScene->DarkRedBrush)
						
					Case BallColors.Cyan
						' OldPen = SelectObject(pScene->DeviceContext, pScene->GreenPen)
						OldBrush = SelectObject(pScene->DeviceContext, pScene->CyanBrush)
						
				End Select
				
				Ellipse( _
					pScene->DeviceContext, _
					pStage->Lines(j, i).Ball.Rectangle.left, _
					pStage->Lines(j, i).Ball.Rectangle.top, _
					pStage->Lines(j, i).Ball.Rectangle.right, _
					pStage->Lines(j, i).Ball.Rectangle.bottom _
				)
				
				' SelectObject(pScene->DeviceContext, OldPen)
				SelectObject(pScene->DeviceContext, OldBrush)
			End If
		Next
	Next
	
	' Двигающийся шар
	' тип движения:
	' - появление из точки в нормальный размер (от 0 до 9)
	' - прыжки при выборе мышью (от 0 до 5 и обратно)
	' - уничтожение, рассыпался в прах (от 9 до 0)
	' координаты
	If pStage->MovedBall.Exist Then
	End If
	
	' Табло с тремя новыми шарами
	For i As Integer = 0 To 2
	Next
	
	SelectObject(pScene->DeviceContext, OldPen)
	
End Sub

Sub SceneCopyRectangle( _
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
