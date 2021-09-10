#include once "Stage.bi"

Function GetRandomBoolean()As Boolean
	
	Dim RndValue As Long = rand()
	
	If RndValue > RAND_MAX \ 2 Then
		Return True
	End If
	
	Return False
	
End Function

Function GetRandomBallColor()As BallColors
	
	Const SevenPart As Long = RAND_MAX \ 7
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
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			' Dim RndExists As Boolean = GetRandomBoolean()
			pStage->Lines(j, i).Ball.Exist = True 'RndExists
			
			Dim RndColor As BallColors = GetRandomBallColor()
			pStage->Lines(j, i).Ball.Color = RndColor
		Next
	Next
	
	' Три случайных цвета
	
	
	Return pStage
	
End Function

Sub DestroyStage( _
		ByVal pStage As Stage Ptr _
	)
	
	Deallocate(pStage)
	
End Sub

Sub StageRecalculateSizes( _
		ByVal pStage As Stage Ptr, _
		ByVal SceneWidth As UINT, _
		ByVal SceneHeight As UINT _
	)
	
	'Scale = max(nHeight \ 480, 1)
	
	Dim SquareLength As UINT = min(SceneWidth, SceneHeight)
	
	Dim CellWidth As UINT = max(40, (SquareLength - 100) \ 9)
	Dim CellHeight As UINT = max(40, (SquareLength - 100) \ 9)
	
	Dim BallMarginWidth As UINT = max(2, CellWidth \ 20)
	Dim BallMarginHeight As UINT = max(2, CellHeight \ 20)
	
	Dim BallWidth As UINT = CellWidth - BallMarginWidth
	Dim BallHeight As UINT = CellHeight - BallMarginHeight
	
	' Ячейка
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			SetRect(@pStage->Lines(j, i).CellRectangle, _
				i * CellWidth, _
				j * CellHeight, _
				i * CellWidth + CellWidth, _
				j * CellHeight + CellHeight _
			)
		Next
	Next
	
	' Шар
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			SetRect(@pStage->Lines(j, i).Ball.BallRectangle, _
				i * CellWidth + BallMarginWidth, _
				j * CellHeight + BallMarginHeight, _
				i * CellWidth + BallWidth, _
				j * CellHeight + BallHeight _
			)
		Next
	Next
	
End Sub

Function StageGetCellFromPoint( _
		ByVal pStage As Stage Ptr, _
		ByVal pp As POINT Ptr, _
		ByVal pCell As POINT Ptr _
	)As Boolean
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			If PtInRect(@pStage->Lines(j, i).CellRectangle, *pp) Then
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
