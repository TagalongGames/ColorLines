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

Sub CellInitialize( _
		ByVal pCell As Cell Ptr, _
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
	
	MatrixSetIdentity(@pCell->PositionMatrix)
	MatrixApplyTranslate( _
		@pCell->PositionMatrix, _
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
	
	MatrixSetIdentity(@pBall->PositionMatrix)
	MatrixApplyRRotate( _
		@pBall->PositionMatrix, _
		Sine45, _
		Cosine45 _
	)
	MatrixApplyTranslate( _
		@pBall->PositionMatrix, _
		CSng(xCoord * CellWidth + CellWidth \ 2 - 1), _
		CSng(yCoord * CellHeight + CellHeight \ 2 - 1) _
	)
	
	Dim RandomColor As BallColors = GetRandomBallColor()
	pBall->Color = RandomColor
	pBall->Frame = AnimationFrames.Stopped
	pBall->Visible = False
	pBall->Selected = False
	
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
			CellInitialize(@pStage->Lines(j, i), i, j)
			BallInitialize(@pStage->Lines(j, i).Ball, i, j)
		Next
	Next
	
	For j As Integer = 0 To 2
		CellInitialize(@pStage->Tablo(j), 10, j + 1)
		BallInitialize(@pStage->Tablo(j).Ball, 10, j + 1)
		pStage->Tablo(j).Ball.Visible = True
	Next
	
	BallInitialize(@pStage->MovedBall, 0, 0)
	
	pStage->Score = 0
	pStage->HiScore = HiScore
	
	For i As Integer = 0 To 2
		Dim pt As POINT = Any
		StageGetRandomEmptyCellCoord(pStage, @pt)
		pStage->Lines(pt.y, pt.x).Ball.Visible = True
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
		ByVal pp As POINT Ptr _
	)As Boolean
	
	' Получить список пустых ячеек
	Dim EmptyCells(0 To 9 * 9 - 1) As POINT = Any
	Dim EmptyCellsCount As Integer = 0
	
	For j As Integer = 0 To 8
		For i As Integer = 0 To 8
			If pStage->Lines(j, i).Ball.Visible = False Then
				EmptyCells(EmptyCellsCount).x = i
				EmptyCells(EmptyCellsCount).y = j
				EmptyCellsCount += 1
			End If
		Next
	Next
	
	If EmptyCellsCount = 0 Then
		Return False
	End If
	
	' Перетасовать список
	For i As Integer = 0 To EmptyCellsCount - 1
		Dim RandomNumber As Integer = rand() Mod EmptyCellsCount
		
		Dim t As POINT = EmptyCells(i)
		EmptyCells(i) = EmptyCells(RandomNumber)
		EmptyCells(RandomNumber) = t
	Next
	
	' Вернуть случайную ячейку из списка
	Dim RandomNumber As Integer = rand() Mod EmptyCellsCount
	*pp = EmptyCells(RandomNumber)
	
	Return True
	
End Function
