#include once "Scene.bi"
#include once "windows.bi"
#include once "win\ole2.bi"
#include once "win\GdiPlus.bi"
#include once "win\oleauto.bi"
#include once "crt.bi"

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
	
	TilesDeviceContext As HDC
	TilesBitmap As HBITMAP
	TilesOldBitmap As HGDIOBJ
	
	Brushes As SceneBrushes
	
	Width As UINT
	Height As UINT
	
End Type

' Заполнение матрицы для операции масштабирования
Sub MatrixSetScale( _
		ByVal m As XFORM Ptr, _
		ByVal ScaleX As Single, _
		ByVal ScaleY As Single _
	)
	
	m->eM11 = ScaleX : m->eM21 = 0.0    : m->eDx = 0.0
	m->eM12 = 0.0    : m->eM22 = ScaleY : m->eDy = 0.0
	' 0              : 0                : 1
	
End Sub

' Заполнение матрицы для операции переноса
Sub MatrixSetTranslate( _
		ByVal m As XFORM Ptr, _
		ByVal dx As Single, _
		ByVal dy As Single _
	)
	
	m->eM11 = 1.0 : m->eM21 = 0.0 : m->eDx = dx
	m->eM12 = 0.0 : m->eM22 = 1.0 : m->eDy = dy
	' 0           : 0             : 1
	
End Sub

' Заполнение матрицы для операции поворота
' В правосторонней системе координат
Sub MatrixSetRRotate( _
		ByVal m As XFORM Ptr, _
		ByVal AngleSine As Single, _
		ByVal AngleCosine As Single _
	)
	
	m->eM11 = AngleCosine : m->eM21 = -1.0 * AngleSine : m->eDx = 0.0
	m->eM12 = AngleSine   : m->eM22 = AngleCosine      : m->eDy = 0.0
	' 0                   : 0                          : 1
	
End Sub

' Заполнение матрицы для операции поворота
' В левосторонней системе координат
Sub MatrixSetLRotate( _
		ByVal m As XFORM Ptr, _
		ByVal AngleSine As Single, _
		ByVal AngleCosine As Single _
	)
	
	m->eM11 = AngleCosine      : m->eM21 = AngleSine   : m->eDx = 0.0
	m->eM12 = -1.0 * AngleSine : m->eM22 = AngleCosine : m->eDy = 0.0
	' 0                        : 0                     : 1
	
End Sub

' Заполнение матрицы для операции отражения
Sub MatrixSetReflect( _
		ByVal m As XFORM Ptr, _
		ByVal x As Boolean, _
		ByVal y As Boolean _
	)
	
	' Отражение dx и dy
	Dim dx As Single = Any
	If x Then
		dx = -1.0
	Else
		dx = 1.0
	End If
	
	Dim dy As Single = Any
	If y Then
		dy = -1.0
	Else
		dy = 1.0
	End If
	
	m->eM11 = dx  : m->eM21 = 0.0 : m->eDx = 0.0
	m->eM12 = 0.0 : m->eM22 = dy  : m->eDy = 0.0
	' 0           : 0             : 1
	
End Sub	

' Заполнение матрицы для операции сдвига
Sub MatrixSetShear( _
		ByVal m As XFORM Ptr, _
		ByVal Horizontal As Single, _
		ByVal Vertical As Single _
	)
	
	m->eM11 = 1.0        : m->eM21 = Vertical : m->eDx = 0.0
	m->eM12 = Horizontal : m->eM22 = 1.0      : m->eDy = 0.0
	' 0                  : 0                  : 1
	
End Sub

' Заполнение матрицы единичной матрицей
Sub MatrixSetIdentity( _
		ByVal m As XFORM Ptr _
	)
	
	m->eM11 = 1.0 : m->eM21 = 0.0 : m->eDx = 0.0
	m->eM12 = 0.0 : m->eM22 = 1.0 : m->eDy = 0.0
	' 0           : 0             : 1
	
End Sub

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
	
	' Проекция камеры на экран, размеры экрана = размерам камеры
	Scope
		Dim ScaleX As Single = max(1.0, CSng(pScene->Width) / CSng(StageGetWidth(pStage)))
		Dim ScaleY As Single = max(1.0, CSng(pScene->Height) / CSng(StageGetHeight(pStage)))
		Dim Scale As Single = min(ScaleX, ScaleY)
		
		Dim ProjectionMatrix As XFORM = Any
		MatrixSetScale(@ProjectionMatrix, Scale, Scale)
		SetProjectionMatrix( _
			pScene->DeviceContext, _
			@ProjectionMatrix _
		)
	End Scope
	
	' Проекция сцены на камеру
	Scope
		Dim ViewMatrix As XFORM = Any
		MatrixSetIdentity(@ViewMatrix)
		SetViewMatrix( _
			pScene->DeviceContext, _
			@ViewMatrix _
		)
	End Scope
	
	' Проекция объекта на сцену
	Scope
		Dim WorldMatrix As XFORM = Any
		MatrixSetIdentity(@WorldMatrix)
		SetWorldMatrix( _
			pScene->DeviceContext, _
			@WorldMatrix _
		)
	End Scope
	
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
	
	
	' declare function CombineTransform(byval lpxfOut as LPXFORM, byval lpxf1 as const XFORM ptr, byval lpxf2 as const XFORM ptr) as WINBOOL
	
	' Матрица
	Dim OutMatrix As XFORM = Any
	
	' Матрица проекции
	' Матрица камеры
	' Мировая матрица
	' Вектор
	' Проекция камеры на экран, размеры экрана = размерам камеры
	Dim ScaleX As Single = max(1.0, CSng(pScene->Width) / CSng(StageGetWidth(pStage)))
	Dim ScaleY As Single = max(1.0, CSng(pScene->Height) / CSng(StageGetHeight(pStage)))
	Dim Scale As Single = min(ScaleX, ScaleY)
	
	Dim ProjectionMatrix As XFORM = Any
	MatrixSetScale(@ProjectionMatrix, Scale, Scale)
	
	' Проекция сцены на камеру
	Dim ViewMatrix As XFORM = Any
	MatrixSetIdentity(@ViewMatrix)
	
	' Проекция объекта на сцену
	Dim WorldMatrix As XFORM = Any
	MatrixSetIdentity(@WorldMatrix)
	
	CombineTransform(@OutMatrix, @ProjectionMatrix, @ViewMatrix)
	
	Dim OutMatrix2 As XFORM = Any
	CombineTransform(@OutMatrix2, @OutMatrix, @WorldMatrix)
	
	' Dim OutMatrix3 As XFORM = Any
	' CombineTransform(@OutMatrix3, @OutMatrix2, @pRectangle)
	
	Dim fLeft As VARIANT = Any
	fLeft.vt = VT_R4
	fLeft.fltVal = CSng(pRectangle->left) * OutMatrix2.eM11 + CSng(pRectangle->top) * OutMatrix2.eM21 + OutMatrix2.eDx
	Dim nLeft As VARIANT = Any
	VariantInit(@nLeft)
	VariantChangeType(@nLeft, @fLeft, 0, VT_I4)
	
	Dim fTop As VARIANT = Any
	fTop.vt = VT_R4
	fTop.fltVal = CSng(pRectangle->left) * OutMatrix2.eM12 + CSng(pRectangle->top) * OutMatrix2.eM22 + OutMatrix2.eDy
	Dim nTop As VARIANT = Any
	VariantInit(@nTop)
	VariantChangeType(@nTop, @fTop, 0, VT_I4)
	
	Dim fRight As VARIANT = Any
	fRight.vt = VT_R4
	fRight.fltVal = CSng(pRectangle->right) * OutMatrix2.eM11 + CSng(pRectangle->bottom) * OutMatrix2.eM21 + OutMatrix2.eDx
	Dim nRight As VARIANT = Any
	VariantInit(@nRight)
	VariantChangeType(@nRight, @fRight, 0, VT_I4)
	
	Dim fBottom As VARIANT = Any
	fBottom.vt = VT_R4
	fBottom.fltVal = CSng(pRectangle->right) * OutMatrix2.eM12 + CSng(pRectangle->bottom) * OutMatrix2.eM22 + OutMatrix2.eDy
	Dim nBottom As VARIANT = Any
	VariantInit(@nBottom)
	VariantChangeType(@nBottom, @fBottom, 0, VT_I4)
	
	' pTranslatedRectangle->left = nLeft - 1
	' pTranslatedRectangle->top =  - 1
	' pTranslatedRectangle->right =  + 1
	' pTranslatedRectangle->bottom =  + 1
	
	SetRect(pTranslatedRectangle, _
		nLeft.lVal, _
		nTop.lVal, _
		nRight.lVal, _
		nBottom.lVal _
	)
	
	Dim buffer As WString * (512 + 1) = Any
	Const ffFormat = WStr("{%d, %d, %d, %d} = {%d, %d, %d, %d}")
	swprintf(@buffer, @ffFormat, pRectangle->left, pRectangle->top, pRectangle->right, pRectangle->bottom, pTranslatedRectangle->left, pTranslatedRectangle->top, pTranslatedRectangle->right, pTranslatedRectangle->bottom)
	buffer[255] = 0
	MessageBoxW(NULL, @buffer, NULL, MB_OK)
	
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
