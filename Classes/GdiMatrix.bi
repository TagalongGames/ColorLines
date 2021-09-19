#ifndef GDIMATRIX_BI
#define GDIMATRIX_BI

#include once "windows.bi"

Type Vector2DF
	X As Single
	Y As Single
End Type

Type Vector2DI
	X As Long
	Y As Long
End Type

' Заполнение матрицы для операции масштабирования
Declare Sub MatrixSetScale( _
	ByVal m As XFORM Ptr, _
	ByVal ScaleX As Single, _
	ByVal ScaleY As Single _
)

' Заполнение матрицы для операции переноса
Declare Sub MatrixSetTranslate( _
	ByVal m As XFORM Ptr, _
	ByVal dx As Single, _
	ByVal dy As Single _
)

' Заполнение матрицы для операции поворота
' В правосторонней системе координат
Declare Sub MatrixSetRRotate( _
	ByVal m As XFORM Ptr, _
	ByVal AngleSine As Single, _
	ByVal AngleCosine As Single _
)

' Заполнение матрицы для операции поворота
' В левосторонней системе координат
Declare Sub MatrixSetLRotate( _
	ByVal m As XFORM Ptr, _
	ByVal AngleSine As Single, _
	ByVal AngleCosine As Single _
)

' Заполнение матрицы для операции отражения
Declare Sub MatrixSetReflect( _
	ByVal m As XFORM Ptr, _
	ByVal x As Boolean, _
	ByVal y As Boolean _
)

' Заполнение матрицы для операции сдвига
Declare Sub MatrixSetShear( _
	ByVal m As XFORM Ptr, _
	ByVal Horizontal As Single, _
	ByVal Vertical As Single _
)

' Заполнение матрицы единичной матрицей
Declare Sub MatrixSetIdentity( _
	ByVal m As XFORM Ptr _
)

Declare Sub MultipleVector( _
	ByVal lpxfOut as Vector2DF Ptr, _
	ByVal lpxf1 As Const XFORM Ptr, _
	ByVal lpVec As Const Vector2DF Ptr _
)

Declare Sub ConvertVector2DFToVector2DI( _
	ByVal lpxfOut as Vector2DI Ptr, _
	ByVal lpVec As Const Vector2DF Ptr _
)

#endif
