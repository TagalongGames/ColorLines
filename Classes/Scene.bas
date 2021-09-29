#include once "Scene.bi"
#include once "GdiMatrix.bi"
#include once "windows.bi"
#include once "win\GdiPlus.bi"

Enum GdiColors
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

Enum GdiPlusColors
	argbBlack =       &hFF000000
	argbDarkBlue =    &hFF000080
	argbDarkGreen =   &hFF008000
	argbDarkCyan =    &hFF008080
	argbDarkRed =     &hFF800000
	argbDarkMagenta = &hFF800080
	argbDarkYellow =  &hFF008080
	argbGray =        &hFFC0C0C0
	argbDarkGray =    &hFF808080
	argbBlue =        &hFF0000FF
	argbGreen =       &hFF00FF00
	argbCyan =        &hFF00FFFF
	argbRed =         &hFFFF0000
	argbMagenta =     &hFFFF00FF
	argbYellow =      &hFFFFFF00
	argbWhite =       &hFFFFFFFF
End Enum

Type SceneBrushes
	
	' Для ячеек
	GrayBrush As HBRUSH
	DarkGrayBrush As HBRUSH
	DashPen As HPEN
	BoundingPen As HPEN
	
	' Для шаров
	RedBrush As HBRUSH
	GreenBrush As HBRUSH
	BlueBrush As HBRUSH
	YellowBrush As HBRUSH
	MagentaBrush As HBRUSH
	DarkRedBrush As HBRUSH
	CyanBrush As HBRUSH
	
End Type

Type _Scene
	DeviceContext As HDC
	Bitmap As HBITMAP
	OldBitmap As HGDIOBJ
	
	Brushes As SceneBrushes
	
	Width As UINT
	Height As UINT
	
	ProjectionMatrix As XFORM
	ViewMatrix As XFORM
	WorldMatrix As XFORM
End Type

Sub DrawBall( _
		ByVal pScene As Scene Ptr, _
		ByVal hDC As HDC, _
		ByVal pBrushes As SceneBrushes Ptr, _
		ByVal pBall As ColorBall Ptr _
	)
	
	Dim PositionMatrix As XFORM = Any
	SetPositionMatrix(@PositionMatrix, @pBall->Position)
	ModifyWorldTransform(hDC, @PositionMatrix, MWT_LEFTMULTIPLY)
	
	' тип движения:
	' - появление из точки в нормальный размер (от 0 до 9)
	' - прыжки при выборе мышью (от 0 до 5 и обратно)
	' - уничтожение, рассыпался в прах (от 9 до 0)
	' координаты
	/'
	If pBall->Visible Then
		Dim OldBrush As HGDIOBJ = Any
		
		Select Case CInt(pBall->Color)
			
			Case BallColors.Red
				OldBrush = SelectObject(hDC, pBrushes->RedBrush)
				
			Case BallColors.Green
				OldBrush = SelectObject(hDC, pBrushes->GreenBrush)
				
			Case BallColors.Blue
				OldBrush = SelectObject(hDC, pBrushes->BlueBrush)
				
			Case BallColors.Yellow
				OldBrush = SelectObject(hDC, pBrushes->YellowBrush)
				
			Case BallColors.Magenta
				OldBrush = SelectObject(hDC, pBrushes->MagentaBrush)
				
			Case BallColors.DarkRed
				OldBrush = SelectObject(hDC, pBrushes->DarkRedBrush)
				
			Case Else ' BallColors.Cyan
				OldBrush = SelectObject(hDC, pBrushes->CyanBrush)
				
		End Select
		
		Ellipse( _
			hDC, _
			pBall->Bounds.left, _
			pBall->Bounds.top, _
			pBall->Bounds.right, _
			pBall->Bounds.bottom _
		)
		
		SelectObject(hDC, OldBrush)
	End If
	'/
	
	If pBall->Visible Then
		
		Dim WorldMatrix As XFORM = Any
		Scope
			Dim OutMatrix As XFORM = Any
			CombineTransform(@OutMatrix, @pScene->ProjectionMatrix, @pScene->ViewMatrix)
			
			CombineTransform(@WorldMatrix, @OutMatrix, @pScene->WorldMatrix)
		End Scope
		
		Scope
			Dim OutMatrix As XFORM = Any
			CombineTransform(@OutMatrix, @PositionMatrix, @WorldMatrix)
			
			WorldMatrix = OutMatrix
		End Scope
		
		Dim elRgn As HRGN = CreateEllipticRgn( _
			pBall->Bounds.left, _
			pBall->Bounds.top, _
			pBall->Bounds.right + 1, _
			pBall->Bounds.bottom + 1 _
		)
		Dim nCount As DWORD = GetRegionData(elRgn, 0, NULL)
		
		Dim lpData As RGNDATA Ptr = Allocate(SizeOf(RGNDATA) * nCount)
		GetRegionData(elRgn, nCount, lpData)
		
		Dim elRgn2 As HRGN = ExtCreateRegion(@WorldMatrix, nCount, lpData)
		
		Dim vertex(0 To 1) As TRIVERTEX = Any
		vertex(0).x     = pBall->Bounds.left
		vertex(0).y     = pBall->Bounds.top
		vertex(0).Red   = &hFFFF
		vertex(0).Green = &hFFFF
		vertex(0).Blue  = &hFFFF
		vertex(0).Alpha = &hFFFF
		
		vertex(1).x     = pBall->Bounds.right
		vertex(1).y     = pBall->Bounds.bottom
		vertex(1).Red   = &h0000
		vertex(1).Green = &h8000
		vertex(1).Blue  = &h8000
		vertex(1).Alpha = &hFFFF
		
		' Create a GRADIENT_RECT structure that 
		' references the TRIVERTEX vertices. 
		Dim gRect As GRADIENT_RECT = Any
		gRect.UpperLeft  = 0
		gRect.LowerRight = 1
		
		SelectClipRgn(hDC, elRgn2)
		
		' Draw a shaded rectangle. 
		GradientFill(hDC, @vertex(0), 2, @gRect, 1, GRADIENT_FILL_RECT_H)
		
		SelectClipRgn(hDC, NULL)
		
		DeleteObject(elRgn2)
		Deallocate(lpData)
		DeleteObject(elRgn)
		
		Ellipse( _
			hDC, _
			pBall->Bounds.left, _
			pBall->Bounds.top, _
			pBall->Bounds.right, _
			pBall->Bounds.bottom _
		)
		
	End If
	
End Sub

Sub DrawCell( _
		ByVal hDC As HDC, _
		ByVal pBrushes As SceneBrushes Ptr, _
		ByVal pCell As Cell Ptr _
	)
	
	Dim PositionMatrix As XFORM = Any
	SetPositionMatrix(@PositionMatrix, @pCell->Position)
	ModifyWorldTransform(hDC, @PositionMatrix, MWT_LEFTMULTIPLY)
	
	Dim OldBrush As HGDIOBJ = Any
	
	Dim MarginX As Long = 0
	Dim MarginY As Long = 0
	
	If pCell->Selected Then
		' Чёрный прямоугольник
		OldBrush = SelectObject(hDC, Cast(HBRUSH, GetStockObject(BLACK_BRUSH)))
		Rectangle( _
			hDC, _
			pCell->Bounds.left, _
			pCell->Bounds.top, _
			pCell->Bounds.right, _
			pCell->Bounds.bottom _
		)
		SelectObject(hDC, OldBrush)
		MarginX = 1
		MarginY = 1
	End If
	
	' Тёмно-серый прямоугольник
	OldBrush = SelectObject(hDC, Cast(HBRUSH, GetStockObject(DKGRAY_BRUSH)))
	Rectangle( _
		hDC, _
		pCell->Bounds.left + MarginX, _
		pCell->Bounds.top + MarginY, _
		pCell->Bounds.right - MarginX, _
		pCell->Bounds.bottom - MarginY _
	)
	
	' Белый прямоугольник
	SelectObject(hDC, Cast(HBRUSH, GetStockObject(WHITE_BRUSH)))
	If pCell->Pressed Then
		Rectangle( _
			hDC, _
			pCell->Bounds.left - 1 + MarginX, _
			pCell->Bounds.top + MarginY, _
			pCell->Bounds.right - 1 - MarginX, _
			pCell->Bounds.bottom - MarginY _
		)
	Else
		Rectangle( _
			hDC, _
			pCell->Bounds.left + MarginX, _
			pCell->Bounds.top + MarginY, _
			pCell->Bounds.right - 1 - MarginX, _
			pCell->Bounds.bottom - 1 - MarginY _
		)
	End If
	
	' Серый прямоугольник
	SelectObject(hDC, Cast(HBRUSH, GetStockObject(GRAY_BRUSH)))
	If pCell->Pressed Then
		Rectangle( _
			hDC, _
			pCell->Bounds.left - 1 + MarginX, _
			pCell->Bounds.top - 1 + MarginY, _
			pCell->Bounds.right + 1 - MarginX, _
			pCell->Bounds.bottom + 1 - MarginY _
		)
	Else
		Rectangle( _
			hDC, _
			pCell->Bounds.left + 1 + MarginX, _
			pCell->Bounds.top + 1 + MarginY, _
			pCell->Bounds.right - 1 - MarginX, _
			pCell->Bounds.bottom - 1 - MarginY _
		)
	End If
	
	' Светло-серый прямоугольник
	SelectObject(hDC, Cast(HBRUSH, GetStockObject(LTGRAY_BRUSH)))
	Rectangle( _
		hDC, _
		pCell->Bounds.left + 1 + MarginX, _
		pCell->Bounds.top + 1 + MarginY, _
		pCell->Bounds.right - 2 - MarginX, _
		pCell->Bounds.bottom - 2 - MarginY _
	)
	
	If pCell->Selected Then
		' Рамка выделения
		Dim OldOldPen As HGDIOBJ = SelectObject(hDC, pBrushes->DashPen)
		SelectObject(hDC, Cast(HBRUSH, GetStockObject(HOLLOW_BRUSH)))
		MarginX += 4
		MarginY += 4
		Rectangle( _
			hDC, _
			pCell->Bounds.left + MarginX - 1, _
			pCell->Bounds.top + MarginY - 1, _
			pCell->Bounds.right - MarginX, _
			pCell->Bounds.bottom - MarginY _
		)
		SelectObject(hDC, OldOldPen)
	End If
	
	SelectObject(hDC, OldBrush)
	
End Sub

Sub SceneClear( _
		ByVal pScene As Scene Ptr _
	)
	
	' Прямоугольник обновления
	Dim SceneRectangle As RECT = Any
	SetRect(@SceneRectangle, 0, 0, pScene->Width, pScene->Height)
	
	FillRect(pScene->DeviceContext, @SceneRectangle, Cast(HBRUSH, GetStockObject(BLACK_BRUSH)))
	
End Sub

Function CreateScene( _
		ByVal hWin As HWND, _
		ByVal SceneWidth As UINT, _
		ByVal SceneHeight As UINT _
	)As Scene Ptr
	
	Dim pScene As Scene Ptr = Allocate(SizeOf(Scene))
	If pScene = NULL Then
		Return NULL
	End If
	
	pScene->Brushes.GrayBrush = CreateSolidBrush(rgbGray)
	pScene->Brushes.DarkGrayBrush = CreateSolidBrush(rgbDarkGray)
	pScene->Brushes.DashPen = CreatePen(PS_DOT, 1, rgbBlack)
	pScene->Brushes.BoundingPen = CreatePen(PS_SOLID, 2, rgbBlack)
	pScene->Brushes.RedBrush = CreateSolidBrush(rgbRed)
	pScene->Brushes.GreenBrush = CreateSolidBrush(rgbGreen)
	pScene->Brushes.BlueBrush = CreateSolidBrush(rgbBlue)
	pScene->Brushes.YellowBrush = CreateSolidBrush(rgbYellow)
	pScene->Brushes.MagentaBrush = CreateSolidBrush(rgbMagenta)
	pScene->Brushes.DarkRedBrush = CreateSolidBrush(rgbDarkRed)
	pScene->Brushes.CyanBrush = CreateSolidBrush(rgbCyan)
	
	Scope
		Dim WindowDC As HDC = GetDC(hWin)
		pScene->DeviceContext = CreateCompatibleDC(WindowDC)
		pScene->Bitmap = CreateCompatibleBitmap(WindowDC, SceneWidth, SceneHeight)
		ReleaseDC(hWin, WindowDC)
	End Scope
	
	pScene->OldBitmap = SelectObject(pScene->DeviceContext, pScene->Bitmap)
	
	pScene->Width = SceneWidth
	pScene->Height = SceneHeight
	
	SetGraphicsMode(pScene->DeviceContext, GM_ADVANCED)
	
	MatrixSetIdentity(@pScene->ProjectionMatrix)
	MatrixSetIdentity(@pScene->ViewMatrix)
	MatrixSetIdentity(@pScene->WorldMatrix)
	
	Return pScene
	
End Function

Sub DestroyScene( _
		ByVal pScene As Scene Ptr _
	)
	
	DeleteObject(pScene->Brushes.GrayBrush)
	DeleteObject(pScene->Brushes.DarkGrayBrush)
	DeleteObject(pScene->Brushes.DashPen)
	DeleteObject(pScene->Brushes.BoundingPen)
	DeleteObject(pScene->Brushes.RedBrush)
	DeleteObject(pScene->Brushes.GreenBrush)
	DeleteObject(pScene->Brushes.BlueBrush)
	DeleteObject(pScene->Brushes.YellowBrush)
	DeleteObject(pScene->Brushes.MagentaBrush)
	DeleteObject(pScene->Brushes.DarkRedBrush)
	DeleteObject(pScene->Brushes.CyanBrush)
	
	SelectObject(pScene->DeviceContext, pScene->OldBitmap)
	DeleteObject(pScene->Bitmap)
	DeleteDC(pScene->DeviceContext)
	
	Deallocate(pScene)
	
End Sub

Sub SceneRender( _
		ByVal pScene As Scene Ptr, _
		ByVal pStage As Stage Ptr _
	)
	
	SceneClear(pScene)
	
	' Старая матрица
	Dim OldMatrix As XFORM = Any
	GetWorldTransform(pScene->DeviceContext, @OldMatrix)
	
	ModifyWorldTransform(pScene->DeviceContext, @pScene->ProjectionMatrix, MWT_LEFTMULTIPLY)
	ModifyWorldTransform(pScene->DeviceContext, @pScene->ViewMatrix, MWT_LEFTMULTIPLY)
	ModifyWorldTransform(pScene->DeviceContext, @pScene->WorldMatrix, MWT_LEFTMULTIPLY)
	
	' Рисуем
	
	Scope
		Dim Buffer(511) As WCHAR = Any
		_itow(pStage->HiScore, @Buffer(0), 10)
		
		TextOutW( _
			pScene->DeviceContext, _
			pStage->Tablo(0).Bounds.left, _
			0, _
			@Buffer(0), _
			lstrlenw(@Buffer(0)) _
		)
	End Scope
	
	Scope
		Dim Buffer(511) As WCHAR = Any
		_itow(pStage->Score, @Buffer(0), 10)
		
		TextOutW( _
			pScene->DeviceContext, _
			pStage->Tablo(0).Bounds.left, _
			pStage->Tablo(2).Bounds.bottom, _
			@Buffer(0), _
			lstrlenw(@Buffer(0)) _
		)
	End Scope
	
	Dim OldPen As HGDIOBJ = SelectObject(pScene->DeviceContext, Cast(HPEN, GetStockObject(NULL_PEN)))
	' Ячейки
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			Dim OldWorldMatrix As XFORM = Any
			GetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
			
			DrawCell( _
				pScene->DeviceContext, _
				@pScene->Brushes, _
				@pStage->Lines(j, i) _
			)
			
			SetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
		Next
	Next
	' Табло
	For i As Integer = 0 To 2
		Dim OldWorldMatrix As XFORM = Any
		GetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
		
		DrawCell( _
			pScene->DeviceContext, _
			@pScene->Brushes, _
			@pStage->Tablo(i) _
		)
		
		SetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
	Next
	SelectObject(pScene->DeviceContext, OldPen)
	
	' Шары
	OldPen = SelectObject(pScene->DeviceContext, pScene->Brushes.BoundingPen)
	Dim OldBrush As HBRUSH = SelectObject(pScene->DeviceContext, Cast(HBRUSH, GetStockObject(NULL_BRUSH)))
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			Dim OldWorldMatrix As XFORM = Any
			GetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
			
			DrawBall( _
				pScene, _
				pScene->DeviceContext, _
				@pScene->Brushes, _
				@pStage->Lines(j, i).Ball _
			)
			
			SetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
		Next
	Next
	' Шары в табле
	For i As Integer = 0 To 2
		Dim OldWorldMatrix As XFORM = Any
		GetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
		
		DrawBall( _
			pScene, _
			pScene->DeviceContext, _
			@pScene->Brushes, _
			@pStage->Tablo(i).Ball _
		)
		
		SetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
	Next
	' Двигающийся шар
	Scope
		Dim OldWorldMatrix As XFORM = Any
		GetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
		
		DrawBall( _
			pScene, _
			pScene->DeviceContext, _
			@pScene->Brushes, _
			@pStage->MovedBall _
		)
		
		SetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
	End Scope
	SelectObject(pScene->DeviceContext, OldPen)
	SelectObject(pScene->DeviceContext, OldBrush)
	
	SetWorldTransform(pScene->DeviceContext, @OldMatrix)
	
End Sub

Sub SceneTranslateBounds( _
		ByVal pScene As Scene Ptr, _
		ByVal pObjectBounds As RECT Ptr, _
		ByVal pPosition As Transformation Ptr, _
		ByVal pScreenBounds As RECT Ptr _
	)
	
	Dim WorldMatrix As XFORM = Any
	Scope
		Dim OutMatrix As XFORM = Any
		CombineTransform(@OutMatrix, @pScene->ProjectionMatrix, @pScene->ViewMatrix)
		
		CombineTransform(@WorldMatrix, @OutMatrix, @pScene->WorldMatrix)
	End Scope
	
	Dim PositionMatrix As XFORM = Any
	SetPositionMatrix(@PositionMatrix, pPosition)
	
	Scope
		Dim OutMatrix As XFORM = Any
		CombineTransform(@OutMatrix, @PositionMatrix, @WorldMatrix)
		
		WorldMatrix = OutMatrix
	End Scope
	
	' Вектор объекта на экране 1
	Dim LeftTopSceneVectorI As Vector2DI = Any
	Scope
		' Вектор объекта на сцене
		Dim LeftTopStageVectorF As Vector2DF = Any
		LeftTopStageVectorF.X = CSng(pObjectBounds->left)
		LeftTopStageVectorF.Y = CSng(pObjectBounds->top)
		
		Dim LeftTopSceneVectorF As Vector2DF = Any
		MultipleVector(@LeftTopSceneVectorF, @WorldMatrix, @LeftTopStageVectorF)
		
		ConvertVector2DFToVector2DI(@LeftTopSceneVectorI, @LeftTopSceneVectorF)
	End Scope
	
	' Вектор объекта на экране 2
	Dim RightBottomSceneVectorI As Vector2DI = Any
	Scope
		' Вектор объекта на сцене
		Dim RightBottomStageVectorF As Vector2DF = Any
		RightBottomStageVectorF.X = CSng(pObjectBounds->right)
		RightBottomStageVectorF.Y = CSng(pObjectBounds->bottom)
		
		Dim RightBottomSceneVectorF As Vector2DF = Any
		MultipleVector(@RightBottomSceneVectorF, @WorldMatrix, @RightBottomStageVectorF)
		
		ConvertVector2DFToVector2DI(@RightBottomSceneVectorI, @RightBottomSceneVectorF)
	End Scope
	
	SetRect(pScreenBounds, _
		LeftTopSceneVectorI.X, _
		LeftTopSceneVectorI.Y, _
		RightBottomSceneVectorI.X, _
		RightBottomSceneVectorI.Y _
	)
	
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

Sub SceneSetProjectionMatrix( _
		ByVal pScene As Scene Ptr, _
		ByVal pProjectionMatrix As XFORM Ptr _
	)
	
	pScene->ProjectionMatrix = *pProjectionMatrix
	
End Sub

Sub SceneSetViewMatrix( _
		ByVal pScene As Scene Ptr, _
		ByVal pViewMatrix As XFORM Ptr _
	)
	
	pScene->ViewMatrix = *pViewMatrix
	
End Sub

Sub SceneSetWorldMatrix( _
		ByVal pScene As Scene Ptr, _
		ByVal pWorldMatrix As XFORM Ptr _
	)
	
	pScene->WorldMatrix = *pWorldMatrix
	
End Sub
