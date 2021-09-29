#include once "Stage.bi"
' #include once "crt.bi"

Const CellWidth As UINT = 40
Const CellHeight As UINT = 40
Const BallWidth As UINT = 30
Const BallHeight As UINT = 30
Const BallMarginWidth As UINT = (CellWidth - BallWidth) \ 2
Const BallMarginHeight As UINT = (CellHeight - BallHeight) \ 2
Const Sine45   = 0.70710678118654752440084436210485
Const Cosine45 = 0.70710678118654752440084436210485

Function GetRandomBoolean()As Boolean
	
	Dim RndValue As Long = rand()
	
	If RndValue > RAND_MAX \ 2 Then
		Return True
	End If
	
	Return False
	
End Function

Function GetRandomBallColor()As BallColors
	
	Dim RndValue As Long = rand()
	
	Return Cast(BallColors, RndValue Mod 7)
	
End Function

Function CreateStage( _
		ByVal HiScore As Integer _
	)As Stage Ptr
	
	Dim pStage As Stage Ptr = Allocate(SizeOf(Stage))
	If pStage = NULL Then
		Return NULL
	End If
	
	Dim CellRectangle As RECT = Any
	SetRect(@CellRectangle, _
		-1 * CellWidth \ 2, _
		-1 * CellHeight \ 2, _
		CellWidth \ 2, _
		CellHeight \ 2 _
	)
	Dim BallRectangle As RECT = Any
	SetRect(@BallRectangle, _
		-1 * BallWidth \ 2, _
		-1 * BallHeight \ 2, _
		BallWidth \ 2, _
		BallHeight \ 2 _
	)
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			CopyRect(@pStage->Lines(j, i).Bounds, @CellRectangle)
			pStage->Lines(j, i).Position.TranslateX = CSng(i * CellWidth + CellWidth \ 2)
			pStage->Lines(j, i).Position.TranslateY = CSng(j * CellHeight + CellHeight \ 2)
			pStage->Lines(j, i).Position.AngleSine = 0.0
			pStage->Lines(j, i).Position.AngleCosine = 1.0
			pStage->Lines(j, i).Position.ScaleX = 1.0
			pStage->Lines(j, i).Position.ScaleY = 1.0
			pStage->Lines(j, i).Position.ReflectX = False
			pStage->Lines(j, i).Position.ReflectY = False
			pStage->Lines(j, i).Position.ShearX = 0.0
			pStage->Lines(j, i).Position.ShearY = 0.0
			
			Scope
				' pStage->Lines(j, i).Ball.Color = BallColors.Red
				pStage->Lines(j, i).Ball.Frame = AnimationFrames.Stopped
				
				CopyRect(@pStage->Lines(j, i).Ball.Bounds, @BallRectangle)
				pStage->Lines(j, i).Ball.Position.TranslateX = CSng(i * CellWidth + CellWidth \ 2)
				pStage->Lines(j, i).Ball.Position.TranslateY = CSng(j * CellHeight + CellHeight \ 2)
				pStage->Lines(j, i).Ball.Position.AngleSine = Sine45
				pStage->Lines(j, i).Ball.Position.AngleCosine = Cosine45
				pStage->Lines(j, i).Ball.Position.ScaleX = 1.0
				pStage->Lines(j, i).Ball.Position.ScaleY = 1.0
				pStage->Lines(j, i).Ball.Position.ReflectX = False
				pStage->Lines(j, i).Ball.Position.ReflectY = False
				pStage->Lines(j, i).Ball.Position.ShearX = 0.0
				pStage->Lines(j, i).Ball.Position.ShearY = 0.0
				
				' pStage->Lines(j, i).Ball.Visible = True
				' pStage->Lines(j, i).Ball.Selected = False
			End Scope
			
			pStage->Lines(j, i).Selected = False
			pStage->Lines(j, i).Pressed = False
			
		Next
	Next
	
	For j As Integer = 0 To 2
		
		CopyRect(@pStage->Tablo(j).Bounds, @CellRectangle)
		pStage->Tablo(j).Position.TranslateX = CSng(10 * CellWidth + CellWidth \ 2)
		pStage->Tablo(j).Position.TranslateY = CSng((j + 1) * CellHeight + CellHeight \ 2)
		pStage->Tablo(j).Position.AngleSine = 0.0
		pStage->Tablo(j).Position.AngleCosine = 1.0
		pStage->Tablo(j).Position.ScaleX = 1.0
		pStage->Tablo(j).Position.ScaleY = 1.0
		pStage->Tablo(j).Position.ReflectX = False
		pStage->Tablo(j).Position.ReflectY = False
		pStage->Tablo(j).Position.ShearX = 0.0
		pStage->Tablo(j).Position.ShearY = 0.0
		
		CopyRect(@pStage->Tablo(j).Ball.Bounds, @BallRectangle)
		pStage->Tablo(j).Ball.Position.TranslateX = CSng(10 * CellWidth + CellWidth \ 2)
		pStage->Tablo(j).Ball.Position.TranslateY = CSng((j + 1) * CellHeight + CellHeight \ 2)
		pStage->Tablo(j).Ball.Position.AngleSine = Sine45
		pStage->Tablo(j).Ball.Position.AngleCosine = Cosine45
		pStage->Tablo(j).Ball.Position.ScaleX = 1.0
		pStage->Tablo(j).Ball.Position.ScaleY = 1.0
		pStage->Tablo(j).Ball.Position.ReflectX = False
		pStage->Tablo(j).Ball.Position.ReflectY = False
		pStage->Tablo(j).Ball.Position.ShearX = 0.0
		pStage->Tablo(j).Ball.Position.ShearY = 0.0
		
		Dim RandomColor As BallColors = GetRandomBallColor()
		pStage->Tablo(j).Ball.Color = RandomColor
		pStage->Tablo(j).Ball.Frame = AnimationFrames.Stopped
		pStage->Tablo(j).Ball.Visible = True
		pStage->Tablo(j).Ball.Selected = False
		pStage->Tablo(j).Selected = False
	Next
	
	' pStage->MovedBall.Color = BallColors.Red
	pStage->MovedBall.Frame = AnimationFrames.Stopped
	CopyRect(@pStage->MovedBall.Bounds, @BallRectangle)
	pStage->MovedBall.Visible = False
	pStage->MovedBall.Selected = False
	
	pStage->Score = 0
	pStage->HiScore = HiScore
	
	Return pStage
	
End Function

Sub DestroyStage( _
		ByVal pStage As Stage Ptr _
	)
	
	Deallocate(pStage)
	
End Sub

Function StageGetWidth( _
		ByVal pStage As Stage Ptr _
	)As Integer
	
	Return CellWidth * 9 + CellWidth + CellWidth
	
End Function

Function StageGetHeight( _
		ByVal pStage As Stage Ptr _
	)As Integer
	
	Return CellHeight * 9
	
End Function

Function StageGetRandomEmptyCellCoord( _
		ByVal pStage As Stage Ptr, _
		ByVal pp As POINT Ptr _
	)As Boolean
	
	Dim EmptyCells(0 To 9 * 9 - 1) As POINT = Any
	Dim EmptyCellsCount As Integer = 0
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			If pStage->Lines(j, i).Ball.Visible = False Then
			' Vector(i) = i
			End If
		Next
	Next
	
	If EmptyCellsCount = 0 Then
		Return False
	End If
	
	Dim RndValue As Long = rand()
	
	Return CInt(RndValue Mod 9)
	
End Function
