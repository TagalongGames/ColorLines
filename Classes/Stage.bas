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
		ByVal HiScore As Integer, _
		ByVal CallBacks As StageCallBacks Ptr, _
		ByVal Context As Any Ptr _
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
				' pStage->Lines(j, i).Ball.Exist = True
			End Scope
			
			pStage->Lines(j, i).Selected = False
			
		Next
	Next
	
	pStage->Lines(0, 0).Selected = True
	pStage->SelectedCellX = 0
	pStage->SelectedCellY = 0
	
	For j As Integer = 0 To 2
		
		CopyRect(@pStage->Tablo(j).Rectangle, @pStage->Lines(j + 2, 8).Rectangle)
		OffsetRect(@pStage->Tablo(j).Rectangle, 2 * CellWidth, 0)
		
		CopyRect(@pStage->Tablo(j).Ball.Rectangle, @pStage->Lines(j + 2, 8).Ball.Rectangle)
		OffsetRect(@pStage->Tablo(j).Ball.Rectangle, 2 * CellWidth, 0)
		
		pStage->Tablo(j).Selected = False
		
		Dim RandomColor As BallColors = GetRandomBallColor()
		pStage->Tablo(j).Ball.Color = RandomColor
		pStage->Tablo(j).Ball.Exist = True
		pStage->Tablo(j).Ball.Frame = AnimationFrames.Stopped
	Next
	
	' pStage->MovedBall.Color = BallColors.Red
	pStage->MovedBall.Frame = AnimationFrames.Stopped
	' pStage->MovedBall.Rectangle = False
	pStage->MovedBall.Exist = False
	
	pStage->CallBacks = *CallBacks
	pStage->Context = Context
	pStage->Score = 0
	pStage->HiScore = HiScore
	
	Return pStage
	
End Function

Sub DestroyStage( _
		ByVal pStage As Stage Ptr _
	)
	
	Deallocate(pStage)
	
End Sub

Function StageGetCellFromPoint( _
		ByVal pStage As Stage Ptr, _
		ByVal pp As POINT Ptr, _
		ByVal pCell As POINT Ptr _
	)As Boolean
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			If PtInRect(@pStage->Lines(j, i).Rectangle, *pp) Then
				pCell->x = i
				pCell->y = j
				Return True
			End If
		Next
	Next
	
	pCell->x = 0
	pCell->y = 0
	
	Return False
	
End Function

Function StageGetWidth( _
		ByVal pStage As Stage Ptr _
	)As Integer
	
	Return pStage->Lines(0, 0).Rectangle.left + pStage->Tablo(0).Rectangle.right
	
End Function

Function StageGetHeight( _
		ByVal pStage As Stage Ptr _
	)As Integer
	
	Return pStage->Lines(0, 0).Rectangle.top + pStage->Lines(8, 0).Rectangle.bottom
	
End Function
