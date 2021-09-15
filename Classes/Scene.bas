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
	
	' ��� �����
	GrayBrush As HBRUSH
	DarkGrayBrush As HBRUSH
	
	' ��� �����
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

' ���������� ������� ��� �������� ���������������
Sub MatrixSetScale( _
		ByVal m As XFORM Ptr, _
		ByVal ScaleX As Single, _
		ByVal ScaleY As Single _
	)
	
	m->eM11 = ScaleX : m->eM21 = 0.0    : m->eDx = 0.0
	m->eM12 = 0.0    : m->eM22 = ScaleY : m->eDy = 0.0
	' 0              : 0                : 1
	
End Sub

' ���������� ������� ��� �������� ��������
Sub MatrixSetTranslate( _
		ByVal m As XFORM Ptr, _
		ByVal dx As Single, _
		ByVal dy As Single _
	)
	
	m->eM11 = 1.0 : m->eM21 = 0.0 : m->eDx = dx
	m->eM12 = 0.0 : m->eM22 = 1.0 : m->eDy = dy
	' 0           : 0             : 1
	
End Sub

' ���������� ������� ��� �������� ��������
' � �������������� ������� ���������
Sub MatrixSetRRotate( _
		ByVal m As XFORM Ptr, _
		ByVal AngleSine As Single, _
		ByVal AngleCosine As Single _
	)
	
	m->eM11 = AngleCosine : m->eM21 = -AngleSine  : m->eDx = 0.0
	m->eM12 = AngleSine   : m->eM22 = AngleCosine : m->eDy = 0.0
	' 0                   : 0                     : 1
	
End Sub

' ���������� ������� ��� �������� ��������
' � ������������� ������� ���������
Sub MatrixSetLRotate( _
		ByVal m As XFORM Ptr, _
		ByVal AngleSine As Single, _
		ByVal AngleCosine As Single _
	)
	
	m->eM11 = AngleCosine : m->eM21 = AngleSine   : m->eDx = 0.0
	m->eM12 = -AngleSine  : m->eM22 = AngleCosine : m->eDy = 0.0
	' 0                   : 0                     : 1
	
End Sub

' ���������� ������� ��� �������� ���������
Sub MatrixSetReflect( _
		ByVal m As XFORM Ptr, _
		ByVal x As Boolean, _
		ByVal y As Boolean _
	)
	
	' ��������� dx � dy
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

' ���������� ������� ��� �������� ������
Sub MatrixSetShear( _
		ByVal m As XFORM Ptr, _
		ByVal Horizontal As Single, _
		ByVal Vertical As Single _
	)
	
	m->eM11 = 1.0        : m->eM21 = Vertical : m->eDx = 0.0
	m->eM12 = Horizontal : m->eM22 = 1.0      : m->eDy = 0.0
	' 0                  : 0                  : 1
	
End Sub

' ���������� ������� ��������� ��������
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
	
	Dim OldPen As HGDIOBJ = Any
	Dim OldBrush As HGDIOBJ = Any
	
	OldPen = SelectObject(hDC, Cast(HPEN, GetStockObject(NULL_PEN)))
	
	' Ҹ���-����� �������������
	OldBrush = SelectObject(hDC, Cast(HBRUSH, GetStockObject(DKGRAY_BRUSH)))
	Rectangle( _
		hDC, _
		pCell->Rectangle.left, _
		pCell->Rectangle.top, _
		pCell->Rectangle.right, _
		pCell->Rectangle.bottom _
	)
	
	' ����� �������������
	SelectObject(hDC, Cast(HBRUSH, GetStockObject(WHITE_BRUSH)))
	Rectangle( _
		hDC, _
		pCell->Rectangle.left, _
		pCell->Rectangle.top, _
		pCell->Rectangle.right - 1, _
		pCell->Rectangle.bottom - 1 _
	)
	
	' ����� �������������
	SelectObject(hDC, Cast(HBRUSH, GetStockObject(GRAY_BRUSH)))
	Rectangle( _
		hDC, _
		pCell->Rectangle.left + 1, _
		pCell->Rectangle.top + 1, _
		pCell->Rectangle.right - 2, _
		pCell->Rectangle.bottom - 2 _
	)
	
	' ����� �������������
	SelectObject(hDC, Cast(HBRUSH, GetStockObject(LTGRAY_BRUSH)))
	Rectangle( _
		hDC, _
		pCell->Rectangle.left + 1, _
		pCell->Rectangle.top + 1, _
		pCell->Rectangle.right - 3, _
		pCell->Rectangle.bottom - 3 _
	)
	
	DrawBall(hDC, pBrushes, @pCell->Ball)
	
	SelectObject(hDC, OldBrush)
	SelectObject(hDC, OldPen)
	
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
	
	' ����� � �����
	pScene->Brushes.GrayBrush = CreateSolidBrush(rgbGray)
	pScene->Brushes.DarkGrayBrush = CreateSolidBrush(rgbDarkGray)
	
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
	
	' �������� ������� �������, �������� ������
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
		// �������� ����, ��������� �� ������ �������.
		GraphicsPath path;
		path.AddEllipse(0, 0, 200, 100);
		
		// �������� ����� ��������� ������� �� ������ �������������� �������.
		PathGradientBrush pthGrBrush(&path);
		pthGrBrush.SetGammaCorrection(TRUE);
		
		// ���������� ���� �� ���� ������� �� �����.
		Color color(Color(255, 0, 0, 255));
		INT num = 1;
		pthGrBrush.SetSurroundColors(&color, &num);
		
		// ���������� ��� ������������ ����� �������� aqua.
		pthGrBrush.SetCenterColor(Color(255, 0, 255, 255));
		
		// ����������� ����� ��������� �������, ����� ��������� ������. 
		graphics.FillPath(&pthGrBrush, &path);
		
		// ���������� ������� ����������� ��� ����� ��������� �������.
		pthGrBrush.SetFocusScales(0.3f, 0.8f);
		
		// ����������� ����� ��������� �������, ����� ����� ��������� ������.
		// �������� ���� ����������� ������ ������ �� ������� ������������ �������.
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
	
	' declare function CombineTransform(byval lpxfOut as LPXFORM, byval lpxf1 as const XFORM ptr, byval lpxf2 as const XFORM ptr) as WINBOOL
	
	/'
	Dim oldMode As Long = GetMapMode(pScene->DeviceContext)
	SetMapMode(pScene->DeviceContext, MM_ISOTROPIC)
	
	' ��������� ���������� ������� ���������
	' �x, �y - ����� �������� �������� �� ����
	Dim oldWindowExt As SIZE = Any
	SetWindowExtEx(pScene->DeviceContext, pScene->Width, pScene->Height, @oldWindowExt)
	
	' ������������ ��������� �������� ���������� ������� ������
	' ���� ���������� ������� ��������� ���� ����������� ����� �������
	' ��� ��� y ���������� ����, ����� "�����������" ��, ����� ������������� �������� �� ��� y
	' �x, �y - ����� �������� �������� �� ����.
	Dim oldViewportExt As SIZE = Any
	SetViewportExtEx(pScene->DeviceContext, pScene->Width, -1 * pScene->Height, @oldViewportExt)
	
	' ������� ������ ��������� ���������� ������� ������
	' (x, y) - ���������� ���������� �����, ������� ����� ������� ������� ���������
	Dim oldViewportOrg As POINT = Any
	SetViewportOrgEx(pScene->DeviceContext, pScene->Width \ 2, pScene->Height \ 2, @oldViewportOrg)
	'/
	
	' ������ �������
	Dim OldMatrix As XFORM = Any
	GetWorldTransform(pScene->DeviceContext, @OldMatrix)
	
	Dim ScaleX As Single = max(1.0, CSng(pScene->Width) / CSng(pStage->Lines(0, 0).Rectangle.left + pStage->Lines(0, 8).Rectangle.right))
	Dim ScaleY As Single = max(1.0, CSng(pScene->Height) / CSng(pStage->Lines(0, 0).Rectangle.top + pStage->Lines(8, 8).Rectangle.bottom))
	Dim Scale As Single = min(ScaleX, ScaleY)
	
	Dim StretchingMatrix As XFORM = Any
	MatrixSetScale(@StretchingMatrix, Scale, Scale)
	SetWorldTransform(pScene->DeviceContext, @StretchingMatrix)
	
	Dim OldPen As HGDIOBJ = Any
	' Dim OldBrush As HGDIOBJ = Any
	
	' ������������� ����������
	Dim MemoryBMRectangle As RECT = Any
	SetRect(@MemoryBMRectangle, 0, 0, pScene->Width, pScene->Height)
	
	' �������
	FillRect(pScene->DeviceContext, @MemoryBMRectangle, Cast(HBRUSH, GetStockObject(BLACK_BRUSH)))
	
	' ������
	OldPen = SelectObject(pScene->DeviceContext, Cast(HBRUSH, GetStockObject(WHITE_PEN)))
	
	' ������
			' OldBrush = SelectObject(pScene->DeviceContext, pScene->DarkGrayBrush)
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			DrawCell( _
				pScene->DeviceContext, _
				@pScene->Brushes, _
				@pStage->Lines(j, i) _
			)
		Next
	Next
			' SelectObject(pScene->DeviceContext, OldBrush)
	
	' ����������� ���
	' ��� ��������:
	' - ��������� �� ����� � ���������� ������ (�� 0 �� 9)
	' - ������ ��� ������ ����� (�� 0 �� 5 � �������)
	' - �����������, ���������� � ���� (�� 9 �� 0)
	' ����������
	If pStage->MovedBall.Exist Then
	End If
	
	' ����� � ����� ������ ������
	For i As Integer = 0 To 2
		DrawCell( _
			pScene->DeviceContext, _
			@pScene->Brushes, _
			@pStage->Tablo(i) _
		)
	Next
	
	SelectObject(pScene->DeviceContext, OldPen)
	
	SetWorldTransform(pScene->DeviceContext, @OldMatrix)
	
	/'
	SetViewportOrgEx(pScene->DeviceContext, oldViewportOrg.x, oldViewportOrg.y, NULL)
	SetViewportExtEx(pScene->DeviceContext, oldViewportExt.cx, oldViewportExt.cy, NULL)
	SetWindowExtEx(pScene->DeviceContext, oldWindowExt.cx, oldWindowExt.cy, NULL)
	SetMapMode(pScene->DeviceContext, oldMode)
	'/
	
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
