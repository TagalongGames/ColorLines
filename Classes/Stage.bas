#include once "Stage.bi"
' #include once "crt.bi"

Const CellWidth As UINT = 40
Const CellHeight As UINT = 40
Const BallWidth As UINT = 30
Const BallHeight As UINT = 30
Const BallMarginWidth As UINT = (CellWidth - BallWidth) \ 2
Const BallMarginHeight As UINT = (CellHeight - BallHeight) \ 2

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

Function GetRandomStageX()As Integer
	
	Dim RndValue As Long = rand()
	
	Return CInt(RndValue Mod 9)
	
End Function

Function GetRandomStageY()As Integer
	
	Dim RndValue As Long = rand()
	
	Return CInt(RndValue Mod 9)
	
End Function

Function CreateStage( _
		ByVal HiScore As Integer _
	)As Stage Ptr
	
	Dim pStage As Stage Ptr = Allocate(SizeOf(Stage))
	If pStage = NULL Then
		Return NULL
	End If
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			SetRect(@pStage->Lines(j, i).Rectangle, _
				i * CellWidth, _
				j * CellHeight, _
				i * CellWidth + CellWidth, _
				j * CellHeight + CellHeight _
			)
			
			Scope
				' pStage->Lines(j, i).Ball.Color = BallColors.Red
				pStage->Lines(j, i).Ball.Frame = AnimationFrames.Stopped
				
				SetRect(@pStage->Lines(j, i).Ball.Rectangle, _
					i * CellWidth + BallMarginWidth, _
					j * CellHeight + BallMarginHeight, _
					i * CellWidth + CellWidth - BallMarginWidth, _
					j * CellHeight + CellHeight - BallMarginHeight _
				)
				' pStage->Lines(j, i).Ball.Visible = True
				' pStage->Lines(j, i).Ball.Selected = False
			End Scope
			
			pStage->Lines(j, i).Selected = False
			pStage->Lines(j, i).Pressed = False
			
		Next
	Next
	
	For j As Integer = 0 To 2
		
		CopyRect(@pStage->Tablo(j).Rectangle, @pStage->Lines(j + 2, 8).Rectangle)
		OffsetRect(@pStage->Tablo(j).Rectangle, 2 * CellWidth, 0)
		
		CopyRect(@pStage->Tablo(j).Ball.Rectangle, @pStage->Lines(j + 2, 8).Ball.Rectangle)
		OffsetRect(@pStage->Tablo(j).Ball.Rectangle, 2 * CellWidth, 0)
		
		Dim RandomColor As BallColors = GetRandomBallColor()
		pStage->Tablo(j).Ball.Color = RandomColor
		pStage->Tablo(j).Ball.Frame = AnimationFrames.Stopped
		pStage->Tablo(j).Ball.Visible = True
		pStage->Tablo(j).Ball.Selected = False
		pStage->Tablo(j).Selected = False
	Next
	
	' pStage->MovedBall.Color = BallColors.Red
	pStage->MovedBall.Frame = AnimationFrames.Stopped
	' pStage->MovedBall.Rectangle = False
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
