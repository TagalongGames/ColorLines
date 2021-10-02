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

Type Transformation
	TranslateX As Single
	TranslateY As Single
	AngleSine As Single
	AngleCosine As Single
	ScaleX As Single
	ScaleY As Single
	ReflectX As Boolean
	ReflectY As Boolean
	ShearX As Single
	ShearY As Single
End Type

Declare Sub MatrixSetShear( _
	ByVal m As XFORM Ptr, _
	ByVal Horizontal As Single, _
	ByVal Vertical As Single _
)

Declare Sub MatrixSetScale( _
	ByVal m As XFORM Ptr, _
	ByVal ScaleX As Single, _
	ByVal ScaleY As Single _
)

Declare Sub MatrixSetReflect( _
	ByVal m As XFORM Ptr, _
	ByVal x As Boolean, _
	ByVal y As Boolean _
)

Declare Sub MatrixSetRRotate( _
	ByVal m As XFORM Ptr, _
	ByVal AngleSine As Single, _
	ByVal AngleCosine As Single _
)

Declare Sub MatrixSetLRotate( _
	ByVal m As XFORM Ptr, _
	ByVal AngleSine As Single, _
	ByVal AngleCosine As Single _
)

Declare Sub MatrixSetTranslate( _
	ByVal m As XFORM Ptr, _
	ByVal dx As Single, _
	ByVal dy As Single _
)

Declare Sub MatrixSetIdentity( _
	ByVal m As XFORM Ptr _
)

Declare Sub MatrixApplyShear( _
	ByVal m As XFORM Ptr, _
	ByVal Horizontal As Single, _
	ByVal Vertical As Single _
)

Declare Sub MatrixApplyScale( _
	ByVal m As XFORM Ptr, _
	ByVal ScaleX As Single, _
	ByVal ScaleY As Single _
)

Declare Sub MatrixApplyReflect( _
	ByVal m As XFORM Ptr, _
	ByVal x As Boolean, _
	ByVal y As Boolean _
)

Declare Sub MatrixApplyRRotate( _
	ByVal m As XFORM Ptr, _
	ByVal AngleSine As Single, _
	ByVal AngleCosine As Single _
)

Declare Sub MatrixApplyLRotate( _
	ByVal m As XFORM Ptr, _
	ByVal AngleSine As Single, _
	ByVal AngleCosine As Single _
)

Declare Sub MatrixApplyTranslate( _
	ByVal m As XFORM Ptr, _
	ByVal dx As Single, _
	ByVal dy As Single _
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

Declare Sub SetPositionMatrix( _
	ByVal m As XFORM Ptr, _
	ByVal pPosition As Transformation Ptr _
)

#endif
