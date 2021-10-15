#include once "Stage.bi"
#include once "GdiMatrix.bi"
' #include once "crt.bi"

Const CellWidth As Long = 40
Const CellHeight As Long = 40
Const BallWidth As Long = 30
Const BallHeight As Long = 30
Const BallMarginWidth As Long = (CellWidth - BallWidth) \ 2
Const BallMarginHeight As Long = (CellHeight - BallHeight) \ 2
Const Sine45   = 0.70710678118654752440084436210485
Const Cosine45 = 0.70710678118654752440084436210485

Function GenerateRandomColorBallKind( _
	)As ColorBallKind
	
	Dim RndValue As Long = rand()
	
	Return Cast(ColorBallKind, RndValue Mod 7)
	
End Function

Sub CellInitialize( _
		ByVal pCell As ColorCell Ptr, _
		ByVal xCoord As Integer, _
		ByVal yCoord As Integer _
	)
	
	Dim CellRectangle As RECT = Any
	SetRect(@CellRectangle, _
		-1 * (CellWidth \ 2), _
		-1 * (CellHeight \ 2), _
		CellWidth \ 2, _
		CellHeight \ 2 _
	)
	
	CopyRect(@pCell->Bounds, @CellRectangle)
	
	MatrixSetIdentity(@pCell->Position)
	MatrixApplyTranslate( _
		@pCell->Position, _
		CSng(xCoord * CellWidth + CellWidth \ 2), _
		CSng(yCoord * CellHeight + CellHeight \ 2) _
	)
	
	pCell->Selected = False
	pCell->Pressed = False
	
End Sub

Sub BallInitialize( _
		ByVal pBall As ColorBall Ptr, _
		ByVal xCoord As Integer, _
		ByVal yCoord As Integer _
	)
	
	Dim BallRectangle As RECT = Any
	SetRect(@BallRectangle, _
		-1 * (BallWidth \ 2), _
		-1 * (BallHeight \ 2), _
		BallWidth \ 2, _
		BallHeight \ 2 _
	)
	
	CopyRect(@pBall->Bounds, @BallRectangle)
	
	MatrixSetIdentity(@pBall->Position)
	MatrixApplyRRotate( _
		@pBall->Position, _
		Sine45, _
		Cosine45 _
	)
	MatrixApplyTranslate( _
		@pBall->Position, _
		CSng(xCoord * CellWidth + CellWidth \ 2 - 1), _
		CSng(yCoord * CellHeight + CellHeight \ 2 - 1) _
	)
	
	Dim RandomColor As ColorBallKind = GenerateRandomColorBallKind()
	pBall->Kind = RandomColor
	pBall->Frame = AnimationFrames.Stopped
	pBall->Visible = False
	pBall->Selected = False
	
End Sub

Function StageGetEmptyCells( _
		ByVal pStage As Stage Ptr, _
		ByVal pEmptyCells As SquareCoord Ptr _
	)As Integer
	
	Dim EmptyCellsCount As Integer = 0
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			If pStage->Balls(j, i).Visible = False Then
				pEmptyCells[EmptyCellsCount].x = i
				pEmptyCells[EmptyCellsCount].y = j
				EmptyCellsCount += 1
			End If
		Next
	Next
	
	Return EmptyCellsCount
	
End Function

Sub StageRandomizeCells( _
		ByVal pCells As SquareCoord Ptr, _
		ByVal Length As Integer _
	)
	
	For i As Integer = 0 To Length - 1
		Dim RandomIndex As Integer = rand() Mod Length
		
		Dim t As SquareCoord = pCells[i]
		pCells[i] = pCells[RandomIndex]
		pCells[RandomIndex] = t
	Next
	
End Sub

Function CreateStage( _
		ByVal HiScore As Integer _
	)As Stage Ptr
	
	Dim pStage As Stage Ptr = Allocate(SizeOf(Stage))
	If pStage = NULL Then
		Return NULL
	End If
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			CellInitialize(@pStage->Cells(j, i), i, j)
			BallInitialize(@pStage->Balls(j, i), i, j)
		Next
	Next
	
	For j As Integer = 0 To 2
		CellInitialize(@pStage->TabloCells(j), 10, j + 1)
		BallInitialize(@pStage->TabloBalls(j), 10, j + 1)
		pStage->TabloBalls(j).Visible = True
	Next
	
	BallInitialize(@pStage->MovedBall, 0, 0)
	
	pStage->Score = 0
	pStage->HiScore = HiScore
	
	For i As Integer = 0 To 2
		Dim pt As SquareCoord = Any
		StageGetRandomEmptyCellCoord(pStage, @pt)
		pStage->Balls(pt.y, pt.x).Visible = True
	Next
	
	Return pStage
	
End Function

Sub DestroyStage( _
		ByVal pStage As Stage Ptr _
	)
	
	Deallocate(pStage)
	
End Sub

Sub StageGetBounds( _
		ByVal pStage As Stage Ptr, _
		ByVal pBounds As RECT Ptr _
	)
	
	SetRect( _
		pBounds, _
		0, _
		0, _
		CellWidth * 9 + CellWidth + CellWidth, _
		CellHeight * 9 _
	)
	
End Sub

Function StageGetRandomEmptyCellCoord( _
		ByVal pStage As Stage Ptr, _
		ByVal pp As SquareCoord Ptr _
	)As Boolean
	
	Dim EmptyCells(0 To 9 * 9 - 1) As SquareCoord = Any
	Dim EmptyCellsCount As Integer = StageGetEmptyCells( _
		pStage, _
		@EmptyCells(0) _
	)
	If EmptyCellsCount = 0 Then
		Return False
	End If
	
	StageRandomizeCells(@EmptyCells(0), EmptyCellsCount)
	
	Dim RandomIndex As Integer = rand() Mod EmptyCellsCount
	*pp = EmptyCells(RandomIndex)
	
	Return True
	
End Function

Function RowSequenceLength( _
		ByVal pStage As Stage Ptr, _
		ByVal X As Integer, _
		ByVal Y As Integer, _
		ByVal BallColor As ColorBallKind _
	)As Integer
	
	If X > 8 Then
		Return 0
	End If
	
	If pStage->Balls(Y, X).Visible = False Then
		Return 0
	End If
	
	If pStage->Balls(Y, X).Kind <> BallColor Then
		Return 0
	End If
	
	Return 1 + RowSequenceLength(pStage, X + 1, Y, BallColor)
	
End Function

Function ColSequenceLength( _
		ByVal pStage As Stage Ptr, _
		ByVal X As Integer, _
		ByVal Y As Integer, _
		ByVal BallColor As ColorBallKind _
	)As Integer
	
	If Y > 8 Then
		Return 0
	End If
	
	If pStage->Balls(Y, X).Visible = False Then
		Return 0
	End If
	
	If pStage->Balls(Y, X).Kind <> BallColor Then
		Return 0
	End If
	
	Return 1 + ColSequenceLength(pStage, X, Y + 1, BallColor)
	
End Function

Function ForwardDiagonalSequenceLength( _
		ByVal pStage As Stage Ptr, _
		ByVal X As Integer, _
		ByVal Y As Integer, _
		ByVal BallColor As ColorBallKind _
	)As Integer
	
	If Y > 8 Then
		Return 0
	End If
	
	If X > 8 Then
		Return 0
	End If
	
	If pStage->Balls(Y, X).Visible = False Then
		Return 0
	End If
	
	If pStage->Balls(Y, X).Kind <> BallColor Then
		Return 0
	End If
	
	Return 1 + ForwardDiagonalSequenceLength(pStage, X + 1, Y + 1, BallColor)
	
End Function

Function BackwardDiagonalSequenceLength( _
		ByVal pStage As Stage Ptr, _
		ByVal X As Integer, _
		ByVal Y As Integer, _
		ByVal BallColor As ColorBallKind _
	)As Integer
	
	If Y > 8 Then
		Return 0
	End If
	
	If X < 0 Then
		Return 0
	End If
	
	If pStage->Balls(Y, X).Visible = False Then
		Return 0
	End If
	
	If pStage->Balls(Y, X).Kind <> BallColor Then
		Return 0
	End If
	
	Return 1 + BackwardDiagonalSequenceLength(pStage, X - 1, Y + 1, BallColor)
	
End Function
