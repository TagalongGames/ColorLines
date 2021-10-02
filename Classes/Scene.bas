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

Type COLOR16RGB
	Red As COLOR16
	Green As COLOR16
	Blue As COLOR16
	Alpha As COLOR16
End Type

Type SceneBrushes
	
	GrayBrush As HBRUSH
	DarkGrayBrush As HBRUSH
	DashPen As HPEN
	BoundingPen As HPEN
	
End Type

Type _Scene
	DeviceContext As HDC
	Bitmap As HBITMAP
	OldBitmap As HGDIOBJ
	
	Brushes As SceneBrushes
	
	Width As UINT
	Height As UINT
	
	WorldMatrix As XFORM
End Type

Sub GetCOLOR16RGB( _
		ByVal BallColor As BallColors, _
		ByVal pColor As COLOR16RGB Ptr _
	)
	
	Select Case BallColor
		
		Case BallColors.Red
			pColor->Red =   &hFF00
			pColor->Green = &h0000
			pColor->Blue  = &h0000
			pColor->Alpha = &hFF00
			
		Case BallColors.Green
			pColor->Red =   &h0000
			pColor->Green = &hFF00
			pColor->Blue  = &h0000
			pColor->Alpha = &hFF00
			
		Case BallColors.Blue
			pColor->Red =   &h0000
			pColor->Green = &h0000
			pColor->Blue  = &hFF00
			pColor->Alpha = &hFF00
			
		Case BallColors.Yellow
			pColor->Red =   &hFF00
			pColor->Green = &hFF00
			pColor->Blue  = &h0000
			pColor->Alpha = &hFF00
			
		Case BallColors.Magenta
			pColor->Red =   &hFF00
			pColor->Green = &h0000
			pColor->Blue  = &hFF00
			pColor->Alpha = &hFF00
			
		Case BallColors.DarkRed
			pColor->Red =   &h8000
			pColor->Green = &h0000
			pColor->Blue  = &h0000
			pColor->Alpha = &hFF00
			
		Case Else ' BallColors.Cyan
			pColor->Red =   &h0000
			pColor->Green = &hFF00
			pColor->Blue  = &hFF00
			pColor->Alpha = &hFF00
			
	End Select
	
End Sub

Sub DrawBall( _
		ByVal pScene As Scene Ptr, _
		ByVal hDC As HDC, _
		ByVal pBrushes As SceneBrushes Ptr, _
		ByVal pBall As ColorBall Ptr _
	)
	
	Dim PositionMatrix As XFORM = Any
	SetPositionMatrix(@PositionMatrix, @pBall->Position)
	ModifyWorldTransform(hDC, @PositionMatrix, MWT_LEFTMULTIPLY)
	
	If pBall->Visible Then
		
		Dim WorldMatrix As XFORM = Any
		Scope
			Dim OutMatrix As XFORM = Any
			CombineTransform(@OutMatrix, @PositionMatrix, @pScene->WorldMatrix)
			
			WorldMatrix = OutMatrix
		End Scope
		
		Dim elRgn As HRGN = CreateEllipticRgn( _
			pBall->Bounds.left, _
			pBall->Bounds.top, _
			pBall->Bounds.right + 2, _
			pBall->Bounds.bottom + 1 _
		)
		Dim nCount As DWORD = GetRegionData(elRgn, 0, NULL)
		
		Dim lpData As RGNDATA Ptr = Allocate(SizeOf(RGNDATA) * nCount)
		If lpData <> NULL Then
			GetRegionData(elRgn, nCount, lpData)
			
			Dim elRgn2 As HRGN = ExtCreateRegion(@WorldMatrix, nCount, lpData)
			
			Dim c As COLOR16RGB = Any
			GetCOLOR16RGB(pBall->Color, @c)
			
			Dim vertex(0 To 1) As TRIVERTEX = Any
			vertex(0).x     = pBall->Bounds.left
			vertex(0).y     = pBall->Bounds.top
			vertex(0).Red   = &hFF00
			vertex(0).Green = &hFF00
			vertex(0).Blue  = &hFF00
			vertex(0).Alpha = &hFF00
			
			vertex(1).x     = pBall->Bounds.right
			vertex(1).y     = pBall->Bounds.bottom
			vertex(1).Red   = c.Red
			vertex(1).Green = c.Green
			vertex(1).Blue  = c.Blue
			vertex(1).Alpha = &hFF00
			
			' Create a GRADIENT_RECT structure that 
			' references the TRIVERTEX vertices. 
			Dim gRect As GRADIENT_RECT = Any
			gRect.UpperLeft  = 0
			gRect.LowerRight = 1
			
			If pBall->Selected = False Then
				SelectClipRgn(hDC, elRgn2)
			End If
			
			' Draw a shaded rectangle. 
			GradientFill(hDC, @vertex(0), 2, @gRect, 1, GRADIENT_FILL_RECT_H)
			
			SelectClipRgn(hDC, NULL)
			
			DeleteObject(elRgn2)
			Deallocate(lpData)
		End If
		
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
	pScene->Brushes.BoundingPen = CreatePen(PS_SOLID, 1, rgbBlack)
	
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
	
	ModifyWorldTransform(pScene->DeviceContext, @pScene->WorldMatrix, MWT_LEFTMULTIPLY)
	
	' Рисуем
	/'
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
	'/
	
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
	' OldPen = SelectObject(pScene->DeviceContext, Cast(HPEN, GetStockObject(BLACK_PEN)))
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
	
	Dim PositionMatrix As XFORM = Any
	SetPositionMatrix(@PositionMatrix, pPosition)
	
	Dim WorldMatrix As XFORM = Any
	Scope
		Dim OutMatrix As XFORM = Any
		CombineTransform(@OutMatrix, @PositionMatrix, @pScene->WorldMatrix)
		
		WorldMatrix = OutMatrix
	End Scope
	
	Dim LeftTopSceneVectorI As Vector2DI = Any
	Scope
		Dim LeftTopStageVectorF As Vector2DF = Any
		LeftTopStageVectorF.X = CSng(pObjectBounds->left)
		LeftTopStageVectorF.Y = CSng(pObjectBounds->top)
		
		Dim LeftTopSceneVectorF As Vector2DF = Any
		MultipleVector(@LeftTopSceneVectorF, @WorldMatrix, @LeftTopStageVectorF)
		
		ConvertVector2DFToVector2DI(@LeftTopSceneVectorI, @LeftTopSceneVectorF)
	End Scope
	
	Dim RightBottomSceneVectorI As Vector2DI = Any
	Scope
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

Sub SceneScale( _
		ByVal pScene As Scene Ptr, _
		ByVal ScaleX As Single, _
		ByVal ScaleY As Single _
	)
	
	Dim m As XFORM = Any
	MatrixSetScale(@m, ScaleX, ScaleY)
	
	pScene->WorldMatrix = m
	
End Sub
