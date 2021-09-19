#include once "Scene.bi"
#include once "GdiMatrix.bi"
#include once "windows.bi"
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

Enum
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
		ByVal hDC As HDC, _
		ByVal pBrushes As SceneBrushes Ptr, _
		ByVal pBall As ColorBall Ptr _
	)
	
	' тип движения:
	' - появление из точки в нормальный размер (от 0 до 9)
	' - прыжки при выборе мышью (от 0 до 5 и обратно)
	' - уничтожение, рассыпался в прах (от 9 до 0)
	' координаты
	
	Dim OldBrush As HGDIOBJ = Any
	
	If pBall->Exist Then
		
		Select Case CInt(pBall->Color)
			
			Case BallColors.Red
				' OldPen = SelectObject(hDC, pBrushes->GreenPen)
				OldBrush = SelectObject(hDC, pBrushes->RedBrush)
				
			Case BallColors.Green
				' OldPen = SelectObject(hDC, pBrushes->GreenPen)
				OldBrush = SelectObject(hDC, pBrushes->GreenBrush)
				
			Case BallColors.Blue
				' OldPen = SelectObject(hDC, pBrushes->GreenPen)
				OldBrush = SelectObject(hDC, pBrushes->BlueBrush)
				
			Case BallColors.Yellow
				' OldPen = SelectObject(hDC, pBrushes->GreenPen)
				OldBrush = SelectObject(hDC, pBrushes->YellowBrush)
				
			Case BallColors.Magenta
				' OldPen = SelectObject(hDC, pBrushes->GreenPen)
				OldBrush = SelectObject(hDC, pBrushes->MagentaBrush)
				
			Case BallColors.DarkRed
				' OldPen = SelectObject(hDC, pBrushes->GreenPen)
				OldBrush = SelectObject(hDC, pBrushes->DarkRedBrush)
				
			Case Else ' BallColors.Cyan
				' OldPen = SelectObject(hDC, pBrushes->GreenPen)
				OldBrush = SelectObject(hDC, pBrushes->CyanBrush)
				
		End Select
		
		Ellipse( _
			hDC, _
			pBall->Rectangle.left, _
			pBall->Rectangle.top, _
			pBall->Rectangle.right, _
			pBall->Rectangle.bottom _
		)
		
		' SelectObject(hDC, OldPen)
		SelectObject(hDC, OldBrush)
	End If
	
End Sub

Sub DrawCell( _
		ByVal hDC As HDC, _
		ByVal pBrushes As SceneBrushes Ptr, _
		ByVal pCell As Cell Ptr _
	)
	
	Dim OldPen As HGDIOBJ = SelectObject(hDC, Cast(HPEN, GetStockObject(NULL_PEN)))
	Dim OldBrush As HGDIOBJ = Any
	
	Dim dx As UINT = 0
	Dim dy As UINT = 0
	
	If pCell->Selected Then
		OldBrush = SelectObject(hDC, Cast(HBRUSH, GetStockObject(BLACK_BRUSH)))
		
		' Чёрный прямоугольник
		Rectangle( _
			hDC, _
			pCell->Rectangle.left, _
			pCell->Rectangle.top, _
			pCell->Rectangle.right, _
			pCell->Rectangle.bottom _
		)
		SelectObject(hDC, OldBrush)
		dx = 1
		dy = 1
	End If
	
	' Тёмно-серый прямоугольник
	OldBrush = SelectObject(hDC, Cast(HBRUSH, GetStockObject(DKGRAY_BRUSH)))
	Rectangle( _
		hDC, _
		pCell->Rectangle.left + dx, _
		pCell->Rectangle.top + dy, _
		pCell->Rectangle.right - dx, _
		pCell->Rectangle.bottom - dy _
	)
	
	' Белый прямоугольник
	SelectObject(hDC, Cast(HBRUSH, GetStockObject(WHITE_BRUSH)))
	Rectangle( _
		hDC, _
		pCell->Rectangle.left + dx, _
		pCell->Rectangle.top + dy, _
		pCell->Rectangle.right - 1 - dx, _
		pCell->Rectangle.bottom - 1 - dy _
	)
	
	' Серый прямоугольник
	SelectObject(hDC, Cast(HBRUSH, GetStockObject(GRAY_BRUSH)))
	Rectangle( _
		hDC, _
		pCell->Rectangle.left + 1 + dx, _
		pCell->Rectangle.top + 1 + dy, _
		pCell->Rectangle.right - 1 - dx, _
		pCell->Rectangle.bottom - 1 - dy _
	)
	
	' Светло-серый прямоугольник
	SelectObject(hDC, Cast(HBRUSH, GetStockObject(LTGRAY_BRUSH)))
	Rectangle( _
		hDC, _
		pCell->Rectangle.left + 1 + dx, _
		pCell->Rectangle.top + 1 + dy, _
		pCell->Rectangle.right - 2 - dx, _
		pCell->Rectangle.bottom - 2 - dy _
	)
	
	If pCell->Selected Then
		SelectObject(hDC, Cast(HBRUSH, GetStockObject(HOLLOW_BRUSH)))
		Dim OldOldPen As HGDIOBJ = SelectObject(hDC, pBrushes->DashPen)
		dx += 4
		dy += 4
		Rectangle( _
			hDC, _
			pCell->Rectangle.left + dx, _
			pCell->Rectangle.top + dy, _
			pCell->Rectangle.right - dx, _
			pCell->Rectangle.bottom - dy _
		)
		SelectObject(hDC, OldOldPen)
	End If
	
	DrawBall(hDC, pBrushes, @pCell->Ball)
	
	SelectObject(hDC, OldBrush)
	SelectObject(hDC, OldPen)
	
End Sub

Sub SceneClear( _
		ByVal pScene As Scene Ptr _
	)
	
	' Прямоугольник обновления
	Dim SceneRectangle As RECT = Any
	SetRect(@SceneRectangle, 0, 0, pScene->Width, pScene->Height)
	
	FillRect(pScene->DeviceContext, @SceneRectangle, Cast(HBRUSH, GetStockObject(BLACK_BRUSH)))
	
End Sub

Sub SetProjectionMatrix( _
		ByVal hDC As HDC, _
		ByVal pProjectionMatrix As XFORM Ptr _
	)
	
	ModifyWorldTransform(hDC, pProjectionMatrix, MWT_LEFTMULTIPLY)
	
End Sub

Sub SetViewMatrix( _
		ByVal hDC As HDC, _
		ByVal pViewMatrix As XFORM Ptr _
	)
	
	ModifyWorldTransform(hDC, pViewMatrix, MWT_LEFTMULTIPLY)
	
End Sub

Sub SetWorldMatrix( _
		ByVal hDC As HDC, _
		ByVal pWorldMatrix As XFORM Ptr _
	)
	
	ModifyWorldTransform(hDC, pWorldMatrix, MWT_LEFTMULTIPLY)
	
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
	
	/'
	Scope
		// Создайте путь, состоящий из одного эллипса.
		GraphicsPath path;
		path.AddEllipse(0, 0, 200, 100);
		
		// Создайте кисть градиента контура на основе эллиптического контура.
		PathGradientBrush pthGrBrush(&path);
		pthGrBrush.SetGammaCorrection(TRUE);
		
		// Установите цвет по всей границе на синий.
		Color color(Color(255, 0, 0, 255));
		INT num = 1;
		pthGrBrush.SetSurroundColors(&color, &num);
		
		// Установите для центрального цвета значение aqua.
		pthGrBrush.SetCenterColor(Color(255, 0, 255, 255));
		
		// Используйте кисть градиента контура, чтобы заполнить эллипс. 
		graphics.FillPath(&pthGrBrush, &path);
		
		// Установите масштаб фокусировки для кисти градиента контура.
		pthGrBrush.SetFocusScales(0.3f, 0.8f);
		
		// Используйте кисть градиента контура, чтобы снова заполнить эллипс.
		// Покажите этот заполненный эллипс справа от первого заполненного эллипса.
		graphics.TranslateTransform(220.0f, 0.0f);
		graphics.FillPath(&pthGrBrush, &path);		
	End Scope
	'/
	
	/'
	Scope
		' declare function GdipSetWorldTransform(byval as GpGraphics ptr, byval as GpMatrix ptr) as GpStatus
		' declare function GdipResetWorldTransform(byval as GpGraphics ptr) as GpStatus
		' declare function GdipMultiplyWorldTransform(byval as GpGraphics ptr, byval as const GpMatrix ptr, byval as GpMatrixOrder) as GpStatus
		' declare function GdipTranslateWorldTransform(byval as GpGraphics ptr, byval as REAL, byval as REAL, byval as GpMatrixOrder) as GpStatus
		' declare function GdipScaleWorldTransform(byval as GpGraphics ptr, byval as REAL, byval as REAL, byval as GpMatrixOrder) as GpStatus
		' declare function GdipRotateWorldTransform(byval as GpGraphics ptr, byval as REAL, byval as GpMatrixOrder) as GpStatus
		' declare function GdipGetWorldTransform(byval as GpGraphics ptr, byval as GpMatrix ptr) as GpStatus
		
		Dim pGraphics As GdiPlus.GpGraphics Ptr = Any
		GdiPlus.GdipCreateFromHDC(pScene->DeviceContext, @pGraphics)
		
		Scope
			Dim pPath As GdiPlus.GpPath Ptr = Any
			GdiPlus.GdipCreatePath( _
				GdiPlus.FillModeAlternate, _
				@pPath _
			)
			GdiPlus.FillModeWinding
			
			GdiPlus.GdipAddPathEllipseI(pPath, 100, 100, 40, 40)
			
			Scope
				Dim pBrush As GdiPlus.GpPathGradient Ptr = Any
				GdiPlus.GdipCreatePathGradientFromPath( _
					pPath, _
					@pBrush _
				)
				
				GdiPlus.GdipSetPathGradientGammaCorrection(pBrush, TRUE)
				
				Dim argbColor As GdiPlus.ARGB = argbBlue
				Dim count As INT_ = 1
				GdiPlus.GdipSetPathGradientSurroundColorsWithCount( _
					pBrush, _
					@argbColor, _
					@count _
				)
				
				Const argbLightBlue = &hFF8080FF
				GdiPlus.GdipSetPathGradientCenterColor( _
					pBrush, _
					argbLightBlue _
				)
				
				GdiPlus.GdipFillPath( _
					pGraphics, _
					pBrush, _
					pPath _
				)
				
				
				
				
				GdiPlus.GdipTranslateWorldTransform( _
					pGraphics, 40.0, 0.0, GdiPlus.MatrixOrderPrepend)
				
				GdiPlus.GdipFillPath( _
					pGraphics, _
					pBrush, _
					pPath _
				)
				
				GdiPlus.GdipTranslateWorldTransform( _
					pGraphics, 40.0, 0.0, GdiPlus.MatrixOrderPrepend)
				
				GdiPlus.GdipFillPath( _
					pGraphics, _
					pBrush, _
					pPath _
				)
				
				GdiPlus.GdipTranslateWorldTransform( _
					pGraphics, 40.0, 0.0, GdiPlus.MatrixOrderPrepend)
				
				GdiPlus.GdipFillPath( _
					pGraphics, _
					pBrush, _
					pPath _
				)
				
				
				
				
				
				
				' GdiPlus.GdipResetPath(pPath)
				' GdiPlus.GdipAddPathEllipseI(pPath, 200, 200, 100, 100)
				' GdiPlus.GdipSetPathGradientPath(pBrush, pPath)
				
				' argbColor = argbRed
				' count = 1
				' GdiPlus.GdipSetPathGradientSurroundColorsWithCount( _
					' pBrush, _
					' @argbColor, _
					' @count _
				' )
				
				' Const argbLightRed = &hFFFF8080
				' GdiPlus.GdipSetPathGradientCenterColor( _
					' pBrush, _
					' argbLightRed _
				' )
				
				' GdiPlus.GdipFillPath( _
					' pGraphics, _
					' pBrush, _
					' pPath _
				' )
				
				
				
				
				
				
				
				GdiPlus.GdipDeleteBrush(pBrush)
				
			End Scope
			
			GdiPlus.GdipDeletePath(pPath)
			
		End Scope
		
		GdiPlus.GdipDeleteGraphics(pGraphics) 
	End Scope
	'/
	
	/'
	Scope
		
		Dim pGraphics As GdiPlus.GpGraphics Ptr = Any
		GdiPlus.GdipCreateFromHDC(pScene->DeviceContext, @pGraphics)
		
		Dim rc As GdiPlus.GpRect = Any
		rc.X = 0
		rc.Y = 0
		rc.Width = 100
		rc.Height = 100
		
		Dim pBrush As GdiPlus.GpLineGradient Ptr = Any
		GdiPlus.GdipCreateLineBrushFromRectI( _
			@rc, _
			argbWhite, _
			argbRed, _
			GdiPlus.LinearGradientModeForwardDiagonal, _
			GdiPlus.WrapModeTile, _
			@pBrush _
		) ' as GdiPlus.GpStatus
		
		'' draw an ellipse
		GdiPlus.GdipFillEllipseI(pGraphics, pBrush, rc.X, rc.Y, rc.Width, rc.Height)
		
		'' destroy the brush
		GdiPlus.GdipDeleteBrush(pBrush)
		
		GdiPlus.GdipDeleteGraphics(pGraphics) 
	End Scope
	'/
	
	/'
	Dim oldMode As Long = GetMapMode(pScene->DeviceContext)
	SetMapMode(pScene->DeviceContext, MM_ISOTROPIC)
	
	' установка логической системы координат
	' сx, сy - новые значения размеров по осям
	Dim oldWindowExt As SIZE = Any
	SetWindowExtEx(pScene->DeviceContext, pScene->Width, pScene->Height, @oldWindowExt)
	
	' Настраивает размеры физической области вывода
	' Если изначально система координат установлена таким образом
	' что ось y направлена вниз, можно "перевернуть" её
	' задав отрицательное значение по оси y
	' сx, сy - новые значения размеров по осям.
	Dim oldViewportExt As SIZE = Any
	SetViewportExtEx(pScene->DeviceContext, pScene->Width, -1 * pScene->Height, @oldViewportExt)
	
	' перенос начала координат физической области вывода
	' (x, y) - физические координаты точки, которую нужно сделать началом координат
	Dim oldViewportOrg As POINT = Any
	SetViewportOrgEx(pScene->DeviceContext, pScene->Width \ 2, pScene->Height \ 2, @oldViewportOrg)
	'/
	
	SceneClear(pScene)
	
	' Старая матрица
	Dim OldMatrix As XFORM = Any
	GetWorldTransform(pScene->DeviceContext, @OldMatrix)
	
	SetProjectionMatrix( _
		pScene->DeviceContext, _
		@pScene->ProjectionMatrix _
	)
	
	SetViewMatrix( _
		pScene->DeviceContext, _
		@pScene->ViewMatrix _
	)
	
	SetWorldMatrix( _
		pScene->DeviceContext, _
		@pScene->WorldMatrix _
	)
	
	' Рисуем
	
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
	
	Scope
		Dim OldWorldMatrix As XFORM = Any
		GetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
		
		' Двигающийся шар
		DrawBall( _
			pScene->DeviceContext, _
			@pScene->Brushes, _
			@pStage->MovedBall _
		)
		
		SetWorldTransform(pScene->DeviceContext, @OldWorldMatrix)
	End Scope
	
	' Табло с тремя новыми шарами
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
	
	SetWorldTransform(pScene->DeviceContext, @OldMatrix)
	
	/'
	SetViewportOrgEx(pScene->DeviceContext, oldViewportOrg.x, oldViewportOrg.y, NULL)
	SetViewportExtEx(pScene->DeviceContext, oldViewportExt.cx, oldViewportExt.cy, NULL)
	SetWindowExtEx(pScene->DeviceContext, oldWindowExt.cx, oldWindowExt.cy, NULL)
	SetMapMode(pScene->DeviceContext, oldMode)
	'/
	
End Sub

Sub SceneTranslateRectangle( _
		ByVal pScene As Scene Ptr, _
		ByVal pStage As Stage Ptr, _
		ByVal pRectangle As RECT Ptr, _
		ByVal pTranslatedRectangle As RECT Ptr _
	)
	
	Dim OutMatrix As XFORM = Any
	CombineTransform(@OutMatrix, @pScene->ProjectionMatrix, @pScene->ViewMatrix)
	
	Dim OutMatrix2 As XFORM = Any
	CombineTransform(@OutMatrix2, @OutMatrix, @pScene->WorldMatrix)
	
	' Вектор
	Dim LeftTopStageVector As Vector2DF = Any
	LeftTopStageVector.X = CSng(pRectangle->left)
	LeftTopStageVector.Y = CSng(pRectangle->Top)
	
	Dim LeftTopSceneVectorF As Vector2DF = Any
	MultipleVector(@LeftTopSceneVectorF, @OutMatrix2, @LeftTopStageVector)
	
	Dim LeftTopSceneVectorI As Vector2DI = Any
	ConvertVector2DFToVector2DI(@LeftTopSceneVectorI, @LeftTopSceneVectorF)
	
	Dim RightBottomStageVector As Vector2DF = Any
	RightBottomStageVector.X = CSng(pRectangle->right)
	RightBottomStageVector.Y = CSng(pRectangle->bottom)
	
	Dim RightBottomSceneVectorF As Vector2DF = Any
	MultipleVector(@RightBottomSceneVectorF, @OutMatrix2, @RightBottomStageVector)
	
	Dim RightBottomSceneVectorI As Vector2DI = Any
	ConvertVector2DFToVector2DI(@RightBottomSceneVectorI, @RightBottomSceneVectorF)
	
	SetRect(pTranslatedRectangle, _
		LeftTopSceneVectorI.X - 1, _
		LeftTopSceneVectorI.Y - 1, _
		RightBottomSceneVectorI.X + 1, _
		RightBottomSceneVectorI.Y + 1 _
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

Sub SceneClick( _
		ByVal pScene As Scene Ptr, _
		ByVal pStage As Stage Ptr, _
		ByVal pScreenPoint As POINT Ptr _
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
