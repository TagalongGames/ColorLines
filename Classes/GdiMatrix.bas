#include once "GdiMatrix.bi"
#include once "win\ole2.bi"
#include once "win\oleauto.bi"

Sub MatrixSetScale( _
		ByVal m As XFORM Ptr, _
		ByVal ScaleX As Single, _
		ByVal ScaleY As Single _
	)
	
	m->eM11 = ScaleX : m->eM21 = 0.0    : m->eDx = 0.0
	m->eM12 = 0.0    : m->eM22 = ScaleY : m->eDy = 0.0
	' 0              : 0                : 1
	
End Sub

Sub MatrixSetTranslate( _
		ByVal m As XFORM Ptr, _
		ByVal dx As Single, _
		ByVal dy As Single _
	)
	
	m->eM11 = 1.0 : m->eM21 = 0.0 : m->eDx = dx
	m->eM12 = 0.0 : m->eM22 = 1.0 : m->eDy = dy
	' 0           : 0             : 1
	
End Sub

Sub MatrixSetRRotate( _
		ByVal m As XFORM Ptr, _
		ByVal AngleSine As Single, _
		ByVal AngleCosine As Single _
	)
	
	m->eM11 = AngleCosine : m->eM21 = -1.0 * AngleSine : m->eDx = 0.0
	m->eM12 = AngleSine   : m->eM22 = AngleCosine      : m->eDy = 0.0
	' 0                   : 0                          : 1
	
End Sub

Sub MatrixSetLRotate( _
		ByVal m As XFORM Ptr, _
		ByVal AngleSine As Single, _
		ByVal AngleCosine As Single _
	)
	
	m->eM11 = AngleCosine      : m->eM21 = AngleSine   : m->eDx = 0.0
	m->eM12 = -1.0 * AngleSine : m->eM22 = AngleCosine : m->eDy = 0.0
	' 0                        : 0                     : 1
	
End Sub

Sub MatrixSetReflect( _
		ByVal m As XFORM Ptr, _
		ByVal x As Boolean, _
		ByVal y As Boolean _
	)
	
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

Sub MatrixSetShear( _
		ByVal m As XFORM Ptr, _
		ByVal Horizontal As Single, _
		ByVal Vertical As Single _
	)
	
	m->eM11 = 1.0        : m->eM21 = Vertical : m->eDx = 0.0
	m->eM12 = Horizontal : m->eM22 = 1.0      : m->eDy = 0.0
	' 0                  : 0                  : 1
	
End Sub

Sub MatrixSetIdentity( _
		ByVal m As XFORM Ptr _
	)
	
	m->eM11 = 1.0 : m->eM21 = 0.0 : m->eDx = 0.0
	m->eM12 = 0.0 : m->eM22 = 1.0 : m->eDy = 0.0
	' 0           : 0             : 1
	
End Sub

Sub MatrixApplyShear( _
		ByVal m As XFORM Ptr, _
		ByVal Horizontal As Single, _
		ByVal Vertical As Single _
	)
	
	Dim ShearMatrix As XFORM = Any
	MatrixSetShear(@ShearMatrix, Horizontal, Vertical)
	CombineTransform(m, m, @ShearMatrix)
	
End Sub

Sub MatrixApplyScale( _
		ByVal m As XFORM Ptr, _
		ByVal ScaleX As Single, _
		ByVal ScaleY As Single _
	)
	
	Dim ScaleMatrix As XFORM = Any
	MatrixSetScale(@ScaleMatrix, ScaleX, ScaleY)
	CombineTransform(m, m, @ScaleMatrix)
	
End Sub

Sub MatrixApplyReflect( _
		ByVal m As XFORM Ptr, _
		ByVal x As Boolean, _
		ByVal y As Boolean _
	)
	
	Dim ReflectMatrix As XFORM = Any
	MatrixSetReflect(@ReflectMatrix, x, y)
	CombineTransform(m, m, @ReflectMatrix)
	
End Sub

Sub MatrixApplyRRotate( _
		ByVal m As XFORM Ptr, _
		ByVal AngleSine As Single, _
		ByVal AngleCosine As Single _
	)
	
	Dim RotationMatrix As XFORM = Any
	MatrixSetRRotate(@RotationMatrix, AngleSine, AngleCosine)
	CombineTransform(m, m, @RotationMatrix)
	
End Sub

Sub MatrixApplyLRotate( _
		ByVal m As XFORM Ptr, _
		ByVal AngleSine As Single, _
		ByVal AngleCosine As Single _
	)
	
	Dim RotationMatrix As XFORM = Any
	MatrixSetLRotate(@RotationMatrix, AngleSine, AngleCosine)
	CombineTransform(m, m, @RotationMatrix)
	
End Sub

Sub MatrixApplyTranslate( _
		ByVal m As XFORM Ptr, _
		ByVal dx As Single, _
		ByVal dy As Single _
	)
	
	Dim TranslationMatrix As XFORM = Any
	MatrixSetTranslate(@TranslationMatrix, dx, dy)
	CombineTransform(m, m, @TranslationMatrix)
	
End Sub

Sub MultipleVector( _
		ByVal lpxfOut as Vector2DF Ptr, _
		ByVal lpxf1 As Const XFORM Ptr, _
		ByVal lpVec As Const Vector2DF Ptr _
	)
	
	lpxfOut->X = lpVec->X * lpxf1->eM11 + lpVec->X * lpxf1->eM21 + lpxf1->eDx
	lpxfOut->Y = lpVec->X * lpxf1->eM12 + lpVec->Y * lpxf1->eM22 + lpxf1->eDy
	
End Sub

Sub ConvertVector2DFToVector2DI( _
		ByVal lpxfOut as Vector2DI Ptr, _
		ByVal lpVec As Const Vector2DF Ptr _
	)
	
	Dim fX As VARIANT = Any
	fX.vt = VT_R4
	fX.fltVal = lpVec->X
	
	Dim nX As VARIANT = Any
	VariantInit(@nX)
	VariantChangeType(@nX, @fX, 0, VT_I4)
	
	Dim fY As VARIANT = Any
	fY.vt = VT_R4
	fY.fltVal = lpVec->Y
	
	Dim nY As VARIANT = Any
	VariantInit(@nY)
	VariantChangeType(@nY, @fY, 0, VT_I4)
	
	lpxfOut->X = nX.lVal
	lpxfOut->Y = nY.lVal
	
End Sub

Sub SetPositionMatrix( _
		ByVal m As XFORM Ptr, _
		ByVal pPosition As Transformation Ptr _
	)
	
	Dim WorldMatrix As XFORM = Any
	Scope
		MatrixSetIdentity(@WorldMatrix)
	End Scope
	
	Scope
		Dim ShearMatrix As XFORM = Any
		MatrixSetShear(@ShearMatrix, pPosition->ShearX, pPosition->ShearY)
		
		CombineTransform(@WorldMatrix, @WorldMatrix, @ShearMatrix)
	End Scope
	
	Scope
		Dim ScaleMatrix As XFORM = Any
		MatrixSetScale(@ScaleMatrix, pPosition->ScaleX, pPosition->ScaleY)
		
		CombineTransform(@WorldMatrix, @WorldMatrix, @ScaleMatrix)
	End Scope
	
	Scope
		Dim ReflectMatrix As XFORM = Any
		MatrixSetReflect(@ReflectMatrix, pPosition->ReflectX, pPosition->ReflectY)
		
		CombineTransform(@WorldMatrix, @WorldMatrix, @ReflectMatrix)
	End Scope
	
	Scope
		Dim RotationMatrix As XFORM = Any
		MatrixSetRRotate(@RotationMatrix, pPosition->AngleSine, pPosition->AngleCosine)
		
		CombineTransform(@WorldMatrix, @WorldMatrix, @RotationMatrix)
	End Scope
	
	Scope
		Dim TranslationMatrix As XFORM = Any
		MatrixSetTranslate(@TranslationMatrix, pPosition->TranslateX, pPosition->TranslateY)
		
		CombineTransform(@WorldMatrix, @WorldMatrix, @TranslationMatrix)
	End Scope
	
	*m = WorldMatrix
	
End Sub
